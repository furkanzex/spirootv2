import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:spirootv2/core/constant/my_color.dart';
import 'package:spirootv2/core/constant/my_size.dart';
import 'package:spirootv2/core/constant/my_style.dart';
import 'package:spirootv2/core/widget/gap/vertical_gap.dart';
import 'package:spirootv2/paywall/paywall_screen.dart';

class PremiumPopup extends StatelessWidget {
  final VoidCallback onSingleUse;

  const PremiumPopup({
    super.key,
    required this.onSingleUse,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(MySize.defaultPadding),
        decoration: BoxDecoration(
          color: MyColor.darkBackgroundColor,
          borderRadius: BorderRadius.circular(MySize.defaultRadius),
          border: Border.all(
            color: MyColor.primaryColor.withOpacity(0.3),
            width: 2,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Premium İkonu
            Container(
              padding: const EdgeInsets.all(MySize.defaultPadding),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: MyColor.primaryColor.withOpacity(0.1),
              ),
              child: Icon(
                Icons.star,
                color: MyColor.primaryColor,
                size: MySize.iconSizeMedium,
              ),
            ),
            verticalGap(MySize.defaultPadding),

            // Başlık
            Text(
              "Premium İçerik",
              style: MyStyle.s1.copyWith(
                color: MyColor.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            verticalGap(MySize.halfPadding),

            // Açıklama
            Text(
              "Bu özelliği kullanmak için Premium'a yükseltebilir veya tek seferlik erişim sağlayabilirsiniz.",
              textAlign: TextAlign.center,
              style: MyStyle.s2.copyWith(
                color: MyColor.textGreyColor,
                height: 1.5,
              ),
            ),
            verticalGap(MySize.doublePadding),

            // Sınırsız Erişim Butonu
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Get.back();
                  paywall();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: MyColor.primaryColor,
                  padding: const EdgeInsets.symmetric(
                      vertical: MySize.defaultPadding),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(MySize.defaultRadius),
                  ),
                ),
                child: Text(
                  "SINIRSIZ ERİŞİM",
                  style: MyStyle.s2.copyWith(
                    color: MyColor.white,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),
            verticalGap(MySize.defaultPadding),

            // Tek Seferlik Erişim Butonu
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () {
                  Get.back();
                  onSingleUse();
                },
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                      vertical: MySize.defaultPadding),
                ),
                child: Text(
                  "TEK SEFERLİK AÇ",
                  style: MyStyle.s2.copyWith(
                    color: MyColor.primaryLightColor,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
