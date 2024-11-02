// ignore: file_names
import 'dart:developer';

import 'package:fluttertoast/fluttertoast.dart';

firebaseAuthException(e) {
  log('FirebaseAuthException hatası: ${e.code}');
  switch (e.code) {
    case 'user-not-found':
      Fluttertoast.showToast(
        msg:
            'Kullanıcı bulunamadı: Belirtilen e-posta veya kullanıcı adı ile hesap bulunamadı.',
        toastLength: Toast.LENGTH_LONG,
      );
      break;
    case 'wrong-password':
      Fluttertoast.showToast(
        msg: 'Yanlış şifre: Girilen şifre yanlış.',
        toastLength: Toast.LENGTH_LONG,
      );
      break;
    case 'invalid-email':
      Fluttertoast.showToast(
        msg:
            'Geçersiz e-posta adresi: Lütfen geçerli bir e-posta adresi girin.',
        toastLength: Toast.LENGTH_LONG,
      );
      break;
    case 'too-many-requests':
      Fluttertoast.showToast(
        msg:
            'Çok fazla giriş denemesi: Çok sayıda yanlış giriş denemesi nedeniyle giriş işlemi engellendi. Bir süre sonra tekrar deneyin.',
        toastLength: Toast.LENGTH_LONG,
      );
      break;
    case 'user-disabled':
      Fluttertoast.showToast(
        msg: 'Kullanıcı devre dışı bırakıldı: Bu hesap devre dışı bırakıldı.',
        toastLength: Toast.LENGTH_LONG,
      );
      break;
    case 'email-already-in-use':
      Fluttertoast.showToast(
        msg:
            'Mail adresi kullanımda: Bu mail adresi ile daha önce kayıt yapılmış.',
        toastLength: Toast.LENGTH_LONG,
      );
      break;
    default:
      Fluttertoast.showToast(
        msg: 'Bir hata oluştu.',
        toastLength: Toast.LENGTH_LONG,
      );
      break;
  }
}
