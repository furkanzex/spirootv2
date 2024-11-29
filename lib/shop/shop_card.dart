import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:spirootv2/core/constant/my_color.dart';
import 'package:spirootv2/core/constant/my_size.dart';
import 'package:spirootv2/core/constant/my_style.dart';
import 'package:spirootv2/shop/shop_model.dart';
import 'package:spirootv2/shop/shop_detail_screen.dart';
import 'package:spirootv2/core/widget/gap/vertical_gap.dart';
import 'package:easy_localization/easy_localization.dart' as easy;

Widget buildShopCard(Shop shop) {
  return GestureDetector(
    onTap: () => Get.to(() => ShopDetailScreen(shop: shop)),
    child: Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(MySize.halfRadius),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(MySize.halfRadius),
        child: Container(
          padding: const EdgeInsets.all(MySize.defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Dükkan görseli
              ClipRRect(
                borderRadius: BorderRadius.circular(MySize.quarterRadius),
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: ExtendedImage.network(
                    shop.images.first,
                    fit: BoxFit.cover,
                    cache: true,
                  ),
                ),
              ),
              verticalGap(MySize.defaultPadding),
              // Dükkan bilgileri
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          shop.name,
                          style: MyStyle.s1.copyWith(
                            color: MyColor.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          shop.city,
                          style: MyStyle.s3.copyWith(
                            color: MyColor.textGreyColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.star,
                            color: Colors.amber,
                            size: MySize.iconSizeSmall,
                          ),
                          Text(
                            shop.rating.toString(),
                            style: MyStyle.s2.copyWith(
                              color: MyColor.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        "${shop.reviewCount} ${easy.tr("shops.reviews")}",
                        style: MyStyle.s3.copyWith(
                          color: MyColor.textGreyColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
