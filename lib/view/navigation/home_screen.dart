import 'package:flutter/material.dart';
import 'package:spirootv2/core/constant/my_size.dart';
import 'package:spirootv2/widget/gap/vertical_gap.dart';
import 'package:spirootv2/widget/section/astrology_section.dart';
import 'package:spirootv2/widget/section/fortune_section.dart';
import 'package:spirootv2/widget/section/greeting_section.dart';
import 'package:easy_localization/easy_localization.dart' as easy;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(MySize.defaultPadding),
      child: SingleChildScrollView(
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
          ],
        ),
      ),
    );
  }
}
