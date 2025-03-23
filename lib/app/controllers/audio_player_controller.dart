import 'package:get/get.dart';

class AudioPlayerController extends GetxController {
  // ID of the currently playing audio player
  final RxString currentlyPlayingId = ''.obs;

  // Set current playing player ID and notify others
  void setCurrentlyPlaying(String playerId) {
    print('Now playing: $playerId');
    currentlyPlayingId.value = playerId;
  }

  // Check if a player with the given ID should be playing
  bool shouldBePlaying(String playerId) {
    return currentlyPlayingId.value.isEmpty ||
        currentlyPlayingId.value == playerId;
  }

  // Stop all players
  void stopAllPlayers() {
    currentlyPlayingId.value = '';
  }
}
