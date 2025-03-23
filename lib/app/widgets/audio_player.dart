import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import '../app_essentials/colors.dart';
import '../controllers/audio_player_controller.dart';

// Initialize the GetX controller
final audioPlayerController = Get.put(AudioPlayerController());

class AudioPlayer extends StatefulWidget {
  final String audioUrl;
  final String? title;
  final bool showDownloadButton;

  const AudioPlayer({
    Key? key,
    required this.audioUrl,
    this.title,
    this.showDownloadButton = true,
  }) : super(key: key);

  @override
  _AudioPlayerState createState() => _AudioPlayerState();
}

class _AudioPlayerState extends State<AudioPlayer> {
  late FlutterSoundPlayer _player;
  bool _isPlayerInitialized = false;
  bool _isPlaying = false;
  bool _isBuffering = false;
  bool _isDownloading = false;
  double _downloadProgress = 0.0;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  Timer? _positionTimer;

  // Generate a unique ID for this player instance
  final String _playerId = UniqueKey().toString();

  @override
  void initState() {
    super.initState();
    _initPlayer();
    print('Audio URL: ${widget.audioUrl}');

    // Listen to the GetX controller to know when to pause
    ever(audioPlayerController.currentlyPlayingId, (String id) {
      if (id != _playerId && _isPlaying) {
        print('Another player started: $id, pausing $_playerId');
        _pausePlayer();
      }
    });
  }

