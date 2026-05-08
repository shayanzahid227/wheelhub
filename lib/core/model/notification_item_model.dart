/// Single saved notification (message, payment, etc.) for in-app list.
class NotificationItem {
  final String id;
  final String title;
  final String body;
  final String type; // 'message', 'payment', 'order', 'general'
  final Map<String, dynamic>? data;
  final DateTime createdAt;
  final bool read;

  const NotificationItem({
    required this.id,
    required this.title,
    required this.body,
    this.type = 'general',
    this.data,
    required this.createdAt,
    this.read = false,
  });

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    return NotificationItem(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      body: json['body'] as String? ?? '',
      type: json['type'] as String? ?? 'general',
      data: json['data'] is Map ? Map<String, dynamic>.from(json['data'] as Map) : null,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String) ?? DateTime.now()
          : DateTime.now(),
      read: json['read'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'type': type,
      'data': data,
      'createdAt': createdAt.toIso8601String(),
      'read': read,
    };
  }

  NotificationItem copyWith({bool? read}) {
    return NotificationItem(
      id: id,
      title: title,
      body: body,
      type: type,
      data: data,
      createdAt: createdAt,
      read: read ?? this.read,
    );
  }
}
