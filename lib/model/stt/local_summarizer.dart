import 'dart:io';

import 'package:edge_gen_ai/edge_gen_ai.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class LocalSummarizer {
  static final EdgeGenAISummarizer _summarizer = EdgeGenAISummarizer();
  static bool _isReady = false;

  /// Checks if Apple Intelligence or Gemini Nano is supported and prepares it.
  static Future<bool> initialize() async {
    if (_isReady) return true;

    try {
      final availability = await _summarizer.checkAvailability();

      if (availability == EdgeGenAIAvailability.available) {
        _isReady = true;
        return true;
      }

      if (availability == EdgeGenAIAvailability.downloadable) {
        // Triggers the OS to download Gemini Nano weights on Android
        await for (final progress in _summarizer.downloadModel()) {
          debugPrint('OS Model status: ${progress.status.name}');
        }
        _isReady = true;
        return true;
      }

      return false;
    } on PlatformException catch (e) {
      debugPrint('EdgeGenAI unavailable: ${e.message}');
      return false;
    }
  }

  /// Summarizes text into bullet points on-device.
  static Future<String> summarize(String text) async {
    if (Platform.isAndroid && text.trim().length < 400) {
      throw Exception('Please provide at least 400 characters to summarize.');
    }

    if (!_isReady) {
      final ready = await initialize();
      if (!ready) {
        throw Exception('On-device summarization is not supported on this device.');
      }
    }

    return await _summarizer.summarize(text);
  }
}
