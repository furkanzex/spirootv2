import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:spirootv2/core/service/revenuecat_services.dart';
import 'package:spirootv2/profile/user_controller.dart';
import 'package:spirootv2/profile/profile_onboarding.dart';
import 'package:spirootv2/paywall/paywall_screen.dart';
import '../models/post_model.dart';
import '../models/comment_model.dart';
import '../models/event_model.dart';
import 'package:easy_localization/easy_localization.dart' as easy;
import 'package:spirootv2/core/service/translation_service.dart';

class SocialService {
  static final _firestore = FirebaseFirestore.instance;
  static final _auth = FirebaseAuth.instance;

  static Future<bool> _checkUserEligibility() async {
    final userController = Get.find<UserController>();

    if (userController.userName.isEmpty) {
      Get.to(() => const ProfileOnboarding());
      return false;
    }

    final isSubscribed = await PurchaseAPI.checkSubscriptionStatus();
    if (!isSubscribed) {
      paywall();
      return false;
    }

    return true;
  }

  // Post işlemleri
  static Stream<List<Post>> getPosts() {
    final _translationService = Get.find<TranslationService>();
    return _firestore
        .collection('posts')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .asyncMap((snapshot) async {
      if (snapshot.docs.isEmpty) return [];

      // Tüm içerikleri tek bir listede topla
      final contents = snapshot.docs
          .map((doc) => Post.fromMap(doc.data(), doc.id).content)
          .toList();

      // Toplu çeviri yap
      final translatedContents = await Future.wait(contents.map(
          (content) => _translationService.translateToAppLanguage(content)));

      final posts = <Post>[];
      for (var i = 0; i < snapshot.docs.length; i++) {
        try {
          final post =
              Post.fromMap(snapshot.docs[i].data(), snapshot.docs[i].id);
          posts.add(Post(
            id: post.id,
            content: translatedContents[i],
            creatorName: post.creatorName,
            creatorId: post.creatorId,
            createdAt: post.createdAt,
            likes: post.likes,
            commentCount: post.commentCount,
            reports: post.reports,
          ));
        } catch (e) {
          print('Post çevirme hatası: $e');
        }
      }

      return posts;
    });
  }

  static Future<void> createPost(String content, String creatorName) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    final post = Post(
      id: '',
      content: content,
      creatorName: creatorName,
      creatorId: userId,
      createdAt: DateTime.now(),
      likes: [],
      commentCount: 0,
      reports: [],
    );

