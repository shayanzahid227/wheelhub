import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hustler_syn/core/constant/app_assets.dart';
import 'package:hustler_syn/core/constant/colors.dart';
import 'package:hustler_syn/core/constant/colors.dart' as AppColors;
import 'package:hustler_syn/core/constant/text_style.dart';
import 'package:hustler_syn/core/model/job_post.dart';
import 'package:hustler_syn/core/utils/image_utils.dart';

class PostCard extends StatelessWidget {
  final PostModel post;

  const PostCard({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 15.h),
      padding: EdgeInsets.all(15.w),
      decoration: BoxDecoration(
        color: planCardColor,
        borderRadius: BorderRadius.circular(15.r),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 25.r,
                backgroundImage: imageProviderFor(
                  post.createdBy?.image,
                  placeholderAsset: AppAssets().profileIcon,
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(post.createdBy?.fullName ?? "User",
                            style: style16_600.copyWith(color: Colors.white)),
                        Wrap(
                          spacing: 8.w,
                          runSpacing: 5.h,
                          children: [post.categoryName ?? "General"]
                              .map((tag) =>
                                  _buildTag(tag, AppColors.primaryColor))
                              .toList(),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Icon(
                          Icons.watch_later_outlined,
                          color: greyColor,
                          size: 16.w,
                        ),
                        SizedBox(width: 5.w),
                        Text(_formatDateTime(post.createdAt),
                            style: style14_400.copyWith(
                                color: AppColors.greyColor)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 15.h),
          Text(
            post.title ?? "",
            style: style18_600.copyWith(fontWeight: FontWeight.w700),
          ),
          SizedBox(height: 8.h),
          Text(
            post.description ?? "",
            style: style14_400.copyWith(color: greyColor),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 15.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 5.h,
            children: (post.languages ?? [])
                .map((language) => Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                      decoration: BoxDecoration(
                        border: Border.all(color: borderColor),
                        borderRadius: BorderRadius.circular(999.r),
                      ),
                      child: Text(
                        language,
                        style: style12_600,
                      ),
                    ))
                .toList(),
          ),
// .

          ///
          /// Category Tags
          ///

          SizedBox(height: 15.h),
          Divider(
            color: borderColor,
          ),
          SizedBox(height: 8.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildDetailItem(Icons.location_on_outlined, post.location ?? ""),
              _buildDetailItem(null, "R ${post.budget ?? 0}",
                  textStyle: style16_600.copyWith(color: primaryColor)),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return "Unknown";
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 60) {
      return "${difference.inMinutes}m ago";
    } else if (difference.inHours < 24) {
      return "${difference.inHours}h ago";
    } else {
      return "${difference.inDays}d ago";
    }
  }

//change add here
  Widget _buildTag(String text, Color color) {
    return Padding(
      padding: const EdgeInsets.only(right: 15.0),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
        decoration: BoxDecoration(
          color: primaryColor,
          borderRadius: BorderRadius.circular(999.r),
        ),
        child: Text(
          text,
          style: style12_600.copyWith(color: backGroundColor),
        ),
      ),
    );
  }

  Widget _buildDetailItem(IconData? icon, String text, {TextStyle? textStyle}) {
    final TextStyle defaultStyle = style14_400.copyWith(color: greyColor);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 16.w, color: greyColor),
          SizedBox(width: 4.w),
        ],
        Text(
          text,
          style: textStyle ?? defaultStyle,
        ),
      ],
    );
  }
}
