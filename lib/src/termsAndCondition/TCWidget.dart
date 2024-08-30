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


class TCWebView extends BasePage {
  TCWebView();

  @override
  WebviewWidgetState createState() => WebviewWidgetState();
}

class WebviewWidgetState extends BasePageState<TCWebView>
    with WidgetsBindingObserver {
  WebViewController? controller;
  bool isArg=false;

  init() async {
// Set the status bar color to black once the animation is completed
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark.copyWith(
      statusBarColor: Colors.black, // Background color of status bar
      statusBarIconBrightness: Brightness.light, // Icon brightness for Android
      statusBarBrightness: Brightness.dark, // Icon brightness for iOS
    ));
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

      ..loadRequest(Uri.parse("https://www.q-u-i-l-t.com/privacy-policy"));

    setState(() {

    });
    controller!.addJavaScriptChannel("MessageHandler", onMessageReceived: (message){
      print("addJavaScriptChannel");
      print(message.message);
      if(message.message=="Unity is ready"){

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
        child: Scaffold(/*appBar: AppBar(
            elevation: 0,
            backgroundColor: Colors.white,leading: InkWell(child: Icon(Icons.arrow_back_ios_rounded,size: 20,),onTap: (){
          Navigator.of(context).pop();
        },)
        )*/
          resizeToAvoidBottomInset: false,
          backgroundColor: Colors.white,
          body:Stack(children: [
            controller!=null?WebViewWidget(controller: controller!,):Container(),
            InkWell(child: Container(child: Icon(Icons.arrow_back_ios_rounded,size: 20,),margin: EdgeInsets.only(left: 10,top: 20),),onTap: (){
              Navigator.of(context).pop();
            },)
          ],),
        ));
  }
}
