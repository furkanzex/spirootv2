class UserModel {
  final String uid;
  final String name;
  final DateTime birthDate;
  final String birthTime;
  final String birthPlace;
  final String gender;
  final String relationshipStatus;
  final List<String> interests;
  final bool isProfileComplete;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String zodiacSign;

  UserModel({
    required this.uid,
    required this.name,
    required this.birthDate,
    required this.birthTime,
    required this.birthPlace,
    required this.gender,
    required this.relationshipStatus,
    required this.interests,
    required this.isProfileComplete,
    required this.createdAt,
    required this.updatedAt,
    required this.zodiacSign,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'birthDate': birthDate,
      'birthTime': birthTime,
      'birthPlace': birthPlace,
      'gender': gender,
      'relationshipStatus': relationshipStatus,
      'interests': interests,
      'isProfileComplete': isProfileComplete,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'zodiacSign': zodiacSign,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'],
      name: map['name'],
      birthDate: map['birthDate'].toDate(),
      birthTime: map['birthTime'],
      birthPlace: map['birthPlace'],
      gender: map['gender'],
      relationshipStatus: map['relationshipStatus'] ?? '',
      interests: List<String>.from(map['interests']),
      isProfileComplete: map['isProfileComplete'],
      createdAt: map['createdAt'].toDate(),
      updatedAt: map['updatedAt'].toDate(),
      zodiacSign: map['zodiacSign'] ?? '',
    );
  }
}
