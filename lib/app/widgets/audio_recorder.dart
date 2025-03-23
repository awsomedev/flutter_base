import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../app_essentials/colors.dart';

class AudioRecorder extends StatefulWidget {
  final Function(File audioFile) onRecordingComplete;

  const AudioRecorder({
    Key? key,
    required this.onRecordingComplete,
  }) : super(key: key);

  @override
  State<AudioRecorder> createState() => _AudioRecorderState();
}

class _AudioRecorderState extends State<AudioRecorder> {
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  final FlutterSoundPlayer _player = FlutterSoundPlayer();

  bool _isRecorderInitialized = false;
  bool _isRecording = false;
  bool _isPlaying = false;
  String? _recordedFilePath;
  Timer? _recordingTimer;
  int _recordingDuration = 0;

  @override
  void initState() {
    super.initState();
    _initRecorder();
  }

  @override
  void dispose() {
    _recorder.closeRecorder();
    _player.closePlayer();
    _recordingTimer?.cancel();
    super.dispose();
  }

  Future<void> _initRecorder() async {
    final status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      throw RecordingPermissionException('Microphone permission not granted');
    }

    await _recorder.openRecorder();
    await _player.openPlayer();

    setState(() {
      _isRecorderInitialized = true;
    });
  }

  Future<void> _startRecording() async {
    if (!_isRecorderInitialized) return;

    final dir = await getTemporaryDirectory();
    _recordedFilePath =
        '${dir.path}/audio_${DateTime.now().millisecondsSinceEpoch}.aac';

    await _recorder.startRecorder(
      toFile: _recordedFilePath,
      codec: Codec.aacADTS,
    );

    _recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _recordingDuration++;
      });
    });

    setState(() {
      _isRecording = true;
    });
  }

  Future<void> _stopRecording() async {
    if (!_isRecording) return;

    await _recorder.stopRecorder();
    _recordingTimer?.cancel();

    setState(() {
      _isRecording = false;
    });

    if (_recordedFilePath != null) {
      final file = File(_recordedFilePath!);
      if (await file.exists()) {
        widget.onRecordingComplete(file);
      }
    }
  }

  Future<void> _playRecording() async {
    if (_recordedFilePath == null) return;

    if (_isPlaying) {
      await _player.stopPlayer();
      setState(() {
        _isPlaying = false;
      });
      return;
    }

    await _player.startPlayer(
      fromURI: _recordedFilePath,
      whenFinished: () {
        setState(() {
          _isPlaying = false;
        });
      },
    );

    setState(() {
      _isPlaying = true;
    });
  }

  void _cancelRecording() {
    if (_isRecording) {
      _recorder.stopRecorder();
      _recordingTimer?.cancel();
    }

    if (_recordedFilePath != null) {
      File(_recordedFilePath!).delete();
      _recordedFilePath = null;
    }

    setState(() {
      _isRecording = false;
      _recordingDuration = 0;
    });
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    if (!_isRecorderInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_recordedFilePath != null && !_isRecording) {
      // Show playback UI
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.divider),
        ),
        child: Row(
          children: [
            IconButton(
              icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
              onPressed: _playRecording,
              color: AppColors.primary,
            ),
            Expanded(
              child: Center(
                child: Text(_formatDuration(_recordingDuration)),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _cancelRecording,
              color: AppColors.error,
            ),
          ],
        ),
      );
    }

    // Show recording UI
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          if (_isRecording) ...[
            IconButton(
              icon: const Icon(Icons.stop),
              onPressed: _stopRecording,
              color: AppColors.error,
            ),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.mic, color: Colors.red),
                  const SizedBox(width: 8),
                  Text(
                    _formatDuration(_recordingDuration),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _cancelRecording,
              color: AppColors.error,
            ),
          ] else ...[
            Expanded(
              child: GestureDetector(
                onTap: _startRecording,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  alignment: Alignment.center,
                  color: Colors.white,
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.mic, color: AppColors.primary),
                      SizedBox(width: 8),
                      Text('Tap to record audio',
                          style: TextStyle(color: AppColors.textSecondary)),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
