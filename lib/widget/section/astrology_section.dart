import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:spirootv2/core/constant/my_color.dart';
import 'package:spirootv2/core/constant/my_icon.dart';
import 'package:spirootv2/core/constant/my_size.dart';
import 'package:spirootv2/core/constant/my_style.dart';
import 'package:spirootv2/widget/astrology/love_career_money.dart';
import 'package:spirootv2/widget/gap/vertical_gap.dart';
import 'package:spirootv2/widget/text_field/section_title.dart';
import 'package:easy_localization/easy_localization.dart' as easy;

Widget astrologySection() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      sectionTitle(
          text: "🪐 ${easy.tr("navigation.astrology")}",
          trailingLabel: easy.tr("home.see_all"),
          icon: MyIcon.forward,
          color: MyColor.primaryLightColor),
      verticalGap(MySize.defaultPadding),
      ClipRRect(
        borderRadius: BorderRadius.circular(MySize.halfRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.all(MySize.defaultPadding),
            decoration: BoxDecoration(
              color: MyColor.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(MySize.halfRadius),
            ),
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
                          "Furkan Zekiri",
                          style: MyStyle.s3.copyWith(
                              color: MyColor.white,
                              fontWeight: FontWeight.bold),
                        ),
                        Text(
                          "Mart 9, 2002 • 13:30",
                          style: MyStyle.s3.copyWith(
                              color: MyColor.textGreyColor,
                              fontWeight: FontWeight.normal),
                        ),
                      ],
                    ),
                    Text(
                      "Bugün",
                      style: MyStyle.s2.copyWith(
                          color: MyColor.textGreyColor,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                verticalGap(MySize.defaultPadding),
                Text(
                  "Neque porro quisquam est qui dolorem ipsum quia dolor sit amet, consectetur, adipisci velit...",
                  style: MyStyle.s3.copyWith(
                      color: MyColor.white, fontWeight: FontWeight.bold),
                ),
                verticalGap(MySize.defaultPadding),
                loveCareerMoney(),
              ],
            ),
          ),
        ),
      ),
    ],
  );
}
