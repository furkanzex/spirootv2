import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:extended_image/extended_image.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:share/share.dart';
import 'package:spirootv2/core/constant/my_color.dart';
import 'package:spirootv2/core/constant/my_size.dart';
import 'package:spirootv2/core/constant/my_style.dart';

class CompatibilityResultScreen extends StatelessWidget {
  final Map<String, dynamic> result;
  final String firstZodiac;
  final String secondZodiac;

  const CompatibilityResultScreen({
    super.key,
    required this.result,
    required this.firstZodiac,
    required this.secondZodiac,
  });

  @override
  Widget build(BuildContext context) {
    // Yüzdeleri int'e çevir
    final overallPercentage = (result['overallPercentage'] as num).toInt();

    // Seçilen türe göre yüzdeleri al
    final isLoveType = result.containsKey('lovePercentage');

    final Map<String, int> percentages = isLoveType
        ? {
            'Aşk': (result['lovePercentage'] as num).toInt(),
            'Tutku': (result['sexPercentage'] as num).toInt(),
            'Aile': (result['familyPercentage'] as num).toInt(),
            'Güven': (result['trustPercentage'] as num).toInt(),
          }
        : {
            'Arkadaşlık': (result['friendshipPercentage'] as num).toInt(),
            'Güven': (result['trustPercentage'] as num).toInt(),
            'İletişim': (result['communicationPercentage'] as num).toInt(),
            'İş': (result['businessPercentage'] as num).toInt(),
          };

    return Scaffold(
      backgroundColor: MyColor.darkBackgroundColor,
      appBar: AppBar(
        surfaceTintColor: MyColor.transparent,
        backgroundColor: MyColor.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: MyColor.white),
          onPressed: () => Get.back(),
        ),
        title: Text(
          isLoveType ? "Aşk Uyumu" : "Arkadaşlık Uyumu",
          style: MyStyle.s1.copyWith(color: MyColor.white),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Share.share(
                'SPIROOT uygulamasından paylaşıldı.\n\n${result['overallDescription']}',
                subject: isLoveType ? 'Aşk Uyumu' : 'Arkadaşlık Uyumu',
              );
            },
            icon: const Icon(
              MingCute.upload_line,
              color: MyColor.white,
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(MySize.defaultPadding),
          child: Column(
            children: [
              // Burç görselleri ve + işareti
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildZodiacCircle(firstZodiac),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Icon(Icons.add, color: MyColor.white, size: 30),
                  ),
                  _buildZodiacCircle(secondZodiac),
                ],
              ),
              verticalGap(MySize.defaultPadding),

              // Burç isimleri ve tarihleri
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildZodiacInfo(
                    result['firstZodiac'] ?? '',
                    result['firstDate'] ?? '',
                  ),
                  _buildZodiacInfo(
                    result['secondZodiac'] ?? '',
                    result['secondDate'] ?? '',
                  ),
                ],
              ),
              verticalGap(MySize.doublePadding),

              // Başlık
              Text(
                result['title'] ?? "Kozmik Bağlantı",
                style: MyStyle.s1.copyWith(
                  color: MyColor.white,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              verticalGap(MySize.defaultPadding),

              // Genel uyum yüzdesi
              Container(
                width: double.infinity,
                height: 8,
                decoration: BoxDecoration(
                  color: MyColor.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Stack(
                  children: [
                    FractionallySizedBox(
                      widthFactor: overallPercentage / 100,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              MyColor.primaryColor,
                              MyColor.secondaryColor
                            ],
                          ),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                "$overallPercentage%",
                style: MyStyle.s2.copyWith(color: MyColor.white),
              ),
              verticalGap(MySize.doublePadding),

              // Detaylı uyum yüzdeleri
              ...percentages.entries.map((entry) =>
                  _buildCompatibilitySection(entry.key, entry.value)),
              verticalGap(MySize.doublePadding),

              // Overall açıklama
              Text(
                "Genel Değerlendirme",
                style: MyStyle.s1.copyWith(
                  color: MyColor.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              verticalGap(MySize.defaultPadding),
              Text(
                result['overallDescription'] ?? "",
                style: MyStyle.s2.copyWith(
                  color: MyColor.white,
                  height: 1.5,
                ),
              ),
              verticalGap(MySize.doublePadding),

              // Values açıklaması
              Text(
                "Ortak Değerler",
                style: MyStyle.s1.copyWith(
                  color: MyColor.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              verticalGap(MySize.defaultPadding),
              Text(
                result['valuesDescription'] ?? "",
                style: MyStyle.s2.copyWith(
                  color: MyColor.white,
                  height: 1.5,
                ),
              ),
              verticalGap(MySize.doublePadding),

              // Aşk ya da arkadaşlık açıklaması
              Text(
                isLoveType ? "Aşk" : "Arkadaşlık",
                style: MyStyle.s1.copyWith(
                  color: MyColor.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              verticalGap(MySize.defaultPadding),
              Text(
                isLoveType
                    ? (result['loveDescription'] ?? "")
                    : (result['friendshipDescription'] ?? ""),
                style: MyStyle.s2.copyWith(
                  color: MyColor.white,
                  height: 1.5,
                ),
              ),
              verticalGap(MySize.defaultPadding),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildZodiacCircle(String zodiac) {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: MyColor.primaryColor.withOpacity(0.2),
      ),
      child: ExtendedImage.network(
        'https://apptoic.com/spiroot/images/$zodiac.png',
        fit: BoxFit.cover,
        cache: true,
      ),
    );
  }

  Widget _buildZodiacInfo(String zodiac, String date) {
    return Column(
      children: [
        Text(
          zodiac.toUpperCase(),
          style: MyStyle.s1.copyWith(
            color: MyColor.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          date,
          style: MyStyle.s3.copyWith(color: MyColor.textGreyColor),
        ),
      ],
    );
  }

  Widget _buildCompatibilitySection(String title, int percentage) {
    return Padding(
      padding: const EdgeInsets.only(bottom: MySize.defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: MyStyle.s2.copyWith(color: MyColor.white),
              ),
              Text(
                "$percentage%",
                style: MyStyle.s2.copyWith(color: MyColor.primaryColor),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            height: 4,
            decoration: BoxDecoration(
              color: MyColor.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(2),
            ),
            child: FractionallySizedBox(
              widthFactor: percentage / 100,
              child: Container(
                decoration: BoxDecoration(
                  color: MyColor.primaryColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget verticalGap(double height) {
    return SizedBox(height: height);
  }

  Widget horizontalGap(double width) {
    return SizedBox(width: width);
  }
}
