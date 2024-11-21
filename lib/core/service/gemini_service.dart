import 'package:get/get.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:easy_localization/easy_localization.dart' as easy;
import 'package:intl/intl.dart';
import 'package:spirootv2/profile/user_controller.dart';
import 'package:spirootv2/profile/user_model.dart';

class GeminiService extends GetxService {
  static const String apiKey = "AIzaSyBxt1593xpDLULlo7KJE4gTjMvPb3JXVCg";

  // Farklı kullanım senaryoları için modeller
  late final GenerativeModel _chatModel;
  late final GenerativeModel _textModel;
  late final GenerativeModel _visionModel;

  // Chat oturumu
  late ChatSession _chatSession;

  // Kullanıcı bilgileri için getter
  UserModel? get currentUser => Get.put(UserController()).currentUser.value;
  String get currentDate => DateFormat('dd.MM.yyyy').format(DateTime.now());
  String get currentTime => DateFormat('HH:mm').format(DateTime.now());

  @override
  void onInit() {
    super.onInit();
    _initializeModels();
  }

  void _initializeModels() {
    // Chat Modeli (Ruhsal Danışman için)
    _chatModel = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: apiKey,
      generationConfig: GenerationConfig(
        temperature: 0.9,
        topP: 0.8,
        topK: 20,
        maxOutputTokens: 2000,
      ),
      safetySettings: _defaultSafetySettings,
    );

