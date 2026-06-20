import 'package:flutter/foundation.dart';
import 'package:wheelhub/auth/models/user.dart';
import 'package:wheelhub/auth/repository/auth_repository.dart';

class AuthViewModel extends ChangeNotifier {
  AuthViewModel({AuthRepository? repository})
      : _repository = repository ?? AuthRepository();

  final AuthRepository _repository;

  bool isLoading = false;
  bool obscurePassword = true;
  bool obscureConfirmPassword = true;
  bool rememberMe = false;

  String email = '';
  String password = '';
  String fullName = '';
  String phoneNumber = '';
  String confirmPassword = '';
  String forgotEmail = '';

  String? emailError;
  String? passwordError;
  String? fullNameError;
  String? phoneError;
  String? confirmPasswordError;
  String? forgotEmailError;

  User? currentUser;

  AuthRepository get repository => _repository;

  Future<void> initialize() async {
    rememberMe = await _repository.getRememberMe();
    final remembered = await _repository.getRememberedEmail();
    if (rememberMe && remembered != null) {
      email = remembered;
    }
    currentUser = await _repository.getCurrentUser();
    notifyListeners();
  }

  Future<AuthDestination> getInitialDestination() {
    return _repository.getInitialDestination();
  }

  void togglePasswordVisibility() {
    obscurePassword = !obscurePassword;
    notifyListeners();
  }

  void toggleConfirmPasswordVisibility() {
    obscureConfirmPassword = !obscureConfirmPassword;
    notifyListeners();
  }

  void setRememberMe(bool value) {
    rememberMe = value;
    notifyListeners();
  }

  void updateEmail(String value) {
    email = value;
    emailError = null;
    notifyListeners();
  }

  void updatePassword(String value) {
    password = value;
    passwordError = null;
    notifyListeners();
  }

  void updateFullName(String value) {
    fullName = value;
    fullNameError = null;
    notifyListeners();
  }

  void updatePhoneNumber(String value) {
    phoneNumber = value;
    phoneError = null;
    notifyListeners();
  }

  void updateConfirmPassword(String value) {
    confirmPassword = value;
    confirmPasswordError = null;
    notifyListeners();
  }

  void updateForgotEmail(String value) {
    forgotEmail = value;
    forgotEmailError = null;
    notifyListeners();
  }

  bool validateLogin() {
    emailError = _validateEmail(email);
    passwordError = _validatePassword(password);
    notifyListeners();
    return emailError == null && passwordError == null;
  }

  bool validateSignup() {
    fullNameError = fullName.trim().isEmpty ? 'Name is required' : null;
    emailError = _validateEmail(email);
    phoneError = _validatePhone(phoneNumber);
    passwordError = _validatePassword(password);
    confirmPasswordError = password != confirmPassword
        ? 'Passwords do not match'
        : null;
    notifyListeners();
    return fullNameError == null &&
        emailError == null &&
        phoneError == null &&
        passwordError == null &&
        confirmPasswordError == null;
  }

  bool validateForgotPassword() {
    forgotEmailError = _validateEmail(forgotEmail);
    notifyListeners();
    return forgotEmailError == null;
  }

  Future<AuthResult> login() async {
    if (!validateLogin()) {
      return const AuthResult(success: false, message: 'Please fix the errors.');
    }

    isLoading = true;
    notifyListeners();

    final result = await _repository.login(
      email: email,
      password: password,
      rememberMe: rememberMe,
    );

    if (result.success) {
      currentUser = result.user;
    }

    isLoading = false;
    notifyListeners();
    return result;
  }

  Future<AuthResult> signup() async {
    if (!validateSignup()) {
      return const AuthResult(success: false, message: 'Please fix the errors.');
    }

    isLoading = true;
    notifyListeners();

    final result = await _repository.signup(
      fullName: fullName,
      email: email,
      phoneNumber: phoneNumber,
      password: password,
    );

    isLoading = false;
    notifyListeners();
    return result;
  }

  Future<void> logout() async {
    await _repository.logout();
    currentUser = null;
    password = '';
    notifyListeners();
  }

  Future<void> completeOnboarding() async {
    await _repository.completeOnboarding();
  }

  String? _validateEmail(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return 'Email is required';
    final pattern = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!pattern.hasMatch(trimmed)) return 'Enter a valid email address';
    return null;
  }

  String? _validatePassword(String value) {
    if (value.isEmpty) return 'Password is required';
    if (value.length < 6) return 'Password must be at least 6 characters';
    return null;
  }

  String? _validatePhone(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return 'Phone number is required';
    final digits = trimmed.replaceAll(RegExp(r'\D'), '');
    if (digits.length < 10) return 'Enter a valid phone number';
    return null;
  }
}
