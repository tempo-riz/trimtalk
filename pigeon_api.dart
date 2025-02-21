import 'package:pigeon/pigeon.dart';

/// Result of a file operation
class NativeResult {
  String path;
  int dateMs;
  int durationMs;
  String name;

  NativeResult({
    required this.path,
    required this.dateMs,
    required this.durationMs,
    required this.name,
  });
}

// these options are not used (need to specify in args)
@ConfigurePigeon(PigeonOptions(
  dartPackageName: 'com.example.pigeon_example',
  dartOut: 'lib/model/files/platform/pigeon_api.g.dart',
  dartOptions: DartOptions(),
  kotlinOut: 'android/app/src/main/kotlin/com/example/trim_talk/pigeon_api.g.kt',
  kotlinOptions: KotlinOptions(),
  // swiftOut: 'ios/Runner/pigeon.g.swift',
  // swiftOptions: SwiftOptions(),
))

// https://github.com/flutter/packages/blob/main/packages/pigeon/example/README.md#HostApi_Example
// @async keyword -> give a callback in kotlin args
@HostApi()
abstract class NativePigeonApi {
  @async
  String? pickFolder();

  List<String> getPersistedUrisPermissions();

  Uint8List? readFileBytes(String uri);

  @async
  List<NativeResult> listAfter(String folderId, int timeMilis);
}
