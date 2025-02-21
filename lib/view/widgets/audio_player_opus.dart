import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:ogg_opus_player/ogg_opus_player.dart';
import 'package:trim_talk/model/utils.dart';

class AudioPlayerOpus extends StatefulWidget {
  const AudioPlayerOpus({super.key, required this.path, required this.duration});

  final String path;
  final String duration;

  @override
  State<AudioPlayerOpus> createState() => _AudioPlayerOpusState();
}

class _AudioPlayerOpusState extends State<AudioPlayerOpus> {
  OggOpusPlayer? _player;

  Timer? timer;

  double _playingPosition = 0;

  @override
  void initState() {
    super.initState();
    _player = OggOpusPlayer(widget.path);

    timer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (!mounted) return;

      setState(() {
        _playingPosition = _player?.currentPosition ?? 0;
      });
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    _player?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = _player?.state.value ?? PlayerState.idle;

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton.filled(
          onPressed: () {
            if (state == PlayerState.playing) {
              _player?.pause();
            } else {
              _player?.play();
              _player?.state.addListener(() {
                if (!context.mounted) return;
                setState(() {});
                if (_player?.state.value == PlayerState.ended) {
                  _player?.dispose();
                  _player = OggOpusPlayer(widget.path);
                }
              });
            }
          },
          icon: Icon(state == PlayerState.playing ? Icons.pause : Icons.play_arrow),
        ),
        gap12,
        // Text('position: ${_playingPosition.toStringAsFixed(2)}'),
        Expanded(
          child: Builder(builder: (context) {
            final dur = parseDuration(widget.duration);

            return LinearProgressIndicator(
              backgroundColor: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
              value: min(_playingPosition / dur.inSeconds, 1),
            );
          }),
        ),
      ],
    );
  }
}
