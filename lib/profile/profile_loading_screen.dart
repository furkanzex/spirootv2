import 'dart:async';
import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:lottie/lottie.dart';
import 'package:get/get.dart';
import 'package:spirootv2/core/constant/my_color.dart';
import 'package:spirootv2/core/constant/my_size.dart';
import 'package:spirootv2/core/constant/my_style.dart';
import 'package:spirootv2/home/homepage.dart';
import 'package:easy_localization/easy_localization.dart' as easy;
import 'package:spirootv2/paywall/paywall_screen.dart';
import 'package:spirootv2/home/home_controller.dart';
import 'package:spirootv2/astrology/astrology_controller.dart';
import 'package:spirootv2/profile/user_controller.dart';

class ProfileLoadingScreen extends StatefulWidget {
  final Future<void> Function() onLoadComplete;

  const ProfileLoadingScreen({
    super.key,
    required this.onLoadComplete,
  });

  @override
  State<ProfileLoadingScreen> createState() => _ProfileLoadingScreenState();
}

class _ProfileLoadingScreenState extends State<ProfileLoadingScreen>
    with SingleTickerProviderStateMixin {
  int _currentStep = 0;
  late AnimationController _shimmerController;

  final List<String> _loadingTexts = [
    easy.tr("profile.profile_loading.0"),
    easy.tr("profile.profile_loading.1"),
    easy.tr("profile.profile_loading.2"),
  ];

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
    _startLoadingSequence();
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  Future<void> _startLoadingSequence() async {
    try {
      for (int i = 0; i < _loadingTexts.length; i++) {
        await Future.delayed(const Duration(seconds: 2));
        if (mounted) {
          setState(() => _currentStep = i);
        }
      }

      if (_currentStep == _loadingTexts.length - 1) {
        await Future.delayed(const Duration(seconds: 2));
      }

      await widget.onLoadComplete();

      if (mounted) {
        await paywall();
        Get.reset();
        Get.offAll(() => const HomePage(), binding: BindingsBuilder(() {
          Get.put(HomeController());
          Get.put(AstrologyController());
          Get.put(UserController());
        }));
      }
    } catch (e) {
      Get.snackbar(
        easy.tr("errors.error"),
        easy.tr("profile.profile_loading.error"),
        backgroundColor: MyColor.errorColor,
        colorText: MyColor.white,
      );
    }
  }

  Widget _buildLoadingText(int index) {
    bool isCurrentStep = index == _currentStep;
    bool isPreviousStep = index < _currentStep;

    return Row(
      children: [
        Icon(
          isPreviousStep || isCurrentStep
              ? MingCute.moon_stars_fill
              : MingCute.moon_stars_line,
          color: isPreviousStep || isCurrentStep
              ? MyColor.primaryLightColor
              : MyColor.textGreyColor,
          size: 24,
        ),
        const SizedBox(width: MySize.halfPadding),
        Expanded(
          child: isPreviousStep || isCurrentStep
              ? Text(
                  _loadingTexts[index],
                  textAlign: TextAlign.left,
                  style: MyStyle.s2.copyWith(
                    color: MyColor.white,
                    shadows: isCurrentStep
                        ? [
                            Shadow(
                              color: MyColor.primaryLightColor.withOpacity(0.5),
                              blurRadius: 12,
                            ),
                            Shadow(
                              color: MyColor.primaryLightColor.withOpacity(0.3),
                              blurRadius: 24,
                            ),
                          ]
                        : null,
                  ),
                )
              : AnimatedBuilder(
                  animation: _shimmerController,
                  builder: (context, child) {
                    return ShaderMask(
                      blendMode: BlendMode.srcIn,
                      shaderCallback: (bounds) {
                        return LinearGradient(
                          colors: [
                            MyColor.textGreyColor.withOpacity(0.5),
                            MyColor.white.withOpacity(0.8),
                            MyColor.textGreyColor.withOpacity(0.5),
                          ],
                          stops: const [0.0, 0.5, 1.0],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          transform: _SlidingGradientTransform(
                            slidePercent: _shimmerController.value,
                          ),
                        ).createShader(bounds);
                      },
                      child: Text(
                        _loadingTexts[index],
                        textAlign: TextAlign.left,
                        style: MyStyle.s2,
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColor.darkBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(MySize.defaultPadding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Lottie.asset(
                'assets/lottie/galaxy.json',
                width: 200,
                height: 200,
              ),
              const SizedBox(height: MySize.doublePadding),
              Column(
                children: List.generate(
                  _loadingTexts.length,
                  (index) => Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: MySize.halfPadding,
                    ),
                    child: _buildLoadingText(index),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SlidingGradientTransform extends GradientTransform {
  const _SlidingGradientTransform({
    required this.slidePercent,
  });

  final double slidePercent;

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    return Matrix4.translationValues(bounds.width * slidePercent, 0.0, 0.0);
  }
}
