import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:spirootv2/core/constant/my_color.dart';
import 'package:spirootv2/core/constant/my_size.dart';
import 'package:spirootv2/core/constant/my_style.dart';
import 'package:spirootv2/core/widget/gap/vertical_gap.dart';
import 'package:lottie/lottie.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:spirootv2/astrology/astrology_controller.dart';
import 'package:spirootv2/profile/user_controller.dart';

class PaywallScreen extends StatelessWidget {
  const PaywallScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColor.darkBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(MySize.defaultPadding),
          child: Column(
            children: [
              // Üst kısım - Animasyon ve Başlık
              SizedBox(
                height: 200,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Lottie.asset(
                      'assets/lottie/stars.json',
                      fit: BoxFit.cover,
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "✨ Premium'a Yükselt",
                          style: MyStyle.s1.copyWith(
                            color: MyColor.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        verticalGap(MySize.halfPadding),
                        Text(
                          "Tüm özelliklere sınırsız erişim",
                          style: MyStyle.s2.copyWith(
                            color: MyColor.textGreyColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              verticalGap(MySize.doublePadding),

              // Özellikler Listesi
              ..._buildFeatureList(),
              verticalGap(MySize.doublePadding),

              // Fiyatlandırma Kartları
              _buildPricingCards(),
              verticalGap(MySize.doublePadding),

              // Güvenli Ödeme Bilgisi
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    MingCute.lock_line,
                    color: MyColor.textGreyColor,
                    size: MySize.iconSizeSmall,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "Güvenli ödeme - İstediğiniz zaman iptal edin",
                    style: MyStyle.s3.copyWith(
                      color: MyColor.textGreyColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildFeatureList() {
    final features = [
      {
        'icon': MingCute.chart_line_line,
        'title': 'Detaylı Astroloji Analizleri',
        'description': 'Günlük, haftalık ve aylık özel yorumlar',
      },
      {
        'icon': MingCute.planet_line,
        'title': 'Transit ve Retro Takibi',
        'description': 'Gezegen hareketlerinin size etkisi',
      },
      {
        'icon': MingCute.heart_line,
        'title': 'Sınırsız Uyumluluk Analizi',
        'description': 'Aşk ve arkadaşlık uyumu hesaplama',
      },
      {
        'icon': MingCute.magic_1_line,
        'title': 'Numeroloji Yorumları',
        'description': 'Kişisel sayılarınızın anlamları',
      },
    ];

    return features.map((feature) {
      return Padding(
        padding: const EdgeInsets.only(bottom: MySize.defaultPadding),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(MySize.halfPadding),
              decoration: BoxDecoration(
                color: MyColor.primaryLightColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(MySize.quarterRadius),
              ),
              child: Icon(
                feature['icon'] as IconData,
                color: MyColor.primaryLightColor,
              ),
            ),
            const SizedBox(width: MySize.defaultPadding),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    feature['title']!.toString(),
                    style: MyStyle.s2.copyWith(
                      color: MyColor.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    feature['description']!.toString(),
                    style: MyStyle.s3.copyWith(
                      color: MyColor.textGreyColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  Widget _buildPricingCards() {
    return Row(
      children: [
        // Aylık Plan
        Expanded(
          child: _buildPricingCard(
            title: 'Aylık',
            price: '49.99',
            isPopular: false,
            onTap: () => _handlePurchase('monthly'),
          ),
        ),
        const SizedBox(width: MySize.defaultPadding),
        // Yıllık Plan
        Expanded(
          child: _buildPricingCard(
            title: 'Yıllık',
            price: '399.99',
            savings: '200 TL tasarruf',
            isPopular: true,
            onTap: () => _handlePurchase('yearly'),
          ),
        ),
      ],
    );
  }

  Widget _buildPricingCard({
    required String title,
    required String price,
    String? savings,
    required bool isPopular,
    required VoidCallback onTap,
  }) {
    return Container(
      padding: const EdgeInsets.all(MySize.defaultPadding),
      decoration: BoxDecoration(
        color: isPopular
            ? MyColor.primaryColor.withOpacity(0.2)
            : MyColor.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(MySize.halfRadius),
        border: Border.all(
          color: isPopular ? MyColor.primaryLightColor : Colors.transparent,
          width: 2,
        ),
      ),
      child: Column(
        children: [
          if (isPopular)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: MySize.halfPadding,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: MyColor.primaryLightColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'En Popüler',
                style: MyStyle.s3.copyWith(
                  color: MyColor.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          verticalGap(MySize.halfPadding),
          Text(
            title,
            style: MyStyle.s2.copyWith(
              color: MyColor.white,
              fontWeight: FontWeight.w500,
            ),
          ),
          verticalGap(MySize.quarterPadding),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '₺',
                style: MyStyle.s2.copyWith(
                  color: MyColor.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                price,
                style: MyStyle.s1.copyWith(
                  color: MyColor.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          if (savings != null) ...[
            verticalGap(MySize.quarterPadding),
            Text(
              savings,
              style: MyStyle.s3.copyWith(
                color: MyColor.primaryLightColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
          verticalGap(MySize.defaultPadding),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: isPopular
                    ? MyColor.primaryLightColor
                    : MyColor.white.withOpacity(0.1),
                padding:
                    const EdgeInsets.symmetric(vertical: MySize.defaultPadding),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(MySize.quarterRadius),
                ),
              ),
              child: Text(
                'Seç',
                style: MyStyle.s2.copyWith(
                  color: MyColor.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handlePurchase(String plan) async {
    try {
      // Satın alma işlemleri burada yapılacak

      // Başarılı satın alma sonrası
      final userRef = FirebaseFirestore.instance
          .collection('users')
          .doc(Get.find<UserController>().userId.value);

      await userRef.update({
        'isSubscribed': true,
        'subscriptionPlan': plan,
        'subscriptionStartDate': DateTime.now().toIso8601String(),
      });

      // AstrologyController'ı güncelle
      final astrologyController = Get.find<AstrologyController>();
      astrologyController.isSubscribed.value = true;
      await astrologyController.loadPremiumContent();

      Get.back(); // Paywall'ı kapat
    } catch (e) {
      print('Purchase error: $e');
      Get.snackbar(
        'Hata',
        'Satın alma işlemi sırasında bir hata oluştu',
        backgroundColor: MyColor.errorColor,
        colorText: MyColor.white,
      );
    }
  }
}
