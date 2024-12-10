import 'dart:math';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:translator/translator.dart';
import 'package:spirootv2/core/constant/my_color.dart';
import 'package:spirootv2/core/constant/my_style.dart';
import 'package:spirootv2/core/constant/my_size.dart';
import 'package:easy_localization/easy_localization.dart' as easy;

class FortuneCookieScreen extends StatefulWidget {
  const FortuneCookieScreen({super.key});

  @override
  State<FortuneCookieScreen> createState() => _FortuneCookieScreenState();
}

class _FortuneCookieScreenState extends State<FortuneCookieScreen>
    with SingleTickerProviderStateMixin {
  int _tapCount = 0;
  bool _isBroken = false;
  bool _showMessage = false;
  String _fortuneMessage = '';
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotateAnimation;
  late Animation<double> _slideAnimation;
  final translator = GoogleTranslator();

  Future<String> _getRandomFortune() async {
    try {
      final String response =
          await rootBundle.loadString('assets/json/fortune_cookie.json');
      final data = json.decode(response);
      final messages = List<String>.from(data['messages']);
      final randomMessage = messages[Random().nextInt(messages.length)];

      // Çeviri işlemi
      final translation = await translator.translate(
        randomMessage,
        to: Localizations.localeOf(context).languageCode,
      );

      return translation.text;
    } catch (e) {
      print('Fortune message error: $e');
      return 'Şansınız her zaman sizinle olsun!';
    }
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: _isBroken ? 1.5 : 1.2,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: _isBroken ? Curves.elasticOut : Curves.easeInOut,
    ));

    _rotateAnimation = Tween<double>(
      begin: 0,
      end: _isBroken ? 0.3 : 0.1,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: _isBroken ? Curves.elasticOut : Curves.easeInOut,
    ));

    _slideAnimation = Tween<double>(
      begin: 0,
      end: -200,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        if (!_isBroken) {
          _controller.reverse();
        }
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    if (_isBroken) return;

    setState(() {
      _tapCount++;
    });

    _controller.forward(from: 0);

    if (_tapCount >= 10) {
      setState(() {
        _isBroken = true;
      });

      _controller.duration = const Duration(milliseconds: 800);
      _controller.forward(from: 0);

      // Mesajı getir ve çevir
      _getRandomFortune().then((message) {
        setState(() {
          _fortuneMessage = message;
          _showMessage = true;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColor.darkBackgroundColor,
      appBar: AppBar(
        backgroundColor: MyColor.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: MyColor.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(easy.tr("Şans Kurabiyesi"),
            style: MyStyle.s1.copyWith(color: MyColor.white)),
      ),
      body: GestureDetector(
        onTapDown: (_) => _handleTap(),
        child: Stack(
          children: [
            // Progress Bar
            Positioned(
              top: MySize.defaultPadding,
              left: MySize.defaultPadding,
              right: MySize.defaultPadding,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(MySize.quarterRadius),
                child: LinearProgressIndicator(
                  value: _tapCount / 10,
                  backgroundColor: MyColor.white.withOpacity(0.1),
                  valueColor:
                      AlwaysStoppedAnimation<Color>(MyColor.primaryLightColor),
                  minHeight: MySize.quarterPadding * 2,
                ),
              ),
            ),

            // Fortune Cookie
            Center(
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, _isBroken ? _slideAnimation.value : 0),
                    child: Transform.scale(
                      scale: _scaleAnimation.value,
                      child: Transform.rotate(
                        angle: _rotateAnimation.value,
                        child: Image.asset(
                          _isBroken
                              ? 'assets/images/fortune_cookie_broken.png'
                              : 'assets/images/fortune_cookie_whole.png',
                          width: MySize.cardWidth * 0.8,
                          height: MySize.cardWidth * 0.8,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // Şans Mesajı
            if (_showMessage)
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 800),
                curve: Curves.elasticOut,
                builder: (context, value, child) {
                  return Transform.translate(
                    offset: Offset(0, 50 * (1 - value)),
                    child: Opacity(
                      opacity: value.clamp(0.0, 1.0),
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.all(MySize.defaultPadding),
                          margin: const EdgeInsets.all(MySize.defaultPadding),
                          decoration: BoxDecoration(
                            color: MyColor.primaryLightColor.withOpacity(0.1),
                            borderRadius:
                                BorderRadius.circular(MySize.quarterRadius),
                            border: Border.all(
                              color: MyColor.primaryLightColor,
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color:
                                    MyColor.primaryLightColor.withOpacity(0.2),
                                blurRadius: MySize.quarterRadius,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: Text(
                            _fortuneMessage,
                            style: MyStyle.s1.copyWith(
                              color: MyColor.white,
                              fontStyle: FontStyle.italic,
                              height: 1.5,
                              shadows: [
                                Shadow(
                                  color: MyColor.primaryLightColor
                                      .withOpacity(0.5),
                                  blurRadius: MySize.quarterRadius,
                                ),
                              ],
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),

            // Tıklama Yönergesi
            if (!_isBroken)
              Positioned(
                bottom: MySize.tenQuartersPadding,
                left: MySize.defaultPadding,
                right: MySize.defaultPadding,
                child: Text(
                  'Kurabiyeyi kırmak için ekrana dokun (${10 - _tapCount} dokunuş kaldı)',
                  style: MyStyle.s2.copyWith(color: MyColor.white),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
