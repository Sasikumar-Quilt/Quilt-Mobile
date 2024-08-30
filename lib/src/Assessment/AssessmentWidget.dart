import 'package:cached_network_image/cached_network_image.dart';
import 'package:fast_cached_network_image/fast_cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';
import 'package:lottie/lottie.dart';
import 'package:quilt/src/Utility.dart';
import 'package:quilt/src/api/Objects.dart';

import '../../main.dart';
import '../journal/JournalListWidget.dart';

class AssessmentWidget extends StatefulWidget {
  @override
  JournalWidgetState createState() => JournalWidgetState();
}

class JournalWidgetState extends State<AssessmentWidget> {
  DateTime? selectedDate;
  DateTime? currentWeekStart;
  ContentObj? contentObj;
  bool isArg = false;

  @override
  void initState() {
    super.initState();
    selectedDate = DateTime.now();
    currentWeekStart = _startOfWeek(selectedDate!);
  }
  DateTime _startOfWeek(DateTime date) {
    int daysFromMonday = (date.weekday - DateTime.monday) % 7;
    return date.subtract(Duration(days: daysFromMonday));
  }

  getArgs() {
    if (!isArg) {
      isArg = true;
      final args = ModalRoute.of(context)?.settings.arguments as Map;
      contentObj = args["url"];
    }
  }
  replayVideo(value) {
    if(value!=null&&value["isReplay"]){

    }else{
      Navigator.of(context).pop();
    }
  }
  @override
  Widget build(BuildContext context) {
    getArgs();
    return SafeArea(child: Scaffold(backgroundColor: Colors.black,body: Container(child: Stack(children: [
      Container( width: double.infinity,
        height: double.infinity,child:FastCachedImage(
          url: contentObj!.animations!,
          fit: BoxFit.cover,
          fadeInDuration: const Duration(milliseconds: 500),
          errorBuilder: (context, exception, stacktrace) {
            return Text(stacktrace.toString());
          },
          loadingBuilder: (context, progress) {
            return Container(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  if (progress.isDownloading && progress.totalBytes != null)
                    Container(
                      height: 100,
                      width: 100,
                      color: Colors.black,
                      child: Center(
                          child: Lottie.asset("assets/images/feed_preloader.json")),
                    ),


                ],
              ),
            );
          },
        )/*CachedNetworkImage( fit: BoxFit.cover,
      imageUrl: contentObj!.animations!,imageBuilder: (context, imageProvider) => Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                  image: imageProvider,
                  fit: BoxFit.cover,
                  colorFilter:
                  ColorFilter.mode(
                      Colors.black.withOpacity(0.85),
                      BlendMode.darken
                  )),
            ),
          ),
      errorWidget: (context, url, error) => Icon(Icons.error),
    )*/,),
      Positioned.fill(
        child: Container(
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.85),
            backgroundBlendMode: BlendMode.darken,
          ),
        ),
      ),
      Container(margin: EdgeInsets.only(top: 20,left: 15),child: IconButton(icon: Icon(Icons.arrow_back_ios,color: Colors.white,),onPressed: (){
        Navigator.of(context).pop();
      },),),
      Align(alignment: Alignment.center,child: Column(crossAxisAlignment: CrossAxisAlignment.center,mainAxisAlignment: MainAxisAlignment.center,mainAxisSize: MainAxisSize.min,children: [
        /*Container(child: Text(Utility.getDate("EEE, dd MMM"),textAlign: TextAlign.center,
          style: TextStyle(
              color: Color(0xffCFC9CE),fontSize: 12,fontFamily: "Causten-Regular"
          ),
        ),),*/
        Container(margin: EdgeInsets.only(top: 15),child: Text("How it works",textAlign: TextAlign.center,
          style: TextStyle(
              color: Colors.white,fontSize: 30,fontFamily: "Causten-Medium"
          ),
        ),),
        Container(margin: EdgeInsets.only(top: 15),height:null,child: SingleChildScrollView(scrollDirection: Axis.vertical,child: Container(child: Text(contentObj!.assessmentList!.assessmentDescription!,textAlign: TextAlign.center,
          style: TextStyle(
              color: Colors.white,fontSize: 16,fontFamily: "Causten-Regular"
          ),
        ),),),),
Container(alignment: Alignment.center,margin: EdgeInsets.only(top: 15),child: Row(crossAxisAlignment: CrossAxisAlignment.center,mainAxisAlignment: MainAxisAlignment.center,children: [
  Container(padding: EdgeInsets.all(5),decoration: BoxDecoration(borderRadius: BorderRadius.circular(15),color: Colors.white.withOpacity(0.2)),child: Row(children: [
    Container(child: SvgPicture.asset("assets/images/FirstAid.svg"),margin: EdgeInsets.only(left: 5),),
    Container(child: Text("ASSESSMENT",textAlign: TextAlign.center,
      style: TextStyle(
          color: Colors.white,fontSize: 12,fontFamily: "Causten-Regular"
      ),
    ),margin: EdgeInsets.only(left: 5,right: 5),)
  ],),),
  Container(child: Text(contentObj!.contentDuration!+" min",textAlign: TextAlign.center,
    style: TextStyle(
        color: Colors.white,fontSize: 12,fontFamily: "Causten-Regular"
    ),
  ),margin: EdgeInsets.only(left: 5,right: 5),)
],),)
      ],)),
      Align(alignment: Alignment.bottomCenter,child: Container(child: Column(mainAxisSize: MainAxisSize.min,children: [
        Container(child: ElevatedButton(
          onPressed: () {
            Navigator.pushNamed(
                context,
                HomeWidgetRoutes
                    .AssessmentListWidget,
                arguments: {
                  "url":contentObj
                }).then((value) => {
              replayVideo(value)
            });
          },style: ElevatedButton.styleFrom(backgroundColor:Colors.white),
          child: Row(crossAxisAlignment: CrossAxisAlignment.center,mainAxisAlignment: MainAxisAlignment.center,children: [

            Container(child: Text('Start Assessment',style:  TextStyle(
                color: Color(0xff131314),
                fontFamily: "Causten-Medium",
                fontSize: 16),),margin: EdgeInsets.only(left: 10),)
          ],),
        ),margin: EdgeInsets.only(top: 0,bottom: 20,left: 15,right: 15),width: double.infinity,height: 50,),
       /* InkWell(child: Container(margin: EdgeInsets.only(top: 10,bottom: 30),child: Text("See Previous Entries",textAlign: TextAlign.center,
          style: TextStyle(
              color: Colors.white,fontSize: 16,fontFamily: "Causten-Bold"
          ),
        ),),onTap: (){
          showJournalModel(context);
        },)*/
      ],),),)

    ],),),));
  }

  void showJournalModel(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,backgroundColor: Colors.white,
      builder: (context) => FractionallySizedBox(heightFactor: 0.95,child: JournalListWidget(contentObj: contentObj,),),
    );
  }
}