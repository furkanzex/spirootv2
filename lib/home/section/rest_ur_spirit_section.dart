import 'package:flutter/material.dart';
import 'package:spirootv2/core/constant/my_color.dart';
import 'package:spirootv2/core/constant/my_size.dart';
import 'package:spirootv2/fortune/fortune_card_model.dart';
import 'package:spirootv2/fortune/fortune_card.dart';
import 'package:spirootv2/core/widget/gap/vertical_gap.dart';
import 'package:spirootv2/core/widget/text_field/section_title.dart';
import 'package:easy_localization/easy_localization.dart' as easy;
import 'package:spirootv2/rest_your_spirit/affirmation_screen.dart';
import 'package:spirootv2/rest_your_spirit/meditation_screen.dart';

Widget restUrSpiritSection(BuildContext context) {
  final List<FortuneCard> fortuneCards = [
    FortuneCard(
      image: "https://apptoic.com/spiroot/images/affirmation.png",
      title: "Olumlama Egzersizi",
      color: MyColor.white.withOpacity(0.1),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AffirmationScreen()),
        );
      },
    ),
    FortuneCard(
      image: "https://apptoic.com/spiroot/images/meditation.png",
      title: "Meditasyon Egzersizi",
      color: MyColor.primaryLightColor,
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const MeditationScreen()),
        );
      },
    ),
  ];

  return Column(
    children: [
      sectionTitle(
        text: "🧘 ${easy.tr("navigation.rest_ur_spirit")}",
      ),
      verticalGap(MySize.defaultPadding),
      GridView.count(
        padding: EdgeInsets.all(0),
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        mainAxisSpacing: MySize.sixQuartersPadding,
        crossAxisSpacing: MySize.halfPadding,
        childAspectRatio: 3 / 2,
        children: fortuneCards.map((card) => buildFortuneCard(card)).toList(),
      ),
    ],
  );
}
