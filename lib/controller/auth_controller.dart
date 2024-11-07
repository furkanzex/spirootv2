import 'package:spirootv2/view/auth/welcome_screen.dart';
import 'package:spirootv2/core/helper/local_storage.dart';
import 'package:spirootv2/view/homepage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

class AuthController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _storage = LocalStorage();

  var isLogin = false.obs;
  var isRegistered = false.obs;

  @override
  void onInit() {
    super.onInit();
    _checkIfLogin();
  }

  void _checkIfLogin() {
    _auth.authStateChanges().listen((User? user) async {
      if (user != null) {
        isLogin.value = true;
        isRegistered.value = await checkUserInFirestore(user.uid);
      } else {
        isLogin.value = false;
      }
    });
  }

  Future<void> signInAnonymously() async {
    try {
      UserCredential userCredential = await _auth.signInAnonymously();

      if (userCredential.user != null) {
        isLogin.value = true;
        await _storage.saveUserId(userCredential.user!.uid);
        await saveUserToFirestore(userCredential.user!);
        isRegistered.value =
            await checkUserInFirestore(userCredential.user!.uid);
        navigateUser();
      }
    } catch (e) {
      debugPrint('Anonim giriş hatası: $e');
      Get.snackbar('Hata', 'Anonim giriş yapılamadı: $e');
    }
  }

  Future<void> saveUserToFirestore(User user) async {
    try {
      final userDoc = _firestore.collection('users').doc(user.uid);

      final docSnapshot = await userDoc.get();
      if (!docSnapshot.exists) {
        await userDoc.set({
          'uid': user.uid,
          'createdAt': FieldValue.serverTimestamp(),
          'isAnonymous': true,
        });
      }
    } catch (e) {
      debugPrint('Firestore kullanıcı kaydı hatası: $e');
      Get.snackbar('Hata', 'Kullanıcı kaydedilemedi: $e');
    }
  }

  Future<bool> checkUserInFirestore(String uid) async {
    try {
      final userDoc = await _firestore.collection('users').doc(uid).get();
      return userDoc.exists;
    } catch (e) {
      debugPrint('Firestore kontrol hatası: $e');
      return false;
    }
  }

  void navigateUser() {
    if (isLogin.value) {
      Get.offAll(() => isRegistered.value ? const HomePage() : WelcomeScreen());
    } else {
      signInAnonymously();
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
      await _storage.removeUserId();
      isLogin.value = false;
      signInAnonymously();
    } catch (e) {
      debugPrint('Çıkış yapma hatası: $e');
      Get.snackbar('Hata', 'Çıkış yapılamadı: $e');
    }
  }
}
