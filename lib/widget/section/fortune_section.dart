import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:spirootv2/core/constant/my_color.dart';
import 'package:spirootv2/core/constant/my_icon.dart';
import 'package:spirootv2/core/constant/my_size.dart';
import 'package:spirootv2/core/constant/my_style.dart';
import 'package:spirootv2/model/fortune/fortune_card_model.dart';
import 'package:spirootv2/widget/card/fortune_card.dart';
import 'package:spirootv2/widget/gap/horizontal_gap.dart';
import 'package:spirootv2/widget/gap/vertical_gap.dart';
import 'package:spirootv2/widget/text_field/section_title.dart';
import 'package:easy_localization/easy_localization.dart' as easy;
import 'package:extended_image/extended_image.dart';

Widget fortuneSection() {
  final List<FortuneCard> fortuneCards = [
    FortuneCard(
      image: "https://apptoic.com/spiroot/images/coffee.png",
      title: "Kahve Falı",
      color: MyColor.white.withOpacity(0.1),
      onTap: () {
        // Kahve falı sayfasına git
      },
    ),
    FortuneCard(
      image: "https://apptoic.com/spiroot/images/tarot.png",
      title: "Tarot Falı",
      color: MyColor.primaryLightColor,
      onTap: () {
        // Tarot falı sayfasına git
      },
    ),
    FortuneCard(
      image: "https://apptoic.com/spiroot/images/palm.png",
      title: "El Falı",
      color: MyColor.white.withOpacity(0.1),
      onTap: () {
        // El falı sayfasına git
      },
    ),
    FortuneCard(
      image: "https://apptoic.com/spiroot/images/katina.png",
      title: "Katina Falı",
      color: MyColor.primaryLightColor,
      onTap: () {
        // Katina falı sayfasına git
      },
    ),
    FortuneCard(
      image: "https://apptoic.com/spiroot/images/face.png",
      title: "Yüz Falı",
      color: MyColor.white.withOpacity(0.1),
      onTap: () {
        // Yüz falı sayfasına git
      },
    ),
    FortuneCard(
      image: "https://apptoic.com/spiroot/images/angel.png",
      title: "Melek Falı",
      color: MyColor.primaryLightColor,
      onTap: () {
        // Melek falı sayfasına git
      },
    ),
  ];

  return Column(
    children: [
      sectionTitle(
        text: "🔮 ${easy.tr("navigation.fortune")}",
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
      verticalGap(MySize.sixQuartersPadding),
      GestureDetector(
        onTap: () {
          // Tüm fallar sayfasına git
        },
        child: ClipRRect(
          borderRadius: BorderRadius.circular(MySize.halfRadius),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(MySize.defaultPadding),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(MySize.halfRadius),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      SizedBox(
                        height: MySize.gridSize,
                        width: MySize.gridSize,
                        child: ExtendedImage.network(
                          "https://apptoic.com/spiroot/images/fortune_list.png",
                          cache: true,
                          loadStateChanged: (ExtendedImageState state) {
                            switch (state.extendedImageLoadState) {
                              case LoadState.loading:
                                return SizedBox(
                                  width: MySize.iconSizeSmall,
                                  height: MySize.iconSizeSmall,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: MyColor.primaryLightColor,
                                  ),
                                );
                              case LoadState.completed:
                                return state.completedWidget;
                              case LoadState.failed:
                                return Center(child: Icon(Icons.error));
                              default:
                                return Container();
                            }
                          },
                        ),
                      ),
                      horizontalGap(MySize.defaultPadding),
                      Text(
                        "Tüm Fallarım",
                        style: MyStyle.s1.copyWith(
                            fontWeight: FontWeight.bold, color: MyColor.white),
                      ),
                      const Spacer(),
                      Icon(
                        MyIcon.forward,
                        color: MyColor.white,
                        size: MySize.iconSizeSmall,
                      )
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ],
  );
}
