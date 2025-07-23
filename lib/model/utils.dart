import 'package:trim_talk/model/utils.dart';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:just_audio/just_audio.dart';
import 'package:mime/mime.dart';
import 'package:trim_talk/l10n/gen/app_localizations.dart';
import 'package:trim_talk/model/files/db.dart';
import 'package:trim_talk/types/result.dart';
import 'package:trim_talk/router.dart';
import 'package:trim_talk/types/language.dart';
import 'package:week_of_year/date_week_extensions.dart';

/// Calculates number of weeks for a given year as per https://en.wikipedia.org/wiki/ISO_week_date#Weeks_per_year
// int numOfWeeks(int year) {
//   DateTime dec28 = DateTime(year, 12, 28);
//   int dayOfDec28 = int.parse(DateFormat("D").format(dec28));
//   // maybe a floor() here
//   return ((dayOfDec28 - dec28.weekday + 10) / 7).round();
// }

/// Calculates week number from a date as per https://en.wikipedia.org/wiki/ISO_week_date#Calculation
int weekNumber(DateTime date) {
  print("weekNumber: $date");
  return date.weekOfYear;
}

int randomInt32() {
  return Random().nextInt(2000000);
}

// check that filename is correct (today) : .../WhatsApp Voice Notes/yyyyww/PTT-yyyymmdd-WA0001.opus
//check if its a file, and if it was created today

bool isToday(File file) {
  final now = DateTime.now();
  final fileDate = file.statSync().modified;
  return now.year == fileDate.year && now.month == fileDate.month && now.day == fileDate.day;
}

/// Year + week number
String getLatestAudioNoteDirId() {
  final year = DateFormat("yyyy").format(DateTime.now());
  final week = weekNumber(DateTime.now()).toString().padLeft(2, '0');
  return "$year$week";
}

bool yesterdayWasAnotherWeekNumber() {
  final today = DateTime.now();
  final yesterday = today.subtract(const Duration(days: 1));
  return weekNumber(yesterday) != weekNumber(today);
}

/// if yesterday was another week number, return the dir id for yesterday, else return null
String? getYersterdayAudioNoteDirId() {
  if (!yesterdayWasAnotherWeekNumber()) {
    return null;
  }
  final yesterday = DateTime.now().subtract(const Duration(days: 1));
  return "${DateFormat("yyyy").format(yesterday)}${weekNumber(yesterday)}";
}

void log(String message) {
  print("[${DateTime.now()}] $message");
}

void listDirDebug(String path) {
  final dir = Directory(path);
  final files = dir.listSync();

  print("Listing ${files.length} ");

  //sort by date
  files.sort((a, b) => b.statSync().modified.compareTo(a.statSync().modified));

  for (final file in files) {
    final stat = file.statSync();
    print(file.path);
    print(stat);
  }
}

String formatDuration(Duration? duration) {
  if (duration == null) {
    return "?";
  }
  int hours = duration.inHours;
  int minutes = duration.inMinutes.remainder(60);
  int seconds = duration.inSeconds.remainder(60);
  String res = '$minutes:${pad2(seconds)}';
  if (hours > 0) {
    res = '$hours:$res';
  }

  return res;
}

Duration parseDuration(String durationStr) {
  List<String> parts = durationStr.split(':');
  // remove possible (x3) in last part
  parts[parts.length - 1] = parts.last.split(' (')[0];

  int seconds = 0, minutes = 0, hours = 0;

  if (parts.length == 2) {
    // Format is MM:SS
    minutes = int.parse(parts[0]);
    seconds = int.parse(parts[1]);
  } else if (parts.length == 3) {
    // Format is HH:MM:SS
    hours = int.parse(parts[0]);
    minutes = int.parse(parts[1]);
    seconds = int.parse(parts[2]);
  }

  return Duration(hours: hours, minutes: minutes, seconds: seconds);
}

String pad2(int value) {
  return value.toString().padLeft(2, '0');
}

