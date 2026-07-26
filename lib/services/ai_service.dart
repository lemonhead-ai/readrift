import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter/foundation.dart';

class AIService {
  // IMPORTANT: The user should provide their own API key.
  // We recommend using a secure way to store this, like --dart-define.
  static const String _apiKey = String.fromEnvironment('GEMINI_API_KEY');

  GenerativeModel? _model;

  AIService() {
    if (_apiKey.isNotEmpty) {
      _model = GenerativeModel(
        model: 'gemini-1.5-flash',
        apiKey: _apiKey,
      );
    }
  }

  bool get isEnabled => _model != null;

  Future<String> summarizeContent(String text) async {
    if (!isEnabled) return "AI features are not configured. Please add your Gemini API key.";

    try {
      final prompt = """
      You are the Universal Librarian of ReadRift. Your tone is poetic, wise, and slightly ethereal. 
      Summarize the following book content in a way that feels like an ancient star-map being revealed. 
      Keep it concise and focus on the 'essence' of the story.
      
      Content: $text
      """;
      final content = [Content.text(prompt)];
      final response = await _model!.generateContent(content);
      return response.text ?? "The cosmic winds were too strong; no summary could be formed.";
    } catch (e) {
      debugPrint("Gemini Summary Error: $e");
      return "An error occurred while communing with the Great Archive.";
    }
  }

  Future<String> lookupCharacter(String text, String characterName) async {
    if (!isEnabled) return "AI features are not configured.";

    try {
      final prompt = """
      You are the Universal Librarian of ReadRift. 
      Explain who the character '$characterName' is within this stellar fragment. 
      Describe their significance as if you are reading their fate in the constellations.
      
      Content: $text
      """;
      final content = [Content.text(prompt)];
      final response = await _model!.generateContent(content);
      return response.text ?? "This being remains hidden in the dark matter.";
    } catch (e) {
      debugPrint("Gemini Character Lookup Error: $e");
      return "The connection to the character's star-thread was lost.";
    }
  }
}
