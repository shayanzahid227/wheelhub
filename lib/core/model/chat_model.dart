import 'package:hustler_syn/core/model/app_user_model.dart';
import 'package:hustler_syn/core/enums/user_role.dart';

/// Model for a conversation in the chat list
/// Maps to backend's formatted conversation response from GET /chat/conversations
class ChatModel {
  final String id; // Conversation ID (_id from backend)
  final AppUser otherUser; // The other participant in the conversation
  final String lastMessage; // Last message text or "Image"
  final DateTime lastMessageAt; // Timestamp of last message
  final int unreadCount; // Number of unread messages for current user
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ChatModel({
    required this.id,
    required this.otherUser,
    required this.lastMessage,
    required this.lastMessageAt,
    required this.unreadCount,
    this.createdAt,
    this.updatedAt,
  });

  /// Create ChatModel from backend JSON response
  factory ChatModel.fromJson(Map<String, dynamic> json) {
    return ChatModel(
      id: json['_id'] as String,
      otherUser: AppUser.fromJson(json['otherUser'] as Map<String, dynamic>),
      lastMessage: json['lastMessage'] as String? ?? '',
      lastMessageAt: json['lastMessageAt'] != null
          ? DateTime.parse(json['lastMessageAt'] as String)
          : DateTime.now(),
      unreadCount: json['unreadCount'] as int? ?? 0,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

  /// Helper getters for backward compatibility with existing UI
  String get userName => otherUser.fullName ?? 'User';
  String get userImage => otherUser.image ?? '';
  String get userType => otherUser.role?.displayName ?? 'User';
  String get lastChat => lastMessage;

  /// Format time ago (e.g., "2h ago", "1d ago")
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(lastMessageAt);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${(difference.inDays / 7).floor()}w ago';
    }
  }

  String get unreadSms => unreadCount.toString();
}

/// Model for individual message in a conversation
/// Maps to backend's message schema within Chat.messages array
class MessageModel {
  final String? id; // Message ID (if available)
  final AppUser? sender; // Sender user object (populated from backend)
  final String senderId; // Sender user ID
  final String message; // Text content
  final String? image; // Image URL (if any)
  final String messageType; // "text", "image", or "both"
  final List<String> readBy; // Array of user IDs who read this message
  final DateTime createdAt; // Message timestamp
  final bool isSentByMe; // Computed field for UI

  MessageModel({
    this.id,
    this.sender,
    required this.senderId,
    required this.message,
    this.image,
    this.messageType = 'text',
    this.readBy = const [],
    required this.createdAt,
    this.isSentByMe = false,
  });

  /// Create MessageModel from backend JSON response
  factory MessageModel.fromJson(
      Map<String, dynamic> json, String currentUserId) {
    final senderId = json['sender'] is String
        ? json['sender'] as String
        : (json['sender'] as Map<String, dynamic>)['_id'] as String;

    return MessageModel(
      id: json['_id'] as String?,
      sender: json['sender'] is Map<String, dynamic>
          ? AppUser.fromJson(json['sender'] as Map<String, dynamic>)
          : null,
      senderId: senderId,
      message: json['message'] as String? ?? '',
      image: json['image'] as String?,
      messageType: json['messageType'] as String? ?? 'text',
      readBy: json['readBy'] != null
          ? List<String>.from(json['readBy'] as List)
          : [],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      isSentByMe: senderId == currentUserId,
    );
  }

  /// Helper getters for backward compatibility with existing UI
  String get text => message;

  /// Format time (e.g., "10:30 AM")
  String get time {
    final hour = createdAt.hour;
    final minute = createdAt.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$displayHour:$minute $period';
  }

  /// Check if message is read by a specific user
  bool isReadBy(String userId) {
    return readBy.contains(userId);
  }

  /// Convert to JSON for sending to backend
  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'image': image,
      'messageType': messageType,
    };
  }
}

/// Full conversation model with all messages
/// Used for detailed conversation view
class ConversationModel {
  final String id; // Conversation ID
  final List<AppUser> participants; // All participants
  final List<MessageModel> messages; // All messages
  final String lastMessage;
  final DateTime lastMessageAt;
  final Map<String, int> unreadCount; // Map of userId -> count
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ConversationModel({
    required this.id,
    required this.participants,
    required this.messages,
    required this.lastMessage,
    required this.lastMessageAt,
    required this.unreadCount,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
  });

  /// Create ConversationModel from backend JSON response
  factory ConversationModel.fromJson(
    Map<String, dynamic> json,
    String currentUserId,
  ) {
    final messagesList = json['messages'] as List? ?? [];

    return ConversationModel(
      id: json['_id'] as String,
      participants: (json['participants'] as List?)
              ?.map((p) => AppUser.fromJson(p as Map<String, dynamic>))
              .toList() ??
          [],
      messages: messagesList
          .map((m) =>
              MessageModel.fromJson(m as Map<String, dynamic>, currentUserId))
          .toList(),
      lastMessage: json['lastMessage'] as String? ?? '',
      lastMessageAt: json['lastMessageAt'] != null
          ? DateTime.parse(json['lastMessageAt'] as String)
          : DateTime.now(),
      unreadCount: json['unreadCount'] != null
          ? Map<String, int>.from(json['unreadCount'] as Map)
          : {},
      isActive: json['isActive'] as bool? ?? true,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

  /// Get the other participant (not the current user)
  AppUser? getOtherParticipant(String currentUserId) {
    return participants.firstWhere(
      (p) => p.id != currentUserId,
      orElse: () => participants.first,
    );
  }
}
