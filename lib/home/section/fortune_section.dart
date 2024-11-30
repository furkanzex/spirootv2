import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:spirootv2/core/constant/my_color.dart';
import 'package:spirootv2/core/constant/my_icon.dart';
import 'package:spirootv2/core/constant/my_size.dart';
import 'package:spirootv2/core/constant/my_style.dart';
import 'package:spirootv2/fortune/dream_interpretation_screen.dart';
import 'package:spirootv2/fortune/fortune_card_model.dart';
import 'package:spirootv2/fortune/fortune_card.dart';
import 'package:spirootv2/core/widget/gap/horizontal_gap.dart';
import 'package:spirootv2/core/widget/gap/vertical_gap.dart';
import 'package:spirootv2/core/widget/text_field/section_title.dart';
import 'package:easy_localization/easy_localization.dart' as easy;
import 'package:extended_image/extended_image.dart';
import 'package:get/get.dart';
import 'package:spirootv2/home/home_controller.dart';

Widget fortuneSection(
    {bool isMainPageWidget = false, required BuildContext context}) {
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
        text:
            "🔮 ${isMainPageWidget ? easy.tr("navigation.fortune") : easy.tr("fortune.fortune_history")}",
        trailingLabel:
            isMainPageWidget ? easy.tr("fortune.fortune_history_button") : null,
        onTap: isMainPageWidget
            ? () {
                final controller = Get.find<HomeController>();
                controller.changePage(1);
              }
            : null,
        icon: isMainPageWidget ? MyIcon.forward : null,
        color: isMainPageWidget ? MyColor.primaryPurpleColor : null,
      ),
      if (!isMainPageWidget) verticalGap(MySize.defaultPadding),
      if (!isMainPageWidget)
        Container(
          padding: const EdgeInsets.all(MySize.defaultPadding),
          decoration: BoxDecoration(
            color: MyColor.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(MySize.halfRadius),
            border: Border.all(
              color: MyColor.primaryLightColor.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "${easy.tr("fortune.no_fortune_history")} 🫢",
                style: MyStyle.s1.copyWith(
                  color: MyColor.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: MySize.halfPadding),
              Text(
                easy.tr("fortune.no_fortune_history_desc"),
                style: MyStyle.s2.copyWith(
                  color: MyColor.textGreyColor,
                ),
              ),
            ],
          ),
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
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const DreamInterpretationScreen(),
            ),
          );
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
              child: Row(
                children: [
                  SizedBox(
                    height: MySize.gridSize,
                    width: MySize.gridSize,
                    child: ExtendedImage.network(
                      "https://apptoic.com/spiroot/images/dream.png",
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
                  Expanded(
                    child: Text(
                      "Rüyanı Yorumla",
                      style: MyStyle.s1.copyWith(
                        fontWeight: FontWeight.bold,
                        color: MyColor.white,
                      ),
                    ),
                  ),
                  Icon(
                    MyIcon.forward,
                    color: MyColor.white,
                    size: MySize.iconSizeSmall,
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
