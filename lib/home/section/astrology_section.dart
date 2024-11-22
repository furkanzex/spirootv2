import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:spirootv2/home/home_controller.dart';
import 'package:spirootv2/profile/user_controller.dart';
import 'package:spirootv2/core/constant/my_color.dart';
import 'package:spirootv2/core/constant/my_icon.dart';
import 'package:spirootv2/core/constant/my_image.dart';
import 'package:spirootv2/core/constant/my_size.dart';
import 'package:spirootv2/core/constant/my_style.dart';
import 'package:spirootv2/core/widget/gap/horizontal_gap.dart';
import 'package:spirootv2/core/widget/gap/vertical_gap.dart';
import 'package:spirootv2/core/widget/text_field/section_title.dart';
import 'package:easy_localization/easy_localization.dart' as easy;

Widget astrologySection() {
  final controller = Get.put(UserController());

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      sectionTitle(
        text: "🪐 ${easy.tr("navigation.astrology")}",
        trailingLabel: easy.tr("home.see_all"),
        icon: MyIcon.forward,
        color: MyColor.primaryLightColor,
        onTap: () {
          final controller = Get.find<HomeController>();
          controller.changePage(2);
        },
      ),
      verticalGap(MySize.defaultPadding),
      ClipRRect(
        borderRadius: BorderRadius.circular(MySize.halfRadius),
        child: InkWell(
          onTap: () {
            final controller = Get.find<HomeController>();
            controller.changePage(2);
          },
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.all(MySize.defaultPadding),
            decoration: BoxDecoration(
              color: MyColor.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(MySize.halfRadius),
              border: Border.all(
                color: MyColor.primaryLightColor.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    SizedBox(
                      height: MySize.iconSizeMedium,
                      width: MySize.iconSizeMedium,
                      child: SvgPicture.asset(MyImage.welcomeImage),
                    ),
                    horizontalGap(MySize.defaultPadding),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            controller.isProfileComplete
                                ? easy.tr(
                                    "Evren sana bir mesaj gönderdi...\nAçmaya hazır mısın?")
                                : easy.tr("Astroloji Yolculuğunu Hemen Başlat"),
                            style: MyStyle.s2.copyWith(
                              color: MyColor.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                verticalGap(MySize.defaultPadding),
                Row(
                  children: [
                    _buildFeatureItem("🌟", easy.tr("Burç Kartı")),
                    horizontalGap(MySize.defaultPadding),
                    _buildFeatureItem("💫", easy.tr("Doğum Haritası")),
                    horizontalGap(MySize.defaultPadding),
                    _buildFeatureItem("🎯", easy.tr("Öngörüler")),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    ],
  );
}

Widget _buildFeatureItem(String emoji, String text) {
  return Expanded(
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: MyColor.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(MySize.quarterRadius),
      ),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          verticalGap(4),
          Text(
            text,
            textAlign: TextAlign.center,
            style: MyStyle.s3.copyWith(
              color: MyColor.textGreyColor,
              fontSize: 12,
            ),
          ),
        ],
      ),
    ),
  );
}
