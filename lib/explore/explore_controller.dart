import 'dart:async';
import 'dart:math';
import 'package:get/get.dart';
import 'package:spirootv2/core/constant/my_color.dart';
import 'package:spirootv2/chat/chat_screen.dart';
import 'package:easy_localization/easy_localization.dart' as easy;

class ExploreController extends GetxController {
  // Aktif eşleşme durumu
  final RxBool isSearching = false.obs;
  final RxBool isMatched = false.obs;
  final RxString currentChatId = ''.obs;

  // Geçici chat verilerini tutmak için
  final RxList<ChatMessage> currentChatMessages = <ChatMessage>[].obs;
  final Rx<TempMatch?> currentMatch = Rx<TempMatch?>(null);

  @override
  void onInit() {
    super.onInit();
    ever(isMatched, (matched) {
      if (!matched) {
        _clearCurrentChat();
      }
    });
  }

  Future<void> startMatching() async {
    try {
      if (isMatched.value) return;

      isSearching.value = true;

      // Simüle edilmiş eşleşme için zamanlayıcı
      Timer(const Duration(seconds: 3), () {
        // Eğer arama iptal edilmemişse eşleşme oluştur
        if (isSearching.value) {
          // Simüle edilmiş eşleşme
          final matchScore = _calculateSimulatedMatchScore();
          final chatId = 'temp_${DateTime.now().millisecondsSinceEpoch}';

          // Geçici eşleşme oluştur
          currentMatch.value = TempMatch(
            chatId: chatId,
            otherUserZodiac: _getRandomZodiac(),
            matchScore: matchScore,
            startTime: DateTime.now(),
          );

          currentChatId.value = chatId;
          isMatched.value = true;
          isSearching.value = false;

          // Chat ekranına yönlendir
          Get.to(() => ChatScreen(chatId: chatId));
        }
      });
    } catch (e) {
      isSearching.value = false;
      Get.snackbar(
        easy.tr('errors.error'),
        easy.tr('explore.error_occurred'),
        backgroundColor: MyColor.errorColor,
        colorText: MyColor.white,
      );
    }
  }

  void sendMessage(String message) {
    if (!isMatched.value) return;

    final newMessage = ChatMessage(
      text: message,
      isMe: true,
      timestamp: DateTime.now(),
    );

    currentChatMessages.add(newMessage);

    // Simüle edilmiş yanıt
    Future.delayed(const Duration(seconds: 1), () {
      final response = ChatMessage(
        text: _generateSimulatedResponse(),
        isMe: false,
        timestamp: DateTime.now(),
      );
      currentChatMessages.add(response);
    });
  }

  void endChat() {
    isMatched.value = false;
    Get.back();
  }

  void _clearCurrentChat() {
    currentChatMessages.clear();
    currentMatch.value = null;
    currentChatId.value = '';
  }

  double _calculateSimulatedMatchScore() {
    return 70.0 + Random().nextDouble() * 30.0; // 70-100 arası rastgele değer
  }

  String _getRandomZodiac() {
    final zodiacSigns = [
      'aries',
      'taurus',
      'gemini',
      'cancer',
      'leo',
      'virgo',
      'libra',
      'scorpio',
      'sagittarius',
      'capricorn',
      'aquarius',
      'pisces'
    ];
    return zodiacSigns[Random().nextInt(zodiacSigns.length)];
  }

  String _generateSimulatedResponse() {
    final responses = [
      "Evet, burçlarımız gerçekten çok uyumlu!",
      "Bu konuda ne düşünüyorsun?",
      "İlginç bir bakış açısı...",
      "Kesinlikle katılıyorum.",
      "Astrolojiye olan ilgin etkileyici.",
    ];
    return responses[Random().nextInt(responses.length)];
  }

  void cancelSearch() {
    try {
      isSearching.value = false;
      Get.back(); // Eğer dialog açıksa kapat
      Get.snackbar(
        easy.tr('explore.canceled'),
        easy.tr('explore.search_canceled'),
        backgroundColor: MyColor.primaryColor.withOpacity(0.1),
        colorText: MyColor.white,
      );
      // ignore: empty_catches
    } catch (e) {}
  }

  @override
  void onClose() {
    _clearCurrentChat();
    super.onClose();
  }
}

// Geçici eşleşme modeli
class TempMatch {
  final String chatId;
  final String otherUserZodiac;
  final double matchScore;
  final DateTime startTime;

  TempMatch({
    required this.chatId,
    required this.otherUserZodiac,
    required this.matchScore,
    required this.startTime,
  });
}

// Chat mesaj modeli
class ChatMessage {
  final String text;
  final bool isMe;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isMe,
    required this.timestamp,
  });
}
