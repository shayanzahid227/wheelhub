import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hustler_syn/core/constant/colors.dart';
import 'package:hustler_syn/core/constant/text_style.dart';

class CustomButton extends StatelessWidget {
  const CustomButton({
    super.key,
    required this.text,
    required this.onTap,
    this.gradientColors, // ✅ optional custom gradient
    this.width,
    this.borderColor,
    this.textColor,
    this.isLoading = false,
  });
  final width;
  final text;
  final VoidCallback onTap;
  final List<Color>? gradientColors; // ✅ new field
  final borderColor;
  final textColor;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0.0),
      child: SizedBox(
        width: width ?? double.infinity,
        height: 50,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14.r),
            ),
            padding: EdgeInsets.zero,
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
          ),
          onPressed: isLoading ? null : onTap,
          child: Ink(
            decoration: BoxDecoration(
              border: Border.all(color: borderColor ?? Colors.transparent),
              gradient: LinearGradient(
                colors:
                    gradientColors ?? [primaryColor, primaryColor], // ✅ default
              ),
              borderRadius: BorderRadius.circular(14.r),
            ),
            child: Container(
              alignment: Alignment.center,
              child: isLoading
                  ? const CircularProgressIndicator(
                      color: backGroundColor,
                    )
                  : Text(
                      text,
                      style: style14B.copyWith(
                          color: textColor ?? backGroundColor,
                          fontWeight: FontWeight.w800),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
