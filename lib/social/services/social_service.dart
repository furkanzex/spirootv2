import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:spirootv2/profile/user_controller.dart';
import 'package:spirootv2/astrology/astrology_controller.dart';
import 'package:spirootv2/profile/profile_onboarding.dart';
import 'package:spirootv2/paywall/paywall_screen.dart';
import '../models/post_model.dart';
import '../models/comment_model.dart';
import '../models/event_model.dart';

class SocialService {
  static final _firestore = FirebaseFirestore.instance;
  static final _auth = FirebaseAuth.instance;

  static Future<bool> _checkUserEligibility() async {
    final userController = Get.find<UserController>();
    final astrologyController = Get.find<AstrologyController>();

    if (userController.userName.isEmpty) {
      Get.to(() => const ProfileOnboarding());
      return false;
    }

    if (!astrologyController.isSubscribed.value) {
      Get.to(() => const PaywallScreen());
      return false;
    }

    return true;
  }

  // Post işlemleri
  static Stream<List<Post>> getPosts() {
    return _firestore
        .collection('posts')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) =>
                Post.fromMap(doc.data() as Map<String, dynamic>, doc.id))
            .toList());
  }

  static Future<void> createPost(String content, String creatorName) async {
    final post = Post(
      id: '',
      content: content,
      creatorName: creatorName,
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
    return _firestore.collection('events').orderBy('eventDate').snapshots().map(
        (snapshot) => snapshot.docs
            .map((doc) =>
                Event.fromMap(doc.data() as Map<String, dynamic>, doc.id))
            .toList());
  }

  static Future<void> createEvent({
    required String title,
    required String description,
    required String location,
    required DateTime eventDate,
    required String imageUrl,
    required String creatorName,
  }) async {
    final event = Event(
      id: '',
      title: title,
      description: description,
      location: location,
      imageUrl: imageUrl,
      creatorName: creatorName,
      eventDate: eventDate,
      createdAt: DateTime.now(),
      participants: [],
      reports: [],
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
            .map((doc) =>
                Comment.fromMap(doc.data() as Map<String, dynamic>, doc.id))
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
            .map((doc) =>
                Comment.fromMap(doc.data() as Map<String, dynamic>, doc.id))
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

  static Stream<List<Post>> getUserPosts(String creatorName) {
    return _firestore
        .collection('posts')
        .where('creatorName', isEqualTo: creatorName)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) =>
                Post.fromMap(doc.data() as Map<String, dynamic>, doc.id))
            .toList());
  }

  static Stream<List<Event>> getUserEvents(String creatorName) {
    return _firestore
        .collection('events')
        .where('creatorName', isEqualTo: creatorName)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) =>
                Event.fromMap(doc.data() as Map<String, dynamic>, doc.id))
            .toList());
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
}
