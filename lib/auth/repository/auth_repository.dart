import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:wheelhub/auth/models/user.dart';

class AuthRepository {
  AuthRepository({SharedPreferences? prefs}) : _prefs = prefs;

  SharedPreferences? _prefs;

  static const onboardingCompletedKey = 'onboarding_completed';
  static const isLoggedInKey = 'is_logged_in';
  static const currentUserKey = 'current_user';
  static const rememberMeKey = 'remember_me';
  static const rememberedEmailKey = 'remembered_email';

  static const demoEmail = 'shayan@gmail.com';
  static const demoPassword = '123456';

  static final User _demoUser = User(
    id: 'user_demo_001',
    fullName: 'Shayan Zahid',
    email: demoEmail,
    phoneNumber: '+92 300 1234567',
    profileImage: null,
    bio: 'Passionate about finding the perfect ride on WheelHub.',
  );

  final List<User> _registeredUsers = [_demoUser];

  Future<SharedPreferences> get prefs async {
    return _prefs ??= await SharedPreferences.getInstance();
  }

  Future<AuthDestination> getInitialDestination() async {
    final storage = await prefs;
    final onboardingDone = storage.getBool(onboardingCompletedKey) ?? false;
    if (!onboardingDone) return AuthDestination.onboarding;

    final loggedIn = storage.getBool(isLoggedInKey) ?? false;
    if (!loggedIn) return AuthDestination.login;

    return AuthDestination.home;
  }

  Future<bool> isOnboardingCompleted() async {
    final storage = await prefs;
    return storage.getBool(onboardingCompletedKey) ?? false;
  }

  Future<void> completeOnboarding() async {
    final storage = await prefs;
    await storage.setBool(onboardingCompletedKey, true);
  }

  Future<bool> isLoggedIn() async {
    final storage = await prefs;
    return storage.getBool(isLoggedInKey) ?? false;
  }

  Future<User?> getCurrentUser() async {
    final storage = await prefs;
    final raw = storage.getString(currentUserKey);
    if (raw == null) return null;
    return User.fromJson(json.decode(raw) as Map<String, dynamic>);
  }

  Future<bool> getRememberMe() async {
    final storage = await prefs;
    return storage.getBool(rememberMeKey) ?? false;
  }

  Future<String?> getRememberedEmail() async {
    final storage = await prefs;
    return storage.getString(rememberedEmailKey);
  }

  Future<void> setRememberMe({required bool value, String? email}) async {
    final storage = await prefs;
    await storage.setBool(rememberMeKey, value);
    if (value && email != null) {
      await storage.setString(rememberedEmailKey, email);
    } else {
      await storage.remove(rememberedEmailKey);
    }
  }

  Future<AuthResult> login({
    required String email,
    required String password,
    required bool rememberMe,
  }) async {
    await Future.delayed(const Duration(milliseconds: 900));

    final normalizedEmail = email.trim().toLowerCase();
    User? matched;

    for (final user in _registeredUsers) {
      if (user.email.toLowerCase() == normalizedEmail) {
        matched = user;
        break;
      }
    }

    if (matched == null &&
        normalizedEmail == demoEmail &&
        password == demoPassword) {
      matched = _demoUser;
    }

    if (matched == null) {
      return const AuthResult(
        success: false,
        message: 'No account found for this email.',
      );
    }

    if (password.length < 6) {
      return const AuthResult(success: false, message: 'Invalid credentials.');
    }

    final storage = await prefs;
    await storage.setBool(isLoggedInKey, true);
    await storage.setString(currentUserKey, json.encode(matched.toJson()));
    await setRememberMe(
      value: rememberMe,
      email: rememberMe ? normalizedEmail : null,
    );

    return AuthResult(
      success: true,
      message: 'Welcome back, ${matched.fullName.split(' ').first}!',
      user: matched,
    );
  }

  Future<AuthResult> signup({
    required String fullName,
    required String email,
    required String phoneNumber,
    required String password,
  }) async {
    await Future.delayed(const Duration(milliseconds: 1100));

    final normalizedEmail = email.trim().toLowerCase();
    final exists = _registeredUsers.any(
      (user) => user.email.toLowerCase() == normalizedEmail,
    );

    if (exists) {
      return const AuthResult(
        success: false,
        message: 'An account with this email already exists.',
      );
    }

    final user = User(
      id: 'user_${DateTime.now().millisecondsSinceEpoch}',
      fullName: fullName.trim(),
      email: normalizedEmail,
      phoneNumber: phoneNumber.trim(),
      bio: 'New WheelHub member',
    );

    _registeredUsers.add(user);

    return AuthResult(
      success: true,
      message: 'Account created successfully. Please log in.',
      user: user,
    );
  }

  Future<void> logout() async {
    final storage = await prefs;
    await storage.setBool(isLoggedInKey, false);
    await storage.remove(currentUserKey);
  }
}
