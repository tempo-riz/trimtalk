import 'dart:io';

// import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit.dart';
// import 'package:ffmpeg_kit_flutter_new/ffmpeg_session.dart';
// import 'package:ffmpeg_kit_flutter_new/ffprobe_kit.dart';
// import 'package:ffmpeg_kit_flutter_new/return_code.dart';

/// Wrapper for ffmpeg utility functions
class AudioTools {
  // Preprocessing Audio Files
// Our speech-to-text models will downsample audio to 16,000 Hz mono before transcribing. This preprocessing can be performed client-side to reduce file size and allow longer files to be uploaded to Groq.

// The following ffmpeg command can be used to reduce file size:

// CopyCopy code
// ffmpeg \
//   -i <your file> \
//   -ar 16000 \
//   -ac 1 \
//   -map 0:a: \
//   <output file name>

  /// convert [audioInput] to wav file (same location with .wav extension)
  static Future<File?> convertToWav(File inputFile, {String? outputDir}) async {
    return null;
    // // if already wav return the file
    // if (inputFile.path.endsWith('.wav')) {
    //   print('File is already a wav file');
    //   return inputFile;
    // }
    // // create a new file with the same name but with .wav extension
    // final destDir = outputDir ?? inputFile.parent.path;
    // final filename = inputFile.path.split('/').last.split('.').first;

    // final File outputFile = File('$destDir/$filename.wav');
    // print('Converting ${inputFile.path} to ${outputFile.path}');
    // // ffmpeg -i input.opus -ar 16000 -ac 1 -map 0:a -c:a pcm_s16le output.wav
    // final FFmpegSession session = await FFmpegKit.execute(
    //   [
    //     '-y', // Overwrite output file if exists
    //     '-i', inputFile.path, // Input file
    //     '-ar', '16000', // Set the audio sample rate to 16000 Hz
    //     '-ac', '1', // Set the number of audio channels to 1 (mono)
    //     '-map', '0:a', // Map only the audio stream
    //     '-c:a', 'pcm_s16le', // Set the audio codec to pcm_s16le
    //     outputFile.path // Output file path (will handle the extension automatically)
    //   ].join(' '),
    // );

    // final ReturnCode? returnCode = await session.getReturnCode();

    // if (ReturnCode.isSuccess(returnCode)) {
    //   print("converted to wav successfully");
    //   return outputFile;
    // } else if (ReturnCode.isCancel(returnCode)) {
    //   print('File convertion canceled');
    // } else {
    //   final output = await session.getAllLogsAsString();
    //   final errorLogs = await session.getFailStackTrace();
    //   print("Output: $output");
    //   print("Error: $errorLogs");
    //   print(
    //     'File convertion error with returnCode ${returnCode?.getValue()}',
    //   );
    // }

    // return null;
  }

  static Future<File?> convertToMp3(File inputFile) async {
    return null;
    // if (inputFile.path.endsWith('.mp3')) {
    //   return inputFile;
    // }
    // final destDir = inputFile.parent.path;
    // final filename = inputFile.path.split('/').last.split('.').first;

    // final File outputFile = File('$destDir/$filename.mp3');

    // String command = '-i ${inputFile.path} -c:a libmp3lame ${outputFile.path}';

    // final FFmpegSession session = await FFmpegKit.execute(command);

    // final ReturnCode? returnCode = await session.getReturnCode();

    // if (ReturnCode.isSuccess(returnCode)) {
    //   return outputFile;
    // } else if (ReturnCode.isCancel(returnCode)) {
    //   print('File convertion canceled');
    // } else {
    //   final output = await session.getAllLogsAsString();
    //   final errorLogs = await session.getFailStackTrace();
    //   print("Output: $output");
    //   print("Error: $errorLogs");
    //   print(
    //     'File convertion error with returnCode ${returnCode?.getValue()}',
    //   );
    // }

    // return null;
  }

  /// returns the files and total duration of the audio file
  static Future<(List<File>, double)?> splitAudio(File inputFile) async {
    return null;
    // // Get the size of the input file
    // final fileSizeInBytes = await inputFile.length();

    // print(inputFile.path);
    // // print in mb
    // print('File size: ${fileSizeInBytes / (1024 * 1024)} MB');

    // // Calculate the number of parts
    // const double maxSizeInBytes = 25.0 * 1024 * 1024; // 25 MB
    // double rawNumberOfParts = fileSizeInBytes / maxSizeInBytes;
    // print('Raw number of parts: $rawNumberOfParts');
    // final numberOfParts = rawNumberOfParts.ceil();

    // print('Splitting audio file into $numberOfParts parts');

    // // Get the duration of the audio file
    // final duration = await getAudioDuration(inputFile.path);
    // if (duration == null) {
    //   print('Error getting audio duration');
    //   return null;
    // }

    // final fullFileName = inputFile.path.split('/').last;

    // final filename = fullFileName.split('.').first;
    // final ext = fullFileName.split('.').last;

    // final outputFiles = <File>[];

    // // Calculate duration for each part
    // final partDuration = duration / numberOfParts;

    // print('Duration: $duration, Part duration: $partDuration');

    // for (int i = 0; i < numberOfParts; i++) {
    //   final startTime = partDuration * i;
    //   final outputFilePath = '${inputFile.parent.path}/${filename}_part$i.$ext';

    //   // FFmpeg command to split the audio file
    //   final command = '-y -i ${inputFile.path} -ss $startTime -t $partDuration $outputFilePath';
    //   final session = await FFmpegKit.execute(command);
    //   print('Created: $outputFilePath');
    //   final returnCode = await session.getReturnCode();
    //   if (ReturnCode.isSuccess(returnCode)) {
    //     outputFiles.add(File(outputFilePath));
    //   } else {
    //     print('Error splitting file $i: $outputFilePath');
    //     return null;
    //   }
    // }
    // return outputFiles.isNotEmpty ? (outputFiles, duration) : null;
  }

  static Future<double?> getAudioDuration(String mediaPath) async {
    return null;
    // final mediaInfoSession = await FFprobeKit.getMediaInformation(mediaPath);
    // final mediaInfo = mediaInfoSession.getMediaInformation();

    // // the given duration is in fractional seconds
    // final strDur = mediaInfo?.getDuration();
    // if (strDur == null) {
    //   return null;
    // }
    // final duration = double.parse(strDur);
    // print('Duration: $duration');
    // return duration;
  }
}