    await _firestore.collection('posts').add(post.toMap());
  }

  static Future<void> likePost(String postId) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    final postRef = _firestore.collection('posts').doc(postId);
    final post = await postRef.get();
    final likes = List<String>.from(post.data()?['likes'] ?? []);

    if (likes.contains(userId)) {
      likes.remove(userId);
    } else {
      likes.add(userId);
    }

    await postRef.update({'likes': likes});
  }

  static Future<void> reportPost(String postId) async {
    if (!await _checkUserEligibility()) return;

    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    final postRef = _firestore.collection('posts').doc(postId);
    final post = await postRef.get();
    final reports = List<String>.from(post.data()?['reports'] ?? []);

    if (!reports.contains(userId)) {
      reports.add(userId);
      await postRef.update({'reports': reports});
    }
  }

  static Future<void> unreportPost(String postId) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    final postRef = _firestore.collection('posts').doc(postId);
    final post = await postRef.get();
    final reports = List<String>.from(post.data()?['reports'] ?? []);

    if (reports.contains(userId)) {
      reports.remove(userId);
      await postRef.update({'reports': reports});
    }
  }

  static Future<void> deletePost(String postId) async {
    await _firestore.collection('posts').doc(postId).delete();
  }

  // Event işlemleri
  static Stream<List<Event>> getEvents() {
    final _translationService = Get.find<TranslationService>();
    return _firestore
        .collection('events')
        .orderBy('eventDate')
        .snapshots()
        .asyncMap((snapshot) async {
      if (snapshot.docs.isEmpty) return [];

      final events = snapshot.docs
          .map((doc) => Event.fromMap(doc.data(), doc.id))
          .toList();

      // Tüm metinleri topla
      final titles = events.map((e) => e.title).toList();
      final descriptions = events.map((e) => e.description).toList();
      final locations = events.map((e) => e.location).toList();

      // Toplu çeviri yap
      final translatedTitles = await Future.wait(titles
          .map((title) => _translationService.translateToAppLanguage(title)));
      final translatedDescriptions = await Future.wait(descriptions
          .map((desc) => _translationService.translateToAppLanguage(desc)));
      final translatedLocations = await Future.wait(locations
          .map((loc) => _translationService.translateToAppLanguage(loc)));

      return List.generate(events.length, (i) {
        try {
          return Event(
            id: events[i].id,
            title: translatedTitles[i],
            description: translatedDescriptions[i],
            location: translatedLocations[i],
            imageUrl: events[i].imageUrl,
            creatorName: events[i].creatorName,
            creatorId: events[i].creatorId,
            eventDate: events[i].eventDate,
            createdAt: events[i].createdAt,
            participants: events[i].participants,
            reports: events[i].reports,
            commentCount: events[i].commentCount,
          );
        } catch (e) {
          print('Etkinlik çevirme hatası: $e');
          return events[i];
        }
      });
    });
  }

  static Future<void> createEvent({
    required String title,
    required String description,
    required String location,
    required DateTime eventDate,
    required String imageUrl,
    required String creatorName,
  }) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    final event = Event(
      id: '',
      title: title,
      description: description,
      location: location,
      imageUrl: imageUrl,
      creatorName: creatorName,
      creatorId: userId,
      eventDate: eventDate,
      createdAt: DateTime.now(),
      participants: [],
      reports: [],
      commentCount: 0,
    );

    await _firestore.collection('events').add(event.toMap());
  }

  static Future<void> joinEvent(String eventId) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    final eventRef = _firestore.collection('events').doc(eventId);
    final event = await eventRef.get();
    final participants = List<String>.from(event.data()?['participants'] ?? []);

    if (participants.contains(userId)) {
      participants.remove(userId);
    } else {
      participants.add(userId);
    }

    await eventRef.update({'participants': participants});
  }

  static Future<void> reportEvent(String eventId) async {
    if (!await _checkUserEligibility()) return;

    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    final eventRef = _firestore.collection('events').doc(eventId);
    final event = await eventRef.get();
    final reports = List<String>.from(event.data()?['reports'] ?? []);

    if (!reports.contains(userId)) {
      reports.add(userId);
      await eventRef.update({'reports': reports});
    }
  }

  static Future<void> unreportEvent(String eventId) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    final eventRef = _firestore.collection('events').doc(eventId);
    final event = await eventRef.get();
    final reports = List<String>.from(event.data()?['reports'] ?? []);

    if (reports.contains(userId)) {
      reports.remove(userId);
      await eventRef.update({'reports': reports});
    }
  }

  static Future<void> deleteEvent(String eventId) async {
    await _firestore.collection('events').doc(eventId).delete();
  }

  // Comment işlemleri
  static Stream<List<Comment>> getComments(String postId) {
    return _firestore
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Comment.fromMap(doc.data(), doc.id))
            .toList());
  }

  static Future<void> addComment(
      String postId, String content, String creatorName) async {
    if (!await _checkUserEligibility()) return;

    final comment = Comment(
      id: '',
      content: content,
      creatorName: creatorName,
      createdAt: DateTime.now(),
      reports: [],
    );

    final batch = _firestore.batch();
    final postRef = _firestore.collection('posts').doc(postId);
    final commentRef = postRef.collection('comments').doc();

    batch.set(commentRef, comment.toMap());
    batch.update(postRef, {
      'commentCount': FieldValue.increment(1),
    });

    await batch.commit();
  }

  static Future<void> reportComment(String postId, String commentId) async {
    if (!await _checkUserEligibility()) return;

    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    final commentRef = _firestore
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .doc(commentId);
    final comment = await commentRef.get();
    final reports = List<String>.from(comment.data()?['reports'] ?? []);

    if (!reports.contains(userId)) {
      reports.add(userId);
      await commentRef.update({'reports': reports});
    }
  }

  static Future<void> unreportComment(String postId, String commentId) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    final commentRef = _firestore
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .doc(commentId);
    final comment = await commentRef.get();
    final reports = List<String>.from(comment.data()?['reports'] ?? []);

    if (reports.contains(userId)) {
      reports.remove(userId);
      await commentRef.update({'reports': reports});
    }
  }

  static Future<void> deleteComment(String postId, String commentId) async {
    final batch = _firestore.batch();
    final postRef = _firestore.collection('posts').doc(postId);
    final commentRef = postRef.collection('comments').doc(commentId);

    batch.delete(commentRef);
    batch.update(postRef, {
      'commentCount': FieldValue.increment(-1),
    });

    await batch.commit();
  }

  static Stream<List<Comment>> getEventComments(String eventId) {
    return _firestore
        .collection('events')
        .doc(eventId)
        .collection('comments')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Comment.fromMap(doc.data(), doc.id))
            .toList());
  }

  static Stream<List<Event>> getFilteredEvents({
    DateTime? startDate,
    DateTime? endDate,
    String? location,
    bool? onlyUpcoming,
  }) {
    Query query = _firestore.collection('events');

    if (startDate != null) {
      query = query.where('eventDate',
          isGreaterThanOrEqualTo: startDate.toIso8601String());
    }

    if (endDate != null) {
      query = query.where('eventDate',
          isLessThanOrEqualTo: endDate.toIso8601String());
    }

    if (location != null && location.isNotEmpty) {
      query = query.where('location', isEqualTo: location);
    }

    if (onlyUpcoming == true) {
      query = query.where('eventDate',
          isGreaterThanOrEqualTo: DateTime.now().toIso8601String());
    }

    return query.orderBy('eventDate').snapshots().map((snapshot) => snapshot
        .docs
        .map((doc) => Event.fromMap(doc.data() as Map<String, dynamic>, doc.id))
        .toList());
  }

  static Stream<List<Post>> getUserPosts(String userId) {
    final _translationService = Get.find<TranslationService>();
    return _firestore
        .collection('posts')
        .where('creatorId', isEqualTo: _auth.currentUser?.uid)
        .snapshots()
        .asyncMap((snapshot) async {
      if (snapshot.docs.isEmpty) return [];

      // Tüm içerikleri tek bir listede topla
      final contents = snapshot.docs
          .map((doc) => Post.fromMap(doc.data(), doc.id).content)
          .toList();

      // Toplu çeviri yap
      final translatedContents = await Future.wait(contents.map(
          (content) => _translationService.translateToAppLanguage(content)));

      final posts = <Post>[];
      for (var i = 0; i < snapshot.docs.length; i++) {
        try {
          final post =
              Post.fromMap(snapshot.docs[i].data(), snapshot.docs[i].id);
          posts.add(Post(
            id: post.id,
            content: translatedContents[i],
            creatorName: post.creatorName,
            creatorId: post.creatorId,
            createdAt: post.createdAt,
            likes: post.likes,
            commentCount: post.commentCount,
            reports: post.reports,
          ));
        } catch (e) {
          print('Post çevirme hatası: $e');
        }
      }

      posts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return posts;
    });
  }

  static Stream<List<Event>> getUserEvents(String userId) {
    final _translationService = Get.find<TranslationService>();
    return _firestore
        .collection('events')
        .where('creatorId', isEqualTo: _auth.currentUser?.uid)
        .snapshots()
        .asyncMap((snapshot) async {
      if (snapshot.docs.isEmpty) return [];

      final events = snapshot.docs
          .map((doc) => Event.fromMap(doc.data(), doc.id))
          .toList();

      // Tüm metinleri topla
      final titles = events.map((e) => e.title).toList();
      final descriptions = events.map((e) => e.description).toList();
      final locations = events.map((e) => e.location).toList();

      // Toplu çeviri yap
      final translatedTitles = await Future.wait(titles
          .map((title) => _translationService.translateToAppLanguage(title)));
      final translatedDescriptions = await Future.wait(descriptions
          .map((desc) => _translationService.translateToAppLanguage(desc)));
      final translatedLocations = await Future.wait(locations
          .map((loc) => _translationService.translateToAppLanguage(loc)));

      final translatedEvents = List.generate(events.length, (i) {
        try {
          return Event(
            id: events[i].id,
            title: translatedTitles[i],
            description: translatedDescriptions[i],
            location: translatedLocations[i],
            imageUrl: events[i].imageUrl,
            creatorName: events[i].creatorName,
            creatorId: events[i].creatorId,
            eventDate: events[i].eventDate,
            createdAt: events[i].createdAt,
            participants: events[i].participants,
            reports: events[i].reports,
            commentCount: events[i].commentCount,
          );
        } catch (e) {
          print('Etkinlik çevirme hatası: $e');
          return events[i];
        }
      });

      translatedEvents.sort((a, b) => a.eventDate.compareTo(b.eventDate));
      return translatedEvents;
    });
  }

  static Future<void> addEventComment(
      String eventId, String content, String creatorName) async {
    if (!await _checkUserEligibility()) return;

    final comment = Comment(
      id: '',
      content: content,
      creatorName: creatorName,
      createdAt: DateTime.now(),
      reports: [],
    );

    final batch = _firestore.batch();
    final eventRef = _firestore.collection('events').doc(eventId);
    final commentRef = eventRef.collection('comments').doc();

    batch.set(commentRef, comment.toMap());
    batch.update(eventRef, {
      'commentCount': FieldValue.increment(1),
    });

    await batch.commit();
  }

  static Future<void> reportEventComment(
      String eventId, String commentId) async {
    if (!await _checkUserEligibility()) return;

    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    final commentRef = _firestore
        .collection('events')
        .doc(eventId)
        .collection('comments')
        .doc(commentId);
    final comment = await commentRef.get();
    final reports = List<String>.from(comment.data()?['reports'] ?? []);

    if (!reports.contains(userId)) {
      reports.add(userId);
      await commentRef.update({'reports': reports});
    }
  }

  Future<void> checkSubscriptionStatus() async {
    try {
      final isSubscribed = await PurchaseAPI.checkSubscriptionStatus();
      if (!isSubscribed) {
        throw Exception(easy.tr('blog.subscription_required'));
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
