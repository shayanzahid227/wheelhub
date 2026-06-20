// enum.dart
enum UserRole { seller, buyer }

extension UserRoleExtension on UserRole {
  String get value {
    switch (this) {
      case UserRole.seller:
        return 'seller';
      case UserRole.buyer:
        return 'buyer';
    }
  }

  String get displayName {
    switch (this) {
      case UserRole.seller:
        return 'Seller';
      case UserRole.buyer:
        return 'Buyer';
    }
  }
}