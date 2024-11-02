import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class DeviceHelper {
  static bool isDarkMode(BuildContext context) {
    return Brightness.dark == MediaQuery.of(context).platformBrightness;
  }

  static double getScreenHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  static double getScreenWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  static bool isIOS() {
    return Platform.isIOS;
  }

  static bool isAndroid() {
    return Platform.isAndroid;
  }

  static String getPlatformName() {
    if (Platform.isAndroid) {
      return "Android";
    } else if (Platform.isIOS) {
      return "iOS";
    } else if (Platform.isMacOS) {
      return "macOS";
    } else if (Platform.isWindows) {
      return "Windows";
    } else if (Platform.isLinux) {
      return "Linux";
    } else {
      return "Unknown";
    }
  }

  static void dismissDialog() {
    if (Get.isOverlaysOpen) {
      Get.back();
    }
  }

  static String trimLeadingWhiteSpace(String text) {
    if (text.startsWith(' ')) {
      return text.substring(1);
    }

    return text;
  }

  static String capitalizeEachWord(String text) {
    return text.split(' ').map((word) {
      if (word.isNotEmpty) {
        return word[0].toUpperCase() + word.substring(1).toLowerCase();
      }
      return word;
    }).join(' ');
  }

  static void hideKeyboard() => Get.focusScope?.unfocus();

  static String getStringValue(dynamic value) => value.toString();

  static int getIntValue(String value) {
    final int? intValue = int.tryParse(value);

    if (intValue != null) {
      return intValue;
    } else {
      return 0;
    }
  }

  static bool isDouble(String value) {
    try {
      double.parse(value);
      return true;
    } on FormatException {
      return false;
    }
  }

  static double getDoubleValue(String value) {
    final double? doubleValue = double.tryParse(value);

    if (doubleValue != null) {
      return doubleValue;
    } else {
      return 0.0;
    }
  }

  static String getFromDateTime(DateTime dateTime) =>
      DateFormat('yyyy.MM.dd').format(dateTime);

  static String getHourFromDateTime(DateTime dateTime) =>
      DateFormat('HH:mm').format(dateTime);

  static String getFromTimestamp(Timestamp timeStamp) =>
      DateFormat('yyyy.MM.dd').format(timeStamp as DateTime);
}
