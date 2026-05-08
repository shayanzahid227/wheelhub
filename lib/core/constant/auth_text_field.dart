import 'package:flutter/material.dart';
import 'package:hustler_syn/core/constant/colors.dart';
import 'package:hustler_syn/core/constant/text_style.dart';

final customAuthField = InputDecoration(
  hintText: "User Name",
  hintStyle: style16_400.copyWith(color: greyColor),
  contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 25),
  fillColor: backGroundColor,
  filled: true,
  enabledBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(10),
    borderSide: const BorderSide(color: borderColor, width: 1),
  ),
  focusedBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(10),
    borderSide: const BorderSide(color: borderColor, width: 1),
  ),
  errorBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(10),
    borderSide: const BorderSide(color: borderColor, width: 1),
  ),
  disabledBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(10),
    borderSide: const BorderSide(color: borderColor, width: 1),
  ),
);

extension InputDecorationRadius on InputDecoration {
  InputDecoration withRadius(double radius) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(radius),
      borderSide: const BorderSide(color: borderColor, width: 1),
    );

    return copyWith(
      enabledBorder: border,
      focusedBorder: border,
      errorBorder: border,
      disabledBorder: border,
    );
  }
}
