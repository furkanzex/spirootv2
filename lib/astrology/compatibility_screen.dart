import 'package:flutter/material.dart';
import 'package:extended_image/extended_image.dart';
import 'package:get/get.dart';
import 'package:spirootv2/core/constant/my_color.dart';
import 'package:spirootv2/core/constant/my_icon.dart';
import 'package:spirootv2/core/constant/my_size.dart';
import 'package:spirootv2/core/constant/my_style.dart';
import 'package:easy_localization/easy_localization.dart' as easy;
import 'package:spirootv2/astrology/astrology_controller.dart';
import 'package:spirootv2/profile/user_controller.dart';

class CompatibilityScreen extends StatelessWidget {
  CompatibilityScreen({super.key});

  final AstrologyController _astrologyController =
      Get.find<AstrologyController>();
  final UserController _userController = Get.find<UserController>();

  final List<Map<String, String>> zodiacSigns = [
    {'name': 'sagittarius', 'date': 'Nov 22 - Dec 21'},
    {'name': 'capricorn', 'date': 'Dec 22 - Jan 19'},
    {'name': 'aquarius', 'date': 'Jan 20 - Feb 18'},
    {'name': 'pisces', 'date': 'Feb 19 - Mar 20'},
    {'name': 'aries', 'date': 'Mar 21 - Apr 19'},
    {'name': 'taurus', 'date': 'Apr 20 - May 20'},
    {'name': 'gemini', 'date': 'May 21 - Jun 20'},
    {'name': 'cancer', 'date': 'Jun 21 - Jul 22'},
    {'name': 'leo', 'date': 'Jul 23 - Aug 22'},
    {'name': 'virgo', 'date': 'Aug 23 - Sep 22'},
    {'name': 'libra', 'date': 'Sep 23 - Oct 22'},
    {'name': 'scorpio', 'date': 'Oct 23 - Nov 21'},
  ];

  final PageController _firstPageController = PageController(
    viewportFraction: 0.4,
    initialPage: 3,
  );

