// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';
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

  /// in milliseconds
  @HiveField(10)
  final int dateMs;

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
    required this.dateMs,
  });

  factory Result.dummy() {
    return Result(
      transcript: dummyTranscript,
      date: dummyDate,
      duration: dummyDuration,
      summary: "summary${Random().nextInt(100)}",
      path: "path",
      filename: "filename",
      dateMs: DateTime.now().millisecondsSinceEpoch,
    );
  }

  factory Result.fromShare(String path, String? groupId) {
    return Result(
      date: formatAudioDate(DateTime.now()),
      dateMs: DateTime.now().millisecondsSinceEpoch,
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
      dateMs: res.dateMs,
    );
  }

  /// used on return of android method chanel
  factory Result.fromMap(Map<String, dynamic> map) {
    return Result(
      date: map['date'] as String,
      duration: map['duration'] as String,
      path: map['path'] as String,
      filename: map['filename'] as String,
      transcript: map['transcript'] != null ? map['transcript'] as String : null,
      summary: map['summary'] != null ? map['summary'] as String : null,
      loadingTranscript: map['loadingTranscript'] as bool,
      loadingSummary: map['loadingSummary'] as bool,
      sender: map['sender'] != null ? map['sender'] as String : null,
      groupId: map['groupId'] != null ? map['groupId'] as String : null,
      dateMs: map['dateMs'] as int,
    );
  }

  @override
  String toString() {
    return 'Result(date: $date, duration: $duration, path: $path, filename: $filename, transcript: $transcript, summary: $summary, loadingTranscript: $loadingTranscript, loadingSummary: $loadingSummary, sender: $sender, groupId: $groupId, dateMs: $dateMs)';
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
    String? groupId,
    int? dateMs,
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
      groupId: groupId ?? this.groupId,
      dateMs: dateMs ?? this.dateMs,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'date': date,
      'duration': duration,
      'path': path,
      'filename': filename,
      'transcript': transcript,
      'summary': summary,
      'loadingTranscript': loadingTranscript,
      'loadingSummary': loadingSummary,
      'sender': sender,
      'groupId': groupId,
      'dateMs': dateMs,
    };
  }

  String toJson() => json.encode(toMap());

  factory Result.fromJson(String source) => Result.fromMap(json.decode(source) as Map<String, dynamic>);

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
        other.sender == sender &&
        other.groupId == groupId &&
        other.dateMs == dateMs;
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
        sender.hashCode ^
        groupId.hashCode ^
        dateMs.hashCode;
  }
}
