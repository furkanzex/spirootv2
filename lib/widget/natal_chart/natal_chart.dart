import 'dart:math';
import 'package:easy_localization/easy_localization.dart' as easy;

import 'package:flutter/material.dart';
import 'package:spirootv2/core/constant/my_color.dart';
import 'package:spirootv2/core/constant/my_size.dart';
import 'package:spirootv2/core/constant/my_style.dart';

class NatalChartWidget extends StatelessWidget {
  final Map<String, dynamic> natalChartData;

  const NatalChartWidget({super.key, required this.natalChartData});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MySize.natalChartSize,
      width: MySize.natalChartSize,
      decoration: BoxDecoration(
        color: MyColor.white.withOpacity(0.05),
        shape: BoxShape.circle,
        border: Border.all(
          color: MyColor.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: CustomPaint(
        painter: NatalChartPainter(natalChartData: natalChartData),
      ),
    );
  }
}

class NatalChartPainter extends CustomPainter {
  final Map<String, dynamic> natalChartData;

  NatalChartPainter({required this.natalChartData});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Dış katman için beyaz paint
    final outerPaint = Paint()
      ..color = MyColor.primaryDarkColor
      ..style = PaintingStyle.fill;

    // İç katman için koyu paint
    final innerPaint = Paint()
      ..color = MyColor.white.withOpacity(0.1)
      ..style = PaintingStyle.fill;

    // Çizgiler için paint
    final linePaint = Paint()
      ..color = MyColor.white.withOpacity(0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // Dış beyaz halka
    canvas.drawCircle(center, radius, outerPaint);
    // İç koyu daire
    canvas.drawCircle(center, radius * 0.85, innerPaint);

    // 12 burç bölümü
    for (int i = 0; i < 12; i++) {
      final startAngle = (i * 30 - 90) * pi / 180;

      // Dış halkadaki bölümleri ayıran çizgiler
      canvas.drawLine(
        Offset(
          center.dx + radius * 0.85 * cos(startAngle),
          center.dy + radius * 0.85 * sin(startAngle),
        ),
        Offset(
          center.dx + radius * cos(startAngle),
          center.dy + radius * sin(startAngle),
        ),
        linePaint,
      );

      // Burç isimleri
      final textAngle = (i * 30 + 15 - 90) * pi / 180;
      final textRadius = radius * 0.925; // İsimler için özel radius
      final textOffset = Offset(
        center.dx + textRadius * cos(textAngle),
        center.dy + textRadius * sin(textAngle),
      );

      final textPainter = TextPainter(
        text: TextSpan(
          text: _getZodiacName(i),
          style: MyStyle.s3.copyWith(color: MyColor.white),
        ),
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
      );

      canvas.save();
      canvas.translate(textOffset.dx, textOffset.dy);

      // Metni teğet olarak yerleştir
      double rotationAngle = textAngle + pi / 2;
      if (textAngle > -pi / 2 && textAngle < pi / 2) {
        rotationAngle += pi;
      }
      canvas.rotate(rotationAngle);

      textPainter.text = TextSpan(
        text: _getZodiacName(i),
        style: MyStyle.s4
            .copyWith(color: MyColor.white, fontWeight: FontWeight.w100),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(-textPainter.width / 2, -textPainter.height / 2),
      );

      canvas.restore();
    }

    // Derece çizgileri
    for (int i = 0; i < 72; i++) {
      final angle = (i * 5 - 90) * pi / 180;
      final isMainDegree = i % 6 == 0;
      final startRadius = radius * (isMainDegree ? 0.85 : 0.87);
      final endRadius = radius * 0.85;

      canvas.drawLine(
        Offset(
          center.dx + startRadius * cos(angle),
          center.dy + startRadius * sin(angle),
        ),
        Offset(
          center.dx + endRadius * cos(angle),
          center.dy + endRadius * sin(angle),
        ),
        linePaint..strokeWidth = isMainDegree ? 1.0 : 0.5,
      );
    }

    // İç içerik için yeni metod
    _drawInnerContent(canvas, center, radius * 0.85);
  }

  void _drawInnerContent(Canvas canvas, Offset center, double radius) {
    final innerPaint = Paint()
      ..color = MyColor.white.withOpacity(0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // İç çemberler
    canvas.drawCircle(center, radius * 0.85, innerPaint);
    canvas.drawCircle(center, radius * 0.7, innerPaint);

    // Gezegen konumları ve açı çizgileri burada çizilecek
    _drawPlanets(
        canvas,
        center,
        radius * 0.75,
        TextPainter(
          textDirection: TextDirection.ltr,
          textAlign: TextAlign.center,
        ));
    _drawAspectLines(canvas, center, radius * 0.7);
  }

  void _drawPlanets(
      Canvas canvas, Offset center, double radius, TextPainter textPainter) {
    final planets = natalChartData['planets'] as Map<String, dynamic>;

    planets.forEach((planet, details) {
      final angle = (details['longitude'] as double) * pi / 180;
      final position = Offset(
        center.dx + radius * cos(angle),
        center.dy + radius * sin(angle),
      );

      textPainter.text = TextSpan(
        text: _getPlanetSymbol(planet),
        style: const TextStyle(
          color: MyColor.white,
          fontSize: 16,
        ),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        position.translate(-textPainter.width / 2, -textPainter.height / 2),
      );
    });
  }

  void _drawAspectLines(Canvas canvas, Offset center, double radius) {
    final planets = natalChartData['planets'] as Map<String, dynamic>;
    final aspectPaint = Paint()
      ..color = MyColor.white.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    // Gezegenlerin birbirleriyle olan açılarını çiz
    final planetList = planets.entries.toList();
    for (int i = 0; i < planetList.length; i++) {
      for (int j = i + 1; j < planetList.length; j++) {
        final angle1 = (planetList[i].value['longitude'] as double) * pi / 180;
        final angle2 = (planetList[j].value['longitude'] as double) * pi / 180;

        canvas.drawLine(
          Offset(
            center.dx + radius * cos(angle1),
            center.dy + radius * sin(angle1),
          ),
          Offset(
            center.dx + radius * cos(angle2),
            center.dy + radius * sin(angle2),
          ),
          aspectPaint,
        );
      }
    }
  }

  String _getZodiacName(int index) {
    final signs = [
      'aries',
      'taurus',
      'gemini',
      'cancer',
      'leo',
      'virgo',
      'libra',
      'scorpio',
      'sagittarius',
      'capricorn',
      'aquarius',
      'pisces'
    ];
    return easy.tr('astrology.zodiac.${signs[index]}.name').toUpperCase();
  }

  String _getPlanetSymbol(String planet) {
    final symbols = {
      'Sun': '☉',
      'Moon': '☽',
      'Mercury': '☿',
      'Venus': '♀',
      'Mars': '♂',
      'Jupiter': '♃',
      'Saturn': '♄',
      'Uranus': '⛢',
      'Neptune': '♆',
      'Pluto': '♇',
    };
    return symbols[planet] ?? planet[0];
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
