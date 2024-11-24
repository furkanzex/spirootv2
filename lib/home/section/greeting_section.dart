import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:spirootv2/home/home_controller.dart';
import 'package:spirootv2/profile/user_controller.dart';
import 'package:spirootv2/core/constant/my_color.dart';
import 'package:spirootv2/core/constant/my_icon.dart';
import 'package:spirootv2/core/constant/my_size.dart';
import 'package:spirootv2/core/constant/my_style.dart';
import 'package:spirootv2/core/constant/my_text.dart';
import 'package:spirootv2/core/widget/gap/horizontal_gap.dart';
import 'package:spirootv2/core/widget/gap/vertical_gap.dart';
import 'package:easy_localization/easy_localization.dart' as easy;
import 'package:spirootv2/core/widget/text_field/section_title.dart';
import 'package:spirootv2/spiritual/spiritual_chat_screen.dart';

Widget greetingSection({
  required String title,
  String? name,
}) {
  final userController = Get.find<UserController>();

  void onTap() {
    if (!userController.isProfileComplete) {
      final controller = Get.find<HomeController>();
      controller.changePage(2);
    } else {
      Get.to(() => SpiritualChatScreen());
    }
  }

  return Column(
    children: [
      sectionTitle(
        text: "🪬 ${easy.tr("navigation.guide")}",
        trailingLabel: easy.tr("home.spiritual_advisor.ask_now"),
        icon: MyIcon.forward,
        color: MyColor.primaryLightColor,
        onTap: onTap,
      ),
      verticalGap(MySize.defaultPadding),
      Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(MySize.halfRadius),
          color: MyColor.white.withOpacity(0.1),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(MySize.halfRadius),
            child: Padding(
              padding: const EdgeInsets.all(MySize.defaultPadding),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    width: MySize.iconSizeMedium,
                    height: MySize.iconSizeMedium,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          MyColor.primaryColor,
                          MyColor.thirdColor,
                        ],
                      ),
                    ),
                    child: Image.asset("assets/images/logo.png"),
                  ),
                  horizontalGap(MySize.defaultPadding),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: MySize.defaultPadding,
                            vertical: MySize.halfPadding,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(MySize.halfRadius),
                              topRight: Radius.circular(MySize.halfRadius),
                              bottomRight: Radius.circular(MySize.halfRadius),
                              bottomLeft: Radius.circular(0),
                            ),
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                MyColor.primaryLightColor,
                                MyColor.thirdColor,
                              ],
                            ),
                          ),
                          child: Text(
                            easy.tr("home.spiritual_advisor.title"),
                            style: MyStyle.s2.copyWith(
                              color: MyColor.white,
                              height: 1.3,
                            ),
                          ),
                        ),
                        verticalGap(4),
                        Text(
                          MyText.appName,
                          style: MyStyle.s3.copyWith(
                            color: MyColor.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ],
  );
}
