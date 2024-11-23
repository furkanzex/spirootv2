import 'package:easy_localization/easy_localization.dart' as easy;

// ignore: file_names
import 'dart:developer';

import 'package:fluttertoast/fluttertoast.dart';

firebaseAuthException(e) {
  log('FirebaseAuthException hatası: ${e.code}');
  switch (e.code) {
    case 'user-not-found':
      Fluttertoast.showToast(
        msg: easy.tr("errors.auth.user_not_found"),
        toastLength: Toast.LENGTH_LONG,
      );
      break;
    case 'wrong-password':
      Fluttertoast.showToast(
        msg: easy.tr("errors.auth.wrong_password"),
        toastLength: Toast.LENGTH_LONG,
      );
      break;
    case 'invalid-email':
      Fluttertoast.showToast(
        msg: easy.tr("errors.auth.invalid_email"),
        toastLength: Toast.LENGTH_LONG,
      );
      break;
    case 'too-many-requests':
      Fluttertoast.showToast(
        msg: easy.tr("errors.auth.too_many_requests"),
        toastLength: Toast.LENGTH_LONG,
      );
      break;
    case 'user-disabled':
      Fluttertoast.showToast(
        msg: easy.tr("errors.auth.user_disabled"),
        toastLength: Toast.LENGTH_LONG,
      );
      break;
    case 'email-already-in-use':
      Fluttertoast.showToast(
        msg: easy.tr("errors.auth.email_already_in_use"),
        toastLength: Toast.LENGTH_LONG,
      );
      break;
    default:
      Fluttertoast.showToast(
        msg: easy.tr("errors.auth.default"),
        toastLength: Toast.LENGTH_LONG,
      );
      break;
  }
}
