import 'package:flutter/material.dart';
import 'package:spirootv2/core/constant/my_color.dart';
import 'package:spirootv2/core/constant/my_icon.dart';
import 'package:spirootv2/core/constant/my_size.dart';
import 'package:spirootv2/core/constant/my_style.dart';
import 'package:spirootv2/core/widget/gap/horizontal_gap.dart';
import 'package:spirootv2/core/widget/gap/vertical_gap.dart';
import 'package:spirootv2/core/widget/text_field/section_title.dart';
import 'package:easy_localization/easy_localization.dart' as easy;
import 'package:extended_image/extended_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:spirootv2/enlightenment/ritual_screen.dart';
import 'package:spirootv2/blog/screens/blog_list_screen.dart';

Widget enlightenmentSection() {
  final List<Map<String, String>> items = [
    {
      "title": easy.tr("navigation.blog"),
      "image": "https://apptoic.com/spiroot/images/blog.png"
    },
    {
      "title": easy.tr("navigation.ritual"),
      "image": "https://apptoic.com/spiroot/images/ritual.png"
    },
  ];

  return Column(
    children: [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: MySize.defaultPadding),
        child: sectionTitle(
          text: "🌟 ${easy.tr("navigation.enlightenment")}",
        ),
      ),
      verticalGap(MySize.defaultPadding),
      CarouselSlider.builder(
        itemCount: items.length,
        options: CarouselOptions(
          autoPlay: true,
          enlargeCenterPage: true,
          enableInfiniteScroll: true,
          viewportFraction: 0.75,
        ),
        itemBuilder: (context, index, realIdx) {
          return GestureDetector(
            onTap: () {
              if (items[index]["title"] == easy.tr("navigation.ritual")) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const RitualScreen(),
                  ),
                );
              } else if (items[index]["title"] == easy.tr("navigation.blog")) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BlogListScreen(),
                  ),
                );
              }
              // El Kitapları için yönlendirme eklenecek
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(MySize.halfRadius),
              child: Stack(
                fit: StackFit.expand,
                alignment: AlignmentDirectional.center,
                children: [
                  ExtendedImage.network(
                    items[index]["image"]!,
                    cache: true,
                    fit: BoxFit.cover,
                    color: Colors.black.withOpacity(0.7),
                    colorBlendMode: BlendMode.darken,
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
                      }
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.all(MySize.defaultPadding),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Icon(
                          MyIcon.back,
                          color: MyColor.textGreyColor,
                          size: MySize.iconSizeSmall,
                        ),
                        horizontalGap(MySize.defaultPadding),
                        Expanded(
                          child: Text(
                            items[index]["title"]!,
                            style: MyStyle.s1.copyWith(
                                fontWeight: FontWeight.bold,
                                color: MyColor.white),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        horizontalGap(MySize.defaultPadding),
                        Icon(
                          MyIcon.forward,
                          color: MyColor.textGreyColor,
                          size: MySize.iconSizeSmall,
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    ],
  );
}
