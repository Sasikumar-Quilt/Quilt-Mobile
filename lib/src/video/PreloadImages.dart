
import 'package:cached_network_image/cached_network_image.dart';
import 'package:fast_cached_network_image/fast_cached_network_image.dart';
import 'package:flutter/cupertino.dart';

import '../api/Objects.dart';

class PreloadImages {
  final Function() updateWidget;
  PreloadImages(this.updateWidget);
  Map<int, FastCachedImageProvider> imageProviders = {};
  List<ContentObj> contentList = [];
  int previousIndex=0;
  int currentIndex=0;
  void init(cList) async{
    disposeAll();
    previousIndex=0;
    currentIndex=0;
    contentList=cList;
    /// Initialize 1st video
    await _initializeControllerAtIndex(0);
    /// Play 1st video
    _playControllerAtIndex(0);
    /// Initialize 2nd vide
    await _initializeNextImageController(1);

  }

  void updateVideoList(cList) {
    contentList=cList;
  }

  onPageChanged(int index){
    print("onPageChanged");
    previousIndex=currentIndex;
    currentIndex=index;
    print("currentIndex");
    print(currentIndex);
    print("previousIndex");
    print(previousIndex);
    if (index > previousIndex) {
      _playNext(index);
    } else {
      _playPrevious(index);
    }

  }
  void _playNext(int index) {
    /// Stop [index - 1] controller
    //_stopControllerAtIndex(index - 1);

    /// Dispose [index - 2] controller
    _disposePreviousImage(index - 2);

    /// Play current video (already initialized)
    _playControllerAtIndex(index);

    /// Initialize [index + 1] controller
    _initializeNextImageController(index + 1);
  }

  void _playPrevious(int index) {
    /// Stop [index + 1] controller
    // _stopControllerAtIndex(index + 1);

    /// Dispose [index + 2] controller
    _disposeNextImage(index + 2);

    /// Play current video (already initialized)
    _playControllerAtIndex(index);

    /// Initialize [index - 1] controller
    _initializePreviousImageController(index - 1);
  }
  Future _initializeControllerAtIndex(int index) async {
    print("_initializeControllerAtIndex");
    if (index >= 0 && index < contentList.length && (contentList[index].contentFormat=="ASSESSMENT")) {
      final FastCachedImageProvider _imageProvider =
      FastCachedImageProvider(contentList![index]
          .animations!);
      imageProviders[index] = _imageProvider;
      _imageProvider.resolve(ImageConfiguration()).addListener(
        ImageStreamListener((_, __) {
          print('🚀🚀🚀 INITIALIZED IMAGE $index');
        }),
      );
      print('🚀🚀🚀 INITIALIZED $index');
    }
  }


  Future<void> _initializeNextImageController(int index) async {
    while (index < contentList.length) {
      if ((contentList[index].contentType=="ASSESSMENT")) {
        await _initializeControllerAtIndex(index);
        break;
      }
      index++;
    }
  }

  Future<void> _initializePreviousImageController(int index) async {
    while (index >= 0) {
      if (contentList[index].contentType=="ASSESSMENT") {
        await _initializeControllerAtIndex(index);
        break;
      }
      index--;
    }
  }

  void _playControllerAtIndex(int index) {
    if (index >= 0 && index < contentList.length &&(contentList[index].contentType=="ASSESSMENT")) {

    }
  }

  void _disposePreviousImage(int index) {
    while (index >= 0) {
      if (index < contentList.length && imageProviders.containsKey(index)) {
        imageProviders.remove(index);
        print('🚀🚀🚀 DISPOSED Image $index');
        break;
      }
      index--;
    }
  }
  void _disposeNextImage(int index) {
    while (index < contentList.length) {
      if (contentList[index].isVideoAudio && imageProviders.containsKey(index)) {

        imageProviders.remove(index);
        print('🚀🚀🚀 DISPOSED Image $index');
        break;
      }
      index++;
    }
  }
  void disposeAll(){
    if(imageProviders.isNotEmpty){
      imageProviders.clear();
    }

  }

}
