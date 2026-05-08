import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hustler_syn/core/constant/colors.dart';
import 'package:hustler_syn/core/constant/text_style.dart';

/// App-wide custom SnackBar using theme colors and text style.
/// Use [context] when in a Widget; when in a ViewModel pass null to use [Get.context].
class AppSnackBar {
  AppSnackBar._();

  static const Duration _defaultDuration = Duration(seconds: 3);
  static const Duration _longDuration = Duration(seconds: 5);

  static BuildContext? _resolveContext(BuildContext? context) {
    if (context != null && context.mounted) return context;
    final ctx = Get.context;
    if (ctx != null && ctx.mounted) return ctx;
    return null;
  }

  /// Success (e.g. "Order completed") – primaryColor background, white text.
  static void showSuccess(BuildContext? context, String message, {Duration? duration}) {
    _show(context, message, backgroundColor: primaryColor, duration: duration ?? _defaultDuration);
  }

  /// Error (e.g. validation/API error) – dark red background, white text.
  static void showError(BuildContext? context, String message, {Duration? duration}) {
    _show(context, message, backgroundColor: const Color(0xff8B2E2E), duration: duration ?? _defaultDuration);
  }

  /// Warning/info (e.g. "Token re-registered") – planCardColor background, white text.
  static void showInfo(BuildContext? context, String message, {Duration? duration}) {
    _show(context, message, backgroundColor: planCardColor, duration: duration ?? _defaultDuration);
  }

  /// Single method: [isError] true → error style, false → success style. [longDuration] for 5s.
  static void show(
    BuildContext? context,
    String message, {
    bool isError = false,
    bool longDuration = false,
    Duration? duration,
  }) {
    final d = duration ?? (longDuration ? _longDuration : _defaultDuration);
    if (isError) {
      showError(context, message, duration: d);
    } else {
      showSuccess(context, message, duration: d);
    }
  }

  static void _show(
    BuildContext? context,
    String message, {
    required Color backgroundColor,
    required Duration duration,
  }) {
    final ctx = _resolveContext(context);
    if (ctx == null) return;
    ScaffoldMessenger.of(ctx).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: style14_500.copyWith(color: whiteColor),
        ),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        duration: duration,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }
}
