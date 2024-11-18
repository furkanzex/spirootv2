import 'package:flutter/material.dart';
import 'package:spirootv2/core/constant/my_color.dart';
import 'package:spirootv2/core/constant/my_size.dart';
import 'package:spirootv2/model/fortune_card_model.dart';
import 'package:spirootv2/widget/card/fortune_card.dart';
import 'package:spirootv2/widget/gap/vertical_gap.dart';
import 'package:spirootv2/widget/text_field/section_title.dart';
import 'package:easy_localization/easy_localization.dart' as easy;

Widget luckSection() {
  final List<FortuneCard> fortuneCards = [
    FortuneCard(
      image: "https://apptoic.com/spiroot/images/cookie.png",
      title: "Şans Kurabiyesi",
      color: MyColor.white.withOpacity(0.1),
      onTap: () {
        // Şans kurabiyesi sayfasına git
      },
    ),
    FortuneCard(
      image: "https://apptoic.com/spiroot/images/globe.png",
      title: "Sihirli Küre",
      color: MyColor.primaryLightColor,
      onTap: () {
        // Sihirli küre sayfasına git
      },
    ),
    FortuneCard(
      image: "https://apptoic.com/spiroot/images/lamp.png",
      title: "Sihirli Lamba",
      color: MyColor.white.withOpacity(0.1),
      onTap: () {
        // Sihirli lamba sayfasına git
      },
    ),
  ];

  return Column(
    children: [
      sectionTitle(
        text: "🍀 ${easy.tr("navigation.luck")}",
      ),
      verticalGap(MySize.defaultPadding),
      GridView.count(
        padding: EdgeInsets.all(0),
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        crossAxisCount: 3,
        mainAxisSpacing: MySize.sixQuartersPadding,
        crossAxisSpacing: MySize.halfPadding,
        childAspectRatio: 1,
        children: fortuneCards.map((card) => buildFortuneCard(card)).toList(),
      ),
    ],
  );
}
