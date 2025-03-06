import 'dart:async';
import 'dart:io';

import 'package:notification_listener_service/notification_event.dart';
import 'package:notification_listener_service/notification_listener_service.dart';
import 'package:trim_talk/model/check_new.dart';

// avoid listenting multiple times
StreamSubscription<ServiceNotificationEvent>? stream;

/// sender and duration of a voice note
class ResultExtraMetadata {
  final String? author;
  final String? duration;

  ResultExtraMetadata(this.author, this.duration);
}

class NotificationWatcher {
  static Future<void> init() async {
    if (Platform.isIOS) return;
    if (!await NotificationListenerService.isPermissionGranted()) return;

// avoid listenting multiple times
    if (stream != null) {
      await stream?.cancel();
      stream = null;
    }

    stream = NotificationListenerService.notificationsStream.listen((ServiceNotificationEvent event) async {
      if (event.packageName != 'com.whatsapp') return;
      if (event.hasRemoved == true) return; // (if user dismissed the notification)
      if (event.content?.startsWith('🎤') == false) return;
      // here we know it's a whatsapp voice note (not dismissed)

      // event.id; // 1
      // remove ( and ) from the title

      // 🎤 Message vocal (0:24) -> (0:24) -> 0:24
      final String? duration = event.content?.split(' ').last.replaceAll(RegExp(r'[()]'), '');
      final String? author = event.title; // Fafa 🐣🦕🦆
      final meta = ResultExtraMetadata(author, duration);

      print(event);

      print('Voice note from $author with duration $duration');
      // wait to be sure the file exists
      await Future.delayed(const Duration(seconds: 1));

      checkForNewAudios(
        isBackground: true,
        extraMetadata: meta,
      );
    });
  }
}
