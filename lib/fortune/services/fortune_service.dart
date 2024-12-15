import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:easy_localization/easy_localization.dart' as easy;

class FortuneService {
  static final _storage = GetStorage();
  static const String _baseUrl = 'https://apptoic.com/spiroot/json';
  static const String _fortuneCachePrefix = 'fortune_data_';
  static const String _affirmationCachePrefix = 'affirmation_data_';

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
        throw Exception('Failed to load fortunes');
      }
    } catch (e) {
      debugPrint('Error loading fortunes: $e');
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
      debugPrint('Affirmations dosya adı: $fileName');
      final url = '$_baseUrl/$fileName';
      debugPrint('İstek URL: $url');

      final response = await http.get(
        Uri.parse(url),
        headers: {'Accept-Charset': 'utf-8'},
      );

      debugPrint('Yanıt durumu: ${response.statusCode}');
      if (response.statusCode == 200) {
        final decodedResponse = utf8.decode(response.bodyBytes);
        debugPrint('Yanıt içeriği: $decodedResponse');
        final data = json.decode(decodedResponse);
        final affirmations = List<String>.from(data['affirmations']);

        // Cache'e kaydet
        _storage.write(cacheKey, affirmations);
        return affirmations;
      } else {
        throw Exception('Failed to load affirmations');
      }
    } catch (e) {
      debugPrint('Error loading affirmations: $e');
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
