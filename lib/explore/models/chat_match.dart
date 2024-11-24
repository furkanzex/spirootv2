import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:spirootv2/profile/user_controller.dart';

class ChatMatch {
  final String chatId;
  final String otherUserId;
  final String otherUserZodiac;
  final double matchScore;
  final DateTime createdAt;
  final String? lastMessage;
  final DateTime? lastMessageTime;

  ChatMatch({
    required this.chatId,
    required this.otherUserId,
    required this.otherUserZodiac,
    required this.matchScore,
    required this.createdAt,
    this.lastMessage,
    this.lastMessageTime,
  });

  factory ChatMatch.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final currentUserId = Get.find<UserController>().userId.value;

    final otherUserId =
        (data['participants'] as List).firstWhere((id) => id != currentUserId);

    return ChatMatch(
      chatId: doc.id,
      otherUserId: otherUserId,
      otherUserZodiac: data['zodiacSigns'][otherUserId],
      matchScore: data['matchScore'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      lastMessage: data['lastMessage'],
      lastMessageTime: data['lastMessageTime'] != null
          ? (data['lastMessageTime'] as Timestamp).toDate()
          : null,
    );
  }
}
