import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:easy_localization/easy_localization.dart' as easy;
import 'package:intl/intl.dart';
import 'package:scaffold_gradient_background/scaffold_gradient_background.dart';
import 'package:spirootv2/core/constant/my_color.dart';
import 'package:spirootv2/core/constant/my_size.dart';
import 'package:spirootv2/core/constant/my_style.dart';
import 'package:spirootv2/core/helper/device_helper.dart';
import 'package:spirootv2/core/service/gemini_service.dart';
import 'package:spirootv2/profile/user_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CoffeeFortuneResultScreen extends StatefulWidget {
  final List<File> images;

  const CoffeeFortuneResultScreen({
    Key? key,
    required this.images,
  }) : super(key: key);

  @override
  State<CoffeeFortuneResultScreen> createState() =>
      _CoffeeFortuneResultScreenState();
}

class _CoffeeFortuneResultScreenState extends State<CoffeeFortuneResultScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _birthDateController = TextEditingController();
  final TextEditingController _relationshipController = TextEditingController();
  final TextEditingController _topic1Controller = TextEditingController();
  final TextEditingController _topic2Controller = TextEditingController();
  bool _isForSelf = true;
  bool _hasProfile = false;
  bool _isInterpreting = false;

  @override
  void initState() {
    super.initState();
    _topic1Controller.text = easy.tr('profile.interests.money');
    _topic2Controller.text = easy.tr('profile.interests.career');
    _checkProfile();
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
          easy.tr(userController.selectedRelationshipStatus.value);
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
        easy.tr(translationKey),
        style: MyStyle.s2.copyWith(color: MyColor.white),
      ),
      onTap: () {
        setState(() {
          controller.text = easy.tr(translationKey);
        });
        Navigator.pop(context);
      },
    );
  }

  Widget _buildTopicItem(String title, TextEditingController controller) {
    return GestureDetector(
      onTap: () => _showTopicPicker(controller),
      child: Container(
        padding: EdgeInsets.all(MySize.defaultPadding),
        decoration: BoxDecoration(
          color: MyColor.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(MySize.halfRadius),
        ),
        child: Row(
          children: [
            Text(
              title,
              style: MyStyle.s2.copyWith(color: MyColor.textGreyColor),
            ),
            SizedBox(width: MySize.defaultPadding),
            Expanded(
              child: Text(
                controller.text,
                style: MyStyle.s1.copyWith(
                  color: MyColor.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: MyColor.white, size: 16),
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
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(MySize.halfRadius)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(MySize.defaultPadding),
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
          padding: EdgeInsets.all(MySize.defaultPadding),
          decoration: BoxDecoration(
            color: isSelected
                ? MyColor.primaryColor
                : MyColor.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(MySize.halfRadius),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                icon,
                style: TextStyle(fontSize: 20),
              ),
              SizedBox(width: 8),
              Text(
                title,
                style: MyStyle.s2.copyWith(
                  color: MyColor.white,
                  fontWeight: FontWeight.bold,
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
    bool readOnly = false,
    bool isEnabled = true,
    VoidCallback? onTap,
  }) {
    return TextFormField(
      controller: controller,
      readOnly: readOnly,
      enabled: isEnabled,
      onTap: onTap,
      style: MyStyle.s2.copyWith(color: MyColor.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: MyStyle.s2.copyWith(color: MyColor.textGreyColor),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(MySize.halfRadius),
          borderSide: BorderSide(color: MyColor.white.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(MySize.halfRadius),
          borderSide: const BorderSide(color: MyColor.primaryLightColor),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(MySize.halfRadius),
          borderSide: BorderSide(color: MyColor.white.withOpacity(0.1)),
        ),
      ),
    );
  }

  Future<void> _sendFortune() async {
    // Form validasyonu
    if (_nameController.text.isEmpty ||
        _birthDateController.text.isEmpty ||
        _relationshipController.text.isEmpty ||
        _topic1Controller.text.isEmpty ||
        _topic2Controller.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(easy.tr('Lütfen tüm alanları doldurun')),
          backgroundColor: Colors.red.withOpacity(0.8),
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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

      // Kahve falı yorumu için prompt oluştur
      Map<String, dynamic> interpretation =
          await geminiService.interpretCoffeeFortune(
        widget.images,
        {
          'name': _nameController.text,
          'birthDate': _birthDateController.text,
          'relationship': _relationshipController.text,
          'topics': [_topic1Controller.text, _topic2Controller.text],
        },
      );

      // Firestore'a kaydet
      await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser?.uid)
          .collection('fortunes')
          .add({
        'type': 'coffee',
        'images': widget.images.map((image) => image.path).toList(),
        'interpretation': interpretation,
        'timestamp': FieldValue.serverTimestamp(),
        'revealAt': Timestamp.fromDate(DateTime.now().add(waitTime)),
        'userInfo': {
          'name': _nameController.text,
          'birthDate': _birthDateController.text,
          'relationship': _relationshipController.text,
          'topics': [_topic1Controller.text, _topic2Controller.text],
          'isForSelf': _isForSelf,
        },
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              easy.tr('Falınız ortalama {0} dakika içinde hazır olacak',
                  args: [waitTime.inMinutes.toString()]),
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
            content:
                Text(easy.tr('Bir hata oluştu: {0}', args: [e.toString()])),
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

  @override
  Widget build(BuildContext context) {
    return ScaffoldGradientBackground(
      gradient: LinearGradient(
        begin: Alignment.bottomLeft,
        end: Alignment.topRight,
        colors: [
          MyColor.darkBackgroundColor,
          MyColor.primaryColor,
        ],
      ),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Kahve Falı',
          style: MyStyle.s1.copyWith(
            color: MyColor.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: MyColor.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(MySize.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_hasProfile)
              Row(
                children: [
                  _buildSelectionButton(
                    title: 'Kendim İçin',
                    icon: '👍',
                    isSelected: _isForSelf,
                    onTap: () {
                      setState(() {
                        _isForSelf = true;
                        _loadUserData();
                      });
                    },
                  ),
                  SizedBox(width: MySize.defaultPadding),
                  _buildSelectionButton(
                    title: 'Başkası İçin',
                    icon: '👉',
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
            SizedBox(height: MySize.defaultPadding),
            Text(
              'Kimin İçin?',
              style: MyStyle.s1.copyWith(
                color: MyColor.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: MySize.defaultPadding),
            _buildTextField(
              controller: _nameController,
              label: 'İsim',
              isEnabled: !_isForSelf || !_hasProfile,
            ),
            SizedBox(height: MySize.defaultPadding),
            _buildTextField(
              controller: _birthDateController,
              label: 'Doğum Tarihi',
              isEnabled: !_isForSelf || !_hasProfile,
              onTap: () => _showDatePicker(),
              readOnly: true,
            ),
            SizedBox(height: MySize.defaultPadding),
            _buildTextField(
              controller: _relationshipController,
              label: 'İlişki Durumu',
              isEnabled: !_isForSelf || !_hasProfile,
              onTap: () => _showRelationshipPicker(),
              readOnly: true,
            ),
            SizedBox(height: MySize.doublePadding),
            Text(
              'Merak Ettiğin Konular',
              style: MyStyle.s1.copyWith(
                color: MyColor.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: MySize.defaultPadding),
            _buildTopicItem('1. Konu', _topic1Controller),
            SizedBox(height: MySize.defaultPadding),
            _buildTopicItem('2. Konu', _topic2Controller),
            SizedBox(height: MySize.doublePadding),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: MyColor.primaryLightColor,
                  padding:
                      EdgeInsets.symmetric(vertical: MySize.defaultPadding),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(MySize.halfRadius),
                  ),
                ),
                onPressed: _isInterpreting ? null : _sendFortune,
                child: _isInterpreting
                    ? SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: MyColor.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        'Gönder',
                        style: MyStyle.s1.copyWith(
                          color: MyColor.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