extension FormatDateTime on DateTime {
  String toReadable() {
    final now = DateTime.now();
    final difference = now.difference(this);

    final context = getContext;
    if (context == null) {
      return "";
    }

    if (difference.inDays == 0) {
      return " ${DateFormat('HH:mm').format(this)}";
    } else if (difference.inDays == 1) {
      return "${context.t.yesterdayAt} ${DateFormat('HH:mm').format(this)}";
    } else {
      if (difference.inDays > 365) {
        return context.t.never;
      }
      return DateFormat('EEE dd/MM, HH:mm').format(this);
    }
  }
}

extension Str on String {
  String log() {
    print(this);
    return this;
  }

  String capitalize() {
    if (isEmpty) {
      return this;
    }
    return "${this[0].toUpperCase()}${substring(1)}";
  }

  String toReadableTime() {
    return DateTime.parse(this).toReadable();
  }
}

BuildContext? get getContext => router.routerDelegate.navigatorKey.currentState?.context ?? router.routerDelegate.navigatorKey.currentContext;

void showLoader() async {
  print("showLoader");
  final ctx = getContext;
  if (ctx == null) {
    return;
  }
  showDialog(
    context: ctx,
    barrierDismissible: true,
    builder: (BuildContext context) {
      return const Dialog(
        backgroundColor: Colors.transparent,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Trimming...", style: TextStyle(color: Colors.white)),
              gap16,
              CircularProgressIndicator(
                backgroundColor: Colors.white,
              ),
            ],
          ),
        ),
      );
    },
  );
}

void showSnackBar(String message) {
  final ctx = getContext;
  if (ctx == null) {
    return;
  }
  ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
    content: Text(message),
    behavior: SnackBarBehavior.floating,
    showCloseIcon: true,
  ));
}

void hideLoader() {
  print("hideLoader");

  final ctx = getContext;
  if (ctx == null) {
    return;
  }
  if (Navigator.of(ctx, rootNavigator: true).canPop()) {
    Navigator.of(ctx, rootNavigator: true).pop();
  }
}

/// Constant sizes to be used in the app (paddings, gaps, rounded corners etc.)
class Sizes {
  static const p4 = 4.0;
  static const p8 = 8.0;
  static const p12 = 12.0;
  static const p14 = 14.0;
  static const p16 = 16.0;
  static const p20 = 20.0;
  static const p24 = 24.0;
  static const p26 = 26.0;
  static const p28 = 28.0;
  static const p32 = 32.0;
  static const p36 = 36.0;
  static const p40 = 40.0;
  static const p48 = 48.0;
  static const p64 = 64.0;
  static const p128 = 128.0;
}

/// Constant gap widths
const gapW4 = SizedBox(width: Sizes.p4);
const gapW8 = SizedBox(width: Sizes.p8);
const gapW12 = SizedBox(width: Sizes.p12);
const gapW16 = SizedBox(width: Sizes.p16);
const gapW20 = SizedBox(width: Sizes.p20);
const gapW24 = SizedBox(width: Sizes.p24);
const gapW32 = SizedBox(width: Sizes.p32);
const gapW48 = SizedBox(width: Sizes.p48);
const gapW64 = SizedBox(width: Sizes.p64);
const gapW128 = SizedBox(width: Sizes.p128);

/// Constant gap heights
const gapH4 = SizedBox(height: Sizes.p4);
const gapH8 = SizedBox(height: Sizes.p8);
const gapH12 = SizedBox(height: Sizes.p12);
const gapH16 = SizedBox(height: Sizes.p16);
const gapH20 = SizedBox(height: Sizes.p20);
const gapH24 = SizedBox(height: Sizes.p24);
const gapH32 = SizedBox(height: Sizes.p32);
const gapH48 = SizedBox(height: Sizes.p48);
const gapH64 = SizedBox(height: Sizes.p64);
const gapH128 = SizedBox(height: Sizes.p128);

/// same but square gap
const gap4 = SizedBox(width: Sizes.p4, height: Sizes.p4);
const gap8 = SizedBox(width: Sizes.p8, height: Sizes.p8);
const gap12 = SizedBox(width: Sizes.p12, height: Sizes.p12);
const gap16 = SizedBox(width: Sizes.p16, height: Sizes.p16);
const gap20 = SizedBox(width: Sizes.p20, height: Sizes.p20);
const gap24 = SizedBox(width: Sizes.p24, height: Sizes.p24);
const gap32 = SizedBox(width: Sizes.p32, height: Sizes.p32);
const gap48 = SizedBox(width: Sizes.p48, height: Sizes.p48);
const gap64 = SizedBox(width: Sizes.p64, height: Sizes.p64);
const gap128 = SizedBox(width: Sizes.p128, height: Sizes.p128);

