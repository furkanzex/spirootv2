import 'dart:math';

import 'package:get/get.dart';
import 'package:spirootv2/model/astrology/daily_horoscope.dart';

class AstrologyController extends GetxController {
  final selectedDay = "TODAY".obs;
  final RxDouble zodiacRotation = 0.0.obs;

  final Map<String, Map<String, dynamic>> zodiacInfo = {
    "Koç": {
      "element": "Ateş",
      "quality": "Öncü",
      "ruler": "Mars",
      "symbol": "♈",
      "dateRange": "21 Mart - 19 Nisan",
      "characteristics": ["Lider", "Enerjik", "Cesur"],
      "color": "Kırmızı",
    },
    "Boğa": {
      "element": "Toprak",
      "quality": "Sabit",
      "ruler": "Venüs",
      "symbol": "♉",
      "dateRange": "20 Nisan - 20 Mayıs",
      "characteristics": ["Kararlı", "Güvenilir", "Sabırlı"],
      "color": "Yeşil",
    },
    "İkizler": {
      "element": "Hava",
      "quality": "Değişken",
      "ruler": "Merkür",
      "symbol": "♊",
      "dateRange": "21 Mayıs - 20 Haziran",
      "characteristics": ["İletişimci", "Meraklı", "Uyumlu"],
      "color": "Sarı",
    },
    "Yengeç": {
      "element": "Su",
      "quality": "Öncü",
      "ruler": "Ay",
      "symbol": "♋",
      "dateRange": "21 Haziran - 22 Temmuz",
      "characteristics": ["Duygusal", "Koruyucu", "Sezgisel"],
      "color": "Gümüş",
    },
    "Aslan": {
      "element": "Ateş",
      "quality": "Sabit",
      "ruler": "Güneş",
      "symbol": "♌",
      "dateRange": "23 Temmuz - 22 Ağustos",
      "characteristics": ["Yaratıcı", "Cömert", "Gururlu"],
      "color": "Altın",
    },
    "Başak": {
      "element": "Toprak",
      "quality": "Değişken",
      "ruler": "Merkür",
      "symbol": "♍",
      "dateRange": "23 Ağustos - 22 Eylül",
      "characteristics": ["Analitik", "Pratik", "Mükemmeliyetçi"],
      "color": "Kahverengi",
    },
    "Terazi": {
      "element": "Hava",
      "quality": "Öncü",
      "ruler": "Venüs",
      "symbol": "♎",
      "dateRange": "23 Eylül - 22 Ekim",
      "characteristics": ["Diplomatik", "Adil", "Sosyal"],
      "color": "Pembe",
    },
    "Akrep": {
      "element": "Su",
      "quality": "Sabit",
      "ruler": "Mars/Plüton",
      "symbol": "♏",
      "dateRange": "23 Ekim - 21 Kasım",
      "characteristics": ["Tutkulu", "Kararlı", "Gizemli"],
      "color": "Bordo",
    },
    "Yay": {
      "element": "Ateş",
      "quality": "Değişken",
      "ruler": "Jüpiter",
      "symbol": "♐",
      "dateRange": "22 Kasım - 21 Aralık",
      "characteristics": ["Maceracı", "İyimser", "Özgür"],
      "color": "Mor",
    },
    "Oğlak": {
      "element": "Toprak",
      "quality": "Öncü",
      "ruler": "Satürn",
      "symbol": "♑",
      "dateRange": "22 Aralık - 19 Ocak",
      "characteristics": ["Disiplinli", "Hırslı", "Sorumlu"],
      "color": "Siyah",
    },
    "Kova": {
      "element": "Hava",
      "quality": "Sabit",
      "ruler": "Uranüs/Satürn",
      "symbol": "♒",
      "dateRange": "20 Ocak - 18 Şubat",
      "characteristics": ["Yenilikçi", "Özgün", "İnsancıl"],
      "color": "Mavi",
    },
    "Balık": {
      "element": "Su",
      "quality": "Değişken",
      "ruler": "Neptün/Jüpiter",
      "symbol": "♓",
      "dateRange": "19 Şubat - 20 Mart",
      "characteristics": ["Sezgisel", "Sanatsal", "Şefkatli"],
      "color": "Turkuaz",
    },
  };

  final Map<String, DailyHoroscope> horoscopes = {
    "YESTERDAY": DailyHoroscope(
      date: "8 Mart 2024",
      essential: "Meditation, inner peace, reflection",
      affirmation: "I am at peace with myself and my surroundings",
      horoscopeText:
          "Yesterday was a day of deep introspection. You might have felt more connected to your spiritual side and found comfort in solitary activities.",
      lovePercentage: 0.65,
      careerPercentage: 0.45,
      moneyPercentage: 0.70,
    ),
    "TODAY": DailyHoroscope(
      date: "9 Mart 2024",
      essential: "Communication, creativity, social connections",
      affirmation: "I express myself freely and authentically",
      horoscopeText:
          "Today brings opportunities for meaningful conversations. Your creative energy is high, making it an excellent time for artistic pursuits or brainstorming sessions.",
      lovePercentage: 0.75,
      careerPercentage: 0.80,
      moneyPercentage: 0.60,
    ),
    "TOMORROW": DailyHoroscope(
      date: "10 Mart 2024",
      essential: "Growth, transformation, new beginnings",
      affirmation: "I embrace change and grow stronger each day",
      horoscopeText:
          "Tomorrow holds potential for significant personal growth. Be open to new opportunities and trust your intuition.",
      lovePercentage: 0.85,
      careerPercentage: 0.70,
      moneyPercentage: 0.65,
    ),
    "WEEK": DailyHoroscope(
      date: "9-15 Mart 2024",
      essential: "Balance, harmony, achievement",
      affirmation: "I create balance in all areas of my life",
      horoscopeText:
          "This week emphasizes finding balance between your personal and professional life. Focus on maintaining harmony while pursuing your goals.",
      lovePercentage: 0.80,
      careerPercentage: 0.75,
      moneyPercentage: 0.70,
    ),
    "MONTH": DailyHoroscope(
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

  DailyHoroscope get currentHoroscope => horoscopes[selectedDay.value]!;

  void changeDay(String day) {
    selectedDay.value = day;
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
    String sign = getZodiacSign(date);
    return zodiacInfo[sign] ?? {};
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
}
