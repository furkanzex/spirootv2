import 'dart:async';
import 'dart:developer';
import 'dart:io' show Platform;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';
import 'package:spirootv2/core/env/env.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';

class PurchaseAPI {
  final String apiKeyGoogle = Env.apiKeyGoogle;
  final String apiKeyApple = Env.apiKeyApple;

  Future<void> init() async {
    await Purchases.setLogLevel(LogLevel.debug);

    PurchasesConfiguration? configuration;
    if (Platform.isAndroid) {
      configuration = PurchasesConfiguration(apiKeyGoogle);
    } else if (Platform.isIOS) {
      configuration = PurchasesConfiguration(apiKeyApple);
    }
    if (configuration != null) {
      await Purchases.configure(configuration);

      // Firebase kullanıcısını RevenueCat ile senkronize et
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await Purchases.logIn(user.uid);
        log("RevenueCat user logged in with ID: ${user.uid}");
      }

      // Abonelik değişikliklerini dinle
      setupSubscriptionListener();
    }
  }

  static Future<List<Offering>> fetchOffers({bool all = true}) async {
    try {
      final offerings = await Purchases.getOfferings();

      if (!all) {
        final current = offerings.current;
        return current == null ? [] : [current];
      } else {
        return offerings.all.values.toList();
      }
    } on PlatformException catch (e) {
      log('Error fetching offers: $e');
      return [];
    }
  }

  static Future<void> fetchAndPresentPaywall(String offerId) async {
    try {
      final offerings = await Purchases.getOfferings();
      final offering = offerings.getOffering(offerId);

      // Paywall'ı göster
      await RevenueCatUI.presentPaywall(
          offering: offering, displayCloseButton: true);

      // Paywall kapandıktan sonra abonelik durumunu kontrol et
      final customerInfo = await Purchases.getCustomerInfo();
      if (customerInfo.entitlements.active.containsKey('paywall') &&
          customerInfo.activeSubscriptions.isNotEmpty) {
        await Future.delayed(const Duration(seconds: 1));
        Phoenix.rebirth(Get.context!);
      }
    } catch (e) {
      log("Error fetching or presenting paywall: $e");
    } finally {}
  }

  static Future<void> setupSubscriptionListener({
    Function? onSubscriptionUpdated,
  }) async {
    Purchases.addCustomerInfoUpdateListener((customerInfo) async {
      final isSubscribed =
          customerInfo.entitlements.active.containsKey('paywall');
      log("Subscription status changed: $isSubscribed");

      if (onSubscriptionUpdated != null) {
        onSubscriptionUpdated();
      }
    });
  }

  Future<bool> handleSinglePurchase() async {
    try {
      final offerings = await Purchases.getOfferings();
      final offering = offerings.getOffering('one-time');

      if (offering == null) {
        log("One-time offering not found");
        return false;
      }

      // Satın alma öncesi durumu kontrol et
      final beforePurchase = await Purchases.getCustomerInfo();
      final beforeNonSubscriptionPurchases =
          beforePurchase.nonSubscriptionTransactions;

      // Paywall'ı göster
      await RevenueCatUI.presentPaywall(
          offering: offering, displayCloseButton: true);

      // Satın alma sonrası durumu kontrol et
      final afterPurchase = await Purchases.getCustomerInfo();
      final afterNonSubscriptionPurchases =
          afterPurchase.nonSubscriptionTransactions;

      // Yeni bir satın alma var mı kontrol et
      return afterNonSubscriptionPurchases.length >
          beforeNonSubscriptionPurchases.length;
    } catch (e) {
      log("Error during single purchase: $e");
      return false;
    }
  }

  static Future<bool> checkSubscriptionStatus() async {
    try {
      final customerInfo = await Purchases.getCustomerInfo();
      return customerInfo.entitlements.active.containsKey('paywall');
    } catch (e) {
      log("Error checking subscription status: $e");
      return false;
    }
  }

  static Future<bool> isPremium() async {
    try {
      return await checkSubscriptionStatus();
    } catch (e) {
      return false;
    }
  }
}
