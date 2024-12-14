import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:get_storage/get_storage.dart';
import 'package:easy_localization/easy_localization.dart' as easy;
import 'package:flutter/material.dart';
import 'package:extended_image/extended_image.dart';

class RitualService {
  static final _storage = GetStorage();
  static const String _cacheKeyPrefix = 'ritual_data_';

  static Future<Map<String, dynamic>> loadRituals(BuildContext context) async {
    final locale = context.locale.languageCode;
    final cacheKey = '$_cacheKeyPrefix$locale';

    // Cache'den kontrol et
    final cachedData = _storage.read(cacheKey);
    if (cachedData != null) {
      return Map<String, dynamic>.from(cachedData);
    }

    // JSON'dan yükle
    final String response =
        await rootBundle.loadString('assets/json/rituals.json');
    final Map<String, dynamic> data = json.decode(response);

    // Temel çevirileri yap
    for (var category in data.values) {
      category['title'] = easy.tr(category['title']);
      category['description'] = easy.tr(category['description']);

      final rituals = category['rituals'] as List;
      for (var ritual in rituals) {
        ritual['title'] = easy.tr(ritual['title']);
        ritual['difficulty'] = easy.tr(ritual['difficulty']);
        ritual['duration'] = easy.tr(ritual['duration']);
      }
    }

    // Cache'e kaydet
    _storage.write(cacheKey, data);

    return data;
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
}
