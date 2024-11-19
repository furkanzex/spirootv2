import 'dart:math';

import 'package:get/get.dart';
import 'package:spirootv2/astrology/daily_horoscope.dart';
import 'package:easy_localization/easy_localization.dart' as easy;

class AstrologyController extends GetxController {
  final RxDouble zodiacRotation = 0.0.obs;
  final RxString selectedDay = easy.tr("astrology.horoscope.dates.today").obs;
  final Rx<DailyHoroscope> selectedHoroscope = DailyHoroscope(
    date: DateTime.now().toString(),
    essential: "",
    affirmation: "",
    horoscopeText: "",
    lovePercentage: 0.0,
    careerPercentage: 0.0,
    moneyPercentage: 0.0,
  ).obs;

  @override
  void onInit() {
    super.onInit();
    // Varsayılan horoskopu yükle
    updateHoroscope(selectedDay.value);
  }

  final Map<String, Map<String, dynamic>> zodiacInfo = {
    "aries": {
      "name": easy.tr("astrology.zodiac.aries.name"),
      "element": easy.tr("astrology.zodiac.aries.element"),
      "quality": easy.tr("astrology.zodiac.aries.quality"),
      "ruler": easy.tr("astrology.zodiac.aries.ruler"),
      "symbol": easy.tr("astrology.zodiac.aries.symbol"),
      "dateRange": easy.tr("astrology.zodiac.aries.dateRange"),
      "characteristics":
          easy.tr("astrology.zodiac.aries.characteristics").split(","),
      "color": easy.tr("astrology.zodiac.aries.color"),
    },
    "taurus": {
      "name": easy.tr("astrology.zodiac.taurus.name"),
      "element": easy.tr("astrology.zodiac.taurus.element"),
      "quality": easy.tr("astrology.zodiac.taurus.quality"),
      "ruler": easy.tr("astrology.zodiac.taurus.ruler"),
      "symbol": easy.tr("astrology.zodiac.taurus.symbol"),
      "dateRange": easy.tr("astrology.zodiac.taurus.dateRange"),
      "characteristics":
          easy.tr("astrology.zodiac.taurus.characteristics").split(","),
      "color": easy.tr("astrology.zodiac.taurus.color"),
    },
    "gemini": {
      "name": easy.tr("astrology.zodiac.gemini.name"),
      "element": easy.tr("astrology.zodiac.gemini.element"),
      "quality": easy.tr("astrology.zodiac.gemini.quality"),
      "ruler": easy.tr("astrology.zodiac.gemini.ruler"),
      "symbol": easy.tr("astrology.zodiac.gemini.symbol"),
      "dateRange": easy.tr("astrology.zodiac.gemini.dateRange"),
      "characteristics":
          easy.tr("astrology.zodiac.gemini.characteristics").split(","),
      "color": easy.tr("astrology.zodiac.gemini.color"),
    },
    "cancer": {
      "name": easy.tr("astrology.zodiac.cancer.name"),
      "element": easy.tr("astrology.zodiac.cancer.element"),
      "quality": easy.tr("astrology.zodiac.cancer.quality"),
      "ruler": easy.tr("astrology.zodiac.cancer.ruler"),
      "symbol": easy.tr("astrology.zodiac.cancer.symbol"),
      "dateRange": easy.tr("astrology.zodiac.cancer.dateRange"),
      "characteristics":
          easy.tr("astrology.zodiac.cancer.characteristics").split(","),
      "color": easy.tr("astrology.zodiac.cancer.color"),
    },
    "leo": {
      "name": easy.tr("astrology.zodiac.leo.name"),
      "element": easy.tr("astrology.zodiac.leo.element"),
      "quality": easy.tr("astrology.zodiac.leo.quality"),
      "ruler": easy.tr("astrology.zodiac.leo.ruler"),
      "symbol": easy.tr("astrology.zodiac.leo.symbol"),
      "dateRange": easy.tr("astrology.zodiac.leo.dateRange"),
      "characteristics":
          easy.tr("astrology.zodiac.leo.characteristics").split(","),
      "color": easy.tr("astrology.zodiac.leo.color"),
    },
    "virgo": {
      "name": easy.tr("astrology.zodiac.virgo.name"),
      "element": easy.tr("astrology.zodiac.virgo.element"),
      "quality": easy.tr("astrology.zodiac.virgo.quality"),
      "ruler": easy.tr("astrology.zodiac.virgo.ruler"),
      "symbol": easy.tr("astrology.zodiac.virgo.symbol"),
      "dateRange": easy.tr("astrology.zodiac.virgo.dateRange"),
      "characteristics":
          easy.tr("astrology.zodiac.virgo.characteristics").split(","),
      "color": easy.tr("astrology.zodiac.virgo.color"),
    },
    "libra": {
      "name": easy.tr("astrology.zodiac.libra.name"),
      "element": easy.tr("astrology.zodiac.libra.element"),
      "quality": easy.tr("astrology.zodiac.libra.quality"),
      "ruler": easy.tr("astrology.zodiac.libra.ruler"),
      "symbol": easy.tr("astrology.zodiac.libra.symbol"),
      "dateRange": easy.tr("astrology.zodiac.libra.dateRange"),
      "characteristics":
          easy.tr("astrology.zodiac.libra.characteristics").split(","),
      "color": easy.tr("astrology.zodiac.libra.color"),
    },
    "scorpio": {
      "name": easy.tr("astrology.zodiac.scorpio.name"),
      "element": easy.tr("astrology.zodiac.scorpio.element"),
      "quality": easy.tr("astrology.zodiac.scorpio.quality"),
      "ruler": easy.tr("astrology.zodiac.scorpio.ruler"),
      "symbol": easy.tr("astrology.zodiac.scorpio.symbol"),
      "dateRange": easy.tr("astrology.zodiac.scorpio.dateRange"),
      "characteristics":
          easy.tr("astrology.zodiac.scorpio.characteristics").split(","),
      "color": easy.tr("astrology.zodiac.scorpio.color"),
    },
    "sagittarius": {
      "name": easy.tr("astrology.zodiac.sagittarius.name"),
      "element": easy.tr("astrology.zodiac.sagittarius.element"),
      "quality": easy.tr("astrology.zodiac.sagittarius.quality"),
      "ruler": easy.tr("astrology.zodiac.sagittarius.ruler"),
      "symbol": easy.tr("astrology.zodiac.sagittarius.symbol"),
      "dateRange": easy.tr("astrology.zodiac.sagittarius.dateRange"),
      "characteristics":
          easy.tr("astrology.zodiac.sagittarius.characteristics").split(","),
      "color": easy.tr("astrology.zodiac.sagittarius.color"),
    },
    "capricorn": {
      "name": easy.tr("astrology.zodiac.capricorn.name"),
      "element": easy.tr("astrology.zodiac.capricorn.element"),
      "quality": easy.tr("astrology.zodiac.capricorn.quality"),
      "ruler": easy.tr("astrology.zodiac.capricorn.ruler"),
      "symbol": easy.tr("astrology.zodiac.capricorn.symbol"),
      "dateRange": easy.tr("astrology.zodiac.capricorn.dateRange"),
      "characteristics":
          easy.tr("astrology.zodiac.capricorn.characteristics").split(","),
      "color": easy.tr("astrology.zodiac.capricorn.color"),
    },
    "aquarius": {
      "name": easy.tr("astrology.zodiac.aquarius.name"),
      "element": easy.tr("astrology.zodiac.aquarius.element"),
      "quality": easy.tr("astrology.zodiac.aquarius.quality"),
      "ruler": easy.tr("astrology.zodiac.aquarius.ruler"),
      "symbol": easy.tr("astrology.zodiac.aquarius.symbol"),
      "dateRange": easy.tr("astrology.zodiac.aquarius.dateRange"),
      "characteristics":
          easy.tr("astrology.zodiac.aquarius.characteristics").split(","),
      "color": easy.tr("astrology.zodiac.aquarius.color"),
    },
    "pisces": {
      "name": easy.tr("astrology.zodiac.pisces.name"),
      "element": easy.tr("astrology.zodiac.pisces.element"),
      "quality": easy.tr("astrology.zodiac.pisces.quality"),
      "ruler": easy.tr("astrology.zodiac.pisces.ruler"),
      "symbol": easy.tr("astrology.zodiac.pisces.symbol"),
      "dateRange": easy.tr("astrology.zodiac.pisces.dateRange"),
      "characteristics":
          easy.tr("astrology.zodiac.pisces.characteristics").split(","),
      "color": easy.tr("astrology.zodiac.pisces.color"),
    },
  };

