import 'package:event_bus_plus/res/app_event.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../main.dart';
import '../api/ApiHelper.dart';
import '../api/BaseApiService.dart';
import '../api/NetworkApiService.dart';
import '../api/Objects.dart';

class FavoriteListWidget extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return FavoriteState();
  }
}
class FavoriteState extends State<FavoriteListWidget>{
  bool isArg=false;
  ApiHelper apiHelper = ApiHelper();
List<ContentObj>contentList=[];
FavoriteListObject? favoriteListObject;
bool isNewCollection=false;
bool isEnable=false;
  TextEditingController mobileNumberCntrl = new TextEditingController();

  @override
  void initState() {
    super.initState();

  }
  getArgs() {
    if (!isArg) {
      isArg = true;
      final args = ModalRoute.of(context)?.settings.arguments as Map;
      favoriteListObject = args["object"];
      contentList.addAll(favoriteListObject!.contentList!);
    }
  }
  @override
  Widget build(BuildContext context) {
getArgs();
    return  Scaffold(appBar: AppBar(
      elevation: 0,centerTitle: true,
      backgroundColor: Colors.black,title: Text(favoriteListObject!.collectionName,style: TextStyle(fontFamily: "Causten-Medium",fontSize: 18,color: Colors.white),),
      leading: InkWell(child:Container(child:  Icon(Icons.arrow_back_ios_rounded,color: Colors.white, size: 20),margin: EdgeInsets.only(left: 5),),onTap: (){
        Navigator.of(context).pop();
      },),actions: [
        InkWell(child: Container(child: Icon(Icons.more_horiz,color: Colors.white,),margin: EdgeInsets.only(right: 10),),onTap: (){
          showActionModel();
        },)
    ],
    ),backgroundColor: Colors.black,body: Container(child:Container(child: ListView.builder(
      padding: EdgeInsets.only(left: 16,right: 16,top: 16,bottom: 16),shrinkWrap: true,
      itemCount: contentList.length,
      itemBuilder: (context,int index) {
        return InkWell(child: Container(margin: EdgeInsets.only(top: 10,bottom: 10),child: Row(crossAxisAlignment: CrossAxisAlignment.center,mainAxisAlignment: MainAxisAlignment.center,children: [
          Container(decoration: BoxDecoration(color: Color(0xff272727),border: Border.all(color: Color(0xff3D3D3D)),borderRadius: BorderRadius.circular(15)),child:
          Container(),padding: EdgeInsets.only(right: 7,left: 7,top: 7,bottom: 7),height: 55,width: 55,),
          Expanded(child: Container(child: Column(crossAxisAlignment: CrossAxisAlignment.start,children: [

            Container(child:  Text(
              contentList![index].contentName!,
              style: TextStyle(fontSize: 16.0, fontFamily: "Causten-Medium",color: Colors.white),
            ),margin: EdgeInsets.only(top: 0),),
            Container(margin: EdgeInsets.only(top: 7),child: Row(children: [
              Container(child: SvgPicture.asset(contentTypeImage(contentList![
              index]
                  .contentType!
                  .toLowerCase()),color: Color(0xff5D5D5D),),margin: EdgeInsets.only(right: 5),),
              Container(child:  Text(getContentType(contentList![
              index]
                  .contentType!)+' . '+contentList![index].contentDuration!+" min",  style: TextStyle(fontSize: 12.0, fontFamily: "Causten-Regular",color: Color(0xff5D5D5D)),),margin: EdgeInsets.only(top: 2),)
            ],),),
          ],),margin: EdgeInsets.only(left: 12),)),
          InkWell(child: Container(child:Icon(Icons.bookmark,color: Color(0xff5D5D5D),),alignment: Alignment.center,),onTap: (){
            updateFavorite(contentList![
            index].id!,favoriteListObject!.collectionId,index);
          },)

        ],),),onTap: (){
          print("contentType");
          print(contentList![index]
              .contentType);
          print(contentList![index]
              .audioURL);
          print(contentList![index]
              .videoURL);

          if (contentList![index]
              .contentType ==
              "JOURNAL") {
            print(contentList![index]
                .contentUrl!);
            Navigator.pushNamed(
                context,
                HomeWidgetRoutes
                    .JournalWidget,
                arguments: {
                  "url": contentList![
                  index]
                });
          } else if (contentList![index]
              .contentType ==
              "ASSESSMENT") {
            Navigator.pushNamed(context,
                HomeWidgetRoutes.AssessmentWidget,
                arguments: {
                  "url": contentList![index]
                });
          } else if ((contentList![index]
              .contentType ==
              "EMI")||(contentList![
          index]
              .contentType ==
          "INFO_TIDBITS")||(contentList![
          index]
              .contentType ==
              "INFO_TIDBITS_OCD")||(contentList![
          index]
              .contentType ==
              "INFO_TIDBITS_GENERAL")) {
            print(contentList![index]
                .contentUrl!);
            Navigator.pushNamed(
                context,
                HomeWidgetRoutes
                    .EmiWidget,
                arguments: {
                  "url": contentList![
                  index]
                });
          } else {
            if (contentList![index]
                .contentFormat ==
                "VIDEO") {
              Navigator.pushNamed(
                  context,
                  HomeWidgetRoutes
                      .VideoplayerWidget,
                  arguments: {
                    "url": contentList![
                    index]
                  }).then((value) => {
              });
            }else if (contentList![index]
                .contentFormat ==
                "AUDIO") {
              setState(() {});
              Navigator.pushNamed(
                  context,
                  HomeWidgetRoutes
                      .AudioPlayerWidget,
                  arguments: {
                    "url": contentList![
                    index]
                  }).then((value) => {
              });
            } else {
              Navigator.pushNamed(
                  context,
                  HomeWidgetRoutes
                      .webScreenScreen,
                  arguments: {
                    "url": contentList![
                    index]
                  });
            }
          }
        },);
      },
    ),)/*Column(crossAxisAlignment: CrossAxisAlignment.start,mainAxisSize: MainAxisSize.max,children: [

      *//*Container(child: Column(children: [

       ,
       *//**//* Divider(color: Color(0xff3D3D3D),),
        Container(alignment: Alignment.topLeft,child:  Text(
          "Recommended",textAlign: TextAlign.start,
          style: TextStyle(fontSize: 18.0, fontFamily: "Causten-Medium",color: Colors.white),
        ),margin: EdgeInsets.only(top: 30,left: 15),),
        Container(margin: EdgeInsets.only(top: 20,left: 15),child: Row(children: [
        Container(decoration: BoxDecoration(color: Color(0xff272727),border: Border.all(color: Color(0xff3D3D3D)),borderRadius: BorderRadius.circular(15)),child:
        Container(child:  Container(child:SvgPicture.asset("assets/images/search1.svg",height: 50,width: 50,fit: BoxFit.scaleDown,color: Color(0xff5D5D5D),),),),padding: EdgeInsets.only(right: 7,left: 7,top: 7,bottom: 7),height: 55,width: 55,),
          Container(alignment: Alignment.topLeft,child:  Text(
            "Find similar",textAlign: TextAlign.start,
            style: TextStyle(fontSize: 16.0, fontFamily: "Causten-Medium",color: Colors.white),
          ),margin: EdgeInsets.only(top: 0,left: 15),)
      ],),)*//**//*
      ],),)*//*
    ],)*/),);
  }
  Future<void> updateFavorite(String id,String collectionId,int pos) async {
    ApiResponse? apiResponse = await apiHelper.updateFavorite(id,collectionId,false);
    LoginResponse loginResponse=LoginResponse.fromJson(apiResponse.data);
    if(loginResponse.status==200){
      List<ContentObj> contsList=[];

      contsList.add(contentList![pos]);
      eventBus.fire(MyEvent(contsList));
      contentList!.removeAt(pos);
      setState(() {

      });
    }
  }
  String getContentType(String lowerCase){
    if ((lowerCase.toLowerCase()=="positive_meditation")|| (lowerCase.toLowerCase()=="mantra_meditation")||(lowerCase.toLowerCase()=="negative_meditation")) {
      return "MEDITATION";
    }else if((lowerCase.toLowerCase() == "hypnotic_induction")){
      return "HYPNOSIS";
    }else if((lowerCase.toLowerCase() == "info_tidbits")||(lowerCase.toLowerCase() == "info_tidbits_ocd")||(lowerCase.toLowerCase() == "info_tidbits_general")){
      return "INTERESTING FACTS";
    }else if(lowerCase.toLowerCase()=="emi"){
      return "QUICK RESET";
    }else if (lowerCase.toLowerCase() == "426_breathing"||lowerCase.toLowerCase()=="box_breathing"||lowerCase.toLowerCase()=="positive_426_breathing"||lowerCase.toLowerCase()=="positive_box_breathing") {
      return "BREATH";
    }else{
      return lowerCase
          .toUpperCase()
          .replaceAll(
          "_",
          " ");
    }
  }
  void showDeleteDialog(){
    showDialog(
      context: context,barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (builder,setState){
          return Dialog(backgroundColor: Colors.black,child: Container(child: Column(mainAxisSize: MainAxisSize.min,children: [
/*
            Container(child: SvgPicture.asset("assets/images/delete.svg",height: 40,width: 40,),margin: EdgeInsets.only(top: 20),),
*/
            Container(child: Text("Delete collection \n"+favoriteListObject!.collectionName+"?",textAlign: TextAlign.center,style: TextStyle(color: Colors.black,fontSize: 20,fontFamily: "Causten-Medium"),),margin: EdgeInsets.only(top: 10),)
            ,Container(child: Text("This action will also remove all experiences saved to this collection from your favorites.",textAlign: TextAlign.center,style: TextStyle(color:Color(0xff888888),fontSize: 14,fontFamily: "Causten-Regular"),),margin: EdgeInsets.only(top: 10,left: 15,right: 15),)
            , GestureDetector(onTapDown: (dertails){
              Navigator.pop(context);
              deleteCollection();
            },child: Container(width: double.infinity,margin: EdgeInsets.only(left: 10,right:10,top: 20,bottom: 10),padding: EdgeInsets.only(left: 15,right: 15,top: 15,bottom: 15),child: Text("Delete",style: TextStyle(color: Colors.white,fontSize: 16,fontFamily: "Causten-Bold"),textAlign: TextAlign.center,),decoration: BoxDecoration(color: Color(0xffC84040),borderRadius: BorderRadius.circular(30)),),)
            , GestureDetector(onTapDown: (dertails){
              Navigator.of(context).pop();
            },child: Container(width: double.infinity,margin: EdgeInsets.only(left: 10,right:10,top: 0,bottom: 20),padding: EdgeInsets.only(left: 15,right: 15,top: 15,bottom: 15),child: Text("Cancel",style: TextStyle(color: Colors.white,fontSize: 16,fontFamily: "Causten-Medium"),textAlign: TextAlign.center),),)
          ],),),);
        }); // Custom dialog widget
      },
    );
  }
  Future<void> deleteCollection() async {
    ApiResponse? apiResponse = await apiHelper.deleteCollection(favoriteListObject!.collectionId);
    LoginResponse loginResponse=LoginResponse.fromJson(apiResponse.data);
    if(loginResponse.status==200){
      eventBus.fire(MyEvent(contentList!));

      Navigator.of(context).pop({"isDeleted":true});
    }
  }
  Future<void> createCollectionApi(String collectionName) async {
    ApiResponse? apiResponse = await apiHelper.createCollection(collectionName,favoriteListObject!.collectionId);
    CreateCollectionObject collectionObject=CreateCollectionObject.fromJson(apiResponse.data);
    if(collectionObject.collectionObject!=null){
      favoriteListObject!.collectionName=mobileNumberCntrl.text.toString();
      setState(() {

      });
    }
  }
  void showActionModel(){
    mobileNumberCntrl.text=favoriteListObject!.collectionName;
    isNewCollection=false;
    isEnable=true;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.black,
      isDismissible: true,
      builder: (BuildContext context) {
       return StatefulBuilder(builder: (BuildContext context, setState) {
         return isNewCollection?Padding(padding: const EdgeInsets.all(8.0),child: Column( mainAxisSize: MainAxisSize.min,children: [
           Container(
             width: 40,
             height: 5,
             decoration: BoxDecoration(
               color: Colors.grey[300],
               borderRadius: BorderRadius.circular(10),
             ),
           ),
           SizedBox(height: 16),
           Container(margin: const EdgeInsets.only(
               left: 15, right: 15, bottom: 30, top: 10),child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,children: [
             InkWell(child: Icon(Icons.arrow_back_ios_rounded,color: Colors.white, size: 20),onTap: (){
               isNewCollection=false;
               setState(() {

               });
             },),
             Container(child: Text('Rename collection',style: TextStyle(fontFamily: "Causten-Medium",fontSize: 18,color: Colors.white),),)
             ,InkWell(child: Icon(Icons.close,color: Colors.white, size: 20),onTap: (){
               Navigator.of(context).pop();
             },),
           ],),),
           Container( margin: const EdgeInsets.only(
               left: 15, right: 15, bottom: 5, top: 0),alignment: Alignment.topLeft,child: Text('Name',style: TextStyle(fontFamily: "Causten-Medium",fontSize: 14,color: Color(0xff888888)),),),
           Container(
             margin: const EdgeInsets.only(
                 left: 15, right: 15, bottom: 5, top: 0),
             padding: const EdgeInsets.all(3.0),
             child: TextField(
               controller: mobileNumberCntrl,inputFormatters: [
             FilteringTextInputFormatter.allow(RegExp("[a-z A-Z 0-9]")),
         ],maxLength: 50,
               keyboardType: TextInputType.text,style: TextStyle(fontFamily: "Causten-Medium",color: Colors.white,fontSize: 14),
               onChanged: (text) {
                 if (text.length>0) {
                   isEnable = true;
                 } else {
                   isEnable = false;
                 }
                 setState(() {});
               },

               decoration: InputDecoration(counterText: "",
                 enabledBorder: OutlineInputBorder(
                     borderSide: const BorderSide(color: Color(0xff3D3D3D), width: 0.7), // No border
                     borderRadius: BorderRadius.circular(30)
                 ),focusedBorder: OutlineInputBorder(
                   borderSide: const BorderSide(color:Color(0xff3D3D3D), width: 0.7), // No border
                   borderRadius: BorderRadius.circular(30)
               ),
                 filled: true,
                 fillColor: Colors.black,
                 contentPadding:
                 const EdgeInsets.symmetric(horizontal: 25.0,vertical: 15),
                 hintStyle: TextStyle(
                     color: Color(0xFFA0949D),
                     fontFamily: "Causten-Regular",
                     fontSize: 14),
                 hintText: "",),
             ),
           ),
           SizedBox(height: 10),

           Container(
             height: 45,
             child: ElevatedButton(
               onPressed: () async {
                 if(isEnable){
                   Navigator.of(context).pop();
                   createCollectionApi(mobileNumberCntrl.text.toString());
                 }
               },
               child: Text(
                 "Save",
                 style: TextStyle(
                     color: isEnable?Color(0xff1A1A1A):Color(0xffB0B0B0),
                     fontSize: 14,
                     fontFamily: "Causten-Medium"),
               ),
               style: ElevatedButton.styleFrom(
                   backgroundColor:
                   Color(0xffECECEC),
                   shape: RoundedRectangleBorder(
                     borderRadius: BorderRadius.circular(30), // <-- Radius
                   )),
             ),
             width: double.infinity,
             margin: EdgeInsets.only(left: 15, right: 15, bottom: 10,top: 0),
           ),
         ],),):Container(
             padding: MediaQuery.of(context).viewInsets,child:Container(
           decoration: BoxDecoration(
             color: Colors.black,
             borderRadius: BorderRadius.only(
               topLeft: Radius.circular(16.0),
               topRight: Radius.circular(16.0),
             ),
           ),child: Container(child: Column(mainAxisSize: MainAxisSize.min,children: [
           InkWell(child: Container(margin: EdgeInsets.only(left: 15,top: 30,bottom: 20,right: 15),child: Row(children: [
             SvgPicture.asset("assets/images/edit.svg",color: Color(0xff888888),),
             Container(margin: EdgeInsets.only(left: 15),child: Text("Rename",style: TextStyle(color: Colors.white,fontSize: 16,fontFamily: "Causten-Medium"),))
           ],),),onTap: (){
             isNewCollection=true;
             setState((){});
           },),
           InkWell(child: Container(margin: EdgeInsets.only(left: 15,top: 10,bottom: 20,right: 15),child: Row(children: [
             SvgPicture.asset("assets/images/delete.svg"),
             Container(margin: EdgeInsets.only(left: 15),child: Text("Delete collection",style: TextStyle(color: Color(0xffC84040),fontSize: 16,fontFamily: "Causten-Medium"),))

           ],),),onTap: (){
             Navigator.of(context).pop();
             showDeleteDialog();
           },)
         ],) ,padding: const EdgeInsets.all(8.0),),));
        });




      },
    );
  }

  String contentTypeImage(String lowerCase) {
    if (lowerCase == "sleep_story") {
      return "assets/images/moon.svg";
    } else if (lowerCase == "game") {
      return "assets/images/game.svg";
    } else if ((lowerCase == "meditation") || (lowerCase == "mindfulness") || (lowerCase=="positive_meditation")|| (lowerCase=="mantra_meditation")||(lowerCase=="negative_meditation")) {
      return "assets/images/meditation.svg";
    } else if (lowerCase == "breath") {
      return "assets/images/wind.svg";
    } else if (lowerCase == "journal") {
      return "assets/images/pen_white.svg";
    } else if (lowerCase == "emi") {
      return "assets/images/emi.svg";
    }else if (lowerCase == "breath"||lowerCase=="426_breathing"||lowerCase=="box_breathing"||lowerCase=="positive_426_breathing"||lowerCase=="positive_box_breathing") {
      return "assets/images/wind.svg";
    } else if (lowerCase == "hypnotic_induction") {
      return "assets/images/Hipnosys.svg";
    }else if (lowerCase == "info_tidbits"||lowerCase == "info_tidbits_ocd"||lowerCase == "info_tidbits_general") {
      return "assets/images/Lightbulb.svg";
    } else {
      return "assets/images/moon.svg";
    }
  }
}