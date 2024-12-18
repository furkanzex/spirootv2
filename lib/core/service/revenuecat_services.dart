import 'dart:async';
import 'dart:developer';
import 'dart:io' show Platform;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';
import 'package:spirootv2/core/env/env.dart';

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
      // Fetch available offerings
      final offerings = await Purchases.getOfferings();
      final offering = offerings.getOffering(offerId);
      await RevenueCatUI.presentPaywall(
          offering: offering, displayCloseButton: true);
    } catch (e) {
      log("Error fetching or presenting paywall: $e");
    }
  }

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void setupSubscriptionListener({Function? onSubscriptionUpdated}) {
    Purchases.addCustomerInfoUpdateListener((customerInfo) async {
      await _handleSubscriptionUpdate(customerInfo);
      if (onSubscriptionUpdated != null) {
        onSubscriptionUpdated();
      }
    });
  }

  Future<void> _handleSubscriptionUpdate(CustomerInfo customerInfo) async {
    try {
      if (customerInfo.entitlements.active.isNotEmpty) {
        // User has an active subscription
        final entitlement = customerInfo.entitlements.active.values.first;
        await _firestore
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser!.email)
            .update({
          'isSubscribed': true,
          'subscription_expiry': entitlement.expirationDate,
        });
      } else if (customerInfo.entitlements.active.isEmpty) {
        await _firestore
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser!.email)
            .update({
          'isSubscribed': false,
          'subscription_expiry': FieldValue.delete(),
        });
      }
    } catch (e) {
      log("Error updating Firestore: $e");
    }
  }
}
