class DailyHoroscope {
  final String date;
  final String horoscopeText;
  final double lovePercentage;
  final double careerPercentage;
  final double moneyPercentage;
  final Map<String, dynamic>? details;

  DailyHoroscope({
    required this.date,
    required this.horoscopeText,
    required this.lovePercentage,
    required this.careerPercentage,
    required this.moneyPercentage,
    this.details,
  });

  Map<String, dynamic> toMap() {
    return {
      'date': date,
      'horoscopeText': horoscopeText,
      'lovePercentage': lovePercentage,
      'careerPercentage': careerPercentage,
      'moneyPercentage': moneyPercentage,
      'details': details,
    };
  }

  factory DailyHoroscope.fromMap(Map<String, dynamic> map) {
    return DailyHoroscope(
      date: map['date'] ?? '',
      horoscopeText: map['horoscopeText'] ?? '',
      lovePercentage: (map['lovePercentage'] ?? 0.0).toDouble(),
      careerPercentage: (map['careerPercentage'] ?? 0.0).toDouble(),
      moneyPercentage: (map['moneyPercentage'] ?? 0.0).toDouble(),
      details: map['details'],
    );
  }
}
