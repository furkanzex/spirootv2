import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:spirootv2/core/constant/my_color.dart';
import 'package:spirootv2/profile/user_controller.dart';
import 'package:spirootv2/core/service/gemini_service.dart';
import 'package:flutter/services.dart';
import 'package:easy_localization/easy_localization.dart' as easy;

class SpiritualChatController extends GetxController {
  final UserController _userController = Get.find<UserController>();
  final GeminiService _geminiService = Get.find<GeminiService>();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final RxList<SpiritualChatMessage> messages = <SpiritualChatMessage>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isThinking = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadMessages();
  }

  Future<void> _loadMessages() async {
    try {
      isLoading.value = true;
      final userId = _userController.userId.value;

      if (userId.isEmpty) {
        print('User ID is empty');
        return;
      }

      final chatDoc = await _firestore.collection('users').doc(userId).get();

      if (!chatDoc.exists || (chatDoc.data()?['messages'] ?? []).isEmpty) {
        // Hoşgeldin mesajını gönder
        final welcomeMessage = SpiritualChatMessage(
          text: easy.tr('spiritual_chat.welcome_message'),
          isMe: false,
          timestamp: DateTime.now(),
        );
        messages.add(welcomeMessage);
        await _saveMessage(welcomeMessage);
        return;
      }

      final List<dynamic> messagesList = chatDoc.data()?['messages'] ?? [];

      messages.value = messagesList
          .map((messageData) => SpiritualChatMessage(
                text: messageData['text'] ?? '',
                isMe: messageData['isMe'] ?? false,
                timestamp: (messageData['timestamp'] as Timestamp).toDate(),
              ))
          .toList();
    } catch (e) {
      print('Load messages error: $e');
      Get.snackbar(
        'Hata',
        'Mesajlar yüklenirken bir hata oluştu',
        backgroundColor: MyColor.errorColor,
        colorText: MyColor.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    try {
      final userId = _userController.userId.value;
      if (userId.isEmpty) {
        print('User ID is empty');
        return;
      }

      // Kullanıcı mesajını oluştur ve kaydet
      final userMessage = SpiritualChatMessage(
        text: text,
        isMe: true,
        timestamp: DateTime.now(),
      );
      messages.insert(0, userMessage);
      await _saveMessage(userMessage);

      // Titreşim ekle
      HapticFeedback.mediumImpact();

      // Düşünme durumunu başlat
      isThinking.value = true;

      // AI yanıtını al
      final response = await _geminiService.chatWithSpiritualGuide(text);

      // Titreşim ekle
      HapticFeedback.mediumImpact();

      // AI mesajını oluştur ve kaydet
      final aiMessage = SpiritualChatMessage(
        text: response,
        isMe: false,
        timestamp: DateTime.now(),
      );

      // Kısa bir gecikme ekle (daha doğal görünmesi için)
      await Future.delayed(const Duration(milliseconds: 500));

      // Düşünme durumunu bitir
      isThinking.value = false;

      messages.insert(0, aiMessage);
      await _saveMessage(aiMessage);
    } catch (e) {
      print('Send message error: $e');
      isThinking.value = false; // Hata durumunda düşünmeyi bitir

      final errorMessage = SpiritualChatMessage(
        text:
            "Üzgünüm, şu anda yanıt veremiyorum. Lütfen daha sonra tekrar deneyin.",
        isMe: false,
        timestamp: DateTime.now(),
      );

      messages.insert(0, errorMessage);
      await _saveMessage(errorMessage);

      Get.snackbar(
        'Hata',
        'Mesaj gönderilirken bir hata oluştu',
        backgroundColor: MyColor.errorColor,
        colorText: MyColor.white,
      );
    }
  }

  Future<void> _saveMessage(SpiritualChatMessage message) async {
    try {
      final userId = _userController.userId.value;

      if (userId.isEmpty) {
        print('User ID is empty');
        return;
      }

      // Mesajı map olarak kaydet
      final chatRef = _firestore.collection('users').doc(userId);

      // Transaction kullanarak güvenli bir şekilde güncelle
      await _firestore.runTransaction((transaction) async {
        final chatDoc = await transaction.get(chatRef);

        if (!chatDoc.exists) {
          // İlk mesaj ise yeni doküman oluştur
          transaction.set(chatRef, {
            'messages': [
              {
                'text': message.text,
                'isMe': message.isMe,
                'timestamp': message.timestamp,
                'messageId': DateTime.now().millisecondsSinceEpoch.toString(),
              }
            ],
            'lastUpdated': DateTime.now(),
          });
        } else {
          // Mevcut mesajları al ve yeni mesajı ekle
          List<dynamic> existingMessages = chatDoc.data()?['messages'] ?? [];
          existingMessages.insert(0, {
            'text': message.text,
            'isMe': message.isMe,
            'timestamp': message.timestamp,
            'messageId': DateTime.now().millisecondsSinceEpoch.toString(),
          });

          // Maksimum 100 mesaj sakla
          if (existingMessages.length > 100) {
            existingMessages = existingMessages.sublist(0, 100);
          }

          transaction.update(chatRef, {
            'messages': existingMessages,
            'lastUpdated': DateTime.now(),
          });
        }
      });
    } catch (e) {
      print('Save message error: $e');
      Get.snackbar(
        'Hata',
        'Mesaj kaydedilemedi',
        backgroundColor: MyColor.errorColor,
        colorText: MyColor.white,
      );
      throw Exception('Message could not be saved');
    }
  }

  Future<void> clearChat() async {
    try {
      final userId = _userController.userId.value;

      if (userId.isEmpty) {
        print('User ID is empty');
        return;
      }

      // Sadece mesajları sil, kullanıcı dökümanını değil
      await _firestore.collection('users').doc(userId).update({
        'messages': [], // Mesajlar listesini boşalt
        'lastUpdated': DateTime.now(),
      });

      // Local mesajları temizle
      messages.clear();

      // Chat oturumunu sıfırla
      _geminiService.resetChat();

      // Hoşgeldin mesajını tekrar gönder
      final welcomeMessage = SpiritualChatMessage(
        text: easy.tr('spiritual_chat.welcome_message'),
        isMe: false,
        timestamp: DateTime.now(),
      );
      messages.add(welcomeMessage);
      await _saveMessage(welcomeMessage);

      Get.snackbar(
        'Başarılı',
        'Sohbet geçmişi temizlendi',
        backgroundColor: MyColor.successColor,
        colorText: MyColor.white,
      );
    } catch (e) {
      print('Clear chat error: $e');
      Get.snackbar(
        'Hata',
        'Sohbet geçmişi temizlenirken bir hata oluştu',
        backgroundColor: MyColor.errorColor,
        colorText: MyColor.white,
      );
    }
  }
}

class SpiritualChatMessage {
  final String text;
  final bool isMe;
  final DateTime timestamp;

  SpiritualChatMessage({
    required this.text,
    required this.isMe,
    required this.timestamp,
  });

  factory SpiritualChatMessage.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return SpiritualChatMessage(
      text: data['text'] ?? '',
      isMe: data['isMe'] ?? false,
      timestamp: (data['timestamp'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'text': text,
      'isMe': isMe,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }
}
