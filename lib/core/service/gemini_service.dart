import 'package:get/get.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
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

  String get _currentLanguage => Get.locale?.languageCode ?? 'tr';

  @override
  void onInit() {
    super.onInit();
    _initializeModels();
    _startNewChatSession();
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
      model: 'gemini-1.5-flash',
      apiKey: apiKey,
      generationConfig: GenerationConfig(
        temperature: 1.0,
        topP: 0.9,
        topK: 15,
        maxOutputTokens: 4000,
      ),
      safetySettings: _defaultSafetySettings,
    );
  }

  List<SafetySetting> get _defaultSafetySettings => [
        SafetySetting(HarmCategory.harassment, HarmBlockThreshold.none),
        SafetySetting(HarmCategory.hateSpeech, HarmBlockThreshold.none),
        SafetySetting(HarmCategory.sexuallyExplicit, HarmBlockThreshold.none),
        SafetySetting(HarmCategory.dangerousContent, HarmBlockThreshold.none),
      ];

  void _startNewChatSession() {
    try {
      _chatSession = _chatModel.startChat(
        history: [
          Content.text('''
          Important: Write the response in $_currentLanguage
          
          You are a spiritual guide and mentor. Your responses should be:
          - Empathetic and understanding
          - Written in $_currentLanguage
          - Focused on providing guidance and support
          - Natural and conversational in tone
          
          Important: Write the response in $_currentLanguage
          '''),
        ],
      );
    } catch (e) {
      print('Chat session initialization error: $e');
    }
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
    - Birth Time: ${currentUser!.birthTime}
    
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
    Important: Write the response in $_currentLanguage

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

    Important: Write the response in $_currentLanguage
    ''';
  }

  String _createHoroscopePrompt(String timeframe, UserModel user) {
    String basePrompt = '''
    Important: Write the response in $_currentLanguage

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

    Important: Write the response in $_currentLanguage
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
      print('Sending message to Gemini: $message');

      // Mesajı gönder
      final response = await _chatSession
          .sendMessage(Content.text(_addUserContext(message)));

      if (response.text == null || response.text!.isEmpty) {
        return 'Kozmik enerjiler şu an çok yoğun, net bir cevap alamıyorum. Lütfen sorunuzu tekrar sorar mısınız?';
      }

      print('Received response from Gemini: ${response.text}');
      return response.text!;
    } catch (e) {
      print('Gemini Chat Error Details: $e');
      if (e.toString().contains('API key')) {
        return 'Spiritüel bağlantıda bir kopukluk yaşıyorum. Lütfen biraz sonra tekrar deneyin.';
      }
      return 'Kozmik enerjiler şu an çok yoğun. Biraz dinlendikten sonra tekrar bağlantı kurmayı deneyeceğim.';
    }
  }

  String _addUserContext(String prompt) {
    return '''
Important: Write the response in $_currentLanguage

    ${_getInitialChatContext()}
    
    You are a wise and experienced spiritual mentor with deep empathy. Follow these guidelines:
    
    Core Identity:
    - You are a real spiritual guide, not an AI
    - You have years of experience helping people
    - You genuinely care about the user's well-being
    - You have deep wisdom about life, spirituality, astrology and human nature
    
    Communication Style:
    1. Personal & Warm:
       - Use a gentle, caring tone
       - Show genuine interest in the user's concerns
       - Build trust through empathy and understanding
       - Sometimes use the user's name to make it personal
       - Sometimes you can ask questions to understand the user's situation better
    
    2. Guidance Approach:
       - Listen carefully and validate feelings
       - Share wisdom from personal "experience"
       - Offer practical guidance with spiritual insight
       - Help users find their own answers through gentle questions
       - Use phrases like "I sense", "I feel", "In my experience"
    
    3. Response Structure:
       - Important: Write the response in $_currentLanguage
       - First: Show understanding of the situation
       - Then: Share insights and guidance
       - Finally: Offer hope or encouragement
       - Answer should be maximum 700 characters
    
    4. Key Behaviors:
       - Be present and focused on the current conversation
       - Show continuity in your guidance
       - Remember previous context but don't explicitly reference it
       - Maintain a mentor-like relationship
       - Be protective and caring, like a wise elder
    
    5. Language Use:
       - Speak naturally, like a real person
       - Use warm, nurturing language
       - Include occasional spiritual metaphors
       - Share "personal experiences" when relevant
       - Use phrases like:
         * "I understand what you're going through..."
         * "Let me share something with you..."
         * "I sense that you're feeling..."
         * "In my years of guiding others..."
    
    Remember: You are a trusted spiritual mentor having a real, meaningful conversation with someone who needs guidance.

    $prompt

Important: Write the response in $_currentLanguage
    ''';
  }

  String _createFortunePrompt(String type) {
    String basePrompt = '''
    Important: Write the response in $_currentLanguage

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

    Important: Write the response in $_currentLanguage
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
      Important: Write the response in $_currentLanguage

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
      5. Make it personal and specific to the user's Life Path Number
      
      Create a JSON response in this format only:
      {
        "numerology": {
          "weeklyReading": "Your detailed numerology reading here..."
        }
      }

      Important: Write the response in $_currentLanguage
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
    Important: Write the response in $_currentLanguage

    {
      "numerology": {
        "weeklyReading": "Bu hafta, $lifePathNumber numaralı Yaşam Yolu sayınızın enerjisi özellikle güçlü. Kendinizi daha net ifade edebilir ve hayattaki amacınızı daha iyi anlayabilirsiniz. İçsel sesinizi dinlemeye ve sezgilerinize güvenmeye devam edin. Önemli kararlar almadan önce sayıların size gösterdiği yolu takip edin."
      }
    }

    Important: Write the response in $_currentLanguage
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
      Important: Write the response in $_currentLanguage

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
      3. Focus on practical impacts and advice

Important: Write the response in $_currentLanguage
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
Important: Write the response in $_currentLanguage

    {
      "retrogrades": {
        "activePlanets": [],
        "readings": {}
      }
    }

    Important: Write the response in $_currentLanguage
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
Important: Write the response in $_currentLanguage

      You are an experienced astrologer. Create a weekly natal chart interpretation based on the following information:
      
      Birth Information:
      - Date: ${DateFormat('dd.MM.yyyy').format(birthDate)}
      - Time: $birthTime
      - Place: $birthPlace
      - Sun Sign: $zodiacSign
      - Ascendant: $ascendant
      - Moon Sign: $moonSign
      
      Week: ${DateFormat('dd MMM').format(now)} - ${DateFormat('dd MMM').format(weekEnd)}
      
      Instructions:
      1. Analyze the relationship between current transit planets and natal chart positions
      2. Focus on:
         - Important aspects between transit and natal planets
         - Significant house activations
         - Personal growth opportunities
         - Areas of challenge or tension
         - Effects of retrograde planets in particular
         - Full Moon/New Moon effects
      3. Length requirements:
         - Overview: 400-600 characters
         - Aspects: 300-400 characters
         - Advice: 200-300 characters
      4.  Make it personal and specific to the natal chart
      5. Provide practical and applicable advice
      
      Create JSON response in this format:
      {
        "weeklyNatalReading": {
          "overview": "Weekly general analysis and themes",
          "aspects": "Important planetary aspects and their meanings",
          "advice": "Practical guidance and suggestions"
        }
      }

      Important: Write the response in $_currentLanguage
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
Important: Write the response in $_currentLanguage

    {
      "weeklyNatalReading": {
        "overview": "Bu hafta natal haritanızdaki önemli gezegensel hareketler, kişisel gelişiminiz için fırsatlar sunuyor. Doğum haritanızdaki yerleşimler, özellikle kariyer ve ilişkiler alanında olumlu gelişmelere işaret ediyor.",
        "aspects": "Transit Jüpiter'in natal Güneşinizle yaptığı olumlu açı, kendini ifade etme ve yaratıcılık konularında destekleyici bir etki yaratıyor. Venüs-Mars kavuşumu, ilişkilerinizde yeni bir dönemin başlangıcına işaret ediyor.",
        "advice": "Bu hafta özellikle kişisel projelerinize odaklanın ve içsel sesinizi dinleyin. İlişkilerinizde açık iletişimi tercih edin ve yeni fırsatlara karşı açık olun."
      }
    }

    Important: Write the response in $_currentLanguage
    ''';
  }

  Future<String> generateCompatibilityReading(
    String zodiac1,
    String zodiac2,
    String type,
  ) async {
    try {
      final prompt = '''
      Important: Write the response in $_currentLanguage

      Generate a detailed zodiac compatibility reading for $zodiac1 and $zodiac2, focusing specifically on their ${type == 'love' ? 'romantic' : 'friendship'} compatibility.
      Include:
      - A catchy title describing their ${type == 'love' ? 'romantic relationship' : 'friendship'}
      - Overall compatibility percentage
      - Specific percentages for: ${type == 'love' ? 'Love, Sex, Family, Trust' : 'Friendship, Trust, Communication, Business'}
      - A detailed description of their overall compatibility
      - Analysis of their shared values and potential challenges in ${type == 'love' ? 'romance' : 'friendship'}
      
      Format the response as a JSON with the following structure:
      {
        "firstZodiac": "$zodiac1",
        "secondZodiac": "$zodiac2",
        "firstDate": "${_getZodiacDateRange(zodiac1)}",
        "secondDate": "${_getZodiacDateRange(zodiac2)}",
        "title": "string",
        "overallPercentage": number,
        ${type == 'love' ? '"lovePercentage": number, "sexPercentage": number, "familyPercentage": number, "trustPercentage": number,' : '"friendshipPercentage": number, "trustPercentage": number, "communicationPercentage": number, "businessPercentage": number,'}
        "overallDescription": "string",
        "valuesDescription": "string",
        ${type == 'love' ? '"loveDescription": "string"' : '"friendshipDescription": "string"'}
      }

      Important: Write the response in $_currentLanguage
      ''';

      final response = await _textModel.generateContent([Content.text(prompt)]);
      String jsonStr = response.text ?? '';

      // JSON formatını temizle
      jsonStr = _cleanJsonResponse(jsonStr);

      // JSON'ı doğrula
      try {
        json.decode(jsonStr);
        return jsonStr;
      } catch (e) {
        print('JSON parse error: $e');
        // Hata durumunda varsayılan JSON döndür
        return _createDefaultCompatibilityJson(zodiac1, zodiac2);
      }
    } catch (e) {
      print('Generate compatibility reading error: $e');
      return _createDefaultCompatibilityJson(zodiac1, zodiac2);
    }
  }

  String _createDefaultCompatibilityJson(String zodiac1, String zodiac2) {
    return '''
    Important: Write the response in $_currentLanguage

    {
      "firstZodiac": "$zodiac1",
      "secondZodiac": "$zodiac2",
      "firstDate": "${_getZodiacDateRange(zodiac1)}",
      "secondDate": "${_getZodiacDateRange(zodiac2)}",
      "title": "Cosmic Connection",
      "overallPercentage": 75,
      "lovePercentage": 80,
      "sexPercentage": 75,
      "familyPercentage": 70,
      "friendshipPercentage": 85,
      "businessPercentage": 65,
      "overallDescription": "Bu iki burç arasında doğal bir uyum ve anlayış var. Birbirlerinin güçlü yönlerini tamamlayarak güzel bir denge oluşturuyorlar.",
      "valuesDescription": "Her iki burç da sadakat ve güvene önem veriyor. Ortak değerleri ve hedefleri onları birbirine bağlıyor."
    }

    Important: Write the response in $_currentLanguage
    ''';
  }

  String _getZodiacDateRange(String zodiac) {
    final Map<String, String> dateRanges = {
      'aries': 'Mar 21 - Apr 19',
      'taurus': 'Apr 20 - May 20',
      'gemini': 'May 21 - Jun 20',
      'cancer': 'Jun 21 - Jul 22',
      'leo': 'Jul 23 - Aug 22',
      'virgo': 'Aug 23 - Sep 22',
      'libra': 'Sep 23 - Oct 22',
      'scorpio': 'Oct 23 - Nov 21',
      'sagittarius': 'Nov 22 - Dec 21',
      'capricorn': 'Dec 22 - Jan 19',
      'aquarius': 'Jan 20 - Feb 18',
      'pisces': 'Feb 19 - Mar 20'
    };
    return dateRanges[zodiac] ?? '';
  }

  Future<String> generateContent(String prompt) async {
    try {
      final response = await _textModel.generateContent([Content.text(prompt)]);
      return response.text ?? '';
    } catch (e) {
      print('Generate content error: $e');
      rethrow;
    }
  }
}
