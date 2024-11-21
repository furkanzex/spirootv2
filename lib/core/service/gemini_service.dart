import 'package:get/get.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:easy_localization/easy_localization.dart' as easy;
import 'package:intl/intl.dart';
import 'package:spirootv2/profile/user_controller.dart';
import 'package:spirootv2/profile/user_model.dart';
import 'dart:convert';

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
    try {
      final prompt = _createHoroscopePrompt(timeframe, user);
      final response = await _textModel.generateContent([Content.text(prompt)]);

      // Yanıtı JSON formatına dönüştür
      String jsonStr = response.text ?? '';

      // JSON formatını doğrula ve temizle
      jsonStr = jsonStr.trim();
      if (!jsonStr.startsWith('{')) {
        // Eğer JSON direkt başlamıyorsa, ilk { karakterinden itibaren al
        final startIndex = jsonStr.indexOf('{');
        if (startIndex != -1) {
          jsonStr = jsonStr.substring(startIndex);
        }
      }
      if (!jsonStr.endsWith('}')) {
        // Eğer JSON direkt bitmiyorsa, son } karakterine kadar al
        final endIndex = jsonStr.lastIndexOf('}') + 1;
        if (endIndex != 0) {
          jsonStr = jsonStr.substring(0, endIndex);
        }
      }

      // JSON formatını kontrol et
      try {
        json.decode(jsonStr); // Test için parse et
        return jsonStr;
      } catch (e) {
        print('JSON format hatası: $e');
        // Hata durumunda varsayılan bir JSON döndür
        return _createDefaultHoroscopeJson(user);
      }
    } catch (e) {
      print('Gemini horoscope error: $e');
      return _createDefaultHoroscopeJson(user);
    }
  }

  String _createDefaultHoroscopeJson(UserModel user) {
    return '''
    {
      "horoscope": {
        "zodiac": "${user.zodiacSign}",
        "timeframe": "today",
        "reading": {
          "overview": "Bugün yıldızlar sizin için olumlu enerjilerle dolu. Kendinizi güçlü ve motive hissedeceksiniz.",
          "love": {
            "prediction": "İlişkilerinizde açık iletişim önem kazanacak.",
            "advice": "Duygularınızı ifade etmekten çekinmeyin.",
            "percentage": 75
          },
          "career": {
            "prediction": "İş hayatınızda yeni fırsatlar görünüyor.",
            "advice": "İnisiyatif almaktan çekinmeyin.",
            "percentage": 80
          },
          "money": {
            "prediction": "Finansal konularda dikkatli olmanız gereken bir gün.",
            "advice": "Büyük harcamalardan kaçının.",
            "percentage": 65
          },
          "lucky": {
            "numbers": [3, 7, 9],
            "colors": ["mavi", "altın"],
            "days": ["Çarşamba", "Cuma"]
          }
        }
      }
    }
    ''';
  }

  String _createHoroscopePrompt(String timeframe, UserModel user) {
    String basePrompt = '''
    You are an experienced astrologer. Create a horoscope reading based on the following information:
    
    User Information:
    - Sun Sign: ${user.zodiacSign}
    - Ascendant: ${user.ascendant}
    - Moon Sign: ${user.moonSign}
    - Birth Date: ${DateFormat('dd.MM.yyyy').format(user.birthDate)}
    - Birth Time: ${user.birthTime}
    
    Timeframe: ${_getTimeframeText(timeframe)}
    
    Response Format:
    {
      "horoscope": {
        "zodiac": "${user.zodiacSign}",
        "timeframe": "${timeframe.replaceAll("astrology.horoscope.dates.", "")}",
        "reading": {
          "overview": "Main horoscope text",
          "love": {
            "prediction": "Love life prediction",
            "advice": "Love advice",
            "percentage": numeric_value
          },
          "career": {
            "prediction": "Career prediction",
            "advice": "Career advice",
            "percentage": numeric_value
          },
          "money": {
            "prediction": "Financial prediction",
            "advice": "Financial advice",
            "percentage": numeric_value
          },
          "lucky": {
            "numbers": [lucky_numbers],
            "colors": ["lucky_colors"],
            "days": ["lucky_days"] (only in week timeframe)
          }
        }
      }
    }
    ''';

    // Zaman dilimine göre özel talimatlar ekle
    switch (timeframe) {
      case "astrology.horoscope.dates.today":
        return '''
        $basePrompt
        
        Special Instructions for Daily Horoscope:
        1. Overview should be max 600 characters
        2. Focus on:
           - Specific planetary aspects for today
           - Immediate opportunities and challenges
           - Hour-by-hour guidance if relevant
           - Most influential planet of the day
        3. Keep predictions specific and actionable
        4. Include mood forecast and best times for activities
        5. Write all text in Turkish
        ''';

      case "astrology.horoscope.dates.week":
        return '''
        $basePrompt
        
        Special Instructions for Weekly Horoscope:
        1. Overview should be max 1500 characters
        2. Focus on:
           - Major planetary movements this week
           - Key dates for opportunities
           - Weekly energy flow and patterns
           - Important lunar phases
           - Significant planetary aspects
        3. Break down predictions by different life areas
        4. Include specific guidance for each major day
        5. Write all text in Turkish
        ''';

      case "astrology.horoscope.dates.month":
        return '''
        $basePrompt
        
        Special Instructions for Monthly Horoscope:
        1. Provide detailed and comprehensive analysis
        2. Focus on:
           - Major astrological events
           - Lunar cycles and their impact
           - Long-term trends and opportunities
           - Planetary retrogrades if any
           - Important conjunctions and aspects
           - Monthly themes and lessons
        3. Include:
           - Week-by-week breakdown
           - Key dates for important decisions
           - Areas of growth and challenge
           - Relationship dynamics
           - Career and financial trends
           - Personal development opportunities
        4. Write all text in Turkish
        ''';

      default:
        return basePrompt;
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

  // NUMEROLOGY METHODS
  Future<String> generateNumerologyReading(
      int lifePathNumber, UserModel user) async {
    try {
      final prompt = '''
      You are an experienced numerologist. Create a weekly numerology reading based on the following information:
      
      User Information:
      - Name: ${user.name}
      - Birth Date: ${DateFormat('dd.MM.yyyy').format(user.birthDate)}
      - Life Path Number: $lifePathNumber
      
      Week: ${DateFormat('MMMM dd').format(DateTime.now())} - ${DateFormat('MMMM dd, yyyy').format(DateTime.now().add(const Duration(days: 7)))}
      
      Instructions:
      1. Create a detailed weekly numerology reading focusing on Life Path Number $lifePathNumber
      2. Consider the current numerological cycles and vibrations
      3. Provide insights about personal growth, relationships, and life purpose
      4. Keep the reading between 500-1000 characters
      5. Write in Turkish
      6. Make it personal and specific to the user's Life Path Number
      
      Create a JSON response in this format only:
      {
        "numerology": {
          "weeklyReading": "Your detailed numerology reading here..."
        }
      }
      ''';

      final response = await _textModel.generateContent([Content.text(prompt)]);
      String jsonStr = response.text ?? '';

      // JSON formatını temizle ve kontrol et
      jsonStr = _cleanJsonResponse(jsonStr);
      return jsonStr;
    } catch (e) {
      print('Numerology reading error: $e');
      return _createDefaultNumerologyJson(lifePathNumber);
    }
  }

  String _createDefaultNumerologyJson(int lifePathNumber) {
    return '''
    {
      "numerology": {
        "weeklyReading": "Bu hafta, $lifePathNumber numaralı Yaşam Yolu sayınızın enerjisi özellikle güçlü. Kendinizi daha net ifade edebilir ve hayattaki amacınızı daha iyi anlayabilirsiniz. İçsel sesinizi dinlemeye ve sezgilerinize güvenmeye devam edin. Önemli kararlar almadan önce sayıların size gösterdiği yolu takip edin."
      }
    }
    ''';
  }

  String _cleanJsonResponse(String jsonStr) {
    // JSON formatını temizle ve kontrol et
    jsonStr = jsonStr.trim();
    if (!jsonStr.startsWith('{')) {
      // Eğer JSON direkt başlamıyorsa, ilk { karakterinden itibaren al
      final startIndex = jsonStr.indexOf('{');
      if (startIndex != -1) {
        jsonStr = jsonStr.substring(startIndex);
      }
    }
    if (!jsonStr.endsWith('}')) {
      // Eğer JSON direkt bitmiyorsa, son } karakterine kadar al
      final endIndex = jsonStr.lastIndexOf('}') + 1;
      if (endIndex != 0) {
        jsonStr = jsonStr.substring(0, endIndex);
      }
    }
    return jsonStr;
  }
}
