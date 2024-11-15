import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:spirootv2/model/astrology/daily_horoscope.dart';

class AstrologyController extends GetxController {
  final selectedDay = "TODAY".obs;

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
      essential: "Fun activities, responsibilities, uniqueness",
      affirmation: "I am overcoming my obstacles",
      horoscopeText:
          "Tomorrow you may act more serious, focusing very little on fun activities. Do not force yourself...",
      lovePercentage: 0.73,
      careerPercentage: 0.55,
      moneyPercentage: 0.57,
    ),
    "WEEK": DailyHoroscope(
      date: "9-15 Mart 2024",
      essential: "Fun activities, responsibilities, uniqueness",
      affirmation: "I am overcoming my obstacles",
      horoscopeText:
          "Tomorrow you may act more serious, focusing very little on fun activities. Do not force yourself...",
      lovePercentage: 0.73,
      careerPercentage: 0.55,
      moneyPercentage: 0.57,
    ),
    "MONTH": DailyHoroscope(
      date: "Mart 2024",
      essential: "Fun activities, responsibilities, uniqueness",
      affirmation: "I am overcoming my obstacles",
      horoscopeText:
          "Tomorrow you may act more serious, focusing very little on fun activities. Do not force yourself...",
      lovePercentage: 0.73,
      careerPercentage: 0.55,
      moneyPercentage: 0.57,
    ),
  };

  DailyHoroscope get currentHoroscope => horoscopes[selectedDay.value]!;

  void changeDay(String day) {
    selectedDay.value = day;
    update();
  }

  // Burç hesaplamaları için yardımcı metodlar
  String getZodiacSign(DateTime date) {
    int month = date.month;
    int day = date.day;

    if ((month == 3 && day >= 21) || (month == 4 && day <= 19)) return "Koç";
    if ((month == 4 && day >= 20) || (month == 5 && day <= 20)) return "Boğa";
    if ((month == 5 && day >= 21) || (month == 6 && day <= 20))
      return "İkizler";
    if ((month == 6 && day >= 21) || (month == 7 && day <= 22)) return "Yengeç";
    if ((month == 7 && day >= 23) || (month == 8 && day <= 22)) return "Aslan";
    if ((month == 8 && day >= 23) || (month == 9 && day <= 22)) return "Başak";
    if ((month == 9 && day >= 23) || (month == 10 && day <= 22))
      return "Terazi";
    if ((month == 10 && day >= 23) || (month == 11 && day <= 21))
      return "Akrep";
    if ((month == 11 && day >= 22) || (month == 12 && day <= 21)) return "Yay";
    if ((month == 12 && day >= 22) || (month == 1 && day <= 19)) return "Oğlak";
    if ((month == 1 && day >= 20) || (month == 2 && day <= 18)) return "Kova";
    return "Balık";
  }

  double getZodiacRotation(DateTime date) {
    return (getZodiacIndex(date) * -30) * (pi / 180); // Her burç 30 derece
  }

  int getZodiacIndex(DateTime date) {
    int month = date.month;
    int day = date.day;

    if ((month == 3 && day >= 21) || (month == 4 && day <= 19)) return 0;
    if ((month == 4 && day >= 20) || (month == 5 && day <= 20)) return 1;
    if ((month == 5 && day >= 21) || (month == 6 && day <= 20)) return 2;
    if ((month == 6 && day >= 21) || (month == 7 && day <= 22)) return 3;
    if ((month == 7 && day >= 23) || (month == 8 && day <= 22)) return 4;
    if ((month == 8 && day >= 23) || (month == 9 && day <= 22)) return 5;
    if ((month == 9 && day >= 23) || (month == 10 && day <= 22)) return 6;
    if ((month == 10 && day >= 23) || (month == 11 && day <= 21)) return 7;
    if ((month == 11 && day >= 22) || (month == 12 && day <= 21)) return 8;
    if ((month == 12 && day >= 22) || (month == 1 && day <= 19)) return 9;
    if ((month == 1 && day >= 20) || (month == 2 && day <= 18)) return 10;
    return 11;
  }

  // Burç elementini döndür (Ateş, Toprak, Hava, Su)
  String getZodiacElement(DateTime date) {
    int index = getZodiacIndex(date);
    switch (index) {
      case 0:
      case 4:
      case 8:
        return "Ateş";
      case 1:
      case 5:
      case 9:
        return "Toprak";
      case 2:
      case 6:
      case 10:
        return "Hava";
      default:
        return "Su";
    }
  }

  // Burç niteliğini döndür (Öncü, Sabit, Değişken)
  String getZodiacQuality(DateTime date) {
    int index = getZodiacIndex(date);
    if (index % 3 == 0) return "Öncü";
    if (index % 3 == 1) return "Sabit";
    return "Değişken";
  }
}
