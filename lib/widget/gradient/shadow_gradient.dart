import 'package:flutter/material.dart';
import 'package:spirootv2/core/constant/my_color.dart';

Widget topRightShadow(Color color) {
  return Container(
    decoration: BoxDecoration(
      gradient: RadialGradient(
        center: Alignment.topRight,
        radius: 1,
        colors: [color, MyColor.transparent],
        stops: const [0, 1],
      ),
    ),
  );
}
