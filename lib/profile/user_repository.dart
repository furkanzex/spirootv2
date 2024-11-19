import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:spirootv2/profile/user_model.dart';

class UserRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  UserRepository({FirebaseFirestore? firestore, FirebaseAuth? auth})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  Future<UserModel> createAnonymousUser() async {
    // Anonim hesap oluştur
    final userCredential = await _auth.signInAnonymously();
    final uid = userCredential.user?.uid ?? '';

    // Yeni kullanıcı modeli oluştur
    final user = UserModel(
      uid: uid,
      name: '',
      birthDate: DateTime.now(),
      birthTime: '',
      birthPlace: '',
      gender: '',
      relationshipStatus: '',
      interests: [],
      isProfileComplete: false,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      zodiacSign: '',
      moonSign: '',
      ascendant: '',
      isSubscribed: false,
    );

    // Firestore'a kaydet
    await createUser(user);

    return user;
  }

  Future<void> createUser(UserModel user) async {
    if (user.uid.isEmpty) return;
    await _firestore.collection('users').doc(user.uid).set(user.toMap());
  }

  Future<void> updateUser(String uid, Map<String, dynamic> data) async {
    if (uid.isEmpty) return;
    await _firestore.collection('users').doc(uid).update({
      ...data,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<UserModel?> getUser(String uid) async {
    if (uid.isEmpty) return null;
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists && doc.data() != null) {
        return UserModel.fromMap(doc.data()!);
      }
    } catch (e) {
      print('Kullanıcı bilgileri alınırken hata: $e');
    }
    return null;
  }
}