  final Map<String, DailyHoroscope> horoscopes = {
    easy.tr("astrology.horoscope.dates.yesterday"): DailyHoroscope(
      date: "8 Mart 2024",
      essential: "Meditation, inner peace, reflection",
      affirmation: "I am at peace with myself and my surroundings",
      horoscopeText:
          "Yesterday was a day of deep introspection. You might have felt more connected to your spiritual side and found comfort in solitary activities.",
      lovePercentage: 0.65,
      careerPercentage: 0.45,
      moneyPercentage: 0.70,
    ),
    easy.tr("astrology.horoscope.dates.today"): DailyHoroscope(
      date: "9 Mart 2024",
      essential: "Communication, creativity, social connections",
      affirmation: "I express myself freely and authentically",
      horoscopeText:
          "Today brings opportunities for meaningful conversations. Your creative energy is high, making it an excellent time for artistic pursuits or brainstorming sessions.",
      lovePercentage: 0.75,
      careerPercentage: 0.80,
      moneyPercentage: 0.60,
    ),
    easy.tr("astrology.horoscope.dates.tomorrow"): DailyHoroscope(
      date: "10 Mart 2024",
      essential: "Growth, transformation, new beginnings",
      affirmation: "I embrace change and grow stronger each day",
      horoscopeText:
          "Tomorrow holds potential for significant personal growth. Be open to new opportunities and trust your intuition.",
      lovePercentage: 0.85,
      careerPercentage: 0.70,
      moneyPercentage: 0.65,
    ),
    easy.tr("astrology.horoscope.dates.week"): DailyHoroscope(
      date: "9-15 Mart 2024",
      essential: "Balance, harmony, achievement",
      affirmation: "I create balance in all areas of my life",
      horoscopeText:
          "This week emphasizes finding balance between your personal and professional life. Focus on maintaining harmony while pursuing your goals.",
      lovePercentage: 0.80,
      careerPercentage: 0.75,
      moneyPercentage: 0.70,
    ),
    easy.tr("astrology.horoscope.dates.month"): DailyHoroscope(
      date: "Mart 2024",
      essential: "Long-term planning, relationships, success",
      affirmation: "I am creating my ideal future",
      horoscopeText:
          "This month brings opportunities for long-term planning and strengthening relationships. Focus on building foundations for future success.",
      lovePercentage: 0.75,
      careerPercentage: 0.85,
      moneyPercentage: 0.80,
    ),
  };

