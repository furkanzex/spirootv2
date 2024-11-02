import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
// ignore: depend_on_referenced_packages
import 'package:image/image.dart' as img;
import 'package:google_generative_ai/google_generative_ai.dart';

const String apiKey = "";

Future<File> resizeImage(File imageFile) async {
  final bytes = await imageFile.readAsBytes();
  img.Image image = img.decodeImage(bytes)!;

  const maxFileSize = 4 * 1024 * 1024;

  if (image.length > maxFileSize) {
    final double scaleFactor = maxFileSize / image.length;
    image = img.copyResize(image,
        width: (image.width * scaleFactor).round(),
        height: (image.height * scaleFactor).round());
  }

  final resizedImageFile = File('${imageFile.path}.jpg');
  await resizedImageFile.writeAsBytes(img.encodeJpg(image));

  return resizedImageFile;
}

Future<String> geminiImageService(String imgPath, String? editInst) async {
  String promptText = "";

  final generationConfig = GenerationConfig(
    maxOutputTokens: 2000,
    temperature: 1.9,
    topP: 0.92,
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
    generationConfig: generationConfig,
    safetySettings: safetySettings,
  );

  String sysInstructions =
      'Answer in ${"lang".tr()}. Introduction: "This is a nutritional analysis application. You will analyze a user-supplied image of a food and provide the nutritional values in a JSON file.", Instructions: "Follow these steps: 1-Analyze the image and identify the food. 2-Research the nutritional values of the food you identified. 3-Present the nutritional values in a JSON text according to the following format: {"name": "[Food Name]","amount": "[Serving Amount]","cal": "[Calorie amount]","carb": "[Carbohydrate amount]","prot": "[Amount of protein]","fat": "[Amount of fat]","fiber": "[Amount of fiber]","sugar": "[Amount of sugar]"}.". Just give the string JSON as output in string text format. Do not add any explanation, i want just and only text. Do not add the units." Answer in ${"lang".tr()}.';

  promptText =
      "**Take this text as system instruction:** [$sysInstructions]. **Additional Instructions:** [$editInst].";

  final resizedImageFile = await resizeImage(File(imgPath));
  final (firstImage) = await (resizedImageFile.readAsBytes());

  final imageParts = [
    DataPart('image/jpeg', firstImage),
  ];

  final prompt = TextPart(promptText);

  final response = await model.generateContent([
    Content.multi([prompt, ...imageParts])
  ]);

  String cleanedResponse =
      response.text!.replaceAll(RegExp(r'```json\n|\n```'), '');
  return cleanedResponse;
}

Future<String?> geminiTextService(String inst) async {
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

  String sysInstructions =
      'Answer in ${"lang".tr()}. Introduction: "This is a nutritional analysis application. You will analyze a user-supplied name and amount of a food and provide the nutritional values in a JSON file. If the amount of food is not provided, set an average.", Instructions: "Follow these steps: 1-identify and Analyze the food. 2-Research the nutritional values of the food you identified. 3-Present the nutritional values in a JSON text according to the following format: {"name": "[Food Name]","amount": "[Serving Amount]","cal": "[Calorie amount]","carb": "[Carbohydrate amount]","prot": "[Amount of protein]","fat": "[Amount of fat]","fiber": "[Amount of fiber]","sugar": "[Amount of sugar]"}.". Just give the string JSON as output in string text format. Do not add any explanation, i want just and only text. Do not add the units." Answer in ${"lang".tr()}.';

  final prompt =
      "**Take this text as system instruction:** [$sysInstructions]. **Food name and amount:** [$inst].";

  final content = [Content.text(prompt)];
  final response = await model.generateContent(content);
  String cleanedResponse =
      response.text!.replaceAll(RegExp(r'```json\n|\n```'), '');
  return cleanedResponse;
}

