import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:groq_sdk/models/groq.dart';
import 'package:groq_sdk/models/groq_chat.dart';
import 'package:groq_sdk/models/groq_llm_model.dart';
import 'package:trim_talk/model/files/db.dart';
import 'package:trim_talk/model/utils.dart';

class Summarizer {
  static Future<String?> summarize(String? transcript) async {
    if (transcript == null) {
      print('Transcript is null in summarizer');
      return null;
    }
    final code = DB.getPref(Prefs.transcriptLanguageCode);

    final maybeLanguage = supportedTranscritionLanguages.where((L) => (L.code == code && code != "auto")).firstOrNull;

    final prompt = _buildPromptSummaryOnly(transcript, language: maybeLanguage?.name);

    const deepSeekId = "deepseek-r1-distill-llama-70b";

    try {
      // First try with deepseek
      // https://console.groq.com/settings/limits
      // https://console.groq.com/settings/billing
      // TODO : https://arc.net/l/quote/jdzwgwwj
      String? result = await _tryWithModel(deepSeekId, prompt);

      // fallback to gemma2-9b-it
      result ??= await _tryWithModel(GroqModels.gemma2_9b, prompt);

      return await _parseJsonAnswerSummaryOnly(result!);
    } catch (e) {
      print(e);
      return null;
    }
  }

  static Future<String?> _tryWithModel(String modelId, String prompt) async {
    final groq = Groq(dotenv.get("GROQ_API_KEY"));

    try {
      final (summary, _) = await groq.startNewChat(modelId, settings: GroqChatSettings()).sendMessage(prompt);
      print("success with model $modelId");
      return summary.choices.first.message;
    } catch (e) {
      print("Error with model $modelId: $e");
      return null;
    }
  }

  static String _buildPromptSummaryOnly(String transcript, {String? language}) {
    final langStr = language != null ? "($language)" : '';

    return '''
Summarize the following audio transcript. The output should be in JSON format with a single key:

{
  "summary": "A concise summary that captures the key information and main points from the provided text."
}
The value of the "summary" key should be in the source language $langStr. Here is the text to process:

$transcript
''';

//     return '''
// Please summarize the provided text, which is an audio transcript, and return the result in JSON format. The JSON should contain two keys:

// 1. "transcript": This should include the original text with enhancements, such as improved clarity, grammar, and readability.
// 2. "summary": This should be a concise summary of the provided text, capturing the main points and key information.

// Make sure the JSON response is properly formatted and structured, answer with the original language $langStr. Here is the text to process:

// $transcript
// ''';
  }

  /// This can throw
  static Future<String?> _parseJsonAnswerSummaryOnly(String jsonStr) async {
    // Example JSON response from the language model
    // {
    //   "transcript": "This is the enhanced version of the audio transcript with improved clarity.",
    //   "summary": "A concise summary of the main points."
    // }
    // Extract the part from the first '{' to the last '}'
    print("parsing $jsonStr");
    int startIndex = jsonStr.indexOf('{');
    int endIndex = jsonStr.lastIndexOf('}') + 1; // +1 to include the last '}'
    String jsonPart = jsonStr.substring(startIndex, endIndex);

    final Map<String, dynamic> parsedResponse = jsonDecode(jsonPart);
    // Extracting the values
    // String? transcript = parsedResponse['transcript'];
    String? summary = parsedResponse['summary'];

    if (summary == null) {
      return null;
    }
    return summary.trim();
  }
}
