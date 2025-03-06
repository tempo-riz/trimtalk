import 'package:trim_talk/model/files/db.dart';
import 'package:trim_talk/model/files/wa_files.dart';
import 'package:trim_talk/model/stt/summarizer.dart';
import 'package:trim_talk/model/stt/transcriber.dart';
import 'package:trim_talk/model/stt/translator.dart';
import 'package:trim_talk/types/result.dart';

/// these methods will :
/// - return itself if failed
/// - manage their loading state
/// - manage the db update

extension ResultExtension on Result {
  /// this will also update the db and loading state
  Future<Result> transcribe(int key) async {
    DB.resultBox.put(key, copyWith(loadingTranscript: true));

    try {
      final copied = await WAFiles.copyToSupportDir(this);

      final transcribed = await Transcriber.transcribe(copied!);

      final succes = transcribed!.copyWith(loadingTranscript: false);

      await DB.resultBox.put(key, succes);

      return succes;
    } catch (e) {
      final fail = copyWith(loadingTranscript: false);

      await DB.resultBox.put(key, fail);
      return fail;
    }
  }

  Future<Result> summarize(int key) async {
    DB.resultBox.put(key, copyWith(loadingSummary: true));

    try {
      final summarized = await Summarizer.summarize(this);

      final succes = summarized!.copyWith(summary: summary, loadingSummary: false, loadingTranscript: false);

      await DB.resultBox.put(key, succes);

      return succes;
    } catch (e) {
      final fail = copyWith(loadingSummary: false);

      await DB.resultBox.put(key, fail);
      return fail;
    }
  }

  /// translate doesnt have a loading flag so just return itself if failed
  Future<Result> translate(int key) async {
    try {
      if (transcript == null) return this; // nothing to translate

      final translated = await Translator.translate(text: transcript!);

      if (translated == null) return this;

      final succes = copyWith(
        transcript: translated,
        summary: summary != null ? await Translator.translate(text: summary!) : null,
      );

      DB.resultBox.put(key, succes);
      return succes;
    } catch (e) {
      return this;
    }
  }
}