Future<String?> geminiNutritionProgramService(
    int age,
    int height,
    int weight,
    int targetWeight,
    String gender,
    String allergies,
    String mainTarget,
    String bodyType,
    String whenx,
    String activity,
    String dietType,
    String sweetFreq,
    String waterFreq) async {
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

  String allergen = "none";

  if (allergies.isNotEmpty) {
    allergen = allergies;
  }

  String sysInstructions =
      'Answer in ${"lang".tr()}. Introduction: "You are a professional dietitian and nutritionist . I would like you to create a personalized monthly diet program for me using the information below. The diet program should include daily meal recommendations, snacks, water consumption and exercise recommendations. Also, present the nutritional values in a JSON text according to the following format. Here is the information:{"age": "Age: $age", "height": "Height: $height", "weight": "Weight: $weight kg",targetWeight": "Target Weight: $targetWeight", "gender": "Gender: $gender", "allergies": "Allergen Info: $allergen", "mainTarget": "Main Target: $mainTarget", "bodyType": "Body Type: $bodyType", "when": "Last Best Body: $whenx", "activity": "Exercise Frequency: $activity", "diet_type": "Diet Type: $dietType", "sweet_freq": "Frequency of Sweet Consumption: $sweetFreq", "water_freq": "Water Consumption Frequency: $waterFreq"}. The diet program should include breakfast, lunch, dinner and snacks for each day. It should also include a weekly exercise plan. The diet program should be prepared taking into account my daily calorie needs and goals. I would like you to output json text in the EXACTLY following format:"{"weekly_plan": [{"day": "Monday", "meals": {"breakfast": [Breakfast suggestion], "morning_snack": [Morning snack suggestion], "lunch": [Lunch recommendation], "afternoon_snack": [Afternoon snack suggestion], "dinner": [Dinner suggestion], "evening_snack": [Evening snack recommendation]}, "exercise": [Daily exercise recommendation], "total_kcal": [Average calories from the daily program]},...]}". Prepare the program for 7 days (1 week). Just give the JSON text as output in string text format. Do not add any explanation.". Answer in ${"lang".tr()}.';

  final prompt =
      "**Take this text as system instruction:** [$sysInstructions].";

  final content = [Content.text(prompt)];
  final response = await model.generateContent(content);
  String cleanedResponse =
      response.text!.replaceAll(RegExp(r'```json\n|\n```'), '');
  return cleanedResponse;
}

Future<String?> geminiAnalysisService(String program, String myMeals) async {
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

  String sysInstructions =
      'Answer in ${"lang".tr()}. Introduction: "You are a professional dietitian and nutritionist . Using this data, I would like you to create a monthly nutritional analysis. Use the datas which i gave to you and analyze my progress. Output should be JSON and the format should be like this example:"{“entry": {“title": “entry”,“desc": “This is an app that provides the user with a personalized monthly nutritional analysis. Using this dataset, a detailed review of daily caloric intake, macronutrient distribution, micronutrient deficiencies or excesses, meal habits and general recommendations will be provided.” },“kcal": {“title": “Overall Caloric Intake”,“desc": *Specify average daily caloric intake and Compare this value with ideal intervals and provide any suggestions.* },“macro": {“title": “Macronutrient Breakdown”,“desc": *Analyze the macronutrient distribution, indicate whether it is balanced and share your observations.*}, “micro": { “title": “Micronutrient Intake Status”,“desc": *Assess micronutrient intake. Identify deficiencies or excesses. If there is insufficient data, add dietitian recommendation.*},"“nutrition_habits": { “title": “Meal Habits”,“desc": *Analyze meal habits and share your observations. Indicate which meal contains more calories.*},“recommendations": {“title": “General Recommendations”, “desc": *Provide general nutritional recommendations for the user. Make specific recommendations such as increasing daily calorie intake, adding protein or carbohydrates, etc.*}, “conclusion": {“title": “conclusion”,“desc": *Make an overall assessment and indicate the highlights. Summarize the recommendations.*}}. Do not add anything else except this format.". Answer in ${"lang".tr()}.';

  final prompt =
      "**Take this text as system instruction:** [$sysInstructions]. **My Weekly Nutrition Plan (this plan is ideal plan):** [$program]. **The Meals That I Ate and Follow (this meal datas are the real datas):** [$myMeals] ";

  final content = [Content.text(prompt)];
  final response = await model.generateContent(content);
  String cleanedResponse =
      response.text!.replaceAll(RegExp(r'```json\n|\n```'), '');
  return cleanedResponse;
}
