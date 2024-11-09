import 'package:flutter/material.dart';
import 'package:spirootv2/core/constant/my_color.dart';
import 'package:spirootv2/core/constant/my_size.dart';
import 'package:spirootv2/widget/gap/vertical_gap.dart';

Widget loveCareerMoney() {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Aşk",
            style: TextStyle(
              color: MyColor.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          verticalGap(MySize.quarterPadding),
          ClipRRect(
            borderRadius: BorderRadius.circular(MySize.halfRadius),
            child: Container(
              width: 75,
              height: 6,
              decoration: BoxDecoration(
                color: MyColor.primaryDarkColor.withOpacity(0.3),
                borderRadius: BorderRadius.circular(MySize.halfRadius),
              ),
              child: LinearProgressIndicator(
                value: 0.75,
                backgroundColor: Colors.transparent,
                valueColor: AlwaysStoppedAnimation<Color>(
                  MyColor.primaryLightColor,
                ),
              ),
            ),
          ),
          verticalGap(MySize.quarterPadding),
          Text(
            "%75",
            style: TextStyle(
              color: MyColor.white.withOpacity(0.7),
              fontSize: 12,
            ),
          ),
        ],
      ),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Kariyer",
            style: TextStyle(
              color: MyColor.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          verticalGap(MySize.quarterPadding),
          ClipRRect(
            borderRadius: BorderRadius.circular(MySize.halfRadius),
            child: Container(
              width: 75,
              height: 6,
              decoration: BoxDecoration(
                color: MyColor.primaryDarkColor.withOpacity(0.3),
                borderRadius: BorderRadius.circular(MySize.halfRadius),
              ),
              child: LinearProgressIndicator(
                value: 0.5,
                backgroundColor: Colors.transparent,
                valueColor: AlwaysStoppedAnimation<Color>(
                  MyColor.primaryLightColor,
                ),
              ),
            ),
          ),
          verticalGap(MySize.quarterPadding),
          Text(
            "%50",
            style: TextStyle(
              color: MyColor.white.withOpacity(0.7),
              fontSize: 12,
            ),
          ),
        ],
      ),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Para",
            style: TextStyle(
              color: MyColor.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          verticalGap(MySize.quarterPadding),
          ClipRRect(
            borderRadius: BorderRadius.circular(MySize.halfRadius),
            child: Container(
              width: 75,
              height: 6,
              decoration: BoxDecoration(
                color: MyColor.primaryDarkColor.withOpacity(0.3),
                borderRadius: BorderRadius.circular(MySize.halfRadius),
              ),
              child: LinearProgressIndicator(
                value: 0.95,
                backgroundColor: Colors.transparent,
                valueColor: AlwaysStoppedAnimation<Color>(
                  MyColor.primaryLightColor,
                ),
              ),
            ),
          ),
          verticalGap(MySize.quarterPadding),
          Text(
            "%95",
            style: TextStyle(
              color: MyColor.white.withOpacity(0.7),
              fontSize: 12,
            ),
          ),
        ],
      ),
    ],
  );
}
