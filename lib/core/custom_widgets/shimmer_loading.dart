import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hustler_syn/core/constant/colors.dart';

class ShimmerWidget extends StatelessWidget {
  final double width;
  final double height;
  final ShapeBorder shapeBorder;

  const ShimmerWidget.rectangular({
    super.key,
    this.width = double.infinity,
    required this.height,
  }) : shapeBorder = const RoundedRectangleBorder();

  const ShimmerWidget.circular({
    super.key,
    required this.width,
    required this.height,
    this.shapeBorder = const CircleBorder(),
  });

  ShimmerWidget.rounded({
    super.key,
    this.width = double.infinity,
    required this.height,
    double borderRadius = 12,
  }) : shapeBorder = RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius.r),
        );

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[900]!,
      highlightColor: Colors.grey[800]!,
      child: Container(
        width: width,
        height: height,
        decoration: ShapeDecoration(
          color: Colors.grey[400]!,
          shape: shapeBorder,
        ),
      ),
    );
  }
}

class ProfileShimmer extends StatelessWidget {
  const ProfileShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 20.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 1.0.sw,
            padding: EdgeInsets.symmetric(vertical: 20.h),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16.r),
              color: planCardColor,
              border: Border.all(color: borderColor),
            ),
            child: Column(
              children: [
                ShimmerWidget.circular(width: 120.w, height: 120.w),
                SizedBox(height: 15.h),
                ShimmerWidget.rounded(width: 150.w, height: 25.h),
                SizedBox(height: 8.h),
                ShimmerWidget.rounded(width: 100.w, height: 18.h),
                SizedBox(height: 20.h),
                ShimmerWidget.rounded(
                    width: 80.w, height: 35.h, borderRadius: 20),
              ],
            ),
          ),
          SizedBox(height: 20.h),
          Container(
            padding: EdgeInsets.all(15.w),
            decoration: BoxDecoration(
              color: planCardColor,
              border: Border.all(color: borderColor),
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Column(
              children: List.generate(
                  3,
                  (index) => Padding(
                        padding: EdgeInsets.only(bottom: 20.h),
                        child: Row(
                          children: [
                            ShimmerWidget.circular(width: 30.w, height: 30.w),
                            SizedBox(width: 15.w),
                            Expanded(child: ShimmerWidget.rounded(height: 20)),
                          ],
                        ),
                      )),
            ),
          ),
        ],
      ),
    );
  }
}

class HomeCardShimmer extends StatelessWidget {
  const HomeCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 0.9.sw,
      height: 450.h,
      decoration: BoxDecoration(
        color: planCardColor,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
              child: const ShimmerWidget.rectangular(height: double.infinity),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(15.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerWidget.rounded(width: 200.w, height: 25.h),
                SizedBox(height: 10.h),
                ShimmerWidget.rounded(width: 120.w, height: 18.h),
                SizedBox(height: 10.h),
                Row(
                  children: [
                    ShimmerWidget.rounded(width: 60.w, height: 15.h),
                    SizedBox(width: 10.w),
                    ShimmerWidget.rounded(width: 60.w, height: 15.h),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class PostListShimmer extends StatelessWidget {
  const PostListShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 10.h),
      itemCount: 5,
      itemBuilder: (context, index) => Container(
        margin: EdgeInsets.only(bottom: 15.h),
        padding: EdgeInsets.all(15.w),
        decoration: BoxDecoration(
          color: planCardColor,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: borderColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ShimmerWidget.circular(width: 40.w, height: 40.w),
                SizedBox(width: 12.w),
                Expanded(child: ShimmerWidget.rounded(height: 18)),
              ],
            ),
            SizedBox(height: 15.h),
            ShimmerWidget.rounded(height: 20.h),
            SizedBox(height: 8.h),
            ShimmerWidget.rounded(height: 60.h),
            SizedBox(height: 15.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ShimmerWidget.rounded(width: 80.w, height: 15.h),
                ShimmerWidget.rounded(
                    width: 60.w, height: 25.h, borderRadius: 15),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class SubscriptionShimmer extends StatelessWidget {
  const SubscriptionShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 30.h),
      child: Column(
        children: [
          ShimmerWidget.circular(width: 145.h, height: 145.h),
          SizedBox(height: 20.h),
          ShimmerWidget.rounded(width: 250.w, height: 35.h),
          SizedBox(height: 10.h),
          ShimmerWidget.rounded(width: 200.w, height: 20.h),
          SizedBox(height: 40.h),
          Container(
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              color: planCardColor,
              border: Border.all(color: borderColor),
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerWidget.rounded(width: 150.w, height: 30.h),
                SizedBox(height: 20.h),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    ShimmerWidget.rounded(width: 100.w, height: 45.h),
                    SizedBox(width: 10.w),
                    ShimmerWidget.rounded(width: 60.w, height: 20.h),
                  ],
                ),
                SizedBox(height: 30.h),
                ...List.generate(
                    4,
                    (index) => Padding(
                          padding: EdgeInsets.only(bottom: 15.h),
                          child: Row(
                            children: [
                              ShimmerWidget.circular(width: 20.w, height: 20.w),
                              SizedBox(width: 12.w),
                              Expanded(
                                  child: ShimmerWidget.rounded(height: 18)),
                            ],
                          ),
                        )),
                SizedBox(height: 20.h),
                ShimmerWidget.rounded(height: 50.h, borderRadius: 12),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
