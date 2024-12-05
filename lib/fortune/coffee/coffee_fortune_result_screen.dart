import 'dart:io';
import 'package:flutter/material.dart';
import 'package:scaffold_gradient_background/scaffold_gradient_background.dart';
import 'package:spirootv2/core/constant/my_color.dart';
import 'package:spirootv2/core/constant/my_size.dart';
import 'package:spirootv2/core/constant/my_style.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';
import 'package:spirootv2/profile/user_controller.dart';

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
  bool _isForSelf = true;
  List<bool> selectedTopics = [
    false,
    false
  ]; // Para ve Kariyer için seçim durumları

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    final userController = Get.find<UserController>();
    if (_isForSelf) {
      _nameController.text = userController.nameController.text;
      _birthDateController.text = DateFormat('d MMM yyyy', 'tr_TR')
          .format(userController.selectedBirthDateTime.value);
      _relationshipController.text =
          userController.selectedRelationshipStatus.value;
    }
  }

  Widget _buildTopicItem(String title, String emoji, int index) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedTopics[index] = !selectedTopics[index];
        });
      },
      child: Container(
        padding: EdgeInsets.all(MySize.defaultPadding),
        decoration: BoxDecoration(
          color: selectedTopics[index]
              ? MyColor.primaryColor
              : MyColor.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(MySize.halfRadius),
        ),
        child: Row(
          children: [
            Text(
              '${index + 1}. ',
              style: MyStyle.s1.copyWith(
                color: MyColor.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              emoji,
              style: TextStyle(fontSize: 24),
            ),
            SizedBox(width: MySize.defaultPadding),
            Text(
              title,
              style: MyStyle.s1.copyWith(
                color: MyColor.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            Spacer(),
            Icon(
              selectedTopics[index]
                  ? Icons.check_circle
                  : Icons.circle_outlined,
              color: MyColor.white,
              size: 24,
            ),
          ],
        ),
      ),
    );
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
            Text(
              'Merak ettiğin konular?',
              style: MyStyle.s1.copyWith(
                color: MyColor.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: MySize.defaultPadding),
            Container(
              padding: EdgeInsets.all(MySize.defaultPadding),
              decoration: BoxDecoration(
                color: MyColor.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(MySize.halfRadius),
              ),
              child: Column(
                children: [
                  _buildTopicItem('Para', '💰', 0),
                  SizedBox(height: MySize.halfPadding),
                  _buildTopicItem('Kariyer', '💼', 1),
                ],
              ),
            ),
            SizedBox(height: MySize.defaultPadding),
            Text(
              'Fotoğraflar',
              style: MyStyle.s1.copyWith(
                color: MyColor.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: MySize.defaultPadding),
            GridView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: MySize.halfPadding,
                mainAxisSpacing: MySize.halfPadding,
              ),
              itemCount: widget.images.length,
              itemBuilder: (context, index) {
                return ClipRRect(
                  borderRadius: BorderRadius.circular(MySize.halfRadius),
                  child: Image.file(
                    widget.images[index],
                    fit: BoxFit.cover,
                  ),
                );
              },
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
            _buildTextField(
              controller: _nameController,
              label: 'İsim',
              icon: Icons.person,
            ),
            SizedBox(height: MySize.defaultPadding),
            _buildTextField(
              controller: _birthDateController,
              label: 'Doğum Günü',
              icon: Icons.calendar_today,
              readOnly: true,
              onTap: () async {
                if (!_isForSelf) {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(1900),
                    lastDate: DateTime.now(),
                  );
                  if (date != null) {
                    _birthDateController.text =
                        DateFormat('d MMM yyyy', 'tr_TR').format(date);
                  }
                }
              },
            ),
            SizedBox(height: MySize.defaultPadding),
            _buildTextField(
              controller: _relationshipController,
              label: 'İlişki Durumu',
              icon: Icons.favorite,
              readOnly: true,
              onTap: () {
                if (!_isForSelf) {
                  _showRelationshipPicker();
                }
              },
            ),
            SizedBox(height: MySize.defaultPadding * 2),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: MyColor.primaryColor,
                  padding:
                      EdgeInsets.symmetric(vertical: MySize.defaultPadding),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(MySize.halfRadius),
                  ),
                ),
                onPressed: () {
                  if (!selectedTopics.contains(true)) {
                    Get.snackbar(
                      'Hata',
                      'Lütfen en az bir konu seçin',
                      backgroundColor: MyColor.errorColor,
                      colorText: MyColor.white,
                    );
                    return;
                  }
                  // TODO: Fal gönderme işlemi
                },
                child: Text(
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
    required IconData icon,
    bool readOnly = false,
    VoidCallback? onTap,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: MySize.defaultPadding),
      decoration: BoxDecoration(
        color: MyColor.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(MySize.halfRadius),
      ),
      child: TextField(
        controller: controller,
        readOnly: readOnly,
        onTap: onTap,
        style: MyStyle.s1.copyWith(color: MyColor.white),
        decoration: InputDecoration(
          border: InputBorder.none,
          icon: Icon(icon, color: MyColor.white),
          labelText: label,
          labelStyle:
              MyStyle.s2.copyWith(color: MyColor.white.withOpacity(0.7)),
        ),
      ),
    );
  }
}
