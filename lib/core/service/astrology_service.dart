import 'package:spirootv2/core/service/revenuecat_services.dart';

class AstrologyService {
  static Future<bool> checkPremiumFeatureAccess() async {
    return await PurchaseAPI.isPremium();
  }

  static String calculateZodiacSign(DateTime birthDate) {
    int month = birthDate.month;
    int day = birthDate.day;

    if ((month == 3 && day >= 21) || (month == 4 && day <= 19)) {
      return 'aries';
    } else if ((month == 4 && day >= 20) || (month == 5 && day <= 20)) {
      return 'taurus';
    } else if ((month == 5 && day >= 21) || (month == 6 && day <= 20)) {
      return 'gemini';
    } else if ((month == 6 && day >= 21) || (month == 7 && day <= 22)) {
      return 'cancer';
    } else if ((month == 7 && day >= 23) || (month == 8 && day <= 22)) {
      return 'leo';
    } else if ((month == 8 && day >= 23) || (month == 9 && day <= 22)) {
      return 'virgo';
    } else if ((month == 9 && day >= 23) || (month == 10 && day <= 22)) {
      return 'libra';
    } else if ((month == 10 && day >= 23) || (month == 11 && day <= 21)) {
      return 'scorpio';
    } else if ((month == 11 && day >= 22) || (month == 12 && day <= 21)) {
      return 'sagittarius';
    } else if ((month == 12 && day >= 22) || (month == 1 && day <= 19)) {
      return 'capricorn';
    } else if ((month == 1 && day >= 20) || (month == 2 && day <= 18)) {
      return 'aquarius';
    } else {
      return 'pisces';
    }
  }

  static String calculateMoonSign(DateTime birthDate, String birthTime) {
    // Basit bir ay burcu hesaplama algoritması
    // Gerçek hesaplama için astronomik kütüphane kullanılmalı
    List<String> signs = [
      'aries',
      'taurus',
      'gemini',
      'cancer',
      'leo',
      'virgo',
      'libra',
      'scorpio',
      'sagittarius',
      'capricorn',
      'aquarius',
      'pisces'
    ];

    int baseIndex = signs.indexOf(calculateZodiacSign(birthDate));
    List<int> timeComponents = birthTime.split(':').map(int.parse).toList();
    int hourOffset = timeComponents[0] % 12;

    return signs[(baseIndex + hourOffset) % 12];
  }

  static String calculateAscendant(
    DateTime birthDate,
    String birthTime,
    String birthPlace,
  ) {
    // Basit bir yükselen burç hesaplama algoritması
    // Gerçek hesaplama için astronomik kütüphane ve koordinat bilgileri kullanılmalı
    List<String> signs = [
      'aries',
      'taurus',
      'gemini',
      'cancer',
      'leo',
      'virgo',
      'libra',
      'scorpio',
      'sagittarius',
      'capricorn',
      'aquarius',
      'pisces'
    ];

    int baseIndex = signs.indexOf(calculateZodiacSign(birthDate));
    List<int> timeComponents = birthTime.split(':').map(int.parse).toList();
    int hourOffset = (timeComponents[0] + (timeComponents[1] / 60)) ~/ 2;

    return signs[(baseIndex + hourOffset) % 12];
  }
}
