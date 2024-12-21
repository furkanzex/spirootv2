import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:spirootv2/core/constant/my_color.dart';
import 'package:spirootv2/profile/user_controller.dart';
import 'package:spirootv2/core/constant/my_size.dart';
import 'package:spirootv2/core/widget/footer/footer.dart';
import 'package:spirootv2/core/widget/gap/vertical_gap.dart';
import 'package:spirootv2/home/section/astrology_section.dart';
import 'package:spirootv2/home/section/enlightenment_section.dart';
import 'package:spirootv2/home/section/fortune_section.dart';
import 'package:spirootv2/home/section/greeting_section.dart';
import 'package:spirootv2/home/section/luck_section.dart';
import 'package:spirootv2/home/section/rest_ur_spirit_section.dart';
import 'package:spirootv2/home/section/social_section.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final userController = Get.put(UserController());

  Future<void> _refreshHome() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      await userController.loadUser(userId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _refreshHome,
      backgroundColor: MyColor.darkBackgroundColor,
      color: MyColor.primaryPurpleColor,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(MySize.defaultPadding),
              child: Column(
                children: [
                  greetingSection(
                    title: context.tr("home.greeting"),
                    name: userController.userName,
                  ),
                  verticalGap(MySize.doublePadding),
                  AstrologySection(),
                  verticalGap(MySize.doublePadding),
                  fortuneSection(isMainPageWidget: true, context: context),
                  verticalGap(MySize.doublePadding),
                ],
              ),
            ),
            socialSection(context),
            Padding(
              padding: const EdgeInsets.all(MySize.defaultPadding),
              child: Column(
                children: [
                  verticalGap(MySize.doublePadding),
                  luckSection(context),
                  verticalGap(MySize.doublePadding),
                ],
              ),
            ),
            enlightenmentSection(),
            Padding(
              padding: const EdgeInsets.all(MySize.defaultPadding),
              child: Column(
                children: [
                  verticalGap(MySize.doublePadding),
                  restUrSpiritSection(context),
                  footer(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
