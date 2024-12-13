import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:scaffold_gradient_background/scaffold_gradient_background.dart';
import 'package:spirootv2/core/constant/my_color.dart';
import 'package:spirootv2/core/constant/my_icon.dart';
import 'package:spirootv2/core/constant/my_size.dart';
import 'package:spirootv2/core/constant/my_style.dart';
import 'package:spirootv2/core/helper/device_helper.dart';
import 'package:spirootv2/core/service/gemini_service.dart';
import 'package:spirootv2/core/widget/gap/vertical_gap.dart';
import 'package:spirootv2/fortune/interpretation/fortune_camera_screen.dart';
import 'package:spirootv2/home/home_controller.dart';
import 'package:spirootv2/profile/user_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FortuneResultScreen extends StatefulWidget {
  final List<File> images;
  final FortuneType fortuneType;

  const FortuneResultScreen({
    super.key,
    required this.images,
    required this.fortuneType,
  });

  @override
  State<FortuneResultScreen> createState() => _FortuneResultScreenState();
}

class _FortuneResultScreenState extends State<FortuneResultScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _birthDateController = TextEditingController();
  final TextEditingController _relationshipController = TextEditingController();
  final TextEditingController _topic1Controller = TextEditingController();
  final TextEditingController _topic2Controller = TextEditingController();
  bool _isForSelf = false;
  bool _hasProfile = false;
  bool _isInterpreting = false;

  @override
  void initState() {
    super.initState();
    _topic1Controller.text = tr('profile.interests.money');
    _topic2Controller.text = tr('profile.interests.career');
    _checkProfile();
    _isForSelf = _hasProfile ? true : false;
  }

  void _checkProfile() {
    final userController = Get.find<UserController>();
    setState(() {
      _hasProfile = userController.nameController.text.isNotEmpty;
      if (_hasProfile) {
        _loadUserData();
      }
    });
  }

  void _loadUserData() {
    final userController = Get.find<UserController>();
    if (_isForSelf && _hasProfile) {
      _nameController.text = userController.nameController.text;
      _birthDateController.text = DateFormat('d MMM yyyy', 'tr_TR')
          .format(userController.selectedBirthDateTime.value);
      _relationshipController.text =
          tr(userController.selectedRelationshipStatus.value);
    }
  }

  void _showTopicPicker(TextEditingController controller) {
    showModalBottomSheet(
      context: context,
      backgroundColor: MyColor.darkBackgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(MySize.halfRadius)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(MySize.defaultPadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Konu Seç',
              style: MyStyle.s1.copyWith(
                color: MyColor.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: MySize.defaultPadding),
            Expanded(
              child: ListView(
                children: [
                  _buildTopicTile(controller, 'profile.interests.money'),
                  _buildTopicTile(controller, 'profile.interests.business'),
                  _buildTopicTile(controller, 'profile.interests.friendship'),
                  _buildTopicTile(controller, 'profile.interests.love'),
                  _buildTopicTile(controller, 'profile.interests.family'),
                  _buildTopicTile(controller, 'profile.interests.career'),
                  _buildTopicTile(controller, 'profile.interests.education'),
                  _buildTopicTile(controller, 'profile.interests.travel'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopicTile(
      TextEditingController controller, String translationKey) {
    return ListTile(
      title: Text(
        tr(translationKey),
        style: MyStyle.s2.copyWith(color: MyColor.white),
      ),
      onTap: () {
        setState(() {
          controller.text = tr(translationKey);
        });
        Navigator.pop(context);
      },
    );
  }

  Widget _buildTopicItem(String title, TextEditingController controller) {
    return GestureDetector(
      onTap: () => _showTopicPicker(controller),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: MySize.defaultPadding,
          vertical: MySize.threeQuartersPadding,
        ),
        decoration: BoxDecoration(
          color: MyColor.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(MySize.quarterRadius),
        ),
        child: Row(
          children: [
            Text(
              title,
              style: MyStyle.s2.copyWith(
                color: MyColor.textGreyColor,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(width: MySize.threeQuartersPadding),
            Expanded(
              child: Text(
                controller.text,
                style: MyStyle.s2.copyWith(
                  color: MyColor.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Icon(MyIcon.forward,
                color: MyColor.textGreyColor, size: MySize.iconSizeTiny),
          ],
        ),
      ),
    );
  }

  void _showDatePicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: MyColor.darkBackgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(MySize.halfRadius)),
      ),
      builder: (context) => Container(
        height: 300,
        padding: EdgeInsets.all(MySize.defaultPadding),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(MySize.halfRadius),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'İptal',
                    style: MyStyle.s2
                        .copyWith(color: MyColor.white.withOpacity(0.3)),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Tamam',
                    style:
                        MyStyle.s2.copyWith(color: MyColor.primaryLightColor),
                  ),
                ),
              ],
            ),
            Expanded(
              child: CupertinoTheme(
                data: CupertinoThemeData(
                  textTheme: CupertinoTextThemeData(
                    dateTimePickerTextStyle: TextStyle(
                      color: MyColor.white,
                      fontSize: 20,
                    ),
                  ),
                ),
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.date,
                  initialDateTime: DateTime.now(),
                  maximumDate: DateTime.now(),
                  minimumDate: DateTime(1900),
                  onDateTimeChanged: (DateTime value) {
                    if (!_isForSelf) {
                      setState(() {
                        _birthDateController.text =
                            DateFormat('d MMM yyyy', 'tr_TR').format(value);
                      });
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showRelationshipPicker() {
    final userController = Get.find<UserController>();
    showModalBottomSheet(
      context: context,
      backgroundColor: MyColor.darkBackgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(MySize.defaultPadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'İlişki Durumu Seç',
              style: MyStyle.s1.copyWith(
                color: MyColor.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: MySize.defaultPadding),
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: userController.relationshipStatuses.map((status) {
                    return ListTile(
                      title: Text(
                        status,
                        style: MyStyle.s2.copyWith(color: MyColor.white),
                      ),
                      onTap: () {
                        setState(() {
                          _relationshipController.text = status;
                        });
                        Navigator.pop(context);
                      },
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectionButton({
    required String title,
    required String icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: MySize.threeQuartersPadding),
          decoration: BoxDecoration(
            color: isSelected
                ? MyColor.primaryPurpleColor
                : MyColor.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(MySize.quarterRadius),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(icon, style: TextStyle(fontSize: MySize.defaultPadding)),
              SizedBox(width: MySize.halfPadding),
              Text(
                title,
                style: MyStyle.s2.copyWith(
                  color: MyColor.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool readOnly = false,
    VoidCallback? onTap,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: MySize.defaultPadding,
        vertical: MySize.threeQuartersPadding,
      ),
      decoration: BoxDecoration(
        color: MyColor.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(MySize.quarterRadius),
      ),
      child: Row(
        children: [
          Icon(icon, color: MyColor.textGreyColor, size: MySize.iconSizeTiny),
          SizedBox(width: MySize.defaultPadding),
          Expanded(
            child: TextField(
              controller: controller,
              readOnly: readOnly,
              onTap: readOnly ? onTap : null,
              style: MyStyle.s2.copyWith(
                color: MyColor.white,
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: label,
                hintStyle: MyStyle.s2.copyWith(
                  color: MyColor.textGreyColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          if (readOnly && onTap != null)
            Icon(MyIcon.forward,
                color: MyColor.textGreyColor, size: MySize.iconSizeTiny),
        ],
      ),
    );
  }

  Future<void> _sendFortune() async {
    // Form validasyonu
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lütfen isim alanını doldurun'),
          backgroundColor: Colors.red.withOpacity(0.8),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return;
    }

    if (_birthDateController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lütfen doğum günü seçin'),
          backgroundColor: Colors.red.withOpacity(0.8),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return;
    }

    if (_relationshipController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lütfen ilişki durumunu seçin'),
          backgroundColor: Colors.red.withOpacity(0.8),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return;
    }

    setState(() {
      _isInterpreting = true;
    });

    try {
      final geminiService = GeminiService();
      final random = Random();
      final waitTime = Duration(minutes: random.nextInt(14) + 1);

      Map<String, dynamic> interpretation;

      switch (widget.fortuneType) {
        case FortuneType.coffee:
          interpretation = await geminiService.interpretCoffeeFortune(
            widget.images,
            {
              'name': _nameController.text,
              'birthDate': _birthDateController.text,
              'relationship': _relationshipController.text,
              'topics': [_topic1Controller.text, _topic2Controller.text],
            },
          );
          break;
        case FortuneType.palm:
          interpretation = await geminiService.interpretPalmFortune(
            widget.images.first,
            {
              'name': _nameController.text,
              'birthDate': _birthDateController.text,
              'relationship': _relationshipController.text,
              'topics': [_topic1Controller.text, _topic2Controller.text],
            },
          );
          break;
        case FortuneType.face:
          interpretation = await geminiService.interpretFaceFortune(
            widget.images.first,
            {
              'name': _nameController.text,
              'birthDate': _birthDateController.text,
              'relationship': _relationshipController.text,
              'topics': [_topic1Controller.text, _topic2Controller.text],
            },
          );
          break;
      }

      // Firestore'a kaydet
      await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser?.uid)
          .collection('fortunes')
          .add({
        'type': fortuneTypeText,
        'images': widget.images.map((image) => image.path).toList(),
        'interpretation': interpretation,
        'timestamp': FieldValue.serverTimestamp(),
        'revealAt': Timestamp.fromDate(DateTime.now().add(waitTime)),
        'userInfo': {
          'name': _nameController.text,
          'birthDate': _birthDateController.text,
          'relationship': _relationshipController.text,
          'topics': [_topic1Controller.text, _topic2Controller.text],
        },
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Falınız ortalama ${waitTime.inMinutes} dakika içinde hazır olacak',
            ),
            backgroundColor: MyColor.primaryLightColor.withOpacity(0.8),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Bir hata oluştu: $e'),
            backgroundColor: Colors.red.withOpacity(0.8),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isInterpreting = false;
        });
      }
    }
  }

  String get screenTitle {
    switch (widget.fortuneType) {
      case FortuneType.coffee:
        return 'Kahve Falı';
      case FortuneType.palm:
        return 'El Falı';
      case FortuneType.face:
        return 'Yüz Falı';
    }
  }

  String get fortuneTypeText {
    switch (widget.fortuneType) {
      case FortuneType.coffee:
        return 'coffee';
      case FortuneType.palm:
        return 'palm';
      case FortuneType.face:
        return 'face';
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => DeviceHelper.hideKeyboard(),
      child: ScaffoldGradientBackground(
        gradient: LinearGradient(
          begin: Alignment.bottomLeft,
          end: Alignment.topRight,
          colors: [
            MyColor.darkBackgroundColor,
            MyColor.primaryColor,
          ],
        ),
        appBar: AppBar(
          backgroundColor: MyColor.transparent,
          surfaceTintColor: MyColor.transparent,
          elevation: 0,
          centerTitle: true,
          title: Text(
            screenTitle,
            style: MyStyle.b4.copyWith(color: MyColor.white),
          ),
          leading: IconButton(
            icon: Icon(MyIcon.back,
                color: MyColor.white, size: MySize.iconSizeSmall),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(MySize.defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Fotoğraflar Bölümü
              SizedBox(
                height: MySize.cardHeight,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: widget.images.length,
                  itemBuilder: (context, index) {
                    return Container(
                      width: MySize.cardWidth * 0.6,
                      margin: EdgeInsets.only(
                        right: index != widget.images.length - 1
                            ? MySize.threeQuartersPadding
                            : 0,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(MySize.halfRadius),
                        color: MyColor.white.withOpacity(0.05),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(MySize.halfRadius),
                        child: Image.file(
                          widget.images[index],
                          fit: BoxFit.cover,
                        ),
                      ),
                    );
                  },
                ),
              ),
              verticalGap(MySize.doublePadding),

              // Merak Edilen Konular
              Text(
                'Merak ettiğin konular',
                style: MyStyle.s1.copyWith(
                  color: MyColor.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              verticalGap(MySize.defaultPadding),
              _buildTopicItem('1. Konu', _topic1Controller),
              verticalGap(MySize.halfPadding),
              _buildTopicItem('2. Konu', _topic2Controller),
              verticalGap(MySize.doublePadding),

              // Kimin İçin Bölümü
              Text(
                'Kimin İçin?',
                style: MyStyle.s1.copyWith(
                  color: MyColor.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              verticalGap(MySize.defaultPadding),
              Row(
                children: [
                  _buildSelectionButton(
                    title: 'Kendim İçin',
                    icon: '👤',
                    isSelected: _isForSelf,
                    onTap: () {
                      if (!_hasProfile) {
                        Get.snackbar(
                          'Profil Tamamlanmamış',
                          'Kendiniz için fal baktırmak için önce profilinizi tamamlamalısınız.',
                          backgroundColor:
                              MyColor.primaryPurpleColor.withOpacity(0.8),
                          colorText: MyColor.white,
                          duration: Duration(seconds: 3),
                          snackPosition: SnackPosition.BOTTOM,
                        );
                        Navigator.pop(context);
                        final controller = Get.find<HomeController>();
                        controller.changePage(2);
                      } else {
                        setState(() {
                          _isForSelf = true;
                          _loadUserData();
                        });
                      }
                    },
                  ),
                  SizedBox(width: MySize.halfPadding),
                  _buildSelectionButton(
                    title: 'Başkası İçin',
                    icon: '👥',
                    isSelected: !_isForSelf,
                    onTap: () {
                      setState(() {
                        _isForSelf = false;
                        _nameController.clear();
                        _birthDateController.clear();
                        _relationshipController.clear();
                      });
                    },
                  ),
                ],
              ),
              verticalGap(MySize.doublePadding),

              _buildTextField(
                readOnly: _isForSelf,
                controller: _nameController,
                label: 'İsim',
                icon: CupertinoIcons.person,
              ),
              verticalGap(MySize.halfPadding),
              _buildTextField(
                controller: _birthDateController,
                label: 'Doğum Günü',
                icon: CupertinoIcons.calendar,
                readOnly: true,
                onTap: _showDatePicker,
              ),
              verticalGap(MySize.halfPadding),
              _buildTextField(
                controller: _relationshipController,
                label: 'İlişki Durumu',
                icon: CupertinoIcons.heart,
                readOnly: true,
                onTap: _showRelationshipPicker,
              ),
              verticalGap(MySize.doublePadding),

              // Gönder Butonu
              SizedBox(
                width: double.infinity,
                height: MySize.iconSizeMedium + MySize.quarterPadding,
                child: ElevatedButton(
                  onPressed: _isInterpreting ? null : _sendFortune,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: MyColor.primaryPurpleColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(MySize.quarterRadius),
                    ),
                  ),
                  child: _isInterpreting
                      ? CircularProgressIndicator(
                          color: MyColor.white,
                          strokeWidth: 2,
                        )
                      : Text(
                          'Yorumla',
                          style: MyStyle.s1.copyWith(
                            color: MyColor.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
              verticalGap(MySize.defaultPadding),
            ],
          ),
        ),
      ),
    );
  }
}
