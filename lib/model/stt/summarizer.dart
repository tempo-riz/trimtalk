import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:groq_sdk/models/groq.dart';
import 'package:groq_sdk/models/groq_chat.dart';
import 'package:groq_sdk/models/groq_llm_model.dart';
import 'package:trim_talk/model/files/db.dart';
import 'package:trim_talk/model/utils.dart';
import 'package:trim_talk/types/result.dart';

class Summarizer {
  static Future<Result?> formatAndSummarizeGroq(Result res) async {
    if (res.transcript == null) {
      print('Transcript is null in summarizer');
      return null;
    }
    final code = DB.getPref(Prefs.transcriptLanguageCode);

    final maybeLanguage = supportedTranscritionLanguages.where((L) => (L.code == code && code != "auto")).firstOrNull;

    final prompt = buildPromptSummaryOnly(res.transcript!, language: maybeLanguage?.name);
    final groq = Groq(dotenv.get("GROQ_API_KEY"));

    try {
      // models here : https://console.groq.com/settings/billing gemma 7b seems cheeper !
      final (summary, usage) = await groq.startNewChat(GroqModels.gemma2_9b, settings: GroqChatSettings()).sendMessage(prompt);
      print('Usage: $usage');
      print(summary.choices.first.message);
      print("parsing json");
      return await parseJsonAnswerSummaryOnly(summary.choices.first.message, res);
    } catch (e) {
      print(e);
      return null;
    }
  }

  static String buildPromptSummaryOnly(String transcript, {String? language}) {
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

  static Future<Result> parseJsonAnswerSummaryOnly(String jsonStr, Result res) async {
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
      return res;
    }
    return res.copyWith(summary: summary.trim(), loadingSummary: false, loadingTranscript: false);
  }
}
