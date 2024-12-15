import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:get/get.dart';
import 'package:spirootv2/core/constant/my_color.dart';
import 'package:spirootv2/core/constant/my_icon.dart';
import 'package:spirootv2/core/constant/my_style.dart';
import 'package:spirootv2/core/constant/my_size.dart';
import 'package:spirootv2/core/widget/gap/vertical_gap.dart';
import 'package:spirootv2/core/widget/text_field/section_title.dart';
import 'package:spirootv2/home/home_controller.dart';
import 'package:easy_localization/easy_localization.dart' as easy;

Widget socialSection(BuildContext context) {
  final controller = Get.find<HomeController>();
  return GestureDetector(
    onTap: () {
      controller.changePage(3);
    },
    child: Column(
      children: [
        Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: MySize.defaultPadding),
          child: sectionTitle(
            text: "⭐️ ${easy.tr("social.title")}",
            trailingLabel: easy.tr("home.see_all"),
            icon: MyIcon.forward,
            color: MyColor.primaryPurpleColor,
            onTap: () {
              controller.changePage(3);
            },
          ),
        ),
        verticalGap(MySize.defaultPadding),
        Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: MySize.defaultPadding),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(MySize.halfRadius),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    MyColor.primaryPurpleColor.withOpacity(0.8),
                    MyColor.primaryDarkColor.withOpacity(0.9),
                  ],
                ),
                borderRadius: BorderRadius.circular(MySize.halfRadius),
                boxShadow: [
                  BoxShadow(
                    color: MyColor.primaryPurpleColor.withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Dekoratif elementler
                  Positioned(
                    right: -20,
                    top: -20,
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: MyColor.white.withOpacity(0.1),
                      ),
                    ),
                  ),
                  Positioned(
                    left: -15,
                    bottom: -15,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: MyColor.white.withOpacity(0.1),
                      ),
                    ),
                  ),
                  // Ana içerik
                  Padding(
                    padding: EdgeInsets.all(MySize.defaultPadding * 1.5),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  context.tr('social.title'),
                                  style: MyStyle.b4.copyWith(
                                    color: MyColor.white,
                                    fontSize: 24,
                                    shadows: [
                                      Shadow(
                                        color: MyColor.black.withOpacity(0.3),
                                        offset: const Offset(0, 2),
                                        blurRadius: 4,
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: MySize.quarterPadding),
                                Text(
                                  context.tr('social.subtitle'),
                                  style: MyStyle.s2.copyWith(
                                    color: MyColor.white.withOpacity(0.9),
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              padding: EdgeInsets.all(MySize.defaultPadding),
                              decoration: BoxDecoration(
                                color: MyColor.white.withOpacity(0.2),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.people_outline,
                                color: MyColor.white,
                                size: MySize.iconSizeMedium,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: MySize.defaultPadding),
                        // Özellikler
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildFeature(
                              icon: Icons.post_add,
                              label: context.tr('social.posts'),
                            ),
                            _buildFeature(
                              icon: Icons.event,
                              label: context.tr('social.events'),
                            ),
                            _buildFeature(
                              icon: Icons.comment,
                              label: context.tr('social.comments'),
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
        ),
      ],
    ),
  );
}

Widget _buildFeature({
  required IconData icon,
  required String label,
}) {
  return Column(
    children: [
      Container(
        padding: EdgeInsets.all(MySize.defaultPadding * 0.7),
        decoration: BoxDecoration(
          color: MyColor.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(MySize.quarterRadius),
        ),
        child: Icon(
          icon,
          color: MyColor.white,
          size: MySize.iconSizeSmall,
        ),
      ),
      SizedBox(height: MySize.quarterPadding),
      Text(
        label,
        style: MyStyle.s3.copyWith(
          color: MyColor.white.withOpacity(0.9),
        ),
      ),
    ],
  );
}
