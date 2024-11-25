import 'dart:math';
import 'dart:convert';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:spirootv2/astrology/daily_horoscope.dart';
import 'package:easy_localization/easy_localization.dart' as easy;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:spirootv2/core/constant/my_color.dart';
import 'package:spirootv2/core/constant/my_size.dart';
import 'package:spirootv2/core/service/gemini_service.dart';
import 'package:spirootv2/profile/user_controller.dart';
import 'package:spirootv2/core/service/ephemeris_service.dart';
import 'package:spirootv2/astrology/compatibility_result_screen.dart';

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

  // Numeroloji ile ilgili değişkenler
  final RxMap<String, dynamic> numerologyReading = <String, dynamic>{}.obs;
  final RxBool isNumerologyAvailable = false.obs;

  // Mevcut sınıfa eklenecek yeni değişkenler
  final RxDouble chartRotation = 0.0.obs;
  final RxMap<String, double> weeklyTransits = <String, double>{}.obs;

  // Yeni değişkenler ekleyelim
  final RxMap<String, dynamic> retrogradeReadings = <String, dynamic>{}.obs;
  final RxBool isRetroReadingsAvailable = false.obs;

  // Yeni değişkenler ekleyelim
  final RxMap<String, Map<String, dynamic>> currentTransits =
      <String, Map<String, dynamic>>{}.obs;
  final RxMap<String, Map<String, dynamic>> upcomingRetrogrades =
      <String, Map<String, dynamic>>{}.obs;

  final RxMap<String, dynamic> weeklyNatalReading = <String, dynamic>{}.obs;
  final RxBool isWeeklyNatalAvailable = false.obs;

  final RxBool isSubscribed = false.obs;

  // Controller'a eklenecek yeni değişkenler
  final RxInt selectedFirstZodiac = 0.obs;
  final RxInt selectedSecondZodiac = 0.obs;

  final List<Map<String, String>> zodiacSigns = [
    {'name': 'sagittarius', 'date': 'Nov 22 - Dec 21'},
    {'name': 'capricorn', 'date': 'Dec 22 - Jan 19'},
    {'name': 'aquarius', 'date': 'Jan 20 - Feb 18'},
    {'name': 'pisces', 'date': 'Feb 19 - Mar 20'},
    {'name': 'aries', 'date': 'Mar 21 - Apr 19'},
    {'name': 'taurus', 'date': 'Apr 20 - May 20'},
    {'name': 'gemini', 'date': 'May 21 - Jun 20'},
    {'name': 'cancer', 'date': 'Jun 21 - Jul 22'},
    {'name': 'leo', 'date': 'Jul 23 - Aug 22'},
    {'name': 'virgo', 'date': 'Aug 23 - Sep 22'},
    {'name': 'libra', 'date': 'Sep 23 - Oct 22'},
    {'name': 'scorpio', 'date': 'Oct 23 - Nov 21'},
  ];

  final RxBool isInitialized = false.obs;
  final UserController _userController = Get.find<UserController>();

  @override
  void onInit() {
    super.onInit();
    _initializeController();
  }

  Future<void> _initializeController() async {
    try {
      // UserController'ın hazır olmasını bekle
      await Get.find<UserController>().initialized;

      // Kullanıcı ID'sini dinle
      ever(_userController.userId, (String userId) {
        if (userId.isNotEmpty && !isInitialized.value) {
          isInitialized.value = true;
          _initializeAstrologyPage();
        }
      });

      // Eğer kullanıcı ID'si zaten varsa, hemen yükle
      if (_userController.userId.value.isNotEmpty) {
        isInitialized.value = true;
        await _initializeAstrologyPage();
      } else {
        // Kullanıcı ID'si yoksa, bekleme moduna geç
        await _waitForUser();
      }
    } catch (e) {
      print('Initialize controller error: $e');
      _handleError('Uygulama başlatılırken bir hata oluştu');
    }
  }

  Future<void> _waitForUser() async {
    int attempts = 0;
    const maxAttempts = 10;
    const retryDelay = Duration(seconds: 2);

    while (attempts < maxAttempts && !isInitialized.value) {
      try {
        if (_userController.userId.value.isNotEmpty) {
          isInitialized.value = true;
          await _initializeAstrologyPage();
          return;
        }
        await Future.delayed(retryDelay);
        attempts++;
      } catch (e) {
        print('Wait for user error: $e');
      }
    }

    if (!isInitialized.value) {
      _handleError(
          'Kullanıcı bilgileri yüklenemedi. Lütfen uygulamayı yeniden başlatın.');
    }
  }

  void _handleError(String message) {
    Get.snackbar(
      'Hata',
      message,
      backgroundColor: MyColor.errorColor,
      colorText: MyColor.white,
      duration: const Duration(seconds: 5),
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  Future<void> _initializeAstrologyPage() async {
    if (!isInitialized.value) {
      await _waitForUser();
      return;
    }

    try {
      await Future.wait([
        _initializeHoroscope(),
        _checkNumerologyAndRetrogrades(),
        _initializeWeeklyChart(),
        _generateWeeklyNatalReading(),
      ]);
    } catch (e) {
      print('Initialize Astrology Page Error: $e');
      _handleError('Astroloji sayfası yüklenirken bir hata oluştu');
    }
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

  Future<void> _checkNumerologyAndRetrogrades() async {
    try {
      final userId = Get.find<UserController>().userId.value;
      final doc = await _firestore.collection('users').doc(userId).get();

      if (!doc.exists) return;

      final data = doc.data()!;
      await Future.wait([
        _checkExistingNumerology(data),
        _checkExistingRetrogrades(data),
      ]);
    } catch (e) {
      print('Check Numerology and Retrogrades Error: $e');
    }
  }

  Future<void> _checkExistingNumerology(Map<String, dynamic> userData) async {
    try {
      final numerology = userData['numerology'];
      if (numerology != null && numerology['expiryDate'] != null) {
        final expiryDate = (numerology['expiryDate'] as Timestamp).toDate();

        if (expiryDate.isAfter(DateTime.now())) {
          numerologyReading.value = {
            'weeklyReading': numerology['reading']['weeklyReading']
          };
          isNumerologyAvailable.value = true;
        } else {
          // Süresi dolmuş, yeni yorum oluştur ama gösterme
          await generateNumerologyReading();
        }
      } else {
        // Yorum yok, yeni yorum oluştur ama gösterme
        await generateNumerologyReading();
      }
    } catch (e) {
      print('Check Existing Numerology Error: $e');
    }
  }

  Future<void> _checkExistingRetrogrades(Map<String, dynamic> userData) async {
    try {
      final retrogrades = userData['retrogrades'];
      if (retrogrades != null && retrogrades['expiryDate'] != null) {
        final expiryDate = (retrogrades['expiryDate'] as Timestamp).toDate();

        if (expiryDate.isAfter(DateTime.now())) {
          // Mevcut retroları getir
          retrogradeReadings.value = retrogrades['readings'];
          isRetroReadingsAvailable.value = true;
        } else {
          // Süresi dolmuş, yeni retro yorumları oluştur
          await _generateAndSaveRetroReadings();
        }
      } else {
        // Retro yorumları yok, yeni oluştur
        await _generateAndSaveRetroReadings();
      }
    } catch (e) {
      print('Check Existing Retrogrades Error: $e');
    }
  }

  Future<void> _generateAndSaveRetroReadings() async {
    try {
      final user = Get.find<UserController>().currentUser.value;
      if (user == null) return;

      final now = DateTime.now();
      final weekEnd = now.add(const Duration(days: 7));

      // Gemini'den retro yorumlarını al
      final response = await _geminiService.generateRetroReadings(
        now,
        weekEnd,
        user.zodiacSign,
      );

      final jsonResponse = json.decode(response);
      retrogradeReadings.value = jsonResponse['retrogrades'];

      // Firebase'e kaydet
      await _saveRetroReadings(jsonResponse['retrogrades']);

      isRetroReadingsAvailable.value = true;
    } catch (e) {
      print('Generate and Save Retro Readings Error: $e');
    }
  }

  // Numeroloji yorumu oluşturma metodunu güncelle
  Future<void> generateNumerologyReading() async {
    try {
      final user = Get.find<UserController>().currentUser.value;
      if (user == null) throw Exception('Kullanıcı bilgisi bulunamadı');

      final lifePathNumber = calculateLifePathNumber(user.birthDate);
      final response =
          await _geminiService.generateNumerologyReading(lifePathNumber, user);

      final jsonResponse = json.decode(response);
      numerologyReading.value = {
        'weeklyReading': jsonResponse['numerology']['weeklyReading']
      };

      // Firebase'e kaydet
      await _saveNumerologyToFirestore(jsonResponse['numerology']);

      isNumerologyAvailable.value = true;
    } catch (e) {
      print('Numerology generation error: $e');
      isNumerologyAvailable.value = false;
    }
  }

  Future<void> _saveNumerologyToFirestore(
      Map<String, dynamic> numerology) async {
    try {
      final userId = Get.find<UserController>().userId.value;

      await _firestore.collection('users').doc(userId).update({
        'numerology': numerology,
      });
    } catch (e) {
      print('Numerology save error: $e');
    }
  }

  Future<void> _initializeWeeklyChart() async {
    try {
      final user = Get.find<UserController>().currentUser.value;
      if (user == null) return;

      // Firebase'den mevcut verileri kontrol et
      final userId = Get.find<UserController>().userId.value;
      final doc = await _firestore.collection('users').doc(userId).get();
      final weeklyChart = doc.data()?['weeklyChart'];

      if (weeklyChart != null && weeklyChart['validUntil'] != null) {
        final validUntil = (weeklyChart['validUntil'] as Timestamp).toDate();

        if (validUntil.isAfter(DateTime.now())) {
          // Mevcut verileri kullan
          chartRotation.value = weeklyChart['rotation'] ?? 0.0;
          currentTransits.value = Map<String, Map<String, dynamic>>.from(
              weeklyChart['currentTransits'] ?? {});
          upcomingRetrogrades.value = Map<String, Map<String, dynamic>>.from(
              weeklyChart['upcomingRetrogrades'] ?? {});
          return;
        }
      }

      // Yeni verileri hesapla
      // Chart rotasyonunu hesapla
      final rotation = EphemerisService.calculateChartRotation(
        user.birthDate,
        DateTime.now(),
      );
      chartRotation.value = rotation;

      // Güncel transitleri hesapla
      final transits = EphemerisService.calculateCurrentTransits(
        user.birthDate,
        user.birthTime,
        user.birthPlace,
      );
      currentTransits.value = transits;

      // Yaklaşan retroları hesapla
      final retros = await EphemerisService.calculateUpcomingRetrogrades(
        DateTime.now(),
        DateTime.now().add(const Duration(days: 7)),
      );
      upcomingRetrogrades.value = retros;

      // Firebase'e kaydet
      await _saveWeeklyChart();
    } catch (e) {}
  }

  Future<void> _saveWeeklyChart() async {
    try {
      final userId = Get.find<UserController>().userId.value;
      final Map<String, dynamic> transitData = {};

      // Map'i güvenli bir şekilde dönüştür
      currentTransits.forEach((key, value) {
        transitData[key] = value;
      });

      await _firestore.collection('users').doc(userId).update({
        'weeklyChart': {
          'rotation': chartRotation.value,
          'currentTransits': transitData,
          'upcomingRetrogrades': upcomingRetrogrades.toJson(),
          'updatedAt': DateTime.now(),
          'validUntil': DateTime.now().add(const Duration(days: 7)),
        }
      });
    } catch (e) {
      print('Weekly chart save error: $e');
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
    if (!isInitialized.value) {
      _handleError('Uygulama henüz başlatılmadı. Lütfen bekleyin.');
      return;
    }

    try {
      isLoading.value = true;

      final user = _userController.currentUser.value;
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
      _handleError('Yorum oluşturulurken bir hata oluştu');
    } finally {
      isLoading.value = false;
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

  // Yaşam Yolu Sayısını hesapla
  int calculateLifePathNumber(DateTime birthDate) {
    String dateStr = DateFormat('ddMMyyyy').format(birthDate);
    int sum = 0;

    // Tüm rakamları topla
    for (var digit in dateStr.split('')) {
      sum += int.parse(digit);
    }

    // Tek basamaklı sayı elde edene kadar toplamaya devam et
    while (sum > 9) {
      int newSum = 0;
      sum.toString().split('').forEach((digit) {
        newSum += int.parse(digit);
      });
      sum = newSum;
    }

    return sum;
  }

  // Retrogradları kontrol eden metod
  Future<void> _checkRetrogrades() async {
    try {
      final userId = Get.find<UserController>().userId.value;
      final doc = await _firestore.collection('users').doc(userId).get();

      if (doc.exists) {
        final retrogrades = doc.data()?['retrogrades'];
        if (retrogrades != null && retrogrades['expiryDate'] != null) {
          final expiryDate = (retrogrades['expiryDate'] as Timestamp).toDate();

          if (expiryDate.isAfter(DateTime.now())) {
            retrogradeReadings.value = retrogrades['readings'];
            isRetroReadingsAvailable.value = true;
          } else {
            await _generateRetroReadings();
          }
        } else {
          await _generateRetroReadings();
        }
      }
    } catch (e) {
      print('Retrograde check error: $e');
    }
  }

  // Retro yorumlarını oluşturan metod
  Future<void> _generateRetroReadings() async {
    try {
      final user = Get.find<UserController>().currentUser.value;
      if (user == null) return;

      final now = DateTime.now();
      final weekEnd = now.add(const Duration(days: 7));

      // Gemini'den retro yorumlarını al
      final response = await _geminiService.generateRetroReadings(
        now,
        weekEnd,
        user.zodiacSign,
      );

      final jsonResponse = json.decode(response);
      retrogradeReadings.value = jsonResponse['retrogrades'];

      // Firebase'e kaydet
      await _saveRetroReadings(jsonResponse['retrogrades']);

      isRetroReadingsAvailable.value = true;
    } catch (e) {
      print('Retrograde generation error: $e');
    }
  }

  // Retro yorumlarını Firebase'e kaydeden metod
  Future<void> _saveRetroReadings(Map<String, dynamic> readings) async {
    try {
      final userId = Get.find<UserController>().userId.value;

      await _firestore.collection('users').doc(userId).update({
        'retrogrades': {
          'readings': readings,
          'createdAt': DateTime.now(),
          'expiryDate': DateTime.now().add(const Duration(days: 7)),
        }
      });
    } catch (e) {
      print('Retrograde save error: $e');
    }
  }

  // Retrogradları kontrol etmek için yeni metodlar
  bool isRetrograde(String planet) {
    // Gezegenlerin retro durumunu kontrol eder
    final position = weeklyTransits[planet]!;
    final retroProb =
        EphemerisService.calculateRetrogradeStatus(planet, position);
    return retroProb > 0.5;
  }

  int get retrogradeCount {
    return weeklyTransits.keys.where((planet) => isRetrograde(planet)).length;
  }

  // Numeroloji kontrolü için public metod
  Future<void> checkNumerologyReading() async {
    try {
      isLoading.value = true;
      final userId = Get.find<UserController>().userId.value;
      final doc = await _firestore.collection('users').doc(userId).get();

      if (doc.exists) {
        final numerology = doc.data()?['numerology'];
        if (numerology != null && numerology['expiryDate'] != null) {
          final expiryDate = (numerology['expiryDate'] as Timestamp).toDate();

          if (expiryDate.isAfter(DateTime.now())) {
            numerologyReading.value = {
              'weeklyReading': numerology['reading']['weeklyReading']
            };
            isNumerologyAvailable.value = true;
          } else {
            // Süresi dolmuş, yeni yorum oluştur
            await generateNumerologyReading();
          }
        } else {
          // Yorum yok, yeni yorum oluştur
          await generateNumerologyReading();
        }
      }
    } catch (e) {
      print('Check Numerology Reading Error: $e');
      isNumerologyAvailable.value = false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _generateWeeklyNatalReading() async {
    try {
      final user = Get.find<UserController>().currentUser.value;
      if (user == null) return;

      // Son yorumun tarihini kontrol et
      final userId = Get.find<UserController>().userId.value;
      final doc = await _firestore.collection('users').doc(userId).get();

      bool needsNewReading = true;
      final natalData = doc.data()?['natal_readings'];

      if (natalData != null && natalData['expiryDate'] != null) {
        final expiryDate = (natalData['expiryDate'] as Timestamp).toDate();
        needsNewReading = DateTime.now().isAfter(expiryDate);
      }

      if (needsNewReading) {
        // Gemini'den yeni yorum al
        final response = await _geminiService.generateWeeklyNatalReading(
          user.birthDate,
          user.birthTime,
          user.birthPlace,
          user.zodiacSign,
          user.ascendant,
          user.moonSign,
        );

        final jsonResponse = json.decode(response);
        final readings = jsonResponse['weeklyNatalReading'];

        // Firebase'e kaydet
        await _firestore.collection('users').doc(userId).update({
          'natal_readings': {
            'readings': readings,
            'createdAt': DateTime.now(),
            'expiryDate': DateTime.now().add(const Duration(days: 7)),
          }
        });

        weeklyNatalReading.value = readings;
        isWeeklyNatalAvailable.value = true;
      } else {
        // Mevcut yorumu kullan
        weeklyNatalReading.value = natalData['readings'];
        isWeeklyNatalAvailable.value = true;
      }
    } catch (e) {
      print('Generate weekly natal reading error: $e');
      isWeeklyNatalAvailable.value = false;
    }
  }

  Future<void> _saveWeeklyNatalReading(Map<String, dynamic> reading) async {
    try {
      final userId = Get.find<UserController>().userId.value;

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('natal_readings')
          .add({
        'reading': reading,
        'createdAt': DateTime.now(),
        'expiryDate': DateTime.now().add(const Duration(days: 7)),
      });
    } catch (e) {
      print('Weekly natal reading save error: $e');
    }
  }

  Future<void> _checkSubscription() async {
    try {
      final userController = Get.find<UserController>();
      final userId = userController.userId.value;

      // userId'nin geçerli olduğundan emin olun
      if (userId.isEmpty) {
        print('User ID is empty');
        isSubscribed.value = false;
        return;
      }

      final doc = await _firestore.collection('users').doc(userId).get();

      if (!doc.exists) {
        print('User document does not exist');
        isSubscribed.value = false;
        return;
      }

      isSubscribed.value = doc.data()?['isSubscribed'] ?? false;

      // Generate readings based on subscription
      if (isSubscribed.value) {
        await _generateAllReadings();
      } else {
        await _generateDailyHoroscopeOnly();
      }
    } catch (e) {
      print('Subscription check error: $e');
      isSubscribed.value = false;
    }
  }

  void _setupAutoRefresh() {
    // Daily refresh at midnight
    Timer.periodic(const Duration(hours: 1), (timer) {
      final now = DateTime.now();
      if (now.hour == 0 && now.minute == 0) {
        _refreshDailyReadings();
      }
    });

    // Weekly refresh
    Timer.periodic(const Duration(days: 1), (timer) {
      final now = DateTime.now();
      if (now.weekday == DateTime.monday && now.hour == 0) {
        _refreshWeeklyReadings();
      }
    });

    // Monthly refresh
    Timer.periodic(const Duration(days: 1), (timer) {
      final now = DateTime.now();
      if (now.day == 1 && now.hour == 0) {
        _refreshMonthlyReadings();
      }
    });
  }

  Future<void> _generateAllReadings() async {
    try {
      // Günlük yorum
      await generateHoroscope();

      // Haftalık natal okuma
      await _generateWeeklyNatalReading();

      // Numeroloji okuması
      await generateNumerologyReading();

      // Retro yorumları
      await _generateRetroReadings();
    } catch (e) {
      print('Generate all readings error: $e');
    }
  }

  Future<void> _generateDailyHoroscopeOnly() async {
    try {
      await generateHoroscope();
    } catch (e) {
      print('Generate daily horoscope error: $e');
    }
  }

  Future<void> _refreshDailyReadings() async {
    try {
      if (isSubscribed.value) {
        // Günlük yorumu yenile
        selectedDay.value = "astrology.horoscope.dates.today";
        await generateHoroscope();
      }
    } catch (e) {
      print('Refresh daily readings error: $e');
    }
  }

  Future<void> _refreshWeeklyReadings() async {
    try {
      if (isSubscribed.value) {
        // Haftalık yorumları yenile
        await _generateWeeklyNatalReading();
        await _generateRetroReadings();
        await generateNumerologyReading();
      }
    } catch (e) {
      print('Refresh weekly readings error: $e');
    }
  }

  Future<void> _refreshMonthlyReadings() async {
    try {
      if (isSubscribed.value) {
        // Aylık yorumları yenile
        selectedDay.value = "astrology.horoscope.dates.month";
        await generateHoroscope();
      }
    } catch (e) {
      print('Refresh monthly readings error: $e');
    }
  }

  // Burç seçimi için metodlar
  void setFirstZodiac(int index) {
    selectedFirstZodiac.value = index;
  }

  void setSecondZodiac(int index) {
    selectedSecondZodiac.value = index;
  }

  // Uyumluluk kontrolü için metod
  Future<void> checkCompatibility(String type) async {
    try {
      isLoading.value = true;

      // Get selected zodiac signs
      final firstZodiac = zodiacSigns[selectedFirstZodiac.value]['name'];
      final secondZodiac = zodiacSigns[selectedSecondZodiac.value]['name'];

      // Show loading dialog
      Get.dialog(
        Center(
          child: Container(
            padding: const EdgeInsets.all(MySize.defaultPadding),
            decoration: BoxDecoration(
              color: MyColor.darkBackgroundColor,
              borderRadius: BorderRadius.circular(MySize.defaultRadius),
            ),
            child: const CircularProgressIndicator(),
          ),
        ),
        barrierDismissible: false,
      );

      // Generate compatibility reading using Gemini
      final response = await _geminiService.generateCompatibilityReading(
        firstZodiac!,
        secondZodiac!,
        type,
      );

      // Parse response
      final result = json.decode(response);

      // Close loading dialog
      Get.back();

      // Show result screen
      Get.to(() => CompatibilityResultScreen(
            result: result,
            firstZodiac: firstZodiac,
            secondZodiac: secondZodiac,
          ));
    } catch (e) {
      print('Compatibility check error: $e');
      Get.back(); // Close loading dialog
      Get.snackbar(
        'Hata',
        'Uyumluluk analizi yapılırken bir hata oluştu',
        backgroundColor: MyColor.errorColor,
        colorText: MyColor.white,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
