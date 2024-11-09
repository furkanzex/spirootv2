import 'package:flutter/material.dart';
import 'package:spirootv2/core/constant/my_size.dart';
import 'package:spirootv2/widget/footer/footer.dart';
import 'package:spirootv2/widget/gap/vertical_gap.dart';
import 'package:spirootv2/widget/section/astrology_section.dart';
import 'package:spirootv2/widget/section/enlightenment_section.dart';
import 'package:spirootv2/widget/section/fortune_section.dart';
import 'package:spirootv2/widget/section/greeting_section.dart';
import 'package:easy_localization/easy_localization.dart' as easy;
import 'package:spirootv2/widget/section/luck_section.dart';
import 'package:spirootv2/widget/section/rest_ur_spirit_section.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(MySize.defaultPadding),
            child: Column(
              children: [
                greetingSection(
                    title: easy.tr("home.greeting"),
                    quote:
                        "Neque porro quisquam est qui dolorem ipsum quia dolor sit amet, consectetur, adipisci velit...",
                    quoteOwner: "~ Çeyru Guvero"),
                verticalGap(MySize.doublePadding),
                astrologySection(),
                verticalGap(MySize.doublePadding),
                fortuneSection(),
                verticalGap(MySize.doublePadding),
                luckSection(),
                verticalGap(MySize.doublePadding),
              ],
            ),
          ),
          enlightenmentSection(),
          Padding(
            padding: const EdgeInsets.all(MySize.defaultPadding),
            child: Column(
              children: [
                verticalGap(MySize.doublePadding),
                restUrSpiritSection(),
                footer(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
