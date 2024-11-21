class User {
  final String id;
  final String name;
  final DateTime birthDate;
  final String birthTime;
  final String birthPlace;
  final String gender;
  final String relationshipStatus;
  final String zodiacSign;
  final String moonSign;
  final String ascendant;
  final bool isProfileComplete;

  User({
    required this.id,
    required this.name,
    required this.birthDate,
    required this.birthTime,
    required this.birthPlace,
    required this.gender,
    required this.relationshipStatus,
    required this.zodiacSign,
    required this.moonSign,
    required this.ascendant,
    this.isProfileComplete = false,
  });

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      birthDate: map['birthDate']?.toDate() ?? DateTime.now(),
      birthTime: map['birthTime'] ?? '',
      birthPlace: map['birthPlace'] ?? '',
      gender: map['gender'] ?? '',
      relationshipStatus: map['relationshipStatus'] ?? '',
      zodiacSign: map['zodiacSign'] ?? '',
      moonSign: map['moonSign'] ?? '',
      ascendant: map['ascendant'] ?? '',
      isProfileComplete: map['isProfileComplete'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'birthDate': birthDate,
      'birthTime': birthTime,
      'birthPlace': birthPlace,
      'gender': gender,
      'relationshipStatus': relationshipStatus,
      'zodiacSign': zodiacSign,
      'moonSign': moonSign,
      'ascendant': ascendant,
      'isProfileComplete': isProfileComplete,
    };
  }
}
