import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:spirootv2/astrology/astrology_controller.dart';
import 'package:spirootv2/core/constant/my_color.dart';
import 'package:spirootv2/core/constant/my_size.dart';
import 'package:spirootv2/core/widget/gap/vertical_gap.dart';

Widget loveCareerMoney() {
  final AstrologyController astrologyController =
      Get.put(AstrologyController());

  return Obx(() => Row(
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
                    value: astrologyController.currentHoroscope.lovePercentage,
                    backgroundColor: Colors.white.withOpacity(0.1),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      MyColor.primaryLightColor,
                    ),
                  ),
                ),
              ),
              verticalGap(MySize.quarterPadding),
              Text(
                "%${(astrologyController.currentHoroscope.lovePercentage * 100).toInt()}",
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
                    value:
                        astrologyController.currentHoroscope.careerPercentage,
                    backgroundColor: Colors.white.withOpacity(0.1),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      MyColor.primaryLightColor,
                    ),
                  ),
                ),
              ),
              verticalGap(MySize.quarterPadding),
              Text(
                "%${(astrologyController.currentHoroscope.careerPercentage * 100).toInt()}",
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
                    value: astrologyController.currentHoroscope.moneyPercentage,
                    backgroundColor: Colors.white.withOpacity(0.1),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      MyColor.primaryLightColor,
                    ),
                  ),
                ),
              ),
              verticalGap(MySize.quarterPadding),
              Text(
                "%${(astrologyController.currentHoroscope.moneyPercentage * 100).toInt()}",
                style: TextStyle(
                  color: MyColor.white.withOpacity(0.7),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ));
}
