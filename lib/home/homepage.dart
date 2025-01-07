import 'package:easy_localization/easy_localization.dart' as easy;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:lottie/lottie.dart';
import 'package:spirootv2/core/service/revenuecat_services.dart';
import 'package:spirootv2/home/home_controller.dart';
import 'package:spirootv2/core/constant/my_color.dart';
import 'package:scaffold_gradient_background/scaffold_gradient_background.dart';
import 'package:spirootv2/core/constant/my_size.dart';
import 'package:spirootv2/core/constant/my_style.dart';
import 'package:spirootv2/core/constant/my_text.dart';
import 'package:spirootv2/home/section/settings_modal_bottom_sheet.dart';
import 'package:spirootv2/paywall/paywall_screen.dart';

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
        surfaceTintColor: MyColor.transparent,
        backgroundColor: MyColor.transparent,
        title: Text(
          MyText.appName,
          style: MyStyle.b2.copyWith(color: MyColor.white),
        ),
        centerTitle: false,
        actions: [
          FutureBuilder<bool>(
            future: PurchaseAPI.isPremium(),
            builder: (context, snapshot) {
              return snapshot.data == true
                  ? SizedBox(
                      height: MySize.iconSizeSmallMedium,
                      width: MySize.iconSizeSmallMedium,
                      child: LottieBuilder.asset("assets/lottie/premium.json"),
                    )
                  : SizedBox(
                      height: MySize.iconSizeSmallMedium,
                      width: MySize.iconSizeSmallMedium,
                      child: GestureDetector(
                        onTap: () {
                          paywall();
                        },
                        child:
                            LottieBuilder.asset("assets/lottie/gift_icon.json"),
                      ),
                    );
            },
          ),
          IconButton(
              onPressed: () {
                showSettingsBottomSheet(context);
              },
              icon: Icon(
                MingCute.angel_line,
                color: MyColor.white,
                size: MySize.iconSizeSmaller,
              ))
        ],
      ),
      body: Obx(() => controller.pages[controller.currentIndex.toInt()]),
      bottomNavigationBar: Obx(
        () => BottomNavigationBar(
          currentIndex: controller.currentIndex.toInt(),
          onTap: controller.changePage,
          backgroundColor: MyColor.transparent,
          selectedItemColor: MyColor.white,
          unselectedItemColor: MyColor.primaryPurpleColor.withOpacity(0.25),
          elevation: 0,
          iconSize: MySize.iconSizeSmaller,
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
                icon: Icon(MingCute.group_line),
                activeIcon: Icon(MingCute.group_fill),
                label: easy.tr("navigation.social")),
            /*
              BottomNavigationBarItem(
                  icon: Icon(MingCute.search_line),
                  activeIcon: Icon(MingCute.search_fill),
                  label: easy.tr("navigation.explore")),*/
          ],
        ),
      ),
    );
  }
}
