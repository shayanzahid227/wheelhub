import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hustler_syn/core/constant/colors.dart';
import 'package:hustler_syn/screens/root_screen/root_view_model.dart';

class CustomBottomNavigationBar extends StatelessWidget {
  final RootViewModel model;
  final List<Map<String, dynamic>> navItems;

  const CustomBottomNavigationBar(
      {super.key, required this.model, required this.navItems});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80.h,
      decoration: BoxDecoration(
          color: planCardColor,
          boxShadow: [
            BoxShadow(
              color: backGroundColor.withOpacity(0.5),
              spreadRadius: 0,
              blurRadius: 10,
              offset: const Offset(0, -3),
            ),
          ],
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(10.r),
            topRight: Radius.circular(10.r),
          ),
          border: Border.all(color: borderColor)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: navItems.asMap().entries.map((entry) {
          int index = entry.key;
          Map<String, dynamic> item = entry.value;
          bool isSelected = model.currentIndex == index;

          return Expanded(
            child: InkWell(
              onTap: () => model.setIndex(index),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image(
                    image: AssetImage(item['icon']),
                    width: 24.w,
                    height: 24.h,
                    color: isSelected ? primaryColor : greyColor,
                  ),
                  5.verticalSpace,
                  Text(
                    item['label'],
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                      color: isSelected ? primaryColor : greyColor,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
