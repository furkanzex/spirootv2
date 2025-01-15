import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:spirootv2/core/service/revenuecat_services.dart';
import 'package:spirootv2/paywall/paywall_screen.dart';

class UsageLimitService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static Future<bool> checkAndIncrementUsage(String feature) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return false;

      final isPremium = await PurchaseAPI.isPremium();
      if (isPremium) return true;

      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final maxUsage = 1;

      final docRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('feature_usage')
          .doc(today.toIso8601String());

      final doc = await docRef.get();
      final currentUsage = doc.exists ? (doc.data()?[feature] ?? 0) : 0;

      if (currentUsage >= maxUsage) {
        paywall();
        return false;
      }

      await docRef.set({
        feature: currentUsage + 1,
        'date': today.toIso8601String(),
      }, SetOptions(merge: true));

      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<int> getRemainingUsage(String feature) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return 0;

      final isPremium = await PurchaseAPI.isPremium();
      if (isPremium) return 999;

      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final maxUsage = 1;

      final docRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('feature_usage')
          .doc(today.toIso8601String());

      final doc = await docRef.get();
      final currentUsage = doc.exists ? (doc.data()?[feature] ?? 0) : 0;

      return (maxUsage - currentUsage).toInt();
    } catch (e) {
      return 0;
    }
  }
}
