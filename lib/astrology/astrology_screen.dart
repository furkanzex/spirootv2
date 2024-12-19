import 'dart:async';
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
import 'package:spirootv2/core/widget/popup/premium_popup.dart';
import 'package:spirootv2/profile/profile_onboarding.dart';
import 'package:spirootv2/astrology/love_career_money.dart';
import 'package:spirootv2/core/widget/divider/divider.dart';
import 'package:spirootv2/core/widget/gap/vertical_gap.dart';
import 'package:easy_localization/easy_localization.dart' as easy;
import 'package:get/get.dart';
import 'package:spirootv2/astrology/astrology_controller.dart';
import 'package:share_plus/share_plus.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:spirootv2/profile/user_controller.dart';
import 'package:spirootv2/core/service/natal_chart_service.dart';
import 'package:spirootv2/astrology/natal_chart.dart';
import 'package:lottie/lottie.dart';
import 'package:spirootv2/astrology/compatibility_screen.dart';
import 'package:spirootv2/core/service/revenuecat_services.dart';

class AstrologyScreen extends StatefulWidget {
  const AstrologyScreen({super.key});

  @override
  State<AstrologyScreen> createState() => _AstrologyScreenState();
}

class _AstrologyScreenState extends State<AstrologyScreen> {
  final UserController _userController = Get.find<UserController>();
  final AstrologyController _astrologyController =
      Get.put(AstrologyController());
  Timer? _countdownTimer;

