import 'package:flutter/foundation.dart';
import 'package:flutter_edge_ai/flutter_edge_ai.dart';
import 'package:flutter_edge_ai_builtin_ai/flutter_edge_ai_builtin_ai.dart';

bool _isInitialized = false;

class LocalSummarizer {
  /// 1. Register the BuiltInAiEngine and check if the device supports it.
  static Future<bool> initialize() async {
    if (_isInitialized) return true;

    await FlutterEdgeAi.initialize(
      inferenceEngines: const [BuiltInAiEngine()],
    );

    final status = await BuiltInAi.availability();
    if (status != BuiltInAiAvailability.available && status != BuiltInAiAvailability.downloadable) {
      print('Built-in AI is not available on this device: $status');
      return false;
    }

    // Ensures the OS feature is enabled and downloads system weights if downloadable
    await BuiltInAi.ensureReady(
      onProgress: (percent) => debugPrint('Preparing OS AI: $percent%'),
    );

    // Record the built-in model identity (0 MB downloaded by your app)
    await FlutterEdgeAi.installModel(
      modelType: ModelType.general,
      fileType: ModelFileType.builtIn,
    ).fromBundled(BuiltInAiModels.forCurrentPlatform!.name).install();

    _isInitialized = true;
    return true;
  }

  /// 2. Summarize input text using a single-turn session.
  static Future<String?> summarize(String prompt) async {
    if (!_isInitialized) {
      final ready = await initialize();
      if (!ready) {
        throw Exception('Built-in AI is not supported on this device.');
      }
    }

    final model = await FlutterEdgeAi.getActiveModel(maxTokens: 2048);
    final session = await model.openSession();

    try {
      await session.addQueryChunk(Message(text: prompt, isUser: true));
      final summary = await session.getResponse();
      return summary.trim();
    } catch (e) {
      print('Error during local summarization: $e');
      return null;
    } finally {
      // Always close the session to free native memory
      await session.close();
    }
  }
}
