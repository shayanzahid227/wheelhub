import 'package:flutter/foundation.dart';
import 'package:hustler_syn/core/model/app_user_model.dart';

class PostModel {
  final String? id;
  final String? title;
  final String? description;
  final double? budget;
  final String? serviceCategoryId; // Store the ID for creation
  final String? categoryName; // Store the name for display
  final String? location;
  final List<String>? languages;
  final List<String>? images;
  final AppUser? createdBy;
  final String? status;
  final DateTime? createdAt;

  PostModel({
    this.id,
    this.title,
    this.description,
    this.budget,
    this.serviceCategoryId,
    this.categoryName,
    this.location,
    this.languages,
    this.images,
    this.createdBy,
    this.status,
    this.createdAt,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) {
    try {
      return PostModel(
        id: json['_id'] as String?,
        title: json['title'] as String?,
        description: json['description'] as String?,
        budget: json['budget'] != null
            ? double.tryParse(json['budget'].toString())
            : null,
        serviceCategoryId: json['serviceCategoryId'] is Map
            ? json['serviceCategoryId']['_id'] as String?
            : json['serviceCategoryId'] as String?,
        categoryName: json['serviceCategoryId'] is Map
            ? json['serviceCategoryId']['name'] as String?
            : null,
        location: json['location'] as String?,
        languages: json['languages'] != null
            ? (json['languages'] is List
                ? List<String>.from(json['languages'] as List)
                : [json['languages'].toString()])
            : null,
        images: json['images'] != null
            ? (json['images'] is List
                ? List<String>.from(json['images'] as List)
                : [json['images'].toString()])
            : null,
        createdBy: json['createdBy'] != null && json['createdBy'] is Map
            ? AppUser.fromJson(json['createdBy'] as Map<String, dynamic>)
            : (json['createdBy'] is String
                ? AppUser(id: json['createdBy'] as String)
                : null),
        status: json['status'] as String?,
        createdAt: json['createdAt'] != null
            ? DateTime.tryParse(json['createdAt'] as String)
            : null,
      );
    } catch (e) {
      debugPrint("Error parsing PostModel from JSON: $e");
      return PostModel(); // Return empty on error
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'budget': budget,
      'serviceCategoryId': serviceCategoryId,
      'location': location,
      'languages': languages,
      'images': images,
    };
  }
}
