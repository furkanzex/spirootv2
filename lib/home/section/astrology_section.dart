import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:spirootv2/home/home_controller.dart';
import 'package:spirootv2/profile/user_controller.dart';
import 'package:spirootv2/core/constant/my_color.dart';
import 'package:spirootv2/core/constant/my_icon.dart';
import 'package:spirootv2/core/constant/my_image.dart';
import 'package:spirootv2/core/constant/my_size.dart';
import 'package:spirootv2/core/constant/my_style.dart';
import 'package:spirootv2/core/widget/gap/horizontal_gap.dart';
import 'package:spirootv2/core/widget/gap/vertical_gap.dart';
import 'package:spirootv2/core/widget/text_field/section_title.dart';
import 'package:easy_localization/easy_localization.dart' as easy;

class AstrologySection extends StatelessWidget {
  const AstrologySection({Key? key}) : super(key: key);

  void _navigateToAstrology() {
    final controller = Get.put(HomeController());
    controller.changePage(2);
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(UserController());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        sectionTitle(
          text: "🪐 ${easy.tr("navigation.astrology")}",
          trailingLabel: easy.tr("home.see_all"),
          icon: MyIcon.forward,
          color: MyColor.primaryPurpleColor,
          onTap: _navigateToAstrology,
        ),
        verticalGap(MySize.defaultPadding),
        ClipRRect(
          borderRadius: BorderRadius.circular(MySize.halfRadius),
          child: controller.isProfileComplete
              ? _buildCompletedProfile()
              : _buildIncompleteProfile(),
        ),
      ],
    );
  }

  Widget _buildCompletedProfile() {
    return GestureDetector(
      onTap: _navigateToAstrology,
      child: Container(
        width: double.infinity,
        height: 120,
        margin: const EdgeInsets.symmetric(horizontal: 5.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(MySize.halfRadius),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(MySize.halfRadius),
          child: Stack(
            children: [
              Positioned.fill(
                child: _buildBackgroundImage(),
              ),
              Positioned.fill(
                child: _buildNavigationRow(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBackgroundImage() {
    return ExtendedImage.network(
      "https://apptoic.com/spiroot/images/astrology.png",
      cache: true,
      fit: BoxFit.cover,
      color: Colors.black.withOpacity(0.7),
      colorBlendMode: BlendMode.darken,
      loadStateChanged: (ExtendedImageState state) {
        switch (state.extendedImageLoadState) {
          case LoadState.loading:
            return const _LoadingIndicator();
          case LoadState.completed:
            return state.completedWidget;
          case LoadState.failed:
            return const Center(child: Icon(Icons.error));
          default:
            return const SizedBox.shrink();
        }
      },
    );
  }

  Widget _buildNavigationRow() {
    return Padding(
      padding: const EdgeInsets.all(MySize.defaultPadding),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              easy.tr("astrology.discover_stars"),
              style: MyStyle.s1.copyWith(
                fontWeight: FontWeight.bold,
                color: MyColor.white,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIncompleteProfile() {
    return InkWell(
      onTap: _navigateToAstrology,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(MySize.defaultPadding),
        decoration: BoxDecoration(
          color: MyColor.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(MySize.halfRadius),
          border: Border.all(
            color: MyColor.primaryLightColor.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWelcomeRow(),
            verticalGap(MySize.defaultPadding),
            _buildFeatureRow(),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeRow() {
    return Row(
      children: [
        SizedBox(
          height: MySize.iconSizeMedium,
          width: MySize.iconSizeMedium,
          child: SvgPicture.asset(MyImage.welcomeImage),
        ),
        horizontalGap(MySize.defaultPadding),
        Expanded(
          child: Text(
            easy.tr("home.astrology.start_journey"),
            style: MyStyle.s2.copyWith(
              color: MyColor.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureRow() {
    return Row(
      children: [
        _buildFeatureItem("🌟", easy.tr("home.astrology.features.birth_chart")),
        horizontalGap(MySize.defaultPadding),
        _buildFeatureItem("💫", easy.tr("home.astrology.features.natal_chart")),
        horizontalGap(MySize.defaultPadding),
        _buildFeatureItem("🎯", easy.tr("home.astrology.features.fortune")),
      ],
    );
  }

  Widget _buildFeatureItem(String emoji, String text) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: MyColor.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(MySize.quarterRadius),
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 20)),
            verticalGap(4),
            Text(
              text,
              textAlign: TextAlign.center,
              style: MyStyle.s3.copyWith(
                color: MyColor.textGreyColor,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoadingIndicator extends StatelessWidget {
  const _LoadingIndicator({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MySize.iconSizeSmall,
      height: MySize.iconSizeSmall,
      child: CircularProgressIndicator(
        strokeWidth: 2,
        color: MyColor.primaryLightColor,
      ),
    );
  }
}
