import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:lottie/lottie.dart';
import 'package:quilt/src/api/Objects.dart';
import 'package:quilt/src/feedback/FeedbackWidget.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

import '../base/BaseState.dart';


class FeedWebView extends BasePage {
  ContentObj contentObj;
  FeedWebView(this.contentObj);

  @override
  WebviewWidgetState createState() => WebviewWidgetState();
}

class WebviewWidgetState extends BasePageState<FeedWebView>
    with WidgetsBindingObserver {
  WebViewController? controller;
  bool isArg=false;
  ContentObj? contentObj;

  init() async {
    contentObj=widget.contentObj;
    print(contentObj);
    late final PlatformWebViewControllerCreationParams params;
    if (WebViewPlatform.instance is WebKitWebViewPlatform) {
      params = WebKitWebViewControllerCreationParams(
        allowsInlineMediaPlayback: true,
        mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
      );
    } else {
      params = const PlatformWebViewControllerCreationParams();
    }
    controller=
        WebViewController.fromPlatformCreationParams(params);
    controller!
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            // Update loading bar.
          },
          onPageStarted: (String url) {},
          onPageFinished: (String url) {
            if(!isArg){
              sendDataToUnity(contentObj!.animations!);
            }
          },
          onWebResourceError: (WebResourceError error) {},
          onNavigationRequest: (NavigationRequest request) {
            /*  if (request.url.startsWith('https://www.youtube.com/')) {
            return NavigationDecision.prevent;
          }*/
            return NavigationDecision.navigate;
          },
        ),
      )

      ..loadRequest(Uri.parse("https://qwlt-games.s3.us-east-2.amazonaws.com/LiveViewer2/index.html"));

    setState(() {

    });
    controller!.addJavaScriptChannel("MessageHandler", onMessageReceived: (message){
      print("addJavaScriptChannel");
      print(message.message);
      if(message.message=="Unity is ready"){
        sendDataToUnity(contentObj!.animations!);
        //Navigator.pushNamed(context, HomeWidgetRoutes.VideoCompletedWidget,arguments: {"object":contentObj,"fromJournal":true}) .then((value) => {replayVideo(value)});

      }
    });
  }
  void sendDataToUnity(String data) {
    print("sendDataToUnity");
    print(data);
    controller!.runJavaScript('receiveDataFromFlutter("$data")');
  }


  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addObserver(this);
    print("webviewInit");
    init();
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance!.removeObserver(this);
  }
  void showFeedbackDialog(){

    showDialog(
      context: context,barrierDismissible: false,
      builder: (BuildContext context) {
        return FeedBackWidget(contentObj: contentObj,); // Custom dialog widget
      },
    ).then((value) => {
      checkFeedback(value)
    });
  }
  checkFeedback(value) {
    print(value["isFeedback"]);
    print("checkFeedback");
    if(value!=null&&value["isFeedback"]==true){
      Navigator.of(context).pop();
    }else if(value!=null&&value["skip"]==true){
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          backgroundColor: Colors.white,
          body:controller!=null?WebViewWidget(controller: controller!,):Container(),
        ));
  }
}
