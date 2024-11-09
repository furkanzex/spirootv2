import 'package:flutter/material.dart';
import 'package:spirootv2/core/constant/my_color.dart';
import 'package:spirootv2/core/constant/my_size.dart';
import 'package:spirootv2/core/constant/my_style.dart';

Widget sectionTitle({
  required String text,
  String? trailingLabel,
  VoidCallback? onTap,
  IconData? icon,
  Color? color,
}) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(
        text,
        style: MyStyle.s1
            .copyWith(color: MyColor.white, fontWeight: FontWeight.bold),
      ),
      if (trailingLabel != null || icon != null)
        GestureDetector(
          onTap: onTap,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                trailingLabel ?? "",
                style: MyStyle.s3
                    .copyWith(color: color, fontWeight: FontWeight.bold),
              ),
              if (icon != null)
                Icon(
                  icon,
                  size: MySize.iconSizeTiny,
                  color: color,
                ),
            ],
          ),
        )
    ],
  );
}
