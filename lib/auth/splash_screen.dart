import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:spirootv2/auth/welcome_screen.dart';
import 'package:spirootv2/core/constant/my_color.dart';
import 'package:spirootv2/core/constant/my_style.dart';
import 'package:flutter/material.dart';
import 'package:spirootv2/core/constant/my_text.dart';
import 'package:spirootv2/auth/auth_controller.dart';
import 'package:spirootv2/core/service/notification_service.dart';
import 'package:spirootv2/home/homepage.dart';
import 'package:easy_localization/easy_localization.dart' as easy;

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  double _fontSize = 2;
  double _containerSize = 1.5;
  double _textOpacity = 0.0;
  double _containerOpacity = 0.0;

  late AnimationController _controller;
  late Animation<double> animation1;
  List<Timer> _timers = [];

  final AuthController controller = Get.put(AuthController());
  bool isLogin = false;
  bool isRegistered = false;

  final notificationService = Get.find<NotificationService>();

  @override
  void initState() {
    super.initState();

    // Yarın, diğer gün ve sonraki gün için bildirim planla
    final now = DateTime.now();

    for (var i = 1; i < 8; i++) {
      final date = now.add(Duration(days: i));
      final randomIndex = DateTime.now().microsecondsSinceEpoch % 25;
      final String title = easy.tr('notifications.daily_horoscope_title');
      final String body =
          easy.tr('notifications.daily_horoscope_messages.$randomIndex');

      // Üç gün için bildirimleri planla
      notificationService.scheduleAstrologyNotifications(
        title: title,
        body: body,
        scheduledDate: date,
      );
    }

    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 3));

    animation1 = Tween<double>(begin: 40, end: 20).animate(CurvedAnimation(
        parent: _controller, curve: Curves.fastLinearToSlowEaseIn))
      ..addListener(() {
        if (mounted) {
          setState(() {
            _textOpacity = 1.0;
          });
        }
      });

    _controller.forward();

    _timers.add(Timer(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _fontSize = 1.06;
        });
      }
    }));

    _timers.add(Timer(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _containerSize = 2;
          _containerOpacity = 1;
        });
      }
    }));

    checkIfLogin();

    _timers.add(Timer(const Duration(seconds: 4), () async {
      if (!mounted) return;

      if (controller.isLogin.value) {
        isRegistered = await controller
            .checkUserInFirestore(FirebaseAuth.instance.currentUser!.uid);
      }

      if (mounted) {
        Navigator.pushReplacement(
          context,
          PageTransition(
            controller.isLogin.value && controller.isRegistered.value
                ? const HomePage()
                : WelcomeScreen(),
          ),
        );
      }
    }));
  }

  void checkIfLogin() async {
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user != null && mounted) {
        setState(() {
          isLogin = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    for (var timer in _timers) {
      timer.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: MyColor.darkBackgroundColor,
      body: Stack(
        children: [
          Column(
            children: [
              AnimatedContainer(
                  duration: const Duration(milliseconds: 2000),
                  curve: Curves.fastLinearToSlowEaseIn,
                  height: height / _fontSize),
              AnimatedOpacity(
                duration: const Duration(milliseconds: 1000),
                opacity: _textOpacity,
                child: Text(
                  MyText.appName,
                  style: MyStyle.b3.copyWith(color: MyColor.textWhiteColor),
                ),
              ),
            ],
          ),
          Center(
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 1000),
              opacity: _containerOpacity,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 2000),
                curve: Curves.fastLinearToSlowEaseIn,
                height: width / _containerSize,
                width: width / _containerSize,
                alignment: Alignment.center,
                child: Image.asset('assets/images/logo.png'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class PageTransition extends PageRouteBuilder {
  final Widget page;

  PageTransition(this.page)
      : super(
          pageBuilder: (context, animation, anotherAnimation) => page,
          transitionDuration: const Duration(milliseconds: 2000),
          transitionsBuilder: (context, animation, anotherAnimation, child) {
            animation = CurvedAnimation(
              curve: Curves.fastLinearToSlowEaseIn,
              parent: animation,
            );
            return Align(
              alignment: Alignment.bottomCenter,
              child: SizeTransition(
                sizeFactor: animation,
                axisAlignment: 0,
                child: page,
              ),
            );
          },
        );
}
