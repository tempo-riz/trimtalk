import 'dart:io';

import 'package:collection/collection.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:groq_sdk/models/groq.dart';
import 'package:groq_sdk/models/groq_llm_model.dart';
import 'package:trim_talk/model/files/converter.dart';
import 'package:trim_talk/model/files/db.dart';
import 'package:trim_talk/model/stt/translator.dart';
import 'package:trim_talk/model/utils.dart';
import 'package:trim_talk/types/result.dart';

class Transcriber {
  static Future<Result?> transcribe(
    Result res, {
    bool skipConvert = false,
    bool skipResize = false,
  }) async {
    final groq = Groq(dotenv.get("GROQ_API_KEY"));

    try {
//       Supported File Types: mp3, mp4, mpeg, mpga, m4a, wav, webm
// Single Audio Track: Only the first track will be transcribed for files with multiple audio tracks. (e.g. dubbed video)

// Preprocessing Audio Files
// Our speech-to-text models will downsample audio to 16,000 Hz mono before transcribing. This preprocessing can be performed client-side to reduce file size and allow longer files to be uploaded to Groq.

// convert to wav first
      File? tmpWavFile;
      if (!skipConvert) {
        tmpWavFile = await AudioTools.convertToWav(File(res.path));
        // print('Error converting to wav, trying with base format anyway');
      }

      final effectiveFile = tmpWavFile ?? File(res.path);

      if (!skipResize) {
        const maxProcessableSizeInBytes = 25 * 1024 * 1024; // 25MB
        // avoid transcribing big files
        const maxSizeInBytes = 76 * 1024 * 1024; // 76MB (allow to chunk 3x25MB files no more)
        final size = effectiveFile.lengthSync();
        if (size > maxSizeInBytes) {
          print('File too big, skipping transcription');
          return res.copyWith(loadingTranscript: false);
        }

        //
        print('file size: $size');
        if (size > maxProcessableSizeInBytes) {
          print('File too big, splitting it');
          return _transcribeBigFile(res, effectiveFile.path);
        }
      }

      // limit is 25MB : https://console.groq.com/docs/speech-text

      final String language = DB.getPref(Prefs.transcriptLanguageCode);
      print('Transcribing ${res.path} with language $language');

      final (transcriptionResult, usage) = await groq.transcribeAudio(
        modelId: GroqModels.whisper_large_v3,
        audioFileUrl: effectiveFile.path,
        optionalParameters: {
          //'temperature': '0', // 0..1 Default: None
          'response_format': 'verbose_json', // Default: json.  json, text, verbose_json to receive timestamps for audio segments.
          if (language.isNotEmpty && language != "auto") 'language': language, // Default: None (Models will auto-detect if not specified)
        },
      );

      print(transcriptionResult.text);
      print(transcriptionResult.json);

      if (res.duration.isEmpty) {
        final dur = transcriptionResult.json['duration'] as num;
        final duration = formatDuration(Duration(seconds: dur.floor()));
        res = res.copyWith(duration: duration);
      }

      // French, ...

      String transcript = transcriptionResult.text.trim();

      if (DB.getPref(Prefs.isTranslated)) {
        final detectedLang = transcriptionResult.json['language'] as String?;
        final detectedLangCode = supportedAppLanguages.firstWhereOrNull((l) => l.name == detectedLang)?.code;

        final transText = await Translator.translate(text: transcript, sourceCode: detectedLangCode);
        if (transText != null) {
          transcript = transText;
        }
      }

      print(usage);

      //clear wav file
      tmpWavFile?.delete();

      return res.copyWith(
        transcript: transcript,
      ); // The transcribed text
    } catch (e) {
      print('Error transcribing audio: $e');
      return null;
    }
  }

  // null if one of the chunks failed
  static Future<Result?> _transcribeBigFile(Result res, String path) async {
    try {
      final tup = await AudioTools.splitAudio(File(path));
      if (tup == null) {
        return res.copyWith(loadingTranscript: false);
      }
      final List<File> files = tup.$1;
      final double dur = tup.$2;

      // keep duration in case transcription fails
      final tmpRes = res.copyWith(duration: formatDuration(Duration(seconds: dur.floor())));

      String transcript = "";

      for (final file in files) {
        final partRes = await transcribe(tmpRes.copyWith(path: file.path), skipConvert: true, skipResize: true);
        if (partRes == null) {
          return null;
        }
        transcript += "${partRes.transcript} ";
      }

      return tmpRes.copyWith(transcript: transcript.trim());
    } catch (e) {
      return null;
    }
  }
}
