import 'package:flutter/material.dart';
import 'package:spirootv2/core/constant/my_color.dart';
import 'package:spirootv2/core/constant/my_size.dart';
import 'package:spirootv2/core/constant/my_style.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:animate_do/animate_do.dart';
import 'package:spirootv2/enlightenment/ritual_list_screen.dart';
import 'package:easy_localization/easy_localization.dart' as easy;
import 'package:scaffold_gradient_background/scaffold_gradient_background.dart';
import 'package:shimmer/shimmer.dart';
import 'services/ritual_service.dart';

class RitualScreen extends StatefulWidget {
  const RitualScreen({super.key});

  @override
  State<RitualScreen> createState() => _RitualScreenState();
}

class _RitualScreenState extends State<RitualScreen> {
  String? _currentLocale;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final newLocale = context.locale.languageCode;

    if (_currentLocale != newLocale) {
      _currentLocale = newLocale;
      RitualService.onLocaleChanged(newLocale);
    }
  }

  Widget _buildShimmerItem() {
    return Shimmer.fromColors(
      baseColor: MyColor.white.withOpacity(0.1),
      highlightColor: MyColor.white.withOpacity(0.2),
      child: Container(
        margin: EdgeInsets.only(bottom: MySize.defaultPadding),
        height: 160,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(MySize.halfRadius),
          color: MyColor.white,
        ),
      ),
    );
  }

  Widget _buildShimmerList() {
    return ListView.builder(
      itemCount: 6,
      itemBuilder: (context, index) => _buildShimmerItem(),
    );
  }

  // Kategori renklerini tanımla
  final Map<String, Color> categoryColors = const {
    'love': MyColor.primaryLightColor,
    'money': MyColor.primaryLightColor,
    'protection': MyColor.primaryLightColor,
    'success': MyColor.primaryLightColor,
    'inspiration': MyColor.primaryLightColor,
    'cleansing': MyColor.primaryLightColor,
  };

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
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        surfaceTintColor: MyColor.transparent,
        backgroundColor: MyColor.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: MyColor.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(easy.tr("Ritüeller"),
            style: MyStyle.b4.copyWith(color: MyColor.white)),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Opacity(
              opacity: 0.5,
              child: SvgPicture.asset(
                'assets/svg/stars.svg',
                fit: BoxFit.cover,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(MySize.defaultPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: FutureBuilder<Map<String, dynamic>>(
                    future: RitualService.loadRituals(context),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return _buildShimmerList();
                      }

                      if (!snapshot.hasData) {
                        return Center(child: Text(easy.tr('Veri bulunamadı')));
                      }

                      final categories = snapshot.data!;

                      return ListView.builder(
                        itemCount: categories.length,
                        itemBuilder: (context, index) {
                          final categoryKey = categories.keys.elementAt(index);
                          final category = categories[categoryKey];

                          return FadeInUp(
                            delay: Duration(milliseconds: 100 * index),
                            child: GestureDetector(
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => RitualListScreen(
                                    category: category,
                                  ),
                                ),
                              ),
                              child: Container(
                                margin: EdgeInsets.only(
                                    bottom: MySize.defaultPadding),
                                height: 160,
                                decoration: BoxDecoration(
                                  borderRadius:
                                      BorderRadius.circular(MySize.halfRadius),
                                  color: categoryColors[categoryKey],
                                ),
                                child: Stack(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(
                                          MySize.halfRadius),
                                      child: RitualService.getCachedImage(
                                          category['image'] as String,
                                          height: 160),
                                    ),
                                    Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(
                                            MySize.halfRadius),
                                        color: MyColor.black.withOpacity(0.6),
                                      ),
                                    ),
                                    Padding(
                                      padding:
                                          EdgeInsets.all(MySize.defaultPadding),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            category['title'] as String,
                                            style: MyStyle.b4
                                                .copyWith(color: MyColor.white),
                                          ),
                                          Text(
                                            category['description'] as String,
                                            style: MyStyle.s2
                                                .copyWith(color: MyColor.white),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
