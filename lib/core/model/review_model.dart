import 'package:flutter/foundation.dart';

class Review {
  final String? id;
  final String? orderId;
  final String? clientId;
  final String? hustlerId;
  final String? serviceId;
  final int? rating;
  final String? comment;
  final DateTime? createdAt;
  final Map<String, dynamic>? rawClient; // For optional embedded client info
  final Map<String, dynamic>? rawHustler;
  final Map<String, dynamic>? rawService;

  const Review({
    this.id,
    this.orderId,
    this.clientId,
    this.hustlerId,
    this.serviceId,
    this.rating,
    this.comment,
    this.createdAt,
    this.rawClient,
    this.rawHustler,
    this.rawService,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    debugPrint("REVIEW_MODEL: fromJson => $json");

    String? string(dynamic v) {
      if (v == null) return null;
      final s = v.toString().trim();
      return s.isEmpty ? null : s;
    }

    int? toInt(dynamic v) {
      if (v == null) return null;
      if (v is int) return v;
      return int.tryParse(v.toString());
    }

    DateTime? date(dynamic v) {
      if (v == null) return null;
      return DateTime.tryParse(v.toString());
    }

    return Review(
      id: string(json['_id'] ?? json['id']),
      orderId: string(json['orderId']),
      clientId: string(json['clientId']),
      hustlerId: string(json['hustlerId']),
      serviceId: string(json['serviceId']),
      rating: toInt(json['rating']),
      comment: string(json['comment']),
      createdAt: date(json['createdAt']),
      rawClient: json['client'] is Map
          ? Map<String, dynamic>.from(json['client'])
          : null,
      rawHustler: json['hustler'] is Map
          ? Map<String, dynamic>.from(json['hustler'])
          : null,
      rawService: json['service'] is Map
          ? Map<String, dynamic>.from(json['service'])
          : null,
    );
  }
}

class ReviewStats {
  final int count;
  final double averageRating;

  const ReviewStats({
    required this.count,
    required this.averageRating,
  });

  factory ReviewStats.fromJson(Map<String, dynamic> json) {
    final count = json['count'] is int
        ? json['count'] as int
        : int.tryParse(json['count']?.toString() ?? '0') ?? 0;

    final avg = json['averageRating'] is num
        ? (json['averageRating'] as num).toDouble()
        : double.tryParse(json['averageRating']?.toString() ?? '0') ?? 0.0;

    return ReviewStats(count: count, averageRating: avg);
  }
}

class ReviewsWithStats {
  final List<Review> reviews;
  final ReviewStats stats;

  const ReviewsWithStats({
    required this.reviews,
    required this.stats,
  });
}
