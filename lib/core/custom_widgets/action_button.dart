import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hustler_syn/core/constant/colors.dart';

class ActionButtons extends StatelessWidget {
  final VoidCallback onClose;
  final VoidCallback onFavorite;

  const ActionButtons({
    super.key,
    required this.onClose,
    required this.onFavorite,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        InkWell(
          onTap: onClose,
          child: Container(
            height: 70.h,
            width: 70.w,
            decoration: BoxDecoration(
                color: backGroundColor,
                shape: BoxShape.circle,
                border: Border.all(color: borderColor)),
            child: Icon(Icons.close, color: Colors.red, size: 20),
          ),
        ),

        SizedBox(width: 30),

        // Favorite button
        InkWell(
          onTap: onFavorite,
          child: CircleAvatar(
            radius: 35,
            backgroundColor: primaryColor,
            child: Icon(Icons.favorite, color: backGroundColor, size: 35),
          ),
        ),
      ],
    );
  }
}
