import 'dart:ui';

import 'package:event_bus_plus/res/event_bus.dart';
import 'package:fast_cached_network_image/fast_cached_network_image.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;
import 'package:flutter/services.dart';
import 'package:quilt/src/Analytics/UserTrackingHelper.dart';
import 'package:quilt/src/Assessment/AssessmentListWidget.dart';
import 'package:quilt/src/Assessment/AssessmentWidget.dart';
import 'package:quilt/src/DashbaordWidget.dart';
import 'package:quilt/src/PushNotificationService.dart';
import 'package:quilt/src/SliderWidget.dart';
import 'package:quilt/src/WebViewWidget.dart';
import 'package:quilt/src/auth/EditProfileWidget.dart';
import 'package:quilt/src/auth/OTPWidget.dart';
import 'package:quilt/src/auth/CreateProfileWidget.dart';
import 'package:quilt/src/auth/ProfileWidget.dart';
import 'package:quilt/src/base/AppEnvironment.dart';
import 'package:quilt/src/dialog/GlobalContextService.dart';
import 'package:quilt/src/emi/EMIWidget.dart';
import 'package:quilt/src/favorite/FavoriteListWidget.dart';
import 'package:quilt/src/favorite/FavoriteWidget.dart';
import 'package:quilt/src/feed/HomeWidgetRoute.dart';
import 'package:quilt/src/feedback/FeedbackWidget.dart';
import 'package:quilt/src/journal/JournalEditorWidget.dart';
import 'package:quilt/src/journal/JournalListWidget.dart';
import 'package:quilt/src/journal/JournalWidget.dart';
import 'package:quilt/src/termsAndCondition/TCWidget.dart';
import 'package:quilt/src/video/AudioPlayerWidget.dart';
import 'package:quilt/src/video/VideoCompletedWidget.dart';
import 'package:quilt/src/video/VideoPlayerWidget.dart';

import 'SplashScreen.dart';
//AudioHandler? audioHandler;

String? routeName="";
int currentTab=0;
const splashTextColor=Color(0xFF2E292C);
const greyColor=Color(0xFFA0949D);

final routes = <String, Widget>{
  HomeWidgetRoutes.SplashScreen:SplashWidget(),
  HomeWidgetRoutes.EnterPasswordWidget:OTPWidget(),
  HomeWidgetRoutes.slideScreen:SliderPage(),
  HomeWidgetRoutes.webScreenScreen:WebviewWidget(),
  HomeWidgetRoutes.profileScreen:ProfileWidget(),
  HomeWidgetRoutes.EditProfileWidget:EditProfileWidget(),
  HomeWidgetRoutes.EnterUserNameWidget:CreateProfileWidget(),
  HomeWidgetRoutes.DashboardWidget:MainContainerWidget(),
  HomeWidgetRoutes.VideoplayerWidget:VideoplayerWidget(),
  HomeWidgetRoutes.VideoCompletedWidget:VideoCompletedWidget(),
  HomeWidgetRoutes.FeedBackWidget:FeedBackWidget(),
  HomeWidgetRoutes.JournalEditorWidget:JournalEditorWidget(),
  HomeWidgetRoutes.JournalListWidgetState:JournalListWidget(),
  HomeWidgetRoutes.JournalWidget:JournalWidget(),
  HomeWidgetRoutes.EmiWidget:EMIWidget(),
  HomeWidgetRoutes.AudioPlayerWidget:AudioPlayerWidget(),
  HomeWidgetRoutes.FavoriteListWidget:FavoriteListWidget(),
  HomeWidgetRoutes.FavoriteWidget:FavoriteWidget(),
  HomeWidgetRoutes.AssessmentWidget:AssessmentWidget(),
  HomeWidgetRoutes.AssessmentListWidget:AssessmentListWidget(),
  HomeWidgetRoutes.TCWebView:TCWebView(),
};

class HomeWidgetRoutes{
  static const SplashScreen = "SplashScreen";
  static const OtpScreen = "otpScreen";
  static const mobileNumberScreen = "mobileNumberScreen";
  static const EnterEmailWidget = "EnterEmailWidget";
  static const EnterPasswordWidget = "EnterPasswordWidget";
  static const EnterUserNameWidget = "EnterUserNameWidget";
  static const homeScreen = "homeScreen";
  static const slideScreen = "slideScreen";
  static const webScreenScreen = "webViewScreen";
  static const profileScreen = "profileScreen";
  static const EditProfileWidget = "EditProfileWidget";
  static const editProfile = "editProfile";
  static const EnterAgeWidget = "EnterAgeWidget";
  static const GenderWidget = "GenderWidget";
  static const DashboardWidget = "DashboardWidget";
  static const VideoplayerWidget = "VideoplayerWidget";
  static const VideoCompletedWidget = "VideoCompletedWidget";
  static const FeedBackWidget = "FeedBackWidget";
  static const JournalEditorWidget = "JournalEditorWidget";
  static const JournalListWidgetState = "JournalListWidgetState";
  static const JournalWidget = "JournalWidget";
  static const EmiWidget = "EmiWidget";
  static const AudioPlayerWidget = "AudioPlayerWidget";
  static const FavoriteListWidget = "FavoriteListWidget";
  static const FavoriteWidget = "FavoriteWidget";
  static const AssessmentWidget = "AssessmentWidget";
  static const AssessmentListWidget = "AssessmentListWidget";
  static const TCWebView = "TCWebView";
}
IEventBus eventBus = EventBus();

void main() async{
  print(appFlavor);
  print("flavor");
  AppEnvironment.setupEnv("Staging");
  await FastCachedImageConfig.init(clearCacheAfter: const Duration(days: 15));
  WidgetsFlutterBinding.ensureInitialized();
  PushNotificationService.initialize();
  FlutterError.onError = (errorDetails) {
    FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
  };
  // Pass all uncaught asynchronous errors that aren't handled by the Flutter framework to Crashlytics
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };
  runApp(App());
}
class App extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
   return MyApp();
  }
}

class MyApp extends State<App> {
  UserTrackingHelper? userTrackingHelper;
@override
  void initState() {
    super.initState();
    userTrackingHelper=UserTrackingHelper();
  }
  @override
  void dispose() {
    print("applicationKilled");
    super.dispose();
  }
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final MyRouteObserver routeObserver = MyRouteObserver();

    return MaterialApp(debugShowCheckedModeBanner: false,
        title: 'Quilt',
        theme: ThemeData(
          primaryColor: Colors.white,
        ),
        home: SplashWidget(),navigatorKey: GlobalContextService.navigatorKey,onGenerateRoute: onGenerateRoute,navigatorObservers: [routeObserver],
    );
  }

  Route onGenerateRoute(RouteSettings settings) {
    final String? route= settings.name;
    print("routeName");
    print(route);
    routeName=route;
    final Widget nextWidget = routes[routeName]!;
    return CupertinoPageRoute( builder: (context) => nextWidget,
      settings: settings,);

  }
}
class MyRouteObserver extends RouteObserver<PageRoute<dynamic>> {
  @override
  void didPop(Route route, Route? previousRoute) {
    print("didPop");
    routeName=previousRoute?.settings.name;
    print("routeName");
    print(routeName);

    super.didPop(route, previousRoute);
  }
  @override
  void didRemove(Route route, Route? previousRoute) {
    super.didRemove(route, previousRoute);
    print("didRemove");
  }
}
