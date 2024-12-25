import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:spirootv2/core/constant/my_color.dart';
import 'package:spirootv2/core/constant/my_size.dart';
import 'package:spirootv2/core/constant/my_style.dart';
import 'package:spirootv2/core/widget/gap/vertical_gap.dart';
import 'package:spirootv2/paywall/paywall_screen.dart';
import 'package:spirootv2/core/service/revenuecat_services.dart';
import 'package:easy_localization/easy_localization.dart' as easy;

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
            Text(
              easy.tr("premium.title"),
              style: MyStyle.s1.copyWith(
                color: MyColor.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            verticalGap(MySize.halfPadding),
            Text(
              easy.tr("premium.description"),
              textAlign: TextAlign.center,
              style: MyStyle.s2.copyWith(
                color: MyColor.textGreyColor,
                height: 1.5,
              ),
            ),
            verticalGap(MySize.doublePadding),
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
                  easy.tr("premium.unlimited"),
                  style: MyStyle.s2.copyWith(
                    color: MyColor.white,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),
            verticalGap(MySize.defaultPadding),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () async {
                  final success = await PurchaseAPI().handleSinglePurchase();
                  if (success) {
                    Get.back();
                    onSingleUse();
                  }
                },
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                      vertical: MySize.defaultPadding),
                ),
                child: Text(
                  easy.tr("premium.single_use"),
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
