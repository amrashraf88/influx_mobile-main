import 'dart:async';

import 'package:adzmavall/features/influencer_chat/presentation/models/influencer_chat_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:just_audio/just_audio.dart';

/// Local playback UI for voice bubbles: play/pause and progress over [message.voiceDuration].
/// When [activeMessageId] is non-null and not this [message.id], this player stops.
class ChatVoiceMessagePlayer extends StatefulWidget {
  const ChatVoiceMessagePlayer({
    super.key,
    required this.message,
    required this.foreground,
    required this.activeMessageId,
  });

  final InfluencerChatMessage message;
  final Color foreground;
  final ValueNotifier<String?> activeMessageId;

  @override
  State<ChatVoiceMessagePlayer> createState() => _ChatVoiceMessagePlayerState();
}

class _ChatVoiceMessagePlayerState extends State<ChatVoiceMessagePlayer> {
  static const Duration _tick = Duration(milliseconds: 50);

  final AudioPlayer _player = AudioPlayer();
  bool _playing = false;
  Timer? _timer;
  StreamSubscription<Duration>? _positionSubscription;
  StreamSubscription<PlayerState>? _playerStateSubscription;
  Duration _position = Duration.zero;
  Duration? _loadedDuration;
  bool _audioLoaded = false;

  int get _totalMs {
    final int ms =
        _loadedDuration?.inMilliseconds ??
        widget.message.voiceDuration?.inMilliseconds ??
        0;
    return ms < 500 ? 1000 : ms;
  }

  int get _elapsedMs => _position.inMilliseconds.clamp(0, _totalMs);

  bool get _hasAudioFile => (widget.message.voiceFilePath ?? '').isNotEmpty;

  double get _progress => (_elapsedMs / _totalMs).clamp(0.0, 1.0);

  @override
  void initState() {
    super.initState();
    widget.activeMessageId.addListener(_onGlobalActiveChanged);
    _positionSubscription = _player.positionStream.listen((Duration position) {
      if (mounted) {
        setState(() => _position = position);
      }
    });
    _playerStateSubscription = _player.playerStateStream.listen((
      PlayerState state,
    ) {
      if (state.processingState == ProcessingState.completed) {
        _handlePlaybackCompleted();
      }
    });
  }

  @override
  void didUpdateWidget(covariant ChatVoiceMessagePlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.activeMessageId != widget.activeMessageId) {
      oldWidget.activeMessageId.removeListener(_onGlobalActiveChanged);
      widget.activeMessageId.addListener(_onGlobalActiveChanged);
    }
    if (oldWidget.message.id != widget.message.id) {
      _stop(resetProgress: true);
      _audioLoaded = false;
      _loadedDuration = null;
    }
  }

  @override
  void dispose() {
    widget.activeMessageId.removeListener(_onGlobalActiveChanged);
    _positionSubscription?.cancel();
    _playerStateSubscription?.cancel();
    _timer?.cancel();
    _player.dispose();
    super.dispose();
  }

  void _onGlobalActiveChanged() {
    if (widget.activeMessageId.value != widget.message.id && _playing) {
      _stop(resetProgress: false);
    }
  }

  void _toggle() {
    if (_playing) {
      _pause();
    } else {
      unawaited(_play());
    }
  }

  Future<void> _play() async {
    widget.activeMessageId.value = widget.message.id;
    if (_elapsedMs >= _totalMs) {
      _position = Duration.zero;
      if (_hasAudioFile) {
        await _player.seek(Duration.zero);
      }
    }
    setState(() => _playing = true);
    if (_hasAudioFile) {
      try {
        if (!_audioLoaded) {
          _loadedDuration = await _player.setFilePath(
            widget.message.voiceFilePath!,
          );
          _audioLoaded = true;
        }
        unawaited(_player.play());
      } on Object {
        _stop(resetProgress: true);
      }
      return;
    }

    _timer?.cancel();
    _timer = Timer.periodic(_tick, (_) {
      if (!mounted) {
        return;
      }
      final Duration nextPosition = _position + _tick;
      if (nextPosition.inMilliseconds >= _totalMs) {
        setState(() => _position = Duration(milliseconds: _totalMs));
        _handlePlaybackCompleted();
        return;
      }
      setState(() => _position = nextPosition);
    });
  }

  void _pause() {
    _timer?.cancel();
    _timer = null;
    if (_hasAudioFile) {
      unawaited(_player.pause());
    }
    setState(() => _playing = false);
    if (widget.activeMessageId.value == widget.message.id) {
      widget.activeMessageId.value = null;
    }
  }

  void _stop({required bool resetProgress}) {
    _timer?.cancel();
    _timer = null;
    if (resetProgress) {
      _position = Duration.zero;
      if (_hasAudioFile) {
        unawaited(_player.seek(Duration.zero));
      }
    }
    if (mounted) {
      setState(() => _playing = false);
    } else {
      _playing = false;
    }
    if (widget.activeMessageId.value == widget.message.id) {
      widget.activeMessageId.value = null;
    }
  }

  void _handlePlaybackCompleted() {
    _timer?.cancel();
    _timer = null;
    if (mounted) {
      setState(() {
        _playing = false;
        _position = Duration.zero;
      });
    } else {
      _playing = false;
      _position = Duration.zero;
    }
    if (_hasAudioFile) {
      unawaited(_player.seek(Duration.zero));
    }
    if (widget.activeMessageId.value == widget.message.id) {
      widget.activeMessageId.value = null;
    }
  }

  String _elapsedLabel() {
    final int totalSeconds = (_elapsedMs / 1000).floor();
    final int minutes = totalSeconds ~/ 60;
    final int seconds = totalSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  String _totalLabel() {
    final int totalSeconds = (_totalMs / 1000).ceil();
    final int minutes = totalSeconds ~/ 60;
    final int seconds = totalSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final Color fg = widget.foreground;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: _toggle,
            borderRadius: BorderRadius.circular(20.r),
            child: Padding(
              padding: EdgeInsets.all(2.w),
              child: Icon(
                _playing ? Icons.pause_rounded : Icons.play_arrow_rounded,
                color: fg,
                size: 26.sp,
              ),
            ),
          ),
        ),
        SizedBox(width: 4.w),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8.r),
            child: LinearProgressIndicator(
              value: _progress,
              minHeight: 4.h,
              backgroundColor: fg.withValues(alpha: 0.22),
              valueColor: AlwaysStoppedAnimation<Color>(fg),
            ),
          ),
        ),
        SizedBox(width: 8.w),
        Text(
          _playing || _elapsedMs > 0
              ? '${_elapsedLabel()} / ${_totalLabel()}'
              : _totalLabel(),
          style: TextStyle(
            color: fg,
            fontSize: 11.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
