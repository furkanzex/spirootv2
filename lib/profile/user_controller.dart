import 'package:get/get.dart';
import 'package:spirootv2/core/constant/my_color.dart';
import 'package:spirootv2/home/homepage.dart';
import 'user_model.dart';
import 'user_repository.dart';
import '../core/service/astrology_service.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:easy_localization/easy_localization.dart' as easy;

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
  final List<String> genderKeys = ['female', 'male', 'other'];
  final List<String> relationshipStatusKeys = [
    'single',
    'in_relationship',
    'engaged',
    'married',
    'divorced',
    'widowed',
    'complicated'
  ];
  final List<String> interestKeys = [
    'money',
    'business',
    'friendship',
    'love',
    'family',
    'career'
  ];

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
    selectedGender.value = '';
    isGenderValid.value = false;
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
    final name = nameController.text.trim();
    isNameValid.value = name.length >= 2;
    showNameError.value = !isNameValid.value;
    return isNameValid.value;
  }

  bool validateDatePage() {
    return isDateValid.value;
  }

  bool validateTimePage() {
    return isTimeValid.value;
  }

  bool validatePlacePage() {
    final isValid = birthPlaceController.text.trim().isNotEmpty;
    isPlaceValid.value = isValid;
    print('Doğum yeri sayfası validasyonu: $isValid');
    return isValid;
  }

  bool validateGenderPage() {
    try {
      return isGenderValid.value && selectedGender.value.isNotEmpty;
    } catch (e) {
      print('Cinsiyet sayfası validasyon hatası: $e');
      return false;
    }
  }

  bool validateRelationshipPage() {
    return isRelationshipStatusValid.value;
  }

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

      // Seçili değerleri key'lere dönüştür
      final genderKey = getGenderKey(selectedGender.value);
      final relationshipStatusKey =
          getRelationshipStatusKey(selectedRelationshipStatus.value);
      final interestKeys = selectedInterests
          .map((interest) => getInterestKey(interest))
          .toList();

      await createOrUpdateUser(
        uid: currentUser.uid,
        name: nameController.text,
        birthDate: selectedBirthDateTime.value,
        birthTime: '${selectedHour.value}:${selectedMinute.value}',
        birthPlace: birthPlaceController.text,
        gender: genderKey, // Key olarak kaydet
        relationshipStatus: relationshipStatusKey, // Key olarak kaydet
        interests: interestKeys, // Key'ler listesi olarak kaydet
      );

      Get.offAll(() => const HomePage());
    } catch (e) {
      print('Profil kaydetme hatası: $e');
      Get.snackbar(
        'Hata',
        'Profil kaydedilirken bir hata oluştu: $e',
        backgroundColor: MyColor.errorColor,
        colorText: MyColor.white,
      );
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
        isSubscribed: false,
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
      // Eğer uid boşsa veya null ise, controller'ı sıfırla
      if (uid.isEmpty) {
        resetController();
        return;
      }

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

        selectedGender.value = getGenderValue(user.gender);
        selectedRelationshipStatus.value =
            getRelationshipStatusValue(user.relationshipStatus);
        selectedInterests.value =
            user.interests.map((key) => getInterestValue(key)).toList();
      } else {
        // Kullanıcı bulunamadıysa controller'ı sıfırla
        resetController();
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
    try {
      print('Doğum yeri validasyonu: $place');
      isPlaceValid.value = place.isNotEmpty;
      birthPlaceController.text = place;
      return isPlaceValid.value;
    } catch (e) {
      handleLocationError(e.toString());
      return false;
    }
  }

  bool validateGender(String gender) {
    try {
      selectedGender.value = gender;
      isGenderValid.value = gender.isNotEmpty;
      return isGenderValid.value;
    } catch (e) {
      print('Cinsiyet validasyon hatası: $e');
      return false;
    }
  }

  bool validateRelationshipStatus(String status) {
    selectedRelationshipStatus.value = status;
    isRelationshipStatusValid.value = status.isNotEmpty;
    return isRelationshipStatusValid.value;
  }

  // isProfileComplete getter'ı ekleyelim
  bool get isProfileComplete => currentUser.value?.isProfileComplete ?? false;

  // userName getter'ı da ekleyelim
  String get userName => currentUser.value?.name ?? '';

  // Görüntülenecek değerleri getiren getterlar
  List<String> get genders =>
      genderKeys.map((key) => easy.tr('profile.gender.$key')).toList();

  List<String> get relationshipStatuses => relationshipStatusKeys
      .map((key) => easy.tr('profile.relationship_status.$key'))
      .toList();

  List<String> get interestStatuses =>
      interestKeys.map((key) => easy.tr('profile.interests.$key')).toList();

  // Key'den value'ya dönüşüm metodları
  String getGenderKey(String displayValue) {
    final index = genders.indexOf(displayValue);
    return index != -1 ? genderKeys[index] : '';
  }

  String getRelationshipStatusKey(String displayValue) {
    final index = relationshipStatuses.indexOf(displayValue);
    return index != -1 ? relationshipStatusKeys[index] : '';
  }

  String getInterestKey(String displayValue) {
    final index = interestStatuses.indexOf(displayValue);
    return index != -1 ? interestKeys[index] : '';
  }

  // Value'dan key'e dönüşüm metodları
  String getGenderValue(String key) {
    return easy.tr('profile.gender.$key');
  }

  String getRelationshipStatusValue(String key) {
    return easy.tr('profile.relationship_status.$key');
  }

  String getInterestValue(String key) {
    return easy.tr('profile.interests.$key');
  }

  // Controller'ı sıfırlama metodu
  void resetController() {
    // Form Controllers
    nameController.clear();
    birthPlaceController.clear();

    // Form Values
    selectedBirthDateTime.value = DateTime.now();
    selectedHour.value = '00';
    selectedMinute.value = '00';
    selectedGender.value = '';
    selectedRelationshipStatus.value = '';
    selectedInterests.clear();

    // Form Validation States
    showNameError.value = false;
    isNameValid.value = false;
    isDateValid.value = false;
    isTimeValid.value = false;
    isPlaceValid.value = false;
    isGenderValid.value = false;
    isRelationshipStatusValid.value = false;

    // User Data
    currentUser.value = null;
    userId.value = '';
    isLoading.value = false;
  }

  void refreshNatalChart() {
    update(['natal_chart']); // GetBuilder için özel ID
  }

  void handleLocationError(String error) {
    if (Get.isSnackbarOpen) {
      Get.closeCurrentSnackbar();
    }

    Get.snackbar(
      'Hata',
      'Konum arama sırasında bir hata oluştu. Lütfen tekrar deneyin.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: MyColor.errorColor,
      colorText: MyColor.white,
      duration: const Duration(seconds: 3),
    );
  }
}
