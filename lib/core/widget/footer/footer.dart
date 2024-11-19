import 'package:flutter/material.dart';
import 'package:spirootv2/core/constant/my_color.dart';
import 'package:spirootv2/core/constant/my_size.dart';
import 'package:spirootv2/core/constant/my_style.dart';
import 'package:spirootv2/core/constant/my_text.dart';
import 'package:spirootv2/core/widget/gap/vertical_gap.dart';

Widget footer() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      verticalGap(MySize.doublePadding * 3),
      SizedBox(
        height: MySize.gridSize,
        width: MySize.gridSize,
        child: Image.asset("assets/images/logo.png"),
      ),
      verticalGap(MySize.halfPadding),
      Text(
        MyText.appName,
        style: MyStyle.b5.copyWith(color: MyColor.white),
      ),
      verticalGap(MySize.quarterPadding),
      Text(
        "Apptoic®",
        style: MyStyle.s3.copyWith(color: MyColor.textGreyColor),
      ),
      verticalGap(MySize.doublePadding),
    ],
  );
}
