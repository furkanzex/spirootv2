import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:spirootv2/core/service/gemini_service.dart';
import 'package:spirootv2/auth/auth_controller.dart';
import 'package:spirootv2/core/service/revenuecat_services.dart';
import 'package:spirootv2/profile/user_controller.dart';
import 'package:spirootv2/core/service/translation_service.dart';
import '../models/blog_post.dart';
import 'package:easy_localization/easy_localization.dart' as easy;

class BlogService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GeminiService _geminiService = Get.find<GeminiService>();
  final AuthController _authController = Get.find<AuthController>();
  final UserController _userController = Get.find<UserController>();
  final TranslationService _translationService = Get.find<TranslationService>();

  // Kullanıcı kontrolü
  Future<void> checkUserEligibility() async {
    final user = _auth.currentUser;
    if (user == null) throw Exception(easy.tr('blog.user_not_logged_in'));

    // Profil kontrolü
    final isProfileComplete = await _authController.isProfileComplete();
    if (!isProfileComplete) {
      throw Exception(easy.tr('blog.profile_incomplete'));
    }

    // Abonelik kontrolü
    await checkSubscriptionStatus();
  }

  Future<void> checkSubscriptionStatus() async {
    try {
      final hasActiveSubscription = await PurchaseAPI.checkSubscriptionStatus();
      if (!hasActiveSubscription) {
        throw Exception(easy.tr('blog.subscription_required'));
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // Blog yazısı oluşturma
  Future<bool> createBlogPost({
    required String title,
    required String content,
    required String imageUrl,
  }) async {
    try {
      // Kullanıcı uygunluk kontrolü
      await checkUserEligibility();

      // İçerik uzunluğunu kontrol et
      if (content.length < 500) {
        throw Exception(easy.tr('blog.content_min_length'));
      }

      // Görsel URL'sini kontrol et
      if (imageUrl.isEmpty) {
        throw Exception(easy.tr('blog.image_url_required'));
      }

      // URL formatını kontrol et
      final uri = Uri.tryParse(imageUrl);
      if (uri == null || !uri.isAbsolute) {
        throw Exception('Geçerli bir görsel URL\'si giriniz.');
      }

      // Desteklenen görsel formatlarını kontrol et
      final validExtensions = ['.jpg', '.jpeg', '.png', '.gif', '.webp'];
      final hasValidExtension =
          validExtensions.any((ext) => imageUrl.toLowerCase().endsWith(ext));

      if (!hasValidExtension) {
        throw Exception(easy.tr('blog.invalid_image_format'));
      }
      // AI moderasyon kontrolü
      final bool isAppropriate =
          await _geminiService.checkBlogContentModeration(title, content);
      if (!isAppropriate) {
        throw Exception(easy.tr('blog.content_not_appropriate'));
      }

      final user = _auth.currentUser;
      if (user == null) throw Exception(easy.tr('blog.user_not_logged_in'));

      final docRef = _firestore.collection('blog_posts').doc();
      final blogPost = BlogPost(
        id: docRef.id,
        title: title,
        content: content,
        imageUrl: imageUrl,
        authorId: user.uid,
        authorName: _userController.userName,
        createdAt: DateTime.now(),
        isApproved: true,
      );

      await docRef.set(blogPost.toMap());
      return true;
    } catch (e) {
      rethrow;
    }
  }

  // Blog yazısını güncelle
  Future<bool> updateBlogPost({
    required String postId,
    required String title,
    required String content,
    required String imageUrl,
  }) async {
    try {
      // Kullanıcı uygunluk kontrolü
      await checkUserEligibility();

      // İçerik uzunluğunu kontrol et
      if (content.length < 500) {
        throw Exception('İçerik en az 500 karakter olmalıdır.');
      }

      // Görsel URL'sini kontrol et
      if (imageUrl.isEmpty) {
        throw Exception(easy.tr('blog.image_url_required'));
      }

      // URL formatını kontrol et
      final uri = Uri.tryParse(imageUrl);
      if (uri == null || !uri.isAbsolute) {
        throw Exception(easy.tr('blog.invalid_url'));
      }

      // Desteklenen görsel formatlarını kontrol et
      final validExtensions = ['.jpg', '.jpeg', '.png', '.gif', '.webp'];
      final hasValidExtension =
          validExtensions.any((ext) => imageUrl.toLowerCase().endsWith(ext));

      if (!hasValidExtension) {
        throw Exception(easy.tr('blog.invalid_image_format'));
      }

      // AI moderasyon kontrolü
      final bool isAppropriate =
          await _geminiService.checkBlogContentModeration(title, content);
      if (!isAppropriate) {
        throw Exception(easy.tr('blog.content_not_appropriate'));
      }

      final user = _auth.currentUser;
      if (user == null) throw Exception(easy.tr('blog.user_not_logged_in'));

      await _firestore.collection('blog_posts').doc(postId).update({
        'title': title,
        'content': content,
        'imageUrl': imageUrl,
        'authorName': _userController.userName,
        'updatedAt': DateTime.now(),
      });

      return true;
    } catch (e) {
      rethrow;
    }
  }

  // Tüm onaylanmış blog yazılarını getir
  Stream<List<BlogPost>> getApprovedBlogPosts() {
    return _firestore
        .collection('blog_posts')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .asyncMap((snapshot) async {
      final posts = <BlogPost>[];

      for (var doc in snapshot.docs) {
        try {
          final post = BlogPost.fromMap(doc.data());
          if (post.isApproved) {
            // İçeriği çevir
            final translatedTitle =
                await _translationService.translateToAppLanguage(post.title);
            final translatedContent =
                await _translationService.translateToAppLanguage(post.content);

            // Yeni bir BlogPost nesnesi oluştur
            posts.add(BlogPost(
              id: post.id,
              title: translatedTitle,
              content: translatedContent,
              imageUrl: post.imageUrl,
              authorId: post.authorId,
              authorName: post.authorName,
              createdAt: post.createdAt,
              isApproved: post.isApproved,
            ));
          }
        } catch (e) {
          print('Blog post çevirme hatası: $e');
        }
      }

      return posts;
    });
  }

  // Kullanıcının kendi blog yazılarını getir
  Stream<List<BlogPost>> getUserBlogPosts(String userId) {
    return _firestore
        .collection('blog_posts')
        .where('authorId', isEqualTo: userId)
        .snapshots()
        .asyncMap((snapshot) async {
      final posts = <BlogPost>[];

      for (var doc in snapshot.docs) {
        try {
          final post = BlogPost.fromMap(doc.data());

          // İçeriği çevir
          final translatedTitle =
              await _translationService.translateToAppLanguage(post.title);
          final translatedContent =
              await _translationService.translateToAppLanguage(post.content);

          // Yeni bir BlogPost nesnesi oluştur
          posts.add(BlogPost(
            id: post.id,
            title: translatedTitle,
            content: translatedContent,
            imageUrl: post.imageUrl,
            authorId: post.authorId,
            authorName: post.authorName,
            createdAt: post.createdAt,
            isApproved: post.isApproved,
          ));
        } catch (e) {
          print('Blog post çevirme hatası: $e');
        }
      }

      // Client tarafında sıralama
      posts.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      return posts;
    });
  }

  // Blog yazısını sil
  Future<void> deleteBlogPost(String postId) async {
    try {
      await _firestore.collection('blog_posts').doc(postId).delete();
    } catch (e) {
      rethrow;
    }
  }
}
