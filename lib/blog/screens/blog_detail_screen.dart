import 'package:flutter/material.dart';
import 'package:scaffold_gradient_background/scaffold_gradient_background.dart';
import 'package:spirootv2/blog/models/blog_post.dart';
import 'package:spirootv2/core/constant/my_color.dart';
import 'package:spirootv2/core/constant/my_icon.dart';
import 'package:spirootv2/core/constant/my_size.dart';
import 'package:spirootv2/core/constant/my_style.dart';
import 'package:intl/intl.dart';
import 'package:easy_localization/easy_localization.dart' as easy;

class BlogDetailScreen extends StatelessWidget {
  final BlogPost post;

  const BlogDetailScreen({super.key, required this.post});

  String _formatDate(DateTime date) {
    return DateFormat('dd.MM.yyyy').format(date);
  }

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
      appBar: AppBar(
        backgroundColor: MyColor.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(MyIcon.back, color: MyColor.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          easy.tr("blog.title"),
          style: MyStyle.b4.copyWith(color: MyColor.white),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Blog görseli
            Image.network(
              post.imageUrl,
              width: double.infinity,
              height: 250,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 250,
                  color: MyColor.primaryColor.withOpacity(0.2),
                  child: Center(
                    child: Icon(
                      Icons.error,
                      color: MyColor.white,
                    ),
                  ),
                );
              },
            ),
            Padding(
              padding: EdgeInsets.all(MySize.defaultPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Başlık
                  Text(
                    post.title,
                    style: MyStyle.s3.copyWith(
                      color: MyColor.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: MySize.defaultPadding),

                  // Yazar ve tarih bilgisi
                  Row(
                    children: [
                      Icon(
                        Icons.person,
                        color: MyColor.white.withOpacity(0.6),
                        size: MySize.iconSizeSmall,
                      ),
                      SizedBox(width: MySize.quarterPadding),
                      Text(
                        post.authorName,
                        style: MyStyle.s3.copyWith(
                          color: MyColor.white.withOpacity(0.6),
                        ),
                      ),
                      SizedBox(width: MySize.defaultPadding),
                      Icon(
                        Icons.calendar_today,
                        color: MyColor.white.withOpacity(0.6),
                        size: MySize.iconSizeSmall,
                      ),
                      SizedBox(width: MySize.quarterPadding),
                      Text(
                        _formatDate(post.createdAt),
                        style: MyStyle.s3.copyWith(
                          color: MyColor.white.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: MySize.defaultPadding * 2),

                  // İçerik
                  Text(
                    post.content,
                    style: MyStyle.s2.copyWith(
                      color: MyColor.white,
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
