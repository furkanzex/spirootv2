import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:spirootv2/home/home_controller.dart';
import 'package:spirootv2/core/constant/my_color.dart';
import 'package:spirootv2/core/constant/my_icon.dart';
import 'package:spirootv2/core/constant/my_size.dart';
import 'package:spirootv2/core/constant/my_style.dart';
import 'package:spirootv2/shop/shop_model.dart';
import 'package:spirootv2/core/widget/gap/vertical_gap.dart';
import 'package:spirootv2/core/widget/text_field/section_title.dart';
import 'package:easy_localization/easy_localization.dart' as easy;
import 'package:extended_image/extended_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:get/get.dart';
import 'package:spirootv2/shop/shop_detail_screen.dart';

Widget topShopsSection() {
  final List<Shop> shops = [
    Shop(
      id: "1",
      name: "Mistik Kahve & Tarot",
      city: "İstanbul, Kadıköy",
      address: "Caferağa Mah. Moda Cad. No:123/A, Kadıköy/İstanbul",
      images: [
        "https://apptoic.com/spiroot/images/dukkan1.jpg",
      ],
      rating: 4.8,
      reviewCount: 127,
      workingHours: "Her gün 10:00 - 22:00",
      phone: "+90 (216) 123 45 67",
      email: "info@mistikkahve.com",
      reviews: [
        Review(
          userId: "user1",
          userName: "Ayşe Y.",
          comment:
              "Kahve falı için gittiğim en iyi mekan! Falcı hanım çok içten ve samimiydi.",
          rating: 5.0,
          date: DateTime.now().subtract(const Duration(days: 2)),
        ),
      ],
    ),
    Shop(
      id: "2",
      name: "Ruhsal Denge Merkezi",
      city: "İzmir, Alsancak",
      address: "Alsancak Mah. Kıbrıs Şehitleri Cad. No:456, Konak/İzmir",
      images: [
        "https://apptoic.com/spiroot/images/dukkan2.jpg",
      ],
      rating: 4.9,
      reviewCount: 89,
      workingHours: "Pazartesi-Cumartesi 11:00 - 20:00",
      phone: "+90 (232) 987 65 43",
      email: "iletisim@ruhsaldenge.com",
      reviews: [
        Review(
          userId: "user3",
          userName: "Zeynep A.",
          comment:
              "Meditasyon seansları muhteşem! Hoca çok bilgili ve yardımsever.",
          rating: 5.0,
          date: DateTime.now().subtract(const Duration(days: 1)),
        ),
      ],
    ),
    Shop(
      id: "3",
      name: "Astroloji & Tarot Evi",
      city: "Ankara, Çankaya",
      address: "Çankaya Mah. Tunalı Hilmi Cad. No:789, Çankaya/Ankara",
      images: [
        "https://apptoic.com/spiroot/images/dukkan3.jpg",
      ],
      rating: 4.7,
      reviewCount: 156,
      workingHours: "Her gün 09:00 - 21:00",
      phone: "+90 (312) 456 78 90",
      email: "bilgi@astrolojitarot.com",
      reviews: [
        Review(
          userId: "user4",
          userName: "Mert B.",
          comment:
              "Astroloji danışmanlığı için geldim, çok profesyonel bir hizmet aldım.",
          rating: 4.7,
          date: DateTime.now().subtract(const Duration(days: 3)),
        ),
      ],
    ),
    Shop(
      id: "4",
      name: "Spiritüel Gelişim Akademisi",
      city: "Bursa, Nilüfer",
      address: "Nilüfer Mah. FSM Bulvarı No:321, Nilüfer/Bursa",
      images: [
        "https://apptoic.com/spiroot/images/dukkan1.jpg",
      ],
      rating: 4.6,
      reviewCount: 73,
      workingHours: "Pazartesi-Cumartesi 10:00 - 19:00",
      phone: "+90 (224) 321 54 76",
      email: "info@spirituelgelisim.com",
      reviews: [
        Review(
          userId: "user5",
          userName: "Selin K.",
          comment: "Reiki eğitimi için geldim, eğitmenler çok donanımlı.",
          rating: 4.6,
          date: DateTime.now().subtract(const Duration(days: 4)),
        ),
      ],
    ),
    Shop(
      id: "5",
      name: "Kristal & Taş Dünyası",
      city: "Antalya, Muratpaşa",
      address: "Muratpaşa Mah. Işıklar Cad. No:147, Muratpaşa/Antalya",
      images: [
        "https://apptoic.com/spiroot/images/dukkan3.jpg",
      ],
      rating: 4.5,
      reviewCount: 94,
      workingHours: "Her gün 10:00 - 20:00",
      phone: "+90 (242) 765 43 21",
      email: "iletisim@kristaldunyasi.com",
      reviews: [
        Review(
          userId: "user6",
          userName: "Deniz Y.",
          comment: "Doğal taşlar ve kristaller konusunda çok bilgililer.",
          rating: 4.5,
          date: DateTime.now().subtract(const Duration(days: 5)),
        ),
      ],
    ),
  ];

  final List<Shop> topShops = [...shops]
    ..sort((a, b) => b.rating.compareTo(a.rating))
    ..take(5).toList();

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: MySize.defaultPadding),
        child: sectionTitle(
          text: "⭐️ ${easy.tr("navigation.top_rated_shops")}",
          trailingLabel: easy.tr("home.see_all"),
          icon: MyIcon.forward,
          color: MyColor.primaryLightColor,
          onTap: () {
            final controller = Get.find<HomeController>();
            controller.changePage(3);
          },
        ),
      ),
      verticalGap(MySize.defaultPadding),
      CarouselSlider(
        options: CarouselOptions(
          height: 200,
          viewportFraction: 0.8,
          enableInfiniteScroll: true,
          autoPlay: true,
          autoPlayInterval: const Duration(seconds: 5),
          enlargeCenterPage: true,
        ),
        items: topShops
            .map((shop) => GestureDetector(
                  onTap: () => Get.to(() => ShopDetailScreen(shop: shop)),
                  child: Container(
                    width: double.infinity,
                    margin: const EdgeInsets.symmetric(horizontal: 5.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(MySize.halfRadius),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(MySize.halfRadius),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          // Dükkan görseli
                          ExtendedImage.network(
                            shop.images.first,
                            fit: BoxFit.cover,
                            cache: true,
                          ),
                          // Gradient overlay
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withOpacity(0.7),
                                ],
                              ),
                            ),
                          ),
                          // Dükkan bilgileri
                          Positioned(
                            left: MySize.defaultPadding,
                            right: MySize.defaultPadding,
                            bottom: MySize.defaultPadding,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  shop.name,
                                  style: MyStyle.s1.copyWith(
                                    color: MyColor.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.star,
                                      color: Colors.amber,
                                      size: MySize.iconSizeSmall,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      "${shop.rating}",
                                      style: MyStyle.s2.copyWith(
                                        color: MyColor.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      " (${shop.reviewCount})",
                                      style: MyStyle.s3.copyWith(
                                        color: MyColor.white.withOpacity(0.8),
                                      ),
                                    ),
                                    const Spacer(),
                                    Text(
                                      shop.city,
                                      style: MyStyle.s3.copyWith(
                                        color: MyColor.white.withOpacity(0.8),
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
                ))
            .toList(),
      ),
    ],
  );
}