    // Text Modeli (Astroloji için)
    _textModel = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: apiKey,
      generationConfig: GenerationConfig(
        temperature: 1.9,
        topP: 0.92,
        topK: 10,
        maxOutputTokens: 2000,
      ),
      safetySettings: _defaultSafetySettings,
    );

    // Vision Modeli (Fal yorumları için)
    _visionModel = GenerativeModel(
      model: 'gemini-1.5-pro',
      apiKey: apiKey,
      generationConfig: GenerationConfig(
        temperature: 1.0,
        topP: 0.9,
        topK: 15,
        maxOutputTokens: 4000,
      ),
      safetySettings: _defaultSafetySettings,
    );

    _startNewChatSession();
  }

  List<SafetySetting> get _defaultSafetySettings => [
        SafetySetting(HarmCategory.harassment, HarmBlockThreshold.none),
        SafetySetting(HarmCategory.hateSpeech, HarmBlockThreshold.none),
        SafetySetting(HarmCategory.sexuallyExplicit, HarmBlockThreshold.none),
        SafetySetting(HarmCategory.dangerousContent, HarmBlockThreshold.none),
      ];

  void _startNewChatSession() {
    _chatSession = _chatModel.startChat(history: [
      Content.text(_getInitialChatContext()),
    ]);
  }

  String _getInitialChatContext() {
    if (currentUser == null) return '';

    return '''
    User Information:
    - Name: ${currentUser!.name}
    - Birth Date: ${DateFormat('dd.MM.yyyy').format(currentUser!.birthDate)}
    - Sun Sign: ${currentUser!.zodiacSign}
    - Ascendant: ${currentUser!.ascendant}
    - Moon Sign: ${currentUser!.moonSign}
    
    Date: $currentDate
    Time: $currentTime
    ''';
  }

  // ASTROLOGY METHODS
  Future<String> generateHoroscope(String timeframe, UserModel user) async {
    final prompt = _createHoroscopePrompt(timeframe, user);
    return _generateWithText(prompt);
  }

  Future<String> _generateWithText(String prompt) async {
    try {
      final content = [Content.text(_addUserContext(prompt))];
      final response = await _textModel.generateContent(content);
      return response.text ?? 'Yanıt oluşturulamadı.';
    } catch (e) {
      print('Gemini Text Hatası: $e');
      return 'İçerik oluşturulurken bir hata oluştu.';
    }
  }

  // FORTUNE TELLING METHODS
  Future<String> generateFortuneReading(
      List<String> imageUrls, String type) async {
    try {
      final contents = await _prepareImageContents(imageUrls);
      contents.insert(0, Content.text(_createFortunePrompt(type)));

      final response = await _visionModel.generateContent(contents);
      return response.text ?? 'Fal yorumu oluşturulamadı.';
    } catch (e) {
      print('Gemini Vision Hatası: $e');
      return 'Fal yorumu oluşturulurken bir hata oluştu.';
    }
  }

  Future<List<Content>> _prepareImageContents(List<String> imageUrls) async {
    // TODO: Implement image loading and conversion
    return [];
  }

  // SPIRITUAL CHAT METHODS
  Future<String> chatWithSpiritualGuide(String message) async {
    try {
      final response = await _chatSession
          .sendMessage(Content.text(_addUserContext(message)));
      return response.text ?? 'Yanıt alınamadı.';
    } catch (e) {
      print('Gemini Chat Hatası: $e');
      return 'Sohbet sırasında bir hata oluştu.';
    }
  }

  String _addUserContext(String prompt) {
    return '''
    ${_getInitialChatContext()}
    
    $prompt
    ''';
  }

  String _createHoroscopePrompt(String timeframe, UserModel user) {
    String basePrompt = '''
    You are an experienced astrologer. Write a horoscope reading for ${user.zodiacSign} sign for ${_getTimeframeText(timeframe)}.
    
    Personal Information:
    - Birth Date: ${DateFormat('dd.MM.yyyy').format(user.birthDate)}
    - Birth Time: ${user.birthTime}
    - Ascendant: ${user.ascendant}
    - Moon Sign: ${user.moonSign}
    
    The reading should include:
    - Love and Relationships
    - Career and Professional Life
    - Money and Financial Matters
    - General Overview and Advice
    ''';

    switch (timeframe) {
      case "astrology.horoscope.dates.today":
        return '''
        $basePrompt
        
        Write a reading for today.
        - Highlight the most important astrological aspects of the day
        - Provide specific advice for today
        - Indicate important hours to pay attention to
        - Explain lucky aspects and areas of caution for the day
        - Give specific advice for love life today
        - Highlight career and work matters to focus on today
        - Discuss financial opportunities and risks for today
        - Do not make it too long, maximum 500 characters
        ''';

      case "astrology.horoscope.dates.week":
        return '''
        $basePrompt
        
        Write a detailed reading for this week (${DateFormat('dd.MM.yyyy').format(DateTime.now())} - ${DateFormat('dd.MM.yyyy').format(DateTime.now().add(const Duration(days: 7)))}).
        - Highlight important astrological transits and aspects for the week
        - Provide information about weekly goals and opportunities
        - Indicate important and critical days of the week
        - Present weekly strategies and recommendations
        - Discuss potential developments in love life this week
        - Highlight important days for career and work
        - Share weekly expectations and advice for financial matters
        - Maximum 1500 characters
        ''';

      case "astrology.horoscope.dates.month":
        return '''
        $basePrompt
        
        Write a detailed reading for ${DateFormat('MMMM yyyy').format(DateTime.now())}.
        - Explain important astrological events and their effects
        - Provide information about long-term goals and opportunities
        - Highlight important dates and periods of the month
        - Present monthly strategies and recommendations
        - Emphasize areas requiring attention throughout the month
        - Discuss expected developments in love life this month
        - Identify critical periods for career and work
        - Share monthly plans and strategies for financial matters
        - Make it long and detailed
        ''';

      default:
        return basePrompt;
    }
  }

  String _createFortunePrompt(String type) {
    String basePrompt = '''
    You are an experienced fortune teller. Analyze the provided images in detail and interpret the ${type} reading.
    
    Personal Information:
    ${_getInitialChatContext()}
    
    The reading should include:
    - General Overview and First Impressions
    - Details About Love and Relationships
    - Signs for Career and Professional Life
    - Financial Matters and Opportunities
    - Predictions for the Near Future
    - Points of Attention
    - Special Advice and Guidance
    ''';

    switch (type.toLowerCase()) {
      case "coffee":
        return '''
        $basePrompt
        
        Special instructions for Coffee Reading:
        - Analyze the shapes inside the cup in detail
        - Interpret the signs on the saucer
        - Distinguish between near and distant future
        - Explain important symbols and their meanings
        ''';

      case "tarot":
        return '''
        $basePrompt
        
        Special instructions for Tarot Reading:
        - Explain the position and meaning of each card
        - Interpret relationships between cards
        - Tell the overall story and message
        - Highlight special warnings and advice
        ''';

      default:
        return basePrompt;
    }
  }

  String _getTimeframeText(String timeframe) {
    switch (timeframe) {
      case "astrology.horoscope.dates.today":
        return '''today (${DateFormat('MMMM dd, yyyy').format(DateTime.now())})''';
      case "astrology.horoscope.dates.week":
        final now = DateTime.now();
        final weekEnd = now.add(const Duration(days: 7));
        return '''this week (${DateFormat('MMMM dd').format(now)} - ${DateFormat('MMMM dd, yyyy').format(weekEnd)})''';
      case "astrology.horoscope.dates.month":
        return '''${DateFormat('MMMM yyyy').format(DateTime.now())}''';
      default:
        return "today";
    }
  }

  void resetChat() {
    _startNewChatSession();
  }
}
