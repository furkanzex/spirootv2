import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:spirootv2/controller/astrology_controller.dart';
import 'package:spirootv2/core/constant/my_color.dart';
import 'package:spirootv2/core/helper/local_storage.dart';

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
  final RxString userId = ''.obs;

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

  // Gender ve RelationshipStatus için index tabanlı yapı
  final Map<String, int> genderIndices = {'female': 0, 'male': 1, 'other': 2};

  final Map<String, int> relationshipIndices = {
    'single': 0,
    'in_relationship': 1,
    'engaged': 2,
    'married': 3,
    'divorced': 4,
    'widowed': 5,
    'complicated': 6
  };

  final Map<String, int> interestIndices = {
    'money': 0,
    'work': 1,
    'friendship': 2,
    'love': 3,
    'family': 4,
    'career': 5,
  };

  final RxBool isProfileComplete = false.obs;
  final RxString userName = ''.obs;
  final RxString profileImage = ''.obs;

  // DateTime olarak doğum saati
  final Rx<DateTime> selectedBirthDateTime = DateTime.now().obs;

  @override
  void onInit() {
    super.onInit();
    _setupListeners();
    loadUserProfile();
  }

  void _setupListeners() {
    nameController.addListener(() => _validateName());
    birthPlaceController.addListener(() => _validatePlace());
  }

  Future<void> loadUserProfile() async {
    try {
      isLoading.value = true;
      final user = _auth.currentUser;

      if (user != null) {
        userId.value = user.uid;
        // Kullanıcı ID'sini locale kaydet
        await LocalStorage().saveUserId(user.uid);

        // Firestore'dan kullanıcı verilerini çek
        final doc = await _firestore.collection('users').doc(user.uid).get();

        if (doc.exists && doc.data() != null) {
          final userData = doc.data()!;

          // Text controller'ları güncelle
          nameController.text = userData['name'] ?? '';
          birthPlaceController.text = userData['birthPlace'] ?? '';

          // Rx değişkenlerini güncelle
          if (userData['birthDate'] != null) {
            selectedDate.value = (userData['birthDate'] as Timestamp).toDate();
          }

          if (userData['birthTime'] != null) {
            final birthTimeTimestamp = userData['birthTime'] as Timestamp;
            final birthDateTime = birthTimeTimestamp.toDate();

            selectedBirthDateTime.value = birthDateTime;
            selectedHour.value = birthDateTime.hour.toString().padLeft(2, '0');
            selectedMinute.value =
                birthDateTime.minute.toString().padLeft(2, '0');
            selectedTime.value =
                '${selectedHour.value}:${selectedMinute.value}';
          }

          selectedGender.value = userData['gender'] ?? '';
          selectedRelationshipStatus.value =
              userData['relationshipStatus'] ?? '';

          if (userData['interests'] != null) {
            selectedInterests.value = List<String>.from(userData['interests']);
          }

          // Validation states'i güncelle
          isNameValid.value = nameController.text.isNotEmpty;
          isDateValid.value = true; // Tarih kontrolü yapılabilir
          isTimeValid.value = selectedTime.value.isNotEmpty;
          isPlaceValid.value = birthPlaceController.text.isNotEmpty;
          isGenderValid.value = selectedGender.value.isNotEmpty;
          isRelationshipStatusValid.value =
              selectedRelationshipStatus.value.isNotEmpty;

          // Yeni alanları yükle
          isProfileComplete.value = userData['isProfileComplete'] ?? false;
          userName.value = userData['name'] ?? '';
          profileImage.value = userData['zodiacSign'] ?? '';
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
          'birthTime': selectedBirthDateTime.value,
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

  void validateGender(String localizedGender) {
    selectedGender.value = localizedGender;
    isGenderValid.value = localizedGender.isNotEmpty;
    if (isGenderValid.value) {
      final genderKey = getGenderKey(localizedGender);
      _saveFieldToFirestore('gender', {
        'localized': localizedGender,
        'key': genderKey,
        'index': genderIndices[genderKey]
      });
    }
  }

  void validateRelationshipStatus(String localizedStatus) {
    selectedRelationshipStatus.value = localizedStatus;
    isRelationshipStatusValid.value = localizedStatus.isNotEmpty;
    if (isRelationshipStatusValid.value) {
      final statusKey = getRelationshipKey(localizedStatus);
      _saveFieldToFirestore('relationshipStatus', {
        'localized': localizedStatus,
        'key': statusKey,
        'index': relationshipIndices[statusKey]
      });
    }
  }

  void updateSelectedTime(String hour, String minute) {
    // Mevcut seçili tarihi al
    final currentDate = selectedDate.value;

    // Yeni bir DateTime oluştur (seçili tarih + seçili saat)
    selectedBirthDateTime.value = DateTime(
      currentDate.year,
      currentDate.month,
      currentDate.day,
      int.parse(hour),
      int.parse(minute),
    );

    // Eski string formatını da güncelle (geriye uyumluluk için)
    selectedHour.value = hour;
    selectedMinute.value = minute;
    selectedTime.value = '$hour:$minute';
    isTimeValid.value = true;

    // Firebase'e kaydet
    _saveFieldToFirestore('birthTime', selectedBirthDateTime.value);
  }

  void toggleInterest(String localizedInterest) {
    if (selectedInterests.contains(localizedInterest)) {
      selectedInterests.remove(localizedInterest);
    } else {
      selectedInterests.add(localizedInterest);
    }

    final List<Map<String, dynamic>> indexedInterests =
        selectedInterests.map((interest) {
      final key = interest.toLowerCase().replaceAll(' ', '_');
      return {'localized': interest, 'key': key, 'index': interestIndices[key]};
    }).toList();

    _saveFieldToFirestore('interests', indexedInterests);
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

  String getGenderKey(String localizedGender) {
    switch (localizedGender) {
      case 'Kadın':
        return 'female';
      case 'Erkek':
        return 'male';
      case 'Diğer':
        return 'other';
      default:
        return 'other';
    }
  }

  String getRelationshipKey(String localizedStatus) {
    switch (localizedStatus) {
      case 'Bekar':
        return 'single';
      case 'İlişkisi var':
        return 'in_relationship';
      case 'Nişanlı':
        return 'engaged';
      case 'Evli':
        return 'married';
      case 'Karmaşık':
        return 'complicated';
      default:
        return 'single';
    }
  }

  // Profil güncelleme metodu
  Future<void> updateProfile() async {
    try {
      isLoading.value = true;
      final userId = LocalStorage().getUserId();
      if (userId != null) {
        await _firestore.collection('users').doc(userId).update({
          'name': nameController.text.trim(),
          'birthDate': selectedDate.value,
          'birthTime': selectedBirthDateTime.value,
          'birthPlace': birthPlaceController.text.trim(),
          'gender': selectedGender.value,
          'relationshipStatus': selectedRelationshipStatus.value,
          'interests': selectedInterests,
          'updatedAt': FieldValue.serverTimestamp(),
        });
        Get.snackbar(
          'Başarılı',
          'Profiliniz güncellendi',
          backgroundColor: MyColor.successColor.withOpacity(0.5),
          colorText: MyColor.white,
        );
      }
    } catch (e) {
      _handleError(e);
    } finally {
      isLoading.value = false;
    }
  }
}
