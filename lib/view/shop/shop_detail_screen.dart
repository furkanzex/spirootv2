import 'package:carousel_slider/carousel_slider.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:spirootv2/core/constant/my_color.dart';
import 'package:spirootv2/core/constant/my_size.dart';
import 'package:spirootv2/core/constant/my_style.dart';
import 'package:spirootv2/model/shop/shop_model.dart';
import 'package:spirootv2/widget/gap/vertical_gap.dart';

class ShopDetailScreen extends StatelessWidget {
  final Shop shop;

  const ShopDetailScreen({super.key, required this.shop});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColor.darkBackgroundColor,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Görsel galerisi
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: MyColor.darkBackgroundColor,
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                child:
                    const Icon(Icons.arrow_back_ios_new, color: MyColor.white),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                children: [
                  CarouselSlider(
                    options: CarouselOptions(
                      height: 400,
                      viewportFraction: 1,
                      enableInfiniteScroll: false,
                    ),
                    items: shop.images
                        .map((image) => ExtendedImage.network(
                              image,
                              fit: BoxFit.cover,
                              cache: true,
                            ))
                        .toList(),
                  ),
                  // Gradient overlay
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    height: 100,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            MyColor.darkBackgroundColor,
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Dükkan bilgileri
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(MySize.defaultPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Dükkan adı ve puanı
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          shop.name,
                          style: MyStyle.s2.copyWith(
                            color: MyColor.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: MySize.defaultPadding,
                          vertical: MySize.halfPadding,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.amber.withOpacity(0.2),
                          borderRadius:
                              BorderRadius.circular(MySize.quarterRadius),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.star,
                              color: Colors.amber,
                              size: MySize.iconSizeSmall,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              "${shop.rating}",
                              style: MyStyle.s2.copyWith(
                                color: Colors.amber,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  verticalGap(MySize.defaultPadding),
                  // Konum bilgisi
                  _buildInfoRow(Icons.location_on, shop.address),
                  verticalGap(MySize.defaultPadding),
                  // Çalışma saatleri
                  _buildInfoRow(Icons.access_time, shop.workingHours),
                  verticalGap(MySize.defaultPadding),
                  // İletişim bilgileri
                  _buildInfoRow(Icons.phone, shop.phone),
                  verticalGap(MySize.halfPadding),
                  _buildInfoRow(Icons.email, shop.email),
                  verticalGap(MySize.doublePadding),
                  // Yorumlar başlığı
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Yorumlar",
                        style: MyStyle.s1.copyWith(
                          color: MyColor.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "(${shop.reviewCount})",
                        style: MyStyle.s2.copyWith(
                          color: MyColor.textGreyColor,
                        ),
                      ),
                    ],
                  ),
                  verticalGap(MySize.defaultPadding),
                  // Yorumlar listesi
                  ...shop.reviews.map((review) => _buildReviewCard(review)),
                  verticalGap(MySize.doublePadding),
                  // Yorum yapma kutusu
                  Container(
                    padding: const EdgeInsets.all(MySize.defaultPadding),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(MySize.halfRadius),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Yorum Yap",
                          style: MyStyle.s2.copyWith(
                            color: MyColor.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        verticalGap(MySize.defaultPadding),
                        TextField(
                          style: MyStyle.s2.copyWith(color: MyColor.white),
                          maxLines: 3,
                          decoration: InputDecoration(
                            hintText: "Deneyimini paylaş...",
                            hintStyle: MyStyle.s2.copyWith(
                              color: MyColor.textGreyColor,
                            ),
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.1),
                            border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.circular(MySize.quarterRadius),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                        verticalGap(MySize.defaultPadding),
                        Row(
                          children: [
                            // Yıldız seçimi
                            ...List.generate(
                                5,
                                (index) => Padding(
                                      padding: const EdgeInsets.only(right: 4),
                                      child: Icon(
                                        Icons.star,
                                        color: index < 3
                                            ? Colors.amber
                                            : Colors.white.withOpacity(0.3),
                                        size: MySize.iconSizeSmall,
                                      ),
                                    )),
                            const Spacer(),
                            // Gönder butonu
                            ElevatedButton(
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(
                                backgroundColor: MyColor.primaryColor,
                                minimumSize: const Size(44, 44),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                      MySize.quarterRadius),
                                ),
                              ),
                              child: Text(
                                "Gönder",
                                style: MyStyle.s2.copyWith(
                                  color: MyColor.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          color: MyColor.primaryLightColor,
          size: MySize.iconSizeSmall,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: MyStyle.s2.copyWith(
              color: MyColor.white,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReviewCard(Review review) {
    return Container(
      margin: const EdgeInsets.only(bottom: MySize.defaultPadding),
      padding: const EdgeInsets.all(MySize.defaultPadding),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(MySize.halfRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                review.userName,
                style: MyStyle.s2.copyWith(
                  color: MyColor.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                children: [
                  Icon(
                    Icons.star,
                    color: Colors.amber,
                    size: MySize.iconSizeSmall,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    review.rating.toString(),
                    style: MyStyle.s3.copyWith(
                      color: MyColor.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
          verticalGap(MySize.halfPadding),
          Text(
            review.comment,
            style: MyStyle.s3.copyWith(
              color: MyColor.white.withOpacity(0.8),
              height: 1.4,
            ),
          ),
          verticalGap(MySize.halfPadding),
          Text(
            _formatDate(review.date),
            style: MyStyle.s3.copyWith(
              color: MyColor.textGreyColor,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final difference = DateTime.now().difference(date);
    if (difference.inDays == 0) {
      return "Bugün";
    } else if (difference.inDays == 1) {
      return "Dün";
    } else if (difference.inDays < 7) {
      return "${difference.inDays} gün önce";
    } else {
      return "${date.day}.${date.month}.${date.year}";
    }
  }
}
