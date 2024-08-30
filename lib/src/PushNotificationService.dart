import 'dart:convert';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_badger/flutter_app_badger.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'firebase/FirebaseOptions.dart';

class PushNotificationService{
  static final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  static Future<void> initialize() async {

    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

    //ios update
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    print('User granted permission: ${settings.authorizationStatus}');
    await _firebaseMessaging.subscribeToTopic('high_importance_channel');

    FirebaseMessaging.onBackgroundMessage(PushNotificationService.firebaseMessagingBackgroundHandler);

    await PushNotificationService.setupFlutterNotifications();
    setForegroundNotification();
  }


  @pragma('vm:entry-point')
  static Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    await PushNotificationService.setupFlutterNotifications();
    if (message.data.isNotEmpty) {
       showFlutterNotification(message);
    }
    // If you're going to use other Firebase services in the background, such as Firestore,
    // make sure you call `initializeApp` before using other Firebase services.
    print('Handling a background message ${message.messageId}');
  }
  static late AndroidNotificationChannel channel;

  static bool isFlutterLocalNotificationsInitialized = false;
  static Future<void> setupFlutterNotifications() async {
    if (isFlutterLocalNotificationsInitialized) {
      return;
    }
    channel = const AndroidNotificationChannel(
      'high_importance_channel', // id
      'High Importance Notifications', // title
      description:
      'This channel is used for important notifications.', // description
      importance: Importance.high,ledColor:Colors.green,enableLights: true,
    );

    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    FlutterAppBadger.removeBadge();

    /// Create an Android Notification Channel.
    ///
    /// We use this channel in the `AndroidManifest.xml` file to override the
    /// default FCM channel to enable heads up notifications.
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    /// Update the iOS foreground notification presentation options to allow
    /// heads up notifications.
    await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
    isFlutterLocalNotificationsInitialized = true;
  }
  static late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  static void setForegroundNotification(){
    FirebaseMessaging.onMessage.listen(PushNotificationService.showFlutterNotification);
  }

  static void showFlutterNotification(RemoteMessage message) {
    print("showFlutterNotification");
    print(message);

    print(message.data);

    String title="";
    String body="";
    if(message.data.isNotEmpty){
      Map<String, dynamic> content = message.data['content'] is String
          ? jsonDecode(message.data['content'])
          : message.data['content'];
       title = content['title'] ?? 'No Title';
       body = content['payload'] ?? 'No Payload';
    }
   /* RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;*/
    if(Platform.isAndroid){
      flutterLocalNotificationsPlugin.show(
        0,
        title,
        body,
        NotificationDetails(
          android: AndroidNotificationDetails(
              channel.id,
              channel.name,color: Colors.green,priority: Priority.high,
              channelDescription: channel.description,colorized: true,
              icon: 'ic_notification'
          ),
        ),
      );
    }
  }
}

