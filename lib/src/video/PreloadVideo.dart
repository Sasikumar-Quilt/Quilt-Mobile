import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:video_player/video_player.dart';

import '../api/Objects.dart';

class PreloadVideos {
  static final PreloadVideos _instance = PreloadVideos._internal();

  // Factory constructor
  factory PreloadVideos(Function() updateWidget) {
    _instance.updateWidget = updateWidget;
    return _instance;
  }

  // Private constructor for singleton
  PreloadVideos._internal();

  late Function() updateWidget;

  // PreloadVideos(this.updateWidget);
  Map<int, VideoPlayerController> controllers = {};
  List<ContentObj> contentList = [];
  int previousIndex = 0;
  int currentIndex = 0;

  void init(cList) async {
    print("initPreloads");
    disposeAll();
    previousIndex = 0;
    currentIndex = 0;
    contentList = cList;
    print(contentList.length);

    /// Initialize 1st video
    await _initializeControllerAtIndex(0);

    /// Play 1st video
    playControllerAtIndex(0);
    // Preload the next 2 videos
    await _initializeNextVideoController(1);
    await _initializeNextVideoController(2);
  }

  void updateVideoList(cList) {
    contentList = cList;
  }

  onPageChanged(int index) {
    print("onPageChanged");
    _stopAllMedia();
    previousIndex = currentIndex;
    currentIndex = index;
    print("currentIndex");
    print(currentIndex);
    print("previousIndex");
    print(previousIndex);
    if (index > previousIndex) {
      _playNext(index);
    } else {
      _playPrevious(index);
    }
    // Dispose controllers out of the desired range
    _disposeControllersOutsideRange(index);
  }

  void _playNext(int index) {
    /// Stop [index - 1] controller
    //_stopControllerAtIndex(index - 1);

    /// Dispose [index - 2] controller
   // _disposePreviousVideoController(index - 3);

    /// Play current video (already initialized)
    playControllerAtIndex(index);

    /// Initialize [index + 1] controller
    _initializeNextVideoController(index + 1);
    _initializeNextVideoController(index + 2);
  }

  void _playPrevious(int index) {
    /// Stop [index + 1] controller
    // _stopControllerAtIndex(index + 1);

    /// Dispose [index + 2] controller
    //_disposeNextVideoController(index + 3);

    /// Play current video (already initialized)
    playControllerAtIndex(index);

    /// Initialize [index - 1] controller
    _initializePreviousVideoController(index - 1);
    _initializePreviousVideoController(index - 2);
  }

  Future _initializeControllerAtIndex(int index) async {
    print("_initializeControllerAtIndex");
    if(!controllers.containsKey(index)){
      if (index >= 0 &&
          index < contentList.length &&
          (contentList[index].isVideoAudio ||
              contentList[index].contentFormat == "VIDEO")) {
        final VideoPlayerController _controller =
        VideoPlayerController.networkUrl(Uri.parse(
            contentList[index].isVideoAudio
                ? contentList[index].videoURL
                : contentList[index].contentUrl!));
        controllers[index] = _controller;
       try{
         await _controller.initialize().timeout(const Duration(seconds: 30));
         if (index == 0) {
           updateWidget();
         }
       } on TimeoutException catch (_) {
         print('Initialization of video at index $index timed out.');
         controllers.remove(index); // Clean up if initialization fails
       } catch (e) {
         print('Failed to initialize video at index $index: $e');
         controllers.remove(index); // Clean up if initialization fails
       }
        print('🚀🚀🚀 INITIALIZED $index');
      }
    }

  }

  Future<void> _initializeNextVideoController(int index) async {
    while (index < contentList.length) {
      if ((contentList[index].isVideoAudio) ||
          (contentList[index].contentFormat == "VIDEO")) {
        await _initializeControllerAtIndex(index);
        break;
      }
      index++;
    }
  }

  Future<void> _initializePreviousVideoController(int index) async {
    while (index >= 0) {
      if ((contentList[index].isVideoAudio) ||
         (contentList[index].contentFormat == "VIDEO")) {
        await _initializeControllerAtIndex(index);
        break;
      }
      index--;
    }
  }

  void playControllerAtIndex(int index) {
    print(index);
    print(contentList[index].isVideoAudio);
    print("contentFormat");
    print("videoControllerSize");
    print(controllers.length);
    print(contentList[index].contentFormat);
    if (controllers.containsKey(index) &&
        index >= 0 &&
        index < contentList.length &&
        ((contentList[index].isVideoAudio) ||
            (contentList[index].contentFormat == "VIDEO"))) {
      final VideoPlayerController _controller = controllers[index]!;

      print("_controller.value.isInitialized");
      print(_controller.value.isInitialized);
      if (_controller.value.isInitialized) {
        _controller.play();
      } else {
        _controller
            .initialize().timeout(const Duration(seconds: 30))
            .then((value) => {updateWidget(),print("afterInitializeVideo")})
            .catchError((error) => {
             _controller.dispose(),
             controllers.remove(index)
        });
      }
      print('🚀🚀🚀 PLAYING $index');
    } else {
      _initializeControllerAtIndex(index);
    }
  }

 /* void _stopControllerAtIndex(int index) {
    if (contentList.length > index && index >= 0) {
      /// Get controller at [index]
      final VideoPlayerController _controller = controllers[index]!;

      /// Pause
      _controller.pause();

      print('🚀🚀🚀 STOPPED $index');
    }
  }*/

  /* void _disposeControllerAtIndex(int index) {
    if (controllers.containsKey(index)) {
      final VideoPlayerController _controller = controllers[index]!;
      _controller.dispose();
      controllers.remove(index);
      print('🚀🚀🚀 DISPOSED $index');
    }
  }*/
 /* void _disposePreviousVideoController(int index) {
    while (index >= 0) {
      if (index < contentList.length &&
          (contentList[index].isVideoAudio ||
              contentList[index].contentFormat == "VIDEO") &&
          controllers.containsKey(index)) {
        final VideoPlayerController _controller = controllers[index]!;
        _controller.dispose();
        controllers.remove(index);
        print('🚀🚀🚀 DISPOSED $index');
        break;
      }
      index--;
    }
  }*/

  /*void _disposeNextVideoController(int index) {
    while (index < contentList.length) {
      if (contentList[index].isVideoAudio && controllers.containsKey(index)) {
        final VideoPlayerController _controller = controllers[index]!;
        _controller.dispose();
        controllers.remove(index);
        print('🚀🚀🚀 DISPOSED $index');
        break;
      }
      index++;
    }
  }*/
  void _disposeControllersOutsideRange(int index) {
    List<int> indexesToDispose = [];
    controllers.forEach((key, controller) {
      if ((key < index - 2) || (key > index + 2)) {
        indexesToDispose.add(key);
      }
    });

    for (var idx in indexesToDispose) {
      _disposeControllerAtIndex(idx);
    }

    print("videoControllerSize");
    print(controllers.length);
  }

  void _disposeControllerAtIndex(int index) {
    if (controllers.containsKey(index)) {
      final VideoPlayerController _controller = controllers[index]!;
      _controller.dispose();
      controllers.remove(index);
      print('🚀🚀🚀 DISPOSED $index');
    }
  }
  void disposeAll() {
    if (controllers.isNotEmpty) {
      controllers.forEach((key, value) {
        value.dispose();
      });
      controllers.clear();
    }
  }

  void _stopAllMedia() {
    if (controllers.isNotEmpty) {
      controllers.forEach((index, controller) {
        controller.pause();
        print('🚀🚀🚀 STOPPED $index');
      });
    }
  }
}
