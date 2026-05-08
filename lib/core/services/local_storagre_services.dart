import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:hustler_syn/core/enums/user_role.dart';
import 'package:hustler_syn/core/model/app_user_model.dart';
import 'package:hustler_syn/core/model/notification_item_model.dart';
import 'package:hustler_syn/core/model/service_category_model.dart';

import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  static const String _userIdKey = 'user_id';
  static const String _userKey = 'user';
  static const String _accessTokenKey = 'token';
  static const String _isClientKey = 'isClient';
  static const String _emailKey = 'email';
  static const String _otpKey = 'otpCode';
  static const String _categoriesKey = 'categories';
  static const String _notificationsKey = 'notifications';

  late SharedPreferences _prefs;

  // Async initializer
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Check if user is logged in
  bool get isLoggedIn {
    return accessToken != null && user != null;
  }

  // Check if user has an active subscription
  bool get hasActiveSubscription {
    return user?.activeSubscriptionId != null;
  }

  // User ID
  String? get userId => _prefs.getString(_userIdKey);
  Future<void> setUserId(String value) => _prefs.setString(_userIdKey, value);

  // User object
  AppUser? get user {
    final userStr = _prefs.getString(_userKey);
    if (userStr == null) return null;
    return AppUser.fromJson(json.decode(userStr));
  }

  Future<void> setUser(AppUser user) async {
    Map<String, dynamic> toSave = user.toJson();
    // Preserve role when API returns user without role (e.g. getProfile returns role: null)
    if (user.role == null) {
      final existing = this.user;
      if (existing?.role != null) {
        toSave['role'] = existing!.role!.value;
        debugPrint("LOCAL STORAGE: Preserved existing role '${existing.role!.value}' (API did not return role).");
      }
    }
    final String userJson = json.encode(toSave);
    debugPrint("LOCAL STORAGE: Writing user: $userJson");
    debugPrint("LOCAL STORAGE: User Role being saved: ${user.role?.value ?? toSave['role']}");
    await _prefs.setString(_userKey, userJson);
    if (user.id != null) {
      await setUserId(user.id!);
    }
  }

  // Access token
  String? get accessToken => _prefs.getString(_accessTokenKey);
  Future<void> setAccessToken(String value) =>
      _prefs.setString(_accessTokenKey, value);

  // Client flag
  bool get isClient => _prefs.getBool(_isClientKey) ?? false;
  Future<void> setIsClient(bool value) => _prefs.setBool(_isClientKey, value);
  // role
  String? get role => user?.role?.value;

  // Email
  String? get email => _prefs.getString(_emailKey);
  Future<void> setEmail(String value) => _prefs.setString(_emailKey, value);
  // otp
  String? get Otp => _prefs.getString(_otpKey);
  Future<void> setOtp(String value) => _prefs.setString(_otpKey, value);
  // Categories
  List<ServiceCategory> get categories {
    final categoriesStr = _prefs.getString(_categoriesKey);
    if (categoriesStr == null) return [];
    final List<dynamic> decoded = json.decode(categoriesStr);
    return decoded
        .map((e) => ServiceCategory.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<void> setCategories(List<ServiceCategory> categories) async {
    final encoded = json.encode(categories.map((e) => e.toJson()).toList());
    await _prefs.setString(_categoriesKey, encoded);
  }

  // Notifications list (FCM saved)
  List<NotificationItem> getNotifications() {
    final str = _prefs.getString(_notificationsKey);
    if (str == null) return [];
    try {
      final list = json.decode(str) as List<dynamic>;
      return list
          .map((e) => NotificationItem.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } catch (_) {
      return [];
    }
  }

  Future<void> addNotification(NotificationItem item) async {
    final list = getNotifications();
    if (list.any((e) => e.id == item.id)) return;
    final newList = [item, ...list];
    await _prefs.setString(
      _notificationsKey,
      json.encode(newList.map((e) => e.toJson()).toList()),
    );
  }

  Future<void> setNotifications(List<NotificationItem> list) async {
    await _prefs.setString(
      _notificationsKey,
      json.encode(list.map((e) => e.toJson()).toList()),
    );
  }

  int get unreadNotificationCount =>
      getNotifications().where((e) => !e.read).length;

  // Clear all data
  Future<void> clearAll() => _prefs.clear();
}
