import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:spirootv2/astrology/astrology_screen.dart';
import 'package:spirootv2/explore/explore_screen.dart';
import 'package:spirootv2/fortune/fortune_screen.dart';
import 'package:spirootv2/home/home_screen.dart';
import 'package:spirootv2/shop/shops_screen.dart';

class HomeController extends GetxController {
  // Seçili sayfa indeksi
  var currentIndex = 0.obs;

  // Sayfalar listesi
  final List<Widget> pages = [
    const HomeScreen(),
    const FortuneScreen(),
    AstrologyScreen(),
    const ShopsScreen(),
    ExploreScreen(),
  ];

  // Sayfa değiştirme fonksiyonu
  void changePage(int index) {
    currentIndex.value = index;
  }

  // Aktif sayfayı getir
  Widget get currentPage => pages[currentIndex.value];
}
