import 'dart:collection';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:quilt/src/Utility.dart';

import 'api/Objects.dart';

class MyChromeSafariBrowser extends StatefulWidget {
  @override
  _InAppWebViewExampleScreenState createState() =>
      _InAppWebViewExampleScreenState();
}

class _InAppWebViewExampleScreenState extends State<MyChromeSafariBrowser>
    with WidgetsBindingObserver {
  final GlobalKey webViewKey = GlobalKey();

  InAppWebViewController? webViewController;
  InAppWebViewSettings settings = InAppWebViewSettings(
      isInspectable: kDebugMode,
      mediaPlaybackRequiresUserGesture: false,
      allowsInlineMediaPlayback: true,
      iframeAllow: "camera; microphone",
      cacheEnabled: true,javaScriptEnabled: true,
      cacheMode: CacheMode.LOAD_CACHE_ELSE_NETWORK,
      iframeAllowFullscreen: true);

  PullToRefreshController? pullToRefreshController;

  late ContextMenu contextMenu;
  String url = "";
  double progress = 0;
  final urlController = TextEditingController();
  bool isArg = false;
  ContentObj? contentObj;

  @override
  void initState() {
    super.initState();

    contextMenu = ContextMenu(
        menuItems: [
          ContextMenuItem(
              id: 1,
              title: "Special",
              action: () async {
                print("Menu item Special clicked!");
                print(await webViewController?.getSelectedText());
                await webViewController?.clearFocus();
              })
        ],
        settings: ContextMenuSettings(hideDefaultSystemContextMenuItems: false),
        onCreateContextMenu: (hitTestResult) async {
          print("onCreateContextMenu");
          print(hitTestResult.extra);
          print(await webViewController?.getSelectedText());
        },
        onHideContextMenu: () {
          print("onHideContextMenu");
        },
        onContextMenuActionItemClicked: (contextMenuItemClicked) async {
          var id = contextMenuItemClicked.id;
          print("onContextMenuActionItemClicked: " +
              id.toString() +
              " " +
              contextMenuItemClicked.title);
        });

    pullToRefreshController = kIsWeb ||
        ![TargetPlatform.iOS, TargetPlatform.android]
            .contains(defaultTargetPlatform)
        ? null
        : PullToRefreshController(
      settings: PullToRefreshSettings(
        color: Colors.blue,
      ),
      onRefresh: () async {
        if (defaultTargetPlatform == TargetPlatform.android) {
          webViewController?.reload();
        } else if (defaultTargetPlatform == TargetPlatform.iOS ||
            defaultTargetPlatform == TargetPlatform.macOS) {
          webViewController?.loadUrl(
              urlRequest:
              URLRequest(url: await webViewController?.getUrl()));
        }
      },
    );
  }

  getArgs() {
    if (!isArg) {
      isArg = true;
      final args = ModalRoute
          .of(context)
          ?.settings
          .arguments as Map;
      contentObj=args["url"];
      url =
          contentObj!.contentUrl!;
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        print("resumed");
        webViewController?.resume();
        break;
      case AppLifecycleState.paused:
        print("paused");
        webViewController?.pause();
        break;
      case AppLifecycleState.detached:
      case AppLifecycleState.inactive:
      // TODO: Handle this case.
      case AppLifecycleState.hidden:
      // TODO: Handle this case.
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    getArgs();
    return Scaffold(
        body: SafeArea(
            child: Column(children: <Widget>[
              Expanded(
                child: Stack(
                  children: [
                    url != "" ? InAppWebView(
                      key: webViewKey,
                      initialUrlRequest:
                      URLRequest(url: WebUri(url)),
                      // initialUrlRequest:
                      // URLRequest(url: WebUri(Uri.base.toString().replaceFirst("/#/", "/") + 'page.html')),
                      // initialFile: "assets/index.html",
                      initialUserScripts: UnmodifiableListView<UserScript>([]),
                      initialSettings: settings,
                      contextMenu: contextMenu,
                      pullToRefreshController: pullToRefreshController,
                      onWebViewCreated: (controller) async {
                        webViewController = controller;

                        print("triggered1");
                        setupJavaScriptHandler(controller);
                      },
                      onLoadStart: (controller, url) async {
                        setState(() {
                          this.url = url.toString();
                          print("urlTest");
                          print(url);
                          urlController.text = this.url;
                        });
                      },
                      onPermissionRequest: (controller, request) async {
                        return PermissionResponse(
                            resources: request.resources,
                            action: PermissionResponseAction.GRANT);
                      },
                      shouldOverrideUrlLoading:
                          (controller, navigationAction) async {
                        var uri = navigationAction.request.url!;
                        print("urlTest");
                        print(uri);

                        return NavigationActionPolicy.ALLOW;
                      },
                      onLoadStop: (controller, url) async {
                        pullToRefreshController?.endRefreshing();
                        print("triggered1");

                        setState(() {
                          this.url = url.toString();
                          urlController.text = this.url;
                        });
                      },
                      onReceivedError: (controller, request, error) {
                        pullToRefreshController?.endRefreshing();
                      },
                      onProgressChanged: (controller, progress) {
                        if (progress == 100) {
                          pullToRefreshController?.endRefreshing();
                        }
                        setState(() {
                          this.progress = progress / 100;
                          urlController.text = this.url;
                        });
                      },
                      onUpdateVisitedHistory: (controller, url, isReload) {
                        setState(() {
                          this.url = url.toString();
                          urlController.text = this.url;
                        });
                      },
                      onConsoleMessage: (controller, consoleMessage) {
                        print(consoleMessage);
                      },
                    ) : Container(),
                    progress < 1.0
                        ? LinearProgressIndicator(value: progress)
                        : Container(),
                  ],
                ),
              ),
              /* ButtonBar(
                alignment: MainAxisAlignment.center,
                children: <Widget>[
                  ElevatedButton(
                    child: Icon(Icons.arrow_back),
                    onPressed: () {
                      webViewController?.goBack();
                    },
                  ),
                  ElevatedButton(
                    child: Icon(Icons.arrow_forward),
                    onPressed: () {
                      webViewController?.goForward();
                    },
                  ),
                  ElevatedButton(
                    child: Icon(Icons.refresh),
                    onPressed: () {
                      webViewController?.reload();
                    },
                  ),
                ],
              ),*/
            ])));
  }

  void setupJavaScriptHandler(controller) {
    print("setJava");
    controller?.addJavaScriptHandler(
        handlerName: 'MessageHandler', callback: (args) {
      // Handle your message here
      print("triggered");
    });

  }
}