String minutesToString(int minutes) {
  if (minutes < 60) {
    return "$minutes min";
  } else {
    final int hours = minutes ~/ 60;
    final int mins = minutes % 60;
    if (hours == 1) {
      return mins == 0 ? "$hours hour" : "$hours hour $mins min";
    } else {
      return mins == 0 ? "$hours hours" : "$hours hours $mins min";
    }
  }
}

/// [0,1] -> 15 min, 30 min, 1 hour, 3 hours, 6 hours, 12 hours  (6 options)
int sliderToMinutes(double value) {
  if (value == 0.0) return 15; // 15 minutes
  if (value == 0.2) return 30; // 30 minutes
  if (value == 0.4) return 60; // 1 hour
  if (value == 0.6) return 180; // 3 hours
  if (value == 0.8) return 360; // 6 hours
  if (value == 1.0) return 720; // 12 hours

  return 15;
}

double minutesToSlider(int minutes) {
  if (minutes == 15) return 0.0;
  if (minutes == 30) return 0.2;
  if (minutes == 60) return 0.4;
  if (minutes == 180) return 0.6;
  if (minutes == 360) return 0.8;
  if (minutes == 720) return 1.0;

  return 0.0;
}

final supportedAppLanguages = [
  Language("English", "en", "us"),
  Language("French", "fr", "fr"),
];

/// (code, name)
final supportedTranscritionLanguages = [
  // name, lanaguge code, country code (flag)
  Language("Auto", "auto", ""),

  Language("English", "en", "us"),
  Language("French", "fr", "fr"),
  Language("Spanish", "es", "es"),
  Language("German", "de", "de"),
  Language("Italian", "it", "it"),
  Language("Portuguese", "pt", "pt"),
  Language("Dutch", "nl", "nl"),
  Language("Polish", "pl", "pl"),
  Language("Romanian", "ro", "ro"),
  Language("Greek", "el", "gr"),
  //
  Language("Afrikaans", "af", "za"),
  Language("Arabic", "ar", "sa"),
  Language("Armenian", "hy", "am"),
  Language("Azerbaijani", "az", "az"),
  Language("Belarusian", "be", "by"),
  Language("Bosnian", "bs", "ba"),
  Language("Bulgarian", "bg", "bg"),
  Language("Catalan", "ca", "es"),
  Language("Chinese", "zh", "cn"),
  Language("Croatian", "hr", "hr"),
  Language("Czech", "cs", "cz"),
  Language("Danish", "da", "dk"),
  Language("Dutch", "nl", "nl"),
// Language("English", "en", "us"),
  Language("Estonian", "et", "ee"),
  Language("Finnish", "fi", "fi"),
// Language("French", "fr", "fr"),
  Language("Galician", "gl", "es"),
// Language("German", "de", "de"),
// Language("Greek", "el", "gr"),
  Language("Hebrew", "he", "il"),
  Language("Hindi", "hi", "in"),
  Language("Hungarian", "hu", "hu"),
  Language("Icelandic", "is", "is"),
  Language("Indonesian", "id", "id"),
// Language("Italian", "it", "it"),
  Language("Japanese", "ja", "jp"),
  Language("Kannada", "kn", "in"),
  Language("Kazakh", "kk", "kz"),
  Language("Korean", "ko", "kr"),
  Language("Latvian", "lv", "lv"),
  Language("Lithuanian", "lt", "lt"),
  Language("Macedonian", "mk", "mk"),
  Language("Malay", "ms", "my"),
  Language("Marathi", "mr", "in"),
  Language("Maori", "mi", "nz"),
  Language("Nepali", "ne", "np"),
// Language("Norwegian", "no", "no"),
  Language("Persian", "fa", "ir"),
// Language("Polish", "pl", "pl"),
  Language("Portuguese", "pt", "pt"),
// Language("Romanian", "ro", "ro"),
  Language("Russian", "ru", "ru"),
  Language("Serbian", "sr", "rs"),
  Language("Slovak", "sk", "sk"),
  Language("Slovenian", "sl", "si"),
// Language("Spanish", "es", "es"),
  Language("Swahili", "sw", "ke"),
  Language("Swedish", "sv", "se"),
  Language("Tagalog", "tl", "ph"),
  Language("Tamil", "ta", "in"),
  Language("Thai", "th", "th"),
  Language("Turkish", "tr", "tr"),
  Language("Ukrainian", "uk", "ua"),
  Language("Urdu", "ur", "pk"),
  Language("Vietnamese", "vi", "vn"),
// Language("Welsh", "cy", "gb")
];

