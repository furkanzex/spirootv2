import 'dart:async';
import 'dart:developer';
import 'dart:io' show Platform;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';

class PurchaseAPI {
  final String apiKeyGoogle = "";
  final String apiKeyApple = "";

  Future<void> init() async {
    PurchasesConfiguration? configuration;
    if (Platform.isAndroid) {
      configuration = PurchasesConfiguration(apiKeyGoogle);
    } else if (Platform.isIOS) {
      try {
        configuration = PurchasesConfiguration(apiKeyApple);
      } catch (e) {
        log(e.toString());
      }
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

  void setupSubscriptionListener() {
    try {
      Purchases.addCustomerInfoUpdateListener((customerInfo) async {
        await _handleSubscriptionUpdate(customerInfo);
      });
    } catch (e) {
      log(e.toString());
    }
  }

  Future<void> _handleSubscriptionUpdate(CustomerInfo customerInfo) async {
    try {
      if (customerInfo.entitlements.active.isNotEmpty) {
        final entitlement = customerInfo.entitlements.active.values.first;
        await _firestore
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser!.email)
            .update({
          'subscription': 'active',
          'subscription_expiry': entitlement.expirationDate,
        });
      } else if (customerInfo.entitlements.active.isEmpty) {
        await _firestore
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser!.email)
            .update({
          'subscription': 'none',
          'subscription_expiry': FieldValue.delete(),
        });
      }
    } catch (e) {
      log("Error updating Firestore: $e");
    }
  }
}
