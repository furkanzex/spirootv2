import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:spirootv2/core/helper/device_helper.dart';
import 'package:scaffold_gradient_background/scaffold_gradient_background.dart';
import 'package:spirootv2/blog/models/blog_post.dart';
import 'package:spirootv2/blog/screens/blog_detail_screen.dart';
import 'package:spirootv2/blog/screens/my_blog_posts_screen.dart';
import 'package:spirootv2/blog/services/blog_service.dart';
import 'package:spirootv2/core/constant/my_color.dart';
import 'package:spirootv2/core/constant/my_icon.dart';
import 'package:spirootv2/core/constant/my_size.dart';
import 'package:spirootv2/core/constant/my_style.dart';
import 'package:easy_localization/easy_localization.dart' as easy;
import 'package:spirootv2/paywall/paywall_screen.dart';
import 'package:spirootv2/profile/profile_onboarding.dart';
import 'create_blog_post_screen.dart';

class BlogListScreen extends StatefulWidget {
  const BlogListScreen({super.key});

  @override
  State<BlogListScreen> createState() => _BlogListScreenState();
}

class _BlogListScreenState extends State<BlogListScreen> {
  final BlogService _blogService = BlogService();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  Future<void> _checkAndNavigateToCreate(BuildContext context) async {
    try {
      await _blogService.checkUserEligibility();
      // Kontroller başarılı, blog oluşturma sayfasına git
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => CreateBlogPostScreen()),
      );
    } catch (e) {
      String errorMessage = e.toString();

      if (errorMessage.contains('profile_incomplete')) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ProfileOnboarding()),
        );
      } else if (errorMessage.contains('subscription_required')) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => PaywallScreen()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<BlogPost> _filterPosts(List<BlogPost> allPosts) {
    if (_searchQuery.isEmpty) {
      return allPosts;
    }

    final query = _searchQuery.toLowerCase();
    return allPosts.where((post) {
      final title = post.title.toLowerCase();
      final content = post.content.toLowerCase();
      final author = post.authorName.toLowerCase();

      return title.contains(query) ||
          content.contains(query) ||
          author.contains(query);
    }).toList();
  }

  Widget _buildSearchBar() {
    return Container(
      margin: EdgeInsets.all(MySize.defaultPadding),
      decoration: BoxDecoration(
        color: MyColor.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(MySize.halfRadius),
      ),
      child: TextField(
        controller: _searchController,
        style: MyStyle.s2.copyWith(color: MyColor.white),
        decoration: InputDecoration(
          hintText: easy.tr("Blog yazısı ara..."),
          hintStyle: MyStyle.s2.copyWith(color: MyColor.white.withOpacity(0.5)),
          prefixIcon: Icon(Icons.search, color: MyColor.white),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.clear, color: MyColor.white),
                  onPressed: () {
                    setState(() {
                      _searchController.clear();
                      _searchQuery = '';
                    });
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: MySize.defaultPadding,
            vertical: MySize.halfPadding,
          ),
        ),
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
      ),
    );
  }

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
    return GestureDetector(
      onTap: () => DeviceHelper.hideKeyboard(),
      child: ScaffoldGradientBackground(
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
              onPressed: () => _checkAndNavigateToCreate(context),
            ),
            IconButton(
              icon: Icon(Icons.bookmark, color: MyColor.white),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MyBlogPostsScreen(),
                  ),
                );
              },
            ),
          ],
        ),
        body: Column(
          children: [
            _buildSearchBar(),
            Expanded(
              child: StreamBuilder<List<BlogPost>>(
                stream: _blogService.getApprovedBlogPosts(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Bir hata oluştu: ${snapshot.error}',
                        style: MyStyle.b4.copyWith(color: MyColor.white),
                      ),
                    );
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(
                        color: MyColor.primaryColor,
                      ),
                    );
                  }

                  final posts = snapshot.data ?? [];
                  final filteredPosts = _filterPosts(posts);

                  if (filteredPosts.isEmpty) {
                    return Center(
                      child: Text(
                        _searchQuery.isEmpty
                            ? easy.tr('Henüz blog yazısı yok')
                            : easy.tr('Arama sonucu bulunamadı'),
                        style: MyStyle.b4.copyWith(color: MyColor.white),
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: EdgeInsets.all(MySize.defaultPadding),
                    itemCount: filteredPosts.length,
                    itemBuilder: (context, index) {
                      final post = filteredPosts[index];
                      return Card(
                        color: MyColor.white.withOpacity(0.1),
                        margin: EdgeInsets.only(bottom: MySize.defaultPadding),
                        child: InkWell(
                          borderRadius:
                              BorderRadius.circular(MySize.halfRadius),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    BlogDetailScreen(post: post),
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
                                      color:
                                          MyColor.primaryColor.withOpacity(0.2),
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
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          post.authorName,
                                          style: MyStyle.s3.copyWith(
                                            color:
                                                MyColor.white.withOpacity(0.6),
                                          ),
                                        ),
                                        Text(
                                          _formatDate(post.createdAt),
                                          style: MyStyle.s3.copyWith(
                                            color:
                                                MyColor.white.withOpacity(0.6),
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
            ),
          ],
        ),
      ),
    );
  }
}
