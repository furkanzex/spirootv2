import 'package:flutter/material.dart';
import 'package:spirootv2/core/constant/my_color.dart';
import 'package:spirootv2/core/constant/my_size.dart';
import 'package:spirootv2/shop/shop_card.dart';
import 'package:spirootv2/core/widget/gap/vertical_gap.dart';
import 'package:spirootv2/core/widget/text_field/section_title.dart';
import 'package:spirootv2/shop/shop_model.dart';
import 'package:easy_localization/easy_localization.dart' as easy;

class ShopsScreen extends StatelessWidget {
  const ShopsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Shop> shops = [
      Shop(
        id: "1",
        name: "Mistik Kahve & Tarot",
        city: "İstanbul, Kadıköy",
        address: "Caferağa Mah. Moda Cad. No:123/A, Kadıköy/İstanbul",
        images: [
          "https://apptoic.com/spiroot/images/dukkan1.jpg",
          "https://apptoic.com/spiroot/images/dukkan2.jpg",
          "https://apptoic.com/spiroot/images/dukkan3.jpg",
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
                "Kahve falı için gittiğim en iyi mekan! Falcı hanım çok içten ve samimiydi. Mekanın mistik atmosferi de ayrı güzel.",
            rating: 5.0,
            date: DateTime.now().subtract(const Duration(days: 2)),
          ),
          Review(
            userId: "user2",
            userName: "Mehmet K.",
            comment:
                "Tarot seansı için gittim, çok profesyonel bir deneyimdi. Mekanın dekorasyonu ve ambiyansı da tam istediğim gibiydi.",
            rating: 4.5,
            date: DateTime.now().subtract(const Duration(days: 5)),
          ),
        ],
      ),
      Shop(
        id: "2",
        name: "Ruhsal Denge Merkezi",
        city: "İzmir, Alsancak",
        address: "Alsancak Mah. Kıbrıs Şehitleri Cad. No:456, Konak/İzmir",
        images: [
          "https://apptoic.com/spiroot/images/dukkan1.jpg",
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
                "Meditasyon seansları muhteşem! Hoca çok bilgili ve yardımsever. Mekanın enerjisi insanı hemen sakinleştiriyor.",
            rating: 5.0,
            date: DateTime.now().subtract(const Duration(days: 1)),
          ),
          Review(
            userId: "user4",
            userName: "Can B.",
            comment:
                "Reiki seansı için gittim, çok memnun kaldım. Mekan çok temiz ve huzurlu. Kesinlikle tavsiye ederim.",
            rating: 4.8,
            date: DateTime.now().subtract(const Duration(days: 3)),
          ),
        ],
      ),
    ];
    return Scaffold(
      backgroundColor: MyColor.transparent,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(MySize.defaultPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    sectionTitle(
                      text: "🏪 ${easy.tr("navigation.shops")}",
                    ),
                    verticalGap(MySize.defaultPadding),
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: shops.length,
                      separatorBuilder: (context, index) =>
                          verticalGap(MySize.defaultPadding),
                      itemBuilder: (context, index) =>
                          buildShopCard(shops[index]),
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
}
