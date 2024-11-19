import 'package:flutter/material.dart';
import 'package:spirootv2/core/constant/my_color.dart';
import 'package:spirootv2/core/constant/my_size.dart';

Widget customElevatedButton({
  VoidCallback? onPressed,
  final String? title,
  final String? imgPath,
  final double? imgSize,
  final TextStyle? titleStyle,
  final IconData? icon,
  final double? iconSize,
  final Color? frontColor,
  required Color bgPrimaryColor,
  final Color? bgSecondaryColor,
  final Widget? child,
}) {
  return Container(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(MySize.halfRadius),
      gradient: bgSecondaryColor != null
          ? LinearGradient(colors: [bgPrimaryColor, bgSecondaryColor])
          : null,
      color: bgSecondaryColor != null ? null : bgPrimaryColor,
    ),
    child: ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: MyColor.transparent,
        elevation: 0,
        padding: const EdgeInsets.symmetric(
          horizontal: MySize.defaultPadding,
          vertical: MySize.halfPadding,
        ),
      ),
      child: child ??
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (imgPath != null)
                SizedBox(
                  width: imgSize ?? MySize.iconSizeTiny,
                  child: Image.asset(imgPath),
                ),
              if (icon != null)
                Icon(
                  icon,
                  size: iconSize ?? MySize.iconSizeTiny,
                  color: frontColor,
                ),
              if ((imgPath != null && title != null) ||
                  (icon != null && title != null))
                const SizedBox(
                  width: MySize.defaultPadding,
                ),
              if (title != null)
                Text(
                  title,
                  style: titleStyle,
                ),
            ],
          ),
    ),
  );
}
