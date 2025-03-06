import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:trim_talk/model/files/db.dart';
import 'package:trim_talk/model/notif/notification_sender.dart';
import 'package:trim_talk/model/stt/result_extensions.dart';
import 'package:trim_talk/model/check_new.dart';
import 'package:trim_talk/main.dart';
import 'package:trim_talk/router.dart';

enum ActionType { dismiss, transcribe, summarize, copy }

const chanelId = 'TrimTalk';
const chanelName = 'TrimTalk notifications';

/// This callback only called by app's own notifications interactions
/// when user tap the notif (action id is null) or tap an action button -> actionId is not null
@pragma('vm:entry-point')
void onNotification(NotificationResponse notif) async {
  await initApp(); // prefs uninitialized if action so we make sure it's initialized

  if (notif.notificationResponseType == NotificationResponseType.selectedNotification) {
    // open the app in foreground
    onNotifTap(notif);
  } else if (notif.notificationResponseType == NotificationResponseType.selectedNotificationAction) {
    // doesnt open the app in foreground
    onActionTap(notif);
  }
}

/// transcribe if no transcription in payload otherwise show the result in app
/// TAP WILL OPEN THE APP
void onNotifTap(NotificationResponse notif) async {
  final notifId = notif.id!;
  if (notif.payload == null || notif.payload!.isEmpty) {
    print('No payload in notification');
    return;
  }

  final resKey = int.parse(notif.payload!);

  final res = DB.resultBox.get(resKey);
  if (res == null) return NotificationSender.showError(notifId, "Failed to transcribe (no result)");

  if (res.transcript != null) {
    // if there is transcipt in the payload, show it in page
    router.goNamed(NamedRoutes.dashboard.name);
    return;
  }
  //otherwise transcribe it

  final transcribed = await res.transcribe(resKey);

  if (transcribed.transcript == null) {
    return NotificationSender.showError(notifId, "Failed to transcribe ${res.duration} (empty result)");
  }
}

/// ACTION TAP WILL NOT OPEN THE APP -> talk in notif to user
void onActionTap(NotificationResponse notif) {
  if (notif.payload == null) return;
  final resKey = int.parse(notif.payload!);

  switch (ActionType.values.firstWhere((a) => a.name == notif.actionId)) {
    case ActionType.transcribe:
      transcribeFileAndShowResult(resKey);
      break;

    case ActionType.dismiss:
      NotificationSender.clear(notif.id!);
      break;

    case ActionType.summarize:
      // TODO: implement summarize
      break;

    case ActionType.copy:
      // Todo fix this - Not working !
      final res = DB.resultBox.get(resKey);
      if (res == null) return;
      Clipboard.setData(ClipboardData(text: res.transcript ?? 'empty transcript'));
      break;
  }
}
