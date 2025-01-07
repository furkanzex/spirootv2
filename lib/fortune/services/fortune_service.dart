import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:easy_localization/easy_localization.dart' as easy;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:spirootv2/core/service/notification_service.dart';

class FortuneService {
  static final _storage = GetStorage();
  static const String _baseUrl = 'https://apptoic.com/spiroot/json';
  static const String _fortuneCachePrefix = 'fortune_data_';
  static const String _affirmationCachePrefix = 'affirmation_data_';
  static final NotificationService _notificationService = NotificationService();

  static Future<void> saveFortune({
    required String fortuneType,
    required String userId,
    required Map<String, dynamic> interpretation,
    required List<String> images,
    required Map<String, dynamic> userInfo,
    required DateTime revealAt,
  }) async {
    try {
      // Firestore'a kaydet
      final docRef = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('fortunes')
          .add({
        'type': fortuneType,
        'images': images,
        'interpretation': interpretation,
        'timestamp': FieldValue.serverTimestamp(),
        'revealAt': Timestamp.fromDate(revealAt),
        'userInfo': userInfo,
      });

      // Bildirim planla
      await _notificationService.scheduleFortuneReadyNotification(
        fortuneId: docRef.id,
        fortuneType: fortuneType,
        revealAt: revealAt,
      );
    } catch (e) {
      rethrow;
    }
  }

  static Future<List<String>> loadFortunes(BuildContext context) async {
    final locale = context.locale.languageCode;
    final cacheKey = '${_fortuneCachePrefix}$locale';

    // Önce cache'den kontrol et
    final cachedData = _storage.read(cacheKey);
    if (cachedData != null) {
      return List<String>.from(cachedData);
    }

    try {
      // Dil dosyasından dosya adını al
      final fileName = easy.tr("fortunes");
      final response = await http.get(
        Uri.parse('$_baseUrl/$fileName'),
        headers: {'Accept-Charset': 'utf-8'},
      );

      if (response.statusCode == 200) {
        final decodedResponse = utf8.decode(response.bodyBytes);
        final data = json.decode(decodedResponse);
        final messages = List<String>.from(data['messages']);

        // Cache'e kaydet
        _storage.write(cacheKey, messages);
        return messages;
      } else {
        throw Exception(easy.tr('fortune.failed_to_load_fortunes'));
      }
    } catch (e) {
      rethrow;
    }
  }

  static Future<List<String>> loadAffirmations(BuildContext context) async {
    final locale = context.locale.languageCode;
    final cacheKey = '${_affirmationCachePrefix}$locale';

    // Önce cache'den kontrol et
    final cachedData = _storage.read(cacheKey);
    if (cachedData != null) {
      return List<String>.from(cachedData);
    }

    try {
      // Dil dosyasından dosya adını al
      final fileName = easy.tr("affirmations");
      final url = '$_baseUrl/$fileName';

      final response = await http.get(
        Uri.parse(url),
        headers: {'Accept-Charset': 'utf-8'},
      );

      if (response.statusCode == 200) {
        final decodedResponse = utf8.decode(response.bodyBytes);
        final data = json.decode(decodedResponse);
        final affirmations = List<String>.from(data['affirmations']);

        // Cache'e kaydet
        _storage.write(cacheKey, affirmations);
        return affirmations;
      } else {
        throw Exception(easy.tr('fortune.failed_to_load_affirmations'));
      }
    } catch (e) {
      rethrow;
    }
  }

  // Dil değiştiğinde cache'i temizle
  static void clearCache() {
    final keys = _storage.getKeys().toList();
    for (var key in keys) {
      if (key is String &&
          (key.startsWith(_fortuneCachePrefix) ||
              key.startsWith(_affirmationCachePrefix))) {
        _storage.remove(key);
      }
    }
  }

  // Dil değişikliğini dinle
  static void onLocaleChanged(String newLocale) {
    clearCache();
  }
}
