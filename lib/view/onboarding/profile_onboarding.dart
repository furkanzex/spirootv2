import 'package:animate_do/animate_do.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:lottie/lottie.dart';
import 'package:spirootv2/controller/astrology_controller.dart';
import 'package:spirootv2/controller/profile_controller.dart';
import 'package:spirootv2/core/constant/my_color.dart';
import 'package:spirootv2/core/constant/my_size.dart';
import 'package:spirootv2/core/constant/my_style.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:google_places_flutter/model/prediction.dart';
import 'package:spirootv2/view/homepage.dart';
import 'package:spirootv2/widget/gap/horizontal_gap.dart';
import 'package:spirootv2/widget/gap/vertical_gap.dart';

class ProfileOnboarding extends StatefulWidget {
  const ProfileOnboarding({super.key});

  @override
  State<ProfileOnboarding> createState() => _ProfileOnboardingState();
}

class _ProfileOnboardingState extends State<ProfileOnboarding> {
  final PageController _pageController = PageController();
  final ProfileController _controller = Get.put(ProfileController());
  final AstrologyController controller = Get.put(AstrologyController());
  int _currentPage = 0;
  double _previousRotation = 0.0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: MyColor.primaryDarkColor,
        body: SafeArea(
          child: Column(
            children: [
              // İlerleme göstergesi
              LinearProgressIndicator(
                value: (_currentPage + 1) / 5,
                backgroundColor: MyColor.white.withOpacity(0.1),
                valueColor: AlwaysStoppedAnimation<Color>(MyColor.primaryColor),
              ),
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  onPageChanged: (int page) {
                    setState(() {
                      _currentPage = page;
                    });
                  },
                  children: [
                    _buildNamePage(),
                    _buildBirthDatePage(),
                    _buildBirthTimePage(),
                    _buildBirthPlacePage(),
                    _buildInterestsPage(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNamePage() {
    return FadeInRight(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: MySize.defaultPadding,
          vertical: MySize.doublePadding,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Seni tanıyalım',
              style: MyStyle.s1.copyWith(
                color: MyColor.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            verticalGap(MySize.halfPadding),
            Text(
              'İsmini öğrenebilir miyiz?',
              style: MyStyle.s3.copyWith(color: MyColor.textGreyColor),
            ),
            verticalGap(MySize.doublePadding),
            TextField(
              controller: _controller.nameController,
              style: MyStyle.s2.copyWith(color: MyColor.white),
              onChanged: _controller.validateName,
              decoration: InputDecoration(
                hintText: 'Adın',
                hintStyle: MyStyle.s2.copyWith(color: MyColor.textGreyColor),
                filled: true,
                fillColor: MyColor.white.withOpacity(0.1),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(MySize.halfRadius),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.all(MySize.defaultPadding),
                errorText: _controller.nameController.text.isNotEmpty &&
                        !_controller.isNameValid.value
                    ? 'Geçerli bir isim giriniz'
                    : null,
              ),
            ),
            const Spacer(),
            Obx(() => ElevatedButton(
                  onPressed: _controller.isNameValid.value
                      ? () => _pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          )
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: MyColor.primaryColor,
                    minimumSize:
                        const Size(double.infinity, 56), // Apple's 44pt minimum
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(MySize.halfRadius),
                    ),
                    disabledBackgroundColor:
                        MyColor.primaryColor.withOpacity(0.3),
                  ),
                  child: Text(
                    'Devam Et',
                    style: MyStyle.s2.copyWith(
                      color: MyColor.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildBirthDatePage() {
    return FadeInRight(
      child: Padding(
        padding: const EdgeInsets.all(MySize.defaultPadding),
        child: Column(
          children: [
            // Başlık
            Text(
              'Doğum tarihin',
              style: MyStyle.s1.copyWith(
                color: MyColor.white,
                fontSize: 28,
                fontWeight: FontWeight.w600,
              ),
            ),

            // İlerleme çubuğu
            Container(
              margin:
                  const EdgeInsets.symmetric(vertical: MySize.defaultPadding),
              height: 2,
              width: MediaQuery.of(context).size.width * 0.3,
              color: MyColor.primaryColor,
            ),

            verticalGap(MySize.doublePadding),

            // Burç çarkı
            Obx(() => SizedBox(
                  height: 250,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Burç çarkı arka planı
                      TweenAnimationBuilder(
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeInOut,
                        tween: Tween<double>(
                          begin: _previousRotation,
                          end: controller.getZodiacRotation(
                              _controller.selectedDate.value),
                        ),
                        onEnd: () {
                          _previousRotation = controller.getZodiacRotation(
                              _controller.selectedDate.value);
                        },
                        builder: (context, double angle, child) {
                          return Transform.rotate(
                            angle: angle,
                            child: Image.asset(
                              'assets/images/zodiac_wheel.png',
                              width: 250,
                            ),
                          );
                        },
                      ),
                      // Işık efekti
                      Container(
                        width: 250,
                        height: 250,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.center,
                            colors: [
                              MyColor.primaryDarkColor.withOpacity(0.3),
                              MyColor.primaryDarkColor,
                            ],
                          ),
                        ),
                      ),
                      verticalGap(MySize.doublePadding),
                      Text(
                        'Tarih burç, numeroloji ve uyumluluk hesaplamaları için önemlidir',
                        textAlign: TextAlign.center,
                        style: MyStyle.s2.copyWith(
                          color: MyColor.textGreyColor,
                        ),
                      ),
                    ],
                  ),
                )),

            // Açıklama metni

            const Spacer(),

            // Tarih seçici
            Container(
              height: 180,
              decoration: BoxDecoration(
                color: MyColor.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(MySize.halfRadius),
              ),
              child: CupertinoTheme(
                data: CupertinoThemeData(
                  textTheme: CupertinoTextThemeData(
                    dateTimePickerTextStyle: MyStyle.s1.copyWith(
                      color: MyColor.white,
                      fontSize: 22,
                    ),
                  ),
                ),
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.date,
                  initialDateTime: _controller.selectedDate.value,
                  maximumDate: DateTime.now(),
                  minimumDate: DateTime(1900),
                  onDateTimeChanged: (DateTime value) {
                    _controller.selectedDate.value = value;
                    _controller.validateDate();
                  },
                ),
              ),
            ),

            verticalGap(MySize.defaultPadding),

            // İleri butonu
            ElevatedButton(
              onPressed: _controller.isDateValid.value
                  ? () => _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      )
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: MyColor.primaryColor,
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(MySize.halfRadius),
                ),
              ),
              child: Text(
                'İleri',
                style: MyStyle.s2.copyWith(
                  color: MyColor.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBirthTimePage() {
    return FadeInRight(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: MySize.defaultPadding,
          vertical: MySize.doublePadding,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Doğum saatin',
              style: MyStyle.s1.copyWith(
                color: MyColor.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            verticalGap(MySize.halfPadding),
            Text(
              'Bilmiyorsan boş bırakabilirsin',
              style: MyStyle.s3.copyWith(color: MyColor.textGreyColor),
            ),
            verticalGap(MySize.doublePadding),
            // İki sütunlu saat seçici
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: MyColor.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(MySize.halfRadius),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: CupertinoPicker(
                      itemExtent: 32,
                      onSelectedItemChanged: (int index) {
                        _controller.selectedHour.value =
                            index.toString().padLeft(2, '0');
                        _controller.updateSelectedTime();
                      },
                      children: List<Widget>.generate(24, (int index) {
                        return Center(
                          child: Text(
                            index.toString().padLeft(2, '0'),
                            style: MyStyle.s2.copyWith(color: MyColor.white),
                          ),
                        );
                      }),
                    ),
                  ),
                  Expanded(
                    child: CupertinoPicker(
                      itemExtent: 32,
                      onSelectedItemChanged: (int index) {
                        _controller.selectedMinute.value =
                            index.toString().padLeft(2, '0');
                        _controller.updateSelectedTime();
                      },
                      children: List<Widget>.generate(60, (int index) {
                        return Center(
                          child: Text(
                            index.toString().padLeft(2, '0'),
                            style: MyStyle.s2.copyWith(color: MyColor.white),
                          ),
                        );
                      }),
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            _buildNavigationButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildBirthPlacePage() {
    return FadeInRight(
      child: Padding(
        padding: const EdgeInsets.all(MySize.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Lottie.asset(
              'assets/lottie/location_animation.json',
              height: 200,
            ),
            verticalGap(MySize.doublePadding),
            Text(
              'Nerede doğdun?',
              style: MyStyle.s1.copyWith(
                color: MyColor.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            verticalGap(MySize.halfPadding),
            Text(
              'Astrolojik hesaplamalar için önemli',
              style: MyStyle.s3.copyWith(color: MyColor.textGreyColor),
            ),
            verticalGap(MySize.doublePadding),
            GooglePlaceAutoCompleteTextField(
              textEditingController: _controller.birthPlaceController,
              googleAPIKey: "AIzaSyDri3yUianYuZw3PfZlruuFLg196-UhXE8",
              textStyle: MyStyle.s2.copyWith(color: MyColor.white),

              inputDecoration: InputDecoration(
                hintText: 'Doğum yerini ara',
                hintStyle: MyStyle.s2.copyWith(color: MyColor.textGreyColor),
                filled: false,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(MySize.halfRadius),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.all(MySize.defaultPadding),
                prefixIcon:
                    Icon(MingCute.search_2_line, color: MyColor.textGreyColor),
                suffixIcon: _controller.birthPlaceController.text.isNotEmpty
                    ? IconButton(
                        onPressed: () {
                          _controller.birthPlaceController.clear();
                        },
                        icon: Icon(MingCute.close_line,
                            color: MyColor.textGreyColor),
                      )
                    : null,
              ),
              debounceTime: 800,
              countries: const ["tr"],
              isLatLngRequired: true,
              getPlaceDetailWithLatLng: (Prediction prediction) {
                _controller.birthPlaceController.text = prediction.description!;
                _controller.validatePlace(prediction.description!);
              },
              itemClick: (Prediction prediction) {
                _controller.birthPlaceController.text = prediction.description!;
                _controller.validatePlace(prediction.description!);
              },
              // Özel liste görünümü
              seperatedBuilder: Divider(
                height: 1,
                color: MyColor.white.withOpacity(0.1),
              ),
              // Özel liste öğesi görünümü
              itemBuilder: (context, index, Prediction prediction) {
                return Container(
                  decoration: BoxDecoration(
                    color: MyColor.darkBackgroundColor,
                    border: Border(
                      bottom: BorderSide(
                        color: MyColor.white.withOpacity(0.1),
                        width: 1,
                      ),
                    ),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        _controller.birthPlaceController.text =
                            prediction.description!;
                        _controller.validatePlace(prediction.description!);
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(MySize.defaultPadding),
                        child: Row(
                          children: [
                            Icon(
                              MingCute.location_2_line,
                              color: MyColor.textGreyColor,
                              size: 24,
                            ),
                            horizontalGap(MySize.defaultPadding),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    prediction.structuredFormatting?.mainText ??
                                        '',
                                    style: MyStyle.s2.copyWith(
                                      color: MyColor.white,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  if (prediction.structuredFormatting
                                          ?.secondaryText !=
                                      null)
                                    Text(
                                      prediction
                                          .structuredFormatting!.secondaryText!,
                                      style: MyStyle.s3.copyWith(
                                        color: MyColor.textGreyColor,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
              isCrossBtnShown: true,
            ),
            const Spacer(),
            _buildNavigationButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildInterestsPage() {
    final List<String> allInterests = [
      'Astroloji',
      'Tarot',
      'Meditasyon',
      'Yoga',
      'Reiki',
      'Kristaller',
      'Numeroloji',
      'Rüya Yorumu',
      'Şifa',
      'Spiritüel Gelişim',
    ];

    return FadeInRight(
      child: Padding(
        padding: const EdgeInsets.all(MySize.defaultPadding),
        child: Column(
          children: [
            Lottie.asset(
              'assets/lottie/interests_animation.json',
              height: 150,
            ),
            verticalGap(MySize.defaultPadding),
            Text(
              'İlgi alanlarını seç',
              style: MyStyle.s1.copyWith(
                color: MyColor.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            verticalGap(MySize.defaultPadding),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 2.5,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: allInterests.length,
                itemBuilder: (context, index) {
                  final interest = allInterests[index];
                  return Obx(() {
                    final isSelected =
                        _controller.selectedInterests.contains(interest);
                    return GestureDetector(
                      onTap: () {
                        if (isSelected) {
                          _controller.selectedInterests.remove(interest);
                        } else {
                          _controller.selectedInterests.add(interest);
                        }
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: isSelected
                              ? MyColor.primaryColor
                              : MyColor.white.withOpacity(0.1),
                          borderRadius:
                              BorderRadius.circular(MySize.halfRadius),
                        ),
                        child: Center(
                          child: Text(
                            interest,
                            style: MyStyle.s3.copyWith(
                              color: MyColor.white,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                      ),
                    );
                  });
                },
              ),
            ),
            verticalGap(MySize.defaultPadding),
            ElevatedButton(
              onPressed: () async {
                if (_controller.selectedInterests.isNotEmpty) {
                  try {
                    await _controller.saveUserProfile();
                    Get.offAll(() => const HomePage());
                  } catch (e) {
                    Get.snackbar(
                      'Hata',
                      'Profil kaydedilirken bir hata oluştu',
                      backgroundColor: MyColor.errorColor,
                      colorText: MyColor.white,
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: MyColor.primaryColor,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(MySize.halfRadius),
                ),
              ),
              child: Text(
                'Profili Tamamla',
                style: MyStyle.s2.copyWith(
                  color: MyColor.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (_currentPage > 0)
          TextButton(
            onPressed: () {
              _pageController.previousPage(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            },
            child: Text(
              'Geri',
              style: MyStyle.s2.copyWith(color: MyColor.primaryColor),
            ),
          ),
        ElevatedButton(
          onPressed: () {
            _pageController.nextPage(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: MyColor.primaryColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(MySize.halfRadius),
            ),
          ),
          child: Text(
            'Devam',
            style: MyStyle.s2.copyWith(color: MyColor.white),
          ),
        ),
      ],
    );
  }
}
