import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:lottie/lottie.dart';
import 'package:quilt/src/Utility.dart';

import '../api/ApiHelper.dart';
import '../api/BaseApiService.dart';
import '../api/NetworkApiService.dart';
import '../base/BaseState.dart';

class OpenFeedBackWidget extends BasePage {
  bool isWeekly;
  OpenFeedBackWidget({required this.isWeekly});

  @override
  OpenFeedBackWidgetState createState() => OpenFeedBackWidgetState();
}

class OpenFeedBackWidgetState extends BasePageState<OpenFeedBackWidget> {
  bool isEnable = false;
  int selectedPos=0;
  TextEditingController textEditingController=new TextEditingController();
  ApiHelper apiHelper = ApiHelper();
 bool isApiCalling=false;
  FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
  }
  Future<void> updateFeedback() async {
    try{
      ApiResponse apiResponse;
      if(widget.isWeekly){
         apiResponse=await apiHelper.updateOverallFeedback(selectedPos.toString(),textEditingController.text.toString());
      }else{
         apiResponse=await apiHelper.updateOverallFeedback(selectedPos.toString(),textEditingController.text.toString());

      }
     if(apiResponse.status==Status.ERROR){
       isApiCalling=false;
       setState(() {

       });
       showSnackbar("Failed to submit feedback");
     }else{
       print("feedbackSaved");
       print(apiResponse.data);
       Navigator.of(context).pop({"success":true});
       //showSnackbar("Thank you for your feedback");
     }
    }catch(error){
      isApiCalling=false;
      setState(() {

      });
      print("error");
      print(error);
    }

  }
  void showSnackbar(String message) {
    int height = 180;
    if (Platform.isIOS) {
      height = 240;
    }
    final snackBar = SnackBar(
      backgroundColor: Colors.transparent,
      behavior: SnackBarBehavior.floating,
      elevation: 0,
      margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).size.height - height,
          right: 5,
          left: 5),
      content: PhysicalModel(
        color: Colors.white,
        elevation: 8,
        shape: BoxShape.circle,
        child: Container(
            padding:
            const EdgeInsets.only(left: 8, right: 8, top: 15, bottom: 15),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(20)),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey,
                  offset: Offset(0.0, 1.0), //(x,y)
                  blurRadius: 6.0,
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                    child: Row(
                      children: [
                        Container(
                          margin: EdgeInsets.only(left: 10),
                          child: Text(message,
                              style: TextStyle(
                                  color: Colors.black,
                                  fontFamily: "Causten-Regular",
                                  fontSize: 14)),
                        )
                      ],
                    )),
              ],
            )),
      ),
    );
    print("snackbar");
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Stack(children: [
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 5,
              margin: EdgeInsets.only(top: 10),
              decoration: BoxDecoration(
                color: Color(0xff454545),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            InkWell(
              child: Container(
                child: Image.asset(
                  "assets/images/close1.png",
                  height: 50,
                ),
                alignment: Alignment.topRight,
                margin: EdgeInsets.only(right: 20, top: 10),
              ),
              onTap: () {
                if(!isApiCalling){
                  Navigator.of(context).pop();
                }

              },
            ),
            Container(
              margin: EdgeInsets.only(bottom: 20, top: 10),
              child: Text(
                "How’s your experience so far?",
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontFamily: "Causten-Medium"),
              ),
            ),
            Container(
              margin: EdgeInsets.only(bottom: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  InkWell(child: Stack(
                    children: [
                      Container(
                        height: 50,
                        width: 50,
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xff272727),border: Border.all(color: selectedPos==1?Color(0xff40A1FB):Color(0xff272727),width: 2)
                        ),
                      ),
                      Positioned( right: 0,
                        top: 0,left:0,bottom: 0,child: Container(
                            width: 25,
                            height: 25,alignment: Alignment.center,
                            child: Image.asset(
                              "assets/images/open_feed1.png",
                              height: 25,
                              width: 25,
                            )),),
                    ],
                  ),onTap: (){
                    selectedPos=1;
                    setState(() {

                    });
                  },),
                  InkWell(child: Stack(
                    children: [
                      Container(
                        height: 50,
                        width: 50,
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xff272727),border: Border.all(color: selectedPos==2?Color(0xff40A1FB):Color(0xff272727),width: 2)
                        ),
                      ),
                      Positioned( right: 0,
                        top: 0,left:0,bottom: 0,child: Container(
                            width: 25,
                            height: 25,alignment: Alignment.center,
                            child: Image.asset(
                              "assets/images/open_feed2.png",
                              height: 25,
                              width: 25,
                            )),),
                    ],
                  ),onTap: (){
                    selectedPos=2;
                    setState(() {

                    });
                  },),
                  InkWell(child: Stack(
                    children: [
                      Container(
                        height: 50,
                        width: 50,
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xff272727),border: Border.all(color: selectedPos==3?Color(0xff40A1FB):Color(0xff272727),width: 2)
                        ),
                      ),
                      Positioned( right: 0,
                        top: 0,left:0,bottom: 0,child: Container(
                            width: 25,
                            height: 25,alignment: Alignment.center,
                            child: Image.asset(
                              "assets/images/open_feed3.png",
                              height: 25,
                              width: 25,
                            )),),
                    ],
                  ),onTap: (){
                    selectedPos=3;
                    setState(() {

                    });
                  },),
                  InkWell(child: Stack(
                    children: [
                      Container(
                        height: 50,
                        width: 50,
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xff272727),border: Border.all(color: selectedPos==4?Color(0xff40A1FB):Color(0xff272727),width: 2)
                        ),
                      ),
                      Positioned( right: 0,
                        top: 0,left:0,bottom: 0,child: Container(
                            width: 25,
                            height: 25,alignment: Alignment.center,
                            child: Image.asset(
                              "assets/images/open_feed4.png",
                              height: 25,
                              width: 25,
                            )),),
                    ],
                  ),onTap: (){
                    selectedPos=4;
                    setState(() {

                    });
                  },),
                  InkWell(child: Stack(
                    children: [
                      Container(
                        height: 50,
                        width: 50,
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xff272727),border: Border.all(color: selectedPos==5?Color(0xff40A1FB):Color(0xff272727),width: 2)
                        ),
                      ),
                      Positioned( right: 0,
                        top: 0,left:0,bottom: 0,child: Container(
                            width: 25,
                            height: 25,alignment: Alignment.center,
                            child: Image.asset(
                              "assets/images/open_feed5.png",
                              height: 25,
                              width: 25,
                            )),),
                    ],
                  ),onTap: (){
                    selectedPos=5;
                    setState(() {

                    });
                  },),
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.only(left: 15, right: 15, bottom: 30, top: 10),
              padding: EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20.0),
                border: Border.all(
                  color: Color(0xff272727), // Border color
                  width: 1.0,
                ),
              ),
              child: TextField(controller: textEditingController,maxLength: 500,onChanged: (text){
                if(!Utility.isEmpty(text)){
                  isEnable=true;
                }else{
                  isEnable=false;
                }
                setState(() {

                });
              },
                style: TextStyle(
                    color: Colors.white,
                    fontFamily: "Causten-Regular" // Text color
                ),focusNode: _focusNode,
                decoration: InputDecoration(
                  hintText: 'Tell us what you think',counterText: "",
                  hintStyle: TextStyle(
                      color: Color(0xff888888),
                      fontFamily: "Causten-Regular" // Hint text color
                  ),
                  border: InputBorder.none,
                ),
                maxLines: 3, // Adjust max lines as needed
              ),
            ),
            Container(
              height: 50,
              child: GestureDetector(
                child: Container(
                  alignment: Alignment.center,
                  child: Text(
                    "Send feedback",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color:selectedPos!=0&&isEnable ? Colors.black : Color(0xff454545),
                        fontSize: 14,
                        fontFamily: "Causten-Medium"),
                  ),
                  decoration: BoxDecoration(
                      color: isEnable&&selectedPos!=0 ? Color(0xff40A1FB) : Color(0xff1A1A1A),
                      borderRadius: BorderRadius.circular(30)),
                ),
                onTap: () {
                  if (selectedPos!=0&&isEnable) {
                    if(!isApiCalling){
                      _focusNode.unfocus();
                      isApiCalling=true;
                      setState(() {

                      });
                      updateFeedback();
                    }
                  }
                },
              ),
              width: double.infinity,
              margin: EdgeInsets.only(left: 15, right: 15, bottom: 10, top: 10),
            ),
          ],
        ),
        isApiCalling?Positioned(top: 0,bottom: 0,left: 0,right: 0,
          child:  Container(
            height: 100,
            width: 100,
            child: Center(
                child: Lottie.asset(
                    "assets/images/feed_preloader.json",height: 100,width: 100)
            ),
          ),
        ):Positioned(top: 0,bottom: 0,left: 0,right: 0,child: Container(),)
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
