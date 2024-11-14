import 'dart:math';

import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:spirootv2/core/constant/my_color.dart';
import 'package:spirootv2/core/constant/my_size.dart';
import 'package:spirootv2/core/constant/my_style.dart';
import 'package:spirootv2/widget/astrology/love_career_money.dart';
import 'package:spirootv2/widget/divider/divider.dart';
import 'package:spirootv2/widget/gap/vertical_gap.dart';
import 'package:easy_localization/easy_localization.dart' as easy;
import 'package:get/get.dart';
import 'package:spirootv2/controller/astrology_controller.dart';
import 'package:share/share.dart';
import 'package:fl_chart/fl_chart.dart';

class AstrologyScreen extends StatelessWidget {
  AstrologyScreen({super.key});

  final AstrologyController astrologyController =
      Get.find<AstrologyController>();

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        // Kullanıcı Bilgileri
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(MySize.defaultPadding),
            child: Column(
              children: [
                // Kullanıcı Adı ve Tarih
                Text(
                  "Furkan Zekiri",
                  style: MyStyle.s1.copyWith(
                    color: MyColor.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "Mart 9, 2002 · 13:3",
                  style: MyStyle.s2.copyWith(
                    color: MyColor.textGreyColor,
                  ),
                ),
                verticalGap(MySize.doublePadding),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Burç Detayları Grid
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildAstroDetail("Sun sign", "Pisces", "♓️"),
                        _buildAstroDetail("Moon sign", "Taurus", "♉️"),
                        _buildAstroDetail("Ascendant", "Libra", "♎️"),
                      ],
                    ),
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [
                                MyColor.primaryColor.withOpacity(0.2),
                                MyColor.primaryLightColor.withOpacity(0.1),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 100,
                          height: 100,
                          child: CircleAvatar(
                            backgroundColor: MyColor.white.withOpacity(0.1),
                            backgroundImage: ExtendedNetworkImageProvider(
                              "https://apptoic.com/spiroot/images/pisces.png",
                              cache: true,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildAstroDetail("Element", "Water", "🌊"),
                        _buildAstroDetail("Polarity", "Feminine", "⚛️"),
                        _buildAstroDetail("Modality", "Mutable", "🔄"),
                      ],
                    ),
                  ],
                ),
                verticalGap(MySize.defaultPadding),
                Container(
                  width: double.infinity,
                  height: MySize.iconSizeMedium,
                  child: ElevatedButton(
                    onPressed: () {
                      // Doğum haritası sayfasına yönlendirme
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: MyColor.white.withOpacity(0.1),
                      foregroundColor: MyColor.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(MySize.halfRadius),
                      ),
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                        horizontal: MySize.defaultPadding,
                        vertical: 12,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons
                              .auto_graph_rounded, // veya astroloji ile ilgili başka bir ikon
                          size: 20,
                        ),
                        const SizedBox(width: MySize.halfPadding),
                        Text(
                          easy.tr("Doğum Haritası"),
                          style: MyStyle.s2.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                verticalGap(MySize.defaultPadding),
                _buildEssentials(),

                // Zaman Seçici
                verticalGap(MySize.defaultPadding),
                divider(),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          _buildTimeButton("YESTERDAY", false),
                          _buildTimeButton("TODAY", true),
                          _buildTimeButton("TOMORROW", false),
                          _buildTimeButton("WEEK", false),
                          _buildTimeButton("MONTH", false),
                        ],
                      ),
                    ],
                  ),
                ),

                // Love, Career, Money Bars
                verticalGap(MySize.doublePadding),
                loveCareerMoney(),

                // Günlük Yorum
                verticalGap(MySize.doublePadding),
                _buildHoroscopeText(),
                verticalGap(MySize.doublePadding),
                _buildCompatibilityTestCard(),
                verticalGap(MySize.doublePadding),
                _buildBiorhythmChart(),
                verticalGap(MySize.doublePadding),
                _buildMoonCalendar(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAstroDetail(String title, String value, String emoji) {
    return Column(
      children: [
        Text(
          title,
          style: MyStyle.s3.copyWith(
            color: MyColor.textGreyColor,
          ),
        ),
        verticalGap(4),
        Text(
          "$emoji $value",
          style: MyStyle.s2.copyWith(
            color: MyColor.white,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildTimeButton(String text, bool isSelected) {
    return Container(
      margin: const EdgeInsets.only(right: MySize.defaultPadding),
      child: TextButton(
        onPressed: () => astrologyController.changeDay(text),
        style: TextButton.styleFrom(
          minimumSize: const Size(44, 44),
          padding:
              const EdgeInsets.symmetric(horizontal: MySize.defaultPadding),
        ),
        child: Obx(() => Text(
              text,
              style: MyStyle.s2.copyWith(
                color: astrologyController.selectedDay.value == text
                    ? MyColor.white
                    : MyColor.primaryLightColor,
                fontWeight: astrologyController.selectedDay.value == text
                    ? FontWeight.bold
                    : FontWeight.normal,
              ),
            )),
      ),
    );
  }

  Widget _buildEssentials() {
    return Obx(() => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Essential:",
              style: MyStyle.s3.copyWith(color: MyColor.textGreyColor),
            ),
            verticalGap(4),
            Text(
              astrologyController.currentHoroscope.essential,
              style: MyStyle.s2.copyWith(
                color: MyColor.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ));
  }

  Widget _buildHoroscopeText() {
    return Obx(() => Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Bugün için yorumun:",
                  style: MyStyle.s2.copyWith(
                    color: MyColor.white,
                    height: 1.5,
                  ),
                ),
                // Paylaş butonu
                IconButton(
                  onPressed: () {
                    Share.share(
                      '${astrologyController.currentHoroscope.horoscopeText}\n\nSpirootV2 uygulamasından paylaşıldı.',
                      subject: 'Günlük Burç Yorumum',
                    );
                  },
                  icon: const Icon(
                    MingCute.upload_line,
                    color: MyColor.primaryLightColor,
                  ),
                  padding:
                      const EdgeInsets.all(12), // 44pt minimum touch target
                  constraints: const BoxConstraints(
                    minWidth: 44,
                    minHeight: 44,
                  ),
                  tooltip: easy.tr("share_horoscope"),
                ),
              ],
            ),
            verticalGap(MySize.defaultPadding),
            Text(
              astrologyController.currentHoroscope.horoscopeText,
              style: MyStyle.s2.copyWith(
                color: MyColor.white,
                height: 1.5,
              ),
            ),
          ],
        ));
  }

  Widget _buildBiorhythmChart() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Başlık ve Açıklama
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              easy.tr("Biyoritim Tablosu"),
              style: MyStyle.s2.copyWith(
                color: MyColor.white,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              "7 Günlük",
              style: MyStyle.s3.copyWith(
                color: MyColor.textGreyColor,
              ),
            ),
          ],
        ),
        verticalGap(MySize.defaultPadding),

        // Grafik Container
        Container(
          height: 220,
          padding: const EdgeInsets.all(MySize.defaultPadding),
          decoration: BoxDecoration(
            color: MyColor.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(MySize.halfRadius),
          ),
          child: LineChart(
            LineChartData(
              gridData: FlGridData(
                show: true,
                drawVerticalLine: true,
                horizontalInterval: 0.5,
                verticalInterval: 1,
                getDrawingHorizontalLine: (value) {
                  return FlLine(
                    color: MyColor.white.withOpacity(0.1),
                    strokeWidth: 1,
                  );
                },
                getDrawingVerticalLine: (value) {
                  return FlLine(
                    color: MyColor.white.withOpacity(0.1),
                    strokeWidth: 1,
                  );
                },
              ),
              titlesData: FlTitlesData(
                show: true,
                topTitles:
                    AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles:
                    AxisTitles(sideTitles: SideTitles(showTitles: false)),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      // Günleri göster
                      final now = DateTime.now();
                      final date = now.add(Duration(days: value.toInt()));
                      return Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          '${date.day}/${date.month}',
                          style: MyStyle.s3.copyWith(
                            color: MyColor.textGreyColor,
                          ),
                        ),
                      );
                    },
                    interval: 1,
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: 0.5,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        '${(value * 100).toInt()}%',
                        style: MyStyle.s3.copyWith(
                          color: MyColor.textGreyColor,
                        ),
                      );
                    },
                  ),
                ),
              ),
              borderData: FlBorderData(show: false),
              minX: 0,
              maxX: 6,
              minY: -1,
              maxY: 1,
              lineBarsData: [
                // Fiziksel (23 günlük döngü)
                LineChartBarData(
                  spots: List.generate(7, (index) {
                    return FlSpot(index.toDouble(), sin(2 * pi * index / 23));
                  }),
                  isCurved: true,
                  color: MyColor.primaryLightColor,
                  dotData: FlDotData(
                    show: true,
                    getDotPainter: (spot, percent, barData, index) {
                      return FlDotCirclePainter(
                        radius: 3,
                        color: MyColor.primaryLightColor,
                        strokeWidth: 1,
                        strokeColor: MyColor.white,
                      );
                    },
                  ),
                ),
                // Duygusal (28 günlük döngü)
                LineChartBarData(
                  spots: List.generate(7, (index) {
                    return FlSpot(index.toDouble(), sin(2 * pi * index / 28));
                  }),
                  isCurved: true,
                  color: MyColor.secondaryColor,
                  dotData: FlDotData(
                    show: true,
                    getDotPainter: (spot, percent, barData, index) {
                      return FlDotCirclePainter(
                        radius: 3,
                        color: MyColor.secondaryColor,
                        strokeWidth: 1,
                        strokeColor: MyColor.white,
                      );
                    },
                  ),
                ),
                // Entelektüel (33 günlük döngü)
                LineChartBarData(
                  spots: List.generate(7, (index) {
                    return FlSpot(index.toDouble(), sin(2 * pi * index / 33));
                  }),
                  isCurved: true,
                  color: Colors.green,
                  dotData: FlDotData(
                    show: true,
                    getDotPainter: (spot, percent, barData, index) {
                      return FlDotCirclePainter(
                        radius: 3,
                        color: Colors.green,
                        strokeWidth: 1,
                        strokeColor: MyColor.white,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
        verticalGap(MySize.defaultPadding),

        // Grafik Açıklamaları
        Column(
          children: [
            _buildLegendItemDetailed(MyColor.primaryLightColor, "Fiziksel",
                "23 günlük döngü - Enerji, güç ve dayanıklılık"),
            verticalGap(8),
            _buildLegendItemDetailed(MyColor.secondaryColor, "Duygusal",
                "28 günlük döngü - Duygu durumu ve hassasiyet"),
            verticalGap(8),
            _buildLegendItemDetailed(Colors.green, "Entelektüel",
                "33 günlük döngü - Zihinsel performans ve yaratıcılık"),
          ],
        ),
      ],
    );
  }

  Widget _buildLegendItemDetailed(
      Color color, String title, String description) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 4,
          color: color,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: MyStyle.s3.copyWith(
                  color: MyColor.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                description,
                style: MyStyle.s3.copyWith(
                  color: MyColor.textGreyColor,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMoonCalendar() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          easy.tr("Ay Takvimi"),
          style: MyStyle.s2.copyWith(
            color: MyColor.white,
            fontWeight: FontWeight.w500,
          ),
        ),
        verticalGap(MySize.defaultPadding),
        Container(
          padding: const EdgeInsets.all(MySize.defaultPadding),
          decoration: BoxDecoration(
            color: MyColor.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(MySize.halfRadius),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "🌕 Dolunay",
                    style: MyStyle.s2.copyWith(
                      color: MyColor.white,
                    ),
                  ),
                  Text(
                    "24 Mart 2024",
                    style: MyStyle.s3.copyWith(
                      color: MyColor.textGreyColor,
                    ),
                  ),
                ],
              ),
              verticalGap(MySize.defaultPadding),
              Text(
                "Dolunay zamanı, duygularınızın yoğun olduğu ve sezgilerinizin güçlendiği bir dönem. İçsel farkındalığınız artabilir ve önemli kararlar almak için uygun bir zaman.",
                style: MyStyle.s2.copyWith(
                  color: MyColor.white,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCompatibilityTestCard() {
    return Container(
      padding: const EdgeInsets.all(MySize.defaultPadding),
      decoration: BoxDecoration(
        color: MyColor.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(MySize.halfRadius),
        border: Border.all(
          color: MyColor.primaryLightColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Başlık ve İkon
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: MyColor.primaryLightColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(MySize.quarterRadius),
                ),
                child: Icon(
                  Icons.favorite_rounded,
                  color: MyColor.primaryLightColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: MySize.defaultPadding),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      easy.tr("astrology.compatibility_test"),
                      style: MyStyle.s2.copyWith(
                        color: MyColor.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      easy.tr("astrology.compatibility_description"),
                      style: MyStyle.s3.copyWith(
                        color: MyColor.textGreyColor,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          verticalGap(MySize.defaultPadding),

          // Test Butonları
          Row(
            children: [
              Expanded(
                child: _buildTestButton(
                  "Aşk Uyumu",
                  Icons.favorite_outline_rounded,
                  () => Get.toNamed('/compatibility/love'),
                ),
              ),
              const SizedBox(width: MySize.defaultPadding),
              Expanded(
                child: _buildTestButton(
                  "Arkadaşlık Uyumu",
                  Icons.people_outline_rounded,
                  () => Get.toNamed('/compatibility/friendship'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTestButton(String text, IconData icon, VoidCallback onPressed) {
    return SizedBox(
      height: 44, // Apple minimum touch target
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          backgroundColor: MyColor.white.withOpacity(0.1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(MySize.quarterRadius),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: MySize.defaultPadding,
            vertical: 8,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: MyColor.primaryLightColor,
            ),
            const SizedBox(width: 8),
            Text(
              text,
              style: MyStyle.s3.copyWith(
                color: MyColor.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
