import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:url_launcher/url_launcher.dart';

import '../base/BaseState.dart';

class VersionUpdateDialog extends BasePage {
  VersionUpdateDialog();

  @override
  VersionUpdateDialogState createState() => VersionUpdateDialogState();
}

class VersionUpdateDialogState extends BasePageState<VersionUpdateDialog> {
  AppUpdateInfo? _updateInfo;
@override
  void initState() {
    super.initState();
    checkForUpdate();
  }
  Future<void> _launchAppStore() async {
     String appStoreUrl = 'https://apps.apple.com/app/6462470118';
    await launchUrl(Uri.parse(appStoreUrl));
  }

  @override
  Widget build(BuildContext context) {
    return Container(padding:EdgeInsets.only(top:10,bottom:20,left:15,right:15),
      child: Stack(children: [
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: EdgeInsets.only(bottom: 0, top: 15),
              child: Text(
                "Version",
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontFamily: "Causten-Medium"),
              ),
            ),
            Container(
              margin: EdgeInsets.only(bottom: 10, top: 10),
              child: Text(
                "The newest version of the app is available",
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Color(0xff888888),
                    fontSize: 14,
                    fontFamily: "Causten-Regular"),
              ),
            ),

            Container(
              height: 50,
              child: GestureDetector(
                child: Container(
                  alignment: Alignment.center,
                  child: Text(
                    "Update",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color:Colors.black,
                        fontSize: 14,
                        fontFamily: "Causten-Medium"),
                  ),
                  decoration: BoxDecoration(
                      color: Color(0xff40A1FB),
                      borderRadius: BorderRadius.circular(30)),
                ),
                onTap: () {
                  if(Platform.isIOS){
                    _launchAppStore();
                  }else{
                    androidForceUpdate();
                  }

                },
              ),
              width: double.infinity,
              margin: EdgeInsets.only(left: 15, right: 15, bottom: 10, top: 10),
            ),
          ],
        ),

      ],),
    );
  }
  Future<void> checkForUpdate() async {
    InAppUpdate.checkForUpdate().then((info) {
      _updateInfo = info;
    });
  }
  void androidForceUpdate(){

    if(_updateInfo?.updateAvailability ==
        UpdateAvailability.updateAvailable){
      InAppUpdate.performImmediateUpdate()
          .catchError((e) {
        return AppUpdateResult.inAppUpdateFailed;
      });
    }
    Navigator.of(context).pop();
  }
  Widget buildEmojiAvatar(BuildContext context, String emoji, bool showBadge,
      {String? badgeText}) {
    return Stack(
      alignment: Alignment.center,
      children: [
        CircleAvatar(
          backgroundColor: Colors.black.withOpacity(0.8),
          radius: 30,
          child: Text(
            emoji,
            style: TextStyle(fontSize: 28),
          ),
        ),
        if (showBadge && badgeText != null)
          Positioned(
            right: 0,
            top: 0,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.orangeAccent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                badgeText,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