const dummyTranscript =
    "Hey, it's Bob. So, the other day, I was out for a walk in the park, just enjoying the fresh air, you know? And I stumbled upon this rock. Nothing special about it, just your average rock sitting there on the ground. But for some reason, it caught my attention. I started wondering how long it had been there, how many people had walked past it without noticing. Isn't it funny how something so ordinary can make you stop and think? Anyway, that's my rock story. Hope you found it as fascinating as I did. Alright, talk to you later. Bye.";

const shortDummyTranscript = "Hey, it's Bob. So, the other day, I was out for a walk in the park, just enjoying the fresh air, you know?";
const dummyDuration = "3:48";
const dummyDate = "Received at 12:13";

final dummyEmptyResult = Result(
  date: dummyDate,
  dateMs: DateTime.now().millisecondsSinceEpoch,
  duration: dummyDuration,
  path: "",
  filename: "",
);

final dummyLoadingResult = dummyEmptyResult.copyWith(loadingTranscript: true);

final dummyResultWithTranscript = dummyEmptyResult.copyWith(transcript: dummyTranscript);

final dummyResultWithShortTranscript = dummyEmptyResult.copyWith(transcript: shortDummyTranscript);

final dummyResultWithTranscriptAndSummaty = dummyResultWithTranscript.copyWith(
    summary: "Bob noticed an ordinary rock during a walk in the park. It made him reflect on how simple things can catch attention and provoke thought.");

extension FilesToResult on List<File> {
  Future<List<Result>> toResults() async {
    final results = <Result>[];
    for (final file in this) {
      final dur = await getAudioFileDuration(file.path);
      final date = await getAudioFileDate(file);

      results.add(Result(
        date: date,
        duration: dur,
        path: file.path,
        filename: file.path.split("/").last,
        dateMs: DateTime.now().millisecondsSinceEpoch,
      ));
    }
    return results;
  }
}

/// mm:ss
Future<String> getAudioFileDuration(String path) async {
  // if (isDebug) return dummyDuration; // for testing (no need to load the whole file
  return formatDuration(await AudioPlayer().setFilePath(path, preload: true)); // need to preload to get the duration, will it load the whole file?
}

/// recieved at hh:mm
Future<String> getAudioFileDate(File f) async {
  // if (isDebug) return dummyDate; // for testing
  final date = await f.lastModified();
  return formatAudioDate(date);
}

String formatAudioDate(DateTime date) {
// if yesterday or older, return date "yesterday" or "2 days ago"
  final diffInDays = (DateTime.now().day - date.day).abs();

  final d = DateFormat("HH:mm").format(date);

  final context = getContext;
  if (context == null) {
    return "";
  }

  if (diffInDays == 0) {
    return "${context.t.receivedAt} $d"; // 17 chars
  }

  if (diffInDays == 1) {
    return "${context.t.yesterdayAt} $d"; // 18
  }

  final String code = DB.getPref(Prefs.appLanguageCode);
  if (code == "fr") {
    return "il y a $diffInDays jours à $d";
  }

  return "$diffInDays ${context.t.daysAgoAt} $d";
}

extension L10nBuildContext on BuildContext {
  AppLocalizations get t => AppLocalizations.of(this);
}

bool isAudioFile(String filePath) {
  if (filePath.split('.').last == 'opus') {
    return true;
  }
  final mimeType = lookupMimeType(filePath);
  return mimeType != null && mimeType.startsWith('audio/');
}
