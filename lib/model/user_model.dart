import 'package:cloud_firestore/cloud_firestore.dart';

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
  final String moonSign;
  final String ascendant;

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
    required this.moonSign,
    required this.ascendant,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'birthDate': Timestamp.fromDate(birthDate),
      'birthTime': birthTime,
      'birthPlace': birthPlace,
      'gender': {
        'key': gender,
      },
      'relationshipStatus': {
        'key': relationshipStatus,
      },
      'interests': interests
          .map((interest) => {
                'key': interest,
              })
          .toList(),
      'isProfileComplete': isProfileComplete,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'zodiacSign': zodiacSign,
      'moonSign': moonSign,
      'ascendant': ascendant,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      name: map['name'] ?? '',
      birthDate: (map['birthDate'] as Timestamp).toDate(),
      birthTime: map['birthTime'] ?? '',
      birthPlace: map['birthPlace'] ?? '',
      gender: map['gender']?['key'] ?? '',
      relationshipStatus: map['relationshipStatus']?['key'] ?? '',
      interests: List<String>.from(
          (map['interests'] ?? []).map((i) => i['key'] ?? '')),
      isProfileComplete: map['isProfileComplete'] ?? false,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
      zodiacSign: map['zodiacSign'] ?? '',
      moonSign: map['moonSign'] ?? '',
      ascendant: map['ascendant'] ?? '',
    );
  }
}
