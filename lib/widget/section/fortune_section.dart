import 'package:flutter/material.dart';
import 'package:spirootv2/core/constant/my_color.dart';
import 'package:spirootv2/core/constant/my_size.dart';
import 'package:spirootv2/widget/gap/vertical_gap.dart';
import 'package:spirootv2/widget/text_field/section_title.dart';
import 'package:easy_localization/easy_localization.dart' as easy;

Widget fortuneSection() {
  return Column(
    children: [
      sectionTitle(
          text: "🔮 ${easy.tr("navigation.fortune")}",
          trailingLabel: easy.tr("home.see_all"),
          icon: Icons.keyboard_arrow_right,
          color: MyColor.primaryLightColor),
      verticalGap(MySize.defaultPadding),
    ],
  );
}
