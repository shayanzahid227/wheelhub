// ignore_for_file: unnecessary_string_interpolations

import 'dart:convert';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hustler_syn/core/model/notification_item_model.dart';
import 'package:hustler_syn/core/services/data_base_services.dart';
import 'package:hustler_syn/core/services/local_storagre_services.dart';
import 'package:hustler_syn/locator.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Handles FCM + local notifications; saves every notification to storage for Notification screen.
/// Set [onNavigateFromNotification] from app startup to open the right screen when user taps a notification.
class NotificationService {
  /// Called when user opens app from a notification (tap). Parameters: type (message|payment|order), data map.
  static void Function(String type, Map<String, dynamic> data)? onNavigateFromNotification;

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _local = FlutterLocalNotificationsPlugin();
  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'hustler_sync_channel',
    'HustlerSync Notifications',
    description: 'Messages, payments and order updates',
    importance: Importance.high,
    playSound: true,
  );

  static const AndroidInitializationSettings _androidInit =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  static const DarwinInitializationSettings _iosInit =
      DarwinInitializationSettings(
    requestAlertPermission: true,
    requestBadgePermission: true,
  );

  /// Notify listeners so Notification screen can refresh.
  final ValueNotifier<int> notificationCount = ValueNotifier(0);

  LocalStorageService get _storage => locator<LocalStorageService>();
  DatabaseServices get _db => locator<DatabaseServices>();

  static String get _platform => Platform.isIOS ? 'ios' : 'android';

  Future<void> init() async {
    await _initLocalNotifications();
    await _requestPermission();
    await _fcm.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
    final token = await _fcm.getToken();
    debugPrint('[FCM] Token: ${token != null ? "${token.toString()}" : null}');

    _registerTokenWithBackend(token);
    _fcm.onTokenRefresh.listen((newToken) {
      debugPrint('[FCM] Token refreshed, re-registering with backend.');
      _registerTokenWithBackend(newToken);
    });
    if (_storage.isLoggedIn && token != null) {
      debugPrint('[FCM] Logged in – token sent to backend. Check logs for "Backend registration failed" if no notifications.');
    }

    FirebaseMessaging.onMessage.listen(_onForegroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_onMessageOpenedApp);
    final initial = await FirebaseMessaging.instance.getInitialMessage();
    if (initial != null) {
      _saveAndHandle(initial);
      _scheduleNavigateFromPayload(initial.data);
    }

    _updateCount();
  }

  void _scheduleNavigateFromPayload(Map<String, dynamic> data) {
    if (data.isEmpty) return;
    final type = (data['type'] ?? data['notification_type'] ?? '').toString();
    if (type.isEmpty) return;
    Future.delayed(const Duration(milliseconds: 800), () {
      onNavigateFromNotification?.call(type, _stringifyData(data));
    });
  }

  static Map<String, dynamic> _stringifyData(Map<String, dynamic> data) {
    return data.map((k, v) => MapEntry(k, v?.toString() ?? ''));
  }

  void _registerTokenWithBackend(String? token) {
    if (token == null || token.isEmpty) return;
    if (!_storage.isLoggedIn) {
      debugPrint('[FCM] Not logged in, skipping backend token registration.');
      return;
    }
    _db.registerFcmToken(token, _platform).then((res) {
      if (res.success) {
        debugPrint('[FCM] Token registered with backend OK.');
      } else {
        debugPrint('[FCM] Backend registration failed: ${res.message} – ensure backend has POST /api/notifications/register-token and FCM service account.');
      }
    });
  }

  /// Call after login/register so backend has the device token for push.
  Future<void> registerTokenWithBackendIfNeeded() async {
    final token = await getToken();
    _registerTokenWithBackend(token);
  }

  /// Ask backend to send a test push to this device (for debugging).
  /// Returns null on success, or the backend error message on failure (e.g. "Notifications are not configured").
  Future<String?> sendTestNotification() async {
    final res = await _db.sendNotificationToSelf(
      title: 'Test',
      body: 'If you see this, FCM is working.',
      data: {'type': 'test'},
    );
    if (res.success) return null;
    return res.message ?? 'Backend error';
  }

  Future<void> _initLocalNotifications() async {
    final initSettings = InitializationSettings(
      android: _androidInit,
      iOS: _iosInit,
    );
    await _local.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );
    if (Platform.isAndroid) {
      await _local
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(_channel);
    }
  }

  Future<void> _requestPermission() async {
    final settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    debugPrint('[FCM] Permission: ${settings.authorizationStatus}');
    if (Platform.isIOS) return;
    final plugin = _local.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (plugin != null) await plugin.requestNotificationsPermission();
  }

  void _onForegroundMessage(RemoteMessage message) {
    _saveAndHandle(message);
    final notif = message.notification;
    if (notif != null) {
      _local.show(
        message.hashCode.abs().remainder(100000),
        notif.title ?? 'Notification',
        notif.body ?? '',
        NotificationDetails(
          android: AndroidNotificationDetails(
            _channel.id,
            _channel.name,
            channelDescription: _channel.description,
            importance: Importance.high,
          ),
          iOS: const DarwinNotificationDetails(),
        ),
        payload: json.encode(message.data),
      );
    }
    _updateCount();
  }

  void _onMessageOpenedApp(RemoteMessage message) {
    _saveAndHandle(message);
    _updateCount();
    _navigateFromPayload(message.data);
  }

  void _onNotificationTap(NotificationResponse response) {
    _updateCount();
    final payload = response.payload;
    if (payload != null && payload.isNotEmpty) {
      try {
        final decoded = json.decode(payload) as Map<String, dynamic>?;
        if (decoded != null && decoded.isNotEmpty) {
          _navigateFromPayload(Map<String, dynamic>.from(decoded));
        }
      } catch (_) {}
    }
  }

  void _navigateFromPayload(Map<String, dynamic> data) {
    if (data.isEmpty) return;
    final type = (data['type'] ?? data['notification_type'] ?? '').toString().toLowerCase();
    if (type.isEmpty) return;
    onNavigateFromNotification?.call(type, _stringifyData(data));
  }

  void _saveAndHandle(RemoteMessage message) {
    final id = message.messageId ?? DateTime.now().millisecondsSinceEpoch.toString();
    final title = message.notification?.title ?? message.data['title'] ?? 'Notification';
    final body = message.notification?.body ?? message.data['body'] ?? '';
    final type = message.data['type'] ?? message.data['notification_type'] ?? 'general';
    final item = NotificationItem(
      id: id,
      title: title,
      body: body,
      type: type,
      data: message.data.isNotEmpty ? message.data : null,
      createdAt: DateTime.now(),
      read: false,
    );
    _storage.addNotification(item);
  }

  void _updateCount() {
    notificationCount.value = _storage.unreadNotificationCount;
  }

  /// Call when Notification screen is opened to refresh count.
  void refreshCount() => _updateCount();

  List<NotificationItem> getNotifications() => _storage.getNotifications();

  Future<void> markAsRead(String id) async {
    final list = _storage.getNotifications();
    final idx = list.indexWhere((e) => e.id == id);
    if (idx < 0) return;
    final updated = list.map((e) => e.id == id ? e.copyWith(read: true) : e).toList();
    await _storage.setNotifications(updated);
    _updateCount();
  }

  Future<void> markAllAsRead() async {
    final list = _storage.getNotifications();
    await _storage.setNotifications(
      list.map((e) => e.copyWith(read: true)).toList(),
    );
    _updateCount();
  }

  Future<String?> getToken() => _fcm.getToken();
}

/// Top-level handler for background FCM (must be top-level).
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  _saveMessageInBackground(message);
}

const String _notificationsKey = 'notifications';

Future<void> _saveMessageInBackground(RemoteMessage message) async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final id = message.messageId ?? DateTime.now().millisecondsSinceEpoch.toString();
    final title = message.notification?.title ?? message.data['title'] ?? 'Notification';
    final body = message.notification?.body ?? message.data['body'] ?? '';
    final type = message.data['type'] ?? message.data['notification_type'] ?? 'general';
    final item = {
      'id': id,
      'title': title,
      'body': body,
      'type': type,
      'data': message.data,
      'createdAt': DateTime.now().toIso8601String(),
      'read': false,
    };
    final existing = prefs.getString(_notificationsKey);
    List<dynamic> list = [];
    if (existing != null) {
      try {
        list = json.decode(existing) as List<dynamic>;
      } catch (_) {}
    }
    if (list.any((e) => (e as Map)['id'] == id)) return;
    list.insert(0, item);
    await prefs.setString(_notificationsKey, json.encode(list));
  } catch (_) {}
}
