import 'dart:math';

import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:spirootv2/core/constant/my_color.dart';
import 'package:spirootv2/core/constant/my_icon.dart';
import 'package:spirootv2/core/constant/my_image.dart';
import 'package:spirootv2/core/constant/my_size.dart';
import 'package:spirootv2/core/constant/my_style.dart';
import 'package:spirootv2/core/widget/gap/horizontal_gap.dart';
import 'package:spirootv2/profile/profile_onboarding.dart';
import 'package:spirootv2/astrology/love_career_money.dart';
import 'package:spirootv2/core/widget/divider/divider.dart';
import 'package:spirootv2/core/widget/gap/vertical_gap.dart';
import 'package:easy_localization/easy_localization.dart' as easy;
import 'package:get/get.dart';
import 'package:spirootv2/astrology/astrology_controller.dart';
import 'package:share/share.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:spirootv2/profile/user_controller.dart';
import 'package:spirootv2/core/service/natal_chart_service.dart';
import 'package:spirootv2/astrology/natal_chart.dart';

class AstrologyScreen extends StatefulWidget {
  const AstrologyScreen({super.key});

  @override
  State<AstrologyScreen> createState() => _AstrologyScreenState();
}

class _AstrologyScreenState extends State<AstrologyScreen> {
  final UserController _userController = Get.find<UserController>();
  final AstrologyController _astrologyController =
      Get.put(AstrologyController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColor.transparent,
      body: SafeArea(
        child: Obx(() {
          // UserController'dan profil tamamlanma durumunu kontrol et
          if (_userController.currentUser.value == null ||
              !_userController.currentUser.value!.isProfileComplete) {
            return _buildProfileIncomplete();
          }
          return _buildAstrologyContent();
        }),
      ),
    );
  }

  Widget _buildProfileIncomplete() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.all(MySize.defaultPadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Üst Görsel
            SizedBox(
              height: MySize.welcomeImageSize,
              width: MySize.welcomeImageSize,
              child: SvgPicture.asset(MyImage.welcomeImage),
            ),
            verticalGap(MySize.doublePadding),

            // Ana Başlık
            Text(
              easy.tr("Yıldızların Sana\nNeler Söylediğini Keşfet"),
              textAlign: TextAlign.center,
              style: MyStyle.s1.copyWith(
                color: MyColor.white,
                fontSize: 32,
                height: 1.3,
                fontWeight: FontWeight.bold,
              ),
            ),
            verticalGap(MySize.defaultPadding),

            // Alt Başlık
            Text(
              easy.tr(
                  "Kişiselleştirilmiş astrolojik içgörülerle\nhayatını aydınlat"),
              textAlign: TextAlign.center,
              style: MyStyle.s2.copyWith(
                color: MyColor.textGreyColor,
                fontSize: 16,
                height: 1.5,
              ),
            ),
            verticalGap(MySize.doublePadding),
// Başla Butonu
            Container(
              width: 280,
              height: 60,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    MyColor.primaryColor,
                    MyColor.secondaryColor,
                  ],
                ),
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: MyColor.primaryColor.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => Get.to(ProfileOnboarding()),
                  borderRadius: BorderRadius.circular(30),
                  child: Center(
                    child: Text(
                      easy.tr("Yolculuğa Başla"),
                      style: MyStyle.s1.copyWith(
                        color: MyColor.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            verticalGap(MySize.doublePadding * 2),
            // Özellik Kartları
            Wrap(
              spacing: MySize.defaultPadding,
              runSpacing: MySize.defaultPadding,
              alignment: WrapAlignment.center,
              children: [
                _buildFeatureCard(
                  icon: "🌌",
                  title: "Burç Kartı",
                  subtitle: "Kişisel burç kartını gör",
                ),
                _buildFeatureCard(
                  icon: "🌠",
                  title: "Doğum Haritası",
                  subtitle: "Kişisel astrolojik haritanı gör",
                ),
                _buildFeatureCard(
                  icon: "🎯",
                  title: "Öngörü ve Tavsiyeler",
                  subtitle: "Günlük öngörüler ve tavsiyeler al",
                ),
                _buildFeatureCard(
                  icon: "💫",
                  title: "Uyumluluk",
                  subtitle: "İlişki ve uyum analizleri yaptır",
                ),
                _buildFeatureCard(
                  icon: "📈",
                  title: "Biyoritim Analizi",
                  subtitle: "Kişisel biyoritim analizini ve tablonu gör",
                ),
                /*_buildFeatureCard(
                  icon: "🌘",
                  title: "Ay Takvimi",
                  subtitle: "Kişisel ay takvimini gör",
                ),*/
              ],
            ),
            verticalGap(MySize.doublePadding * 2),
          ],
        ),
      ),
    );
  }

  Widget _buildAstrologyContent() {
    // Burç detaylarını al
    final zodiacSign = _userController.currentUser.value!.zodiacSign;
    final moonSign = _userController.currentUser.value!.moonSign;
    final ascendant = _userController.currentUser.value!.ascendant;

    // Burç detaylarını getir
    final zodiacDetails =
        _astrologyController.getZodiacDetailsByName(zodiacSign);
    final moonDetails = _astrologyController.getZodiacDetailsByName(moonSign);
    final ascendantDetails =
        _astrologyController.getZodiacDetailsByName(ascendant);

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.all(MySize.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profil Bilgileri
            Center(
              child: Column(
                children: [
                  Text(
                    _userController.currentUser.value!.name,
                    style: MyStyle.s1.copyWith(
                      color: MyColor.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "${DateFormat('MMMM d, yyyy').format(_userController.currentUser.value!.birthDate)} · ${_userController.currentUser.value!.birthTime}",
                    style: MyStyle.s2.copyWith(
                      color: MyColor.textGreyColor,
                    ),
                  ),
                ],
              ),
            ),
            verticalGap(MySize.doublePadding),

            // Burç Detayları
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Burç Detayları Grid
                Flexible(
                  flex: 1,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildAstroDetail(
                        "Güneş Burcu",
                        zodiacDetails['name'] ?? '',
                        zodiacDetails['symbol'] ?? '',
                      ),
                      _buildAstroDetail(
                        "Ay Burcu",
                        moonDetails['name'] ?? '',
                        moonDetails['symbol'] ?? '',
                      ),
                      _buildAstroDetail(
                        "Yükselen",
                        ascendantDetails['name'] ?? '',
                        ascendantDetails['symbol'] ?? '',
                      ),
                    ],
                  ),
                ),
                Flexible(
                  flex: 1,
                  child: Stack(
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
                            "https://apptoic.com/spiroot/images/$zodiacSign.png",
                            cache: true,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Flexible(
                  flex: 1,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildAstroDetail(
                        "Element",
                        zodiacDetails['element'] ?? '',
                        _getElementEmoji(zodiacDetails['element'] ?? ''),
                      ),
                      _buildAstroDetail(
                        "Nitelik",
                        zodiacDetails['quality'] ?? '',
                        _getQualityEmoji(zodiacDetails['quality'] ?? ''),
                      ),
                      _buildAstroDetail(
                        "Yönetici",
                        zodiacDetails['ruler'] ?? '',
                        "⭐",
                      ),
                    ],
                  ),
                ),
              ],
            ),
            verticalGap(MySize.defaultPadding),

            _buildCharacteristics(zodiacDetails['characteristics'] ?? ''),

            // Zaman Seçici
            verticalGap(MySize.defaultPadding),
            divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildTimeButton(
                  "astrology.horoscope.dates.today",
                  _astrologyController.selectedDay.value ==
                      "astrology.horoscope.dates.today",
                ),
                _buildTimeButton(
                  "astrology.horoscope.dates.week",
                  _astrologyController.selectedDay.value ==
                      "astrology.horoscope.dates.week",
                ),
                _buildTimeButton(
                  "astrology.horoscope.dates.month",
                  _astrologyController.selectedDay.value ==
                      "astrology.horoscope.dates.month",
                ),
              ],
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
            /*verticalGap(MySize.doublePadding),
            _buildMoonCalendar(),*/
            verticalGap(MySize.doublePadding),
            _buildNatalChart(),
          ],
        ),
      ),
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
    String displayText = easy.tr(text);

    return Container(
      margin: const EdgeInsets.only(right: MySize.defaultPadding),
      child: TextButton(
        onPressed: () {
          _astrologyController.changeDay(text);
        },
        style: TextButton.styleFrom(
          minimumSize: const Size(44, 44),
          padding:
              const EdgeInsets.symmetric(horizontal: MySize.defaultPadding),
          backgroundColor: isSelected
              ? MyColor.primaryColor.withOpacity(0.2)
              : Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(MySize.quarterRadius),
          ),
        ),
        child: Text(
          displayText,
          style: MyStyle.s2.copyWith(
            color: isSelected ? MyColor.white : MyColor.primaryLightColor,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildCharacteristics(String characteristics) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "Karakteristik",
              style: MyStyle.s3.copyWith(color: MyColor.textGreyColor),
            ),
            verticalGap(4),
            Text(
              characteristics,
              style: MyStyle.s2.copyWith(
                color: MyColor.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHoroscopeText() {
    return Obx(() {
      String displayText = "";
      switch (_astrologyController.selectedDay.value) {
        case "astrology.horoscope.dates.today":
          displayText = easy.tr("astrology.horoscope.for_dates.today");
          break;
        case "astrology.horoscope.dates.week":
          displayText = easy.tr("astrology.horoscope.for_dates.week");
          break;
        case "astrology.horoscope.dates.month":
          displayText = easy.tr("astrology.horoscope.for_dates.month");
          break;
        default:
          displayText = easy.tr("astrology.horoscope.for_dates.today");
      }

      return Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "$displayText:",
                style: MyStyle.s2.copyWith(
                  color: MyColor.white,
                  height: 1.5,
                ),
              ),
              if (_astrologyController.isHoroscopeAvailable.value)
                IconButton(
                  onPressed: () {
                    Share.share(
                      'SPIROOT uygulamasından paylaşıldı.\n\n${_astrologyController.selectedHoroscope.value.horoscopeText}',
                      subject: 'Astroloji Yorumum',
                    );
                  },
                  icon: const Icon(
                    MingCute.upload_line,
                    color: MyColor.primaryLightColor,
                  ),
                  padding: const EdgeInsets.all(12),
                  constraints: const BoxConstraints(
                    minWidth: 44,
                    minHeight: 44,
                  ),
                  tooltip: "Paylaş",
                ),
            ],
          ),
          verticalGap(MySize.defaultPadding),
          if (_astrologyController.isLoading.value)
            Column(
              children: [
                const CircularProgressIndicator(),
                verticalGap(MySize.defaultPadding),
                Text(
                  "✨ Yıldızlar sizin için konuşuyor...",
                  style: MyStyle.s3.copyWith(
                    color: MyColor.textGreyColor,
                    fontWeight: FontWeight.w500,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            )
          else if (_astrologyController.isHoroscopeAvailable.value)
            Container(
              padding: const EdgeInsets.all(MySize.defaultPadding),
              decoration: BoxDecoration(
                color: MyColor.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(MySize.halfRadius),
                border: Border.all(
                  color: MyColor.primaryLightColor.withOpacity(0.1),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Genel Yorum
                  Text(
                    _astrologyController.selectedHoroscope.value.horoscopeText,
                    style: MyStyle.s2.copyWith(
                      color: MyColor.white,
                      height: 1.5,
                    ),
                  ),
                  verticalGap(MySize.defaultPadding),
                  divider(),
                  verticalGap(MySize.defaultPadding),

                  // Detaylı Yorumlar
                  if (_astrologyController.selectedHoroscope.value.details !=
                      null) ...[
                    // Aşk Yorumu
                    _buildDetailSection(
                      "💝 Aşk & İlişkiler",
                      _astrologyController.selectedHoroscope.value
                          .details!['love']['prediction'],
                      _astrologyController
                          .selectedHoroscope.value.details!['love']['advice'],
                    ),
                    verticalGap(MySize.defaultPadding),

                    // Kariyer Yorumu
                    _buildDetailSection(
                      "💼 Kariyer",
                      _astrologyController.selectedHoroscope.value
                          .details!['career']['prediction'],
                      _astrologyController
                          .selectedHoroscope.value.details!['career']['advice'],
                    ),
                    verticalGap(MySize.defaultPadding),

                    // Para Yorumu
                    _buildDetailSection(
                      "💰 Finansal",
                      _astrologyController.selectedHoroscope.value
                          .details!['money']['prediction'],
                      _astrologyController
                          .selectedHoroscope.value.details!['money']['advice'],
                    ),
                    verticalGap(MySize.defaultPadding),
                    divider(),
                    verticalGap(MySize.defaultPadding),

                    // Şanslı Bilgiler
                    Text(
                      "✨ Şanslı Detaylar",
                      style: MyStyle.s2.copyWith(
                        color: MyColor.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    verticalGap(MySize.halfPadding),

                    // Şanslı Sayılar
                    _buildLuckyItem(
                      "🔢 Şanslı Sayılar:",
                      _astrologyController
                          .selectedHoroscope.value.details!['lucky']['numbers']
                          .join(', '),
                    ),
                    verticalGap(MySize.quarterPadding),

                    // Şanslı Renkler
                    _buildLuckyItem(
                      "🎨 Şanslı Renkler:",
                      _astrologyController
                          .selectedHoroscope.value.details!['lucky']['colors']
                          .join(', '),
                    ),
                    verticalGap(MySize.quarterPadding),

                    // Şanslı Günler
                    if (_astrologyController
                            .selectedHoroscope.value.details!['lucky']['days']
                            .join(', ') !=
                        "")
                      _buildLuckyItem(
                        "📅 Şanslı Günler:",
                        _astrologyController
                            .selectedHoroscope.value.details!['lucky']['days']
                            .join(', '),
                      ),
                  ],
                ],
              ),
            )
          else
            Container(
              padding: const EdgeInsets.all(MySize.defaultPadding),
              decoration: BoxDecoration(
                color: MyColor.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(MySize.halfRadius),
                border: Border.all(
                  color: MyColor.primaryLightColor.withOpacity(0.1),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: MyColor.primaryColor.withOpacity(0.05),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Astroloji İkonu ve Efektler
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      // Arka plan efekti
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [
                              MyColor.primaryColor.withOpacity(0.2),
                              MyColor.secondaryColor.withOpacity(0.1),
                            ],
                          ),
                        ),
                      ),
                      // Yıldız efekti
                      Transform.rotate(
                        angle: pi / 4,
                        child: Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            gradient: LinearGradient(
                              colors: [
                                MyColor.primaryLightColor.withOpacity(0.2),
                                MyColor.primaryColor.withOpacity(0.1),
                              ],
                            ),
                          ),
                        ),
                      ),
                      // İkon
                      Icon(
                        MingCute.planet_line,
                        color: MyColor.white,
                        size: MySize.iconSizeMedium,
                      ),
                    ],
                  ),
                  verticalGap(MySize.defaultPadding),

                  // Samimi Mesaj
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: MyStyle.s2.copyWith(
                        color: MyColor.white,
                        height: 1.5,
                      ),
                      children: [
                        TextSpan(
                          text:
                              "✨ Merhaba değerli ${easy.tr("astrology.zodiac.${_userController.currentUser.value!.zodiacSign}.name")} burcu,\nyıldızlar senin için özel mesajlar hazırladı!",
                          style: MyStyle.s2.copyWith(
                            color: MyColor.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),

                  verticalGap(MySize.defaultPadding),

                  // Keşfet Butonu
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (_astrologyController.isLoading.value) return;

                        await _astrologyController.generateHoroscope();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: MyColor.primaryColor,
                        foregroundColor: MyColor.white,
                        padding: const EdgeInsets.symmetric(
                          vertical: MySize.defaultPadding,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(MySize.quarterRadius),
                        ),
                        elevation: 2,
                      ),
                      child: Obx(
                        () => _astrologyController.isLoading.value
                            ? const CircularProgressIndicator(
                                color: MyColor.white)
                            : Text(
                                easy.tr("Kozmik Mesajı Gör"),
                                style:
                                    MyStyle.s2.copyWith(color: MyColor.white),
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      );
    });
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
            color: MyColor.white.withOpacity(0.1),
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
                "23 günlük döngü - Enerji, gç ve dayanıklılık"),
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
        // Ay Takvimi
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
            color: MyColor.white.withOpacity(0.0),
            borderRadius: BorderRadius.circular(MySize.halfRadius),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Büyük Ay Görseli ve Bilgiler
              Row(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: MyColor.white.withOpacity(0.9),
                    ),
                  ),
                  const SizedBox(width: MySize.defaultPadding),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Waxing Gibbous",
                          style: MyStyle.s2.copyWith(
                            color: MyColor.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          "in taurus ♉️ (5°63')",
                          style: MyStyle.s3.copyWith(
                            color: MyColor.textGreyColor,
                          ),
                        ),
                        Text(
                          "Illumination 99%",
                          style: MyStyle.s3.copyWith(
                            color: MyColor.textGreyColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              verticalGap(MySize.defaultPadding),

              // Ay Fazları
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildMoonPhase("Nov 1", "🌑"),
                  _buildMoonPhase("Nov 9", "🌓"),
                  _buildMoonPhase("Nov 15", "🌕"),
                  _buildMoonPhase("Nov 22", "🌗"),
                ],
              ),

              verticalGap(MySize.defaultPadding),
              Text(
                "Moon in Taurus",
                style: MyStyle.s2.copyWith(
                  color: MyColor.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
              verticalGap(8),
              Text(
                "Today brings much emotional security. You find comfort in that which you can control. You may struggle to express your affections to loved ones and come off as possessive or clingy.",
                style: MyStyle.s3.copyWith(
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

  Widget _buildMoonPhase(String date, String emoji) {
    return Column(
      children: [
        Text(
          emoji,
          style: const TextStyle(fontSize: 24),
        ),
        verticalGap(4),
        Text(
          date,
          style: MyStyle.s3.copyWith(
            color: MyColor.textGreyColor,
          ),
        ),
      ],
    );
  }

  Widget _buildNatalChart() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          easy.tr("Natal Grafik"),
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
          child: Obx(() {
            // Kullanıcı verilerinin yüklenip yüklenmediğini kontrol et
            if (_userController.currentUser.value == null) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            return Column(
              children: [
                FutureBuilder<Map<String, dynamic>>(
                  future: NatalChartService.calculateNatalChart(
                    _userController.currentUser.value!.birthDate,
                    _userController.currentUser.value!.birthTime,
                    _userController.currentUser.value!.birthPlace,
                  ),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return SizedBox(
                        height: MySize.natalChartSize,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 40,
                                height: 40,
                                child: CircularProgressIndicator(
                                  color: MyColor.primaryLightColor,
                                  strokeWidth: 3,
                                  backgroundColor:
                                      MyColor.white.withOpacity(0.1),
                                ),
                              ),
                              verticalGap(MySize.defaultPadding),
                              Text(
                                'Natal Chart Hazırlanıyor...',
                                style: MyStyle.s3.copyWith(
                                  color: MyColor.white.withOpacity(0.7),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    if (snapshot.hasError) {
                      return SizedBox(
                        height: MySize.natalChartSize,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.error_outline,
                                color: MyColor.textGreyColor,
                                size: 40,
                              ),
                              verticalGap(MySize.defaultPadding),
                              Text(
                                'Yüklenirken Hata Oluştu',
                                style: MyStyle.s3.copyWith(
                                  color: MyColor.white,
                                ),
                              ),
                              verticalGap(MySize.halfPadding),
                              TextButton(
                                onPressed: () {
                                  setState(() {}); // Yeniden yüklemeyi tetikle
                                },
                                child: Text(
                                  'Tekrar Dene',
                                  style: MyStyle.s3.copyWith(
                                    color: MyColor.primaryLightColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    if (snapshot.hasData) {
                      return NatalChartWidget(natalChartData: snapshot.data!);
                    }

                    return const SizedBox.shrink();
                  },
                ),
                verticalGap(MySize.defaultPadding),
                divider(),
                verticalGap(MySize.defaultPadding),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(MySize.halfPadding),
                      decoration: BoxDecoration(
                        color: MyColor.primaryLightColor,
                        borderRadius:
                            BorderRadius.circular(MySize.quarterRadius),
                      ),
                      child: Column(
                        children: [
                          Text(
                            "14",
                            style: MyStyle.s2.copyWith(
                              color: MyColor.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            "NOV",
                            style: MyStyle.s3.copyWith(
                              color: MyColor.textGreyColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: MySize.defaultPadding),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Mercury semi-square Pluto",
                            style: MyStyle.s2.copyWith(
                              color: MyColor.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          verticalGap(MySize.halfPadding),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              GestureDetector(
                                onTap: () {},
                                child: Row(
                                  children: [
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Text(
                                          easy.tr("astrology.see_details"),
                                          style: MyStyle.s3.copyWith(
                                              color: MyColor.primaryLightColor,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        Icon(
                                          MyIcon.forward,
                                          size: MySize.iconSizeTiny,
                                          color: MyColor.primaryLightColor,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            );
          }),
        ),
      ],
    );
  }

  Widget _buildCompatibilityTestCard() {
    return Container(
      height: 150,
      width: double.infinity,
      decoration: BoxDecoration(
        color: MyColor.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(MySize.halfRadius),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(MySize.halfRadius),
        child: Stack(
          fit: StackFit.expand,
          children: [
            ExtendedImage.network(
              "https://apptoic.com/spiroot/images/compatibility.png",
              fit: BoxFit.cover,
              cache: true,
            ),
            // Gradient overlay
            Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(MySize.defaultPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Başlık ve İkon
                  Row(
                    children: [
                      Icon(
                        MingCute.group_fill,
                        color: MyColor.white,
                        size: MySize.iconSizeSmall,
                      ),
                      const SizedBox(width: MySize.defaultPadding),
                      Expanded(
                        child: Text(
                          easy.tr("Uyum Testi"),
                          style: MyStyle.s2.copyWith(
                            color: MyColor.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  verticalGap(MySize.defaultPadding),

                  // Test Butonları
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        child: _buildTestButton(
                          "Aşk",
                          MingCute.heart_line,
                          () => Get.toNamed('/compatibility/love'),
                        ),
                      ),
                      const SizedBox(width: MySize.defaultPadding),
                      Expanded(
                        child: _buildTestButton(
                          "Arkadaşlık",
                          MingCute.group_line,
                          () => Get.toNamed('/compatibility/friendship'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTestButton(String text, IconData icon, VoidCallback onPressed) {
    return SizedBox(
      height: MySize.iconSizeMedium,
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          backgroundColor: MyColor.primaryDarkColor,
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
              color: MyColor.white,
            ),
            const SizedBox(width: 8),
            Text(
              text,
              maxLines: 2,
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

  Widget _buildFeatureCard({
    required String icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      width: 160,
      padding: const EdgeInsets.all(MySize.defaultPadding),
      decoration: BoxDecoration(
        color: MyColor.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(MySize.defaultRadius),
        border: Border.all(
          color: MyColor.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Text(
            icon,
            style: const TextStyle(fontSize: MySize.iconSizeSmall),
          ),
          verticalGap(8),
          Text(
            title,
            style: MyStyle.s2.copyWith(
              color: MyColor.white,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          verticalGap(4),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: MyStyle.s3.copyWith(
              color: MyColor.textGreyColor,
              fontWeight: FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  String _getElementEmoji(String element) {
    switch (element.toLowerCase()) {
      case 'ateş':
        return '🔥';
      case 'toprak':
        return '🌍';
      case 'hava':
        return '💨';
      case 'su':
        return '💧';
      default:
        return '⭐';
    }
  }

  String _getQualityEmoji(String quality) {
    switch (quality.toLowerCase()) {
      case 'öncü':
        return '🚀';
      case 'sabit':
        return '🏔️';
      case 'deişken':
        return '🔄';
      default:
        return '⭐';
    }
  }

  Widget _buildDetailSection(String title, String prediction, String advice) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: MyStyle.s2.copyWith(
            color: MyColor.white,
            fontWeight: FontWeight.w500,
          ),
        ),
        verticalGap(MySize.halfPadding),
        Text(
          prediction,
          style: MyStyle.s2.copyWith(
            color: MyColor.white,
            height: 1.5,
          ),
        ),
        verticalGap(MySize.halfPadding),
        Container(
          padding: const EdgeInsets.all(MySize.halfPadding),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(MySize.quarterRadius),
            border: Border.all(
              color: MyColor.secondaryColor,
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.tips_and_updates_outlined,
                color: MyColor.secondaryColor,
                size: MySize.iconSizeSmall,
              ),
              horizontalGap(MySize.halfPadding),
              Expanded(
                child: Text(
                  advice,
                  style: MyStyle.s3.copyWith(
                    color: MyColor.secondaryColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLuckyItem(String label, String value) {
    return Row(
      children: [
        Text(
          label,
          style: MyStyle.s3.copyWith(
            color: MyColor.textGreyColor,
          ),
        ),
        horizontalGap(MySize.halfPadding),
        Text(
          value,
          style: MyStyle.s3.copyWith(
            color: MyColor.white,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
