import 'package:flutter/material.dart';
import 'package:spirootv2/core/constant/my_color.dart';
import 'package:spirootv2/core/constant/my_size.dart';
import 'package:spirootv2/core/constant/my_style.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:animate_do/animate_do.dart';
import 'package:spirootv2/enlightenment/ritual_list_screen.dart';
import 'package:easy_localization/easy_localization.dart' as easy;
import 'package:scaffold_gradient_background/scaffold_gradient_background.dart';

class RitualScreen extends StatelessWidget {
  const RitualScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final categories = [
      {
        'title': 'Şifa Ritüelleri',
        'image':
            'https://images.unsplash.com/photo-1600431521340-491eca880813?q=80',
        'description': 'Fiziksel ve ruhsal şifa için kutsal ritüeller',
        'color': Color(0xFF7B8FF7),
      },
      {
        'title': 'Bereket Ritüelleri',
        'image':
            'https://images.unsplash.com/photo-1515942661900-94b3d1972591?q=80',
        'description': 'Bolluk ve bereket çekmek için güçlü ritüeller',
        'color': Color(0xFFF7C77B),
      },
      {
        'title': 'Aşk Ritüelleri',
        'image':
            'https://images.unsplash.com/photo-1518531933037-91b2f5f229cc?q=80',
        'description': 'Aşk ve ilişkiler için özel ritüeller',
        'color': Color(0xFFF77B9D),
      },
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
                  child: ListView.builder(
                    itemCount: categories.length,
                    itemBuilder: (context, index) => FadeInUp(
                      delay: Duration(milliseconds: 100 * index),
                      child: GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => RitualListScreen(
                              category: categories[index],
                            ),
                          ),
                        ),
                        child: Container(
                          margin:
                              EdgeInsets.only(bottom: MySize.defaultPadding),
                          height: 160,
                          decoration: BoxDecoration(
                            borderRadius:
                                BorderRadius.circular(MySize.halfRadius),
                            color: categories[index]['color'] as Color,
                          ),
                          child: Stack(
                            children: [
                              ClipRRect(
                                borderRadius:
                                    BorderRadius.circular(MySize.halfRadius),
                                child: Image.network(
                                  categories[index]['image'] as String,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: double.infinity,
                                  color: Colors.black.withOpacity(0.3),
                                  colorBlendMode: BlendMode.darken,
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.all(MySize.defaultPadding),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      categories[index]['title'] as String,
                                      style: MyStyle.b4
                                          .copyWith(color: MyColor.white),
                                    ),
                                    Text(
                                      categories[index]['description']
                                          as String,
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
                    ),
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
