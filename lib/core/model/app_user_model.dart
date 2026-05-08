import 'package:flutter/foundation.dart';
import 'package:hustler_syn/core/enums/user_role.dart';

class AppUser {
  String? id;
  UserRole? role;

  String? category;
  String? fullName;
  String? email;
  String? password;
  String? phone;
  String? language;
  List<ServiceAndPriceDetail>? servicePrices;
  String? businessName;
  String? description;
  String? image;
  double? rating;
  String? distance;

  /// Hustler coordinates for per-client distance (optional; backend may send latitude/longitude or location).
  double? latitude;
  double? longitude;
  bool? isVerified;
  List<String>? tags;
  List<String>? businessImages;
  DateTime? createdAt;
  String? token;
  String? activeSubscriptionId;

  AppUser({
    this.email,
    this.id,
    this.image,
    this.fullName,
    this.role,
    this.category,
    this.rating,
    this.distance,
    this.latitude,
    this.longitude,
    this.isVerified,
    this.description,
    this.phone,
    this.password,
    this.language,
    this.servicePrices,
    this.tags,
    this.businessImages,
    this.businessName,
    this.token,
    this.activeSubscriptionId,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now(); // default when creating

  // -----------------------------
  // FROM JSON
  // -----------------------------
  factory AppUser.fromJson(Map<String, dynamic> json) {
    debugPrint("APP_USER_MODEL: fromJson RAW DATA: $json");
    // Helper to parse role from string to Enum
    UserRole? parseRole(String? val) {
      if (val == null) return null;
      if (val.toLowerCase() == 'client') return UserRole.client;
      if (val.toLowerCase() == 'hustler') return UserRole.hustler;
      return null;
    }

    // Helper to extract category if role contains "Plumbing" etc.
    String? parseCategory(String? val) {
      if (val == null) return null;
      if (val.toLowerCase() == 'client' || val.toLowerCase() == 'hustler') {
        return null;
      }
      return val; // Treat as category
    }

    // Try to find if user info is nested inside a 'user' key
    final Map<String, dynamic> effectiveJson =
        (json['user'] is Map) ? Map<String, dynamic>.from(json['user']) : json;

    // Helper to handle null or empty strings for fallbacks
    String? val(dynamic v) {
      if (v == null) return null;
      String s = v.toString().trim();
      return s.isEmpty ? null : s;
    }

    // Helper to search in both top-level and nested maps
    dynamic findField(String key) =>
        effectiveJson[key] ??
        (json[key]) ??
        (json['data'] is Map ? json['data'][key] : null);

    double? parseDouble(dynamic v) {
      if (v == null) return null;
      if (v is num) return v.toDouble();
      return double.tryParse(v.toString());
    }

    double? locationLat(dynamic loc) {
      if (loc is! Map) return null;
      final m = Map<String, dynamic>.from(loc);
      return parseDouble(m['lat'] ?? m['latitude']);
    }

    double? locationLng(dynamic loc) {
      if (loc is! Map) return null;
      final m = Map<String, dynamic>.from(loc);
      return parseDouble(m['lng'] ?? m['longitude'] ?? m['lon']);
    }

    String? rawRole =
        val(findField('role')) ?? val(findField('Role')) ?? val(json['role']);

    return AppUser(
      email: val(findField('email')) ?? val(findField('Email')),
      id: (val(findField('id')) ??
          val(findField('_id')) ??
          val(findField('userId'))),
      image: val(findField('profileImage')) ??
          val(findField('image')) ??
          val(findField('img')) ??
          val(findField('avatar')) ??
          val(json['profileImage']) ??
          val(json['image']),
      fullName: (val(findField('fullName')) ??
          val(findField('name')) ??
          val(findField('fullname')) ??
          val(findField('FullName')) ??
          val(findField('userName'))),
      role: parseRole(rawRole),
      category: (findField('category') is String
              ? findField('category') as String
              : (findField('category') is Map
                  ? findField('category')['name']
                  : null)) ??
          (findField('serviceCategoryId') is Map
              ? findField('serviceCategoryId')['name']?.toString()
              : (findField('services') != null &&
                      (findField('services') as List).isNotEmpty
                  ? (findField('services')[0]['serviceCategoryId'] is Map
                      ? findField('services')[0]['serviceCategoryId']['name']
                          ?.toString()
                      : (findField('services')[0]['serviceCategoryId'] is String
                          ? findField('services')[0]['serviceCategoryId']
                              as String // Store the ID, will be resolved later
                          : null))
                  : null)) ??
          parseCategory(rawRole),
      rating: findField('rating') != null
          ? double.tryParse(findField('rating').toString())
          : null,
      distance: findField('distance') as String?,
      latitude: parseDouble(findField('latitude')) ??
          parseDouble(findField('lat')) ??
          locationLat(findField('location')),
      longitude: parseDouble(findField('longitude')) ??
          parseDouble(findField('lng')) ??
          locationLng(findField('location')),
      isVerified: findField('isVerified') as bool?,
      description: (val(findField('description')) ??
          val(findField('businessDesc')) ??
          val(findField('businessDescription')) ??
          val(findField('Description')) ??
          val(findField('bio')) ??
          (findField('services') != null &&
                  (findField('services') as List).isNotEmpty
              ? val(findField('services')[0]['description'])
              : null)),
      phone: (val(findField('phone')) ??
          val(findField('phoneNumber')) ??
          val(findField('phone_number')) ??
          val(findField('phoneNo')) ??
          val(findField('mobile')) ??
          val(findField('mobileNumber')) ??
          val(findField('tel')) ??
          val(findField('contact')) ??
          val(findField('Phone'))),
      password: val(findField('password')),
      language: val(findField('language')),
      businessName: (val(findField('businessName')) ??
          (findField('services') != null &&
                  (findField('services') as List).isNotEmpty
              ? val(findField('services')[0]['name'])
              : null) ??
          val(findField('companyName'))),
      servicePrices: (findField('servicePrices') ?? findField('services')) !=
              null
          ? ((findField('servicePrices') ?? findField('services')) as List)
              .map((e) =>
                  ServiceAndPriceDetail.fromJson(Map<String, dynamic>.from(e)))
              .toList()
          : (findField('startingPrice') != null
              ? [
                  ServiceAndPriceDetail.ServiceAndPriceDetail(
                    startingPrice: findField('startingPrice').toString(),
                    serviceName: (val(findField('businessName')) ??
                        val(findField('companyName'))),
                    description: (val(findField('description')) ??
                        val(findField('businessDesc')) ??
                        val(findField('businessDescription')) ??
                        val(findField('bio'))),
                  )
                ]
              : null),

      ///
      tags: findField('tags') != null
          ? List<String>.from(findField('tags'))
          : null,
      businessImages: findField('businessImages') != null
          ? List<String>.from(findField('businessImages'))
          : null,
      createdAt: findField('createdAt') != null
          ? DateTime.tryParse(findField('createdAt')) ?? DateTime.now()
          : DateTime.now(),
      token: (val(json['token']) ??
          val(json['accessToken']) ??
          val(findField('token')) ??
          val(findField('accessToken')) ??
          (json['data'] is Map ? val(json['data']['token']) : null)),
      activeSubscriptionId: (val(findField('activeSubscriptionId')) ??
          val(findField('subscriptionId'))),
    );
  }

  // -----------------------------
  // TO JSON
  // -----------------------------
  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'id': id,
      'profileImage': image,
      'fullName': fullName,
      'role': role?.value, // Store as string value 'client' or 'hustler'
      'category': category,
      'rating': rating,
      'distance': distance,
      'isVerified': isVerified,
      'description': description,
      'phone': phone,
      'password': password,
      'language': language,
      'businessName': businessName,
      'createdAt': createdAt?.toIso8601String(),
      'servicePrices': servicePrices?.map((e) => e.toJson()).toList(),
      'tags': tags,
      'businessImages': businessImages,
      'token': token,
      'activeSubscriptionId': activeSubscriptionId,
    };
  }
}

