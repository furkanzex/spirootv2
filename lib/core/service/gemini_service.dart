import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:image/image.dart' as img;
import 'package:google_generative_ai/google_generative_ai.dart';

final String apiKey = "";

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

class ConversationState {
  final GenerativeModel _model;
  late final ChatSession chat;
  String conversationHistory = "";

  ConversationState(this._model) : chat = _model.startChat();

  void updateHistory(String userMessage, String aiResponse) {
    conversationHistory += "You: $userMessage\nAI: $aiResponse\n";
  }
}

ConversationState? _conversationState;

Future<String> geminiImageService(
  String type,
  List<String> imgPaths,
  String q,
  String category,
  String subcategory,
  String instructions,
  String tone,
  String length,
  String audience,
  String style,
) async {
  String question = q.isEmpty ? "" : q;
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

  _conversationState ??= ConversationState(model);

  String sysInstructions =
      "Answer in ${"lang".tr()}. As a sophisticated AI model, your task is to generate a comprehensive output for the category of [$category], specifically focusing on the subcategory of [$subcategory]. You should follow these detailed instructions to ensure the output meets the desired criteria: [$instructions]. The content you produce should be well-structured, coherent, and adhere to the following guidelines: **Tone and Style**: The tone should be [$tone]. **Length and Detail**: The output should be [$length]. **Audience and Purpose**: The content is intended for [$audience]. **Structure**: Ensure the content is organized logically, with a clear introduction, body, and conclusion. Use appropriate headings, subheadings, and paragraphs to enhance readability. **Creativity and Originality**: The output should be [$style]. Finally, your response should seamlessly build and provided instructions and guidelines. Answer in ${"lang".tr()}.";

  if (category.isEmpty ||
      subcategory.isEmpty ||
      instructions.isEmpty ||
      tone.isEmpty ||
      style.isEmpty ||
      audience.isEmpty ||
      length.isEmpty) {
    promptText =
        "Answer in ${"lang".tr()}. ${_conversationState!.conversationHistory} $q";
  } else {
    promptText =
        "**Take this text as system instruction:** [$sysInstructions]. **Our previous conversation (don't tell me this information):** ${_conversationState!.conversationHistory} **My question:** $question";
  }

  List<File> resizedImagesList = [];
  for (var i = 0; i < imgPaths.length; i++) {
    final resizedImageFile = await resizeImage(File(imgPaths[i]));
    resizedImagesList.add(resizedImageFile);
  }

  final List<DataPart> imageParts = [];
  for (var resizedImageFile in resizedImagesList) {
    final imageBytes = await resizedImageFile.readAsBytes();
    imageParts.add(DataPart('image/jpeg', imageBytes));
  }

  final prompt = TextPart(promptText);

  final response = await _conversationState!.chat
      .sendMessage(Content.multi([prompt, ...imageParts]));

  _conversationState!.updateHistory(question, response.text!);

  return response.text!;
}
