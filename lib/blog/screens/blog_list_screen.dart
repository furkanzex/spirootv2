import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:scaffold_gradient_background/scaffold_gradient_background.dart';
import 'package:spirootv2/blog/models/blog_post.dart';
import 'package:spirootv2/blog/screens/blog_detail_screen.dart';
import 'package:spirootv2/blog/services/blog_service.dart';
import 'package:spirootv2/core/constant/my_color.dart';
import 'package:spirootv2/core/constant/my_icon.dart';
import 'package:spirootv2/core/constant/my_size.dart';
import 'package:spirootv2/core/constant/my_style.dart';
import 'package:easy_localization/easy_localization.dart' as easy;
import 'create_blog_post_screen.dart';

class BlogListScreen extends StatelessWidget {
  BlogListScreen({super.key}) {
    print('BlogListScreen oluşturuldu');
  }

  final BlogService _blogService = BlogService();

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        if (difference.inMinutes == 0) {
          return easy.tr("Şimdi");
        }
        return "${difference.inMinutes} ${easy.tr("dakika önce")}";
      }
      return "${difference.inHours} ${easy.tr("saat önce")}";
    } else if (difference.inDays < 7) {
      return "${difference.inDays} ${easy.tr("gün önce")}";
    } else {
      return DateFormat('dd.MM.yyyy').format(date);
    }
  }

  @override
  Widget build(BuildContext context) {
    print('BlogListScreen build başladı');
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
        surfaceTintColor: MyColor.transparent,
        backgroundColor: MyColor.transparent,
        elevation: 0,
        title: Text(
          easy.tr("Blog"),
          style: MyStyle.b4.copyWith(color: MyColor.white),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: Icon(MyIcon.back,
              color: MyColor.white, size: MySize.iconSizeSmall),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.add, color: MyColor.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CreateBlogPostScreen(),
                ),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.bookmark, color: MyColor.white),
            onPressed: () {
              //kullanıcının kendi paylaştığı blog yazılarını görebileceği ve editleyebileceği sayfaya yönlendirme yapılacak
            },
          ),
        ],
      ),
      body: StreamBuilder<List<BlogPost>>(
        stream: _blogService.getApprovedBlogPosts(),
        builder: (context, snapshot) {
          print(
              'StreamBuilder build - Bağlantı durumu: ${snapshot.connectionState}');

          if (snapshot.hasError) {
            print('StreamBuilder hata: ${snapshot.error}');
            return Center(
              child: Text(
                'Bir hata oluştu: ${snapshot.error}',
                style: MyStyle.b4.copyWith(color: MyColor.white),
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            print('StreamBuilder yükleniyor');
            return Center(
              child: CircularProgressIndicator(
                color: MyColor.primaryColor,
              ),
            );
          }

          final posts = snapshot.data ?? [];
          print('Alınan blog yazısı sayısı: ${posts.length}');

          if (posts.isEmpty) {
            print('Blog yazısı bulunamadı');
            return Center(
              child: Text(
                'Henüz blog yazısı yok',
                style: MyStyle.b4.copyWith(color: MyColor.white),
              ),
            );
          }

          print('Blog yazıları listeleniyor');
          return ListView.builder(
            padding: EdgeInsets.all(MySize.defaultPadding),
            itemCount: posts.length,
            itemBuilder: (context, index) {
              final post = posts[index];
              print('Blog yazısı gösteriliyor: ${post.id}');
              return Card(
                color: MyColor.white.withOpacity(0.1),
                margin: EdgeInsets.only(bottom: MySize.defaultPadding),
                child: InkWell(
                  borderRadius: BorderRadius.circular(MySize.halfRadius),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BlogDetailScreen(post: post),
                      ),
                    );
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(MySize.quarterRadius),
                        ),
                        child: Image.network(
                          post.imageUrl,
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              height: 200,
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
                      ),
                      Padding(
                        padding: EdgeInsets.all(MySize.defaultPadding),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              post.title,
                              style: MyStyle.s1.copyWith(
                                color: MyColor.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: MySize.halfPadding),
                            Text(
                              post.content.length > 100
                                  ? '${post.content.substring(0, 100)}...'
                                  : post.content,
                              style: MyStyle.s3.copyWith(
                                color: MyColor.white.withOpacity(0.8),
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 3,
                            ),
                            SizedBox(height: MySize.defaultPadding),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  post.authorName,
                                  style: MyStyle.s3.copyWith(
                                    color: MyColor.white.withOpacity(0.6),
                                  ),
                                ),
                                Text(
                                  _formatDate(post.createdAt),
                                  style: MyStyle.s3.copyWith(
                                    color: MyColor.white.withOpacity(0.6),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
