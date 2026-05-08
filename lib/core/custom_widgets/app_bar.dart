import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hustler_syn/core/constant/app_assets.dart';
import 'package:hustler_syn/core/constant/colors.dart';
import 'package:hustler_syn/core/constant/text_style.dart';

import 'package:hustler_syn/screens/profile/notification_screen/notification_screen.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showRedIcon;
  final bool centerTitle;
  final bool showBackButton;
  final bool showAction;
  final Widget? action;

  const CustomAppBar({
    super.key,
    required this.title,
    this.showRedIcon = true,
    this.centerTitle = true,
    this.showBackButton = true,
    this.showAction = true,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      toolbarHeight: 100.h,
      leading: showBackButton
          ? IconButton(
              onPressed: () => Get.back(),
              icon: Icon(Icons.arrow_back, color: whiteColor),
            )
          : null,
      title: Text(title, style: style20_600),
      centerTitle: centerTitle,
      actions: showAction
          ? [
              Padding(
                padding: const EdgeInsets.only(right: 15.0),
                child: action ??
                    Padding(
                      padding: EdgeInsets.only(right: 15.w),
                      child: Stack(
                        children: [
                          GestureDetector(
                            onTap: () => Get.to(NotificationScreen()),
                            child: Container(
                              height: 30.h,
                              width: 27.w,
                              margin: EdgeInsets.only(top: 20.h),
                              child: Image(
                                image: AssetImage(AppAssets().notificationIcon),
                                color: Colors.white,
                              ),
                            ),
                          ),
                          if (showRedIcon)
                            Positioned(
                              top: 15.h,
                              right: 0,
                              child: const Icon(
                                Icons.circle,
                                color: Colors.red,
                                size: 10,
                              ),
                            ),
                        ],
                      ),
                    ),
              ),
            ]
          : null,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
