import 'package:animate_do/animate_do.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:lottie/lottie.dart';
import 'package:spirootv2/controller/astrology_controller.dart';
import 'package:spirootv2/controller/profile_controller.dart';
import 'package:spirootv2/core/constant/my_color.dart';
import 'package:spirootv2/core/constant/my_icon.dart';
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
  late final PageController _pageController;
  late final ProfileController _controller;
  late final AstrologyController _astrologyController;
  final FocusNode _focusNode = FocusNode();
  int _currentPage = 0;
  double _previousRotation = 0.0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _controller = Get.put(ProfileController());
    _astrologyController = Get.put(AstrologyController());
    _pageController.addListener(_onPageChanged);
  }

  void _onPageChanged() {
    if (_pageController.page != null) {
      setState(() {
        _currentPage = _pageController.page!.round();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Focus(
        focusNode: _focusNode,
        child: Scaffold(
          backgroundColor: MyColor.primaryDarkColor,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            automaticallyImplyLeading: false,
            leading: _currentPage > 0
                ? IconButton(
                    icon: Icon(MyIcon.back, color: MyColor.white),
                    onPressed: () {
                      _pageController.previousPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                  )
                : null,
            title: Text(
              _getPageTitle(_currentPage),
              style: MyStyle.s1.copyWith(
                color: MyColor.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          body: SafeArea(
            child: Column(
              children: [
                LinearProgressIndicator(
                  value: (_currentPage + 1) / 7,
                  backgroundColor: MyColor.white.withOpacity(0.1),
                  valueColor:
                      AlwaysStoppedAnimation<Color>(MyColor.primaryLightColor),
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
                      _buildGenderPage(),
                      _buildRelationshipStatusPage(),
                      _buildInterestsPage(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getPageTitle(int page) {
    switch (page) {
      case 0:
        return 'Seni tanıyalım';
      case 1:
        return 'Doğum tarihin';
      case 2:
        return 'Doğum saatin';
      case 3:
        return 'Doğum yerin';
      case 4:
        return 'Cinsiyetin';
      case 5:
        return 'İlişki durumun';
      case 6:
        return 'İlgi alanların';
      default:
        return '';
    }
  }

  Widget _buildNamePage() {
    return FadeInRight(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: MySize.defaultPadding,
          vertical: MySize.doublePadding,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              height: 150,
              child: Image.asset(
                'assets/images/name.png',
                width: 250,
              ),
            ),
            verticalGap(MySize.doublePadding),
            TextField(
              controller: _controller.nameController,
              style: MyStyle.s2.copyWith(color: MyColor.white),
              decoration: InputDecoration(
                labelText: 'İsmin nedir?',
                labelStyle: MyStyle.s2.copyWith(color: MyColor.textGreyColor),
                filled: true,
                fillColor: MyColor.white.withOpacity(0.1),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(MySize.halfRadius),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.all(MySize.defaultPadding),
                errorText: _controller.showNameError.value
                    ? 'İsim alanı boş bırakılamaz'
                    : null,
              ),
            ),
            const Spacer(),
            _buildNavigationButtons(onValidate: _controller.validateNamePage),
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
            Expanded(
              child: Obx(() {
                final zodiacSign = _astrologyController
                    .getZodiacSign(_controller.selectedDate.value);
                final zodiacDetails = _astrologyController
                    .getZodiacDetails(_controller.selectedDate.value);

                return Column(
                  children: [
                    verticalGap(MySize.defaultPadding),
                    SizedBox(
                      height: 300,
                      child: Stack(
                        alignment: Alignment.bottomCenter,
                        children: [
                          // Burç çarkı arka planı
                          TweenAnimationBuilder(
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.easeInOut,
                            tween: Tween<double>(
                              begin: _previousRotation,
                              end: _astrologyController.calculateZodiacRotation(
                                  _controller.selectedDate.value),
                            ),
                            onEnd: () {
                              _previousRotation =
                                  _astrologyController.calculateZodiacRotation(
                                      _controller.selectedDate.value);
                            },
                            builder: (context, double angle, child) {
                              return Transform.rotate(
                                angle: angle,
                                child: Image.asset(
                                  'assets/images/zodiac_wheel.png',
                                  width: 300,
                                ),
                              );
                            },
                          ),
                          // Işık efekti
                          Container(
                            width: 300,
                            height: 300,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.center,
                                colors: [
                                  MyColor.primaryDarkColor.withOpacity(0),
                                  MyColor.primaryDarkColor,
                                ],
                              ),
                            ),
                          ),
                          if (zodiacDetails.isNotEmpty)
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Burç: $zodiacSign ${zodiacDetails['symbol']}',
                                  style:
                                      MyStyle.s2.copyWith(color: MyColor.white),
                                ),
                                verticalGap(MySize.halfPadding),
                                Text(
                                  'Element: ${zodiacDetails['element']}',
                                  style: MyStyle.s3
                                      .copyWith(color: MyColor.textGreyColor),
                                ),
                                Text(
                                  'Nitelik: ${zodiacDetails['quality']}',
                                  style: MyStyle.s3
                                      .copyWith(color: MyColor.textGreyColor),
                                ),
                                Text(
                                  'Yönetici Gezegen: ${zodiacDetails['ruler']}',
                                  style: MyStyle.s3
                                      .copyWith(color: MyColor.textGreyColor),
                                ),
                                verticalGap(MySize.defaultPadding),
                                Text(
                                  'Tarih Aralığı: ${zodiacDetails['dateRange']}',
                                  style: MyStyle.s3.copyWith(
                                      color: MyColor.primaryLightColor),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ],
                );
              }),
            ),
            Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(MySize.defaultPadding),
                  decoration: BoxDecoration(
                    color: MyColor.darkBackgroundColor,
                    borderRadius: BorderRadius.circular(MySize.halfRadius),
                  ),
                  child: Column(
                    children: [
                      Container(
                        height: 180,
                        decoration: BoxDecoration(
                          color: MyColor.transparent,
                          borderRadius:
                              BorderRadius.circular(MySize.halfRadius),
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
                    ],
                  ),
                ),
                verticalGap(MySize.defaultPadding),
                _buildNavigationButtons(
                  onValidate: () => _controller.validateDatePage(),
                ),
              ],
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
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Tarih burç, numeroloji ve uyumluluk hesaplamaları için önemlidir',
              textAlign: TextAlign.center,
              style: MyStyle.s3.copyWith(
                color: MyColor.textGreyColor,
              ),
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
                        _controller.updateSelectedTime(
                            _controller.selectedHour.value,
                            _controller.selectedMinute.value);
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
                        _controller.updateSelectedTime(
                            _controller.selectedHour.value,
                            _controller.selectedMinute.value);
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
            _buildNavigationButtons(onValidate: _controller.validateTimePage),
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
                labelText: 'Doğum yerini ara',
                labelStyle: MyStyle.s2.copyWith(color: MyColor.textGreyColor),
                filled: false,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(MySize.halfRadius),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.all(MySize.defaultPadding),
                prefixIcon: Icon(MingCute.search_2_line,
                    color: MyColor.textGreyColor.withOpacity(0.5)),
              ),
              debounceTime: 800,
              countries: const ["tr", "us", "gb"],
              isLatLngRequired: true,
              getPlaceDetailWithLatLng: (Prediction prediction) {
                _controller.birthPlaceController.text = prediction.description!;
                _controller.validatePlace(prediction.description!);
                FocusScope.of(context).unfocus();
              },
              itemClick: (Prediction prediction) {
                _controller.birthPlaceController.text = prediction.description!;
                _controller.validatePlace(prediction.description!);
                FocusScope.of(context).unfocus();
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
            _buildNavigationButtons(onValidate: _controller.validatePlacePage),
          ],
        ),
      ),
    );
  }

  Widget _buildGenderPage() {
    return FadeInRight(
      child: Padding(
        padding: const EdgeInsets.all(MySize.defaultPadding),
        child: Column(
          children: [
            Lottie.asset(
              'assets/lottie/gender_animation.json',
              height: 200,
            ),
            verticalGap(MySize.defaultPadding),
            Expanded(
              child: ListView.builder(
                itemCount: _controller.genders.length,
                itemBuilder: (context, index) {
                  final gender = _controller.genders[index];
                  return Obx(() {
                    final isSelected =
                        _controller.selectedGender.value == gender;
                    return Padding(
                      padding:
                          const EdgeInsets.only(bottom: MySize.defaultPadding),
                      child: InkWell(
                        onTap: () {
                          _controller.selectedGender.value = gender;
                          _controller.validateGender(gender);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(MySize.defaultPadding),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? MyColor.primaryColor
                                : MyColor.white.withOpacity(0.1),
                            borderRadius:
                                BorderRadius.circular(MySize.halfRadius),
                          ),
                          child: Text(
                            gender,
                            style: MyStyle.s2.copyWith(
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
            _buildNavigationButtons(onValidate: _controller.validateGenderPage),
          ],
        ),
      ),
    );
  }

  Widget _buildRelationshipStatusPage() {
    return FadeInRight(
      child: Padding(
        padding: const EdgeInsets.all(MySize.defaultPadding),
        child: Column(
          children: [
            Lottie.asset(
              'assets/lottie/relationship_animation.json',
              height: 200,
            ),
            verticalGap(MySize.defaultPadding),
            Expanded(
              child: ListView.builder(
                itemCount: _controller.relationshipStatuses.length,
                itemBuilder: (context, index) {
                  final status = _controller.relationshipStatuses[index];
                  return Obx(() {
                    final isSelected =
                        _controller.selectedRelationshipStatus.value == status;
                    return Padding(
                      padding:
                          const EdgeInsets.only(bottom: MySize.defaultPadding),
                      child: InkWell(
                        onTap: () {
                          _controller.selectedRelationshipStatus.value = status;
                          _controller.validateRelationshipStatus(status);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(MySize.defaultPadding),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? MyColor.primaryColor
                                : MyColor.white.withOpacity(0.1),
                            borderRadius:
                                BorderRadius.circular(MySize.halfRadius),
                          ),
                          child: Text(
                            status,
                            style: MyStyle.s2.copyWith(
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
            _buildNavigationButtons(
                onValidate: _controller.validateRelationshipPage),
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

  Widget _buildNavigationButtons({
    required Function() onValidate,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Spacer(),
        ElevatedButton(
          onPressed: () {
            if (onValidate()) {
              _pageController.nextPage(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: MyColor.primaryLightColor,
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

  @override
  void dispose() {
    _pageController.removeListener(_onPageChanged);
    _pageController.dispose();
    _focusNode.dispose();
    super.dispose();
  }
}
