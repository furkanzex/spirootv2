import 'dart:async';
import 'dart:math';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:translator/translator.dart';
import 'package:spirootv2/core/constant/my_color.dart';
import 'package:spirootv2/core/constant/my_style.dart';
import 'package:spirootv2/core/constant/my_size.dart';
import 'package:easy_localization/easy_localization.dart' as easy;

class MagicOrbScreen extends StatefulWidget {
  const MagicOrbScreen({super.key});

  @override
  State<MagicOrbScreen> createState() => _MagicOrbScreenState();
}

class _MagicOrbScreenState extends State<MagicOrbScreen>
    with SingleTickerProviderStateMixin {
  final List<Offset> _points = [];
  bool _isReading = false;
  String _fortuneMessage = '';
  Timer? _timer;
  int _touchDuration = 0;
  final translator = GoogleTranslator();
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _fadeAnimation =
        Tween<double>(begin: 0.0, end: 1.0).animate(_fadeController);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _fadeController.dispose();
    super.dispose();
  }

  Future<String> _getRandomFortune() async {
    try {
      final String response =
          await rootBundle.loadString('assets/json/fortunes.json');
      final data = json.decode(response);
      final messages = List<String>.from(data['messages']);
      final randomMessage = messages[Random().nextInt(messages.length)];

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

  void _startReading() async {
    if (!_isReading) {
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
      if (_touchDuration >= 10 && !_isReading) {
        timer.cancel();
        _startReading();
      }
    });
  }

  void _handlePanUpdate(DragUpdateDetails details) {
    if (!_isReading) {
      setState(() {
        _points.add(details.localPosition);
        if (_points.length > 10) {
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
        title: Text(
          easy.tr("fortune.magic_orb"),
          style: MyStyle.b4.copyWith(color: MyColor.white),
        ),
        centerTitle: true,
      ),
      body: GestureDetector(
        onPanStart: _handlePanStart,
        onPanUpdate: _handlePanUpdate,
        onPanEnd: _handlePanEnd,
        child: Stack(
          children: [
            Container(
              width: double.infinity,
              height: double.infinity,
              color: MyColor.darkBackgroundColor,
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
                  easy.tr("fortune.magic_orb_guide"),
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

class TrailPainter extends CustomPainter {
  final List<Offset> points;

  TrailPainter(this.points);

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;

    final paint = Paint()
      ..color = MyColor.primaryPurpleColor.withOpacity(0.5)
      ..strokeWidth = 30
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);

    final path = Path();
    path.moveTo(points.first.dx, points.first.dy);

    for (var i = 0; i < points.length - 1; i++) {
      final p0 = points[i];
      final p1 = points[i + 1];
      path.quadraticBezierTo(
        p0.dx,
        p0.dy,
        (p0.dx + p1.dx) / 2,
        (p0.dy + p1.dy) / 2,
      );
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(TrailPainter oldDelegate) => true;
}
