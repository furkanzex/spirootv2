import 'package:flutter/material.dart';
import 'package:spirootv2/core/constant/my_color.dart';
import 'package:spirootv2/core/constant/my_size.dart';
import 'package:spirootv2/core/constant/my_style.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:animate_do/animate_do.dart';
import 'package:spirootv2/enlightenment/ritual_list_screen.dart';
import 'package:easy_localization/easy_localization.dart' as easy;
import 'package:scaffold_gradient_background/scaffold_gradient_background.dart';
import 'services/ritual_service.dart';

class RitualScreen extends StatelessWidget {
  const RitualScreen({super.key});

  // Kategori renklerini tanımla
  final Map<String, Color> categoryColors = const {
    'love': Color(0xFFF77B9D),
    'money': Color(0xFFF7C77B),
    'protection': Color(0xFF7B8FF7),
    'success': Color(0xFF7BF7AD),
    'inspiration': Color(0xFFB57BF7),
    'cleansing': Color(0xFF7BE6F7),
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
          // Arkaplan dekorasyonu
          Positioned.fill(
            child: Opacity(
              opacity: 0.5,
              child: SvgPicture.asset(
                'assets/svg/stars.svg',
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Ana içerik
          Padding(
            padding: EdgeInsets.all(MySize.defaultPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: FutureBuilder<Map<String, dynamic>>(
                    future: RitualService.loadRituals(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircularProgressIndicator(
                                color: MyColor.primaryLightColor,
                              ),
                              SizedBox(height: MySize.defaultPadding),
                              Text(
                                easy.tr('Ritüeller yükleniyor...'),
                                style: MyStyle.s2.copyWith(
                                  color: MyColor.white,
                                ),
                              ),
                            ],
                          ),
                        );
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
                                      child: Image.network(
                                        category['image'] as String,
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                        height: double.infinity,
                                        color: Colors.black.withOpacity(0.3),
                                        colorBlendMode: BlendMode.darken,
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
