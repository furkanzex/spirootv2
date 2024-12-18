// ignore_for_file: use_build_context_synchronously

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
import 'package:get/get.dart';
import 'package:spirootv2/profile/user_controller.dart';
import 'package:spirootv2/astrology/astrology_controller.dart';

class BlogListScreen extends StatefulWidget {
  const BlogListScreen({super.key});

  @override
  State<BlogListScreen> createState() => _BlogListScreenState();
}

class _BlogListScreenState extends State<BlogListScreen> {
  final BlogService _blogService = BlogService();
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final TextEditingController _imageUrlController = TextEditingController();
  final _userController = Get.find<UserController>();
  final _astrologyController = Get.find<AstrologyController>();
  final _formKey = GlobalKey<FormState>();
  String _searchQuery = '';
  bool _isLoading = false;

  Future<bool> _checkUserStatusAndRedirect() async {
    if (_userController.userName.isEmpty) {
      Get.to(() => const ProfileOnboarding());
      return false;
    }

    if (!_astrologyController.isSubscribed.value) {
      paywall();
      return false;
    }

    return true;
  }

  Future<void> _submitPost() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _blogService.createBlogPost(
        title: _titleController.text.trim(),
        content: _contentController.text.trim(),
        imageUrl: _imageUrlController.text.trim(),
      );

      _titleController.clear();
      _contentController.clear();
      _imageUrlController.clear();

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(easy.tr("blog.post_created")),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  bool _isValidUrl(String url) {
    if (url.isEmpty) return false;

    final uri = Uri.tryParse(url);
    if (uri == null || !uri.isAbsolute) return false;

    final validExtensions = ['.jpg', '.jpeg', '.png', '.gif', '.webp'];
    return validExtensions.any((ext) => url.toLowerCase().endsWith(ext));
  }

  void _showCreateBlogSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      enableDrag: true,
      isDismissible: true,
      backgroundColor: MyColor.primaryDarkColor,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(MySize.halfRadius)),
      ),
      builder: (context) => WillPopScope(
        onWillPop: () async {
          _titleController.clear();
          _contentController.clear();
          _imageUrlController.clear();
          return true;
        },
        child: DraggableScrollableSheet(
          initialChildSize: 0.75,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) => SingleChildScrollView(
            controller: scrollController,
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                MySize.defaultPadding,
                MySize.defaultPadding,
                MySize.defaultPadding,
                MediaQuery.of(context).viewInsets.bottom +
                    MySize.defaultPadding,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      easy.tr("blog.new_post"),
                      style: MyStyle.b4.copyWith(color: MyColor.white),
                    ),
                    SizedBox(height: MySize.defaultPadding),
                    TextFormField(
                      controller: _titleController,
                      style: MyStyle.s2.copyWith(color: MyColor.white),
                      decoration: InputDecoration(
                        labelText: easy.tr("blog.title"),
                        labelStyle:
                            MyStyle.s2.copyWith(color: MyColor.textGreyColor),
                        border: OutlineInputBorder(),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: MyColor.textGreyColor),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: MyColor.primaryPurpleColor),
                        ),
                        errorStyle:
                            MyStyle.s3.copyWith(color: MyColor.errorColor),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return easy.tr("blog.title_required");
                        }
                        if (value.trim().length < 10) {
                          return easy.tr("blog.title_min_length");
                        }
                        if (value.trim().length > 100) {
                          return easy.tr("blog.title_max_length");
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: MySize.defaultPadding),
                    TextFormField(
                      controller: _contentController,
                      style: MyStyle.s2.copyWith(color: MyColor.white),
                      maxLines: 10,
                      decoration: InputDecoration(
                        labelText: easy.tr("blog.content"),
                        labelStyle:
                            MyStyle.s2.copyWith(color: MyColor.textGreyColor),
                        border: OutlineInputBorder(),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: MyColor.textGreyColor),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: MyColor.primaryPurpleColor),
                        ),
                        errorStyle:
                            MyStyle.s3.copyWith(color: MyColor.errorColor),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return easy.tr("blog.content_required");
                        }
                        if (value.trim().length < 500) {
                          return easy.tr("blog.content_min_length");
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: MySize.defaultPadding),
                    TextFormField(
                      controller: _imageUrlController,
                      style: MyStyle.s2.copyWith(color: MyColor.white),
                      decoration: InputDecoration(
                        labelText: easy.tr("blog.image_url"),
                        labelStyle:
                            MyStyle.s2.copyWith(color: MyColor.textGreyColor),
                        border: OutlineInputBorder(),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: MyColor.textGreyColor),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: MyColor.primaryPurpleColor),
                        ),
                        errorStyle:
                            MyStyle.s3.copyWith(color: MyColor.errorColor),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return easy.tr("blog.image_url_required");
                        }
                        if (!_isValidUrl(value.trim())) {
                          return easy.tr("blog.invalid_image_url");
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: MySize.defaultPadding),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () {
                            _titleController.clear();
                            _contentController.clear();
                            _imageUrlController.clear();
                            Navigator.pop(context);
                          },
                          child: Text(
                            easy.tr("common.cancel"),
                            style: MyStyle.s2
                                .copyWith(color: MyColor.textGreyColor),
                          ),
                        ),
                        SizedBox(width: MySize.defaultPadding),
                        ElevatedButton(
                          onPressed: _isLoading ? null : _submitPost,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: MyColor.primaryPurpleColor,
                          ),
                          child: _isLoading
                              ? SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: MyColor.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(
                                  easy.tr("blog.publish"),
                                  style:
                                      MyStyle.s2.copyWith(color: MyColor.white),
                                ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _titleController.dispose();
    _contentController.dispose();
    _imageUrlController.dispose();
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
          hintText: easy.tr("blog.search"),
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
          return easy.tr("blog.now");
        }
        return "${difference.inMinutes} ${easy.tr("blog.minutes_ago")}";
      }
      return "${difference.inHours} ${easy.tr("blog.hours_ago")}";
    } else if (difference.inDays < 7) {
      return "${difference.inDays} ${easy.tr("blog.days_ago")}";
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
            "Blog",
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
              onPressed: () async {
                if (await _checkUserStatusAndRedirect()) {
                  _showCreateBlogSheet();
                }
              },
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
                        easy.tr('errors.error'),
                        style: MyStyle.s3.copyWith(color: MyColor.white),
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
                            ? easy.tr('blog.no_posts')
                            : easy.tr('blog.no_results'),
                        style: MyStyle.s3.copyWith(color: MyColor.white),
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
                                          Icons.image_not_supported_outlined,
                                          color: MyColor.white.withOpacity(0.5),
                                          size: MySize.iconSizeBig,
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
