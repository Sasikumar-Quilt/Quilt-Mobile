import 'dart:typed_data';

import 'package:fast_cached_network_image/fast_cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class ImageViewWidget extends StatefulWidget {
  final String imageUrl;

  ImageViewWidget({required this.imageUrl});

  @override
  _ImageViewWidgetState createState() => _ImageViewWidgetState();
}

class _ImageViewWidgetState extends State<ImageViewWidget> {

  @override
  void initState() {
    super.initState();
    print("imageViewWidget");
  }
  @override
  Widget build(BuildContext context) {

    return Container(
      width: double.infinity,
      height: double.infinity,
      child:  FastCachedImage(
        url: widget.imageUrl,
        fit: BoxFit.cover,
        fadeInDuration: const Duration(milliseconds: 500),
        errorBuilder: (context, exception, stacktrace) {
          return Text(stacktrace.toString());
        },
        loadingBuilder: (context, progress) {
          return Container(
            child: Stack(
              alignment: Alignment.center,
              children: [
                if (progress.isDownloading && progress.totalBytes != null)
                  Container(
                    height: 100,
                    width: 100,
                    color: Colors.black,
                    child: Center(
                        child: Lottie.asset("assets/images/feed_preloader.json")),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}