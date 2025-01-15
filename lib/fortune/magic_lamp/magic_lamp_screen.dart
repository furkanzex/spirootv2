import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:spirootv2/core/helper/device_helper.dart';
import 'package:translator/translator.dart';
import 'package:spirootv2/core/constant/my_color.dart';
import 'package:spirootv2/core/constant/my_style.dart';
import 'package:spirootv2/core/constant/my_size.dart';
import 'package:easy_localization/easy_localization.dart' as easy;
import 'package:spirootv2/fortune/services/fortune_service.dart';
import 'package:spirootv2/core/service/usage_limit_service.dart';

class MagicLampScreen extends StatefulWidget {
  const MagicLampScreen({super.key});

  @override
  State<MagicLampScreen> createState() => _MagicLampScreenState();
}

class _MagicLampScreenState extends State<MagicLampScreen>
    with SingleTickerProviderStateMixin {
  final List<TrailPoint> _points = [];
  bool _isReading = false;
  String _fortuneMessage = '';
  Timer? _timer;
  Timer? _fadeTimer;
  int _touchDuration = 0;
  final translator = GoogleTranslator();
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  final Random _random = Random();

  final List<Color> _colors = [
    MyColor.white,
    MyColor.secondaryColor,
    MyColor.goldColor,
  ];

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _fadeAnimation =
        Tween<double>(begin: 0.0, end: 1.0).animate(_fadeController);
    _startFadeTimer();
  }

  void _startFadeTimer() {
    _fadeTimer?.cancel();
    _fadeTimer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (_points.isNotEmpty) {
        setState(() {
          for (var point in _points) {
            point.opacity *= 0.97;
            point.width *= 0.995;
          }
          _points.removeWhere((point) => point.opacity < 0.01);
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _fadeTimer?.cancel();
    _fadeController.dispose();
    super.dispose();
  }

  Future<String> _getRandomFortune() async {
    try {
      final messages = await FortuneService.loadFortunes(context);
      return messages[Random().nextInt(messages.length)];
    } catch (e) {
      return easy.tr('fortune.fortune_message');
    }
  }

  void _startReading() async {
    if (!_isReading) {
      final canUse =
          await UsageLimitService.checkAndIncrementUsage('magic_lamp');
      if (!canUse) return;

      HapticFeedback.heavyImpact();

      setState(() {
        _isReading = true;
      });

      String fortune = await _getRandomFortune();
      setState(() {
        _fortuneMessage = fortune;
      });
      _fadeController.forward();
    }
  }

  void _handlePanStart(DragStartDetails details) {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _touchDuration++;
      if (_touchDuration >= 3 && !_isReading) {
        timer.cancel();
        _startReading();
      }
    });
  }

  void _handlePanUpdate(DragUpdateDetails details) {
    if (!_isReading) {
      if (_points.isEmpty || _random.nextInt(10) == 0) {
        HapticFeedback.lightImpact();
      }

      setState(() {
        _points.add(
          TrailPoint(
            position: details.localPosition,
            color: _colors[_random.nextInt(_colors.length)],
            width: 60,
            opacity: 0.9,
          ),
        );
        if (_points.length > 20) {
          _points.removeAt(0);
        }
      });
    }
  }

  void _handlePanEnd(DragEndDetails details) {
    _timer?.cancel();
    _touchDuration = 0;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final newLocale = context.locale.languageCode;
    FortuneService.onLocaleChanged(newLocale);
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
        title: Text(easy.tr('fortune.magic_lamp'),
            style: MyStyle.b4.copyWith(color: MyColor.white)),
        centerTitle: true,
        actions: [
          FutureBuilder<int>(
            future: UsageLimitService.getRemainingUsage('magic_lamp'),
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
      body: GestureDetector(
        onPanStart: _handlePanStart,
        onPanUpdate: _handlePanUpdate,
        onPanEnd: _handlePanEnd,
        child: Stack(
          children: [
            if (!_isReading)
              Padding(
                padding: EdgeInsets.only(
                    top: DeviceHelper.getScreenHeight(context) * 0.1),
                child: Padding(
                  padding: EdgeInsets.all(MySize.defaultPadding),
                  child: Image.asset(
                    "assets/images/magic_lamp.png",
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            CustomPaint(
              painter: TrailPainter(_points),
              size: Size(
                  MySize.deviceWidth(context), MySize.deviceHeight(context)),
            ),
            if (_isReading)
              Center(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Container(
                    padding: EdgeInsets.all(MySize.defaultPadding),
                    margin: EdgeInsets.all(MySize.defaultPadding),
                    decoration: BoxDecoration(
                      color: MyColor.primaryColor.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(MySize.halfRadius),
                      boxShadow: [
                        BoxShadow(
                          color: MyColor.primaryPurpleColor.withOpacity(0.3),
                          blurRadius: 15,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Text(
                      _fortuneMessage,
                      style: MyStyle.s1.copyWith(
                        color: MyColor.white,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            if (!_isReading)
              Positioned(
                bottom: MySize.doublePadding,
                left: MySize.defaultPadding,
                right: MySize.defaultPadding,
                child: Text(
                  easy.tr('fortune.start_magic_lamp'),
                  style: MyStyle.s2.copyWith(
                    color: MyColor.whiteTintColor,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class TrailPoint {
  final Offset position;
  final Color color;
  double width;
  double opacity;

  TrailPoint({
    required this.position,
    required this.color,
    required this.width,
    required this.opacity,
  });
}

class TrailPainter extends CustomPainter {
  final List<TrailPoint> points;

  TrailPainter(this.points);

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;

    for (var i = 0; i < points.length - 1; i++) {
      final current = points[i];
      final next = points[i + 1];

      final paint = Paint()
        ..color = current.color.withOpacity(current.opacity)
        ..strokeWidth = current.width
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15);

      final path = Path();
      path.moveTo(current.position.dx, current.position.dy);

      if (i < points.length - 2) {
        final next2 = points[i + 2];
        final controlPoint1 = Offset(
          current.position.dx + (next.position.dx - current.position.dx) / 2,
          current.position.dy + (next.position.dy - current.position.dy) / 2,
        );
        final controlPoint2 = Offset(
          next.position.dx + (next2.position.dx - next.position.dx) / 2,
          next.position.dy + (next2.position.dy - next.position.dy) / 2,
        );

        path.cubicTo(
          controlPoint1.dx,
          controlPoint1.dy,
          controlPoint2.dx,
          controlPoint2.dy,
          next2.position.dx,
          next2.position.dy,
        );
      } else {
        path.lineTo(next.position.dx, next.position.dy);
      }

      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(TrailPainter oldDelegate) => true;
}

class LampClipper extends CustomClipper<Rect> {
  final Offset center;
  final double radius;

  LampClipper({required this.center, required this.radius});

  @override
  Rect getClip(Size size) {
    return Rect.fromCircle(center: center, radius: radius);
  }

  @override
  bool shouldReclip(LampClipper oldClipper) {
    return center != oldClipper.center || radius != oldClipper.radius;
  }
}
