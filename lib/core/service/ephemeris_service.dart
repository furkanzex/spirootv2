class EphemerisService {
  // Sabit değerler
  static const double MEAN_TROPICAL_YEAR = 365.242190;
  static const double J2000 = 2451545.0;

  static const List<double> ZODIAC_CUSPS = [
    0,
    30,
    60,
    90,
    120,
    150,
    180,
    210,
    240,
    270,
    300,
    330
  ];

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

  // Transit hesaplama
  static Map<String, Map<String, dynamic>> calculateCurrentTransits(
    DateTime birthDate,
    String birthTime,
    String birthPlace,
  ) {
    try {
      final days = _daysSinceJ2000(DateTime.now());

      // Gezegenlerin güncel konumlarını hesapla
      final transits = <String, Map<String, dynamic>>{};

      PLANET_DAILY_MOTION.forEach((planet, motion) {
        final position = _calculatePlanetPosition(planet, days);
        transits[planet] = {
          'position': position,
          'sign': getZodiacSign(position),
          'isRetrograde': _isCurrentlyRetrograde(planet, DateTime.now()),
        };
      });

      return transits;
    } catch (e) {
      print('Calculate current transits error: $e');
      // Hata durumunda boş map dön
      return <String, Map<String, dynamic>>{};
    }
  }

  // Burç hesaplama
  static String getZodiacSign(double degree) {
    final signIndex = (degree / 30).floor();
    final signs = [
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
    return signs[signIndex % 12];
  }

  // Açı hesaplama
  static Map<String, List<Map<String, dynamic>>> _calculatePlanetaryAspects(
    double position,
    Map<String, double> allPlanets,
  ) {
    final aspects = <String, List<Map<String, dynamic>>>{};

    final majorAspects = {
      'Conjunction': 0.0,
      'Sextile': 60.0,
      'Square': 90.0,
      'Trine': 120.0,
      'Opposition': 180.0,
    };

    allPlanets.forEach((otherPlanet, otherPosition) {
      final aspectList = <Map<String, dynamic>>[];

      majorAspects.forEach((aspectName, aspectAngle) {
        final orb = calculateOrb(position, otherPosition);
        if (isAspectActive(orb, aspectAngle)) {
          aspectList.add({
            'aspect': aspectName,
            'angle': aspectAngle,
            'orb': orb,
            'applying': isAspectApplying(position, otherPosition),
          });
        }
      });

      if (aspectList.isNotEmpty) {
        aspects[otherPlanet] = aspectList;
      }
    });

    return aspects;
  }

  // Açı hesaplama yardımcı metodları
  static double calculateOrb(double pos1, double pos2) {
    var diff = (pos1 - pos2).abs();
    if (diff > 180) diff = 360 - diff;
    return diff;
  }

  static bool isAspectActive(double orb, double aspectAngle) {
    final tolerance = aspectAngle == 0 ? 10.0 : 8.0;
    return (orb - aspectAngle).abs() <= tolerance;
  }

  static bool isAspectApplying(double pos1, double pos2) {
    return (pos1 - pos2 + 360) % 360 < 180;
  }

  // Retro hesaplama
  static bool _isCurrentlyRetrograde(String planet, DateTime date) {
    final retroPeriods = getRetroSchedule(planet, date.year);

    for (var period in retroPeriods) {
      if (period['start'] != null && period['end'] != null) {
        final start = period['start'] as DateTime;
        final end = period['end'] as DateTime;
        if (date.isAfter(start) && date.isBefore(end)) {
          return true;
        }
      }
    }

    return false;
  }

  // Retro takvimi
  static List<Map<String, DateTime>> getRetroSchedule(String planet, int year) {
    // 2024 yılı için örnek retro tarihleri
    final schedules = {
      'Mercury': [
        {'start': DateTime(2024, 4, 21), 'end': DateTime(2024, 5, 14)},
        {'start': DateTime(2024, 8, 23), 'end': DateTime(2024, 9, 15)},
        {'start': DateTime(2024, 12, 13), 'end': DateTime(2025, 1, 1)},
      ],
      'Venus': [
        {'start': DateTime(2024, 7, 22), 'end': DateTime(2024, 9, 3)},
      ],
      'Mars': [
        {'start': DateTime(2024, 12, 6), 'end': DateTime(2025, 2, 23)},
      ],
      // Diğer gezegenler için de benzer şekilde eklenebilir
    };

    return (schedules[planet] ?? []).cast<Map<String, DateTime>>();
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

    double jd = day +
        ((153 * m + 2) ~/ 5) +
        365 * y +
        (y ~/ 4) -
        (y ~/ 100) +
        (y ~/ 400) -
        32045.5;

    return jd;
  }

  static double _calculatePlanetPosition(String planet, double days) {
    double meanMotion = PLANET_DAILY_MOTION[planet]! * days;
    return meanMotion % 360;
  }

  // Mevcut sınıfa eklenecek metodlar

  // Chart rotasyonunu hesapla
  static double calculateChartRotation(
      DateTime birthDate, DateTime currentDate) {
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

  // Yaklaşan retroları hesapla
  static Future<Map<String, Map<String, dynamic>>> calculateUpcomingRetrogrades(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final retrogrades = <String, Map<String, dynamic>>{};

    // Retro olabilecek gezegenleri kontrol et
    final retroPlanets = [
      'Mercury',
      'Venus',
      'Mars',
      'Jupiter',
      'Saturn',
      'Uranus',
      'Neptune',
      'Pluto'
    ];

    for (var planet in retroPlanets) {
      final retroPeriods = getRetroSchedule(planet, startDate.year);

      for (var period in retroPeriods) {
        final start = period['start'] as DateTime;
        if (start.isAfter(startDate) && start.isBefore(endDate)) {
          final end = period['end'] as DateTime;
          retrogrades[planet] = {
            'startDate': start,
            'endDate': end,
            'duration': end.difference(start).inDays,
            'sign': getZodiacSign(
                _calculatePlanetPosition(planet, _daysSinceJ2000(start))),
          };
          break;
        }
      }
    }

    return retrogrades;
  }

  // Retro durumunu hesapla
  static double calculateRetrogradeStatus(String planet, double position) {
    // Şu anki tarihi al
    final now = DateTime.now();

    // Gezegenin retro durumunu kontrol et
    if (_isCurrentlyRetrograde(planet, now)) {
      return 1.0; // Retro
    }

    // Yaklaşan retro durumunu kontrol et
    final retroPeriods = getRetroSchedule(planet, now.year);
    for (var period in retroPeriods) {
      final start = period['start'] as DateTime;
      if (start.isAfter(now) && start.difference(now).inDays <= 7) {
        // Retro başlangıcına 7 gün veya daha az kaldıysa
        return 0.8; // Yaklaşan retro
      }
    }

    return 0.0; // Retro değil
  }
}
