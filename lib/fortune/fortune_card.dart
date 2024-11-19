import 'dart:ui';

import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:spirootv2/core/constant/my_color.dart';
import 'package:spirootv2/core/constant/my_size.dart';
import 'package:spirootv2/core/constant/my_style.dart';
import 'package:spirootv2/fortune/fortune_card_model.dart';

Widget buildFortuneCard(FortuneCard card) {
  return GestureDetector(
    onTap: card.onTap,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(MySize.halfRadius),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                padding: EdgeInsets.all(MySize.defaultPadding),
                decoration: BoxDecoration(
                  color: card.color?.withOpacity(0.1) ??
                      Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(MySize.halfRadius),
                ),
                child: Center(
                  child: ExtendedImage.network(
                    card.image,
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
              ),
            ),
          ),
        ),
        SizedBox(height: 4),
        Text(
          card.title,
          style: MyStyle.s3
              .copyWith(fontWeight: FontWeight.bold, color: MyColor.white),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    ),
  );
}
