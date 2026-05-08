// enum.dart
enum UserRole { client, hustler }

extension UserRoleExtension on UserRole {
  String get value {
    switch (this) {
      case UserRole.client:
        return 'client';
      case UserRole.hustler:
        return 'hustler';
    }
  }

  String get displayName {
    switch (this) {
      case UserRole.client:
        return 'Client';
      case UserRole.hustler:
        return 'Hustler';
    }
  }
}