import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hustler_syn/core/constant/app_assets.dart';
import 'package:hustler_syn/core/constant/colors.dart';
import 'package:hustler_syn/core/constant/text_style.dart';
import 'package:hustler_syn/core/services/local_storagre_services.dart';
import 'package:hustler_syn/core/model/app_user_model.dart';
import 'package:hustler_syn/core/utils/image_utils.dart';
import 'package:hustler_syn/locator.dart';

class CustomDiscoverCard extends StatelessWidget {
  final AppUser model;
  final VoidCallback onTap;

  const CustomDiscoverCard(
      {super.key, required this.model, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final viewerRole = locator<LocalStorageService>().user?.role;
    // You can customize this logic based on your needs
    bool isComingSoon = model.category?.toLowerCase() == "coming soon" ||
        (model.tags?.contains("Coming Soon") ?? false);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 15.h),
        decoration: BoxDecoration(
            color: planCardColor,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
                color: isComingSoon
                    ? primaryColor.withOpacity(0.25)
                    : borderColor)),
        child: Padding(
          padding: EdgeInsets.all(12.w),
          child: Row(
            children: [
              Container(
                height: 80.h,
                width: 80.w, // Fixed the double dot issue
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16.r),
                  image: isComingSoon
                      ? null
                      : DecorationImage(
                          image: isNetworkImageUrl(model.image)
                              ? CachedNetworkImageProvider(model.image!)
                                  as ImageProvider
                              : AssetImage(AppAssets().boys),
                          fit: BoxFit.cover,
                        ),
                ),
                child: isComingSoon
                    ? Center(
                        child: CircleAvatar(
                          radius: 30.r,
                          backgroundImage: isNetworkImageUrl(model.image)
                              ? CachedNetworkImageProvider(model.image!)
                                  as ImageProvider
                              : AssetImage(AppAssets().boys),
                        ),
                      )
                    : null,
              ),
              SizedBox(width: 15.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      // this name is not showing here please make it fix
                      model.fullName ?? "",
                      style: style16_600.copyWith(),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      // category issue
                      model.category ?? "no category found",
                      style: style14_400.copyWith(color: greyColor),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    isComingSoon
                        ? Text('')
                        : Row(
                            children: [
                              Image(
                                image: AssetImage(
                                  AppAssets().locationIcon,
                                ),
                                height: 12.h,
                                color: whiteColor,
                                width: 10.w,
                              ),
                              5.horizontalSpace,
                              Flexible(
                                child: Text(
                                  model.distance?.isNotEmpty == true
                                      ? model.distance!
                                      : "0.0",
                                  style: style14_400.copyWith(),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              10.horizontalSpace,
                              Icon(Icons.star, color: Colors.amber, size: 16.w),
                              5.horizontalSpace,
                              Text(
                                (model.rating ?? 5.0).toStringAsFixed(1),
                                style: style14_400.copyWith(),
                              ),
                              Spacer(),
                              if (model.servicePrices != null &&
                                  model.servicePrices!.isNotEmpty)
                                Text(
                                  "R ${model.servicePrices![0].formatAmount(model.servicePrices![0].priceForViewer(viewerRole))}",
                                  style:
                                      style14_600.copyWith(color: primaryColor),
                                ),
                            ],
                          ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
