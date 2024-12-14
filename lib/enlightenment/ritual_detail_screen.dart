import 'package:flutter/material.dart';
import 'package:spirootv2/core/constant/my_color.dart';
import 'package:spirootv2/core/constant/my_size.dart';
import 'package:spirootv2/core/constant/my_style.dart';
import 'package:animate_do/animate_do.dart';
import 'package:easy_localization/easy_localization.dart' as easy;
import 'package:spirootv2/enlightenment/services/ritual_service.dart';
import 'package:shimmer/shimmer.dart';

class RitualDetailScreen extends StatelessWidget {
  final Map<String, dynamic> ritual;

  const RitualDetailScreen({super.key, required this.ritual});

  Widget _buildShimmerItem() {
    return Container(
      margin: EdgeInsets.only(bottom: MySize.halfPadding),
      padding: EdgeInsets.all(MySize.defaultPadding),
      decoration: BoxDecoration(
        color: MyColor.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(MySize.quarterRadius),
      ),
      child: Row(
        children: [
          Shimmer.fromColors(
            baseColor: MyColor.white.withOpacity(0.1),
            highlightColor: MyColor.white.withOpacity(0.2),
            child: Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: MyColor.white,
                shape: BoxShape.circle,
              ),
            ),
          ),
          SizedBox(width: MySize.halfPadding),
          Expanded(
            child: Shimmer.fromColors(
              baseColor: MyColor.white.withOpacity(0.1),
              highlightColor: MyColor.white.withOpacity(0.2),
              child: Container(
                height: 20,
                decoration: BoxDecoration(
                  color: MyColor.white,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerContent(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColor.darkBackgroundColor,
      appBar: AppBar(
        surfaceTintColor: MyColor.transparent,
        backgroundColor: MyColor.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: MyColor.white),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: false,
        title: Shimmer.fromColors(
          baseColor: MyColor.white.withOpacity(0.1),
          highlightColor: MyColor.white.withOpacity(0.2),
          child: Container(
            width: 200,
            height: 24,
            decoration: BoxDecoration(
              color: MyColor.white,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
      ),
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: EdgeInsets.all(MySize.defaultPadding),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildSection(
                  title: 'Gerekli Malzemeler',
                  icon: Icons.workspaces,
                  child: Column(
                    children: List.generate(5, (index) => _buildShimmerItem()),
                  ),
                ),
                SizedBox(height: MySize.defaultPadding),
                _buildSection(
                  title: 'Ritüel Adımları',
                  icon: Icons.format_list_numbered,
                  child: Column(
                    children: List.generate(7, (index) => _buildShimmerItem()),
                  ),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: RitualService.translateRitualDetails(
        ritual,
        context.locale.languageCode,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildShimmerContent(context);
        }

        if (!snapshot.hasData) {
          return Scaffold(
            backgroundColor: MyColor.darkBackgroundColor,
            body: Center(
              child: Text(
                'Veri yüklenemedi',
                style: MyStyle.s1.copyWith(color: MyColor.white),
              ),
            ),
          );
        }

        final translatedRitual = snapshot.data!;

        return Scaffold(
          backgroundColor: MyColor.darkBackgroundColor,
          appBar: AppBar(
            surfaceTintColor: MyColor.transparent,
            backgroundColor: MyColor.transparent,
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios, color: MyColor.white),
              onPressed: () => Navigator.pop(context),
            ),
            centerTitle: false,
            title: Text(translatedRitual['title'],
                style: MyStyle.b4.copyWith(color: MyColor.white),
                textAlign: TextAlign.start),
          ),
          body: CustomScrollView(
            slivers: [
              SliverPadding(
                padding: EdgeInsets.all(MySize.defaultPadding),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _buildSection(
                      title: 'Gerekli Malzemeler',
                      icon: Icons.workspaces,
                      child: Column(
                        children: (translatedRitual['materials'] as List)
                            .map((material) {
                          return FadeInLeft(
                            child: _buildListItem(material),
                          );
                        }).toList(),
                      ),
                    ),
                    SizedBox(height: MySize.defaultPadding),
                    _buildSection(
                      title: 'Ritüel Adımları',
                      icon: Icons.format_list_numbered,
                      child: Column(
                        children: List.generate(
                          (translatedRitual['steps'] as List).length,
                          (index) => FadeInRight(
                            delay: Duration(milliseconds: 100 * index),
                            child: _buildStepItem(
                              index + 1,
                              translatedRitual['steps'][index],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ]),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: MyColor.primaryLightColor),
            SizedBox(width: MySize.halfPadding),
            Text(
              title,
              style: MyStyle.s2
                  .copyWith(color: MyColor.white, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        SizedBox(height: MySize.defaultPadding),
        child,
      ],
    );
  }

  Widget _buildListItem(String text) {
    return Container(
      margin: EdgeInsets.only(bottom: MySize.halfPadding),
      padding: EdgeInsets.all(MySize.defaultPadding),
      decoration: BoxDecoration(
        color: MyColor.primaryLightColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(MySize.quarterRadius),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.check_circle_outline,
                color: MyColor.primaryLightColor,
                size: MySize.iconSizeTiny,
              ),
              SizedBox(width: MySize.halfPadding),
              Expanded(
                child: Text(
                  text,
                  style: MyStyle.s2.copyWith(color: MyColor.white),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStepItem(int step, String text) {
    return Container(
      margin: EdgeInsets.only(bottom: MySize.halfPadding),
      padding: EdgeInsets.all(MySize.defaultPadding),
      decoration: BoxDecoration(
        color: MyColor.primaryLightColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(MySize.quarterRadius),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: MySize.iconSizeTiny,
            height: MySize.iconSizeTiny,
            decoration: BoxDecoration(
              color: MyColor.primaryLightColor,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                step.toString(),
                style: MyStyle.s3.copyWith(color: MyColor.white),
              ),
            ),
          ),
          SizedBox(width: MySize.defaultPadding),
          Expanded(
            child: Text(
              text,
              style: MyStyle.s2.copyWith(color: MyColor.white),
              softWrap: true,
            ),
          ),
        ],
      ),
    );
  }
}
