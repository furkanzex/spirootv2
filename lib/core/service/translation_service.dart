import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:translator/translator.dart';

class TranslationService extends GetxService {
  final translator = GoogleTranslator();
  final storage = GetStorage();

  bool get isAutoTranslateEnabled => storage.read('auto_translate') ?? false;

  Future<TranslationService> init() async {
    return this;
  }

  Future<String> translateText(String text, String targetLanguage) async {
    if (!isAutoTranslateEnabled) return text;

    try {
      final translation = await translator.translate(
        text,
        to: targetLanguage,
      );
      return translation.text;
    } catch (e) {
      print('Translation error: $e');
      return text;
    }
  }

  Future<String> translateToAppLanguage(String text) async {
    if (!isAutoTranslateEnabled) return text;

    final currentLocale = Get.locale?.languageCode ?? 'en';
    return translateText(text, currentLocale);
  }
}