  DailyHoroscope get currentHoroscope =>
      horoscopes[selectedDay.value] ??
      DailyHoroscope(
        date: DateTime.now().toString(),
        essential: "",
        affirmation: "",
        horoscopeText: "Henüz yorum yok",
        lovePercentage: 0.0,
        careerPercentage: 0.0,
        moneyPercentage: 0.0,
      );

  void changeDay(String day) {
    selectedDay.value = day;
    updateHoroscope(day);
  }

  void updateHoroscope(String day) {
    selectedHoroscope.value = horoscopes[day] ??
        DailyHoroscope(
          date: DateTime.now().toString(),
          essential: "",
          affirmation: "",
          horoscopeText: "Henüz yorum yok",
          lovePercentage: 0.0,
          careerPercentage: 0.0,
          moneyPercentage: 0.0,
        );
    update();
  }

  String getZodiacSign(DateTime date) {
    int month = date.month;
    int day = date.day;

    if ((month == 3 && day >= 21) || (month == 4 && day <= 19)) return "aries";
    if ((month == 4 && day >= 20) || (month == 5 && day <= 20)) return "taurus";
    if ((month == 5 && day >= 21) || (month == 6 && day <= 20)) return "gemini";
    if ((month == 6 && day >= 21) || (month == 7 && day <= 22)) return "cancer";
    if ((month == 7 && day >= 23) || (month == 8 && day <= 22)) return "leo";
    if ((month == 8 && day >= 23) || (month == 9 && day <= 22)) return "virgo";
    if ((month == 9 && day >= 23) || (month == 10 && day <= 22)) return "libra";
    if ((month == 10 && day >= 23) || (month == 11 && day <= 21))
      return "scorpio";
    if ((month == 11 && day >= 22) || (month == 12 && day <= 21))
      return "sagittarius";
    if ((month == 12 && day >= 22) || (month == 1 && day <= 19))
      return "capricorn";
    if ((month == 1 && day >= 20) || (month == 2 && day <= 18))
      return "aquarius";
    return "pisces";
  }

  Map<String, dynamic> getZodiacDetails(DateTime date) {
    String zodiacSign = getZodiacSign(date);
    final zodiacKey = zodiacSign.toLowerCase();

    return {
      "name": easy.tr("astrology.zodiac.$zodiacKey.name"),
      "element": easy.tr("astrology.zodiac.$zodiacKey.element"),
      "quality": easy.tr("astrology.zodiac.$zodiacKey.quality"),
      "ruler": easy.tr("astrology.zodiac.$zodiacKey.ruler"),
      "symbol": easy.tr("astrology.zodiac.$zodiacKey.symbol"),
      "dateRange": easy.tr("astrology.zodiac.$zodiacKey.dateRange"),
      "characteristics":
          easy.tr("astrology.zodiac.$zodiacKey.characteristics").split(","),
      "color": easy.tr("astrology.zodiac.$zodiacKey.color"),
    };
  }

