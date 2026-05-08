// ignore_for_file: must_be_immutable, use_key_in_widget_constructors, deprecated_member_use

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hustler_syn/core/constant/app_assets.dart';
import 'package:hustler_syn/core/constant/colors.dart';
import 'package:hustler_syn/core/constant/text_style.dart';
import 'package:hustler_syn/core/model/app_user_model.dart';
import 'package:shimmer/shimmer.dart';

class ProfileCard extends StatelessWidget {
  AppUser profileModel = AppUser();

  ProfileCard({required this.profileModel});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.0.w),
      height: MediaQuery.sizeOf(context).height * 0.58,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        color: Colors.black,
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(25),
            child: Stack(
              children: [
                ///
                /// main big image --> user image
                /// Only load from network when it's a valid URL; otherwise use placeholder asset.
                (profileModel.image != null &&
                        profileModel.image!.startsWith('http'))
                    ? CachedNetworkImage(
                        imageUrl: profileModel.image!,
                        height: double.infinity,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        fadeInDuration: Duration.zero,
                        placeholder: (context, url) => Shimmer.fromColors(
                          baseColor: Colors.grey[800]!,
                          highlightColor: Colors.grey[700]!,
                          child: Container(
                            height: double.infinity,
                            width: double.infinity,
                            color: Colors.black,
                          ),
                        ),
                        errorWidget: (context, url, error) => Image.asset(
                          AppAssets().boys,
                          height: double.infinity,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      )
                    : Image.asset(
                        AppAssets().boys,
                        height: double.infinity,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  height: MediaQuery.sizeOf(context).height * 0.5,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          blackColor.withOpacity(1),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            right: 20,
            top: 20,
            child: CircleAvatar(
              backgroundColor: Color(0xff3ee0cf66).withOpacity(0.8),
              child: Icon(
                Icons.info_outline_rounded,
                color: Colors.white,
                size: 30,
              ),
            ),
          ),
          Positioned(
            bottom: 30,
            left: 20,
            right: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        profileModel.fullName ?? '',
                        style: style25B.copyWith(),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),

                    ///
                    ///. verified badge container in front of name
                    ///
                    20.horizontalSpace,
                    Container(
                      decoration: BoxDecoration(
                        color: primaryColor,
                        borderRadius: BorderRadiusDirectional.circular(999.r),
                      ),
                      child: Padding(
                        padding: EdgeInsetsGeometry.symmetric(
                            horizontal: 12, vertical: 4),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Image.asset(
                              AppAssets().vettedIcon,
                              scale: 4,
                              height: 13.h,
                              width: 13.w,
                            ),
                            5.horizontalSpace,
                            Text(
                              'Vetted',
                              style: style12_600.copyWith(color: blackColor),
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
                SizedBox(height: 4),

                ///
                ///. herw we will show business name
                ///

                Text(
                  profileModel.businessName ?? 'no business name',
                  style: style16_600.copyWith(fontSize: 17.sp),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 10),
                Row(
                  children: [
                    Icon(Icons.star, color: Colors.yellow, size: 18),
                    SizedBox(width: 5),
                    Text(
                      (profileModel.rating ?? 5.0).toStringAsFixed(1),
                      style: style14_600.copyWith(fontSize: 15.sp),
                    ),
                    10.horizontalSpace,
                   Text("()",style: style14_600.copyWith(color: greyColor),)
                  ],
                ),
                SizedBox(height: 12),
                Row(
  children: [
    Icon(Icons.location_on_outlined,
        color: greyColor, size: 18),
    SizedBox(width: 5),
    Flexible(
      child: Text(
        profileModel.distance?.isNotEmpty == true
            ? profileModel.distance!
            : "city name",
        style: style14_600.copyWith(
            fontSize: 15.sp, color: greyColor),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    )
  ],
                )

                // tags
                // Builder(
                //   builder: (context) {
                //     // Derive up to 4 unique service categories from the hustler's services.
                //     final List<String> serviceTags = [];
                //     if (profileModel.servicePrices != null) {
                //       for (final service in profileModel.servicePrices!) {
                //         final name = service.serviceCategoryName?.trim();
                //         if (name != null &&
                //             name.isNotEmpty &&
                //             !serviceTags.contains(name)) {
                //           serviceTags.add(name);
                //           if (serviceTags.length >= 4) break;
                //         }
                //       }
                //     }

                //     final List<String> tagsToShow = serviceTags.isNotEmpty
                //         ? serviceTags
                //         : (profileModel.tags ??
                //             ['tag1', 'tag2', 'tag3', 'tag4']);

                //     return Wrap(
                //       spacing: 8,
                //       runSpacing: 8,
                //       children: tagsToShow.map((tag) {
                //         return Container(
                //           padding:
                //               EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                //           decoration: BoxDecoration(
                //             color: backGroundColor,
                //             borderRadius: BorderRadius.circular(11283.r),
                //           ),
                //           child: Text(
                //             tag,
                //             style: style14_600,
                //           ),
                //         );
                //       }).toList(),
                //     );
                //   },
                // )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
