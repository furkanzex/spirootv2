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
import 'package:spirootv2/core/extension/string_extension.dart';
import 'package:firebase_auth/firebase_auth.dart';

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

  // Biyoritim için yeni değişkenler ekleyelim
  final RxMap<String, dynamic> biorhythmReading = <String, dynamic>{}.obs;
  final RxBool isBiorhythmAvailable = false.obs;

  // Retro durumu için yeni değişkenler
  final RxBool hasRetrogrades = false.obs;
  final RxList<Map<String, dynamic>> activeRetrogrades =
      <Map<String, dynamic>>[].obs;

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
      _userController.initialized;

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

        // Biyoritim yorumunu kontrol et
        if (isSubscribed.value) {
          await checkBiorhythmReading();
        }

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
        checkWeeklyNatalReading(),
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

  Future<void> _checkExistingRetrogrades(Map<String, dynamic> data) async {
    try {
      // Kullanıcının dökümanından retrogrades verilerini al
      if (data.containsKey('retrogrades') &&
          data['retrogrades'] != null &&
          data['retrogrades']['readings'] != null) {
        final retroData = data['retrogrades'];
        final readings = retroData['readings'] as Map<String, dynamic>;

        // Süre kontrolü
        final expiryDate = (retroData['expiryDate'] as Timestamp).toDate();
        if (expiryDate.isAfter(DateTime.now())) {
          hasRetrogrades.value = readings['hasRetrogrades'] ?? false;
          if (readings['retrogrades'] != null) {
            activeRetrogrades.clear();
            activeRetrogrades.addAll(
                List<Map<String, dynamic>>.from(readings['retrogrades']));
          }
        } else {
          hasRetrogrades.value = false;
          activeRetrogrades.clear();
        }
      } else {
        hasRetrogrades.value = false;
        activeRetrogrades.clear();
      }
    } catch (e) {
      print('Retrogrades kontrol hatası: $e');
      hasRetrogrades.value = false;
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
        user: user,
        currentTransits: currentTransits,
      );

      // Yanıtı kontrol et ve state'i güncelle
      if (response['retrogrades'] != null && response['retrogrades'] is List) {
        final retroList =
            List<Map<String, dynamic>>.from(response['retrogrades']);

        if (retroList.isNotEmpty) {
          // Retro var
          hasRetrogrades.value = true;
          activeRetrogrades.value = retroList;

          // Firebase'e kaydet
          await _saveRetroReadings({
            'hasRetrogrades': true,
            'retrogrades': retroList,
          });
        } else {
          // Retro yok
          hasRetrogrades.value = false;
          activeRetrogrades.clear();

          // Firebase'e boş kaydet
          await _saveRetroReadings({
            'hasRetrogrades': false,
            'retrogrades': [],
          });
        }
      }

      print(
          'Retro state güncellendi - hasRetrogrades: ${hasRetrogrades.value}, activeRetrogrades: ${activeRetrogrades.length}');
    } catch (e) {
      print('Generate and Save Retro Readings Error: $e');
      hasRetrogrades.value = false;
      activeRetrogrades.clear();
    }
  }

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
    } catch (e) {
      print('Weekly chart initialization error: $e');
    }
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
          final now = DateTime.now();
          final today = DateTime(now.year, now.month, now.day);

          // Eğer son kullanma tarihi bugünden büyükse yorumu kullan
          if (expiryDate.isAfter(today)) {
            selectedHoroscope.value = DailyHoroscope.fromMap(interpretation);
            isHoroscopeAvailable.value = true;
          } else {
            isHoroscopeAvailable.value = false;
            // Süresi geçmiş yorumu otomatik oluştur
            await generateHoroscope(cleanTimeframe);
          }
        } else {
          isHoroscopeAvailable.value = false;
          // Yorum yoksa yeni yorum oluştur
          await generateHoroscope(cleanTimeframe);
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

  Future<void> generateHoroscope([String? timeframe]) async {
    try {
      isLoading.value = true;

      final user = _userController.currentUser.value;
      if (user == null) {
        throw Exception('Kullanıcı bilgisi bulunamadı');
      }

      // Timeframe parametresi verilmemişse selectedDay'den al
      final currentTimeframe = timeframe ??
          selectedDay.value.replaceAll("astrology.horoscope.dates.", "");

      // Premium kontrolü - Günlük yorum değilse ve premium değilse oluşturma
      if (currentTimeframe != "today" && !isSubscribed.value) {
        isHoroscopeAvailable.value = false;
        return;
      }

      // Tarih aralığını belirle
      final now = DateTime.now();
      String dateRange;
      switch (currentTimeframe) {
        case "today":
          dateRange = DateFormat('dd MMMM yyyy').format(now);
          break;
        case "week":
          final weekEnd = now.add(const Duration(days: 7));
          dateRange =
              "${DateFormat('dd MMMM').format(now)} - ${DateFormat('dd MMMM yyyy').format(weekEnd)}";
          break;
        case "month":
          dateRange = DateFormat('MMMM yyyy').format(now);
          break;
        default:
          dateRange = DateFormat('dd MMMM yyyy').format(now);
      }

      // Zaman dilimine göre özel prompt oluştur
      String customPrompt;
      switch (currentTimeframe) {
        case "today":
          customPrompt = '''
          $dateRange tarihi için günlük burç yorumu oluştur.
          Bugünün gezegen konumlarını ve açılarını dikkate al.
          Yorum kısa ve öz olmalı, günlük aktiviteler için tavsiyeler içermeli.
          ''';
          break;
        case "week":
          customPrompt = '''
          $dateRange tarihleri arası için haftalık burç yorumu oluştur.
          Bu haftaki önemli gezegen hareketlerini ve Ay fazlarını dikkate al.
          Yorum daha detaylı olmalı, haftanın önemli günlerini belirtmeli.
          Hafta boyunca dikkat edilmesi gereken konuları vurgula.
          ''';
          break;
        case "month":
          customPrompt = '''
          $dateRange ayı için aylık burç yorumu oluştur.
          Bu aydaki tüm önemli astrolojik olayları dikkate al.
          Retrogradları, Yeni Ay ve Dolunay etkilerini, önemli gezegen geçişlerini içermeli.
          Ay boyunca yaşanacak değişimleri ve fırsatları detaylı açıkla.
          Uzun vadeli planlar için tavsiyelerde bulun.
          ''';
          break;
        default:
          customPrompt = "$dateRange tarihi için günlük burç yorumu oluştur.";
      }

      // Gemini servisinden yorumu al
      final response = await _geminiService.generateHoroscope(
        selectedDay.value,
        user,
        customPrompt,
      );

      // JSON yanıtını temizle ve parse et
      String cleanJson = response.trim();
      if (!cleanJson.startsWith('{')) {
        final startIndex = cleanJson.indexOf('{');
        if (startIndex != -1) {
          cleanJson = cleanJson.substring(startIndex);
        }
      }
      if (!cleanJson.endsWith('}')) {
        final endIndex = cleanJson.lastIndexOf('}') + 1;
        if (endIndex > 0) {
          cleanJson = cleanJson.substring(0, endIndex);
        }
      }

      // JSON'ı parse et
      final jsonResponse = json.decode(cleanJson);
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
      await _saveHoroscopeToFirestore(horoscope, currentTimeframe);

      selectedHoroscope.value = horoscope;
      isHoroscopeAvailable.value = true;

      // Natal Chart yorumu kontrolü ve oluşturma
      if (isSubscribed.value && currentTimeframe != "today") {
        await _generateAndSaveNatalReading(currentTimeframe);
      }
    } catch (e) {
      print('Horoscope generation error: $e');
      isHoroscopeAvailable.value = false;
      _handleError('Yorum oluşturulurken bir hata oluştu');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _saveHoroscopeToFirestore(
      DailyHoroscope horoscope, String timeframe) async {
    try {
      final userId = _userController.userId.value;
      final user = _userController.currentUser.value!;
      final now = DateTime.now();

      // Zaman dilimine göre son kullanma tarihini ayarla
      DateTime expiryDate;
      switch (timeframe) {
        case "today":
          // Günün sonunu değil, bir sonraki günün başlangıcını baz al
          expiryDate = DateTime(now.year, now.month, now.day + 1);
          break;
        case "week":
          expiryDate = now.add(const Duration(days: 7));
          break;
        case "month":
          expiryDate = DateTime(now.year, now.month + 1, 1);
          break;
        default:
          expiryDate = DateTime(now.year, now.month, now.day + 1);
      }

      // Sadece ilgili yorumu güncelle, diğerlerine dokunma
      await _firestore.collection('users').doc(userId).set({
        'interpretations': {
          user.zodiacSign: {
            timeframe: {
              ...horoscope.toMap(),
              'createdAt': now,
              'expiryDate': expiryDate,
            }
          }
        }
      }, SetOptions(merge: true)); // merge: true ile mevcut verileri koru
    } catch (e) {
      print('Save horoscope error: $e');
      throw Exception('Yorum kaydedilemedi');
    }
  }

  void changeDay(String day) async {
    try {
      // Eğer zaten yükleme yapılıyorsa çık
      if (isLoading.value) return;

      // Seçili günü güncelle
      selectedDay.value = day;

      // Önce mevcut yorumu kontrol et
      final userId = _userController.userId.value;
      final zodiacSign = _userController.currentUser.value?.zodiacSign ?? '';
      final cleanTimeframe = day.replaceAll("astrology.horoscope.dates.", "");

      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        final interpretations = doc.data()?['interpretations'];
        if (interpretations != null &&
            interpretations[zodiacSign] != null &&
            interpretations[zodiacSign][cleanTimeframe] != null) {
          final interpretation = interpretations[zodiacSign][cleanTimeframe];
          final expiryDate = interpretation['expiryDate'].toDate();

          // Yorum varsa ve süresi geçmemişse, direkt onu kullan
          if (expiryDate.isAfter(DateTime.now())) {
            selectedHoroscope.value = DailyHoroscope.fromMap(interpretation);
            isHoroscopeAvailable.value = true;
            return;
          }
        }
      }

      // Yorum yoksa veya süresi geçmişse yeni yorum oluştur
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
    try {
      // Doğum saatini de dahil et
      final utcBirthTime = DateTime(
        birthDateTime.year,
        birthDateTime.month,
        birthDateTime.day,
        birthDateTime.hour,
        birthDateTime.minute,
      ).toUtc();

      final daysSinceJ2000 = EphemerisService.daysSinceJ2000(utcBirthTime);

      // Ay'ın günlük hareketi yaklaşık 13.2 derece
      final hoursSinceMidnight =
          birthDateTime.hour + (birthDateTime.minute / 60);
      final dailyMotion = EphemerisService.PLANET_DAILY_MOTION['Moon']!;
      final hourlyMotion = dailyMotion / 24;

      final moonPosition =
          EphemerisService.calculatePlanetPosition('Moon', daysSinceJ2000) +
              (hourlyMotion * hoursSinceMidnight);

      return EphemerisService.getZodiacSign(moonPosition);
    } catch (e) {
      print('Ay burcu hesaplama hatası: $e');
      return getZodiacSign(birthDateTime);
    }
  }

  String getAscendant(DateTime birthDateTime, String birthPlace) {
    try {
      final coordinates = _getCoordinatesFromPlace(birthPlace);
      if (coordinates == null) {
        throw Exception('Doğum yeri koordinatları bulunamadı');
      }

      // Doğum saatini UTC'ye çevir
      final utcBirthTime = DateTime(
        birthDateTime.year,
        birthDateTime.month,
        birthDateTime.day,
        birthDateTime.hour,
        birthDateTime.minute,
      ).toUtc();

      // RAMC (Right Ascension of Midheaven) hesapla
      final lst =
          _calculateSiderealTime(utcBirthTime, coordinates['longitude']!);
      final ramc = lst * 0.997269566; // Sidereal/Solar ratio

      // Yükselen derecesini hesapla
      final ascendantDegree =
          _calculateAscendantDegree(ramc, coordinates['latitude']!);

      return EphemerisService.getZodiacSign(ascendantDegree);
    } catch (e) {
      print('Yükselen burç hesaplama hatası: $e');
      return getZodiacSign(birthDateTime);
    }
  }

  double _calculateAscendantDegree(double siderealTime, double latitude) {
    try {
      // Yükselen burç formülü
      final tanA = -cos(siderealTime * pi / 180) /
          (sin(latitude * pi / 180) * tan(23.4367 * pi / 180) +
              sin(siderealTime * pi / 180) * cos(latitude * pi / 180));

      var ascendant = atan(tanA) * 180 / pi;

      // Kadranı düzelt
      if (cos(siderealTime * pi / 180) > 0) {
        ascendant += 180;
      }
      if (ascendant < 0) {
        ascendant += 360;
      }

      return ascendant % 360;
    } catch (e) {
      print('Yükselen derece hesaplama hatası: $e');
      return 0.0;
    }
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

  String getZodiacSymbolByName(String zodiacName) {
    return getZodiacDetailsByName(zodiacName)['symbol'] ?? '';
  }

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

  Future<void> _saveRetroReadings(Map<String, dynamic> readings) async {
    try {
      final userId = _userController.userId.value;
      final now = DateTime.now();

      // Debug için kaydedilecek veriyi yazdır
      print('Firebase\'e kaydedilecek retro verisi: $readings');

      // Firebase'e kaydet
      await _firestore.collection('users').doc(userId).set({
        'retrogrades': {
          'readings': readings,
          'createdAt': now,
          'expiryDate': now.add(const Duration(days: 7)),
          'lastUpdated': now,
        }
      }, SetOptions(merge: true));

      print('Retro verileri Firebase\'e kaydedildi');
    } catch (e) {
      print('Retro kayıt hatası: $e');
      _handleError('Retro kayıt hatası: $e');
    }
  }

  bool isRetrograde(String planet) {
    try {
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

  Future<void> checkNumerologyReading() async {
    try {
      if (!isSubscribed.value) {
        isNumerologyAvailable.value = false;
        numerologyReading.clear();
        return;
      }

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
      }
    } catch (e) {
      print('Check Numerology Reading Error: $e');
      isNumerologyAvailable.value = false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> checkWeeklyNatalReading() async {
    try {
      isLoading.value = true;

      // Premium kontrolü
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

      // Yeni yorum oluşturma ihtiyac varsa
      if (needsNewReading) {
        final user = _userController.currentUser.value!;
        final natalReading = await _geminiService.generateWeeklyNatalReading(
          user.birthDate,
          user.birthTime,
          user.birthPlace,
          user.zodiacSign,
          user.ascendant,
          user.moonSign,
        );

        final jsonResponse = json.decode(natalReading);
        weeklyNatalReading.value = jsonResponse['weeklyNatalReading'];
        isWeeklyNatalAvailable.value = true;

        // Firebase'e kaydet
        await _firestore.collection('users').doc(userId).update({
          'weekly_natal': {
            'reading': jsonResponse['weeklyNatalReading'],
            'createdAt': DateTime.now(),
            'expiryDate': DateTime.now().add(const Duration(days: 7)),
          }
        });
      }
    } catch (e) {
      print('Weekly natal reading error: $e');
      isWeeklyNatalAvailable.value = false;
    } finally {
      isLoading.value = false;
    }
  }

  void setFirstZodiac(int index) {
    selectedFirstZodiac.value = index;
  }

  void setSecondZodiac(int index) {
    selectedSecondZodiac.value = index;
  }

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

  Map<String, dynamic> calculatePlanetPosition(String planet) {
    try {
      double degree;
      int sign;
      bool isRetrograde;
      Map<String, dynamic> aspects = {};

      // Şu anki tarihi al
      final now = DateTime.now();
      EphemerisService.daysSinceJ2000(now);

      switch (planet) {
        case 'Sun':
          degree = EphemerisService.calculateSunPosition();
          isRetrograde = false; // Güneş asla retro olmaz
          break;
        case 'Moon':
          degree = EphemerisService.calculateMoonPosition();
          isRetrograde = false; // Ay asla retro olmaz
          break;
        default:
          degree = EphemerisService.calculateSimplePlanetPosition(planet);
          // Retro durumunu kontrol et
          final retroPeriods =
              EphemerisService.getRetroSchedule(planet, now.year);
          isRetrograde = retroPeriods.any((period) {
            final start = period['start'] as DateTime;
            final end = period['end'] as DateTime;
            return now.isAfter(start) && now.isBefore(end);
          });
      }

      // Burç hesaplama (her burç 30 derece)
      sign = (degree / 30).floor() % 12;

      return {
        'degree': degree,
        'sign': sign,
        'isRetrograde': isRetrograde,
        'aspects': aspects,
        'hasRetro': isRetrograde // Widget kontrolü için ek alan
      };
    } catch (e) {
      print('Gezegen pozisyonu hesaplama hatası: $e');
      return {
        'degree': 0.0,
        'sign': 0,
        'isRetrograde': false,
        'aspects': {},
        'hasRetro': false
      };
    }
  }

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

  Future<void> _deletePremiumContent(DocumentReference userRef) async {
    try {
      final user = _userController.currentUser.value;
      if (user == null) return;

      // Haftalık ve aylık yorumları sil
      await userRef.update({
        'interpretations.${user.zodiacSign}.week': FieldValue.delete(),
        'interpretations.${user.zodiacSign}.month': FieldValue.delete(),
      });

      // Natal grafik yorumlarını sil
      await userRef.collection('natalChartReadings').get().then((snapshot) {
        for (var doc in snapshot.docs) {
          doc.reference.delete();
        }
      });

      // Numeroloji yorumlarını sil
      await userRef.update({
        'numerology': FieldValue.delete(),
      });

      // Local state'i temizle
      weeklyNatalReading.clear();
      isWeeklyNatalAvailable.value = false;
      numerologyReading.clear();
      isNumerologyAvailable.value = false;

      // Horoscope state'ini güncelle
      selectedDay.value = "astrology.horoscope.dates.today";
      await checkHoroscope(selectedDay.value);
    } catch (e) {
      print('Delete premium content error: $e');
    }
  }

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

  Future<void> _loadRetroReadings() async {
    try {
      final userId = _userController.userId.value;
      final doc = await _firestore.collection('users').doc(userId).get();
      final retrogrades = doc.data()?['retrogrades'];

      bool needsNewReadings = true;

      if (retrogrades != null && retrogrades['expiryDate'] != null) {
        final expiryDate = (retrogrades['expiryDate'] as Timestamp).toDate();

        if (expiryDate.isAfter(DateTime.now())) {
          retrogradeReadings.value = retrogrades['readings'];
          isRetroReadingsAvailable.value = true;
          needsNewReadings = false;
        }
      }

      if (needsNewReadings) {
        await _generateAndSaveRetroReadings();
      }
    } catch (e) {
      print('Load retro readings error: $e');
    }
  }

  Future<void> loadPremiumContent() async {
    if (!isSubscribed.value) return;

    try {
      isLoading.value = true;

      await Future.wait([
        _loadDailyHoroscope(),
        _loadWeeklyHoroscope(),
        _loadMonthlyHoroscope(),
        _loadWeeklyNatalReading(),
        _loadNumerologyReading(),
        _loadRetroReadings(),
      ]);
    } catch (e) {
      print('Load premium content error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _loadWeeklyHoroscope() async {
    try {
      selectedDay.value = "astrology.horoscope.dates.week";
      await checkHoroscope(selectedDay.value);

      // Yorum yoksa veya süresi geçmişse yeni yorum oluştur
      if (!isHoroscopeAvailable.value) {
        await generateHoroscope('weekly');
      }
    } catch (e) {
      print('Load weekly horoscope error: $e');
    }
  }

  Future<void> _loadMonthlyHoroscope() async {
    try {
      selectedDay.value = "astrology.horoscope.dates.month";
      await checkHoroscope(selectedDay.value);

      // Yorum yoksa veya süresi geçmişse yeni yorum oluştur
      if (!isHoroscopeAvailable.value) {
        await generateHoroscope('monthly');
      }
    } catch (e) {
      print('Load monthly horoscope error: $e');
    }
  }

  Future<void> _loadNumerologyReading() async {
    try {
      await checkNumerologyReading();

      // Yorum yoksa veya süresi geçmişse yeni yorum oluştur
      if (!isNumerologyAvailable.value) {
        await generateNumerologyReading();
      }
    } catch (e) {
      print('Load numerology reading error: $e');
    }
  }

  Future<void> _loadWeeklyNatalReading() async {
    try {
      final userId = _userController.userId.value;
      final doc = await _firestore.collection('users').doc(userId).get();
      final natalData = doc.data()?['weekly_natal'];

      bool needsNewReading = true;

      if (natalData != null && natalData['expiryDate'] != null) {
        final expiryDate = (natalData['expiryDate'] as Timestamp).toDate();

        if (expiryDate.isAfter(DateTime.now())) {
          weeklyNatalReading.value = natalData['reading'];
          isWeeklyNatalAvailable.value = true;
          needsNewReading = false;
        }
      }

      // Yeni yorum oluşturma ihtiyacı varsa
      if (needsNewReading) {
        await checkWeeklyNatalReading();
      }
    } catch (e) {
      print('Load weekly natal reading error: $e');
      isWeeklyNatalAvailable.value = false;
    }
  }

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

  Future<void> _generateAndSaveNatalReading(String timeframe) async {
    try {
      final user = _userController.currentUser.value!;
      final natalReading = await _geminiService.generateWeeklyNatalReading(
        user.birthDate,
        user.birthTime,
        user.birthPlace,
        user.zodiacSign,
        user.ascendant,
        user.moonSign,
      );

      final jsonResponse = json.decode(natalReading);
      weeklyNatalReading.value = jsonResponse['weeklyNatalReading'];
      isWeeklyNatalAvailable.value = true;

      // Firebase'e kaydet
      await _firestore
          .collection('users')
          .doc(_userController.userId.value)
          .update({
        'weekly_natal': {
          'reading': jsonResponse['weeklyNatalReading'],
          'createdAt': DateTime.now(),
          'expiryDate': DateTime.now().add(const Duration(days: 7)),
        }
      });
    } catch (e) {
      print('Generate natal reading error: $e');
      isWeeklyNatalAvailable.value = false;
    }
  }

  Map<String, double>? _getCoordinatesFromPlace(String birthPlace) {
    try {
      // Türkiye'deki büyük şehirler için koordinatlar
      final coordinates = {
        'İstanbul': {'latitude': 41.0082, 'longitude': 28.9784},
        'Ankara': {'latitude': 39.9334, 'longitude': 32.8597},
        'İzmir': {'latitude': 38.4237, 'longitude': 27.1428},
        'Bursa': {'latitude': 40.1885, 'longitude': 29.0610},
        'Antalya': {'latitude': 36.8969, 'longitude': 30.7133},
        'Adana': {'latitude': 37.0000, 'longitude': 35.3213},
        'Gaziantep': {'latitude': 37.0662, 'longitude': 37.3833},
        'Konya': {'latitude': 37.8714, 'longitude': 32.4846},
        'Mersin': {'latitude': 36.8121, 'longitude': 34.6339},
        'Diyarbakır': {'latitude': 37.9144, 'longitude': 40.2306},
      };

      final place = birthPlace.split(',')[0].trim().toLowerCase();
      final cityCoords = coordinates[place.toTitleCase()];

      if (cityCoords != null) {
        return {
          'latitude': cityCoords['latitude']!,
          'longitude': cityCoords['longitude']!,
        };
      }

      // Varsayılan olarak İstanbul koordinatlarını döndür
      return {'latitude': 41.0082, 'longitude': 28.9784};
    } catch (e) {
      print('Koordinat çevirme hatası: $e');
      return null;
    }
  }

  double _calculateSiderealTime(DateTime utcTime, double longitude) {
    try {
      final daysSinceJ2000 = EphemerisService.daysSinceJ2000(utcTime);

      final gst = (100.46061837 +
              (36000.770053608 * daysSinceJ2000 / 36525.0) +
              (0.000387933 * pow(daysSinceJ2000 / 36525.0, 2)) -
              (pow(daysSinceJ2000 / 36525.0, 3) / 38710000.0)) %
          360;

      final lst = (gst + longitude) % 360;
      return lst;
    } catch (e) {
      print('Sidereal zaman hesaplama hatası: $e');
      return 0.0;
    }
  }

  // Biyoritim yorumu kontrolü
  Future<void> checkBiorhythmReading() async {
    try {
      final userId = _userController.userId.value;
      final doc = await _firestore.collection('users').doc(userId).get();
      final biorhythmData = doc.data()?['biorhythm_reading'];

      bool needsNewReading = true;

      if (biorhythmData != null && biorhythmData['expiryDate'] != null) {
        final expiryDate = (biorhythmData['expiryDate'] as Timestamp).toDate();

        if (expiryDate.isAfter(DateTime.now())) {
          biorhythmReading.value = biorhythmData['reading'];
          isBiorhythmAvailable.value = true;
          needsNewReading = false;
        }
      }

      if (needsNewReading) {
        await generateBiorhythmReading();
      }
    } catch (e) {
      print('Check biorhythm reading error: $e');
      isBiorhythmAvailable.value = false;
    }
  }

  // Biyoritim yorumu oluşturma
  Future<void> generateBiorhythmReading() async {
    try {
      isLoading.value = true;
      final user = _userController.currentUser.value!;
      final reading = await _geminiService.generateBiorhythmReading(
        user.birthDate,
        user.name,
      );

      final jsonResponse = json.decode(reading);
      biorhythmReading.value = jsonResponse['biorhythmReading'];
      isBiorhythmAvailable.value = true;

      // Firebase'e kaydet
      await _firestore
          .collection('users')
          .doc(_userController.userId.value)
          .update({
        'biorhythm_reading': {
          'reading': jsonResponse['biorhythmReading'],
          'createdAt': DateTime.now(),
          'expiryDate': DateTime.now().add(const Duration(days: 1)),
        }
      });
    } catch (e) {
      print('Generate biorhythm reading error: $e');
      isBiorhythmAvailable.value = false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> checkRetrogrades() async {
    try {
      isLoading.value = true;
      final user = _userController.currentUser.value;
      if (user == null) return;

      final doc = await _firestore
          .collection('users')
          .doc(_userController.userId.value)
          .get();

      final retroData = doc.data()?['retrogrades'];
      final now = DateTime.now();

      // Debug için veriyi yazdır
      print('Firebase\'den gelen retro verisi: $retroData');

      // Mevcut retro verilerini kontrol et
      if (retroData != null && retroData['readings'] != null) {
        final expiryDate = (retroData['expiryDate'] as Timestamp).toDate();

        // Veriler güncel mi kontrol et
        if (expiryDate.isAfter(now)) {
          final readings = retroData['readings'] as Map<String, dynamic>;

          // Debug için readings verisini yazdır
          print('Mevcut readings verisi: $readings');

          if (readings['hasRetrogrades'] != null) {
            hasRetrogrades.value = readings['hasRetrogrades'];
            if (readings['retrogrades'] != null) {
              activeRetrogrades.value =
                  List<Map<String, dynamic>>.from(readings['retrogrades']);
            }
            print(
                'Cache\'den retro durumu güncellendi - hasRetrogrades: ${hasRetrogrades.value}, activeRetrogrades: ${activeRetrogrades.length}');
            return;
          }
        }
      }

      // Yeni retro verilerini oluştur
      final weekEnd = now.add(const Duration(days: 7));

      // Önce transit pozisyonlarını güncelle
      await _loadCurrentTransits();

      print('Transit pozisyonları güncellendi: $currentTransits');

      // Retro hesaplamalarını yap
      final response = await _geminiService.generateRetroReadings(
        now,
        weekEnd,
        user.zodiacSign,
        user: user,
        currentTransits: currentTransits,
      );

      // Debug için response verisini yazdır
      print('Gemini\'den gelen retro yanıtı: $response');

      // Firebase'e kaydet
      await _saveRetroReadings(response);

      // State'i güncelle
      _updateRetroState(response);

      print(
          'Retro durumu güncellendi - hasRetrogrades: ${hasRetrogrades.value}, activeRetrogrades: ${activeRetrogrades.length}');
    } catch (e) {
      print('Retro kontrol hatası: $e');
      hasRetrogrades.value = false;
      activeRetrogrades.clear();
    } finally {
      isLoading.value = false;
    }
  }

  void _updateRetroState(Map<String, dynamic> data) {
    try {
      // Debug için gelen veriyi yazdır
      print('_updateRetroState\'e gelen veri: $data');

      // hasRetrogrades değerini güncelle
      hasRetrogrades.value = data['hasRetrogrades'] ?? false;
      print('hasRetrogrades değeri güncellendi: ${hasRetrogrades.value}');

      // Retrogrades listesini güncelle
      if (data['retrogrades'] != null && data['retrogrades'] is List) {
        final retroList = List<Map<String, dynamic>>.from(data['retrogrades']);
        activeRetrogrades.value = retroList;

        // Liste boş değilse hasRetrogrades'i true yap
        if (retroList.isNotEmpty) {
          hasRetrogrades.value = true;
        }

        print('Retro listesi güncellendi - uzunluk: ${retroList.length}');

        // Her bir retrograd için detayları yazdır
        for (var retro in retroList) {
          print('Retrograd Gezegen: ${retro['planet']}');
          print('Burç: ${retro['sign']}');
          print('Derece: ${retro['degree']}');
          print('Başlangıç: ${retro['startDate']}');
          print('Bitiş: ${retro['endDate']}');
          if (retro['shadowPeriod'] != null) {
            print(
                'Gölge Periyodu - Öncesi: ${retro['shadowPeriod']['preRetrograde']}');
            print(
                'Gölge Periyodu - Sonrası: ${retro['shadowPeriod']['postRetrograde']}');
          }
        }
      } else {
        activeRetrogrades.clear();
        print('Retro listesi boş veya hatalı format');
      }
    } catch (e) {
      print('Retro state güncelleme hatası: $e');
      hasRetrogrades.value = false;
      activeRetrogrades.clear();
    }
  }

  Future<void> saveRetroData(Map<String, dynamic> retroData) async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) throw Exception('Kullanıcı girişi yapılmamış');

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('retrogrades')
          .add({
        ...retroData,
        'timestamp': FieldValue.serverTimestamp(),
      });

      print('Retro verileri Firebase\'e kaydedildi');
    } catch (e) {
      print('Save retro data error: $e');
      throw Exception('Retro verileri kaydedilemedi');
    }
  }
}
