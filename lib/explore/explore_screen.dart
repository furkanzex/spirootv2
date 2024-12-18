import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:spirootv2/chat/chat_screen.dart';
import 'package:spirootv2/core/constant/my_color.dart';
import 'package:spirootv2/core/constant/my_size.dart';
import 'package:spirootv2/core/constant/my_style.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:lottie/lottie.dart';
import 'package:spirootv2/explore/explore_controller.dart';
import 'package:easy_localization/easy_localization.dart' as easy;

class ExploreScreen extends StatelessWidget {
  ExploreScreen({super.key});

  final ExploreController _exploreController = Get.put(ExploreController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColor.darkBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          easy.tr('explore.title'),
          style: MyStyle.s1.copyWith(
            color: MyColor.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Obx(() {
        if (_exploreController.isSearching.value) {
          return _buildSearchingView();
        }
        return _buildMainView();
      }),
      floatingActionButton: Obx(() {
        // Eşleşme aranıyorsa FAB gösterme
        if (_exploreController.isSearching.value) {
          return const SizedBox();
        }

        // Aktif eşleşme varsa sohbete devam et butonu göster
        if (_exploreController.isMatched.value) {
          return FloatingActionButton.extended(
            onPressed: () => Get.to(() =>
                ChatScreen(chatId: _exploreController.currentChatId.value)),
            backgroundColor: MyColor.primaryColor,
            label: Row(
              children: [
                const Icon(MingCute.chat_3_line, color: MyColor.white),
                const SizedBox(width: 8),
                Text(
                  easy.tr('explore.continue_chat'),
                  style: MyStyle.s2.copyWith(
                    color: MyColor.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          );
        }

        // Eğer aktif eşleşme yoksa yeni eşleşme ara butonu göster
        return FloatingActionButton.extended(
          onPressed: () => _exploreController.startMatching(),
          backgroundColor: MyColor.primaryColor,
          icon: const Icon(MingCute.search_3_line, color: MyColor.white),
          label: Text(
            easy.tr('explore.search'),
            style: MyStyle.s2.copyWith(
              color: MyColor.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      }),
    );
  }

  Widget _buildSearchingView() {
    return Stack(
      children: [
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 200,
                width: 200,
                child: Lottie.asset(
                  'assets/lottie/searching.json',
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: MySize.defaultPadding),
              Text(
                easy.tr('explore.searching'),
                style: MyStyle.s1.copyWith(
                  color: MyColor.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: MySize.halfPadding),
              Text(
                easy.tr('explore.searching_description'),
                style: MyStyle.s3.copyWith(
                  color: MyColor.textGreyColor,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        // İptal butonu
        Positioned(
          top: MySize.defaultPadding,
          right: MySize.defaultPadding,
          child: IconButton(
            onPressed: () {
              _exploreController.cancelSearch();
            },
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: MyColor.white.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.close,
                color: MyColor.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMainView() {
    return Column(
      children: [
        // Online kullanıcı sayısı
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: MySize.defaultPadding,
            vertical: MySize.halfPadding,
          ),
          margin: const EdgeInsets.all(MySize.defaultPadding),
          decoration: BoxDecoration(
            color: MyColor.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(MySize.halfRadius),
            border: Border.all(
              color: MyColor.primaryColor.withOpacity(0.2),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                easy.tr('explore.ready_for_new_matches'),
                style: MyStyle.s3.copyWith(
                  color: MyColor.white,
                ),
              ),
            ],
          ),
        ),

        // Ana içerik
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(MySize.defaultPadding),
            child: Column(
              children: [
                // Eşleşme kartı
                Container(
                  padding: const EdgeInsets.all(MySize.defaultPadding),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        MyColor.primaryColor.withOpacity(0.2),
                        MyColor.secondaryColor.withOpacity(0.2),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(MySize.defaultRadius),
                  ),
                  child: Column(
                    children: [
                      Lottie.asset(
                        'assets/lottie/cosmic_match.json',
                        height: 200,
                      ),
                      Text(
                        easy.tr('explore.cosmic_match'),
                        style: MyStyle.s1.copyWith(
                          color: MyColor.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        easy.tr('explore.cosmic_match_description'),
                        textAlign: TextAlign.center,
                        style: MyStyle.s2.copyWith(
                          color: MyColor.white.withOpacity(0.8),
                        ),
                      ),
                      const SizedBox(height: MySize.defaultPadding),
                      Text(
                        easy.tr('explore.chat_is_temporary'),
                        textAlign: TextAlign.center,
                        style: MyStyle.s3.copyWith(
                          color: MyColor.textGreyColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
