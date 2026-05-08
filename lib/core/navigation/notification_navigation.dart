import 'package:get/get.dart';
import 'package:hustler_syn/core/services/notification_service.dart';
import 'package:hustler_syn/screens/chat/conversation_screen.dart';
import 'package:hustler_syn/screens/home/check_out/orders_screen.dart';

/// Call once at app startup (e.g. from main.dart) to wire notification tap → screen.
void setupNotificationNavigation() {
  NotificationService.onNavigateFromNotification = _handleNotificationNavigation;
}

void _handleNotificationNavigation(String type, Map<String, dynamic> data) {
  // Defer so navigator is ready
  Future.microtask(() => _navigate(type, data));
}

void _navigate(String type, Map<String, dynamic> data) {
  String s(String key) => (data[key] is String) ? data[key] as String : (data[key]?.toString() ?? '');

  switch (type.toLowerCase()) {
    case 'message':
      final senderId = s('senderId');
      if (senderId.isEmpty) return;
      Get.to(() => ConversationScreen(
            otherUserId: senderId,
            conversationId: s('conversationId').isEmpty ? null : s('conversationId'),
            userName: s('senderName').isEmpty ? 'User' : s('senderName'),
            userImage: s('senderImage').isEmpty ? '' : s('senderImage'),
            userType: s('senderType').isEmpty ? 'hustler' : s('senderType'),
          ));
      break;
    case 'payment':
    case 'order':
      Get.to(() => const OrdersScreen());
      break;
    default:
      break;
  }
}
