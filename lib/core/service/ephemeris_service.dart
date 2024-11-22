import 'dart:math';
import 'package:intl/intl.dart';

class EphemerisService {
  // Gezegenler için sabit değerler
  static const double MEAN_TROPICAL_YEAR = 365.242190; // Tropical yıl
  static const double J2000 = 2451545.0; // Julian date for 2000-01-01 12:00 UT
  
  // Burç başlangıç dereceleri (0° Koç'tan başlayarak)
  static const List<double> ZODIAC_CUSPS = [
    0, 30, 60, 90, 120, 150, 180, 210, 240, 270, 300, 330
  ];

  // Gezegen hareketleri için ortalama günlük değerler (derece/gün)
  static const Map<String, double> PLANET_DAILY_MOTION = {
    'Sun': 0.9856473,
    'Moon': 13.1763581,
    'Mercury': 1.3824,
    'Venus': 1.6021302,
    'Mars': 0.5240207,
    'Jupiter': 0.0830853,
    'Saturn': 0.0334442,
    'Uranus': 0.0116943,
    'Neptune': 0.0059510,
    'Pluto': 0.0039470,
  };

  // Haftalık transit hesaplama
  static Map<String, double> calculateWeeklyTransits(DateTime birthDate, String birthTime, String birthPlace) {
    final now = DateTime.now();
    final transits = <String, double>{};
    
    // Doğum zamanından günümüze geçen gün sayısı
    final daysSinceJ2000 = _daysSinceJ2000(now);
    
    // Her gezegen için pozisyon hesapla
    PLANET_DAILY_MOTION.forEach((planet, dailyMotion) {
      // Gezegenin mevcut pozisyonunu hesapla
      double position = _calculatePlanetPosition(planet, daysSinceJ2000);
      transits[planet] = position;
    });

    return transits;
  }

  // Açı hesaplama (aspect calculation)
  static double calculateChartRotation(DateTime birthDate, DateTime currentDate) {
    // Doğum anından şimdiye kadar geçen süreyi hesapla
    final daysDiff = currentDate.difference(birthDate).inDays;
    
    // Precesyon etkisini hesapla (yaklaşık yıllık 50.3 açı saniyesi)
    final precessionEffect = (daysDiff / 365.25) * (50.3 / 3600);
    
    // Güneşin ilerleme açısını hesapla
    final solarProgression = (daysDiff * PLANET_DAILY_MOTION['Sun']!);
    
    // Toplam rotasyon açısı
    final totalRotation = (solarProgression + precessionEffect) % 360;
    
    return totalRotation;
  }

  // Yardımcı metodlar
  static double _daysSinceJ2000(DateTime date) {
    final julian = _dateToJulian(date);
    return julian - J2000;
  }

  static double _dateToJulian(DateTime date) {
    final year = date.year;
    final month = date.month;
    final day = date.day;
    
    int a = (14 - month) ~/ 12;
    int y = year + 4800 - a;
    int m = month + 12 * a - 3;
    
    double jd = day + ((153 * m + 2) ~/ 5) + 365 * y + (y ~/ 4) - (y ~/ 100) + 
                (y ~/ 400) - 32045.5;
    
    return jd;
  }

  static double _calculatePlanetPosition(String planet, double days) {
    // Basit linear hareket hesaplaması
    double meanMotion = PLANET_DAILY_MOTION[planet]! * days;
    
    // 360 derece içinde normalize et
    return meanMotion % 360;
  }
} 