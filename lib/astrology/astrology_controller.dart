import 'dart:math';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:spirootv2/astrology/daily_horoscope.dart';
import 'package:easy_localization/easy_localization.dart' as easy;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:spirootv2/core/constant/my_color.dart';
import 'package:spirootv2/core/service/gemini_service.dart';
import 'package:spirootv2/profile/user_controller.dart';

class AstrologyController extends GetxController {
  final RxDouble zodiacRotation = 0.0.obs;
  final RxString selectedDay = easy.tr("astrology.horoscope.dates.today").obs;
  final Rx<DailyHoroscope> selectedHoroscope = DailyHoroscope(
    date: DateTime.now().toString(),
    horoscopeText: "",
    lovePercentage: 0.0,
    careerPercentage: 0.0,
    moneyPercentage: 0.0,
  ).obs;

  final GeminiService _geminiService = Get.put(GeminiService());
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Yorum durumunu kontrol etmek için
  final RxBool isHoroscopeAvailable = false.obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    // onInit'te Future işlemi çalıştırmak için
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeHoroscope();
    });
  }

  Future<void> _initializeHoroscope() async {
    try {
      // Başlangıç değerini ayarla
      selectedDay.value = "astrology.horoscope.dates.today";

      // Bugünün yorumunu kontrol et
      await checkHoroscope(
          selectedDay.value.replaceAll("astrology.horoscope.dates.", ""));
    } catch (e) {
      print('Initialize Horoscope Error: $e');
    }
  }

  Future<void> checkHoroscope(String timeframe) async {
    try {
      isLoading.value = true;
      final userId = Get.find<UserController>().userId.value;
      final zodiacSign =
          Get.find<UserController>().currentUser.value?.zodiacSign ?? '';

      // timeframe'den "astrology.horoscope.dates." kısmını kaldır
      String cleanTimeframe =
          timeframe.replaceAll("astrology.horoscope.dates.", "");

      // Kullanıcı dökümanından yorumu kontrol et
      final doc = await _firestore.collection('users').doc(userId).get();

      if (doc.exists) {
        final interpretations = doc.data()?['interpretations'];
        if (interpretations != null &&
            interpretations[zodiacSign] != null &&
            interpretations[zodiacSign][cleanTimeframe] != null) {
          final interpretation = interpretations[zodiacSign][cleanTimeframe];
          final expiryDate = interpretation['expiryDate'].toDate();

          if (expiryDate.isAfter(DateTime.now())) {
            selectedHoroscope.value = DailyHoroscope.fromMap(interpretation);
            isHoroscopeAvailable.value = true;
          } else {
            isHoroscopeAvailable.value = false;
            // Süresi geçmiş yorumu otomatik oluştur
            await generateHoroscope();
          }
        } else {
          isHoroscopeAvailable.value = false;
        }
      } else {
        isHoroscopeAvailable.value = false;
      }
    } catch (e) {
      print('Horoscope check error: $e');
      isHoroscopeAvailable.value = false;
    } finally {
      isLoading.value = false;
      update();
    }
  }

  Future<void> generateHoroscope() async {
    try {
      isLoading.value = true;

      final user = Get.find<UserController>().currentUser.value;
      if (user == null) {
        throw Exception('Kullanıcı bilgisi bulunamadı');
      }

      // Gemini servisinden yorumu al
      final response =
          await _geminiService.generateHoroscope(selectedDay.value, user);

      // JSON'ı parse et ve horoscope nesnesini oluştur
      try {
        final jsonResponse = json.decode(response);
        final reading = jsonResponse['horoscope']['reading'];

        final horoscope = DailyHoroscope(
          date: DateTime.now().toString(),
          horoscopeText: reading['overview'],
          lovePercentage: reading['love']['percentage'] / 100,
          careerPercentage: reading['career']['percentage'] / 100,
          moneyPercentage: reading['money']['percentage'] / 100,
          details: {
            'love': reading['love'],
            'career': reading['career'],
            'money': reading['money'],
            'lucky': reading['lucky'],
          },
        );

        // Firestore'a kaydet
        await _saveHoroscopeToFirestore(horoscope);

        selectedHoroscope.value = horoscope;
        isHoroscopeAvailable.value = true;
      } catch (e) {
        print('JSON parse hatası: $e');
        throw Exception('Yorum formatı geçersiz');
      }
    } catch (e) {
      print('Horoscope generation error: $e');
      Get.snackbar(
        'Hata',
        'Kozmik mesaj oluşturulurken bir hata oluştu',
        backgroundColor: MyColor.errorColor,
        colorText: MyColor.white,
      );
    } finally {
      isLoading.value = false;
      update();
    }
  }

  Future<void> _saveHoroscopeToFirestore(DailyHoroscope horoscope) async {
    try {
      final userId = Get.find<UserController>().userId.value;
      final user = Get.find<UserController>().currentUser.value!;

      String cleanTimeframe =
          selectedDay.value.replaceAll("astrology.horoscope.dates.", "");

      final userRef = _firestore.collection('users').doc(userId);

      Map<String, dynamic> currentInterpretations =
          (await userRef.get()).data()?['interpretations'] ?? {};

      if (!currentInterpretations.containsKey(user.zodiacSign)) {
        currentInterpretations[user.zodiacSign] = {};
      }

      currentInterpretations[user.zodiacSign][cleanTimeframe] = {
        ...horoscope.toMap(),
        'expiryDate': DateTime.now().add(const Duration(days: 1)),
        'createdAt': DateTime.now(),
      };

      await userRef.update({
        'interpretations': currentInterpretations,
      });
    } catch (e) {
      print('Firestore save error: $e');
      throw Exception('Yorum kaydedilemedi');
    }
  }

  String _getDocumentId(String timeframe) {
    final now = DateTime.now();
    switch (timeframe) {
      case "astrology.horoscope.dates.today":
        return DateFormat('yyyy-MM-dd').format(now);
      case "astrology.horoscope.dates.week":
        int weekNumber =
            ((now.difference(DateTime(now.year, 1, 1)).inDays) / 7).ceil();
        return 'week-${now.year}-$weekNumber';
      case "astrology.horoscope.dates.month":
        return 'month-${now.year}-${now.month}';
      default:
        return DateFormat('yyyy-MM-dd').format(now);
    }
  }

  DateTime _calculateExpiryDate(String timeframe) {
    final now = DateTime.now();
    switch (timeframe) {
      case "astrology.horoscope.dates.today":
        return DateTime(now.year, now.month, now.day, 23, 59, 59);
      case "astrology.horoscope.dates.week":
        return now.add(Duration(days: 7 - now.weekday));
      case "astrology.horoscope.dates.month":
        return DateTime(now.year, now.month + 1, 0, 23, 59, 59);
      default:
        return now.add(const Duration(days: 1));
    }
  }

  void changeDay(String day) async {
    try {
      selectedDay.value = day;
      await checkHoroscope(day);
    } catch (e) {
      print('Change Day Error: $e');
    }
  }

  DailyHoroscope get currentHoroscope => selectedHoroscope.value;

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
    if ((month == 10 && day >= 23) || (month == 11 && day <= 21)) {
      return "scorpio";
    }
    if ((month == 11 && day >= 22) || (month == 12 && day <= 21)) {
      return "sagittarius";
    }
    if ((month == 12 && day >= 22) || (month == 1 && day <= 19)) {
      return "capricorn";
    }
    if ((month == 1 && day >= 20) || (month == 2 && day <= 18)) {
      return "aquarius";
    }
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
    if ((month == 4 && day >= 20) || (month == 5 && day <= 20)) {
      return 1; // Boğa
    }
    if ((month == 5 && day >= 21) || (month == 6 && day <= 20)) {
      return 2; // İkizler
    }
    if ((month == 6 && day >= 21) || (month == 7 && day <= 22)) {
      return 3; // Yengeç
    }
    if ((month == 7 && day >= 23) || (month == 8 && day <= 22)) {
      return 4; // Aslan
    }
    if ((month == 8 && day >= 23) || (month == 9 && day <= 22)) {
      return 5; // Başak
    }
    if ((month == 9 && day >= 23) || (month == 10 && day <= 22)) {
      return 6; // Terazi
    }
    if ((month == 10 && day >= 23) || (month == 11 && day <= 21)) {
      return 7; // Akrep
    }
    if ((month == 11 && day >= 22) || (month == 12 && day <= 21)) {
      return 8; // Yay
    }
    if ((month == 12 && day >= 22) || (month == 1 && day <= 19)) {
      return 9; // Oğlak
    }
    if ((month == 1 && day >= 20) || (month == 2 && day <= 18)) {
      return 10; // Kova
    }
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
