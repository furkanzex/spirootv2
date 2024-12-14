import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:extended_image/extended_image.dart';
import 'package:http/http.dart' as http;
import 'package:easy_localization/easy_localization.dart' as easy;

class RitualService {
  static final _storage = GetStorage();
  static const String _cacheKeyPrefix = 'ritual_data_';
  static const String _baseUrl = 'https://apptoic.com/spiroot/json';

  static Future<Map<String, dynamic>> loadRituals(BuildContext context) async {
    final locale = context.locale.languageCode;
    final cacheKey = '$_cacheKeyPrefix$locale';

    // Önce cache'den kontrol et
    final cachedData = _storage.read(cacheKey);
    if (cachedData != null) {
      return Map<String, dynamic>.from(cachedData);
    }

    try {
      // Dil dosyasından ritüel dosya adını al
      final ritualFileName = easy.tr("ritual");

      // HTTP isteğini UTF-8 headers ile yap
      final response = await http.get(
        Uri.parse('$_baseUrl/$ritualFileName'),
        headers: {'Accept-Charset': 'utf-8'},
      );

      if (response.statusCode == 200) {
        // Yanıtı UTF-8 olarak decode et
        final String decodedResponse = utf8.decode(response.bodyBytes);
        final data = json.decode(decodedResponse);

        // Cache'e kaydet
        _storage.write(cacheKey, data);
        return Map<String, dynamic>.from(data);
      } else {
        throw Exception('Failed to load rituals');
      }
    } catch (e) {
      debugPrint('Error loading rituals: $e');
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> translateRitualDetails(
    Map<String, dynamic> ritual,
    String locale,
  ) async {
    // Çeviriye gerek yok çünkü doğru dildeki JSON dosyasını kullanıyoruz
    return ritual;
  }

  static Widget getCachedImage(String imageUrl, {double? height}) {
    return ExtendedImage.network(
      imageUrl,
      fit: BoxFit.cover,
      width: double.infinity,
      height: height ?? 160,
      cache: true,
      color: Colors.black.withOpacity(0.3),
      colorBlendMode: BlendMode.darken,
      loadStateChanged: (ExtendedImageState state) {
        switch (state.extendedImageLoadState) {
          case LoadState.loading:
            return Container(
              color: Colors.black12,
              height: height ?? 160,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            );
          case LoadState.failed:
            return Container(
              color: Colors.black12,
              height: height ?? 160,
              child: const Center(
                child: Icon(Icons.error),
              ),
            );
          default:
            return null;
        }
      },
    );
  }

  // Sadece çeviri cache'ini temizle
  static void clearTranslationCache() {
    final keys = _storage.getKeys().toList();
    for (var key in keys) {
      if (key is String && key.startsWith(_cacheKeyPrefix)) {
        _storage.remove(key);
      }
    }
  }

  // Dil değiştiğinde cache'i temizle
  static void onLocaleChanged(String newLocale) {
    clearTranslationCache();
  }
}