  void _pausePlayer() async {
    if (_isPlaying) {
      await _player.pausePlayer();
      _positionTimer?.cancel();
      _positionTimer = null;

      if (mounted) {
        setState(() {
          _isPlaying = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _positionTimer?.cancel();
    _player.closePlayer();
    super.dispose();
  }

  Future<void> _initPlayer() async {
    _player = FlutterSoundPlayer();
    await _player.openPlayer();

    if (mounted) {
      setState(() {
        _isPlayerInitialized = true;
      });
    }
  }

  Future<void> _togglePlay() async {
    if (!_isPlayerInitialized) return;

    if (_isPlaying) {
      _pausePlayer();
    } else {
      // Notify the controller that this player is starting
      audioPlayerController.setCurrentlyPlaying(_playerId);

      setState(() {
        _isBuffering = true;
      });

      try {
        if (_player.isPaused) {
          await _player.resumePlayer();
        } else {
          // Start playing and show buffering state
          await _player.startPlayer(
            fromURI: widget.audioUrl,
            whenFinished: () {
              if (mounted) {
                setState(() {
                  _isPlaying = false;
                  _position = Duration.zero;
                });
                _positionTimer?.cancel();
                _positionTimer = null;
              }
            },
          );
        }

        // If we reach here, playing started successfully
        setState(() {
          _isPlaying = true;
          _isBuffering = false;
        });

        // Start progress tracking after playback has begun
        _startProgressTracking();
      } catch (e) {
        // Handle playback error
        if (mounted) {
          setState(() {
            _isBuffering = false;
            _isPlaying = false;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error playing audio: $e'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    }
  }

  void _startProgressTracking() {
    // Cancel any existing timer
    _positionTimer?.cancel();
    _positionTimer = null;

    // Start a new timer that updates progress every 100ms
    _positionTimer =
        Timer.periodic(const Duration(milliseconds: 100), (timer) async {
      if (!_isPlaying || !mounted) {
        timer.cancel();
        return;
      }

      try {
        final progress = await _player.getProgress();
        print('Raw Progress Data: $progress');

        if (mounted) {
          setState(() {
            // Update position and duration from player
            if (progress != null) {
              // FlutterSound API returns progress differently depending on version
              // Try different keys that might contain the position/duration
              _position = progress['progress'] ??
                  progress['progress'] ??
                  progress['currentPosition'] ??
                  Duration.zero;

              _duration = progress['duration'] ??
                  progress['audioDuration'] ??
                  Duration.zero;

              print('Updated - Position: $_position, Duration: $_duration');
            }

            // If we're getting progress updates, we're not buffering anymore
            if (_isBuffering) {
              _isBuffering = false;
            }
          });
        }
      } catch (e) {
        print('Error tracking progress: $e');
      }
    });
  }

  Future<void> _seekTo(double value) async {
    if (!_isPlayerInitialized) return;

    setState(() {
      _isBuffering = true;
    });

    try {
      final newPosition =
          Duration(milliseconds: (value * _duration.inMilliseconds).round());
      await _player.seekToPlayer(newPosition);

      setState(() {
        _position = newPosition;
        _isBuffering = false;
      });
    } catch (e) {
      setState(() {
        _isBuffering = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error seeking: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _downloadAudio() async {
    if (_isDownloading) return;

    setState(() {
      _isDownloading = true;
      _downloadProgress = 0.0;
    });

    try {
      // Get the file name from the URL
      final fileName = widget.audioUrl.split('/').last;
      final documentsDir = await getApplicationDocumentsDirectory();
      final filePath = '${documentsDir.path}/$fileName';

      // Check if file already exists
      if (await File(filePath).exists()) {
        // File already exists, show a dialog
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('File already downloaded'),
              backgroundColor: AppColors.success,
            ),
          );
        }
        setState(() {
          _isDownloading = false;
        });
        return;
      }

      // Create http client for download with progress tracking
      final request = http.Request('GET', Uri.parse(widget.audioUrl));
      final response = await http.Client().send(request);

      final totalBytes = response.contentLength ?? 0;
      var receivedBytes = 0;

      // Create file in device storage
      final file = File(filePath);
      final fileStream = file.openWrite();

      // Download with progress tracking
      await response.stream.forEach((bytes) {
        fileStream.add(bytes);
        receivedBytes += bytes.length;

        if (mounted) {
          final progress = totalBytes > 0 ? receivedBytes / totalBytes : 0.0;
          setState(() {
            _downloadProgress = progress;
          });
        }
      });

      await fileStream.close();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Audio saved to ${file.path}'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Download failed: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isDownloading = false;
        });
      }
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    if (!_isPlayerInitialized) {
      return Container(
        height: 60,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.divider.withOpacity(0.2)),
        ),
        child: const Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              color: AppColors.primary,
              strokeWidth: 2,
            ),
          ),
        ),
      );
    }

    final progressValue = _duration.inMilliseconds > 0
        ? (_position.inMilliseconds / _duration.inMilliseconds).clamp(0.0, 1.0)
        : 0.0;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.divider.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          // Play/Pause button
          Container(
            height: 36,
            width: 36,
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: _isBuffering
                ? const Padding(
                    padding: EdgeInsets.all(8),
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : IconButton(
                    icon: Icon(
                      _isPlaying ? Icons.pause : Icons.play_arrow,
                      size: 18,
                    ),
                    onPressed: _togglePlay,
                    color: Colors.white,
                    padding: EdgeInsets.zero,
                    splashRadius: 18,
                  ),
          ),

          // Audio info and progress
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.title != null) ...[
                  Text(
                    widget.title!,
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                ],

                // Progress and duration
                Row(
                  children: [
                    Expanded(
                      child: SliderTheme(
                        data: SliderThemeData(
                          trackHeight: 4,
                          thumbShape: const RoundSliderThumbShape(
                            enabledThumbRadius: 6,
                            elevation: 1,
                          ),
                          overlayShape:
                              const RoundSliderOverlayShape(overlayRadius: 12),
                          trackShape: const RoundedRectSliderTrackShape(),
                          activeTrackColor: AppColors.primary,
                          inactiveTrackColor:
                              AppColors.divider.withOpacity(0.3),
                          thumbColor: AppColors.primary,
                          overlayColor: AppColors.primary.withOpacity(0.2),
                        ),
                        child: Slider(
                          value: progressValue,
                          onChanged: (value) {
                            final newPosition = Duration(
                                milliseconds:
                                    (value * _duration.inMilliseconds).round());
                            setState(() {
                              _position = newPosition;
                            });
                          },
                          onChangeStart: (value) {
                            if (_isPlaying) {
                              _player.pausePlayer();
                              setState(() {
                                _isPlaying = false;
                              });
                            }
                          },
                          onChangeEnd: (value) async {
                            final newPosition = Duration(
                                milliseconds:
                                    (value * _duration.inMilliseconds).round());
                            await _player.seekToPlayer(newPosition);

                            await _player.resumePlayer();
                            setState(() {
                              _isPlaying = true;
                              _position = newPosition;
                            });

                            _startProgressTracking();
                          },
                        ),
                      ),
                    ),

                    // Duration text
                    Padding(
                      padding: const EdgeInsets.only(left: 4),
                      child: Text(
                        _formatDuration(_duration),
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary.withOpacity(0.7),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
