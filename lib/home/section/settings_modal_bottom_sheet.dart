import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:spirootv2/auth/auth_controller.dart';
import 'package:spirootv2/paywall/paywall_screen.dart';
import 'package:spirootv2/profile/user_controller.dart';
import 'package:spirootv2/core/constant/my_color.dart';
import 'package:spirootv2/core/constant/my_icon.dart';
import 'package:spirootv2/core/constant/my_size.dart';
import 'package:spirootv2/core/constant/my_style.dart';
import 'package:easy_localization/easy_localization.dart' as easy;
import 'package:icons_plus/icons_plus.dart';
import 'package:spirootv2/profile/profile_onboarding.dart';
import 'package:spirootv2/core/widget/divider/divider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:spirootv2/profile/profile_page.dart';
import 'package:spirootv2/astrology/astrology_controller.dart';

// Otomatik çeviri kontrolü için RxBool değişkeni
final RxBool isAutoTranslateEnabled = false.obs;
final storage = GetStorage();

// Çeviri durumunu kontrol eden fonksiyon
void toggleAutoTranslate(bool value) {
  isAutoTranslateEnabled.value = value;
  storage.write('auto_translate', value);
}

// Uygulama başladığında çeviri durumunu yükle
void loadAutoTranslateState() {
  isAutoTranslateEnabled.value = storage.read('auto_translate') ?? false;
}

// Dil değiştirme fonksiyonu
void _changeLanguage(BuildContext context, Locale newLocale) async {
  try {
    // Önce EasyLocalization'ı güncelle
    await easy.EasyLocalization.of(context)?.setLocale(newLocale);

    // GetX'in locale'ini güncelle
    Get.updateLocale(newLocale);

    // Modalları kapat
    if (context.mounted) {
      Navigator.pop(context); // Dil seçim modalını kapat
      Navigator.pop(context); // Settings modalını kapat
    }
  } catch (e) {
    Get.snackbar(
      easy.tr("errors.error"),
      easy.tr("settings.app.language.change_error"),
      backgroundColor: MyColor.errorColor,
      colorText: MyColor.white,
      duration: const Duration(seconds: 2),
    );
  }
}

// Dil seçim modalı
void _showLanguageSelectionModal(BuildContext context) {
  final Map<String, Map<String, dynamic>> languages = {
    'English': {
      'locale': const Locale('en', 'US'),
      'flag': '🇺🇸',
    },
    'Türkçe': {
      'locale': const Locale('tr', 'TR'),
      'flag': '🇹🇷',
    },
  };

  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (context) => Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: MyColor.darkBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 45,
            height: 5,
            decoration: BoxDecoration(
              color: MyColor.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              easy.tr("settings.app.language.title"),
              style: MyStyle.s1.copyWith(
                color: MyColor.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: languages.entries.map((entry) {
                  final bool isSelected = context.locale.languageCode ==
                      entry.value['locale'].languageCode;
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 8,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    tileColor: isSelected
                        ? MyColor.primaryColor.withOpacity(0.1)
                        : Colors.transparent,
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? MyColor.primaryColor.withOpacity(0.1)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        entry.value['flag'],
                        style: const TextStyle(fontSize: 24),
                      ),
                    ),
                    title: Text(
                      entry.key,
                      style: MyStyle.s2.copyWith(
                        color: MyColor.white,
                      ),
                    ),
                    trailing: isSelected
                        ? Icon(
                            Icons.check,
                            color: MyColor.primaryColor,
                          )
                        : null,
                    onTap: () =>
                        _changeLanguage(context, entry.value['locale']),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    ),
  );
}

