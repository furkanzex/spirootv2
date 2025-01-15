import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:translator/translator.dart';
import 'package:confetti/confetti.dart';
import 'package:spirootv2/core/constant/my_color.dart';
import 'package:spirootv2/core/constant/my_style.dart';
import 'package:spirootv2/core/constant/my_size.dart';
import 'package:easy_localization/easy_localization.dart' as easy;
import 'package:lottie/lottie.dart';
import 'package:shimmer/shimmer.dart';
import 'package:spirootv2/fortune/services/fortune_service.dart';
import 'package:spirootv2/core/service/usage_limit_service.dart';
import 'package:spirootv2/paywall/paywall_screen.dart';

class AffirmationScreen extends StatefulWidget {
  const AffirmationScreen({super.key});

  @override
  State<AffirmationScreen> createState() => _AffirmationScreenState();
}

class _AffirmationScreenState extends State<AffirmationScreen>
    with TickerProviderStateMixin {
  bool _isLoading = true;
  int _currentAffirmationIndex = 0;
  int _tapCount = 0;
  List<String> _selectedAffirmations = [];
  bool _isCompleted = false;
  late AnimationController _controller;
  final translator = GoogleTranslator();
  late ConfettiController _confettiController;
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _controller.reverse();
      }
    });

    _confettiController =
        ConfettiController(duration: const Duration(seconds: 3));
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeInOut,
    ));

    _checkUsageAndLoad();
  }

  Future<void> _checkUsageAndLoad() async {
    try {
      final remainingUsage =
          await UsageLimitService.getRemainingUsage('affirmation');
      if (!mounted) return;

      if (remainingUsage <= 0) {
        await paywall();
        if (!mounted) return;
        Get.back();
        return;
      }

      await _loadInitialAffirmation();
    } catch (e) {
      if (!mounted) return;
      Get.back();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final newLocale = context.locale.languageCode;
    FortuneService.onLocaleChanged(newLocale);
  }

  Future<void> _loadInitialAffirmation() async {
    if (!mounted) return;

    try {
      final allAffirmations = await FortuneService.loadAffirmations(context);
      if (!mounted) return;

      final random = Random();
      final selectedIndices = <int>{};
      final selectedAffirmations = <String>[];

      while (selectedIndices.length < 5) {
        final randomIndex = random.nextInt(allAffirmations.length);
        if (selectedIndices.add(randomIndex)) {
          selectedAffirmations.add(allAffirmations[randomIndex]);
        }
      }

      if (!mounted) return;
      setState(() {
        _selectedAffirmations = selectedAffirmations;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _selectedAffirmations =
            List.filled(5, easy.tr("rest.affirmation_default"));
        _isLoading = false;
      });
    }
  }

  void _handleTap() async {
    if (_isCompleted) return;

    HapticFeedback.heavyImpact();
    _scaleController.forward().then((_) => _scaleController.reverse());

    setState(() {
      _tapCount++;
    });

    if (_tapCount == 7) {
      if (_currentAffirmationIndex == 4) {
        setState(() {
          _isCompleted = true;
        });
        _confettiController.play();

        // Olumlama tamamlandıktan sonra kullanım hakkını düşür
        final canUse =
            await UsageLimitService.checkAndIncrementUsage('affirmation');
        if (!canUse) {
          if (!mounted) return;
          await paywall();
          if (!mounted) return;
          Get.back();
          return;
        }

        if (!mounted) return;
        Future.delayed(const Duration(seconds: 3), () {
          if (!mounted) return;
          Get.back();
        });
      } else {
        setState(() {
          _currentAffirmationIndex++;
          _tapCount = 0;
        });
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _confettiController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  Widget _buildShimmerContent() {
    return Scaffold(
      backgroundColor: MyColor.darkBackgroundColor,
      appBar: AppBar(
        backgroundColor: MyColor.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: MyColor.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(easy.tr("rest.affirmation"),
            style: MyStyle.b4.copyWith(color: MyColor.white)),
      ),
      body: Stack(
        children: [
          // Progress Bar Shimmer
          Positioned(
            top: MySize.defaultPadding,
            left: MySize.defaultPadding,
            right: MySize.defaultPadding,
            child: Row(
              children: List.generate(
                5,
                (index) => Expanded(
                  child: Shimmer.fromColors(
                    baseColor: MyColor.white.withOpacity(0.1),
                    highlightColor: MyColor.white.withOpacity(0.2),
                    child: Container(
                      margin: EdgeInsets.symmetric(
                          horizontal: MySize.quarterPadding),
                      height: MySize.quarterPadding * 2,
                      decoration: BoxDecoration(
                        color: MyColor.white,
                        borderRadius:
                            BorderRadius.circular(MySize.quarterRadius),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Center Text Shimmer
          Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                Lottie.asset(
                  'assets/lottie/affirmation_bg.json',
                  width: MySize.deviceWidth(context) * 0.9,
                  height: MySize.deviceWidth(context) * 0.9,
                  fit: BoxFit.contain,
                ),
                Shimmer.fromColors(
                  baseColor: MyColor.white.withOpacity(0.1),
                  highlightColor: MyColor.white.withOpacity(0.2),
                  child: Container(
                    width: MySize.deviceWidth(context) * 0.7,
                    height: 100,
                    decoration: BoxDecoration(
                      color: MyColor.white,
                      borderRadius: BorderRadius.circular(MySize.quarterRadius),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Bottom Text Shimmer
          Positioned(
            bottom: MySize.tenQuartersPadding,
            left: MySize.defaultPadding,
            right: MySize.defaultPadding,
            child: Shimmer.fromColors(
              baseColor: MyColor.white.withOpacity(0.1),
              highlightColor: MyColor.white.withOpacity(0.2),
              child: Container(
                height: 20,
                decoration: BoxDecoration(
                  color: MyColor.white,
                  borderRadius: BorderRadius.circular(MySize.quarterRadius),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return _buildShimmerContent();
    }

    return Scaffold(
      backgroundColor: MyColor.darkBackgroundColor,
      appBar: AppBar(
        backgroundColor: MyColor.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: MyColor.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(easy.tr("rest.affirmation"),
            style: MyStyle.b4.copyWith(color: MyColor.white)),
        actions: [
          FutureBuilder<int>(
            future: UsageLimitService.getRemainingUsage('affirmation'),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return SizedBox.shrink();
              return Center(
                child: Padding(
                  padding: EdgeInsets.only(right: MySize.defaultPadding),
                  child: Text(
                    snapshot.data == 999 ? '∞' : '${snapshot.data}x',
                    style: MyStyle.s2.copyWith(
                      color: MyColor.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          GestureDetector(
            onTapDown: (_) => _handleTap(),
            child: Stack(
              children: [
                // Progress Bar
                Positioned(
                  top: MySize.defaultPadding,
                  left: MySize.defaultPadding,
                  right: MySize.defaultPadding,
                  child: Row(
                    children: List.generate(
                      5,
                      (index) => Expanded(
                        child: Container(
                          margin: EdgeInsets.symmetric(
                              horizontal: MySize.quarterPadding),
                          child: ClipRRect(
                            borderRadius:
                                BorderRadius.circular(MySize.quarterRadius),
                            child: LinearProgressIndicator(
                              value: index < _currentAffirmationIndex
                                  ? 1
                                  : index == _currentAffirmationIndex
                                      ? _tapCount / 7
                                      : 0,
                              backgroundColor: MyColor.white.withOpacity(0.1),
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  MyColor.roseColor),
                              minHeight: MySize.quarterPadding * 2,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // Affirmation Text
                Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Lottie.asset(
                        'assets/lottie/affirmation_bg.json',
                        width: MySize.deviceWidth(context) * 0.9,
                        height: MySize.deviceWidth(context) * 0.9,
                        fit: BoxFit.contain,
                      ),
                      AnimatedBuilder(
                        animation: _scaleController,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _scaleAnimation.value,
                            child: Container(
                              padding:
                                  EdgeInsets.all(MySize.defaultPadding * 2),
                              decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.circular(MySize.defaultRadius),
                              ),
                              child: Text(
                                _isCompleted
                                    ? easy.tr("rest.congratulations")
                                    : _selectedAffirmations[
                                        _currentAffirmationIndex],
                                style: MyStyle.s1.copyWith(
                                  color: MyColor.white,
                                  fontStyle: FontStyle.italic,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),

                // Tap Counter
                if (!_isCompleted)
                  Positioned(
                    bottom: MySize.tenQuartersPadding,
                    left: MySize.defaultPadding,
                    right: MySize.defaultPadding,
                    child: Text(
                      easy.tr("rest.tap_count",
                          namedArgs: {"x": (7 - _tapCount).toString()}),
                      style: MyStyle.s2.copyWith(color: MyColor.white),
                      textAlign: TextAlign.center,
                    ),
                  ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirection: pi / 2,
              maxBlastForce: 5,
              minBlastForce: 1,
              emissionFrequency: 0.05,
              numberOfParticles: 50,
              gravity: 0.1,
              shouldLoop: false,
              colors: [
                MyColor.primaryPurpleColor,
                MyColor.primaryLightColor,
                MyColor.goldColor,
                MyColor.roseColor,
              ],
            ),
          ),
        ],
      ),
    );
  }
}
