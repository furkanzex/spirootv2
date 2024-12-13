import 'package:flutter/material.dart';
import 'package:spirootv2/core/constant/my_color.dart';
import 'package:spirootv2/core/constant/my_size.dart';
import 'package:spirootv2/core/constant/my_style.dart';
import 'package:animate_do/animate_do.dart';
import 'package:spirootv2/enlightenment/ritual_detail_screen.dart';
import 'package:easy_localization/easy_localization.dart' as easy;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:scaffold_gradient_background/scaffold_gradient_background.dart';

class RitualListScreen extends StatelessWidget {
  final Map<String, dynamic> category;

  const RitualListScreen({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    final rituals = [
      {
        'title': 'Dolunay Şükran Ritüeli',
        'duration': '30 dakika',
        'difficulty': 'Kolay',
        'image':
            'https://images.unsplash.com/photo-1502239608882-93b729c6af43?q=80',
        'materials': [
          'Beyaz mum',
          'Tütsü',
          'Kristal',
          'Not defteri',
        ],
        'steps': [
          'Kutsal alanınızı hazırlayın',
          'Tütsünüzü yakın',
          'Mumu yakın ve niyetinizi belirleyin',
          'Meditasyon yapın',
          'Şükranlarınızı yazın',
        ],
      },
      // Diğer ritüeller...
    ];

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
        title: Text(category['title'],
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
                  child: ListView.builder(
                    itemCount: rituals.length,
                    itemBuilder: (context, index) {
                      final ritual = rituals[index];
                      return FadeInUp(
                        delay: Duration(milliseconds: 100 * index),
                        child: GestureDetector(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  RitualDetailScreen(ritual: ritual),
                            ),
                          ),
                          child: Container(
                            margin:
                                EdgeInsets.only(bottom: MySize.defaultPadding),
                            decoration: BoxDecoration(
                              color: MyColor.white.withOpacity(0.1),
                              borderRadius:
                                  BorderRadius.circular(MySize.halfRadius),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(MySize.halfRadius),
                                  ),
                                  child: Image.network(
                                    ritual['image'] as String,
                                    height: 200,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                Padding(
                                  padding:
                                      EdgeInsets.all(MySize.defaultPadding),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        ritual['title'] as String,
                                        style: MyStyle.b4
                                            .copyWith(color: MyColor.white),
                                      ),
                                      SizedBox(height: MySize.halfPadding),
                                      Row(
                                        children: [
                                          _buildInfoChip(
                                              ritual['duration'] as String),
                                          SizedBox(width: MySize.halfPadding),
                                          _buildInfoChip(
                                              ritual['difficulty'] as String),
                                        ],
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
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(String text) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: MySize.defaultPadding,
        vertical: MySize.quarterPadding,
      ),
      decoration: BoxDecoration(
        color: MyColor.primaryLightColor,
        borderRadius: BorderRadius.circular(MySize.quarterRadius),
      ),
      child: Text(
        text,
        style: MyStyle.s3.copyWith(color: MyColor.white),
      ),
    );
  }
}
