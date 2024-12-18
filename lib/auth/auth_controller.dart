import 'package:spirootv2/profile/user_controller.dart';
import 'package:spirootv2/core/constant/my_color.dart';
import 'package:spirootv2/auth/welcome_screen.dart';
import 'package:spirootv2/core/helper/local_storage.dart';
import 'package:spirootv2/home/homepage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:easy_localization/easy_localization.dart' as easy;

class AuthController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _storage = LocalStorage();

  var isLogin = false.obs;
  var isRegistered = false.obs;
  var isLoading = false.obs;

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
      Get.snackbar(
          easy.tr('error.error'), easy.tr('error.anonymous_login_failed'));
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
          'updatedAt': FieldValue.serverTimestamp(),
          'isAnonymous': true,
          'isSubscribed': false,
          'isProfileComplete': false,
        });
      }
    } catch (e) {
      Get.snackbar(easy.tr('error.error'), easy.tr('error.user_not_saved'));
    }
  }

  Future<bool> checkUserInFirestore(String uid) async {
    try {
      final userDoc = await _firestore.collection('users').doc(uid).get();
      return userDoc.exists;
    } catch (e) {
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
      Get.snackbar(easy.tr('error.error'), easy.tr('error.logout_failed'));
    }
  }

  Future<void> deleteAccount() async {
    try {
      final String? userId = _auth.currentUser?.uid;

      if (userId != null) {
        // Önce kullanıcının fortunes koleksiyonunu sil
        final userFortunesRef =
            _firestore.collection('users').doc(userId).collection('fortunes');

        final fortunesDocs = await userFortunesRef.get();
        final batch = _firestore.batch();

        for (var doc in fortunesDocs.docs) {
          batch.delete(doc.reference);
        }

        await batch.commit();

        // Sonra ana kullanıcı dökümanını sil
        await _firestore.collection('users').doc(userId).delete();

        // UserController'ı temizle
        final userController = Get.find<UserController>();
        userController.resetController();

        // Authentication'dan kullanıcıyı sil
        await _auth.currentUser?.delete();

        // Local storage'ı temizle
        await _storage.removeUserId();

        // State'i güncelle
        isLogin.value = false;
        isRegistered.value = false;

        // Welcome sayfasına yönlendir ve geri dönüşü engelle
        Get.offAll(() => WelcomeScreen(), predicate: (_) => false);
      } else {
        throw Exception(easy.tr('error.user_not_found'));
      }
    } catch (e) {
      throw Exception(easy.tr('error.account_not_deleted'));
    }
  }

  Future<void> handleSignIn() async {
    try {
      isLoading.value = true;

      // Anonim giriş yap
      await signInAnonymously();
    } catch (e) {
      Get.snackbar(
        easy.tr('error.error'),
        easy.tr('error.error_auth'),
        backgroundColor: MyColor.darkBackgroundColor,
        colorText: MyColor.white,
      );
      throw Exception(e);
    } finally {
      isLoading.value = false;
    }
  }

  // Profil tamamlama kontrolü
  Future<bool> isProfileComplete() async {
    final user = _auth.currentUser;
    if (user == null) return false;

    final userData = await _firestore.collection('users').doc(user.uid).get();
    return userData.exists &&
        userData.data()?['name'] != null &&
        userData.data()?['birthDate'] != null;
  }

  // Aktif abonelik kontrolü
  Future<bool> hasActiveSubscription() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      final userData = await _firestore.collection('users').doc(user.uid).get();
      return userData.data()?['isSubscribed'] ?? false;
    } catch (e) {
      return false;
    }
  }
}