///
///
///.    ServicePrice
///
///
class ServiceAndPriceDetail {
  String? id;
  String? userId;
  String? serviceName;
  String? startingPrice;

  double get basePriceAmount {
    return double.tryParse(startingPrice ?? '0') ?? 0;
  }

  /// Client-facing price (includes 10% platform fee).
  double get clientPriceAmount {
    return basePriceAmount * 1.1;
  }

  /// Price shown to viewers:
  /// - Client sees marked-up price (base * 1.10)
  /// - Hustler (and others) see base price
  double priceForViewer(UserRole? viewerRole) {
    return viewerRole == UserRole.client ? clientPriceAmount : basePriceAmount;
  }

  String formatAmount(num value) {
    final d = value.toDouble();
    if (d == d.roundToDouble()) return d.toInt().toString();
    return d.toStringAsFixed(2);
  }

  String get formattedClientPrice {
    double value = clientPriceAmount;
    if (value == value.roundToDouble()) {
      return value.toInt().toString();
    }
    return value.toStringAsFixed(2);
  }

  String? description;
  List<String>? images;
  String? serviceCategoryId;
  String? serviceCategoryName;
  bool? isDeleted;
  DateTime? createdAt;

  ServiceAndPriceDetail.ServiceAndPriceDetail({
    this.id,
    this.serviceName,
    this.startingPrice, // startingPrice
    this.description,
    this.images,
    this.serviceCategoryId,
    this.serviceCategoryName,
    this.isDeleted,
    this.createdAt,
  });

  // -----------------------------
  // FROM JSON
  // -----------------------------
  factory ServiceAndPriceDetail.fromJson(Map<String, dynamic> json) {
    String? categoryId;
    String? categoryName;
    if (json['serviceCategoryId'] is Map) {
      final Map<String, dynamic> cat =
          Map<String, dynamic>.from(json['serviceCategoryId']);
      categoryId = (cat['_id'] ?? cat['id'])?.toString();
      categoryName = cat['name']?.toString();
    } else {
      categoryId = json['serviceCategoryId'] as String?;
    }

    return ServiceAndPriceDetail.ServiceAndPriceDetail(
      id: (json['_id'] ?? json['id']) as String?,
      serviceName: (json['name'] ?? json['serviceName']) as String?,
      startingPrice: (json['startingPrice'] ?? json['price'])?.toString(),
      description: json['description'] as String?,
      images: json['images'] != null
          ? List<String>.from((json['images'] as List)
              .where((e) => e != null)
              .map((e) => e.toString()))
          : null,
      serviceCategoryId: categoryId,
      serviceCategoryName: categoryName,
      isDeleted: json['isDeleted'] as bool?,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'])
          : null,
    );
  }

  // -----------------------------
  // TO JSON
  // -----------------------------
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'name': serviceName,
      'startingPrice':
          startingPrice != null ? double.tryParse(startingPrice!) : 0,
      'description': description,
      'userId': userId,
      'serviceCategoryId': serviceCategoryId,
      'images': images,
    };
    if (id != null) data['id'] = id;
    return data;
  }
}
