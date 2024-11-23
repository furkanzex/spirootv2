import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:spirootv2/auth/auth_controller.dart';
import 'package:spirootv2/core/widget/gap/vertical_gap.dart';
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
import 'package:flutter_phoenix/flutter_phoenix.dart';

// Dil değiştirme fonksiyonu
void _changeLanguage(BuildContext context, String languageCode) async {
  try {
    Locale newLocale;
    switch (languageCode) {
      case 'tr':
        newLocale = const Locale('tr', 'TR');
        break;
      case 'en':
        newLocale = const Locale('en', 'US');
        break;
      default:
        return;
    }

    // Dili değiştir ve hemen ardından uygulamayı yeniden başlat
    await Future.wait([
      context.setLocale(newLocale),
      Future.delayed(const Duration(milliseconds: 100), () {
        Phoenix.rebirth(context);
      }),
    ]);
  } catch (e) {
    // Hata durumunda snackbar göster
    if (context.mounted) {
      Get.snackbar(
        'Hata',
        'Dil değiştirilirken bir hata oluştu',
        backgroundColor: MyColor.errorColor,
        colorText: MyColor.white,
      );
    }
    print('Dil değiştirme hatası: $e');
  }
}

// Dil seçim modalı
void _showLanguageSelectionModal(BuildContext context) {
  showModalBottomSheet(
    context: context,
    backgroundColor: MyColor.darkBackgroundColor,
    shape: const RoundedRectangleBorder(
      borderRadius:
          BorderRadius.vertical(top: Radius.circular(MySize.halfRadius)),
    ),
    builder: (context) => Container(
      padding: const EdgeInsets.all(MySize.defaultPadding),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            easy.tr('settings.app.language.title'),
            style: MyStyle.s1.copyWith(
              color: MyColor.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          verticalGap(MySize.defaultPadding),
          ListTile(
            title: Text(
              'Türkçe',
              style: MyStyle.s2.copyWith(color: MyColor.white),
            ),
            trailing: context.locale == const Locale('tr', 'TR')
                ? const Icon(Icons.check, color: MyColor.white)
                : null,
            onTap: () {
              _changeLanguage(context, 'tr');
              Navigator.pop(context);
            },
          ),
          ListTile(
            title: Text(
              'English',
              style: MyStyle.s2.copyWith(color: MyColor.white),
            ),
            trailing: context.locale == const Locale('en', 'US')
                ? const Icon(Icons.check, color: MyColor.white)
                : null,
            onTap: () {
              _changeLanguage(context, 'en');
              Navigator.pop(context);
            },
          ),
        ],
      ),
    ),
  );
}

void showSettingsBottomSheet(BuildContext context) {
  final userController = Get.find<UserController>();

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
                            Text(
                              easy.tr("settings.account.free_account"),
                              style: MyStyle.s3
                                  .copyWith(color: MyColor.textGreyColor),
                            ),
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
                      onTap: () {},
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
