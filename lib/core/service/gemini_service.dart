import 'package:get/get.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:intl/intl.dart';
import 'package:spirootv2/fortune/tarot/tarot_card_model.dart';
import 'package:spirootv2/profile/user_controller.dart';
import 'package:spirootv2/profile/user_model.dart';
import 'dart:convert';
import 'dart:math';

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
  Future<String> generateHoroscope(String timeframe, UserModel user,
      [String? customPrompt]) async {
    try {
      final prompt = '''
      Important: Write the response in $_currentLanguage

      You are an experienced astrologer. Create a horoscope reading based on the following information:
      
      User Information:
      - Sun Sign: ${user.zodiacSign}
      - Ascendant: ${user.ascendant}
      - Moon Sign: ${user.moonSign}
      - Birth Date: ${DateFormat('dd.MM.yyyy').format(user.birthDate)}
      - Birth Time: ${user.birthTime}
      
      Timeframe: ${_getTimeframeText(timeframe)}
      
      ${customPrompt ?? "Create a detailed horoscope reading"}
      
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
              "days": ["lucky_days"]
            }
          }
        }
      }

      Important: Write the response in $_currentLanguage
      ''';

      final response = await _textModel.generateContent([Content.text(prompt)]);
      return response.text ?? _createDefaultHoroscopeJson(user);
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

    You are an experienced fortune teller. Analyze the provided images in detail and interpret the $type reading.
    
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
        return DateFormat('MMMM yyyy').format(DateTime.now());
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

  Future<Map<String, dynamic>> generateRetroReadings(
    DateTime startDate,
    DateTime endDate,
    String zodiacSign, {
    required UserModel user,
    required Map<String, Map<String, dynamic>> currentTransits,
  }) async {
    final prompt = '''
Important: Write the response in $_currentLanguage and return as JSON

You are a professional astrologer analyzing retrograde planets. You have many years of experience in ephemeris calculations and retrograde analysis. Consider the following data:

User Information:
- Birth Date: ${DateFormat('dd.MM.yyyy').format(user.birthDate)}
- Birth Time: ${user.birthTime}
- Birth Place: ${user.birthPlace}
- Sun Sign: ${user.zodiacSign}
- Ascendant: ${user.ascendant}
- Moon Sign: ${user.moonSign}

Analysis Period:
Start: ${DateFormat('dd MMM yyyy, HH:mm').format(startDate)}
End: ${DateFormat('dd MMM yyyy, HH:mm').format(endDate)}

Current Planetary Positions:
${currentTransits.entries.map((e) => "- ${e.key}: ${e.value['sign']} (${e.value['degree']}°)${e.value['isRetrograde'] ? ' Retrograde' : ''}").join('\n')}

Required Analysis:
1. Check ALL planets for retrograde motion:
   - Mercury
   - Venus
   - Mars
   - Jupiter
   - Saturn
   - Uranus
   - Neptune
   - Pluto

2. For each planet:
   - Calculate exact retrograde periods
   - Determine zodiac sign and degree at station points
   - Analyze speed and motion
   - Check aspects to natal planets
   - Consider shadow periods

3. Special Considerations:
   - Pre-retrograde shadow periods
   - Post-retrograde shadow periods
   - Station points (when planets appear to stand still)
   - Direct motion periods
   - Aspects to natal planets during retrogrades
   - House positions in natal chart

4. Impact Analysis:
   - Effect on natal chart placements
   - Influence on houses and angles
   - Aspect patterns during retrograde
   - Personal significance based on:
     * Sun sign ($zodiacSign)
     * Ascendant (${user.ascendant})
     * Moon sign (${user.moonSign})

Return response in this exact JSON format:
{
  "hasRetrogrades": boolean,
  "retrogrades": [
    {
      "planet": "planet_name",
      "startDate": "dd MMM",
      "endDate": "dd MMM",
      "sign": "zodiac_sign",
      "degree": number,
      "impact": "detailed_impact_considering_natal_chart_max_200_chars",
      "advice": "practical_advice_based_on_user_placements_max_200_chars",
      "natalAspects": [
        {
          "natalPlanet": "planet_name",
          "aspect": "aspect_type (conjunction, sextile, square, trine, opposition)",
          "orb": number,
          "interpretation": "brief_interpretation"
        }
      ],
      "shadowPeriod": {
        "preRetrograde": "dd MMM",
        "postRetrograde": "dd MMM"
      }
    }
  ]
}

Technical Notes:
1. Use Swiss Ephemeris calculations for accuracy
2. Consider stations within 1 degree orb
3. Include aspects within these orbs:
   - Conjunction: 8°
   - Opposition: 8°
   - Trine: 7°
   - Square: 7°
   - Sextile: 6°
4. Check shadow periods:
   - Pre-retrograde: When planet first crosses degree where it will station direct
   - Post-retrograde: Until planet crosses degree where it stationed retrograde

Important: Write the response in $_currentLanguage
''';

    try {
      final content = Content.text(prompt);
      final response = await _textModel.generateContent([content]);

      if (response.text == null || response.text!.isEmpty) {
        throw Exception('Retro yorumu oluşturulamadı');
      }

      final cleanedResponse = _cleanJsonResponse(response.text!);
      return json.decode(cleanedResponse);
    } catch (e) {
      print('Retro analizi hatası: $e');
      throw Exception('Retro analizi hatası: $e');
    }
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

  Future<String> generateBiorhythmReading(
      DateTime birthDate, String userName) async {
    try {
      final now = DateTime.now();
      final daysSinceBirth = now.difference(birthDate).inDays;

      final physical = sin(2 * pi * daysSinceBirth / 23);
      final emotional = sin(2 * pi * daysSinceBirth / 28);
      final intellectual = sin(2 * pi * daysSinceBirth / 33);
      final intuitive = sin(2 * pi * daysSinceBirth / 38);

      final prompt = '''
Important: Write the response in $_currentLanguage

      Create a biorhythm interpretation for $userName based on the following cycles:
      
      Physical Cycle: ${(physical * 100).toStringAsFixed(1)}%
      Emotional Cycle: ${(emotional * 100).toStringAsFixed(1)}%
      Intellectual Cycle: ${(intellectual * 100).toStringAsFixed(1)}%
      Intuitive Cycle: ${(intuitive * 100).toStringAsFixed(1)}%
      
      Create a JSON response with this format:
      {
        "biorhythmReading": {
          "overview": "General interpretation of current biorhythm state",
          "physical": {
            "status": "Current physical cycle interpretation",
            "advice": "Physical well-being advice"
          },
          "emotional": {
            "status": "Current emotional cycle interpretation",
            "advice": "Emotional well-being advice"
          },
          "intellectual": {
            "status": "Current intellectual cycle interpretation",
            "advice": "Mental activity advice"
          },
          "intuitive": {
            "status": "Current intuitive cycle interpretation",
            "advice": "Intuition and awareness advice"
          }
        }
      }

Important: Write the response in $_currentLanguage
      ''';

      final response = await _textModel.generateContent([Content.text(prompt)]);
      String jsonStr = response.text ?? '';

      jsonStr = _cleanJsonResponse(jsonStr);
      return jsonStr;
    } catch (e) {
      print('Generate biorhythm reading error: $e');
      return _createDefaultBiorhythmJson();
    }
  }

  String _createDefaultBiorhythmJson() {
    return '''
Important: Write the response in $_currentLanguage

    {
      "biorhythmReading": {
        "overview": "Biyoritminiz genel olarak dengeli bir dönemde. Fiziksel ve duygusal enerjileriniz uyum içinde çalışıyor.",
        "physical": {
          "status": "Fiziksel enerjiniz yükseliş döneminde. Vücudunuz daha dinç ve güçlü hissediyor.",
          "advice": "Bu enerjiyi spor ve fiziksel aktivitelerle değerlendirin."
        },
        "emotional": {
          "status": "Duygusal döngünüz stabil bir seviyede seyrediyor.",
          "advice": "Dengeli duygusal durumunuzu korumak için meditasyon yapabilirsiniz."
        },
        "intellectual": {
          "status": "Zihinsel kapasiteniz yüksek bir noktada.",
          "advice": "Yeni projeler başlatmak için ideal bir zaman."
        },
        "intuitive": {
          "status": "Sezgisel yetenekleriniz güçlü bir dönemde.",
          "advice": "İçgüdülerinizi dinleyin ve önemli kararlar için kullanın."
        }
      }
    }

Important: Write the response in $_currentLanguage
    ''';
  }

  Future<String?> interpretDream(String dream) async {
    final generationConfig = GenerationConfig(
      maxOutputTokens: 4000,
      temperature: 2,
      topP: 0.9,
      topK: 10,
    );
    final safetySettings = [
      SafetySetting(HarmCategory.harassment, HarmBlockThreshold.none),
      SafetySetting(HarmCategory.hateSpeech, HarmBlockThreshold.none),
      SafetySetting(HarmCategory.sexuallyExplicit, HarmBlockThreshold.none),
      SafetySetting(HarmCategory.dangerousContent, HarmBlockThreshold.none),
    ];
    final model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: apiKey,
      safetySettings: safetySettings,
      generationConfig: generationConfig,
    );

    final prompt =
        "'$dream' here, interpret the dream in $_currentLanguage like a professional dream interpreter with a mystical language and sprinkle emojis into the interpretation. Make precise predictions about the future. The dream interpretation should consist of a minimum of 3 paragraphs, the first paragraphs should analyze the dream and the last paragraph should give a general summary of the dream. interpret the dream in $_currentLanguage";
    final content = [Content.text(prompt)];
    final response = await model.generateContent(content);
    return response.text;
  }

  Future<Map<String, dynamic>> interpretTarotCards(
      List<TarotCard> selectedCards) async {
    final generationConfig = GenerationConfig(
      maxOutputTokens: 4000,
      temperature: 2,
      topP: 0.9,
      topK: 10,
    );

    final safetySettings = [
      SafetySetting(HarmCategory.harassment, HarmBlockThreshold.none),
      SafetySetting(HarmCategory.hateSpeech, HarmBlockThreshold.none),
      SafetySetting(HarmCategory.sexuallyExplicit, HarmBlockThreshold.none),
      SafetySetting(HarmCategory.dangerousContent, HarmBlockThreshold.none),
    ];

    final model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: apiKey,
      safetySettings: safetySettings,
      generationConfig: generationConfig,
    );

    try {
      final user = Get.find<UserController>().currentUser.value;
      final relationshipStatus = user?.relationshipStatus ?? 'Belirtilmemiş';
      final interests = user?.interests.join(', ') ?? 'Belirtilmemiş';

      final prompt = '''
Important: Write the response in $_currentLanguage
      Pretend you are a professional tarot reader and interpret these three cards in $_currentLanguage language:

      USER INFORMATION:
      Relationship Status: $relationshipStatus
      Areas of Interest: $interests

      PAST CARD: ${selectedCards[0].name}
      ${selectedCards[0].keywords.join(', ')}
      ${selectedCards[0].meaning}

      PRESENT CARD: ${selectedCards[1].name}
      ${selectedCards[1].keywords.join(', ')}
      ${selectedCards[1].meaning}

      FUTURE CARD: ${selectedCards[2].name}
      ${selectedCards[2].keywords.join(', ')}
      ${selectedCards[2].meaning}

      Please provide three separate interpretations considering the user's relationship status and interests:
      - First, interpret the past card with mystical language, sprinkle emojis into the interpretation
      - Then, interpret the present card with mystical language, sprinkle emojis into the interpretation
      - Finally, interpret the future card with mystical language and make precise predictions, sprinkle emojis into the interpretation

      Each interpretation should be max 1500 characters long. Separate each interpretation with "###".
      Important: Write the response in $_currentLanguage
      ''';

      final content = Content.text(prompt);
      final response = await model.generateContent([content]);

      if (response.text == null || response.text!.isEmpty) {
        throw Exception('Yorum oluşturulamadı');
      }

      final interpretations = response.text!.split('###');
      if (interpretations.length != 3) {
        throw Exception('Yorumlar doğru formatta alınamadı');
      }

      return {
        'past': interpretations[0].trim(),
        'present': interpretations[1].trim(),
        'future': interpretations[2].trim(),
      };
    } catch (e) {
      throw Exception('Tarot yorumu oluşturulurken bir hata oluştu: $e');
    }
  }

  Future<Map<String, dynamic>> interpretKatinaCards(
      List<TarotCard> selectedCards) async {
    final generationConfig = GenerationConfig(
      maxOutputTokens: 4000,
      temperature: 2,
      topP: 0.9,
      topK: 10,
    );

    final safetySettings = [
      SafetySetting(HarmCategory.harassment, HarmBlockThreshold.none),
      SafetySetting(HarmCategory.hateSpeech, HarmBlockThreshold.none),
      SafetySetting(HarmCategory.sexuallyExplicit, HarmBlockThreshold.none),
      SafetySetting(HarmCategory.dangerousContent, HarmBlockThreshold.none),
    ];

    final model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: apiKey,
      safetySettings: safetySettings,
      generationConfig: generationConfig,
    );

    try {
      final user = Get.find<UserController>().currentUser.value;
      final relationshipStatus = user?.relationshipStatus ?? 'Belirtilmemiş';
      final interests = user?.interests.join(', ') ?? 'Belirtilmemiş';

      final prompt = '''
Important: Write the response in $_currentLanguage
      Pretend you are a professional Katina card reader and interpret these three cards in $_currentLanguage language:

      USER INFORMATION:
      Relationship Status: $relationshipStatus
      Areas of Interest: $interests

      PAST CARD: ${selectedCards[0].name}
      ${selectedCards[0].keywords.join(', ')}
      ${selectedCards[0].meaning}

      PRESENT CARD: ${selectedCards[1].name}
      ${selectedCards[1].keywords.join(', ')}
      ${selectedCards[1].meaning}

      FUTURE CARD: ${selectedCards[2].name}
      ${selectedCards[2].keywords.join(', ')}
      ${selectedCards[2].meaning}

      Please provide three separate interpretations considering the user's relationship status and interests:
      - First, interpret the past card with mystical language, sprinkle emojis into the interpretation
      - Then, interpret the present card with mystical language, sprinkle emojis into the interpretation
      - Finally, interpret the future card with mystical language and make precise predictions, sprinkle emojis into the interpretation

      Interpretation should be about love.
      Each interpretation should be max 1500 characters long. 
      Separate each interpretation with "###".
      Important: Write the response in $_currentLanguage
      ''';

      final content = Content.text(prompt);
      final response = await model.generateContent([content]);

      if (response.text == null || response.text!.isEmpty) {
        throw Exception('Yorum oluşturulamadı');
      }

      final interpretations = response.text!.split('###');
      if (interpretations.length != 3) {
        throw Exception('Yorumlar doğru formatta alınamadı');
      }

      return {
        'past': interpretations[0].trim(),
        'present': interpretations[1].trim(),
        'future': interpretations[2].trim(),
      };
    } catch (e) {
      throw Exception('Katina yorumu oluşturulurken bir hata oluştu: $e');
    }
  }

  Future<Map<String, dynamic>> interpretAngelCards(
      List<TarotCard> selectedCards) async {
    final generationConfig = GenerationConfig(
      maxOutputTokens: 4000,
      temperature: 1.8, // Daha yaratıcı yanıtlar için sıcaklığı artırdım
      topP: 0.95,
      topK: 15,
    );

    final safetySettings = [
      SafetySetting(HarmCategory.harassment, HarmBlockThreshold.none),
      SafetySetting(HarmCategory.hateSpeech, HarmBlockThreshold.none),
      SafetySetting(HarmCategory.sexuallyExplicit, HarmBlockThreshold.none),
      SafetySetting(HarmCategory.dangerousContent, HarmBlockThreshold.none),
    ];

    final model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: apiKey,
      safetySettings: safetySettings,
      generationConfig: generationConfig,
    );

    try {
      final user = Get.find<UserController>().currentUser.value;
      final relationshipStatus = user?.relationshipStatus ?? 'Belirtilmemiş';
      final interests = user?.interests.join(', ') ?? 'Belirtilmemiş';

      final prompt = '''
Important: Write the response in $_currentLanguage
      Pretend you are a professional Angel card reader and interpret these three cards in $_currentLanguage language:

      USER INFORMATION:
      Relationship Status: $relationshipStatus
      Areas of Interest: $interests

      PAST CARD: ${selectedCards[0].name}
      ${selectedCards[0].keywords.join(', ')}
      ${selectedCards[0].meaning}

      PRESENT CARD: ${selectedCards[1].name}
      ${selectedCards[1].keywords.join(', ')}
      ${selectedCards[1].meaning}

      FUTURE CARD: ${selectedCards[2].name}
      ${selectedCards[2].keywords.join(', ')}
      ${selectedCards[2].meaning}

      Please provide three separate interpretations with divine angelic guidance considering the user's relationship status and interests:
      - First, interpret the past card with gentle and loving angelic language. Focus on healing messages from guardian angels about past experiences. Include angel numbers and their meanings. Use angel-related emojis (👼,✨,💫,🕊️,🙏).
      
      - Then, interpret the present card with uplifting angelic wisdom. Share guidance about current situation from Archangels. Include crystal and color recommendations for spiritual support. Use angel-related emojis.
      
      - Finally, interpret the future card with hopeful angelic predictions. Provide specific angel affirmations and prayers for manifesting positive outcomes. Include dates or timeframes when guided. Use angel-related emojis.

      Each interpretation should:
      - Offer practical spiritual advice
      - End with an angelic blessing
      - Be max 1500 characters long
      
      Separate each interpretation with "###".
      Important: Write the response in $_currentLanguage
      ''';

      final content = Content.text(prompt);
      final response = await model.generateContent([content]);

      if (response.text == null || response.text!.isEmpty) {
        throw Exception('Yorum oluşturulamadı');
      }

      final interpretations = response.text!.split('###');
      if (interpretations.length != 3) {
        throw Exception('Yorumlar doğru formatta alınamadı');
      }

      return {
        'past': interpretations[0].trim(),
        'present': interpretations[1].trim(),
        'future': interpretations[2].trim(),
      };
    } catch (e) {
      throw Exception('Melek kartı yorumu oluşturulurken bir hata oluştu: $e');
    }
  }
}
