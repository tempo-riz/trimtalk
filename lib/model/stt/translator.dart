import 'package:deepl_dart/deepl_dart.dart' as deepl;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:trim_talk/model/files/db.dart';

class Translator {
  /// translate to app language
  ///
  ///  will return null if failed or if language is the same as app language
  static Future<String?> translate({required String text, String? sourceCode}) async {
    final String appLangCode = DB.getPref(Prefs.appLanguageCode);

    if (appLangCode == sourceCode) return null;

    // translate if enabled and if different than app language
    final translator = deepl.Translator(authKey: dotenv.get("DEEPL_API_KEY"));
    // convert to app language
    final deeplRes = await translator.translateTextSingular(text, appLangCode, sourceLang: sourceCode);
    if (deeplRes.text.isEmpty) return null;
    return deeplRes.text;
  }

  /// translate a result (transcript and summary)
  // static Future<Result?> translateRes(Result res) async {
  //   final transcript = res.transcript;
  //   final summary = res.summary;

  //   if (transcript == null) return null;

  //   final translatedTranscript = await translate(text: transcript);
  //   final translatedSummary = summary == null ? null : await translate(text: summary);

  //   if (translatedTranscript == null) return null;

  //   return res.copyWith(
  //     transcript: translatedTranscript,
  //     summary: translatedSummary,
  //   );
  // }
}
