import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:spirootv2/controller/astrology_controller.dart';
import 'package:spirootv2/core/constant/my_color.dart';

class ProfileController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Text Controllers
  final TextEditingController nameController = TextEditingController();
  final TextEditingController birthPlaceController = TextEditingController();

  // Observable Values
  final RxString selectedHour = '00'.obs;
  final RxString selectedMinute = '00'.obs;
  final RxString selectedTime = ''.obs;
  final Rx<DateTime> selectedDate = DateTime.now().obs;
  final RxString selectedGender = ''.obs;
  final RxString selectedRelationshipStatus = ''.obs;
  final RxList<String> selectedInterests = <String>[].obs;

  // Validation States
  final RxBool showNameError = false.obs;
  final RxBool isNameValid = false.obs;
  final RxBool isDateValid = false.obs;
  final RxBool isTimeValid = false.obs;
  final RxBool isPlaceValid = false.obs;
  final RxBool isGenderValid = false.obs;
  final RxBool isRelationshipStatusValid = false.obs;

  // Loading State
  final RxBool isLoading = false.obs;

  // Constants
  final List<String> genders = ['Kadın', 'Erkek', 'Diğer'];
  final List<String> relationshipStatuses = [
    'Bekar',
    'İlişkisi var',
    'Nişanlı',
    'Evli',
    'Karmaşık'
  ];

  @override
  void onInit() {
    super.onInit();
    _setupListeners();
    _loadUserProfile();
  }

  void _setupListeners() {
    nameController.addListener(() => _validateName());
    birthPlaceController.addListener(() => _validatePlace());
  }

  Future<void> _loadUserProfile() async {
    try {
      isLoading.value = true;
      final user = _auth.currentUser;
      if (user != null) {
        final doc = await _firestore.collection('users').doc(user.uid).get();
        if (doc.exists && doc.data() != null) {
          final userData = doc.data()!;

          // Load existing data if available
          if (userData['name'] != null) {
            nameController.text = userData['name'];
            _validateName();
          }

          if (userData['birthDate'] != null) {
            selectedDate.value = (userData['birthDate'] as Timestamp).toDate();
            _validateDate();
          }

          if (userData['birthTime'] != null) {
            selectedTime.value = userData['birthTime'];
            final timeParts = userData['birthTime'].split(':');
            selectedHour.value = timeParts[0];
            selectedMinute.value = timeParts[1];
            _validateTime();
          }

          if (userData['birthPlace'] != null) {
            birthPlaceController.text = userData['birthPlace'];
            _validatePlace();
          }

          if (userData['gender'] != null) {
            selectedGender.value = userData['gender'];
            _validateGender(userData['gender']);
          }

          if (userData['relationshipStatus'] != null) {
            selectedRelationshipStatus.value = userData['relationshipStatus'];
            _validateRelationshipStatus(userData['relationshipStatus']);
          }

          if (userData['interests'] != null) {
            selectedInterests.value = List<String>.from(userData['interests']);
          }
        }
      }
    } catch (e) {
      _handleError(e);
    } finally {
      isLoading.value = false;
    }
  }

  // Validation Methods
  void _validateName() {
    final name = nameController.text.trim();
    isNameValid.value = name.length >= 2;
    _saveFieldToFirestore('name', name);
  }

  void _validateDate() {
    final now = DateTime.now();
    final age = now.year - selectedDate.value.year;
    isDateValid.value = age >= 13 && age <= 100;

    if (isDateValid.value) {
      final zodiacSign =
          Get.find<AstrologyController>().getZodiacSign(selectedDate.value);
      _saveFieldToFirestore('birthDate', selectedDate.value);
      _saveFieldToFirestore('zodiacSign', zodiacSign);

      // Burç detaylarını da kaydet
      final zodiacDetails =
          Get.find<AstrologyController>().getZodiacDetails(selectedDate.value);
      _saveFieldToFirestore('zodiacDetails', zodiacDetails);
    }
  }

  void _validateTime() {
    selectedTime.value = '${selectedHour.value}:${selectedMinute.value}';
    isTimeValid.value = true;
    _saveFieldToFirestore('birthTime', selectedTime.value);
  }

  void _validatePlace() {
    isPlaceValid.value = birthPlaceController.text.trim().isNotEmpty;
    if (isPlaceValid.value) {
      _saveFieldToFirestore('birthPlace', birthPlaceController.text.trim());
    }
  }

  void validatePlace(String value) {
    birthPlaceController.text = value;
    _validatePlace();
  }

  void _validateGender(String value) {
    selectedGender.value = value;
    isGenderValid.value = value.isNotEmpty;
    if (isGenderValid.value) {
      _saveFieldToFirestore('gender', value);
    }
  }

  void _validateRelationshipStatus(String value) {
    selectedRelationshipStatus.value = value;
    isRelationshipStatusValid.value = value.isNotEmpty;
    if (isRelationshipStatusValid.value) {
      _saveFieldToFirestore('relationshipStatus', value);
    }
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
  bool validateInterestsPage() => selectedInterests.isNotEmpty;

  // Firebase Operations
  Future<void> _saveFieldToFirestore(String field, dynamic value) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).set({
          field: value,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }
    } catch (e) {
      _handleError(e);
    }
  }

  Future<void> saveUserProfile() async {
    try {
      isLoading.value = true;
      final user = _auth.currentUser;
      if (user != null) {
        final zodiacSign =
            Get.find<AstrologyController>().getZodiacSign(selectedDate.value);

        await _firestore.collection('users').doc(user.uid).set({
          'name': nameController.text.trim(),
          'birthDate': selectedDate.value,
          'birthTime': selectedTime.value,
          'birthPlace': birthPlaceController.text.trim(),
          'gender': selectedGender.value,
          'relationshipStatus': selectedRelationshipStatus.value,
          'interests': selectedInterests,
          'zodiacSign': zodiacSign,
          'isProfileComplete': true,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }
    } catch (e) {
      _handleError(e);
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  void _handleError(dynamic error) {
    debugPrint('Hata: $error');
    Get.snackbar(
      'Hata',
      error.toString(),
      backgroundColor: MyColor.errorColor,
      colorText: MyColor.white,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  @override
  void onClose() {
    nameController.dispose();
    birthPlaceController.dispose();
    super.onClose();
  }

  void validateDate() {
    final now = DateTime.now();
    final age = now.year - selectedDate.value.year;
    isDateValid.value = age >= 13 && age <= 100;

    if (isDateValid.value) {
      final zodiacSign =
          Get.find<AstrologyController>().getZodiacSign(selectedDate.value);
      _saveFieldToFirestore('birthDate', selectedDate.value);
      _saveFieldToFirestore('zodiacSign', zodiacSign);

      final zodiacDetails =
          Get.find<AstrologyController>().getZodiacDetails(selectedDate.value);
      _saveFieldToFirestore('zodiacDetails', zodiacDetails);
    }
  }

  void validateGender(String value) {
    selectedGender.value = value;
    isGenderValid.value = value.isNotEmpty;
    if (isGenderValid.value) {
      _saveFieldToFirestore('gender', value);
    }
  }

  void validateRelationshipStatus(String value) {
    selectedRelationshipStatus.value = value;
    isRelationshipStatusValid.value = value.isNotEmpty;
    if (isRelationshipStatusValid.value) {
      _saveFieldToFirestore('relationshipStatus', value);
    }
  }

  void updateSelectedTime(String hour, String minute) {
    selectedHour.value = hour;
    selectedMinute.value = minute;
    selectedTime.value = '$hour:$minute';
    isTimeValid.value = true;
    _saveFieldToFirestore('birthTime', selectedTime.value);
  }

  void toggleInterest(String interest) {
    if (selectedInterests.contains(interest)) {
      selectedInterests.remove(interest);
    } else {
      selectedInterests.add(interest);
    }
    _saveFieldToFirestore('interests', selectedInterests);
  }

  bool isFieldValid(String field) {
    switch (field) {
      case 'name':
        return isNameValid.value;
      case 'date':
        return isDateValid.value;
      case 'time':
        return isTimeValid.value;
      case 'place':
        return isPlaceValid.value;
      case 'gender':
        return isGenderValid.value;
      case 'relationshipStatus':
        return isRelationshipStatusValid.value;
      case 'interests':
        return selectedInterests.isNotEmpty;
      default:
        return false;
    }
  }
}
