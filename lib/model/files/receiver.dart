// import 'package:receive_sharing_intent/receive_sharing_intent.dart';

import 'dart:io';

import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:trim_talk/model/files/db.dart';
import 'package:trim_talk/model/stt/transcriber.dart';
import 'package:trim_talk/model/utils.dart';
import 'package:trim_talk/types/result.dart';
import 'package:mime/mime.dart';

bool isAudioFile(String filePath) {
  if (filePath.split('.').last == 'opus') {
    return true;
  }
  final mimeType = lookupMimeType(filePath);
  return mimeType != null && mimeType.startsWith('audio/');
}
// bool _isInit = false;

class Receiver {
  static void init() {
    // For sharing images coming from outside the app while the app is in the memory
    ReceiveSharingIntent.instance.getMediaStream().listen((files) {
      if (files.isEmpty) {
        return;
      }
      _process(files.first);
      ReceiveSharingIntent.instance.reset();
    }, onError: (err) {
      print('getMediaStream Shared files error: $err');
    });

    // For sharing images coming from outside the app while the app is closed
    ReceiveSharingIntent.instance.getInitialMedia().then((files) {
      if (files.isEmpty) {
        return;
      }
      _process(files.first);
      ReceiveSharingIntent.instance.reset();
    }).catchError((err) {
      print('getInitialSharing Shared files error: $err');
    });
  }

  static void _process(SharedMediaFile sharedFile) async {
    if (sharedFile.type != SharedMediaType.file || !isAudioFile(sharedFile.path)) {
      print('Not an audio file');
      return;
    }
    print('Processing shared file: ${sharedFile.path}');
    final file = File(sharedFile.path);

    String date = formatAudioDate(DateTime.now());
    String duration = "";

    final result = Result(date: date, duration: duration, path: file.path, filename: file.path.split('/').last, loadingTranscript: true);
    final key = await DB.resultBox.add(result);

    final newRes = await Transcriber.fromResult(result);
    if (newRes == null) {
      DB.resultBox.put(key, result.copyWith(loadingTranscript: false));
      return;
    }
    DB.resultBox.put(key, newRes);
    print(newRes);
  }
}
