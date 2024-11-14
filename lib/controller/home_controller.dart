import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:spirootv2/view/navigation/astrology_screen.dart';
import 'package:spirootv2/view/navigation/explore_screen.dart';
import 'package:spirootv2/view/navigation/fortune_screen.dart';
import 'package:spirootv2/view/navigation/home_screen.dart';
import 'package:spirootv2/view/navigation/shops_screen.dart';

class HomeController extends GetxController {
  // Seçili sayfa indeksi
  var currentIndex = 0.obs;

  // Sayfalar listesi
  final List<Widget> pages = [
    const HomeScreen(),
    const FortuneScreen(),
    AstrologyScreen(),
    const ShopsScreen(),
    const ExploreScreen(),
  ];

  // Sayfa değiştirme fonksiyonu
  void changePage(int index) {
    currentIndex.value = index;
  }

  // Aktif sayfayı getir
  Widget get currentPage => pages[currentIndex.value];
}
