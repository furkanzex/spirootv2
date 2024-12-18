import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:spirootv2/core/constant/my_color.dart';
import 'package:spirootv2/profile/user_controller.dart';
import 'package:spirootv2/core/service/gemini_service.dart';
import 'package:flutter/services.dart';
import 'package:easy_localization/easy_localization.dart' as easy;
import 'package:spirootv2/astrology/astrology_controller.dart';
import 'package:spirootv2/paywall/paywall_screen.dart';

class SpiritualChatController extends GetxController {
  final UserController _userController = Get.find<UserController>();
  final GeminiService _geminiService = Get.find<GeminiService>();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AstrologyController _astrologyController =
      Get.find<AstrologyController>();

  final RxList<SpiritualChatMessage> messages = <SpiritualChatMessage>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isThinking = false.obs;
  final RxBool isInitialized = false.obs;

  @override
  void onInit() {
    super.onInit();
    _initializeController();
  }

  Future<void> _initializeController() async {
    try {
      // UserController'ın hazır olmasını bekle
      Get.find<UserController>().initialized;

      // Kullanıcı ID'sini dinle
      ever(_userController.userId, (String userId) {
        if (userId.isNotEmpty && !isInitialized.value) {
          isInitialized.value = true;
          _loadMessages();
        }
      });

      // Eğer kullanıcı ID'si zaten varsa, hemen yükle
      if (_userController.userId.value.isNotEmpty) {
        isInitialized.value = true;
        await _loadMessages();
      } else {
        // Kullanıcı ID'si yoksa, bekleme moduna geç
        await _waitForUser();
      }
    } catch (e) {
      _handleError(easy.tr("spiritual_chat.error_occurred"));
    }
  }

  Future<void> _waitForUser() async {
    int attempts = 0;
    const maxAttempts = 10; // Deneme sayısını artırdık
    const retryDelay = Duration(seconds: 2);

    while (attempts < maxAttempts && !isInitialized.value) {
      try {
        if (_userController.userId.value.isNotEmpty) {
          isInitialized.value = true;
          await _loadMessages();
          return;
        }
        await Future.delayed(retryDelay);
        attempts++;
        // ignore: empty_catches
      } catch (e) {}
    }

    if (!isInitialized.value) {
      _handleError(easy.tr("spiritual_chat.error_occurred_chat"));
    }
  }

  void _handleError(String message) {
    Get.snackbar(
      easy.tr("errors.error"),
      message,
      backgroundColor: MyColor.errorColor,
      colorText: MyColor.white,
      duration: const Duration(seconds: 5),
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  Future<void> _loadMessages() async {
    try {
      isLoading.value = true;
      final userId = _userController.userId.value;

      if (userId.isEmpty) {
        // Kullanıcı ID'si boşsa, kullanıcının yüklenmesini bekle
        await _waitForUser();
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
      } else {
        final List<dynamic> messagesList = chatDoc.data()?['messages'] ?? [];
        messages.value = messagesList
            .map((messageData) => SpiritualChatMessage(
                  text: messageData['text'] ?? '',
                  isMe: messageData['isMe'] ?? false,
                  timestamp: (messageData['timestamp'] as Timestamp).toDate(),
                ))
            .toList();
      }
    } catch (e) {
      Get.snackbar(
        easy.tr("errors.error"),
        easy.tr("spiritual_chat.error_occurred_messages"),
        backgroundColor: MyColor.errorColor,
        colorText: MyColor.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> sendMessage(String text) async {
    if (!isInitialized.value) {
      _handleError(easy.tr("spiritual_chat.error_chat_has_not_started"));
      return;
    }

    if (text.trim().isEmpty) return;

    // Abonelik kontrolü
    if (!_astrologyController.isSubscribed.value) {
      paywall();
      return;
    }

    try {
      final userId = _userController.userId.value;
      if (userId.isEmpty) {
        _handleError(easy.tr("spiritual_chat.error_chat_no_session"));
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
      _handleError(easy.tr("spiritual_chat.error_occurred_send_message"));
    }
  }

  Future<void> _saveMessage(SpiritualChatMessage message) async {
    try {
      final userId = _userController.userId.value;

      if (userId.isEmpty) {
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
      Get.snackbar(
        easy.tr("errors.error"),
        easy.tr("spiritual_chat.error_occurred_save_message"),
        backgroundColor: MyColor.errorColor,
        colorText: MyColor.white,
      );
    }
  }

  Future<void> clearChat() async {
    try {
      final userId = _userController.userId.value;

      if (userId.isEmpty) {
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
        easy.tr("common.success"),
        easy.tr("spiritual_chat.success_clear_chat"),
        backgroundColor: MyColor.successColor,
        colorText: MyColor.white,
      );
    } catch (e) {
      Get.snackbar(
        easy.tr("common.error"),
        easy.tr("spiritual_chat.error_occurred_clear_chat"),
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
