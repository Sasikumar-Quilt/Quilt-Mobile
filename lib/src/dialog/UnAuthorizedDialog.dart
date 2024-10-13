import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../main.dart';
import '../PrefUtils.dart';

void showErrorDialog(BuildContext? context) {
  GoogleSignIn? _googleSignIn;
  if (defaultTargetPlatform == TargetPlatform.android) {
    _googleSignIn = GoogleSignIn(
        clientId:
        "930588986366-rp6ddk8dm4siehj4n4di9d0t7kt270f8.apps.googleusercontent.com");
  } else {
    _googleSignIn = GoogleSignIn();
  }
  showDialog(
    context: context!,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return StatefulBuilder(builder: (builder, setState) {
        return Dialog(
          backgroundColor: Colors.black,
          child: Container(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
/*
            Container(child: SvgPicture.asset("assets/images/delete.svg",height: 40,width: 40,),margin: EdgeInsets.only(top: 20),),
*/
                Container(
                  child: Text(
                    "Unauthorized Access" ,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontFamily: "Causten-Medium"),
                  ),
                  margin: EdgeInsets.only(top: 10),
                ),
                Container(
                  child: Text(
                    "Oops! Your login session has ended. Please sign in again to keep using the app.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Color(0xff888888),
                        fontSize: 14,
                        fontFamily: "Causten-Regular"),
                  ),
                  margin: EdgeInsets.only(top: 10, left: 15, right: 15),
                ),
                GestureDetector(
                  onTapDown: (dertails) {
                    _googleSignIn?.signOut();
                    PreferenceUtils.clear();
                    Navigator.of(context).pop();
                    Navigator.pushNamedAndRemoveUntil(context, HomeWidgetRoutes.SplashScreen, (route) => false);

                  },
                  child: Container(
                    width: double.infinity,
                    margin: EdgeInsets.only(
                        left: 10, right: 10, top: 20, bottom: 10),
                    padding: EdgeInsets.only(
                        left: 15, right: 15, top: 15, bottom: 15),
                    child: Text(
                      "Okay",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontFamily: "Causten-Bold"),
                      textAlign: TextAlign.center,
                    ),
                    decoration: BoxDecoration(
                        color: Color(0xffC84040),
                        borderRadius: BorderRadius.circular(30)),
                  ),
                )
              ],
            ),
          ),
        );
      }); // Custom dialog widget
    },
  );
}