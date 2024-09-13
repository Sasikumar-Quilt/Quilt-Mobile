import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';

import '../base/BaseState.dart';

class FeedBackDialog extends BasePage {
  FeedBackDialog();

  @override
  FeedBackDialogState createState() => FeedBackDialogState();
}

class FeedBackDialogState extends BasePageState<FeedBackDialog> {

  @override
  Widget build(BuildContext context) {
    return Container(padding:EdgeInsets.only(top:10,bottom:20,left:15,right:15),
      child: Stack(children: [
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              child: SvgPicture.asset(
                "assets/images/terms_img.svg",
                height: 50,
                width: 50,
              ),
              alignment: Alignment.center,
              margin:
              EdgeInsets.only(top: 20, bottom: 0),
            ),
            Container(
              margin: EdgeInsets.only(bottom: 0, top: 15),
              child: Text(
                "Thank you for your feedback",
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
                "Thank you so much for taking the time to share your thoughts and feedback with us",
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
                    "Okay",
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
                 Navigator.of(context).pop();
                },
              ),
              width: double.infinity,
              margin: EdgeInsets.only(left: 0, right: 0, bottom: 10, top: 10),
            ),
          ],
        ),

      ],),
    );
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
