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
    with SingleTickerProviderStateMixin {
  String _affirmation = '';
  bool _isLoading = true;
  int _currentAffirmationIndex = 0;
  int _tapCount = 0;
  List<String> _selectedAffirmations = [];
  bool _isCompleted = false;
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  final translator = GoogleTranslator();
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _controller.reverse();
      }
    });

    _confettiController =
        ConfettiController(duration: const Duration(seconds: 3));
    _loadInitialAffirmation();
  }

  Future<void> _loadInitialAffirmation() async {
    try {
      final String response =
          await rootBundle.loadString('assets/json/affirmations.json');
      final data = json.decode(response);
      final allAffirmations = List<String>.from(data['affirmations']);

      // Rastgele 5 olumlama seç
      final random = Random();
      while (_selectedAffirmations.length < 5) {
        final randomIndex = random.nextInt(allAffirmations.length);
        final affirmation = allAffirmations[randomIndex];
        if (!_selectedAffirmations.contains(affirmation)) {
          final translation = await translator.translate(
            affirmation,
            to: Localizations.localeOf(context).languageCode,
          );
          _selectedAffirmations.add(translation.text);
        }
      }

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

  Future<String> _getRandomAffirmation() async {
    try {
      final String response =
          await rootBundle.loadString('assets/json/affirmations.json');
      final data = json.decode(response);
      final messages = List<String>.from(data['messages']);
      final randomMessage = messages[Random().nextInt(messages.length)];

      final translation = await translator.translate(
        randomMessage,
        to: Localizations.localeOf(context).languageCode,
      );

      return translation.text;
    } catch (e) {
      return 'Her şey yolunda gidecek!';
    }
  }

  void _handleTap() {
    if (_isCompleted) return;

    HapticFeedback.mediumImpact();

    setState(() {
      _tapCount++;
    });

    _controller.forward(from: 0);

    if (_tapCount >= 7) {
      HapticFeedback.heavyImpact();

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
                                      ? _tapCount / 10
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
                      Padding(
                        padding: EdgeInsets.all(MySize.defaultPadding * 2),
                        child: Text(
                          _isCompleted
                              ? "Tebrikler! Bugünkü olumlamalarınızı tamamladınız! 🎉"
                              : _selectedAffirmations[_currentAffirmationIndex],
                          style: MyStyle.s1.copyWith(
                            color: MyColor.white,
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
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
                      'Bu olumlama için ${10 - _tapCount} tekrar kaldı',
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
                MyColor.primaryColor,
                MyColor.primaryLightColor,
                MyColor.secondaryColor,
                MyColor.thirdColor,
              ],
            ),
          ),
        ],
      ),
    );
  }
}
