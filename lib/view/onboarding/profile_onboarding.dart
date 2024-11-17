import 'dart:math';

import 'package:animate_do/animate_do.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:spirootv2/controller/astrology_controller.dart';
import 'package:spirootv2/controller/profile_controller.dart';
import 'package:spirootv2/core/constant/my_color.dart';
import 'package:spirootv2/core/constant/my_icon.dart';
import 'package:spirootv2/core/constant/my_size.dart';
import 'package:spirootv2/core/constant/my_style.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:google_places_flutter/model/prediction.dart';
import 'package:spirootv2/widget/gap/horizontal_gap.dart';
import 'package:spirootv2/widget/gap/vertical_gap.dart';
import 'package:spirootv2/view/onboarding/profile_loading_screen.dart';

class ProfileOnboarding extends StatefulWidget {
  const ProfileOnboarding({super.key});

  @override
  State<ProfileOnboarding> createState() => _ProfileOnboardingState();
}

class _ProfileOnboardingState extends State<ProfileOnboarding> {
  late final PageController _pageController;
  late final ProfileController _controller;
  late final AstrologyController _astrologyController;
  final FocusNode _birthPlaceFocusNode = FocusNode();
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
                      curve: Curves.easeOut,
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
          mainAxisSize: MainAxisSize.min,
          children: [
            Obx(() {
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
                                style: MyStyle.s3
                                    .copyWith(color: MyColor.primaryLightColor),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ],
              );
            }),
            verticalGap(MySize.doublePadding),
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
                            itemExtent: MySize.tenQuartersPadding,
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
              ],
            ),
            const Spacer(),
            _buildNavigationButtons(
              onValidate: () => _controller.validateDatePage(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBirthTimePage() {
    final randomRotation = (Random().nextDouble() * 2 * pi) - pi;
    return FadeInRight(
      child: Padding(
        padding: const EdgeInsets.all(MySize.defaultPadding),
        child: Column(
          children: [
            Column(
              children: [
                verticalGap(MySize.defaultPadding),
                SizedBox(
                  height: 300,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      TweenAnimationBuilder(
                        duration: const Duration(seconds: 5),
                        curve: Curves.easeInOut,
                        tween: Tween<double>(
                          begin: _previousRotation,
                          end: randomRotation,
                        ),
                        onEnd: () {
                          setState(() {
                            _previousRotation = randomRotation;
                          });
                        },
                        builder: (context, double angle, child) {
                          return Transform.rotate(
                            angle: angle,
                            child: Image.asset(
                              'assets/images/birth_time.png',
                              width: 280,
                            ),
                          );
                        },
                      ),
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
                      Column(
                        children: [
                          Flexible(
                            flex: 3,
                            child: Container(),
                          ),
                          Flexible(
                            flex: 2,
                            child: Text(
                              'Tarih burç, numeroloji ve uyumluluk hesaplamaları için önemlidir',
                              textAlign: TextAlign.center,
                              style: MyStyle.s3.copyWith(
                                color: MyColor.textGreyColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
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
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Text(
                                  "Saat",
                                  style:
                                      MyStyle.s2.copyWith(color: MyColor.white),
                                ),
                                Text(
                                  "Dakika",
                                  style:
                                      MyStyle.s2.copyWith(color: MyColor.white),
                                ),
                              ],
                            ),
                            Expanded(
                              child: Row(
                                children: [
                                  Expanded(
                                    child: CupertinoPicker(
                                      itemExtent: MySize.doublePadding,
                                      onSelectedItemChanged: (int index) {
                                        _controller.selectedHour.value =
                                            index.toString().padLeft(2, '0');
                                        _controller.updateSelectedTime(
                                            _controller.selectedHour.value,
                                            _controller.selectedMinute.value);
                                      },
                                      children: List<Widget>.generate(24,
                                          (int index) {
                                        return Center(
                                          child: Text(
                                            index.toString().padLeft(2, '0'),
                                            style: MyStyle.s2
                                                .copyWith(color: MyColor.white),
                                          ),
                                        );
                                      }),
                                    ),
                                  ),
                                  Expanded(
                                    child: CupertinoPicker(
                                      itemExtent: MySize.doublePadding,
                                      onSelectedItemChanged: (int index) {
                                        _controller.selectedMinute.value =
                                            index.toString().padLeft(2, '0');
                                        _controller.updateSelectedTime(
                                            _controller.selectedHour.value,
                                            _controller.selectedMinute.value);
                                      },
                                      children: List<Widget>.generate(60,
                                          (int index) {
                                        return Center(
                                          child: Text(
                                            index.toString().padLeft(2, '0'),
                                            style: MyStyle.s2
                                                .copyWith(color: MyColor.white),
                                          ),
                                        );
                                      }),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Spacer(),
            _buildNavigationButtons(onValidate: _controller.validateTimePage),
          ],
        ),
      ),
    );
  }

  Widget _buildBirthPlacePage() {
    return Padding(
      padding: const EdgeInsets.all(MySize.defaultPadding),
      child: Column(
        children: [
          GooglePlaceAutoCompleteTextField(
            textEditingController: _controller.birthPlaceController,
            googleAPIKey: "AIzaSyDri3yUianYuZw3PfZlruuFLg196-UhXE8",
            textStyle: MyStyle.s2.copyWith(color: MyColor.white),
            focusNode: _birthPlaceFocusNode,
            inputDecoration: InputDecoration(
              labelText: 'Doğum yerini ara',
              labelStyle: MyStyle.s2.copyWith(color: MyColor.textGreyColor),
              filled: false,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(MySize.halfRadius),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.all(MySize.defaultPadding),
              prefixIcon: Icon(
                MingCute.search_2_line,
                color: MyColor.textGreyColor.withOpacity(0.5),
              ),
            ),
            debounceTime: 800,
            countries: const ["tr", "us", "gb"],
            isLatLngRequired: true,
            getPlaceDetailWithLatLng: (Prediction prediction) {
              _controller.birthPlaceController.text = prediction.description!;
              _controller.validatePlace(prediction.description!);
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _birthPlaceFocusNode.unfocus(); // Tahmin menüsünü kapat
              });
              if (_controller.validatePlacePage()) {
                _pageController.nextPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              }
            },
            itemClick: (Prediction prediction) {
              _controller.birthPlaceController.text = prediction.description!;
              _controller.validatePlace(prediction.description!);
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _birthPlaceFocusNode.unfocus(); // Tahmin menüsünü kapat
              });
              if (_controller.validatePlacePage()) {
                _pageController.nextPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              }
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
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        _birthPlaceFocusNode.unfocus(); // Tahmin menüsünü kapat
                      });
                      if (_controller.validatePlacePage()) {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      }
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
                                if (prediction
                                        .structuredFormatting?.secondaryText !=
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
          verticalGap(MySize.defaultPadding),
          Text(
            'Tarih burç, numeroloji ve uyumluluk hesaplamaları için önemlidir',
            textAlign: TextAlign.center,
            style: MyStyle.s3.copyWith(
              color: MyColor.textGreyColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGenderPage() {
    return FadeInRight(
      child: Padding(
        padding: const EdgeInsets.all(MySize.defaultPadding),
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            Text(
              'Tarih burç, numeroloji ve uyumluluk hesaplamaları için önemlidir',
              textAlign: TextAlign.center,
              style: MyStyle.s3.copyWith(
                color: MyColor.textGreyColor,
              ),
            ),
            Column(
              children: [
                const Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildGenderBox(
                      _controller.genders[0],
                      _controller.genderIndices.keys.elementAt(0),
                      _controller,
                    ),
                    _buildGenderBox(
                      _controller.genders[1],
                      _controller.genderIndices.keys.elementAt(1),
                      _controller,
                    ),
                    _buildGenderBox(
                      _controller.genders[2],
                      _controller.genderIndices.keys.elementAt(2),
                      _controller,
                    ),
                  ],
                ),
                const Spacer(),
                _buildNavigationButtons(
                    onValidate: _controller.validateGenderPage),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGenderBox(
      String gender, String genderIcon, ProfileController controller) {
    return Obx(() {
      final isSelected = controller.selectedGender.value == gender;
      IconData icon;
      if (genderIcon == 'male') {
        icon = MingCute.male_line;
      } else if (genderIcon == 'female') {
        icon = MingCute.female_line;
      } else {
        icon = MingCute.round_line;
      }
      return Column(
        children: [
          InkWell(
            overlayColor: WidgetStateProperty.all(MyColor.transparent),
            onTap: () => controller.validateGender(gender),
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(MySize.halfRadius),
                gradient: isSelected
                    ? LinearGradient(
                        colors: [
                          MyColor.primaryLightColor,
                          MyColor.secondaryColor,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                color: isSelected ? null : MyColor.white.withOpacity(0.1),
              ),
              padding: const EdgeInsets.all(MySize.defaultPadding),
              child: Icon(
                icon,
                color: MyColor.white,
                size: MySize.iconSizeMedium,
              ),
            ),
          ),
          verticalGap(MySize.defaultPadding),
          Text(
            gender,
            style: MyStyle.s2.copyWith(
              color: MyColor.white,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      );
    });
  }

  Widget _buildRelationshipStatusPage() {
    return FadeInRight(
      child: Padding(
        padding: const EdgeInsets.all(MySize.defaultPadding),
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            Text(
              'İlişki durumunu seç',
              textAlign: TextAlign.center,
              style: MyStyle.s3.copyWith(
                color: MyColor.textGreyColor,
              ),
            ),
            Column(
              children: [
                const Spacer(),
                Wrap(
                  spacing: MySize.defaultPadding,
                  runSpacing: MySize.defaultPadding,
                  alignment: WrapAlignment.center,
                  children: [
                    _buildRelationshipBox(
                      _controller.relationshipStatuses[0],
                      MingCute.user_2_line,
                      _controller,
                    ),
                    _buildRelationshipBox(
                      _controller.relationshipStatuses[1],
                      MingCute.hand_heart_line,
                      _controller,
                    ),
                    _buildRelationshipBox(
                      _controller.relationshipStatuses[2],
                      MingCute.heart_line,
                      _controller,
                    ),
                    _buildRelationshipBox(
                      _controller.relationshipStatuses[3],
                      MingCute.love_line,
                      _controller,
                    ),
                    _buildRelationshipBox(
                      _controller.relationshipStatuses[4],
                      MingCute.book_3_line,
                      _controller,
                    ),
                    _buildRelationshipBox(
                      _controller.relationshipStatuses[5],
                      MingCute.heart_crack_line,
                      _controller,
                    ),
                    _buildRelationshipBox(
                      _controller.relationshipStatuses[6],
                      MingCute.question_line,
                      _controller,
                    ),
                  ],
                ),
                const Spacer(),
                _buildNavigationButtons(
                  onValidate: _controller.validateRelationshipPage,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRelationshipBox(
    String status,
    IconData icon,
    ProfileController controller,
  ) {
    return Obx(() {
      final isSelected = controller.selectedRelationshipStatus.value == status;
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            overlayColor: WidgetStateProperty.all(MyColor.transparent),
            onTap: () {
              controller.selectedRelationshipStatus.value = status;
              controller.validateRelationshipStatus(status);
            },
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(MySize.halfRadius),
                gradient: isSelected
                    ? LinearGradient(
                        colors: [
                          MyColor.primaryLightColor,
                          MyColor.secondaryColor,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                color: isSelected ? null : MyColor.white.withOpacity(0.1),
              ),
              padding: const EdgeInsets.all(MySize.defaultPadding),
              child: Icon(
                icon,
                color: MyColor.white,
                size: MySize.iconSizeMedium,
              ),
            ),
          ),
          verticalGap(MySize.defaultPadding),
          Text(
            status,
            style: MyStyle.s2.copyWith(
              color: MyColor.white,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      );
    });
  }

  Widget _buildInterestsPage() {
    return FadeInRight(
      child: Padding(
        padding: const EdgeInsets.all(MySize.defaultPadding),
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            Text(
              'İlgi alanlarını seç',
              textAlign: TextAlign.center,
              style: MyStyle.s3.copyWith(
                color: MyColor.textGreyColor,
              ),
            ),
            Column(
              children: [
                const Spacer(),
                Wrap(
                  spacing: MySize.defaultPadding,
                  runSpacing: MySize.defaultPadding,
                  alignment: WrapAlignment.center,
                  children: [
                    _buildInterestBox(
                      _controller.interestStatuses[0],
                      MingCute.currency_dollar_2_line,
                      _controller,
                    ),
                    _buildInterestBox(
                      _controller.interestStatuses[1],
                      MingCute.briefcase_line,
                      _controller,
                    ),
                    _buildInterestBox(
                      _controller.interestStatuses[2],
                      MingCute.group_line,
                      _controller,
                    ),
                    _buildInterestBox(
                      _controller.interestStatuses[3],
                      MingCute.love_line,
                      _controller,
                    ),
                    _buildInterestBox(
                      _controller.interestStatuses[4],
                      MingCute.home_3_line,
                      _controller,
                    ),
                    _buildInterestBox(
                      _controller.interestStatuses[5],
                      MingCute.trending_up_line,
                      _controller,
                    ),
                  ],
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: () async {
                    if (_controller.selectedInterests.isNotEmpty) {
                      Get.to(
                        () => ProfileLoadingScreen(
                          onLoadComplete: () async {
                            try {
                              await _controller.saveUserProfile();
                            } catch (e) {
                              Get.snackbar(
                                'Hata',
                                'Profil kaydedilirken bir hata oluştu',
                                backgroundColor: MyColor.errorColor,
                                colorText: MyColor.white,
                              );
                              rethrow;
                            }
                          },
                        ),
                        fullscreenDialog: true,
                      );
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
          ],
        ),
      ),
    );
  }

  Widget _buildInterestBox(
    String interest,
    IconData icon,
    ProfileController controller,
  ) {
    return Obx(() {
      final isSelected = controller.selectedInterests.contains(interest);
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            overlayColor: WidgetStateProperty.all(MyColor.transparent),
            onTap: () => controller.toggleInterest(interest),
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(MySize.halfRadius),
                gradient: isSelected
                    ? LinearGradient(
                        colors: [
                          MyColor.primaryLightColor,
                          MyColor.secondaryColor,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                color: isSelected ? null : MyColor.white.withOpacity(0.1),
              ),
              padding: const EdgeInsets.all(MySize.defaultPadding),
              child: Icon(
                icon,
                color: MyColor.white,
                size: MySize.iconSizeMedium,
              ),
            ),
          ),
          verticalGap(MySize.defaultPadding),
          Text(
            interest,
            style: MyStyle.s2.copyWith(
              color: MyColor.white,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      );
    });
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
    _birthPlaceFocusNode.dispose();
    super.dispose();
  }
}
