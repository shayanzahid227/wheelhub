import 'package:flutter/foundation.dart';
import 'package:hustler_syn/core/enums/user_role.dart';
import 'package:hustler_syn/core/model/app_user_model.dart';
import 'package:hustler_syn/core/model/request_services.dart';
import 'package:hustler_syn/core/services/data_base_services.dart';
import 'package:hustler_syn/core/services/local_storagre_services.dart';
import 'package:hustler_syn/core/services/notification_service.dart';
import 'package:hustler_syn/locator.dart';

class AuthServices {
  bool isLogin = false;

  final _localStorageService = locator<LocalStorageService>();
  final _dbService = DatabaseServices();

  AppUser appUser = AppUser();

  ///
  /// register client
  ///
  ///
  Future<RequestResponse<AppUser>> registerClient() async {
    try {
      final response = await _dbService.registerClient(appUser);

      if (response.success && response.data != null) {
        final user = response.data!;
        user.role ??= UserRole.client; // Backend may not return role
        print("registering client respone: ${response.toJson()}");
        await _localStorageService.setUser(user);
        if (user.token != null) {
          debugPrint("AuthServices: Saving access token: ${user.token}");
          await _localStorageService.setAccessToken(user.token!);
        }
        if (user.id != null) {
          debugPrint("AuthServices: Saving user ID: ${user.id}");
          await _localStorageService.setUserId(user.id!);
        }
        await locator<NotificationService>().registerTokenWithBackendIfNeeded();

        final savedUser = _localStorageService.user;
        debugPrint(
            "AuthServices: Verified Saved User Role: ${savedUser?.role?.value}");

        return RequestResponse(
          true,
          message: "user register successfuly",
          data: user,
        );
      } else {
        debugPrint("Register client failed: ${response.message}");
        return RequestResponse(
          false,
          message: response.message ?? "Failed to register client",
        );
      }
    } catch (e) {
      debugPrint("Register client Exception: $e");
      return RequestResponse(false, message: "Unexpected error: $e");
    }
  }

  ///
  /// register hustler
  ///
  Future<RequestResponse<AppUser>> registerHustler() async {
    debugPrint("AUTH SERVICES: registerHustler");
    try {
      final response = await _dbService.registerHustler(appUser);

      if (response.success && response.data != null) {
        final user = response.data!;
        user.role ??= UserRole.hustler; // Backend may not return role
        await _localStorageService.setUser(user);
        if (user.token != null) {
          debugPrint("AuthServices: Saving access token: ${user.token}");
          await _localStorageService.setAccessToken(user.token!);
        }
        if (user.id != null) {
          debugPrint("AuthServices: Saving user ID: ${user.id}");
          await _localStorageService.setUserId(user.id!);
        }
        await locator<NotificationService>().registerTokenWithBackendIfNeeded();

        final savedUser = _localStorageService.user;
        debugPrint(
            "AuthServices: Verified Saved Hustler Role: ${savedUser?.role?.value}");

        return RequestResponse(
          true,
          message: "Hustler registered successfully",
          data: user,
        );
      } else {
        debugPrint("Register hustler failed: ${response.message}");
        return RequestResponse(
          false,
          message: response.message ?? "Failed to register hustler",
        );
      }
    } catch (e) {
      debugPrint("Register hustler Exception: $e");
      return RequestResponse(false, message: "Unexpected error: $e");
    }
  }

  ///
  ///. login user
  ///
  Future<RequestResponse<AppUser>> loginUser() async {
    try {
      final responce = await _dbService.loginUser(appUser);
      if (responce.success && responce.data != null) {
        final user = responce.data!;
        debugPrint("AUTH SERVICES: loginUser SUCCESS");
        debugPrint("User Role FROM BACKEND: ${user.role}");
        debugPrint("User Role VALUE: ${user.role?.value}");
        await _localStorageService.setUser(user);
        debugPrint("AUTH SERVICES: User set in LocalStorage");
        if (user.token != null) {
          debugPrint("AuthServices: Saving access token: ${user.token}");
          await _localStorageService.setAccessToken(user.token!);
        }
        if (user.id != null) {
          debugPrint("AuthServices: Saving user ID: ${user.id}");
          await _localStorageService.setUserId(user.id!);
        }
        await locator<NotificationService>().registerTokenWithBackendIfNeeded();
        return RequestResponse(
          true,
          message: "user login successfuly",
          data: user,
        );
      } else {
        debugPrint("Login user failed: ${responce.message}");
        return RequestResponse(
          false,
          message: responce.message ?? "Failed to login user",
        );
      }
    } catch (e) {
      debugPrint("Login user Exception: $e");
      return RequestResponse(false, message: "Unexpected error: $e");
    }
  }

  Future<RequestResponse<void>> forgotPassword({
    required String email,
    required String newPassword,
  }) async {
    try {
      final response = await _dbService.forgotPassword(
        email: email,
        newPassword: newPassword,
      );

      if (response.success) {
        return RequestResponse(
          true,
          message: response.message ?? "Password updated successfully",
        );
      }

      return RequestResponse(
        false,
        message: response.message ?? "Failed to update password",
      );
    } catch (e) {
      debugPrint("Forgot password Exception: $e");
      return RequestResponse(false, message: "Unexpected error: $e");
    }
  }
}
