import 'package:easy_localization/easy_localization.dart' as easy;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:spirootv2/controller/home_controller.dart';
import 'package:spirootv2/core/constant/my_color.dart';
import 'package:scaffold_gradient_background/scaffold_gradient_background.dart';
import 'package:spirootv2/core/constant/my_style.dart';
import 'package:spirootv2/core/constant/my_text.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final HomeController controller = Get.put(HomeController());

  @override
  Widget build(BuildContext context) {
    return ScaffoldGradientBackground(
      gradient: LinearGradient(
        begin: Alignment.bottomLeft,
        end: Alignment.topRight,
        colors: [
          MyColor.darkBackgroundColor,
          MyColor.primaryColor,
        ],
      ),
      appBar: AppBar(
        backgroundColor: MyColor.transparent,
        title: Text(
          MyText.appName,
          style: MyStyle.b3.copyWith(color: MyColor.white),
        ),
        centerTitle: false,
        actions: [
          IconButton(
              onPressed: () {},
              icon: Icon(
                MingCute.user_3_fill,
                color: MyColor.white,
              ))
        ],
      ),
      body: Obx(() => controller.pages[controller.currentIndex.toInt()]),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Obx(
          () => BottomNavigationBar(
            currentIndex: controller.currentIndex.toInt(),
            onTap: controller.changePage,
            backgroundColor: MyColor.transparent,
            selectedItemColor: MyColor.white,
            unselectedItemColor: MyColor.primaryColor,
            elevation: 0,
            type: BottomNavigationBarType.fixed,
            items: [
              BottomNavigationBarItem(
                  icon: Icon(MingCute.pavilion_line),
                  activeIcon: Icon(MingCute.pavilion_fill),
                  label: easy.tr("navigation.home")),
              BottomNavigationBarItem(
                  icon: Icon(MingCute.globe_line),
                  activeIcon: Icon(MingCute.globe_fill),
                  label: easy.tr("navigation.fortune")),
              BottomNavigationBarItem(
                  icon: Icon(MingCute.planet_line),
                  activeIcon: Icon(MingCute.planet_fill),
                  label: easy.tr("navigation.astrology")),
              BottomNavigationBarItem(
                  icon: Icon(MingCute.search_line),
                  activeIcon: Icon(MingCute.search_fill),
                  label: easy.tr("navigation.explore")),
            ],
          ),
        ),
      ),
    );
  }
}
