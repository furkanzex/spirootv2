import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:easy_localization/easy_localization.dart' as easy;
import 'package:spirootv2/core/constant/my_color.dart';
import 'package:spirootv2/core/constant/my_size.dart';
import 'package:spirootv2/core/constant/my_style.dart';

class NoInternetWidget extends StatelessWidget {
  const NoInternetWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Lottie.asset(
            'assets/lottie/no-int.json',
            repeat: true,
          ),
          const SizedBox(height: MySize.doublePadding),
          Text(
            easy.tr('internet.title'),
            style: MyStyle.s1.copyWith(
              color: MyColor.primaryLightColor,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: MySize.defaultPadding),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: MySize.defaultPadding),
            child: Text(
              easy.tr('internet.desc'),
              style: MyStyle.s2.copyWith(
                color: MyColor.primaryLightColor.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
