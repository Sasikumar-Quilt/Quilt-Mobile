import 'package:audioplayers/audioplayers.dart';
import 'package:path/path.dart' as p;

class AudioPlayerManager {
  static final AudioPlayerManager _instance = AudioPlayerManager._internal();
  factory AudioPlayerManager() => _instance;
  Function(Duration)? onPositionChangedCallback;

  late AudioPlayer _audioPlayer;
  void withUpdateCallback(Function(Duration duration)? updateAudioPosition) {
this.updateAudioPosition=updateAudioPosition!;
  }
   Function(Duration duration)? updateAudioPosition;

  AudioPlayerManager._internal() {
    _audioPlayer = AudioPlayer();
    _audioPlayer.onPositionChanged.listen((event) {
      if (onPositionChangedCallback != null) {
        onPositionChangedCallback!(event);
      }
      if(updateAudioPosition!=null){
        updateAudioPosition!(event);
      }

    });
  }

  AudioPlayer get player => _audioPlayer;

  String currentAction="Feed";

  Future<void> playAudio(String url,Duration? duration,bool isLoop) async {
    print("duration");
    print(duration);
    print(isLoop);
    String mType = getMimeType(url);
    print("MimeType");
    print(mType);

    if (duration != null) {
      await player.play(UrlSource(url,mimeType: mType),
          position: duration);
    } else {
      await player.play(UrlSource(url,mimeType: mType));
    }
    if(isLoop){
      player.setReleaseMode(ReleaseMode.loop);
    }else{
      player.setReleaseMode(ReleaseMode.release);
    }
  }
  String getMimeType(String url) {
    String extension = p.extension(url).toLowerCase();

    switch (extension) {
      case '.mp3':
        return 'audio/mpeg';
      case '.m4a':
        return 'audio/mp4';
      case '.wav':
        return 'audio/wav';
      case '.ogg':
        return 'audio/ogg';
      case '.flac':
        return 'audio/flac';
      default:
        return 'audio/mpeg'; // Fallback to a default MIME type
    }
  }
  void resumeAudio(){
    player.resume();
  }
  void dispose(){
    player.dispose();
  }
  void pause() async{
    print("audionPaused");
    if(player.state!=PlayerState.disposed){
      await player.pause();
    }
  }
  void seek(Duration duration){
    player.seek(duration);
  }
  void setVolume(bool isMute){
    print("setVolume");
    print(isMute);
    player.setVolume(isMute ? 0.0 : 1.0);
  }
  void setCurrentAction(String currentAction){
    this.currentAction=currentAction;
  }
  String getCurrentAction(){
    return currentAction;
  }
}