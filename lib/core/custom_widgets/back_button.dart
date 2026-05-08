
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get_core/get_core.dart';
import 'package:get/get_navigation/get_navigation.dart';
import 'package:hustler_syn/core/constant/colors.dart';

class CustomBackButton extends StatelessWidget {
  final Color backgroundColor;
  final Color iconColor;
  const CustomBackButton({
    super.key,
    this.backgroundColor = whiteColor,
    this.iconColor = blackColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 33.h,
      width: 33.w,
      alignment: Alignment.center, // ✅ ensures fixed size & centered icon
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: backgroundColor,
        boxShadow: [
          BoxShadow(
            blurRadius: 4,
            spreadRadius: 0,
            color: blackColor.withOpacity(0.15),
          ),
        ],
      ),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque, // ✅ makes tap area equal to container
        onTap: () {
          Get.back();
        },
        child: Icon(Icons.arrow_back_ios_sharp, color: iconColor, size: 20),
      ),
    );
  }
}
