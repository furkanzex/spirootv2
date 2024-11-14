import 'package:get/get.dart';
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
}
