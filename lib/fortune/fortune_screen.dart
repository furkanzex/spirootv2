import 'package:flutter/material.dart';
import 'package:spirootv2/core/constant/my_color.dart';
import 'package:spirootv2/core/constant/my_size.dart';
import 'package:spirootv2/fortune/fortune_history_section.dart';
import 'package:spirootv2/home/section/fortune_section.dart';
import 'package:easy_localization/easy_localization.dart' as easy;

class FortuneScreen extends StatelessWidget {
  const FortuneScreen({super.key});

  @override
  Widget build(BuildContext context) {
    bool hasFortunes = true; // Bu değer Firestore'dan gelecek

    return Scaffold(
      backgroundColor: MyColor.transparent,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(MySize.defaultPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!hasFortunes) ...[
                  fortuneSection(),
                ] else
                  fortuneHistorySection(context),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
