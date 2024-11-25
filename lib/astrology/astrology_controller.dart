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
    ever(_userController.userId, _onUserIdChanged);
    _initializeController();
  }

  void _onUserIdChanged(String userId) {
    if (userId.isNotEmpty && !isInitialized.value) {
      _initializeController();
    }
  }

  Future<void> _initializeController() async {
    try {
      isLoading.value = true;

      // UserController'ın hazır olmasını bekle
      await _userController.initialized;

      // Kullanıcı ID'sini kontrol et
      if (_userController.userId.value.isEmpty) {
        await _waitForUser();
        return;
      }

      // Kullanıcı bilgilerini kontrol et
      if (_userController.currentUser.value == null) {
        await _userController.loadUser(_userController.userId.value);
      }

      if (_userController.currentUser.value != null) {
        // Abonelik durumunu kontrol et
        await _checkSubscriptionStatus();

        // Temel astroloji verilerini yükle
        await _loadBasicAstrologyData();

        // Premium içerikleri kontrol et ve yükle/sil
        await _managePremiumContent();

        isInitialized.value = true;
      }
    } catch (e) {
      print('Initialize controller error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _waitForUser() async {
    int attempts = 0;
    const maxAttempts = 5;
    const retryDelay = Duration(seconds: 1);

    while (attempts < maxAttempts) {
      try {
        if (_userController.currentUser.value != null) {
          isInitialized.value = true;
          await _initializeAstrologyPage();
          return;
        }

        // Kullanıcı bilgilerini yeniden yüklemeyi dene
        if (_userController.userId.value.isNotEmpty) {
          await _userController.loadUser(_userController.userId.value);
          if (_userController.currentUser.value != null) {
            isInitialized.value = true;
            await _initializeAstrologyPage();
            return;
          }
        }

        await Future.delayed(retryDelay);
        attempts++;
      } catch (e) {
        print('Wait for user error: $e');
        await Future.delayed(retryDelay);
        attempts++;
      }
    }

    if (!isInitialized.value) {
      print(
          'Kullanıcı bilgileri yüklenemedi: Maksimum deneme sayısına ulaşıldı');
    }
  }

  void _handleError(String message) {
    try {
      // Get.context'in null olup olmadığını kontrol et
      if (Get.context != null && Get.isSnackbarOpen != true) {
        Get.snackbar(
          'Hata',
          message,
          backgroundColor: MyColor.errorColor,
          colorText: MyColor.white,
          duration: const Duration(seconds: 5),
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        // Context yoksa veya snackbar zaten açıksa sadece konsola yaz
        print('Hata: $message');
      }
    } catch (e) {
      print('Hata gösterme hatası: $e');
      print('Orijinal hata mesajı: $message');
    }
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
          retrogradeReadings.value = retrogrades['readings'];
          isRetroReadingsAvailable.value = true;
        } else {
          await _generateAndSaveRetroReadings();
        }
      } else {
        await _generateAndSaveRetroReadings();
      }
    } catch (e) {
      print('Check Existing Retrogrades Error: $e');
      await _generateAndSaveRetroReadings();
    }
  }

  Future<void> _generateAndSaveRetroReadings() async {
    try {
      final user = _userController.currentUser.value;
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
      _useDefaultRetroReadings();
    }
  }

  // Numeroloji yorumu oluşturma metodunu güncelle
  Future<void> generateNumerologyReading() async {
    if (!isSubscribed.value) return;

    try {
      isLoading.value = true;

      final user = _userController.currentUser.value;
      if (user == null) {
        throw Exception('Kullanıcı bilgisi bulunamadı');
      }

      final lifePathNumber = calculateLifePathNumber(user.birthDate);
      final response =
          await _geminiService.generateNumerologyReading(lifePathNumber, user);

      final jsonResponse = json.decode(response);
      final reading = jsonResponse['numerology'];

      // Firebase'e kaydet
      await _firestore
          .collection('users')
          .doc(_userController.userId.value)
          .update({
        'numerology': {
          'reading': reading,
          'createdAt': DateTime.now(),
          'expiryDate':
              DateTime.now().add(const Duration(days: 7)), // 7 günlük süre
        }
      });

      // Local state'i güncelle
      numerologyReading.value = {'weeklyReading': reading['weeklyReading']};
      isNumerologyAvailable.value = true;
    } catch (e) {
      print('Numerology generation error: $e');
      isNumerologyAvailable.value = false;
      _handleError('Numeroloji yorumu oluşturulurken bir hata oluştu');
    } finally {
      isLoading.value = false;
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

      // Map'i güvenli bir şekilde dönştür
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
    try {
      isLoading.value = true;

      final user = _userController.currentUser.value;
      if (user == null) {
        throw Exception('Kullanıcı bilgisi bulunamadı');
      }

      // Gemini servisinden yorumu al
      final response = await _geminiService.generateHoroscope(
        selectedDay.value,
        user,
      );

      // JSON'ı parse et ve horoscope nesnesini oluştur
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

      // Firebase'e kaydet
      await _saveHoroscopeToFirestore(horoscope);

      selectedHoroscope.value = horoscope;
      isHoroscopeAvailable.value = true;
    } catch (e) {
      print('Horoscope generation error: $e');
      isHoroscopeAvailable.value = false;
      _handleError('Yorum oluşturulurken bir hata oluştu');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _saveHoroscopeToFirestore(DailyHoroscope horoscope) async {
    try {
      final userId = _userController.userId.value;
      final user = _userController.currentUser.value!;
      final now = DateTime.now();

      // Günün sonuna kadar geçerli olacak şekilde ayarla
      final expiryDate = DateTime(now.year, now.month, now.day, 23, 59, 59);

      await _firestore.collection('users').doc(userId).update({
        'interpretations.${user.zodiacSign}.today': {
          ...horoscope.toMap(),
          'createdAt': now,
          'expiryDate': expiryDate,
        }
      });
    } catch (e) {
      print('Save horoscope error: $e');
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

  // Retro yorumlarını Firebase'e kaydet
  Future<void> _saveRetroReadings(Map<String, dynamic> readings) async {
    try {
      final userId = _userController.userId.value;
      final now = DateTime.now();

      await _firestore.collection('users').doc(userId).update({
        'retrogrades': {
          'readings': readings,
          'createdAt': now,
          'expiryDate': now.add(const Duration(days: 7)), // 7 günlük süre
          'lastUpdated': now,
        }
      });
    } catch (e) {
      print('Save retro readings error: $e');
    }
  }

  // Varsayılan retro verilerini kullan
  void _useDefaultRetroReadings() {
    try {
      final now = DateTime.now();
      final defaultRetroData = {
        'activePlanets': ['Mercury', 'Venus', 'Mars'],
        'readings': {
          'Mercury': {
            'period':
                '${DateFormat('dd MMM').format(now)} - ${DateFormat('dd MMM').format(now.add(const Duration(days: 21)))}',
            'sign': 'gemini',
            'impact':
                'İletişim ve teknoloji alanlarında dikkatli olunması gereken bir dönem.',
            'advice': 'Önemli kararlar almadan önce iki kez düşünün.',
          },
          'Venus': {
            'period':
                '${DateFormat('dd MMM').format(now)} - ${DateFormat('dd MMM').format(now.add(const Duration(days: 40)))}',
            'sign': 'libra',
            'impact':
                'İlişkiler ve finansal konularda yeniden değerlendirme zamanı.',
            'advice':
                'Büyük harcamalar ve ilişki kararları için acele etmeyin.',
          },
          'Mars': {
            'period':
                '${DateFormat('dd MMM').format(now)} - ${DateFormat('dd MMM').format(now.add(const Duration(days: 30)))}',
            'sign': 'aries',
            'impact': 'Enerji seviyelerinde dalgalanmalar yaşanabilir.',
            'advice':
                'Agresif davranışlardan kaçının, enerjinizi yapıcı projelere yönlendirin.',
          }
        }
      };

      retrogradeReadings.value = defaultRetroData;
      isRetroReadingsAvailable.value = true;
    } catch (e) {
      print('Use default retro readings error: $e');
    }
  }

  // Retrogradları kontrol etmek için yeni metodlar
  bool isRetrograde(String planet) {
    try {
      // Gezegenlerin retro durumunu kontrol eder
      final position = weeklyTransits[planet]!;
      return EphemerisService.calculateRetrogradeStatus(planet, position);
    } catch (e) {
      print('Retro durumu kontrol hatası: $e');
      return false;
    }
  }

  int get retrogradeCount {
    return weeklyTransits.keys.where((planet) => isRetrograde(planet)).length;
  }

  // Numeroloji kontrolü için public metod
  Future<void> checkNumerologyReading() async {
    try {
      isLoading.value = true;
      final userId = _userController.userId.value;
      final doc = await _firestore.collection('users').doc(userId).get();

      if (!doc.exists) {
        isNumerologyAvailable.value = false;
        return;
      }

      final numerology = doc.data()?['numerology'];
      bool needsNewReading = true;

      if (numerology != null && numerology['expiryDate'] != null) {
        final expiryDate = (numerology['expiryDate'] as Timestamp).toDate();

        // Mevcut yorum varsa ve süresi geçmemişse kullan
        if (expiryDate.isAfter(DateTime.now())) {
          numerologyReading.value = {
            'weeklyReading': numerology['reading']['weeklyReading']
          };
          isNumerologyAvailable.value = true;
          needsNewReading = false;
        }
      }

      // Yeni yorum oluşturma kontrolü
      if (needsNewReading && isSubscribed.value) {
        await generateNumerologyReading();
      } else if (!isSubscribed.value) {
        // Abonelik yoksa numeroloji verilerini temizle
        numerologyReading.clear();
        isNumerologyAvailable.value = false;
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
      // Abonelik kontrolü - Abone değilse hiçbir işlem yapma
      if (!isSubscribed.value) {
        isWeeklyNatalAvailable.value = false;
        weeklyNatalReading.clear();
        return;
      }

      final userId = _userController.userId.value;
      final doc = await _firestore.collection('users').doc(userId).get();
      final natalData = doc.data()?['weekly_natal'];

      bool needsNewReading = true;

      // Mevcut yorum ve son kullanma tarihi kontrolü
      if (natalData != null && natalData['expiryDate'] != null) {
        final expiryDate = (natalData['expiryDate'] as Timestamp).toDate();

        // Süresi geçmemişse mevcut yorumu kullan
        if (expiryDate.isAfter(DateTime.now())) {
          weeklyNatalReading.value = natalData['reading'];
          isWeeklyNatalAvailable.value = true;
          needsNewReading = false;
        }
      }

      // Yeni yorum oluşturma ihtiyacı varsa ve abonelik aktifse
      if (needsNewReading && isSubscribed.value) {
        await _generateWeeklyNatalReading();
      }
    } catch (e) {
      print('Load weekly natal reading error: $e');
      isWeeklyNatalAvailable.value = false;
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

  // Gezegen pozisyonlarını hesaplayan metotta
  Map<String, dynamic> calculatePlanetPosition(String planet) {
    try {
      double degree;
      int sign;
      bool isRetrograde;
      Map<String, dynamic> aspects = {}; // Varsayılan boş map

      switch (planet) {
        case 'Sun':
          degree = EphemerisService.calculateSunPosition();
          break;
        case 'Moon':
          degree = EphemerisService.calculateMoonPosition();
          break;
        default:
          degree = EphemerisService.calculatePlanetPosition(planet);
      }

      // Burç hesaplama (her burç 30 derece)
      sign = (degree / 30).floor() % 12;

      // Retro durumu kontrolü - bool değer döndüren metodu kullan
      isRetrograde = EphemerisService.calculateRetrogradeStatus(planet, degree);

      return {
        'degree': degree,
        'sign': sign,
        'isRetrograde': isRetrograde,
        'aspects': aspects // Aspects ekle
      };
    } catch (e) {
      print('Gezegen pozisyonu hesaplama hatası: $e');
      return {
        'degree': 0.0,
        'sign': 0,
        'isRetrograde': false,
        'aspects': {} // Hata durumunda boş map
      };
    }
  }

  // Abonelik durumunu kontrol et
  Future<void> _checkSubscriptionStatus() async {
    try {
      final userDoc = await _firestore
          .collection('users')
          .doc(_userController.userId.value)
          .get();

      isSubscribed.value = userDoc.data()?['isSubscribed'] ?? false;
    } catch (e) {
      print('Subscription check error: $e');
      isSubscribed.value = false;
    }
  }

  // Premium içerikleri yönet
  Future<void> _managePremiumContent() async {
    try {
      final userRef =
          _firestore.collection('users').doc(_userController.userId.value);

      if (!isSubscribed.value) {
        // Premium içerikleri sil
        await _deletePremiumContent(userRef);
      } else {
        // Premium içerikleri yükle (eğer yoksa)
        await loadPremiumContent();
      }
    } catch (e) {
      print('Premium content management error: $e');
    }
  }

  // Premium içerikleri sil
  Future<void> _deletePremiumContent(DocumentReference userRef) async {
    try {
      // Natal grafik yorumlarını sil
      await userRef.collection('natalChartReadings').get().then((snapshot) {
        for (var doc in snapshot.docs) {
          doc.reference.delete();
        }
      });

      // Diğer premium içerikleri sıfırla
      weeklyNatalReading.clear();
      isWeeklyNatalAvailable.value = false;
    } catch (e) {
      print('Delete premium content error: $e');
    }
  }

  // Temel astroloji verilerini yükle
  Future<void> _loadBasicAstrologyData() async {
    try {
      await Future.wait([
        _loadContentWithExpiry('daily_horoscope', _loadDailyHoroscope),
        _loadContentWithExpiry('current_transits', _loadCurrentTransits),
        _loadRetroReadings(),
      ]);
    } catch (e) {
      print('Load basic astrology data error: $e');
    }
  }

  // Günlük yorum yükleme
  Future<void> _loadDailyHoroscope() async {
    try {
      selectedDay.value = "astrology.horoscope.dates.today";
      final userId = _userController.userId.value;
      final doc = await _firestore.collection('users').doc(userId).get();

      if (!doc.exists) return;

      final interpretations = doc.data()?['interpretations'];
      final zodiacSign = _userController.currentUser.value?.zodiacSign;

      if (zodiacSign == null) return;

      bool needsNewReading = true;

      // Mevcut yorumu kontrol et
      if (interpretations != null && 
          interpretations[zodiacSign] != null && 
          interpretations[zodiacSign]['today'] != null) {
        final interpretation = interpretations[zodiacSign]['today'];
        final expiryDate = (interpretation['expiryDate'] as Timestamp).toDate();

        // Süresi geçmemişse mevcut yorumu kullan
        if (expiryDate.isAfter(DateTime.now())) {
          selectedHoroscope.value = DailyHoroscope.fromMap(interpretation);
          isHoroscopeAvailable.value = true;
          needsNewReading = false;
        }
      }

      // Yeni yorum oluşturma ihtiyacı varsa
      if (needsNewReading) {
        await generateHoroscope();
      }
    } catch (e) {
      print('Load daily horoscope error: $e');
      isHoroscopeAvailable.value = false;
    }
  }

  // Transit verilerini yükle
  Future<void> _loadCurrentTransits() async {
    try {
      final user = _userController.currentUser.value;
      if (user == null) return;

      final transits = EphemerisService.calculateCurrentTransits(
        user.birthDate,
        user.birthTime,
        user.birthPlace,
      );
      currentTransits.value = transits;
    } catch (e) {
      print('Load current transits error: $e');
    }
  }

  // Retro okumalarını yükle - 7 günlük kontrol ile
  Future<void> _loadRetroReadings() async {
    try {
      final userId = _userController.userId.value;
      final doc = await _firestore.collection('users').doc(userId).get();
      final retrogrades = doc.data()?['retrogrades'];

      bool needsNewReadings = true;

      if (retrogrades != null && retrogrades['expiryDate'] != null) {
        final expiryDate = (retrogrades['expiryDate'] as Timestamp).toDate();

        // Mevcut yorumlar varsa ve süresi geçmemişse kullan
        if (expiryDate.isAfter(DateTime.now())) {
          retrogradeReadings.value = retrogrades['readings'];
          isRetroReadingsAvailable.value = true;
          needsNewReadings = false;
        }
      }

      // Yorum yoksa veya süresi geçmişse yeni yorum oluştur
      if (needsNewReadings) {
        await _generateAndSaveRetroReadings();
      }
    } catch (e) {
      print('Load retro readings error: $e');
      // Hata durumunda varsayılan verileri kullan
      _useDefaultRetroReadings();
    }
  }

  // Premium içerikleri yükle
  Future<void> loadPremiumContent() async {
    if (!isSubscribed.value) return;

    try {
      await Future.wait([
        _loadContentWithExpiry('daily_horoscope', _loadDailyHoroscope),
        _loadContentWithExpiry('weekly_horoscope', _loadWeeklyHoroscope),
        _loadContentWithExpiry('monthly_horoscope', _loadMonthlyHoroscope),
        _loadContentWithExpiry('weekly_natal', _loadWeeklyNatalReading),
        _loadContentWithExpiry('current_transits', _loadCurrentTransits),
        _loadContentWithExpiry('retro_readings', _loadRetroReadings),
        _loadContentWithExpiry('numerology', _loadNumerologyReading),
      ]);
    } catch (e) {
      print('Load premium content error: $e');
    }
  }

  // Haftalık yorum yükleme
  Future<void> _loadWeeklyHoroscope() async {
    try {
      selectedDay.value = "astrology.horoscope.dates.week";
      await checkHoroscope(selectedDay.value);
    } catch (e) {
      print('Load weekly horoscope error: $e');
    }
  }

  // Aylık yorum yükleme
  Future<void> _loadMonthlyHoroscope() async {
    try {
      selectedDay.value = "astrology.horoscope.dates.month";
      await checkHoroscope(selectedDay.value);
    } catch (e) {
      print('Load monthly horoscope error: $e');
    }
  }

  // Numeroloji okuması yükleme
  Future<void> _loadNumerologyReading() async {
    try {
      await checkNumerologyReading();
    } catch (e) {
      print('Load numerology reading error: $e');
    }
  }

  // Haftalık natal okuma yükleme
  Future<void> _loadWeeklyNatalReading() async {
    try {
      // Abonelik kontrolü
      if (!isSubscribed.value) {
        isWeeklyNatalAvailable.value = false;
        weeklyNatalReading.clear();
        return;
      }

      final userId = _userController.userId.value;
      final doc = await _firestore.collection('users').doc(userId).get();
      final natalData = doc.data()?['weekly_natal'];

      bool needsNewReading = true;

      // Mevcut yorum ve son kullanma tarihi kontrolü
      if (natalData != null && natalData['expiryDate'] != null) {
        final expiryDate = (natalData['expiryDate'] as Timestamp).toDate();

        // Süresi geçmemişse mevcut yorumu kullan
        if (expiryDate.isAfter(DateTime.now())) {
          weeklyNatalReading.value = natalData['reading'];
          isWeeklyNatalAvailable.value = true;
          needsNewReading = false;
        }
      }

      // Yeni yorum oluşturma ihtiyacı varsa ve abonelik aktifse
      if (needsNewReading && isSubscribed.value) {
        await _generateWeeklyNatalReading();
      }
    } catch (e) {
      print('Load weekly natal reading error: $e');
      isWeeklyNatalAvailable.value = false;
    }
  }

  // İçerik yükleme ve son kullanma tarihi kontrolü
  Future<void> _loadContentWithExpiry(
    String contentType,
    Future<void> Function() loadFunction,
  ) async {
    try {
      final userDoc = await _firestore
          .collection('users')
          .doc(_userController.userId.value)
          .get();

      final contentData = userDoc.data()?[contentType];
      bool needsRefresh = true;

      if (contentData != null && contentData['expiryDate'] != null) {
        final expiryDate = (contentData['expiryDate'] as Timestamp).toDate();
        if (expiryDate.isAfter(DateTime.now())) {
          needsRefresh = false;
        }
      }

      if (needsRefresh) {
        await loadFunction();
        // Yeni son kullanma tarihi ayarla
        await _updateExpiryDate(contentType);
      }
    } catch (e) {
      print('Load content with expiry error for $contentType: $e');
    }
  }

  // Son kullanma tarihini güncelle
  Future<void> _updateExpiryDate(String contentType) async {
    try {
      final now = DateTime.now();
      DateTime expiryDate;

      // İçerik tipine göre son kullanma tarihi belirle
      switch (contentType) {
        case 'daily_horoscope':
          expiryDate = DateTime(now.year, now.month, now.day, 23, 59, 59);
          break;
        case 'weekly_horoscope':
        case 'weekly_natal':
        case 'retro_readings':
          expiryDate = now.add(const Duration(days: 7));
          break;
        case 'monthly_horoscope':
          expiryDate = DateTime(now.year, now.month + 1, 1)
              .subtract(const Duration(seconds: 1));
          break;
        default:
          expiryDate = now.add(const Duration(days: 1));
      }

      await _firestore
          .collection('users')
          .doc(_userController.userId.value)
          .update({
        '$contentType.expiryDate': Timestamp.fromDate(expiryDate),
      });
    } catch (e) {
      print('Update expiry date error for $contentType: $e');
    }
  }
}
