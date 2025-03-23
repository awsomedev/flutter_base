import 'package:flutter/material.dart';
import '../app_essentials/colors.dart';
import '../widgets/audio_player.dart';

class AudioPlayerExample extends StatelessWidget {
  const AudioPlayerExample({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Example audio URLs
    const audioUrl1 =
        'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3';
    const audioUrl2 =
        'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-2.mp3';
    // Larger file to demonstrate buffering
    const audioUrl3 = 'https://samplelib.com/lib/preview/mp3/sample-15s.mp3';

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Audio Player Example',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        backgroundColor: AppColors.surface,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Audio Player',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),

            // First audio example - with title
            const AudioPlayer(
              audioUrl: audioUrl1,
              title: 'Classic Piano Melody',
            ),

            const SizedBox(height: 24),

            // Second audio example - without title
            const AudioPlayer(
              audioUrl: audioUrl2,
            ),

            const SizedBox(height: 24),

            // Third audio example - to demonstrate buffering
            const AudioPlayer(
              audioUrl: audioUrl3,
              title: 'Demo with Buffering',
            ),

            const SizedBox(height: 24),

            // Instructions
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.secondary.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'How to use:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '1. Import the AudioPlayer widget\n'
                    '2. Pass an audio URL to the widget\n'
                    '3. Optionally provide a title\n'
                    '4. The player will handle play/pause, seeking, and downloading',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Example code:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'AudioPlayer(\n'
                    '  audioUrl: "https://example.com/audio.mp3",\n'
                    '  title: "My Audio Track",\n'
                    ')',
                    style: TextStyle(
                      fontFamily: 'monospace',
                      backgroundColor: AppColors.surface,
                      color: AppColors.primary,
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Features:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '• Play/Pause audio\n'
                    '• Buffering indicator during loading\n'
                    '• Accurate progress tracking\n'
                    '• Seek through audio timeline\n'
                    '• Display current and total duration\n'
                    '• Download audio file to device\n'
                    '• Optional title display',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
