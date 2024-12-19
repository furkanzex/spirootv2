import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:spirootv2/profile/user_controller.dart';
import 'package:spirootv2/core/constant/my_color.dart';
import 'package:spirootv2/core/constant/my_icon.dart';
import 'package:spirootv2/core/constant/my_size.dart';
import 'package:spirootv2/core/constant/my_style.dart';
import 'package:spirootv2/core/widget/gap/vertical_gap.dart';
import 'package:easy_localization/easy_localization.dart' as easy;

class ProfilePage extends StatelessWidget {
  ProfilePage({super.key});

  final UserController _userController = Get.find<UserController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColor.primaryDarkColor,
      appBar: AppBar(
        surfaceTintColor: MyColor.transparent,
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          easy.tr("profile.profile_title"),
          style: MyStyle.s1.copyWith(
            color: MyColor.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        automaticallyImplyLeading: false,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(MyIcon.back, color: MyColor.white),
        ),
      ),
      body: Obx(() {
        if (_userController.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(MySize.defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Kullanıcı ID'si
              _buildReadOnlyField(
                  easy.tr("profile.user_id"), _userController.userId.value),
              verticalGap(MySize.defaultPadding),

              // İsim
              _buildReadOnlyField(
                  easy.tr("profile.name"), _userController.nameController.text),
              verticalGap(MySize.defaultPadding),

              // Doğum Tarihi
              _buildReadOnlyField(
                easy.tr("profile.birth_date"),
                DateFormat('MMMM d, yyyy')
                    .format(_userController.selectedBirthDateTime.value),
              ),
              verticalGap(MySize.defaultPadding),

              // Doğum Saati
              _buildReadOnlyField(
                easy.tr("profile.birth_time"),
                '${_userController.selectedHour.value}:${_userController.selectedMinute.value}',
              ),
              verticalGap(MySize.defaultPadding),

              // Doğum Yeri
              _buildReadOnlyField(easy.tr("profile.birth_place"),
                  _userController.birthPlaceController.text),
              verticalGap(MySize.defaultPadding),

              // Cinsiyet
              _buildReadOnlyField(easy.tr("profile.gender_title"),
                  easy.tr(_userController.selectedGender.value)),
              verticalGap(MySize.defaultPadding),

              // İlişki Durumu
              _buildReadOnlyField(easy.tr("profile.relationship_title"),
                  easy.tr(_userController.selectedRelationshipStatus.value)),
              verticalGap(MySize.defaultPadding),

              // İlgi Alanları
              Text(
                easy.tr("profile.interests_title"),
                style: MyStyle.s2.copyWith(color: MyColor.textGreyColor),
              ),
              verticalGap(MySize.halfPadding),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _userController.selectedInterests.map((interest) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: MySize.defaultPadding,
                      vertical: MySize.halfPadding,
                    ),
                    decoration: BoxDecoration(
                      color: MyColor.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(MySize.halfRadius),
                    ),
                    child: Text(
                      easy.tr(interest),
                      style: MyStyle.s3.copyWith(color: MyColor.white),
                    ),
                  );
                }).toList(),
              ),
              verticalGap(MySize.doublePadding),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildReadOnlyField(String label, String value) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(MySize.defaultPadding),
      decoration: BoxDecoration(
        color: MyColor.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(MySize.halfRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: MyStyle.s3.copyWith(color: MyColor.textGreyColor),
          ),
          verticalGap(MySize.quarterPadding),
          Text(
            value,
            style: MyStyle.s2.copyWith(color: MyColor.white),
          ),
        ],
      ),
    );
  }
}
