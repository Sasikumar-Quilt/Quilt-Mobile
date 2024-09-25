import 'dart:io';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';
import 'package:lottie/lottie.dart';
import 'package:quilt/src/base/BaseState.dart';

import '../api/ApiHelper.dart';
import '../api/Objects.dart';
import 'dart:math' as math;

class FeedBackWidget extends BasePage {
  ContentObj? contentObj;
  FeedBackWidget({this.contentObj});
  @override
  FeedBackWidgetState createState() => FeedBackWidgetState();
}

class FeedBackWidgetState extends BasePageState<FeedBackWidget> with SingleTickerProviderStateMixin{

  ApiHelper apiHelper = ApiHelper();
  bool isArg = false;
  ContentObj? contentObj;
  Offset _position = Offset.zero; // Track the current position of the image
  String _currentImage = 'assets/images/neutral.svg'; // Track the current image
  Offset? _initialPosition;
  int feedbackPos=3;
  bool isShowFeedback=false;
  late Animation<Offset> _offsetAnimation;
  late AnimationController _controller;

  @override
  void initState() {

    super.initState();
    SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.light
        )
    );
    contentObj=widget.contentObj;
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _offsetAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: Offset(0.1, 0.0),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticIn,
    ));
  }

  getArgs() {
    if (!isArg) {
      isArg = true;
      final args = ModalRoute.of(context)?.settings.arguments as Map;
      contentObj = args["object"];
      _initialPosition = args["offSet"];
    }
  }
