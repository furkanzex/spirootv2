import 'package:spirootv2/core/service/revenuecat_services.dart';

paywall() async {
  PurchaseAPI.setupSubscriptionListener();
  PurchaseAPI.fetchAndPresentPaywall('paywall');
}
