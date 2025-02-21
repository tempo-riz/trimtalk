import 'package:trim_talk/model/files/db.dart';
import 'package:trim_talk/main.dart';
import 'package:workmanager/workmanager.dart';

// IF THIS DOESNT WORK, flutter clean, remove pods and retry
@pragma('vm:entry-point')
void taskCallback() async {
  // we can even use plugins in here :)
  Workmanager().executeTask((task, inputData) async {
    print("Background task: $task"); //simpleTask will be emitted here.
    // this fails (cannot send to native from a bg task)
    // potential solutions :
    // - full native workmanager that sends notif (local or firebase)
    // - implement propper communication, see IsolateNameServer (maybe possible)
    //

    // try {
    //   WidgetsFlutterBinding.ensureInitialized();
    //   final rootIsolateToken = ServicesBinding.rootIsolateToken;
    //   if (rootIsolateToken != null) {
    //     BackgroundIsolateBinaryMessenger.ensureInitialized(rootIsolateToken);
    //   }

    //   const platform = MethodChannel('com.trim_talk.app/whatsapp');
    //   final List<Map>? maps = await platform.invokeListMethod<Map>('listAfter', {
    //     "folderId": "202434",
    //     "dateInMs": "1000".toString(),
    //   });
    //   await DB.init();
    //   await DB.resultBox.addAll(maps!.map((e) => Result.fromMap(e)).toList());
    //   await DB.resultBox.add(dummyEmptyResult);
    //   await DB.resultBox.close();
    //   // await initApp();
    //   print("INIT APP DONE");
    //   // await checkForNewAudios();
    //   print("CHECK FOR NEW AUDIOS DONE");
    // } catch (e) {
    //   await DB.init();

    //   await DB.resultBox.add(dummyLoadingResult);

    //   print("Error in background task: $e");
    //   return Future.error(e);
    // }
    // I/flutter ( 7380): Error in background task: MissingPluginException(No implementation found for method getPersistedUris on channel com.trim_talk.app/whatsapp)
// I/NotificationManager( 7380): com.trimtalk.app: notify(-744716756, null, Notification(channel=WorkmanagerDebugChannelId shortcut=null contentView=null vibrate=null sound=null defaults=0x0 flags=0x0 color=0x00000000 vis=PRIVATE semFlags=0x0 semPriority=0 semMissedCount=0)) as user

    // this code works in bg
    // try {
    //   await DB.init();
    //   await DB.resultBox.add(dummyResultWithTranscript);
    //   // await DB.resultBox.close();
    // } catch (e) {
    //   print("Error in background task: $e");
    //   return Future.value(false);
    // }

    return Future.value(true);
  });
}

const _uniqueName = "uniqueTaskName";

/// background task (workmanager)
class Task {
  /// to cancel the task

  /// setup the background task
  static Future<void> init() async {
    // https: //pub.dev/packages/workmanager
    await Workmanager().initialize(taskCallback, // The top level function, aka callbackDispatcher
        isInDebugMode: isDebug // If enabled it will post a notification whenever the task is running. Handy for debugging tasks
        );

    print("Task setup done");
  }

  /// will start the task in the background (first execution is immediate)  send a confirmation notif
  static Future<void> start({bool updateView = true}) async {
    if (updateView) DB.setPref(Prefs.isTaskRunning, true);

    await Workmanager().registerPeriodicTask(
      _uniqueName, "periodicTaskName",
      initialDelay: const Duration(seconds: 3), // start after 5 seconds to avoid slider to be stuck
      frequency: Duration(minutes: DB.getPref(Prefs.frequencyMinutes)), // cannot be less than 15 minutes (android limitation)

      // existingWorkPolicy: ExistingWorkPolicy.replace,
      // constraints: Constraints(
      //   // connected or metered mark the task as requiring internet
      //   networkType: NetworkType.not_required,
      // ),
      // inputData: <String, dynamic>{},
      // outOfQuotaPolicy: OutOfQuotaPolicy.run_as_non_expedited_work_request, // this throws an error
    );
    // await NotificationHandler.showNotification(
    //     title: "Ready to trim !", body: "Now when you receive a WhatsApp audio, we will ask you if you want to trim it :)");
  }

  static Future<void> cancel({bool updateView = true}) async {
    if (updateView) DB.setPref(Prefs.isTaskRunning, false);
    await Workmanager().cancelByUniqueName(_uniqueName);
  }

  static bool isRunning() {
    return DB.getPref(Prefs.isTaskRunning);

    // /// will look if last run is older than 24h or not
    // final lastRun = Prefs.getLastRunTime();
    // final now = DateTime.now();
    // final diff = now.difference(lastRun);
    // return diff.inHours < 24;
  }
}

// NOT NEEDED WITH: existingWorkPolicy: ExistingWorkPolicy.replace, clean up the task before if it already exists
// await cancelTask();
// Workmanager().registerOneOffTask("task-identifier", "simpleTask");
