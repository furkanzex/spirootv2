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

  Future<String> generateRetroReadings(
    DateTime startDate,
    DateTime endDate,
    String zodiacSign,
  ) async {
    try {
      final prompt = '''
      You are an experienced astrologer. Create retrograde readings for the following period:
      
      Date Range: ${DateFormat('MMMM dd').format(startDate)} - ${DateFormat('MMMM dd, yyyy').format(endDate)}
      Zodiac Sign: $zodiacSign
      
      Create a JSON response with current retrograde planets and their interpretations:
      {
        "retrogrades": {
          "activePlanets": ["planet_names"],
          "readings": {
            "planet_name": {
              "period": "retrograde_period",
              "impact": "brief_impact_description (max 150 chars)",
              "advice": "brief_advice (max 100 chars)"
            }
          }
        }
      }
      
      Instructions:
      1. Only include currently retrograde planets
      2. Keep descriptions concise and specific
      3. Write all text in Turkish
      4. Focus on practical impacts and advice
      ''';

      final response = await _textModel.generateContent([Content.text(prompt)]);
      String jsonStr = response.text ?? '';

      jsonStr = _cleanJsonResponse(jsonStr);
      return jsonStr;
    } catch (e) {
      print('Retrograde reading error: $e');
      return _createDefaultRetroJson();
    }
  }

  String _createDefaultRetroJson() {
    return '''
    {
      "retrogrades": {
        "activePlanets": [],
        "readings": {}
      }
    }
    ''';
  }

  Future<String> generateWeeklyNatalReading(
    DateTime birthDate,
    String birthTime,
    String birthPlace,
    String zodiacSign,
    String ascendant,
    String moonSign,
  ) async {
    try {
      final now = DateTime.now();
      final weekEnd = now.add(const Duration(days: 7));
      
      final prompt = '''
      Sen deneyimli bir astrologsun. Aşağıdaki bilgilere göre haftalık natal chart yorumu oluştur:
      
      Doğum Bilgileri:
      - Tarih: ${DateFormat('dd.MM.yyyy').format(birthDate)}
      - Saat: $birthTime
      - Yer: $birthPlace
      - Güneş Burcu: $zodiacSign
      - Yükselen: $ascendant
      - Ay Burcu: $moonSign
      
      Hafta: ${DateFormat('dd MMM').format(now)} - ${DateFormat('dd MMM').format(weekEnd)}
      
      Talimatlar:
      1. Şu anki transit gezegenlerin natal chart pozisyonlarıyla ilişkisini analiz et
      2. Odaklan:
         - Transit ve natal gezegenler arasındaki önemli açılar
         - Önemli ev aktivasyonları
         - Kişisel gelişim fırsatları
         - Zorluk veya gerilim alanları
         - Özellikle retro gezegenlerin etkileri
         - Dolunay/Yeniay etkileri
      3. Yorum uzunluğu:
         - Genel bakış: 400-600 karakter
         - Açılar: 300-400 karakter
         - Tavsiyeler: 200-300 karakter
      4. Türkçe yaz
      5. Kişisel ve natal charta özel olsun
      6. Pratik ve uygulanabilir tavsiyeler ver
      
      Bu formatta JSON yanıt oluştur:
      {
        "weeklyNatalReading": {
          "overview": "Haftalık genel analiz ve temalar",
          "aspects": "Önemli gezegensel açılar ve anlamları",
          "advice": "Pratik rehberlik ve öneriler"
        }
      }
      ''';

      final response = await _textModel.generateContent([Content.text(prompt)]);
      String jsonStr = response.text ?? '';

      jsonStr = _cleanJsonResponse(jsonStr);
      return jsonStr;
    } catch (e) {
      print('Weekly natal reading generation error: $e');
      return _createDefaultWeeklyNatalJson();
    }
  }

  String _createDefaultWeeklyNatalJson() {
    return '''
    {
      "weeklyNatalReading": {
        "overview": "Bu hafta natal haritanızdaki önemli gezegensel hareketler, kişisel gelişiminiz için fırsatlar sunuyor. Doğum haritanızdaki yerleşimler, özellikle kariyer ve ilişkiler alanında olumlu gelişmelere işaret ediyor.",
        "aspects": "Transit Jüpiter'in natal Güneşinizle yaptığı olumlu açı, kendini ifade etme ve yaratıcılık konularında destekleyici bir etki yaratıyor. Venüs-Mars kavuşumu, ilişkilerinizde yeni bir dönemin başlangıcına işaret ediyor.",
        "advice": "Bu hafta özellikle kişisel projelerinize odaklanın ve içsel sesinizi dinleyin. İlişkilerinizde açık iletişimi tercih edin ve yeni fırsatlara karşı açık olun."
      }
    }
    ''';
  }
}
