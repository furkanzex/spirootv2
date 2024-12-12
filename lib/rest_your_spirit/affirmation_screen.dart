import 'dart:math';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:translator/translator.dart';
import 'package:confetti/confetti.dart';
import 'package:spirootv2/core/constant/my_color.dart';
import 'package:spirootv2/core/constant/my_style.dart';
import 'package:spirootv2/core/constant/my_size.dart';
import 'package:easy_localization/easy_localization.dart' as easy;
import 'package:lottie/lottie.dart';

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
    _loadInitialAffirmation();
  }

  Future<void> _loadInitialAffirmation() async {
    try {
      // JSON'u bir kere yükle ve cache'le
      final String response =
          await rootBundle.loadString('assets/json/affirmations.json');
      final data = json.decode(response);
      final allAffirmations = List<String>.from(data['affirmations']);

      // Rastgele 5 affirmation seç
      final random = Random();
      final selectedIndices = <int>{};
      final currentLocale = Localizations.localeOf(context).languageCode;

      // Paralel çeviri işlemleri için Future listesi
      final List<Future<String>> translationFutures = [];

      while (selectedIndices.length < 5) {
        final randomIndex = random.nextInt(allAffirmations.length);
        if (selectedIndices.add(randomIndex)) {
          final affirmation = allAffirmations[randomIndex];
          translationFutures.add(translator
              .translate(affirmation, to: currentLocale)
              .then((translation) => translation.text));
        }
      }

      // Tüm çevirileri paralel olarak bekle
      final translations = await Future.wait(translationFutures);
      _selectedAffirmations = translations;

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      _selectedAffirmations = List.filled(5, 'Her şey yolunda gidecek!');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _handleTap() {
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
        Future.delayed(const Duration(seconds: 3), () {
          Navigator.pop(context);
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

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: MyColor.darkBackgroundColor,
        appBar: AppBar(
          backgroundColor: MyColor.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios, color: MyColor.white),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(easy.tr("Olumlama Egzersizi"),
              style: MyStyle.s1.copyWith(color: MyColor.white)),
        ),
        body: Center(
          child: Container(
            color: MyColor.darkBackgroundColor,
            child: CircularProgressIndicator(
              color: MyColor.primaryColor,
            ),
          ),
        ),
      );
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
        title: Text(easy.tr("Olumlama Egzersizi"),
            style: MyStyle.s1.copyWith(color: MyColor.white)),
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
                                    ? "Tebrikler! Bugünkü olumlamalarınızı tamamladınız! 🎉"
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
                      'Bu olumlama için ${7 - _tapCount} tekrar kaldı',
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
