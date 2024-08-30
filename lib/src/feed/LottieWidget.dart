import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class LottieWidget extends StatefulWidget {
  final String animationJsonString;

  LottieWidget({required this.animationJsonString});

  @override
  _LottieWidgetState createState() => _LottieWidgetState();
}

class _LottieWidgetState extends State<LottieWidget> {
  Future? _lottieFuture;

  @override
  void initState() {
    super.initState();
    print("lottieUpdate");
    _lottieFuture = loadLottieFromJsonString(widget.animationJsonString);
  }
  static Future<Uint8List> loadLottieFromJsonString(String jsonString) async {
    print("loadLottieFromJsonString");
    final List<int> jsonMap = jsonString.codeUnits;
    final bytes = Uint8List.fromList(jsonMap); //utf8.encode(jsonString);
    return bytes;
    /*await LottieComposition.fromBytes(Uint8List.fromList(bytes))*/;
  }
  @override
  void dispose() {
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {

    return FutureBuilder(
      future: _lottieFuture,
      builder: (context,
          snapshot) {
        if (snapshot
            .connectionState ==
            ConnectionState
                .done) {
          return Lottie
              .memory(
            snapshot
                .data!,
            animate: true,
            repeat: true,
          );
        } else {
          return CircularProgressIndicator();
        }
      },
    );
  }
}