void showSettingsBottomSheet(BuildContext context) {
  final userController = Get.find<UserController>();
  final astrologyController = Get.find<AstrologyController>();

  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (context) => Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: MyColor.darkBackgroundColor,
        borderRadius: const BorderRadius.vertical(
            top: Radius.circular(MySize.halfRadius)),
      ),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: MySize.defaultPadding),
            width: MySize.tenQuartersPadding,
            height: MySize.quarterPadding,
            decoration: BoxDecoration(
              color: MyColor.white.withOpacity(0.3),
              borderRadius: BorderRadius.circular(MySize.halfRadius),
            ),
          ),

          // Profile Section
          GestureDetector(
            onTap: () {
              Navigator.pop(context);
              Get.to(
                  () => userController.isProfileComplete
                      ? ProfilePage()
                      : const ProfileOnboarding(),
                  transition: Transition.rightToLeft,
                  duration: const Duration(milliseconds: 300));
            },
            child: Padding(
              padding: const EdgeInsets.all(MySize.defaultPadding),
              child: Obx(() => Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: MyColor.primaryColor,
                        backgroundImage: userController.isProfileComplete &&
                                userController.currentUser.value?.zodiacSign
                                        .isNotEmpty ==
                                    true
                            ? ExtendedNetworkImageProvider(
                                "https://apptoic.com/spiroot/images/${userController.currentUser.value?.zodiacSign}.png",
                                cache: true,
                              )
                            : null,
                        child: userController.isProfileComplete &&
                                userController.currentUser.value?.zodiacSign
                                        .isNotEmpty ==
                                    true
                            ? null
                            : Icon(MingCute.user_4_fill,
                                color: MyColor.white, size: 30),
                      ),
                      const SizedBox(width: MySize.defaultPadding),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              userController.isProfileComplete
                                  ? userController.userName
                                  : easy.tr("settings.account.guest_user"),
                              style: MyStyle.s1.copyWith(
                                color: MyColor.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Obx(() => Text(
                                  astrologyController.isSubscribed.value
                                      ? "Premium"
                                      : easy
                                          .tr("settings.account.free_account"),
                                  style: MyStyle.s3.copyWith(
                                    color:
                                        astrologyController.isSubscribed.value
                                            ? MyColor.primaryLightColor
                                            : MyColor.textGreyColor,
                                  ),
                                )),
                          ],
                        ),
                      ),
                      Icon(
                        MingCute.right_line,
                        color: MyColor.white,
                        size: MySize.iconSizeSmall,
                      ),
                    ],
                  )),
            ),
          ),

          divider(),

          // Settings
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(MySize.defaultPadding),
              children: [
                _buildSettingsGroup(
                  title: easy.tr("settings.account.title"),
                  items: [
                    _buildSettingsItem(
                      icon: MingCute.VIP_2_line,
                      title: easy.tr("settings.account.upgrade"),
                      onTap: () {
                        paywall();
                      },
                    ),
                  ],
                ),
                _buildSettingsGroup(
                  title: easy.tr("settings.app.title"),
                  items: [
                    _buildSettingsItem(
                      icon: MingCute.notification_line,
                      title: easy.tr("settings.app.notifications"),
                      onTap: () {},
                    ),
                    _buildSettingsItem(
                      icon: Icons.language,
                      title: easy.tr('settings.app.language.title'),
                      trailing: easy.tr('settings.app.language.current'),
                      onTap: () => _showLanguageSelectionModal(context),
                    ),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Container(
                        padding: const EdgeInsets.all(MySize.halfPadding),
                        decoration: BoxDecoration(
                          color: MyColor.white.withOpacity(0.1),
                          borderRadius:
                              BorderRadius.circular(MySize.quarterRadius),
                        ),
                        child: Icon(MingCute.translate_2_line,
                            color: MyColor.white),
                      ),
                      title: Text(
                        easy.tr('settings.app.auto_translate'),
                        style: MyStyle.s2.copyWith(color: MyColor.white),
                      ),
                      subtitle: Text(
                        easy.tr('settings.app.auto_translate_desc'),
                        style:
                            MyStyle.s3.copyWith(color: MyColor.textGreyColor),
                      ),
                      trailing: Obx(() => Switch(
                            value: isAutoTranslateEnabled.value,
                            onChanged: toggleAutoTranslate,
                            activeColor: MyColor.primaryPurpleColor,
                            inactiveTrackColor: MyColor.white.withOpacity(0.1),
                          )),
                    ),
                  ],
                ),
                _buildSettingsGroup(
                  title: easy.tr("settings.support.title"),
                  items: [
                    _buildSettingsItem(
                      icon: MingCute.question_line,
                      title: easy.tr("settings.support.help_center"),
                      onTap: () {
                        launchUrl(Uri.parse('mailto:apptoiccontact@gmail.com'),
                            mode: LaunchMode.externalApplication);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Delete
          Padding(
            padding: const EdgeInsets.all(MySize.defaultPadding),
            child: SizedBox(
              width: double.infinity,
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  backgroundColor: MyColor.darkBackgroundColor,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                        MySize.halfRadius),
                                  ),
                                  title: Text(
                                    easy.tr(
                                        "settings.account.delete_confirmation.title"),
                                    style: MyStyle.s1.copyWith(
                                      color: MyColor.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  content: Text(
                                    easy.tr(
                                        "settings.account.delete_confirmation.message"),
                                    style: MyStyle.s2
                                        .copyWith(color: MyColor.white),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: Text(
                                        easy.tr(
                                            "settings.account.delete_confirmation.cancel"),
                                        style: MyStyle.s2.copyWith(
                                            color: MyColor.primaryLightColor),
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () async {
                                        try {
                                          final authController =
                                              Get.find<AuthController>();
                                          await authController.deleteAccount();
                                        } catch (e) {
                                          Get.snackbar(
                                            'Hata',
                                            'Hesap silinirken bir hata oluştu: $e',
                                            backgroundColor:
                                                MyColor.darkBackgroundColor,
                                            colorText: MyColor.white,
                                          );
                                        }
                                      },
                                      child: Text(
                                        easy.tr(
                                            "settings.account.delete_confirmation.confirm"),
                                        style: MyStyle.s2.copyWith(
                                            color: MyColor.errorColor),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                MyColor.errorColor.withOpacity(0.1),
                            padding:
                                const EdgeInsets.all(MySize.defaultPadding),
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(MySize.halfRadius),
                            ),
                          ),
                          child: Text(
                            easy.tr("settings.account.delete"),
                            style: MyStyle.s2.copyWith(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton(
                          onPressed: () {
                            const url =
                                'https://apptoic.com/spiroot-privacy-policy/';
                            final uri = Uri.parse(url);
                            launchUrl(uri,
                                mode: LaunchMode.externalApplication);
                          },
                          child: Text(
                            "privacy policy",
                            style: MyStyle.s4,
                          )),
                      Text("•", style: MyStyle.s4),
                      TextButton(
                          onPressed: () {
                            const url =
                                'https://apptoic.com/spiroot-terms-of-use-eula/';
                            final uri = Uri.parse(url);
                            launchUrl(uri,
                                mode: LaunchMode.externalApplication);
                          },
                          child: Text("terms of use", style: MyStyle.s4)),
                    ],
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

Widget _buildSettingsGroup(
    {required String title, required List<Widget> items}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.symmetric(vertical: MySize.defaultPadding),
        child: Text(
          title,
          style: MyStyle.s2.copyWith(
            color: MyColor.primaryLightColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      ...items,
      const SizedBox(height: MySize.defaultPadding),
    ],
  );
}

Widget _buildSettingsItem({
  required IconData icon,
  required String title,
  String? trailing,
  required VoidCallback onTap,
}) {
  return ListTile(
    onTap: onTap,
    contentPadding: EdgeInsets.zero,
    leading: Container(
      padding: const EdgeInsets.all(MySize.halfPadding),
      decoration: BoxDecoration(
        color: MyColor.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(MySize.quarterRadius),
      ),
      child: Icon(icon, color: MyColor.white),
    ),
    title: Text(
      title,
      style: MyStyle.s2.copyWith(color: MyColor.white),
    ),
    trailing: trailing != null
        ? Text(
            trailing,
            style: MyStyle.s3.copyWith(color: MyColor.textGreyColor),
          )
        : Icon(
            MyIcon.forward,
            color: MyColor.textGreyColor,
            size: MySize.iconSizeTiny,
          ),
  );
}