  double calculateZodiacRotation(DateTime date) {
    int index = getZodiacIndex(date);
    double rotation = (index * -30) * (pi / 180);
    zodiacRotation.value = rotation;
    return rotation;
  }

  void updateZodiacRotation(DateTime date) {
    double newRotation = calculateZodiacRotation(date);
    zodiacRotation.value = newRotation;
    update();
  }

  int getZodiacIndex(DateTime date) {
    int month = date.month;
    int day = date.day;

    if ((month == 3 && day >= 21) || (month == 4 && day <= 19)) return 0; // Koç
    if ((month == 4 && day >= 20) || (month == 5 && day <= 20))
      return 1; // Boğa
    if ((month == 5 && day >= 21) || (month == 6 && day <= 20))
      return 2; // İkizler
    if ((month == 6 && day >= 21) || (month == 7 && day <= 22))
      return 3; // Yengeç
    if ((month == 7 && day >= 23) || (month == 8 && day <= 22))
      return 4; // Aslan
    if ((month == 8 && day >= 23) || (month == 9 && day <= 22))
      return 5; // Başak
    if ((month == 9 && day >= 23) || (month == 10 && day <= 22))
      return 6; // Terazi
    if ((month == 10 && day >= 23) || (month == 11 && day <= 21))
      return 7; // Akrep
    if ((month == 11 && day >= 22) || (month == 12 && day <= 21))
      return 8; // Yay
    if ((month == 12 && day >= 22) || (month == 1 && day <= 19))
      return 9; // Oğlak
    if ((month == 1 && day >= 20) || (month == 2 && day <= 18))
      return 10; // Kova
    return 11; // Balık
  }

  String getZodiacElement(DateTime date) {
    return getZodiacDetails(date)['element'] ?? '';
  }

  String getZodiacQuality(DateTime date) {
    return getZodiacDetails(date)['quality'] ?? '';
  }

  String getZodiacRuler(DateTime date) {
    return getZodiacDetails(date)['ruler'] ?? '';
  }

  String getZodiacSymbol(DateTime date) {
    return getZodiacDetails(date)['symbol'] ?? '';
  }

  String getZodiacDateRange(DateTime date) {
    return getZodiacDetails(date)['dateRange'] ?? '';
  }

  List<String> getZodiacCharacteristics(DateTime date) {
    return List<String>.from(getZodiacDetails(date)['characteristics'] ?? []);
  }

  String getZodiacColor(DateTime date) {
    return getZodiacDetails(date)['color'] ?? '';
  }

  String getMoonSign(DateTime birthDateTime) {
    // Basit bir hesaplama için şimdilik güneş burcundan 2 burç sonrasını döndürelim
    // Gerçek hesaplama için astronomi kütüphanesi kullanılmalı
    final sunSign = getZodiacSign(birthDateTime);
    final zodiacSigns = [
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

    final currentIndex = zodiacSigns.indexOf(sunSign.toLowerCase());
    final moonIndex = (currentIndex + 2) % 12;
    return zodiacSigns[moonIndex];
  }

  String getAscendant(DateTime birthDateTime, String birthPlace) {
    // Basit bir hesaplama için şimdilik güneş burcundan 3 burç sonrasını döndürelim
    // Gerçek hesaplama için doğum yeri koordinatları ve astronomi kütüphanesi kullanılmalı
    final sunSign = getZodiacSign(birthDateTime);
    final zodiacSigns = [
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

    final currentIndex = zodiacSigns.indexOf(sunSign.toLowerCase());
    final ascendantIndex = (currentIndex + 3) % 12;
    return zodiacSigns[ascendantIndex];
  }

  Map<String, dynamic> getZodiacDetailsByName(String zodiacName) {
    final zodiacKey = zodiacName.toLowerCase();

    return {
      "name": easy.tr("astrology.zodiac.$zodiacKey.name"),
      "element": easy.tr("astrology.zodiac.$zodiacKey.element"),
      "quality": easy.tr("astrology.zodiac.$zodiacKey.quality"),
      "ruler": easy.tr("astrology.zodiac.$zodiacKey.ruler"),
      "symbol": easy.tr("astrology.zodiac.$zodiacKey.symbol"),
      "dateRange": easy.tr("astrology.zodiac.$zodiacKey.dateRange"),
      "characteristics": easy.tr("astrology.zodiac.$zodiacKey.characteristics"),
      "color": easy.tr("astrology.zodiac.$zodiacKey.color"),
    };
  }

  // Sadece sembol almak için yardımcı metod
  String getZodiacSymbolByName(String zodiacName) {
    return getZodiacDetailsByName(zodiacName)['symbol'] ?? '';
  }
}
