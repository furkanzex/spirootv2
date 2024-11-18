import 'package:get/get.dart';
import 'package:spirootv2/view/homepage.dart';
import '../model/user_model.dart';
import '../data/user_repository.dart';
import '../core/service/astrology_service.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserController extends GetxController {
  final UserRepository _repository;

  final Rx<UserModel?> currentUser = Rx<UserModel?>(null);
  final RxBool isLoading = false.obs;
  final RxString userId = ''.obs;

  // Form Controllers
  final TextEditingController nameController = TextEditingController();
  final TextEditingController birthPlaceController = TextEditingController();

  // Form Values
  final Rx<DateTime> selectedBirthDateTime = DateTime.now().obs;
  final RxString selectedHour = '00'.obs;
  final RxString selectedMinute = '00'.obs;
  final RxString selectedGender = ''.obs;
  final RxString selectedRelationshipStatus = ''.obs;
  final RxList<String> selectedInterests = <String>[].obs;

  // Form Validation States
  final RxBool showNameError = false.obs;
  final RxBool isNameValid = false.obs;
  final RxBool isDateValid = false.obs;
  final RxBool isTimeValid = false.obs;
  final RxBool isPlaceValid = false.obs;
  final RxBool isGenderValid = false.obs;
  final RxBool isRelationshipStatusValid = false.obs;

  // Constants
  final List<String> genders = ['Kadın', 'Erkek', 'Diğer'];
  final List<String> relationshipStatuses = [
    'Bekar',
    'İlişkisi var',
    'Nişanlı',
    'Evli',
    'Boşanmış',
    'Dul',
    'Karmaşık'
  ];
  final List<String> interestStatuses = [
    'Para',
    'İş',
    'Arkadaşlık',
    'Aşk',
    'Aile',
    'Kariyer',
  ];

  final Map<String, int> genderIndices = {'female': 0, 'male': 1, 'other': 2};

  UserController({UserRepository? repository})
      : _repository = repository ?? UserRepository();

  @override
  void onInit() {
    super.onInit();
    nameController.addListener(_validateName);
    birthPlaceController.addListener(_validatePlace);
  }

  @override
  void onClose() {
    nameController.dispose();
    birthPlaceController.dispose();
    super.onClose();
  }

  // Form Validation Methods
  void _validateName() {
    final name = nameController.text.trim();
    isNameValid.value = name.length >= 2;
    showNameError.value = !isNameValid.value;
  }

  void _validatePlace() {
    isPlaceValid.value = birthPlaceController.text.trim().isNotEmpty;
  }

  // Page Validation Methods
  bool validateNamePage() {
    showNameError.value = !isNameValid.value;
    return isNameValid.value;
  }

  bool validateDatePage() => isDateValid.value;
  bool validateTimePage() => isTimeValid.value;
  bool validatePlacePage() => isPlaceValid.value;
  bool validateGenderPage() => isGenderValid.value;
  bool validateRelationshipPage() => isRelationshipStatusValid.value;

  // Time Management
  void updateSelectedTime(String hour, String minute) {
    selectedHour.value = hour;
    selectedMinute.value = minute;
    isTimeValid.value = true;
  }

  // Interest Management
  void toggleInterest(String interest) {
    if (selectedInterests.contains(interest)) {
      selectedInterests.remove(interest);
    } else {
      selectedInterests.add(interest);
    }
  }

  // Save Profile
  Future<void> saveUserProfile() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) return;

      await createOrUpdateUser(
        uid: currentUser.uid,
        name: nameController.text,
        birthDate: selectedBirthDateTime.value,
        birthTime: '${selectedHour.value}:${selectedMinute.value}',
        birthPlace: birthPlaceController.text,
        gender: selectedGender.value,
        relationshipStatus: selectedRelationshipStatus.value,
        interests: selectedInterests.toList(),
      );

      Get.offAll(() => const HomePage());
    } catch (e) {
      print('Profil kaydetme hatası: $e');
      rethrow;
    }
  }

  Future<void> createOrUpdateUser({
    required String uid,
    required String name,
    required DateTime birthDate,
    required String birthTime,
    required String birthPlace,
    required String gender,
    required String relationshipStatus,
    required List<String> interests,
  }) async {
    try {
      isLoading.value = true;

      final zodiacSign = AstrologyService.calculateZodiacSign(birthDate);
      final moonSign = AstrologyService.calculateMoonSign(birthDate, birthTime);
      final ascendant = AstrologyService.calculateAscendant(
        birthDate,
        birthTime,
        birthPlace,
      );

      final user = UserModel(
        uid: uid,
        name: name,
        birthDate: birthDate,
        birthTime: birthTime,
        birthPlace: birthPlace,
        gender: gender,
        relationshipStatus: relationshipStatus,
        interests: interests,
        isProfileComplete: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        zodiacSign: zodiacSign,
        moonSign: moonSign,
        ascendant: ascendant,
      );

      print('Kaydedilecek kullanıcı bilgileri:');
      print('Burç: ${user.zodiacSign}');
      print('Ay Burcu: ${user.moonSign}');
      print('Yükselen: ${user.ascendant}');

      await _repository.createUser(user);
      await loadUser(uid);
    } catch (e) {
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadUser(String uid) async {
    try {
      isLoading.value = true;
      userId.value = uid;
      final user = await _repository.getUser(uid);
      if (user != null) {
        currentUser.value = user;

        // Form değerlerini güncelle
        nameController.text = user.name;
        birthPlaceController.text = user.birthPlace;
        selectedBirthDateTime.value = user.birthDate;

        final timeParts = user.birthTime.split(':');
        if (timeParts.length == 2) {
          selectedHour.value = timeParts[0];
          selectedMinute.value = timeParts[1];
        }

        selectedGender.value = user.gender;
        selectedRelationshipStatus.value = user.relationshipStatus;
        selectedInterests.value = user.interests;
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateUserField(String uid, String field, dynamic value) async {
    try {
      isLoading.value = true;
      await _repository.updateUser(uid, {field: value});
      await loadUser(uid);
    } finally {
      isLoading.value = false;
    }
  }

  // Validasyon metodları
  bool validateName(String name) {
    isNameValid.value = name.length >= 2;
    return isNameValid.value;
  }

  void validateDate() {
    final now = DateTime.now();
    final age = now.year - selectedBirthDateTime.value.year;
    isDateValid.value = age >= 13 && age <= 100;
  }

  bool validateTime(String time) {
    isTimeValid.value = time.isNotEmpty;
    return isTimeValid.value;
  }

  bool validatePlace(String place) {
    isPlaceValid.value = place.isNotEmpty;
    return isPlaceValid.value;
  }

  bool validateGender(String gender) {
    isGenderValid.value = gender.isNotEmpty;
    return isGenderValid.value;
  }

  bool validateRelationshipStatus(String status) {
    isRelationshipStatusValid.value = status.isNotEmpty;
    return isRelationshipStatusValid.value;
  }

  // isProfileComplete getter'ı ekleyelim
  bool get isProfileComplete => currentUser.value?.isProfileComplete ?? false;

  // userName getter'ı da ekleyelim
  String get userName => currentUser.value?.name ?? '';
}
