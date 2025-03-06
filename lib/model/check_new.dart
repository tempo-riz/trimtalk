import 'dart:io';
import 'package:flutter/services.dart';
import 'package:trim_talk/model/files/db.dart';
import 'package:trim_talk/model/notif/notification_sender.dart';
import 'package:trim_talk/model/notif/notification_watcher.dart';
import 'package:trim_talk/model/stt/result_extensions.dart';
import 'package:trim_talk/model/utils.dart';
import 'package:trim_talk/model/files/wa_files.dart';
import 'package:trim_talk/types/result.dart';

/// Ask the user if they want to trim each audio file OR transcribe it if auto-transcribe is enabled
Future<void> checkForNewAudios({
  bool userRequestedTrim = false,
  bool isBackground = false,
  ResultExtraMetadata? extraMetadata,
}) async {
  try {
    DB.setPref(Prefs.isCheckingForFiles, true);

    bool isFirstRun = DB.getPref(Prefs.isFirstRun);

    // if first run, get the last 3 audios NOTES from the last 3 days
    if (isFirstRun) {
      print("First run");
      await DB.setPref(Prefs.lastRun, DateTime.now().subtract(const Duration(days: 5)).toIso8601String());
      await DB.setPref(Prefs.isFirstRun, false);
    }

    DateTime date = DateTime.parse(DB.getPref(Prefs.lastRun));
    await DB.setPref(Prefs.lastRun, DateTime.now().toIso8601String());

    // date = date.subtract(Duration(hours: 22)); // TODOD DEBUG
    List<Result> results = await WAFiles.getAudiosAfter(date);
    if (isFirstRun) {
      results = results.take(4).toList();
    }
    print("found ${results.length} files");

    if (userRequestedTrim && results.isEmpty) {
      showSnackBar("No new audio found since last run");
    }

    for (Result r in results) {
      print("Processing ${r.path}");

      // add sender if in extra and same duration
      if (extraMetadata != null && extraMetadata.duration == r.duration) {
        r = r.copyWith(sender: extraMetadata.author);
      }

      final resKey = await DB.resultBox.add(r);

      if (DB.getPref(Prefs.isAutoTranscript) || isBackground) {
        await transcribeFileAndShowResult(resKey);
        continue;
      }

      await NotificationSender.promptUserValidation(r, resKey);
    }
  } catch (e) {
    print("Error checking for new audios: $e");
  } finally {
    DB.setPref(Prefs.isCheckingForFiles, false);
  }
}

Future<void> transcribeFileAndShowResult(int resKey) async {
  final notifId = randomInt32();

  final res = DB.resultBox.get(resKey);
  if (res == null) {
    return NotificationSender.showError(notifId, "Failed to transcribe (no result)");
  }

  NotificationSender.showLoading(notifId, res.duration);

  final newRes = await res.transcribe(resKey);
  // show loading result

  if (newRes.transcript == null) {
    return NotificationSender.showError(notifId, "Failed to transcribe ${res.duration} (empty transcript)");
  }

  NotificationSender.showTranscriptResult(newRes, resKey, notifId);
}

/// DEBUG ONLY create a new files and then check
Future<void> createAndCheck() async {
  print("Debugging 1 audio file");

  final data = await rootBundle.load("assets/audio/jfk.wav");
  final bytes = data.buffer.asUint8List();
  final filename = "AUD-${DateTime.now().millisecondsSinceEpoch}.wav";
  final path = WAFiles.waFilesDir + filename;
  final file = File(path);
  if (file.existsSync()) {
    file.createSync(recursive: true);
    await file.writeAsBytes(bytes);
    print("Copied jfk to $path");
  }

  await DB.setPref(Prefs.lastRun, DateTime.fromMicrosecondsSinceEpoch(0).toIso8601String());

  checkForNewAudios();

  //remove the file when done
}
