import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:translator/translator.dart';
import 'package:get_storage/get_storage.dart';

class RitualService {
  static final translator = GoogleTranslator();
  static final _storage = GetStorage();
  static const String cacheKey = 'ritual_data_tr';

  static Future<Map<String, dynamic>> loadRituals() async {
    // Önce cache'den kontrol et
    final cachedData = _storage.read(cacheKey);
    if (cachedData != null) {
      return Map<String, dynamic>.from(cachedData);
    }

    // Cache'de yoksa JSON'dan yükle ve çevir
    final String response =
        await rootBundle.loadString('assets/json/rituals.json');
    final Map<String, dynamic> data = json.decode(response);

    // Paralel çeviri için tüm çeviri işlemlerini topla
    List<Future> translations = [];

    for (var category in data.values) {
      translations.add(translator
          .translate(category['title'] as String, to: 'tr')
          .then((value) {
        category['title'] = value.text;
      }));

      translations.add(translator
          .translate(category['description'] as String, to: 'tr')
          .then((value) {
        category['description'] = value.text;
      }));

      final rituals = category['rituals'] as List;
      for (var ritual in rituals) {
        translations.add(translator
            .translate(ritual['title'] as String, to: 'tr')
            .then((value) {
          ritual['title'] = value.text;
        }));

        translations.add(translator
            .translate(ritual['duration'] as String, to: 'tr')
            .then((value) {
          ritual['duration'] = value.text;
        }));

        translations.add(translator
            .translate(ritual['difficulty'] as String, to: 'tr')
            .then((value) {
          ritual['difficulty'] = value.text;
        }));

        final materials = ritual['materials'] as List;
        for (var i = 0; i < materials.length; i++) {
          final index = i;
          translations.add(translator
              .translate(materials[i] as String, to: 'tr')
              .then((value) {
            materials[index] = value.text;
          }));
        }

        final steps = ritual['steps'] as List;
        for (var i = 0; i < steps.length; i++) {
          final index = i;
          translations.add(
              translator.translate(steps[i] as String, to: 'tr').then((value) {
            steps[index] = value.text;
          }));
        }
      }
    }

    // Tüm çevirileri paralel olarak bekle
    await Future.wait(translations);

    // Çevrilmiş veriyi cache'e kaydet
    _storage.write(cacheKey, data);

    return data;
  }
}
