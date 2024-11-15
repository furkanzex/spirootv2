import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:spirootv2/core/constant/my_size.dart';
import 'package:spirootv2/model/user/user_model.dart';

class ProfileController extends GetxController {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController birthPlaceController = TextEditingController();

  final Rx<DateTime> selectedDate = DateTime.now().obs;
  final RxString selectedHour = '00'.obs;
  final RxString selectedMinute = '00'.obs;
  final RxString selectedTime = ''.obs;
  final RxList<String> selectedInterests = <String>[].obs;

  final RxBool isNameValid = false.obs;
  final RxBool isDateValid = false.obs;
  final RxBool isPlaceValid = false.obs;
  final RxBool areInterestsValid = false.obs;
  final RxBool isLoading = false.obs;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void onInit() {
    super.onInit();
    selectedDate.value = DateTime(
      DateTime.now().year - 18,
      DateTime.now().month,
      DateTime.now().day,
    );
    updateSelectedTime();
    loadUserProfile();
  }

  void validateName(String value) {
    isNameValid.value = value.trim().length >= 2;
  }

  void validateDate() {
    final now = DateTime.now();
    final age = now.year - selectedDate.value.year;
    isDateValid.value = age >= 13 && age <= 100;
  }

  void validatePlace(String value) {
    isPlaceValid.value = value.trim().length >= 3;
  }

  void validateInterests() {
    areInterestsValid.value = selectedInterests.length >= 1;
  }

  void updateSelectedTime() {
    selectedTime.value = '${selectedHour.value}:${selectedMinute.value}';
  }

  bool isCurrentPageValid(int page) {
    switch (page) {
      case 0:
        return isNameValid.value;
      case 1:
        return isDateValid.value;
      case 2:
        return true;
      case 3:
        return isPlaceValid.value;
      case 4:
        return areInterestsValid.value;
      default:
        return false;
    }
  }

  Future<void> saveUserProfile() async {
    try {
      isLoading.value = true;
      final user = _auth.currentUser;
      if (user != null) {
        final userModel = UserModel(
          uid: user.uid,
          name: nameController.text.trim(),
          birthDate: selectedDate.value,
          birthTime: selectedTime.value,
          birthPlace: birthPlaceController.text.trim(),
          relationshipStatus: 'Single',
          interests: selectedInterests,
          isProfileComplete: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        await _firestore
            .collection('users')
            .doc(user.uid)
            .set(userModel.toMap());

        Get.snackbar(
          'Başarılı',
          'Profilin başarıyla kaydedildi',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          margin: const EdgeInsets.all(MySize.defaultPadding),
          borderRadius: MySize.halfRadius,
          duration: const Duration(seconds: 2),
        );
      }
    } catch (e) {
      Get.snackbar(
        'Hata',
        'Profil kaydedilirken bir hata oluştu',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        margin: const EdgeInsets.all(MySize.defaultPadding),
        borderRadius: MySize.halfRadius,
        duration: const Duration(seconds: 2),
      );
      debugPrint('Profil kaydetme hatası: $e');
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadUserProfile() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        final doc = await _firestore.collection('users').doc(user.uid).get();
        if (doc.exists) {
          final userData = UserModel.fromMap(doc.data()!);
          nameController.text = userData.name;
          selectedDate.value = userData.birthDate;
          if (userData.birthTime.isNotEmpty) {
            final timeParts = userData.birthTime.split(':');
            selectedHour.value = timeParts[0];
            selectedMinute.value = timeParts[1];
            updateSelectedTime();
          }
          birthPlaceController.text = userData.birthPlace;
          selectedInterests.value = userData.interests;
        }
      }
    } catch (e) {
      debugPrint('Profil yükleme hatası: $e');
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    birthPlaceController.dispose();
    super.onClose();
  }
}
