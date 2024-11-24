class ZodiacCompatibilityTable {
  static double getCompatibility(String sign1, String sign2) {
    // Burç uyum tablosu (0-100 arası değerler)
    final Map<String, Map<String, double>> compatibilityTable = {
      'aries': {
        'aries': 75.0,
        'taurus': 60.0,
        'gemini': 85.0,
        'cancer': 65.0,
        'leo': 90.0,
        'virgo': 55.0,
        'libra': 70.0,
        'scorpio': 80.0,
        'sagittarius': 95.0,
        'capricorn': 50.0,
        'aquarius': 85.0,
        'pisces': 65.0,
      },
      'taurus': {
        'aries': 60.0,
        'taurus': 90.0,
        'gemini': 55.0,
        'cancer': 85.0,
        'leo': 70.0,
        'virgo': 95.0,
        'libra': 80.0,
        'scorpio': 90.0,
        'sagittarius': 50.0,
        'capricorn': 95.0,
        'aquarius': 55.0,
        'pisces': 85.0,
      },
      'gemini': {
        'aries': 85.0,
        'taurus': 55.0,
        'gemini': 85.0,
        'cancer': 60.0,
        'leo': 90.0,
        'virgo': 75.0,
        'libra': 95.0,
        'scorpio': 60.0,
        'sagittarius': 85.0,
        'capricorn': 55.0,
        'aquarius': 95.0,
        'pisces': 65.0,
      },
      'cancer': {
        'aries': 65.0,
        'taurus': 85.0,
        'gemini': 60.0,
        'cancer': 85.0,
        'leo': 65.0,
        'virgo': 80.0,
        'libra': 70.0,
        'scorpio': 95.0,
        'sagittarius': 55.0,
        'capricorn': 80.0,
        'aquarius': 60.0,
        'pisces': 95.0,
      },
      'leo': {
        'aries': 90.0,
        'taurus': 70.0,
        'gemini': 90.0,
        'cancer': 65.0,
        'leo': 85.0,
        'virgo': 65.0,
        'libra': 90.0,
        'scorpio': 75.0,
        'sagittarius': 95.0,
        'capricorn': 60.0,
        'aquarius': 80.0,
        'pisces': 70.0,
      },
      'virgo': {
        'aries': 55.0,
        'taurus': 95.0,
        'gemini': 75.0,
        'cancer': 80.0,
        'leo': 65.0,
        'virgo': 85.0,
        'libra': 75.0,
        'scorpio': 85.0,
        'sagittarius': 60.0,
        'capricorn': 95.0,
        'aquarius': 70.0,
        'pisces': 80.0,
      },
      'libra': {
        'aries': 70.0,
        'taurus': 80.0,
        'gemini': 95.0,
        'cancer': 70.0,
        'leo': 90.0,
        'virgo': 75.0,
        'libra': 85.0,
        'scorpio': 75.0,
        'sagittarius': 85.0,
        'capricorn': 70.0,
        'aquarius': 90.0,
        'pisces': 75.0,
      },
      'scorpio': {
        'aries': 80.0,
        'taurus': 90.0,
        'gemini': 60.0,
        'cancer': 95.0,
        'leo': 75.0,
        'virgo': 85.0,
        'libra': 75.0,
        'scorpio': 90.0,
        'sagittarius': 65.0,
        'capricorn': 85.0,
        'aquarius': 65.0,
        'pisces': 95.0,
      },
      'sagittarius': {
        'aries': 95.0,
        'taurus': 50.0,
        'gemini': 85.0,
        'cancer': 55.0,
        'leo': 95.0,
        'virgo': 60.0,
        'libra': 85.0,
        'scorpio': 65.0,
        'sagittarius': 85.0,
        'capricorn': 65.0,
        'aquarius': 90.0,
        'pisces': 70.0,
      },
      'capricorn': {
        'aries': 50.0,
        'taurus': 95.0,
        'gemini': 55.0,
        'cancer': 80.0,
        'leo': 60.0,
        'virgo': 95.0,
        'libra': 70.0,
        'scorpio': 85.0,
        'sagittarius': 65.0,
        'capricorn': 85.0,
        'aquarius': 75.0,
        'pisces': 85.0,
      },
      'aquarius': {
        'aries': 85.0,
        'taurus': 55.0,
        'gemini': 95.0,
        'cancer': 60.0,
        'leo': 80.0,
        'virgo': 70.0,
        'libra': 90.0,
        'scorpio': 65.0,
        'sagittarius': 90.0,
        'capricorn': 75.0,
        'aquarius': 85.0,
        'pisces': 80.0,
      },
      'pisces': {
        'aries': 65.0,
        'taurus': 85.0,
        'gemini': 65.0,
        'cancer': 95.0,
        'leo': 70.0,
        'virgo': 80.0,
        'libra': 75.0,
        'scorpio': 95.0,
        'sagittarius': 70.0,
        'capricorn': 85.0,
        'aquarius': 80.0,
        'pisces': 90.0,
      },
    };

    // Burç isimlerini küçük harfe çevir
    final sign1Lower = sign1.toLowerCase();
    final sign2Lower = sign2.toLowerCase();

    // İlk burçtan ikinci burca olan uyumu al
    final compatibility1 = compatibilityTable[sign1Lower]?[sign2Lower];
    // İkinci burçtan ilk burca olan uyumu al
    final compatibility2 = compatibilityTable[sign2Lower]?[sign1Lower];

    // İki yönlü uyumun ortalamasını al
    if (compatibility1 != null && compatibility2 != null) {
      return (compatibility1 + compatibility2) / 2;
    }

    // Eğer uyum değeri bulunamazsa varsayılan değer döndür
    return 70.0;
  }

  // Element uyumlarını kontrol et
  static double getElementalCompatibility(String element1, String element2) {
    final Map<String, Map<String, double>> elementalCompatibility = {
      'fire': {
        'fire': 90.0,
        'earth': 60.0,
        'air': 85.0,
        'water': 65.0,
      },
      'earth': {
        'fire': 60.0,
        'earth': 85.0,
        'air': 65.0,
        'water': 90.0,
      },
      'air': {
        'fire': 85.0,
        'earth': 65.0,
        'air': 90.0,
        'water': 70.0,
      },
      'water': {
        'fire': 65.0,
        'earth': 90.0,
        'air': 70.0,
        'water': 95.0,
      },
    };

    return elementalCompatibility[element1]?[element2] ?? 70.0;
  }

  // Burçların elementlerini döndür
  static String getZodiacElement(String sign) {
    final Map<String, String> zodiacElements = {
      'aries': 'fire',
      'leo': 'fire',
      'sagittarius': 'fire',
      'taurus': 'earth',
      'virgo': 'earth',
      'capricorn': 'earth',
      'gemini': 'air',
      'libra': 'air',
      'aquarius': 'air',
      'cancer': 'water',
      'scorpio': 'water',
      'pisces': 'water',
    };

    return zodiacElements[sign.toLowerCase()] ?? 'unknown';
  }

  // Burçların niteliklerini döndür
  static String getZodiacQuality(String sign) {
    final Map<String, String> zodiacQualities = {
      'aries': 'cardinal',
      'cancer': 'cardinal',
      'libra': 'cardinal',
      'capricorn': 'cardinal',
      'taurus': 'fixed',
      'leo': 'fixed',
      'scorpio': 'fixed',
      'aquarius': 'fixed',
      'gemini': 'mutable',
      'virgo': 'mutable',
      'sagittarius': 'mutable',
      'pisces': 'mutable',
    };

    return zodiacQualities[sign.toLowerCase()] ?? 'unknown';
  }

  // Nitelik uyumlarını kontrol et
  static double getQualityCompatibility(String quality1, String quality2) {
    final Map<String, Map<String, double>> qualityCompatibility = {
      'cardinal': {
        'cardinal': 75.0,
        'fixed': 85.0,
        'mutable': 80.0,
      },
      'fixed': {
        'cardinal': 85.0,
        'fixed': 70.0,
        'mutable': 90.0,
      },
      'mutable': {
        'cardinal': 80.0,
        'fixed': 90.0,
        'mutable': 85.0,
      },
    };

    return qualityCompatibility[quality1]?[quality2] ?? 70.0;
  }
}
