import 'dart:math';

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:trim_talk/model/utils.dart';

class AudioPlayerStandard extends StatefulWidget {
  const AudioPlayerStandard({super.key, required this.path, required this.duration});

  final String path;
  final String duration;

  @override
  State<AudioPlayerStandard> createState() => _AudioPlayerStandardState();
}

class _AudioPlayerStandardState extends State<AudioPlayerStandard> {
  final player = AudioPlayer();

  bool isPlaying = false;
  bool hasError = false;

  @override
  void initState() {
    super.initState();
    initPlayer();
  }

  void initPlayer() async {
    try {
      await player.setFilePath(widget.path, preload: true);
    } catch (e) {
      setState(() {
        hasError = true;
      });
      print('Error setting file path ${widget.path} standard player: $e');
    }
  }

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    player.playerStateStream.listen((event) {
      if (!context.mounted) return;
      if (event.playing) {
        setState(() {
          isPlaying = true;
        });
      } else {
        setState(() {
          isPlaying = false;
        });
      }
    });

    if (hasError) {
      return gap12;
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton.filled(
          onPressed: () {
            if (isPlaying) {
              player.pause();
            } else {
              player.play();
            }
          },
          icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
        ),
        gap12,
        Expanded(
          child: StreamBuilder(
              stream: player.positionStream,
              builder: (context, snapshot) {
                final dur = parseDuration(widget.duration);

                final playingPosition = snapshot.data?.inSeconds ?? 0;

                return LinearProgressIndicator(
                  backgroundColor: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                  value: min(playingPosition / dur.inSeconds, 1),
                );
              }),
        ),
        // Text('position: ${_playingPosition.toStringAsFixed(2)}'),
      ],
    );
  }
}
