class ServiceCategory {
  String? id;
  String? name;
  String? description;
  bool? isDeleted;
  DateTime? createdAt;

  ServiceCategory({
    this.id,
    this.name,
    this.description,
    this.isDeleted,
    this.createdAt,
  });

  // FROM JSON - matching backend ServiceCategory model
  factory ServiceCategory.fromJson(Map<String, dynamic> json) {
    return ServiceCategory(
      id: (json['_id'] ?? json['id'])?.toString(),
      name: json['name'] as String?,
      description: json['description'] as String?,
      isDeleted: json['isDeleted'] as bool? ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'])
          : null,
    );
  }

  // TO JSON
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'description': description,
      'isDeleted': isDeleted,
      'createdAt': createdAt?.toIso8601String(),
    };
  }
}
