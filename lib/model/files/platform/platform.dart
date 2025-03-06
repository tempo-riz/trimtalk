import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:trim_talk/model/files/platform/pigeon_api.g.dart';
import 'package:trim_talk/model/utils.dart';
import 'package:trim_talk/types/result.dart';
import 'package:path/path.dart' as p;

final NativePigeonApi api = NativePigeonApi();

class NativePlatform {
  /// result should be : content://com.android.externalstorage.documents/tree/primary%3AAndroid%2Fmedia%2Fcom.whatsapp%2FWhatsApp%2FMedia%2FWhatsApp%20Voice%20Notes
  static Future<String?> pickFolder() async {
    return await api.pickFolder();
  }

  static Future<List<String>> getPersistedUrisPermissions() async {
    final result = await api.getPersistedUrisPermissions();

    return result.whereType<String>().toList();
  }

  static Future<Uint8List?> readFile(String uri) async {
    final Uint8List? result = await api.readFileBytes(uri);
    return result;
  }

  /// android/ios via shared intent -> return it as is
  ///
  /// android (saf) -> copy to app support dir
  static Future<Result?> copyToSupportDirFromNative(Result res) async {
    final destDir = await getApplicationSupportDirectory();
    final newFile = File(p.join(destDir.path, res.filename));

    print("copyToSupportDir: ${res.path} to ${newFile.path}");

    // if doesnt start with content it's because it's from shared intent
    if (!res.path.startsWith("content://")) {
      // in that case we already copied it so return as is
      return res;
    }

    final bytes = await readFile(res.path);
    if (bytes == null) {
      print("bytes is null");
      return null;
    }

    await newFile.writeAsBytes(bytes);
    print("File copied to ${newFile.path}");

    return res.copyWith(path: newFile.path);
  }

  static Future<List<Result>> listAfter(DateTime date) async {
    final folderId = getLatestAudioNoteDirId();
    print(folderId);
    final int time = date.millisecondsSinceEpoch;

    // using isolate to avoid "Skipped 194 frames!  The application may be doing too much work on its main thread."
    // SEEMS NOT TO WORK IN ISOLATE (token is not null) -> use thread kotlin side
    try {
      return listAfterCallRaw(folderId, time);
    } catch (e) {
      print(e);
      return [];
    }
  }

  static Future<List<Result>> listAfterCallRaw(String folderId, int dateInMs) async {
    final nativeResults = await api.listAfter(folderId, dateInMs);

    return nativeResults.whereType<NativeResult>().map((res) => Result.fromNative(res)).toList();
  }
}