  @override
  void initState() {
    super.initState();
    // Her 1 saatte bir geri sayımı güncelle
    _countdownTimer = Timer.periodic(const Duration(hours: 1), (timer) {
      setState(() {
        // Retro kartlarını yeniden oluştur
      });
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  // Kalan gün sayısını hesaplayan yardımcı metod
  String _getRemainingDays(String endDateStr) {
    try {
      final now = DateTime.now();
      final end = DateFormat('dd MMM').parse(endDateStr);
      final endWithYear = DateTime(
        now.year + (end.month < now.month ? 1 : 0),
        end.month,
        end.day,
      );

      final difference = endWithYear.difference(now);
      final days = difference.inDays;
      final hours = difference.inHours % 24;

      if (days > 0) {
        return "$days ${easy.tr("astrology.days_left")}";
      } else if (hours > 0) {
        return "$hours ${easy.tr("astrology.hours_left")}";
      } else {
        return easy.tr("astrology.last_day");
      }
    } catch (e) {
      return "";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColor.transparent,
      body: SafeArea(
        child: Obx(() {
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
            easy.tr("astrology.discover_stars"),
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
            easy.tr("astrology.personalized_horoscope"),
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
                onTap: () => Get.to(
                  () => ProfileOnboarding(),
                  fullscreenDialog: true,
                ),
                borderRadius: BorderRadius.circular(30),
                child: Center(
                  child: Text(
                    easy.tr("astrology.start_journey"),
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
                icon: easy.tr("astrology.feature_cards.birth_chart.icon"),
                title: easy.tr("astrology.feature_cards.birth_chart.title"),
                subtitle:
                    easy.tr("astrology.feature_cards.birth_chart.subtitle"),
              ),
              _buildFeatureCard(
                icon: easy.tr("astrology.feature_cards.horoscope.icon"),
                title: easy.tr("astrology.feature_cards.horoscope.title"),
                subtitle: easy.tr("astrology.feature_cards.horoscope.subtitle"),
              ),
              _buildFeatureCard(
                icon: easy.tr("astrology.feature_cards.natal_chart.icon"),
                title: easy.tr("astrology.feature_cards.natal_chart.title"),
                subtitle:
                    easy.tr("astrology.feature_cards.natal_chart.subtitle"),
              ),
              _buildFeatureCard(
                icon: easy.tr("astrology.feature_cards.predictions.icon"),
                title: easy.tr("astrology.feature_cards.predictions.title"),
                subtitle:
                    easy.tr("astrology.feature_cards.predictions.subtitle"),
              ),
              _buildFeatureCard(
                icon: easy.tr("astrology.feature_cards.compatibility.icon"),
                title: easy.tr("astrology.feature_cards.compatibility.title"),
                subtitle:
                    easy.tr("astrology.feature_cards.compatibility.subtitle"),
              ),
              _buildFeatureCard(
                icon: easy.tr("astrology.feature_cards.biorhythm.icon"),
                title: easy.tr("astrology.feature_cards.biorhythm.title"),
                subtitle: easy.tr("astrology.feature_cards.biorhythm.subtitle"),
              ),
            ],
          ),
          verticalGap(MySize.doublePadding * 2),
        ],
      ),
    );
  }

  Widget _buildAstrologyContent() {
    final zodiacSign = _userController.currentUser.value!.zodiacSign;
    final moonSign = _userController.currentUser.value!.moonSign;
    final ascendant = _userController.currentUser.value!.ascendant;

    final zodiacDetails =
        _astrologyController.getZodiacDetailsByName(zodiacSign);
    final moonDetails = _astrologyController.getZodiacDetailsByName(moonSign);
    final ascendantDetails =
        _astrologyController.getZodiacDetailsByName(ascendant);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(MySize.defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                      easy.tr("astrology.sun_horoscope"),
                      zodiacDetails['name'] ?? '',
                      zodiacDetails['symbol'] ?? '',
                    ),
                    _buildAstroDetail(
                      easy.tr("astrology.moon_horoscope"),
                      moonDetails['name'] ?? '',
                      moonDetails['symbol'] ?? '',
                    ),
                    _buildAstroDetail(
                      easy.tr("astrology.ascendant_horoscope"),
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
                        backgroundColor: MyColor.white.withOpacity(0.05),
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
                      easy.tr("astrology.element"),
                      zodiacDetails['element'] ?? '',
                      _getElementEmoji(zodiacDetails['element'] ?? ''),
                    ),
                    _buildAstroDetail(
                      easy.tr("astrology.quality"),
                      zodiacDetails['quality'] ?? '',
                      _getQualityEmoji(zodiacDetails['quality'] ?? ''),
                    ),
                    _buildAstroDetail(
                      easy.tr("astrology.ruler"),
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

          verticalGap(MySize.doublePadding),
          loveCareerMoney(),
          verticalGap(MySize.doublePadding),
          _buildHoroscopeText(),
          verticalGap(MySize.doublePadding),
          _buildCompatibilityTestCard(),
          verticalGap(MySize.doublePadding),
          _buildBiorhythmChart(),
          verticalGap(MySize.doublePadding),
          _buildNatalChart(),
          verticalGap(MySize.doublePadding),
          _buildRetroSection(),
          verticalGap(MySize.doublePadding),
          _buildNumerologyCard(),
        ],
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
          backgroundColor:
              isSelected ? MyColor.white.withOpacity(0.05) : Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(MySize.quarterRadius),
          ),
        ),
        child: Text(
          displayText,
          style: MyStyle.s2.copyWith(
            color: isSelected
                ? MyColor.white
                : MyColor.primaryPurpleColor.withOpacity(0.25),
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
              easy.tr("astrology.characteristics"),
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
                      '${easy.tr("astrology.share_info")}\n\n${_astrologyController.selectedHoroscope.value.horoscopeText}',
                      subject: easy.tr("astrology.share_subject"),
                    );
                  },
                  icon: const Icon(
                    MingCute.upload_line,
                    color: MyColor.primaryPurpleColor,
                  ),
                  padding: const EdgeInsets.all(12),
                  constraints: const BoxConstraints(
                    minWidth: 44,
                    minHeight: 44,
                  ),
                  tooltip: easy.tr("astrology.share"),
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
                  easy.tr("astrology.loading"),
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
                      easy.tr("astrology.horoscope.love_and_relationships"),
                      _astrologyController.selectedHoroscope.value
                          .details!['love']['prediction'],
                      _astrologyController
                          .selectedHoroscope.value.details!['love']['advice'],
                    ),
                    verticalGap(MySize.defaultPadding),

                    // Kariyer Yorumu
                    _buildDetailSection(
                      easy.tr("astrology.horoscope.career"),
                      _astrologyController.selectedHoroscope.value
                          .details!['career']['prediction'],
                      _astrologyController
                          .selectedHoroscope.value.details!['career']['advice'],
                    ),
                    verticalGap(MySize.defaultPadding),

                    // Para Yorumu
                    _buildDetailSection(
                      easy.tr("astrology.horoscope.financial"),
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
                      easy.tr("astrology.horoscope.lucky_details"),
                      style: MyStyle.s2.copyWith(
                        color: MyColor.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    verticalGap(MySize.halfPadding),

                    // Şanslı Sayılar
                    _buildLuckyItem(
                      easy.tr("astrology.horoscope.lucky_numbers"),
                      _astrologyController
                          .selectedHoroscope.value.details!['lucky']['numbers']
                          .join(', '),
                    ),
                    verticalGap(MySize.quarterPadding),

                    // Şanslı Renkler
                    _buildLuckyItem(
                      easy.tr("astrology.horoscope.lucky_colors"),
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
                        easy.tr("astrology.lucky_days"),
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
                          text: easy.tr("astrology.hello_zodiac", namedArgs: {
                            "zodiac": easy.tr(
                                "astrology.zodiac.${_userController.currentUser.value!.zodiacSign}.name")
                          }),
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
                      onPressed: () => _showCosmicMessage(),
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
                                easy.tr("astrology.see_cosmic_message"),
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
    final birthDate =
        _userController.currentUser.value?.birthDate ?? DateTime.now();
    final today = DateTime.now();
    final daysSinceBirth = today.difference(birthDate).inDays;

    List<Map<String, double>> weeklyBiorhythm = List.generate(7, (index) {
      final day = daysSinceBirth + index;
      return {
        'physical': sin(2 * pi * day / 23),
        'emotional': sin(2 * pi * day / 28),
        'intellectual': sin(2 * pi * day / 33),
      };
    });

    return GestureDetector(
      onTap: _showBiorhythmContent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                easy.tr("astrology.biorythym"),
                style: MyStyle.s2.copyWith(
                  color: MyColor.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Column(
                children: [
                  Text(
                    "${DateFormat('dd MMM').format(today)} - ${DateFormat('dd MMM').format(today.add(const Duration(days: 6)))}",
                    style: MyStyle.s3.copyWith(
                      color: MyColor.textGreyColor,
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        easy.tr("astrology.see_details"),
                        style: MyStyle.s3.copyWith(
                          color: MyColor.primaryPurpleColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Icon(
                        MyIcon.forward,
                        size: MySize.iconSizeTiny,
                        color: MyColor.primaryPurpleColor,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          verticalGap(MySize.defaultPadding),

          Container(
            height: 220,
            padding: const EdgeInsets.all(MySize.defaultPadding),
            decoration: BoxDecoration(
              color: MyColor.white.withOpacity(0.05),
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
                      color: MyColor.white.withOpacity(0.05),
                      strokeWidth: 1,
                    );
                  },
                  getDrawingVerticalLine: (value) {
                    return FlLine(
                      color: MyColor.white.withOpacity(0.05),
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
                        final date = today.add(Duration(days: value.toInt()));
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
                    spots: weeklyBiorhythm.asMap().entries.map((entry) {
                      return FlSpot(
                          entry.key.toDouble(), entry.value['physical']!);
                    }).toList(),
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
                    spots: weeklyBiorhythm.asMap().entries.map((entry) {
                      return FlSpot(
                          entry.key.toDouble(), entry.value['emotional']!);
                    }).toList(),
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
                    spots: weeklyBiorhythm.asMap().entries.map((entry) {
                      return FlSpot(
                          entry.key.toDouble(), entry.value['intellectual']!);
                    }).toList(),
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

          // Grafik açıklamaları
          Column(
            children: [
              _buildLegendItemDetailed(
                  MyColor.primaryLightColor,
                  easy.tr("astrology.physical"),
                  "${(weeklyBiorhythm[0]['physical']! * 100).toInt()}% - ${easy.tr("astrology.physical_cycle")}"),
              verticalGap(8),
              _buildLegendItemDetailed(
                  MyColor.secondaryColor,
                  easy.tr("astrology.emotional"),
                  "${(weeklyBiorhythm[0]['emotional']! * 100).toInt()}% - ${easy.tr("astrology.emotional_cycle")}"),
              verticalGap(8),
              _buildLegendItemDetailed(
                  Colors.green,
                  easy.tr("astrology.intellectual"),
                  "${(weeklyBiorhythm[0]['intellectual']! * 100).toInt()}% - ${easy.tr("astrology.intellectual_cycle")}"),
            ],
          ),
        ],
      ),
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

  void _showBiorhythmContent() {
    if (_astrologyController.isSubscribed.value) {
      // Premium kullanıcı için direkt göster
      _showBiorhythmDetails();
    } else {
      // Premium olmayan kullanıcı için popup göster
      Get.dialog(
        PremiumPopup(
          onSingleUse: () => _showBiorhythmDetails(),
        ),
      );
    }
  }

  void _showBiorhythmDetails() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(MySize.doublePadding),
        decoration: const BoxDecoration(
          color: MyColor.darkBackgroundColor,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(MySize.defaultRadius),
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                easy.tr("astrology.daily_biorhythm_analysis"),
                style: MyStyle.s1.copyWith(
                  color: MyColor.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              verticalGap(MySize.defaultPadding),
              Obx(() {
                if (_astrologyController.isLoading.value) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: MyColor.primaryColor,
                    ),
                  );
                }

                if (!_astrologyController.isBiorhythmAvailable.value) {
                  return Center(
                    child: Text(
                      easy.tr("astrology.biorhythm_not_created"),
                      style: MyStyle.s2.copyWith(
                        color: MyColor.white,
                      ),
                    ),
                  );
                }

                return _buildBiorhythmContent();
              }),
            ],
          ),
        ),
      ),
    );

    // Eğer biyoritim yorumu yoksa, oluştur
    if (!_astrologyController.isBiorhythmAvailable.value &&
        !_astrologyController.isLoading.value) {
      _astrologyController.checkBiorhythmReading();
    }
  }

  Widget _buildBiorhythmContent() {
    final reading = _astrologyController.biorhythmReading;

    if (reading.isEmpty) {
      return Center(
        child: Text(
          easy.tr("astrology.biorhythm_not_found"),
          style: MyStyle.s2.copyWith(
            color: MyColor.white,
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          reading['overview'] ?? '',
          style: MyStyle.s2.copyWith(
            color: MyColor.white,
            height: 1.5,
          ),
        ),
        verticalGap(MySize.defaultPadding),
        _buildBiorhythmSection(
            easy.tr("astrology.physical"), reading['physical']),
        _buildBiorhythmSection(
            easy.tr("astrology.emotional"), reading['emotional']),
        _buildBiorhythmSection(
            easy.tr("astrology.intellectual"), reading['intellectual']),
        _buildBiorhythmSection(
            easy.tr("astrology.intuitive"), reading['intuitive']),
      ],
    );
  }

  Widget _buildBiorhythmSection(String title, Map<String, dynamic>? data) {
    if (data == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: MyStyle.s2.copyWith(
            color: MyColor.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        verticalGap(MySize.halfPadding),
        Text(
          data['status'] ?? '',
          style: MyStyle.s3.copyWith(
            color: MyColor.white,
            height: 1.5,
          ),
        ),
        verticalGap(MySize.quarterPadding),
        Text(
          data['advice'] ?? '',
          style: MyStyle.s3.copyWith(
            color: MyColor.textGreyColor,
            height: 1.5,
          ),
        ),
        verticalGap(MySize.defaultPadding),
      ],
    );
  }

  Widget _buildNatalChart() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          easy.tr("astrology.natal_chart"),
          style: MyStyle.s2.copyWith(
            color: MyColor.white,
            fontWeight: FontWeight.w500,
          ),
        ),
        verticalGap(MySize.defaultPadding),
        Container(
          padding: const EdgeInsets.all(MySize.defaultPadding),
          decoration: BoxDecoration(
            color: MyColor.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(MySize.halfRadius),
          ),
          child: Obx(() {
            if (_userController.currentUser.value == null) {
              return _buildLoadingWidget();
            }

            return Column(
              children: [
                SizedBox(
                  height: MySize.natalChartSize,
                  child: FutureBuilder<Map<String, dynamic>>(
                    future: _retryNatalChart(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(
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
                                      MyColor.white.withOpacity(0.05),
                                ),
                              ),
                              verticalGap(MySize.defaultPadding),
                              Text(
                                easy.tr("astrology.natal_chart_preparing"),
                                style: MyStyle.s3.copyWith(
                                  color: MyColor.white.withOpacity(0.7),
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      if (snapshot.hasError) {
                        return _buildErrorWidget();
                      }

                      if (snapshot.hasData) {
                        return NatalChartWidget(natalChartData: snapshot.data!);
                      }

                      return _buildLoadingWidget();
                    },
                  ),
                ),
                verticalGap(MySize.defaultPadding),
                _buildWeeklyNatalReading(),
                verticalGap(MySize.defaultPadding),
                divider(),
                verticalGap(MySize.defaultPadding),
                _buildTransits(),
              ],
            );
          }),
        ),
      ],
    );
  }

  Future<Map<String, dynamic>> _retryNatalChart() async {
    const maxAttempts = 3;
    const delayDuration = Duration(seconds: 2);

    for (var attempt = 1; attempt <= maxAttempts; attempt++) {
      try {
        return await NatalChartService.calculateNatalChart(
          _userController.currentUser.value!.birthDate,
          _userController.currentUser.value!.birthTime,
          _userController.currentUser.value!.birthPlace,
        );
      } catch (e) {
        if (attempt == maxAttempts) {
          rethrow;
        }
        await Future.delayed(delayDuration);
      }
    }

    throw Exception(easy.tr("astrology.natal_chart_not_calculated"));
  }

  Widget _buildTransits() {
    final now = DateTime.now();
    final weekEnd = now.add(const Duration(days: 7));
    final weekRange =
        "${DateFormat('dd MMM').format(now)} - ${DateFormat('dd MMM').format(weekEnd)}";

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Başlık ve Tarih
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              easy.tr("astrology.weekly_transit_table"),
              style: MyStyle.s2.copyWith(
                color: MyColor.white,
                fontWeight: FontWeight.w500,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: MySize.halfPadding,
                vertical: MySize.quarterPadding,
              ),
              decoration: BoxDecoration(
                color: MyColor.primaryLightColor,
                borderRadius: BorderRadius.circular(MySize.quarterRadius),
              ),
              child: Text(
                weekRange,
                style: MyStyle.s3.copyWith(color: MyColor.white),
              ),
            ),
          ],
        ),
        verticalGap(MySize.defaultPadding),

        // Transit Tablosu
        Container(
          decoration: BoxDecoration(
            color: MyColor.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(MySize.quarterRadius),
            border: Border.all(
              color: MyColor.primaryLightColor.withOpacity(0.1),
              width: 1,
            ),
          ),
          child: Table(
            border: TableBorder(
              horizontalInside: BorderSide(
                color: MyColor.white.withOpacity(0.05),
                width: 1,
              ),
            ),
            children: [
              // Tablo Başlığı
              TableRow(
                decoration: BoxDecoration(
                  color: MyColor.primaryLightColor,
                ),
                children: [
                  _buildTableHeader(easy.tr("astrology.planet")),
                  _buildTableHeader(easy.tr("astrology.position")),
                  _buildTableHeader(easy.tr("astrology.aspects")),
                ],
              ),
              // Gezegen Satırları
              ..._astrologyController.currentTransits.entries.map((entry) {
                final planetData = entry.value;
                final sign = planetData['sign'] as String? ?? '';
                final degree = planetData['degree'] as double? ?? 0.0;
                final aspects =
                    planetData['aspects'] as Map<String, dynamic>? ?? {};

                return TableRow(
                  decoration: BoxDecoration(
                    color: MyColor.transparent,
                  ),
                  children: [
                    // Gezegen
                    _buildTableCell(
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _getPlanetSymbol(entry.key),
                            style: MyStyle.s2.copyWith(
                              color: MyColor.white,
                            ),
                          ),
                          Text(
                            " ${_getPlanetName(entry.key)}",
                            style: MyStyle.s3.copyWith(
                              color: MyColor.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Konum
                    _buildTableCell(
                      Text(
                        "${degree.toStringAsFixed(1)}° ${_getZodiacSymbol(sign)}",
                        style: MyStyle.s3.copyWith(
                          color: MyColor.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    // Açılar
                    _buildTableCell(
                      Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 4,
                        children: aspects.entries.map((aspect) {
                          final aspectData =
                              aspect.value as Map<String, dynamic>;
                          return Text(
                            "${_getPlanetSymbol(aspect.key)}${_getAspectSymbol(aspectData['aspect'] as String)}",
                            style: MyStyle.s3.copyWith(
                              color: MyColor.textGreyColor,
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                );
              }),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTableHeader(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: MySize.halfPadding,
        horizontal: MySize.quarterPadding,
      ),
      child: Text(
        text,
        style: MyStyle.s3.copyWith(
          color: MyColor.white,
          fontWeight: FontWeight.w500,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildTableCell(Widget child) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: MySize.halfPadding,
        horizontal: MySize.quarterPadding,
      ),
      child: Center(child: child),
    );
  }

  Widget _buildCompatibilityTestCard() {
    return Container(
      height: 150,
      width: double.infinity,
      decoration: BoxDecoration(
        color: MyColor.white.withOpacity(0.05),
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
                          easy.tr("astrology.compatibility_test"),
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
                          easy.tr("astrology.love"),
                          () => Get.to(() => CompatibilityScreen(type: "love")),
                          MingCute.heart_line,
                        ),
                      ),
                      horizontalGap(MySize.defaultPadding),
                      Expanded(
                        child: _buildTestButton(
                          easy.tr("astrology.friendship"),
                          () => Get.to(
                              () => CompatibilityScreen(type: "friendship")),
                          MingCute.group_line,
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

  Widget _buildTestButton(String text, VoidCallback onPressed, IconData? icon) {
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
            if (icon != null)
              Icon(
                icon,
                color: MyColor.white,
              ),
            if (icon != null) horizontalGap(MySize.halfPadding),
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
          color: MyColor.white.withOpacity(0.05),
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

  Widget _buildNumerologyCard() {
    final lifePathNumber = _astrologyController
        .calculateLifePathNumber(_userController.currentUser.value!.birthDate);

    // Hafta aralığını hesapla
    final now = DateTime.now();
    final weekEnd = now.add(const Duration(days: 7));
    final weekRange =
        "${DateFormat('dd MMM').format(now)} - ${DateFormat('dd MMM').format(weekEnd)}";

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          easy.tr("astrology.numerology"),
          style: MyStyle.s2.copyWith(
            color: MyColor.white,
            fontWeight: FontWeight.w500,
          ),
        ),
        verticalGap(MySize.defaultPadding),
        Container(
          padding: const EdgeInsets.all(MySize.defaultPadding),
          decoration: BoxDecoration(
            color: MyColor.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(MySize.halfRadius),
          ),
          child: Column(
            children: [
              // Numeroloji Grafiği ve Bilgileri
              Column(
                children: [
                  // Sol taraf - Yaşam Yolu Sayısı Grafiği
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: MySize.natalChartSize,
                        height: MySize.natalChartSize,
                        child: Center(
                          child: Text(
                            lifePathNumber.toString(),
                            style: MyStyle.s1.copyWith(
                              color: MyColor.white,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      // Lottie animasyonu
                      Positioned.fill(
                        child: Lottie.asset(
                          'assets/lottie/num.json',
                          fit: BoxFit.cover,
                          repeat: true,
                        ),
                      ),
                    ],
                  ),
                  horizontalGap(MySize.defaultPadding),
                ],
              ),
              verticalGap(MySize.defaultPadding),
              divider(),
              verticalGap(MySize.defaultPadding),

              // Alt kısım - Haftalık Özet
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(MySize.halfPadding),
                    decoration: BoxDecoration(
                      color: MyColor.primaryLightColor,
                      borderRadius: BorderRadius.circular(MySize.quarterRadius),
                    ),
                    child: Text(
                      weekRange,
                      style: MyStyle.s3.copyWith(
                        color: MyColor.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  horizontalGap(MySize.defaultPadding),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _showNumerologyContent(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            easy.tr("astrology.weekly_numerology"),
                            style: MyStyle.s2.copyWith(
                              color: MyColor.white,
                              fontWeight: FontWeight.normal,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          verticalGap(MySize.halfPadding),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    easy.tr("astrology.see_details"),
                                    style: MyStyle.s3.copyWith(
                                      color: MyColor.primaryPurpleColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Icon(
                                    MyIcon.forward,
                                    size: MySize.iconSizeTiny,
                                    color: MyColor.primaryPurpleColor,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showCosmicMessage() async {
    final isPremium = await PurchaseAPI.isPremium();
    if (isPremium) {
      _showCosmicMessageContent();
    } else {
      if (_astrologyController.selectedDay.value !=
          "astrology.horoscope.dates.today") {
        Get.dialog(
          PremiumPopup(
            onSingleUse: () => _showCosmicMessageContent(),
          ),
        );
      } else {
        _showCosmicMessageContent();
      }
    }
  }

  void _showCosmicMessageContent() async {
    if (_astrologyController.isLoading.value) return;

    // Seçilen zaman dilimine göre horoscope kontrolü yap
    final timeframe = _astrologyController.selectedDay.value;
    await _astrologyController.checkHoroscope(timeframe);

    // Eğer yorum yoksa veya süresi geçmişse yeni yorum oluştur
    if (!_astrologyController.isHoroscopeAvailable.value) {
      await _astrologyController.generateHoroscope();
    }
  }

  Widget _buildLoadingWidget() {
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
                backgroundColor: MyColor.white.withOpacity(0.05),
              ),
            ),
            verticalGap(MySize.defaultPadding),
            Text(
              easy.tr("astrology.natal_chart_preparing"),
              style: MyStyle.s3.copyWith(
                color: MyColor.white.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
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
              easy.tr("astrology.natal_chart_error"),
              textAlign: TextAlign.center,
              style: MyStyle.s3.copyWith(
                color: MyColor.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Gezegen sembollerini döndüren metod
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
    return symbols[planet] ?? planet;
  }

  // Burç sembollerini döndüren metod
  String _getZodiacSymbol(String sign) {
    final symbols = {
      'aries': '♈',
      'taurus': '♉',
      'gemini': '♊',
      'cancer': '♋',
      'leo': '♌',
      'virgo': '♍',
      'libra': '♎',
      'scorpio': '♏',
      'sagittarius': '♐',
      'capricorn': '♑',
      'aquarius': '♒',
      'pisces': '♓',
    };
    return symbols[sign] ?? sign;
  }

  // Gezegen isimlerini Türkçe'den İngilizce'ye çeviren metod
  String _getPlanetName(String planet) {
    // Önce gelen gezegen ismini küçük harfe çevirelim
    final planetLower = planet.toLowerCase();

    // İngilizce isimleri döndür
    switch (planetLower) {
      case 'sun':
      case 'güneş':
        return 'Sun';
      case 'moon':
      case 'ay':
        return 'Moon';
      case 'mercury':
      case 'merkür':
        return 'Mercury';
      case 'venus':
      case 'venüs':
        return 'Venus';
      case 'mars':
        return 'Mars';
      case 'jupiter':
      case 'jüpiter':
        return 'Jupiter';
      case 'saturn':
      case 'satürn':
        return 'Saturn';
      case 'uranus':
      case 'uranüs':
        return 'Uranus';
      case 'neptune':
      case 'neptün':
        return 'Neptune';
      case 'pluto':
      case 'plüton':
        return 'Pluto';
      default:
        return planet.substring(0, 1).toUpperCase() +
            planet.substring(1).toLowerCase();
    }
  }

  // Açı sembollerini döndüren metod
  String _getAspectSymbol(String aspect) {
    final symbols = {
      'Conjunction': '☌', // Kavuşum
      'Sextile': '⚹', // Altmışlık
      'Square': '□', // Kare
      'Trine': '△', // Üçgen
      'Opposition': '☍', // Karşıt
    };
    return symbols[aspect] ?? aspect;
  }

  Widget _buildRetroSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Retrolar",
          style: MyStyle.s2.copyWith(
            color: MyColor.white,
            fontWeight: FontWeight.w500,
          ),
        ),
        verticalGap(MySize.defaultPadding),
        Obx(() {
          if (_astrologyController.isLoading.value) {
            return const Center(
              child: CircularProgressIndicator(color: MyColor.primaryColor),
            );
          }

          // activeRetrogrades listesini kontrol et
          if (!_astrologyController.hasRetrogrades.value ||
              _astrologyController.activeRetrogrades.isEmpty) {
            return Container(
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
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.check_circle_outline,
                    color: MyColor.successColor,
                    size: 48,
                  ),
                  verticalGap(MySize.defaultPadding),
                  Text(
                    easy.tr("astrology.retro_no_planet"),
                    style: MyStyle.s2.copyWith(
                      color: MyColor.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  verticalGap(MySize.halfPadding),
                  Text(
                    easy.tr("astrology.retro_all_planets_moving"),
                    style: MyStyle.s3.copyWith(
                      color: MyColor.textGreyColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _astrologyController.activeRetrogrades.length,
            itemBuilder: (context, index) {
              final retro = _astrologyController.activeRetrogrades[index];
              return _buildRetroCard(retro);
            },
          );
        }),
      ],
    );
  }

  Widget _buildRetroCard(Map<String, dynamic> retro) {
    final shadowPeriod = retro['shadowPeriod'];
    final bool isInShadow = shadowPeriod != null;

    return Container(
      margin: const EdgeInsets.only(bottom: MySize.defaultPadding),
      decoration: BoxDecoration(
        color: MyColor.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(MySize.halfRadius),
        border: Border.all(
          color: isInShadow
              ? MyColor.primaryLightColor.withOpacity(0.2)
              : Colors.transparent,
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showRetroDetails(retro),
          borderRadius: BorderRadius.circular(MySize.halfRadius),
          child: Padding(
            padding: const EdgeInsets.all(MySize.defaultPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Gezegen ikonu
                    ClipRRect(
                      borderRadius: BorderRadius.circular(30),
                      child: ExtendedImage.network(
                        "https://apptoic.com/spiroot/images/${_getPlanetImageName(retro['planet'])}.png",
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                        cache: true,
                        loadStateChanged: (state) {
                          if (state.extendedImageLoadState ==
                              LoadState.loading) {
                            return Container(
                              width: 60,
                              height: 60,
                              color: MyColor.primaryLightColor.withOpacity(0.1),
                              child: const CircularProgressIndicator(
                                  strokeWidth: 2),
                            );
                          }
                          return null;
                        },
                      ),
                    ),
                    horizontalGap(MySize.defaultPadding),

                    // Gezegen detayları
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                _getPlanetName(retro['planet']),
                                style: MyStyle.s2.copyWith(
                                  color: MyColor.white,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              horizontalGap(MySize.halfPadding),
                              Text(
                                "${retro['degree']}° ${_getZodiacSymbol(retro['sign'])}",
                                style:
                                    MyStyle.s2.copyWith(color: MyColor.white),
                              ),
                            ],
                          ),
                          verticalGap(MySize.quarterPadding),
                          Text(
                            "${retro['startDate']} → ${retro['endDate']}",
                            style: MyStyle.s3
                                .copyWith(color: MyColor.textGreyColor),
                          ),
                          if (isInShadow) ...[
                            verticalGap(MySize.quarterPadding),
                            Row(
                              children: [
                                Icon(
                                  Icons.wb_twilight,
                                  color: MyColor.primaryLightColor,
                                  size: 14,
                                ),
                                horizontalGap(4),
                                Text(
                                  easy.tr("astrology.shadow_period"),
                                  style: MyStyle.s3.copyWith(
                                    color: MyColor.primaryLightColor,
                                  ),
                                ),
                              ],
                            ),
                            verticalGap(MySize.quarterPadding),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Pre-Retro: ${retro['shadowPeriod']['preRetrograde']}",
                                  style: MyStyle.s3
                                      .copyWith(color: MyColor.textGreyColor),
                                ),
                                Text(
                                  "Post-Retro: ${retro['shadowPeriod']['postRetrograde']}",
                                  style: MyStyle.s3
                                      .copyWith(color: MyColor.textGreyColor),
                                ),
                              ],
                            ),
                          ],
                          if (retro['natalAspects']?.isNotEmpty == true) ...[
                            verticalGap(MySize.quarterPadding),
                            Row(
                              children: [
                                Icon(
                                  Icons.auto_graph,
                                  color: MyColor.primaryLightColor,
                                  size: 14,
                                ),
                                horizontalGap(4),
                                Text(
                                  "${easy.tr("astrology.natal_aspects")}: ${(retro['natalAspects'] as List).length}",
                                  style: MyStyle.s3.copyWith(
                                    color: MyColor.primaryLightColor,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showRetroDetails(Map<String, dynamic> retro) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(MySize.doublePadding),
        decoration: const BoxDecoration(
          color: MyColor.darkBackgroundColor,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(MySize.defaultRadius),
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Gezegen başlığı
              Row(
                children: [
                  ExtendedImage.network(
                    "https://apptoic.com/spiroot/images/${_getPlanetImageName(retro['planet'])}.png",
                    width: 40,
                    height: 40,
                    fit: BoxFit.cover,
                    cache: true,
                  ),
                  horizontalGap(MySize.defaultPadding),
                  Text(
                    "${_getPlanetName(retro['planet'])} Retrosu",
                    style: MyStyle.s1.copyWith(
                      color: MyColor.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              verticalGap(MySize.defaultPadding),

              // Konum ve tarih bilgisi
              Container(
                padding: const EdgeInsets.all(MySize.defaultPadding),
                decoration: BoxDecoration(
                  color: MyColor.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(MySize.halfRadius),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${retro['sign']} ${retro['degree']}° ",
                          style: MyStyle.s2.copyWith(color: MyColor.white),
                        ),
                        verticalGap(MySize.halfPadding),
                        Text(
                          "(${retro['startDate']} → ${retro['endDate']})",
                          style: MyStyle.s3.copyWith(
                            color: MyColor.primaryLightColor,
                          ),
                          softWrap: true,
                        ),
                      ],
                    ),
                    if (retro['shadowPeriod'] != null) ...[
                      verticalGap(MySize.defaultPadding),
                      Row(
                        children: [
                          Icon(
                            Icons.wb_twilight,
                            color: MyColor.primaryLightColor,
                            size: 16,
                          ),
                          horizontalGap(MySize.halfPadding),
                          Text(
                            "${easy.tr("astrology.shadow_period")}:",
                            style: MyStyle.s3.copyWith(
                              color: MyColor.primaryLightColor,
                            ),
                          ),
                        ],
                      ),
                      verticalGap(MySize.quarterPadding),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Pre-Retro: ${retro['shadowPeriod']['preRetrograde']}",
                            style: MyStyle.s3
                                .copyWith(color: MyColor.textGreyColor),
                          ),
                          Text(
                            "Post-Retro: ${retro['shadowPeriod']['postRetrograde']}",
                            style: MyStyle.s3
                                .copyWith(color: MyColor.textGreyColor),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              verticalGap(MySize.defaultPadding),

              // Etki ve tavsiyeler
              Text(
                easy.tr("astrology.impact"),
                style: MyStyle.s2.copyWith(
                  color: MyColor.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              verticalGap(MySize.halfPadding),
              Text(
                retro['impact'],
                style: MyStyle.s2.copyWith(
                  color: MyColor.white,
                  height: 1.5,
                ),
              ),
              verticalGap(MySize.defaultPadding),

              // Natal açılar
              if (retro['natalAspects']?.isNotEmpty == true) ...[
                Text(
                  easy.tr("astrology.natal_aspects"),
                  style: MyStyle.s2.copyWith(
                    color: MyColor.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                verticalGap(MySize.halfPadding),
                ...(retro['natalAspects'] as List).map((aspect) => Container(
                      margin: const EdgeInsets.only(bottom: MySize.halfPadding),
                      padding: const EdgeInsets.all(MySize.defaultPadding),
                      decoration: BoxDecoration(
                        color: MyColor.white.withOpacity(0.05),
                        borderRadius:
                            BorderRadius.circular(MySize.quarterRadius),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                "${aspect['natalPlanet']} ${_getAspectSymbol(aspect['aspect'])} (${aspect['orb']}°)",
                                style: MyStyle.s3.copyWith(
                                  color: MyColor.primaryLightColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          verticalGap(MySize.quarterPadding),
                          Text(
                            aspect['interpretation'],
                            style: MyStyle.s3.copyWith(
                              color: MyColor.white,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    )),
                verticalGap(MySize.defaultPadding),
              ],

              // Tavsiyeler
              Container(
                padding: const EdgeInsets.all(MySize.defaultPadding),
                decoration: BoxDecoration(
                  color: MyColor.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(MySize.halfRadius),
                  border: Border.all(
                    color: MyColor.primaryLightColor.withOpacity(0.2),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      easy.tr("astrology.advice"),
                      style: MyStyle.s2.copyWith(
                        color: MyColor.primaryLightColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    verticalGap(MySize.halfPadding),
                    Text(
                      retro['advice'],
                      style: MyStyle.s3.copyWith(
                        color: MyColor.white,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getPlanetImageName(String planet) {
    // Gezegen isimlerini küçük harfle ve İngilizce olarak döndür
    switch (planet.toLowerCase()) {
      case 'jupiter':
      case 'jüpiter':
        return 'jupiter';
      case 'uranus':
      case 'uranüs':
        return 'uranus';
      case 'neptune':
      case 'neptün':
        return 'neptune';
      case 'saturn':
      case 'satürn':
        return 'saturn';
      case 'mars':
        return 'mars';
      case 'mercury':
      case 'merkür':
        return 'mercury';
      case 'venus':
      case 'venüs':
        return 'venus';
      case 'pluto':
      case 'plüton':
        return 'pluto';
      case 'sun':
      case 'güneş':
        return 'sun';
      case 'moon':
      case 'ay':
        return 'moon';
      default:
        // Eğer bilinmeyen bir gezegen gelirse, küçük harfe çevirip döndür
        return planet.toLowerCase();
    }
  }

  Widget _buildWeeklyNatalReading() {
    return FutureBuilder<bool>(
        future: PurchaseAPI.isPremium(),
        builder: (context, snapshot) {
          final isPremium = snapshot.data ?? false;

          if (!isPremium) {
            return Container(
              padding: const EdgeInsets.all(MySize.defaultPadding),
              decoration: BoxDecoration(
                color: MyColor.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(MySize.halfRadius),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => Get.dialog(
                    PremiumPopup(
                      onSingleUse: () {
                        Get.back();
                        _astrologyController.checkWeeklyNatalReading();
                      },
                    ),
                  ),
                  borderRadius: BorderRadius.circular(MySize.halfRadius),
                  child: Padding(
                    padding: const EdgeInsets.all(MySize.halfPadding),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(MySize.halfPadding),
                              decoration: BoxDecoration(
                                color: MyColor.white.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.auto_graph,
                                color: MyColor.white,
                              ),
                            ),
                            horizontalGap(MySize.defaultPadding),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    easy.tr("astrology.weekly_natal_reading"),
                                    style: MyStyle.s2.copyWith(
                                      color: MyColor.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    easy.tr(
                                        "astrology.weekly_natal_reading_description"),
                                    style: MyStyle.s3.copyWith(
                                      color: MyColor.textGreyColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              Icons.lock_outline,
                              color: MyColor.white,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }

          if (!_astrologyController.isWeeklyNatalAvailable.value) {
            return const SizedBox.shrink();
          }
          final reading = _astrologyController.weeklyNatalReading;

          return Padding(
            padding:
                const EdgeInsets.symmetric(vertical: MySize.defaultPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: MyColor.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.auto_graph,
                        color: MyColor.white,
                      ),
                    ),
                    horizontalGap(MySize.defaultPadding),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            easy.tr("astrology.weekly_natal_reading"),
                            style: MyStyle.s2.copyWith(
                              color: MyColor.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            easy.tr(
                                "astrology.weekly_natal_reading_description"),
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
                Text(
                  reading['overview'] ?? '',
                  style: MyStyle.s3.copyWith(
                    color: MyColor.white,
                    height: 1.5,
                  ),
                ),
                if (reading['aspects'] != null) ...[
                  verticalGap(MySize.defaultPadding),
                  Text(
                    easy.tr("astrology.important_aspects"),
                    style: MyStyle.s2.copyWith(
                      color: MyColor.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  verticalGap(MySize.halfPadding),
                  Text(
                    reading['aspects'],
                    style: MyStyle.s3.copyWith(
                      color: MyColor.white,
                      height: 1.5,
                    ),
                  ),
                ],
                if (reading['advice'] != null) ...[
                  verticalGap(MySize.defaultPadding),
                  Text(
                    easy.tr("astrology.advice"),
                    style: MyStyle.s2.copyWith(
                      color: MyColor.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  verticalGap(MySize.halfPadding),
                  Text(
                    reading['advice'],
                    style: MyStyle.s3.copyWith(
                      color: MyColor.white,
                      height: 1.5,
                    ),
                  ),
                ],
              ],
            ),
          );
        });
  }

  // Numeroloji içeriğini gösterme fonksiyonu
  void _showNumerologyContent() {
    if (_astrologyController.isSubscribed.value) {
      // Premium kullanıcı için direkt göster
      _showNumerologyDetails();
    } else {
      // Premium olmayan kullanıcı için popup göster
      Get.dialog(
        PremiumPopup(
          onSingleUse: () => _showNumerologyDetails(),
        ),
      );
    }
  }

  // Numeroloji detaylarını gösteren bottom sheet
  void _showNumerologyDetails() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(MySize.doublePadding),
        decoration: const BoxDecoration(
          color: MyColor.darkBackgroundColor,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(MySize.defaultRadius),
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                easy.tr("astrology.weekly_numerology_reading"),
                style: MyStyle.s1.copyWith(
                  color: MyColor.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              verticalGap(MySize.defaultPadding),
              Obx(() {
                if (_astrologyController.isLoading.value) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: MyColor.primaryColor,
                    ),
                  );
                }

                if (!_astrologyController.isNumerologyAvailable.value) {
                  return Center(
                    child: Text(
                      easy.tr("astrology.numerology_not_created"),
                      style: MyStyle.s2.copyWith(
                        color: MyColor.white,
                      ),
                    ),
                  );
                }

                return _buildNumerologyContent();
              }),
            ],
          ),
        ),
      ),
    );

    // Eğer numeroloji yorumu yoksa, oluştur
    if (!_astrologyController.isNumerologyAvailable.value &&
        !_astrologyController.isLoading.value) {
      _astrologyController.checkNumerologyReading();
    }
  }

  // Numeroloji içeriğini oluşturan widget
  Widget _buildNumerologyContent() {
    final reading = _astrologyController.numerologyReading;

    if (reading.isEmpty) {
      return Center(
        child: Text(
          easy.tr("astrology.numerology_not_found"),
          style: MyStyle.s2.copyWith(
            color: MyColor.white,
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          reading['weeklyReading'] ?? '',
          style: MyStyle.s2.copyWith(
            color: MyColor.white,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}
