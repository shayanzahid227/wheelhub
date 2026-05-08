import 'package:hustler_syn/core/model/app_user_model.dart';

/// Client order from backend: Pay → Pending (confirmed) → Release funds → Completed.
class OrderModel {
  final String id;
  final String status; // confirmed, completed, cancelled
  final num amount;
  final String? currency;
  final String? serviceId;
  final String? serviceName;
  final String? hustlerId;
  final String? hustlerName;
  final String? hustlerImage;
  final String? clientId;
  final String? clientName;
  final DateTime? scheduledAt;
  final DateTime? createdAt;
  final DateTime? completedAt;
  final String? durationLabel;
  final String? notes;

  const OrderModel({
    required this.id,
    required this.status,
    required this.amount,
    this.currency,
    this.serviceId,
    this.serviceName,
    this.hustlerId,
    this.hustlerName,
    this.hustlerImage,
    this.clientId,
    this.clientName,
    this.scheduledAt,
    this.createdAt,
    this.completedAt,
    this.durationLabel,
    this.notes,
  });

  bool get isPending => status.isNotEmpty && status.toLowerCase() == 'confirmed';
  bool get isCompleted =>
      status.isNotEmpty &&
      (status.toLowerCase() == 'completed' || status.toLowerCase() == 'released');

  static String? _str(dynamic v) {
    if (v == null) return null;
    final s = v.toString().trim();
    return s.isEmpty ? null : s;
  }

  static String? _clientNameFromOrder(Map<String, dynamic> order) {
    if (order['client'] is Map) {
      final c = order['client'] as Map<String, dynamic>;
      return _str(c['fullName']) ?? _str(c['name']) ?? _str(c['userName']);
    }
    return _str(order['clientName']);
  }

  static String? _nameFromMap(Map<String, dynamic>? m) {
    if (m == null) return null;
    return _str(m['fullName']) ?? _str(m['name']) ?? _str(m['userName']) ?? _str(m['displayName']);
  }

  static String? _imageFromMap(Map<String, dynamic>? m) {
    if (m == null) return null;
    return _str(m['profileImage']) ?? _str(m['image']) ?? _str(m['avatar']);
  }

  static DateTime? _date(dynamic v) {
    if (v == null) return null;
    if (v is DateTime) return v;
    return DateTime.tryParse(v.toString());
  }

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    final order = json['order'] as Map<String, dynamic>? ?? json;
    // Hustler can be object or id (or nested e.g. hustler.user)
    Map<String, dynamic>? hustlerObj;
    String? hustlerId;
    if (order['hustler'] != null) {
      if (order['hustler'] is Map) {
        hustlerObj = Map<String, dynamic>.from(order['hustler'] as Map);
        hustlerId = hustlerObj['_id']?.toString() ?? hustlerObj['id']?.toString();
        if (hustlerId == null && hustlerObj['user'] is Map) {
          final u = hustlerObj['user'] as Map<String, dynamic>;
          hustlerId = u['_id']?.toString() ?? u['id']?.toString();
        }
      } else {
        hustlerId = order['hustler'].toString();
      }
    }
    // Service can be object or id
    String? serviceId;
    String? serviceName;
    if (order['service'] != null) {
      if (order['service'] is Map) {
        final svc = order['service'] as Map<String, dynamic>;
        serviceId = svc['_id']?.toString() ?? svc['id']?.toString();
        serviceName = _str(svc['name']) ?? _str(svc['serviceName']);
      } else {
        serviceId = order['service'].toString();
      }
    }
    Map<String, dynamic>? hustlerUserObj;
    if (hustlerObj != null && hustlerObj['user'] is Map) {
      hustlerUserObj = Map<String, dynamic>.from(hustlerObj['user'] as Map);
    }
    final statusStr = _str(order['status']) ?? _str(order['orderStatus']) ?? _str(order['state']) ?? 'confirmed';
    return OrderModel(
      id: _str(order['_id']) ?? _str(order['id']) ?? '',
      status: statusStr,
      amount: (order['amount'] is num) ? order['amount'] as num : num.tryParse(order['amount']?.toString() ?? '0') ?? 0,
      currency: _str(order['currency']),
      serviceId: serviceId ?? _str(order['serviceId']),
      serviceName: serviceName ?? _str(order['serviceName']),
      hustlerId: hustlerId ?? _str(order['hustlerId']),
      hustlerName: hustlerObj != null ? (_nameFromMap(hustlerObj) ?? _nameFromMap(hustlerUserObj)) : _str(order['hustlerName']),
      hustlerImage: hustlerObj != null ? (_imageFromMap(hustlerObj) ?? _imageFromMap(hustlerUserObj)) : _str(order['hustlerImage']),
      clientId: _str(order['client']) ?? _str(order['clientId']),
      clientName: _clientNameFromOrder(order),
      scheduledAt: _date(order['scheduledAt']),
      createdAt: _date(order['createdAt']),
      completedAt: _date(order['completedAt']),
      durationLabel: _str(order['durationLabel']),
      notes: _str(order['notes']),
    );
  }

  /// Build minimal AppUser for navigation to profile/chat.
  AppUser toHustlerAppUser() {
    return AppUser(
      id: hustlerId,
      fullName: hustlerName,
      image: hustlerImage,
    );
  }
}
