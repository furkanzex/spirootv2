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
import 'package:spirootv2/home/home_screen.dart';
import 'package:spirootv2/profile/user_controller.dart';
import 'package:spirootv2/astrology/astrology_controller.dart';

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
        // Controller'ları yeniden başlat
        await _reinitializeControllers();

        // Premium içeriklerin yüklenmesi için 3 saniye bekle
        await Future.delayed(const Duration(seconds: 3));

        // Ana sayfaya yönlendir ve tüm stack'i temizle
        Get.offAll(() => const HomeScreen());
      }
    } catch (e) {
      log("Error fetching or presenting paywall: $e");
    }
  }

  // Controller'ları yeniden başlatma metodu
  static Future<void> _reinitializeControllers() async {
    try {
      // UserController'ı yeniden başlat
      if (Get.isRegistered<UserController>()) {
        final userController = Get.find<UserController>();
        userController.onInit();
        log("UserController reinitialized");
      }

      // AstrologyController'ı yeniden başlat
      if (Get.isRegistered<AstrologyController>()) {
        final astrologyController = Get.find<AstrologyController>();
        astrologyController.onInit();
        log("AstrologyController reinitialized");
      }

      // Tüm GetX controller'ları yeniden başlat
      Get.reset();
      log("All GetX controllers reset");
    } catch (e) {
      log("Error reinitializing controllers: $e");
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
