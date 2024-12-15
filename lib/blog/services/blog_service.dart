import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:spirootv2/core/service/gemini_service.dart';
import 'package:spirootv2/auth/auth_controller.dart';
import '../models/blog_post.dart';

class BlogService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GeminiService _geminiService = Get.find<GeminiService>();
  final AuthController _authController = Get.find<AuthController>();

  // Kullanıcı kontrolü
  Future<void> checkUserEligibility() async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Kullanıcı oturum açmamış.');

    // Profil kontrolü
    final isProfileComplete = await _authController.isProfileComplete();
    if (!isProfileComplete) {
      throw Exception('profile_incomplete');
    }

    // Abonelik kontrolü
    final hasActiveSubscription = await _authController.hasActiveSubscription();
    if (!hasActiveSubscription) {
      throw Exception('subscription_required');
    }
  }

  // Blog yazısı oluşturma
  Future<bool> createBlogPost({
    required String title,
    required String content,
    required String imageUrl,
  }) async {
    try {
      print('Blog yazısı oluşturma başladı');

      // Kullanıcı uygunluk kontrolü
      await checkUserEligibility();

      // İçerik uzunluğunu kontrol et
      if (content.length < 500) {
        throw Exception('İçerik en az 500 karakter olmalıdır.');
      }

      // Görsel URL'sini kontrol et
      if (imageUrl.isEmpty) {
        throw Exception('Görsel URL\'si zorunludur.');
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
        throw Exception(
            'Desteklenen görsel formatları: JPG, JPEG, PNG, GIF, WEBP');
      }

      print('İçerik kontrolleri tamamlandı, moderasyon başlıyor');

      // AI moderasyon kontrolü
      final bool isAppropriate =
          await _geminiService.checkBlogContentModeration(title, content);
      if (!isAppropriate) {
        throw Exception('İçerik uygunsuz bulundu ve reddedildi.');
      }

      print('Moderasyon tamamlandı, kullanıcı kontrolü yapılıyor');

      final user = _auth.currentUser;
      if (user == null) throw Exception('Kullanıcı oturum açmamış.');

      print('Kullanıcı doğrulandı, Firestore\'a yazılıyor');

      final docRef = _firestore.collection('blog_posts').doc();
      final blogPost = BlogPost(
        id: docRef.id,
        title: title,
        content: content,
        imageUrl: imageUrl,
        authorId: user.uid,
        authorName: user.displayName ?? 'Anonim',
        createdAt: DateTime.now(),
        isApproved: true,
      );

      await docRef.set(blogPost.toMap());
      print('Blog yazısı başarıyla oluşturuldu: ${docRef.id}');
      return true;
    } catch (e) {
      print('Blog yazısı oluşturma hatası: $e');
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
      print('Blog yazısı güncelleme başladı');

      // Kullanıcı uygunluk kontrolü
      await checkUserEligibility();

      // İçerik uzunluğunu kontrol et
      if (content.length < 500) {
        throw Exception('İçerik en az 500 karakter olmalıdır.');
      }

      // Görsel URL'sini kontrol et
      if (imageUrl.isEmpty) {
        throw Exception('Görsel URL\'si zorunludur.');
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
        throw Exception(
            'Desteklenen görsel formatları: JPG, JPEG, PNG, GIF, WEBP');
      }

      print('İçerik kontrolleri tamamlandı, moderasyon başlıyor');

      // AI moderasyon kontrolü
      final bool isAppropriate =
          await _geminiService.checkBlogContentModeration(title, content);
      if (!isAppropriate) {
        throw Exception('İçerik uygunsuz bulundu ve reddedildi.');
      }

      print('Moderasyon tamamlandı, kullanıcı kontrolü yapılıyor');

      final user = _auth.currentUser;
      if (user == null) throw Exception('Kullanıcı oturum açmamış.');

      print('Kullanıcı doğrulandı, Firestore\'a yazılıyor');

      await _firestore.collection('blog_posts').doc(postId).update({
        'title': title,
        'content': content,
        'imageUrl': imageUrl,
        'updatedAt': DateTime.now(),
      });

      print('Blog yazısı başarıyla güncellendi: $postId');
      return true;
    } catch (e) {
      print('Blog yazısı güncelleme hatası: $e');
      rethrow;
    }
  }

  // Tüm onaylanmış blog yazılarını getir
  Stream<List<BlogPost>> getApprovedBlogPosts() {
    print('Blog yazıları stream başlatıldı');

    return _firestore
        .collection('blog_posts')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      print(
          'Blog yazıları snapshot alındı. Doküman sayısı: ${snapshot.docs.length}');

      final posts = snapshot.docs
          .map((doc) {
            print('Doküman verisi: ${doc.data()}');
            try {
              final post = BlogPost.fromMap(doc.data());
              if (post.isApproved) {
                return post;
              }
              return null;
            } catch (e) {
              print('Blog post dönüştürme hatası: $e');
              return null;
            }
          })
          .where((post) => post != null)
          .cast<BlogPost>()
          .toList();

      print('Dönüştürülen blog yazısı sayısı: ${posts.length}');
      return posts;
    });
  }

  // Kullanıcının kendi blog yazılarını getir
  Stream<List<BlogPost>> getUserBlogPosts(String userId) {
    return _firestore
        .collection('blog_posts')
        .where('authorId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      final posts =
          snapshot.docs.map((doc) => BlogPost.fromMap(doc.data())).toList();

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
      print('Blog silme hatası: $e');
      rethrow;
    }
  }
}
