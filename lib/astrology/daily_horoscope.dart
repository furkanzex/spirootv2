class DailyHoroscope {
  final String date;
  final String essential;
  final String affirmation;
  final String horoscopeText;
  final double lovePercentage;
  final double careerPercentage;
  final double moneyPercentage;

  DailyHoroscope({
    required this.date,
    required this.essential,
    required this.affirmation,
    required this.horoscopeText,
    required this.lovePercentage,
    required this.careerPercentage,
    required this.moneyPercentage,
  });

  // Firebase'den veriyi modele dönüştür
  factory DailyHoroscope.fromMap(Map<String, dynamic> map) {
    return DailyHoroscope(
      date: map['date'] ?? '',
      essential: map['essential'] ?? '',
      affirmation: map['affirmation'] ?? '',
      horoscopeText: map['horoscopeText'] ?? '',
      lovePercentage: (map['lovePercentage'] ?? 0.0).toDouble(),
      careerPercentage: (map['careerPercentage'] ?? 0.0).toDouble(),
      moneyPercentage: (map['moneyPercentage'] ?? 0.0).toDouble(),
    );
  }

  // Modeli Firebase'e kaydetmek için Map'e dönüştür
  Map<String, dynamic> toMap() {
    return {
      'date': date,
      'essential': essential,
      'affirmation': affirmation,
      'horoscopeText': horoscopeText,
      'lovePercentage': lovePercentage,
      'careerPercentage': careerPercentage,
      'moneyPercentage': moneyPercentage,
    };
  }
}
