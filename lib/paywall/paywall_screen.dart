import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';
import 'package:spirootv2/core/service/revenuecat_services.dart';

paywall() async {
  PurchaseAPI.setupSubscriptionListener();
  PurchaseAPI.fetchAndPresentPaywall('paywall');
}
