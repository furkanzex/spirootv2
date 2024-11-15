class UserModel {
  final String uid;
  final String name;
  final DateTime birthDate;
  final String birthTime;
  final String birthPlace;
  final String relationshipStatus;
  final List<String> interests;
  final bool isProfileComplete;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserModel({
    required this.uid,
    required this.name,
    required this.birthDate,
    required this.birthTime,
    required this.birthPlace,
    required this.relationshipStatus,
    required this.interests,
    this.isProfileComplete = false,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'birthDate': birthDate,
      'birthTime': birthTime,
      'birthPlace': birthPlace,
      'relationshipStatus': relationshipStatus,
      'interests': interests,
      'isProfileComplete': isProfileComplete,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'],
      name: map['name'],
      birthDate: map['birthDate'].toDate(),
      birthTime: map['birthTime'],
      birthPlace: map['birthPlace'],
      relationshipStatus: map['relationshipStatus'],
      interests: List<String>.from(map['interests']),
      isProfileComplete: map['isProfileComplete'],
      createdAt: map['createdAt'].toDate(),
      updatedAt: map['updatedAt'].toDate(),
    );
  }
}