  final PageController _secondPageController = PageController(
    viewportFraction: 0.4,
    initialPage: 3,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColor.darkBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          "Compatibility",
          style: MyStyle.s1.copyWith(
            color: MyColor.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        automaticallyImplyLeading: false,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(
            MyIcon.back,
            color: MyColor.white,
          ),
        ),
      ),
      body: Column(
        children: [
          const Spacer(),
          // İlk burç seçici
          SizedBox(
            height: 250,
            child: PageView.builder(
              controller: _firstPageController,
              itemCount: zodiacSigns.length,
              onPageChanged: (index) {
                _astrologyController.setFirstZodiac(index);
              },
              itemBuilder: (context, index) {
                final sign = zodiacSigns[index];
                return Obx(() {
                  final isSelected =
                      index == _astrologyController.selectedFirstZodiac.value;
                  final isUserZodiac = sign['name'] ==
                      _userController.currentUser.value?.zodiacSign;
                  return AnimatedScale(
                    scale: isSelected ? 1.0 : 0.7,
                    duration: const Duration(milliseconds: 300),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: isSelected ? 180 : 140,
                          height: isSelected ? 180 : 140,
                          margin: const EdgeInsets.symmetric(
                              horizontal: MySize.defaultPadding),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isSelected
                                ? MyColor.primaryColor.withOpacity(0.2)
                                : Colors.transparent,
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color:
                                          MyColor.primaryColor.withOpacity(0.3),
                                      blurRadius: 20,
                                      spreadRadius: 5,
                                    )
                                  ]
                                : null,
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              ExtendedImage.network(
                                'https://apptoic.com/spiroot/images/${sign['name']}.png',
                                width: isSelected ? 160 : 120,
                                height: isSelected ? 160 : 120,
                                cache: true,
                                loadStateChanged: (state) {
                                  switch (state.extendedImageLoadState) {
                                    case LoadState.loading:
                                      return const Center(
                                          child: CircularProgressIndicator());
                                    case LoadState.completed:
                                      return state.completedWidget;
                                    case LoadState.failed:
                                      return const Center(
                                          child: Icon(Icons.error));
                                  }
                                },
                              ),
                              if (isUserZodiac)
                                Positioned(
                                  top: 0,
                                  right: 0,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: MyColor.white,
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.2),
                                          blurRadius: 4,
                                        ),
                                      ],
                                    ),
                                    child: const Text(
                                      "You",
                                      style: TextStyle(
                                        color: MyColor.darkBackgroundColor,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        if (isSelected) ...[
                          Text(
                            _getLocalizedZodiacName(sign['name']!),
                            style: MyStyle.s1.copyWith(
                              color: MyColor.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            sign['date']!,
                            style: MyStyle.s3.copyWith(
                              color: MyColor.textGreyColor,
                            ),
                          ),
                        ],
                      ],
                    ),
                  );
                });
              },
            ),
          ),

          // VS Bölümü
          Container(
            margin: const EdgeInsets.symmetric(vertical: MySize.defaultPadding),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  height: 1,
                  color: MyColor.primaryColor.withOpacity(0.3),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: MySize.defaultPadding,
                    vertical: MySize.halfPadding,
                  ),
                  decoration: BoxDecoration(
                    color: MyColor.primaryColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: MyColor.primaryColor.withOpacity(0.3),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: MyColor.primaryColor.withOpacity(0.1),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Text(
                    "VS",
                    style: MyStyle.s1.copyWith(
                      color: MyColor.primaryColor,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // İkinci burç seçici
          SizedBox(
            height: 250,
            child: PageView.builder(
              controller: _secondPageController,
              itemCount: zodiacSigns.length,
              onPageChanged: (index) {
                _astrologyController.setSecondZodiac(index);
              },
              itemBuilder: (context, index) {
                final sign = zodiacSigns[index];
                return Obx(() {
                  final isSelected =
                      index == _astrologyController.selectedSecondZodiac.value;
                  return AnimatedScale(
                    scale: isSelected ? 1.0 : 0.7,
                    duration: const Duration(milliseconds: 300),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: isSelected ? 180 : 140,
                          height: isSelected ? 180 : 140,
                          margin: const EdgeInsets.symmetric(
                              horizontal: MySize.defaultPadding),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isSelected
                                ? MyColor.primaryColor.withOpacity(0.2)
                                : Colors.transparent,
                          ),
                          child: ExtendedImage.network(
                            'https://apptoic.com/spiroot/images/${sign['name']}.png',
                            width: isSelected ? 160 : 120,
                            height: isSelected ? 160 : 120,
                            cache: true,
                            loadStateChanged: (state) {
                              switch (state.extendedImageLoadState) {
                                case LoadState.loading:
                                  return const Center(
                                      child: CircularProgressIndicator());
                                case LoadState.completed:
                                  return state.completedWidget;
                                case LoadState.failed:
                                  return const Center(child: Icon(Icons.error));
                              }
                            },
                          ),
                        ),
                        if (isSelected) ...[
                          Text(
                            _getLocalizedZodiacName(sign['name']!),
                            style: MyStyle.s1.copyWith(
                              color: MyColor.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            sign['date']!,
                            style: MyStyle.s3.copyWith(
                              color: MyColor.textGreyColor,
                            ),
                          ),
                        ],
                      ],
                    ),
                  );
                });
              },
            ),
          ),

          const Spacer(),
          // Check Compatibility butonu
          Padding(
            padding: const EdgeInsets.all(MySize.defaultPadding),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(MySize.defaultRadius),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF6C5DD3).withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: () => _astrologyController.checkCompatibility(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6C5DD3),
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(MySize.defaultRadius),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  "CHECK COMPATIBILITY",
                  style: MyStyle.s2.copyWith(
                    color: MyColor.white,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getLocalizedZodiacName(String sign) {
    return easy.tr("astrology.zodiac.$sign.name");
  }
}
