// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:math';

import 'package:hive/hive.dart';

import 'package:trim_talk/model/files/platform/pigeon_api.g.dart';
import 'package:trim_talk/model/utils.dart';

part 'result.g.dart';

// update using: dart run build_runner build -d
@HiveType(typeId: 1)
class Result extends HiveObject {
  @HiveField(0)
  final String date;

  @HiveField(1)
  final String duration;

  /// can be uri
  @HiveField(2)
  final String path;

  @HiveField(3)
  final String filename;

  @HiveField(4)
  final String? transcript;

  @HiveField(5)
  final String? summary;

  /// used to show loading indicator
  @HiveField(6)
  final bool loadingTranscript;

  @HiveField(7)
  final bool loadingSummary;

  @HiveField(8)
  final String? sender;

  @HiveField(9)
  final String? groupId;

  Result({
    required this.date,
    required this.duration,
    required this.path,
    required this.filename,
    this.transcript,
    this.summary,
    this.loadingTranscript = false,
    this.loadingSummary = false,
    this.sender,
    this.groupId,
  });

  factory Result.dummy() {
    return Result(
      transcript: dummyTranscript,
      date: dummyDate,
      duration: dummyDuration,
      summary: "summary${Random().nextInt(100)}",
      path: "path",
      filename: "filename",
    );
  }

  factory Result.fromShare(String path, String? groupId) {
    return Result(
      date: formatAudioDate(DateTime.now()),
      duration: "",
      path: path,
      filename: path.split('/').last,
      groupId: groupId,
    );
  }

  factory Result.fromNative(NativeResult res) {
    final datetime = DateTime.fromMillisecondsSinceEpoch(res.dateMs);
    final dur = Duration(milliseconds: res.durationMs);

    return Result(
      date: formatAudioDate(datetime),
      duration: formatDuration(dur),
      path: res.path,
      filename: res.name,
    );
  }

  /// used on return of android method chanel
  factory Result.fromMap(Map map) {
    final String path = map["path"];
    final int date = map["date"];
    final int durationMs = map["duration"];
    final String name = map["name"];

    final datetime = DateTime.fromMillisecondsSinceEpoch(date);
    final dur = Duration(milliseconds: durationMs);

    return Result(
      date: formatAudioDate(datetime),
      duration: formatDuration(dur),
      path: path,
      filename: name,
    );
  }

  Result copyWith({
    String? date,
    String? duration,
    String? path,
    String? filename,
    String? transcript,
    String? summary,
    bool? loadingTranscript,
    bool? loadingSummary,
    String? sender,
  }) {
    return Result(
      date: date ?? this.date,
      duration: duration ?? this.duration,
      path: path ?? this.path,
      filename: filename ?? this.filename,
      transcript: transcript ?? this.transcript,
      summary: summary ?? this.summary,
      loadingTranscript: loadingTranscript ?? this.loadingTranscript,
      loadingSummary: loadingSummary ?? this.loadingSummary,
      sender: sender ?? this.sender,
    );
  }

  @override
  bool operator ==(covariant Result other) {
    if (identical(this, other)) return true;

    return other.date == date &&
        other.duration == duration &&
        other.path == path &&
        other.filename == filename &&
        other.transcript == transcript &&
        other.summary == summary &&
        other.loadingTranscript == loadingTranscript &&
        other.loadingSummary == loadingSummary &&
        other.sender == sender;
  }

  @override
  int get hashCode {
    return date.hashCode ^
        duration.hashCode ^
        path.hashCode ^
        filename.hashCode ^
        transcript.hashCode ^
        summary.hashCode ^
        loadingTranscript.hashCode ^
        loadingSummary.hashCode ^
        sender.hashCode;
  }

  @override
  String toString() {
    return 'Result(date: $date, duration: $duration, path: $path, filename: $filename, transcript: $transcript, summary: $summary, loading: $loadingTranscript $loadingSummary sender: $sender)';
  }
}