Future<void> updateFeedback() async {
       apiHelper.updateContentFeedback(feedbackPos,contentObj!.contentId!);
       Navigator.of(context).pop({"isFeedback":true});
}
  @override
  Widget build(BuildContext context) {
    //getArgs();

    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;
    final double centerY = (screenHeight / 2);
    final double centerX = screenWidth / 2;
    final double height=centerY-60;
   _initialPosition = Offset(centerX+50, centerY-100);
    return Scaffold(
      backgroundColor: isShowFeedback?Colors.black:Colors.black.withOpacity(0.6),
      body:GestureDetector(child: isShowFeedback?Container(  width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Stack(children: [
          // The first layer: blurred black background
          Container(
            width: double.infinity,
            height: double.infinity,
            color: Color(0xFF0F0E0F), // Basic black color
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2), // Blur effect
              child: Container(
                color: Colors.black.withOpacity(0.1), // Slightly transparent overlay
              ),
            ),
          ),
          // Bottom ellipse gradient
          // Top ellipse gradient
          Align(

            child: Container(

             /* decoration: BoxDecoration(
                color: Color(0xFF40A1FB).withOpacity(0.7), // Primary blue color with opacity
                borderRadius: BorderRadius.circular(400), // 440px border radius
              ),*/
              child: Image.asset("assets/images/r_bg1.png",width: double.infinity,)/*BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 100, sigmaY: 30), // Heavy blur effect
                child: Container(
                  color: Colors.transparent,
                ),
              )*/,
            ),alignment: Alignment.topCenter,
          ),
          // Bottom ellipse gradient
          Align(alignment: Alignment.bottomCenter,

            child:  Container(

              /* decoration: BoxDecoration(
                color: Color(0xFF40A1FB).withOpacity(0.7), // Primary blue color with opacity
                borderRadius: BorderRadius.circular(400), // 440px border radius
              ),*/
              child: Image.asset("assets/images/r_bg2.png",width: double.infinity,)/*BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 100, sigmaY: 30), // Heavy blur effect
                child: Container(
                  color: Colors.transparent,
                ),
              )*/,
            ),
          ),
          Align(child: Container(margin: EdgeInsets.only(top: 90),decoration: BoxDecoration(
            border: Border.all(
                width: 1.0,color: Colors.white
            ),
            borderRadius: BorderRadius.all(
                Radius.circular(20.0) //                 <--- border radius here
            ),
          ),padding:EdgeInsets.only(left: 15,right: 15,top: 8,bottom: 8),child: Text("BETTER",style: TextStyle(color: Colors.white,fontSize: 14,fontFamily: "Causten-Regular"),),),alignment: Alignment.topCenter,)
          ,Align(child: Container(decoration: BoxDecoration(color: Colors.white,
            border: Border.all(
                width: 1.0,color: Colors.white
            ),
            borderRadius: BorderRadius.all(
                Radius.circular(20.0) //                 <--- border radius here
            ),
          ),padding:EdgeInsets.only(left: 15,right: 15,top: 8,bottom: 8),child: Text("THE SAME",style: TextStyle(color: Color(0xFF2E292C),fontSize: 14,fontFamily: "Causten-Bold"),),),alignment: Alignment.center,)
          ,Align(child: Container(child: SvgPicture.asset("assets/images/line.svg"),margin: EdgeInsets.only(bottom: 250),),alignment: Alignment.center,),
          Align(child: Container(child: SvgPicture.asset("assets/images/line.svg"),margin: EdgeInsets.only(top: 250),),alignment: Alignment.center,),
          Align(child: Container(decoration: BoxDecoration(
            border: Border.all(
                width: 1.0,color: Colors.white
            ),
            borderRadius: BorderRadius.all(
                Radius.circular(20.0) //                 <--- border radius here
            ),
          ),padding:EdgeInsets.only(left: 15,right: 15,top: 8,bottom: 8),margin: EdgeInsets.only(bottom: 90),child: Text("WORSE",style: TextStyle(color: Colors.white,fontSize: 14,fontFamily: "Causten-Regular"),),),alignment: Alignment.bottomCenter,)
          ,Positioned(
            left:  _position.dx,
            top:  _position.dy,

            child:  AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return FadeTransition(
                  opacity: animation,
                  child: ScaleTransition(
                    scale: animation,
                    child: child,
                  ),
                );
              },
              child: SvgPicture.asset(
                _currentImage,
                key: ValueKey<String>(_currentImage),
                height: 100,
              ),
            ),/*SlideTransition( position: _offsetAnimation,child: SvgPicture.asset(
              _currentImage,
              height: 100,
            ),)*/

          )],),
      ):Container(  width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        padding: EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(child:  Center(
              child:  Lottie.asset('assets/images/feedback.json'),
            ),margin: EdgeInsets.only(bottom: 0),),

            Text('How do you feel after\n this experience?',textAlign: TextAlign.center,style: TextStyle(
                color: Colors.white,
                fontFamily: "Causten-SemiBold",
                fontWeight: FontWeight.bold,
                fontSize: 20),),
            Container(child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop({"skip":true}); // Close the dialog
              },
              child: Text('Skip',style:  TextStyle(
                  color: Color(0xFF2E292C),
                  fontFamily: "Causten-Bold",
                  fontWeight: FontWeight.bold,
                  fontSize: 12),),
            ),margin: EdgeInsets.only(top: 30),),
          ],
        ),
      ),onPanUpdate: (details){
        _position += details.delta;
        print('Current Position: $_position');
        print(details.delta);

        if(!isShowFeedback){
          isShowFeedback=true;
        }
        setState(() {

          // Debug prints to track position and changes
          print('Current Position: $_position');
          print('Center Y: $centerY');
          // Change image based on position relative to center of the screen
          if (_position.dy > 380&&_position.dy<480) {

            _currentImage = 'assets/images/sad.svg'; // Below center
            if(feedbackPos!=4){
              vibrate();
              // _controller.forward(from: 0).then((_) =>  _controller.stop());
            }
            feedbackPos=4;
          }else if (_position.dy > 480) {


            _currentImage = 'assets/images/extremSad.svg'; // Below center
            if(feedbackPos!=5){
              vibrate();
              // _controller.forward(from: 0).then((_) =>  _controller.stop());
            }
            feedbackPos=5;
            /*Future.delayed(const Duration(milliseconds: 200), () {

            });*/
          } else if (_position.dy >130&&_position.dy <230) {

            _currentImage = 'assets/images/good.svg'; // Above center
            if(feedbackPos!=2){
              vibrate();
              // _controller.forward(from: 0).then((_) => _controller.reverse());
            }
            feedbackPos=2;
          }  else if (_position.dy <130) {

            _currentImage = 'assets/images/happy.svg'; // Above center
            if(feedbackPos!=1){
              vibrate();
              //_controller.forward(from: 0).then((_) =>  _controller.stop());
            }
            feedbackPos=1;
          } else {
            _currentImage = 'assets/images/neutral.svg'; // At center (replace with appropriate image path)
            if(feedbackPos!=3){
              vibrate();
              //_controller.forward(from: 0).then((_) => _controller.stop());
            }
            feedbackPos=3;
          }
          print('Current Image: $_currentImage');
        });

      },onPanStart: (details){

        _position=Offset(details.globalPosition.dx-100, details.globalPosition.dy-140);
        setState(() {

        });
      },onPanEnd: (details){
        updateFeedback();
      },),
    );
  }
  void vibrate() async{

  }
  void showFeedbackDialog(){
    bool _isSmile = true; // Track the current image state
    Offset _startPosition = Offset(0, 0); // Track the starting position of the drag
    Offset _endPosition = Offset(0, 0); // Track the current position of the drag

    double _maxHeight = 70.0; // Maximum height for the image movement
    double _maxWidth = 100.0; // Maximum width for the image movement

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (builder,setState){
          return Dialog(
            backgroundColor: Colors.transparent, // Transparent background
            child: Container(
              padding: EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                 Container(child:  GestureDetector(
              onPanStart: (details) {
            setState(() {
            _startPosition = details.globalPosition;
            _endPosition = _startPosition;
            });
            },
                   onPanEnd: (details){
                _isSmile=true;
                     setState(() {
                       _startPosition = Offset(0, 0);
                       _endPosition = Offset(0, 0);
                     });
                   },
              onPanUpdate: (details) {
                setState(() {
                  _endPosition += details.delta;
                  // Calculate the movement along the oblique line
                  double dx = _endPosition.dx - _startPosition.dx;
                  double dy = _endPosition.dy - _startPosition.dy;
                  // Limit movement to diagonal direction only
                  if (dx.abs() > dy.abs()) {

                    // Horizontal movement dominates, adjust dy to match dx
                    _endPosition = Offset(
                      _startPosition.dx + dy,
                      _startPosition.dy + dy,
                    );
                  } else {
                    // Vertical movement dominates, adjust dx to match dy
                    _endPosition = Offset(
                      _startPosition.dx + dx,
                      _startPosition.dy + dx,
                    );
                  }
// Restrict height and width of the movement
                  // Restrict height and width of the movement
                  double newHeight = (_endPosition.dy - _startPosition.dy).abs();
                  double newWidth = (_endPosition.dx - _startPosition.dx).abs();
                  // Calculate movement percentage based on maximum height and width
                  double heightPercentage = newHeight / _maxHeight;
                  double widthPercentage = newWidth / _maxWidth;
                  if (heightPercentage > 1.0) {
                    // Ensure the image does not exceed the maximum height
                    _endPosition = Offset(
                      _startPosition.dx + (_endPosition.dx - _startPosition.dx) / heightPercentage,
                      _startPosition.dy + (_endPosition.dy - _startPosition.dy) / heightPercentage,
                    );
                  }
                  if (widthPercentage > 1.0) {
                    // Ensure the image does not exceed the maximum width
                    _endPosition = Offset(
                      _startPosition.dx + (_endPosition.dx - _startPosition.dx) / widthPercentage,
                      _startPosition.dy + (_endPosition.dy - _startPosition.dy) / widthPercentage,
                    );
                  }
                  // Change image based on direction
                  if (dy>0) {
                    // Horizontal movement, change to sad image
                    _isSmile = false;
                  } else {
                    // Vertical movement, change to smile image
                    _isSmile = true;
                  }
                });
              },
              child: Center(
                child:  Transform.translate(
                  offset: _endPosition - _startPosition,
                  child: _isSmile
                      ? SvgPicture.asset('assets/images/rating1.svg', height: 100)
                      :SvgPicture.asset('assets/images/rating2.svg', height: 100),
                ),
              ),
            ),height: 200,margin: EdgeInsets.only(bottom: 20),),

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
        }); // Custom dialog widget
      },
    );
  }
}
