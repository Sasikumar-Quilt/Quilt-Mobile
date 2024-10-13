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

import '../main.dart';
import 'base/BaseState.dart';

class WebviewWidget extends BasePage {
  WebviewWidget({Key? key}) : super(key: key);

  @override
  WebviewWidgetState createState() => WebviewWidgetState();
}

class WebviewWidgetState extends BasePageState<WebviewWidget>
    with WidgetsBindingObserver {
  WebViewController? controller;
  bool isArg=false;
  ContentObj? contentObj;
  bool _isPaused = false;
  String? _currentUrl;


  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    print("state:" + state.toString());

    if (state == AppLifecycleState.paused) {
      pauseAudio();
    } else if (state == AppLifecycleState.resumed) {
      playAudio();
    }
  }
  void pauseAudio() {
    if (controller != null) {
      controller!.runJavaScript("pause();");
    }
  }
  void playAudio() {
    if (controller != null) {
      controller!.runJavaScript("play();");
    }
  }

  void _resumeWebView() {
    if (controller != null && _currentUrl != null) {
      controller!.loadRequest(Uri.parse(_currentUrl!));
    }
  }
  getArgs() async {
    if(!isArg){

      isArg=true;
      final args = ModalRoute.of(context)?.settings.arguments as Map;
      contentObj=args["url"];
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
            onPageFinished: (String url) {},
            onWebResourceError: (WebResourceError error) {
              print(error.errorCode);
              print(error.errorType);

              if(WebResourceErrorType.webContentProcessTerminated==error.errorType){
                //controller!.reload();
              }
            },
            onNavigationRequest: (NavigationRequest request) {
              /*  if (request.url.startsWith('https://www.youtube.com/')) {
            return NavigationDecision.prevent;
          }*/
              return NavigationDecision.navigate;
            },
          ),
        )
        ..loadRequest(Uri.parse(contentObj!.contentUrl!));

      setState(() {

      });
      controller!.addJavaScriptChannel("MessageHandler", onMessageReceived: (message){
       print("addJavaScriptChannel");
       print(message.message);
        if(message.message=="closeWebView"){
          showFeedbackDialog();
          //Navigator.pushNamed(context, HomeWidgetRoutes.VideoCompletedWidget,arguments: {"object":contentObj,"fromJournal":true}) .then((value) => {replayVideo(value)});

        }
      });
    }
  }
  void sendDataToUnity(String data) {
    controller!.runJavaScript('receiveDataFromFlutter("$data")');
  }

  replayVideo(value) {
    if(value!=null&&value["isReplay"]){

    }else{
      Navigator.of(context).pop();
    }
  }
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addObserver(this);

  }

  @override
  void dispose() {
    super.dispose();
    pauseAudio();
    WidgetsBinding.instance!.removeObserver(this);
  }
  void showFeedbackDialog(){

    /*showDialog(
      context: context,barrierDismissible: false,
      builder: (BuildContext context) {
        return *//*StatefulBuilder(builder: (builder,setState){
          return Dialog(
            backgroundColor: Colors.transparent, // Transparent background
            child: Container(
              padding: EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(child: InkWell(child: Center(
                    child:  Lottie.asset('assets/images/feedback.json'),
                  ),onTap: (){
                    Navigator.pushNamed(context, HomeWidgetRoutes.FeedBackWidget,arguments: {"object":contentObj}).then((value) => checkFeedback(value));

                  },),margin: EdgeInsets.only(bottom: 0),),

                  Text('How do you feel after\n this experience?',textAlign: TextAlign.center,style: TextStyle(
                      color: Colors.white,
                      fontFamily: "Causten-SemiBold",
                      fontWeight: FontWeight.bold,
                      fontSize: 20),),
                  Container(child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Close the dialog
                    },
                    child: Text('Skip',style:  TextStyle(
                        color: Color(0xFF2E292C),
                        fontFamily: "Causten-Bold",
                        fontWeight: FontWeight.bold,
                        fontSize: 12),),
                  ),margin: EdgeInsets.only(top: 30),),
                ],
              ),
            ),
          );
        })*//*FeedBackWidget(contentObj: contentObj,); // Custom dialog widget
      },
    ).then((value) => {
      checkFeedback(value)
    });*/
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.5), // Optional: background color with opacity
      pageBuilder: (BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {
        return FeedBackWidget(
          contentObj: contentObj,
        ); // Your custom widget
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
      transitionDuration: Duration(milliseconds: 300), // Optional: transition duration
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
    getArgs();
    return SafeArea(
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          backgroundColor: Colors.white,
          body:controller!=null?WebViewWidget(controller: controller!,):Container(),
        ));
  }
  Future<bool> onBackPress() async {
    print("onBack");
    return false;
  }
}
