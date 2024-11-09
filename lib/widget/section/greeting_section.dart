import 'package:flutter/material.dart';
import 'package:spirootv2/core/constant/my_color.dart';
import 'package:spirootv2/core/constant/my_size.dart';
import 'package:spirootv2/core/constant/my_style.dart';
import 'package:spirootv2/widget/gap/vertical_gap.dart';
import 'package:spirootv2/widget/text_field/section_title.dart';

Widget greetingSection({
  required String title,
  String? name,
  required String quote,
  required String quoteOwner,
}) {
  return Column(
    children: [
      Row(
        children: [
          sectionTitle(text: name == null ? "👋 $title" : "👋 $title $name")
        ],
      ),
      verticalGap(MySize.defaultPadding),
      Row(
        children: [
          Expanded(
            child: Text(
              quote,
              style: MyStyle.s3.copyWith(color: MyColor.white),
            ),
          )
        ],
      ),
      verticalGap(MySize.halfPadding),
      Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            quoteOwner,
            style: MyStyle.s3.copyWith(color: MyColor.textGreyColor),
          )
        ],
      ),
    ],
  );
}
