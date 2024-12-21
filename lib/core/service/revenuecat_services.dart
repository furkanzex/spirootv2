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

  static bool _isInitialSetup = true;

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

  Future<void> fetchAndPresentPaywall(String offerId) async {
    try {
      final offerings = await Purchases.getOfferings();
      final offering = offerings.getOffering(offerId);
      await RevenueCatUI.presentPaywall(
          offering: offering, displayCloseButton: true);
    } catch (e) {
      log("Error fetching or presenting paywall: $e");
    }
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

      // Sadece ilk kurulum sırasında veya abonelik değişikliklerinde yeniden başlat
      if (!_isInitialSetup &&
          customerInfo.entitlements.active.containsKey('paywall') &&
          customerInfo.activeSubscriptions.isNotEmpty) {
        await Future.delayed(const Duration(seconds: 1));
        Phoenix.rebirth(Get.context!);
      }
      _isInitialSetup = false;
    });
  }

  Future<bool> handleSinglePurchase() async {
    try {
      final offerings = await Purchases.getOfferings();

      // "one-time" teklifini göster
      await RevenueCatUI.presentPaywall(
          offering: offerings.getOffering('one-time'),
          displayCloseButton: true);

      // Satın alma durumunu kontrol et
      final customerInfo = await Purchases.getCustomerInfo();
      return customerInfo.entitlements.active.isNotEmpty;
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
