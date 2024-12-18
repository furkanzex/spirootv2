import 'package:flutter/material.dart';
import 'package:scaffold_gradient_background/scaffold_gradient_background.dart';
import 'package:spirootv2/blog/models/blog_post.dart';
import 'package:spirootv2/blog/screens/blog_detail_screen.dart';
import 'package:spirootv2/blog/screens/edit_blog_post_screen.dart';
import 'package:spirootv2/blog/services/blog_service.dart';
import 'package:spirootv2/core/constant/my_color.dart';
import 'package:spirootv2/core/constant/my_icon.dart';
import 'package:spirootv2/core/constant/my_size.dart';
import 'package:spirootv2/core/constant/my_style.dart';
import 'package:easy_localization/easy_localization.dart' as easy;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class MyBlogPostsScreen extends StatelessWidget {
  MyBlogPostsScreen({super.key});

  final BlogService _blogService = BlogService();
  final String _currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';

  String _formatDate(DateTime date) {
    return DateFormat('dd.MM.yyyy').format(date);
  }

  Future<void> _showDeleteConfirmation(
      BuildContext context, BlogPost post) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: MyColor.darkBackgroundColor,
          title: Text(
            easy.tr('blog.delete_post'),
            style: MyStyle.b4.copyWith(color: MyColor.white),
          ),
          content: Text(
            easy.tr('blog.delete_post_confirmation'),
            style: MyStyle.s2.copyWith(color: MyColor.white),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                easy.tr('blog.cancel'),
                style: MyStyle.s2.copyWith(color: MyColor.white),
              ),
            ),
            TextButton(
              onPressed: () async {
                try {
                  await _blogService.deleteBlogPost(post.id);
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(easy.tr('blog.post_deleted')),
                      backgroundColor: Colors.green,
                    ),
                  );
                } catch (e) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(easy.tr('blog.post_deletion_error')),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: Text(
                easy.tr('blog.delete'),
                style: MyStyle.s2.copyWith(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  void _navigateToEditScreen(BuildContext context, BlogPost post) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditBlogPostScreen(post: post),
      ),
    );
  }

  Widget _buildBlogPostCard(BuildContext context, BlogPost post) {
    return Card(
      color: MyColor.darkBackgroundColor,
      elevation: 2,
      child: ListTile(
        contentPadding: EdgeInsets.all(MySize.defaultPadding),
        leading: Image.network(post.imageUrl),
        title: Text(
          post.title,
          style: MyStyle.b5.copyWith(color: MyColor.white),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: MySize.defaultPadding / 2),
            Text(
              _formatDate(post.createdAt),
              style: MyStyle.s3.copyWith(color: MyColor.white.withOpacity(0.7)),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.edit, color: MyColor.white),
              onPressed: () => _navigateToEditScreen(context, post),
            ),
            IconButton(
              icon: Icon(Icons.delete, color: Colors.red),
              onPressed: () => _showDeleteConfirmation(context, post),
            ),
          ],
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BlogDetailScreen(post: post),
            ),
          );
        },
      ),
    );
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
          easy.tr("blog.my_posts"),
          style: MyStyle.b4.copyWith(color: MyColor.white),
        ),
      ),
      body: StreamBuilder<List<BlogPost>>(
        stream: _blogService.getUserBlogPosts(_currentUserId),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text(
                easy.tr('blog.error_occurred'),
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

          if (posts.isEmpty) {
            return Center(
              child: Text(
                easy.tr('blog.no_posts'),
                style: MyStyle.b4.copyWith(color: MyColor.white),
              ),
            );
          }

          return ListView.builder(
            padding: EdgeInsets.all(MySize.defaultPadding),
            itemCount: posts.length,
            itemBuilder: (context, index) {
              final post = posts[index];
              return _buildBlogPostCard(context, post);
            },
          );
        },
      ),
    );
  }
}
