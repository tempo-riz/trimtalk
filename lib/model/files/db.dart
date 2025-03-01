import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:intl/intl.dart';
import 'package:trim_talk/model/utils.dart';
import 'package:trim_talk/types/result.dart';

const _resultBoxKey = 'results';
const _prefsBoxKey = 'prefs';
const _dummyResultKey = 'dummyRes';

enum Prefs {
  lastRun,
  isAcknowledged,
  isFirstRun,
  isTutoDone,
  isAutoTranscript,
  isTaskRunning,
  frequencyMinutes,
  transcriptLanguageCode,
  currentWhisperModel,
  isAppInForeground,
  isNotificationEnabled,
  isWatchingNotification,
  appLanguageCode,
  isDarkMode,
  isCheckingForFiles,
  isTranslated,
}

class DB {
  static Future<void> init() async {
    await Hive.initFlutter();
    // await Hive.deleteBoxFromDisk(_resultBoxKey);
    // await Hive.deleteBoxFromDisk(_dummyResultKey);
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(ResultAdapter());
    }
    // await Hive.deleteBoxFromDisk(_resultBoxKey); to clear during debug

    // if corrupted clear the box
    try {
      await Hive.openBox<Result>(_resultBoxKey);
    } catch (e) {
      debugPrint('result box is corrupted: $e');

      await Hive.deleteBoxFromDisk(_resultBoxKey);

      await Hive.openBox(_resultBoxKey);
    }

    try {
      await Hive.openBox(_prefsBoxKey);
    } catch (e) {
      debugPrint('pref box is corrupted: $e');

      await Hive.deleteBoxFromDisk(_prefsBoxKey);

      await Hive.openBox(_prefsBoxKey);
    }

    try {
      await Hive.openBox<Result>(_dummyResultKey);
      final box = await Hive.openBox<Result>(_dummyResultKey);
      if (box.isEmpty) {
        await box.add(dummyEmptyResult);
      }
    } catch (e) {
      debugPrint('result box is corrupted: $e');

      await Hive.deleteBoxFromDisk(_dummyResultKey);
    }

    // await Hive.openBox(_prefsBoxKey);
    // await Hive.openBox<Result>(_resultBoxKey);
  }

  static Box<Result> get resultBox {
    try {
      return Hive.box<Result>(_resultBoxKey);
    } catch (e) {
      // prob box not open so open it
      print("Error in opening result box: $e");
      Hive.openBox<Result>(_resultBoxKey);
    }
    return Hive.box<Result>(_resultBoxKey);
  }

  /// make sure its open
  static Future<Box<Result>> get asyncResultBox async {
    return await Hive.openBox<Result>(_resultBoxKey);
  }

  static Box get prefsBox {
    try {
      return Hive.box(_prefsBoxKey);
    } catch (e) {
      // prob box not open so open it
      print("Error in opening prefs box: $e");
      Hive.openBox(_prefsBoxKey);
    }
    return Hive.box(_prefsBoxKey);
  }

  static Box<Result> get dummyResultBox {
    try {
      return Hive.box<Result>(_dummyResultKey);
    } catch (e) {
      // prob box not open so open it
      print("Error in opening dummy result box: $e");
      Hive.openBox<Result>(_dummyResultKey);
    }
    return Hive.box<Result>(_dummyResultKey);
  }

  /// reopens the result box (to get data lost in notif action isolate)
  static Future<void> refreshResult() async {
    await resultBox.close();
    await Hive.openBox<Result>(_resultBoxKey);
  }

  static T getPref<T>(Prefs pref) {
    return prefsBox.getPref<T>(pref);
  }

  static Future<void> clearAll() async {
    await Hive.deleteBoxFromDisk(_resultBoxKey);
    await Hive.deleteBoxFromDisk(_prefsBoxKey);
  }

  static Future<void> clearResults() async {
    await Hive.deleteBoxFromDisk(_resultBoxKey);
    await Hive.openBox<Result>(_resultBoxKey);
  }

  static Future<void> setPref(Prefs pref, dynamic value) async {
    await prefsBox.put(pref.name, value);
  }
}

extension BoxPref on Box {
  T getPref<T>(Prefs pref) {
    final def = switch (pref) {
      Prefs.isAcknowledged => false,
      Prefs.isAutoTranscript => false,
      Prefs.isTaskRunning => false,
      Prefs.frequencyMinutes => 15,
      Prefs.isFirstRun => true,
      Prefs.transcriptLanguageCode => "auto", //supportedLanguages.map((L) => L.code).contains(system) ? system : 'en',
      Prefs.currentWhisperModel => '', // to check if model is downloaded or not
      Prefs.lastRun => DateTime.fromMicrosecondsSinceEpoch(0).toIso8601String(),
      Prefs.isAppInForeground => false,
      Prefs.isTutoDone => false,
      Prefs.isNotificationEnabled => false,
      Prefs.appLanguageCode => Intl.getCurrentLocale().split('_')[0],
      Prefs.isDarkMode => false,
      Prefs.isCheckingForFiles => false,
      Prefs.isWatchingNotification => false,
      Prefs.isTranslated => false,
    };
    return DB.prefsBox.get(pref.name, defaultValue: def);
  }
}

class PrefBuilder<T> extends StatelessWidget {
  const PrefBuilder({
    super.key,
    required this.builder,
    required this.pref,
  });

  final Widget Function(BuildContext context, T value) builder;
  final Prefs pref;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: DB.prefsBox.listenable(keys: [pref.name]),
        builder: (BuildContext context, Box box, Widget? child) {
          return builder(context, box.getPref<T>(pref));
        });
  }
}
