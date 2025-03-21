import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:trim_talk/model/files/db.dart';
import 'package:trim_talk/model/stt/result_extensions.dart';
import 'package:trim_talk/model/utils.dart';
import 'package:trim_talk/types/result.dart';

class Receiver {
  static void init() {
    // For sharing images coming from outside the app while the app is in the memory
    ReceiveSharingIntent.instance.getMediaStream().listen((files) {
      if (files.isEmpty) {
        return;
      }
      _processFile(files.first);
      ReceiveSharingIntent.instance.reset();
    }, onError: (err) {
      print('getMediaStream Shared files error: $err');
    });

    // For sharing images coming from outside the app while the app is closed
    ReceiveSharingIntent.instance.getInitialMedia().then((files) {
      if (files.isEmpty) {
        return;
      }
      _processFile(files.first);
      ReceiveSharingIntent.instance.reset();
    }).catchError((err) {
      print('getInitialSharing Shared files error: $err');
    });
  }

  static void _processFile(SharedMediaFile sharedFile) async {
    if (sharedFile.type != SharedMediaType.file || !isAudioFile(sharedFile.path)) {
      print('Not an audio file');
      return;
    }
    print('Processing shared file: ${sharedFile.path}');

    final res = Result.fromShare(sharedFile.path);

    final key = await DB.createResultAsync(res);

    await res.transcribe(key);
  }
}
