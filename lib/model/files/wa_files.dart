import 'dart:io';

import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:trim_talk/model/files/permissions.dart';
import 'package:trim_talk/model/files/platform/platform.dart';
import 'package:trim_talk/model/utils.dart';
import 'package:trim_talk/types/result.dart';

/// Directory where WhatsApp stores audio messages
class WAFiles {
  /// set the media path relative to the android version
  ///
  /// Android 12- : /storage/emulated/0/WhatsApp/Media/WhatsApp Voice Notes/
  ///
  /// Android 13+ : /storage/emulated/0/Android/media/com.whatsapp/WhatsApp/Media/WhatsApp Voice Notes/

  static String basePath = '/storage/emulated/0/WhatsApp/Media';

  /// Directory where WhatsApp stores audio messages
  static String waFilesDir = '$basePath/WhatsApp Audio/';

  /// Directory where WhatsApp stores voice notes recorded in the app
  static String waNotesBaseDir = '$basePath/WhatsApp Voice Notes/';

  static String uriNotesDir =
      "content://com.android.externalstorage.documents/tree/primary%3AAndroid%2Fmedia%2Fcom.whatsapp%2FWhatsApp%2FMedia%2FWhatsApp%20Voice%20Notes";

  static String getAudioNotesDir() {
    return p.join(WAFiles.waNotesBaseDir, getLatestAudioNoteDirId());
  }

  static File? getLatestAudioNote() {
    final path = getAudioNotesDir();
    print("Looking for files in $path");
    final dir = Directory(path);
    final files = dir.listSync();

    // first get all files that starts with PTT-yyyymmdd
    DateTime now = DateTime.now();
    String today = DateFormat("yyyyMMdd").format(now);

    final List<File> todayFiles = files.whereType<File>().where((entry) => p.basename(entry.path).startsWith("PTT-$today")).toList();
    //then get the latest one
    todayFiles.sort((a, b) => b.statSync().modified.compareTo(a.statSync().modified));

    if (todayFiles.isEmpty) {
      print("No files found here");
      return null;
    }

    if (!(todayFiles.firstOrNull?.existsSync() ?? false)) {
      print("File does not exist (yet?)");
      return null;
    }

    return todayFiles.firstOrNull;
  }

  static File? getLatestAudioFile() {
    final dir = Directory(waFilesDir);
    print("Looking for files in $waFilesDir");
    print(dir.existsSync());
    dir.listSync().forEach((element) {
      print(element);
    });
    final files = dir.existsSync() ? dir.listSync() : [];

    // first get all files that starts with PTT-yyyymmdd

    final List<File> todayFiles = files.whereType<File>().where((entry) => p.basename(entry.path).startsWith("AUD-")).toList();

    //then get the latest one
    todayFiles.sort((a, b) => b.statSync().modified.compareTo(a.statSync().modified));

    return todayFiles.firstOrNull;
  }

  static File? debug() {
    final dir = Directory(waFilesDir);
    print("Looking for files in $waFilesDir");
    print(dir.existsSync());
    dir.listSync().forEach((element) {
      print(element);
    });
    final files = dir.existsSync() ? dir.listSync() : [];

    // first get all files that starts with PTT-yyyymmdd

    final List<File> todayFiles = files.whereType<File>().where((entry) => p.basename(entry.path).startsWith("AUD-")).toList();

    //then get the latest one
    todayFiles.sort((a, b) => b.statSync().modified.compareTo(a.statSync().modified));

    return todayFiles.firstOrNull;
  }

  /// will look in the audio files and audio notes folders (week's folder only)
  ///
  /// Sorted from oldest to newest
  static Future<List<Result>> getAudiosAfter(DateTime date) async {
    final isLegacy = await Permissions.isLegacyStorage();
    if (isLegacy) {
      // AUDIO NOTES
      final dNotes = Directory(getAudioNotesDir());
      final List<FileSystemEntity> files2 = dNotes.existsSync() ? dNotes.listSync() : [];

      // also get yesterday files if waas a different week number
      final String? yesterdayDirName = getYersterdayAudioNoteDirId();
      if (yesterdayDirName != null) {
        final Directory dNotes2 = Directory(yesterdayDirName);
        final List<FileSystemEntity> yesterdayNotes = dNotes2.existsSync() ? dNotes2.listSync() : [];
        files2.addAll(yesterdayNotes);
      }

      final List<File> audioNotes =
          files2.whereType<File>().where((entry) => p.basename(entry.path).startsWith("PTT-") && entry.statSync().modified.isAfter(date)).toList();
      // older first
      audioNotes.sort((a, b) => a.statSync().modified.compareTo(b.statSync().modified));

      return audioNotes.toResults();
    }

    final Stopwatch stopwatch = Stopwatch()..start();
    final res = await NativePlatform.listAfter(date);
    print("getAudiosAfter took ${stopwatch.elapsedMilliseconds}ms");
    stopwatch.stop();
    return res;
  }

  static Future<Result?> copyToSupportDir(Result res) async {
    final isLegacyAndroid = Platform.isAndroid && await Permissions.isLegacyStorage();
    if (isLegacyAndroid) {
      // if legacy need to copy file in support dir
      final supDir = await getApplicationSupportDirectory();
      final sourceFile = File(res.path);
      final destFile = File(p.join(supDir.path, res.filename));
      try {
        await sourceFile.copy(destFile.path);
        return res.copyWith(path: destFile.path);
      } catch (e) {
        print(e);
        return null;
      }
    }
    return await NativePlatform.copyToSupportDirFromNative(res);
  }

  static Future<void> deleteFile(String path) async {
    final file = File(path);
    if (await file.exists()) {
      file.delete();
    }
  }
}
