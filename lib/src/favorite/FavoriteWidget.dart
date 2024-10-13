import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lottie/lottie.dart';
import 'package:quilt/src/favorite/CollectionHelper.dart';
import 'package:shimmer/shimmer.dart';

import '../../main.dart';
import '../api/ApiHelper.dart';
import '../api/BaseApiService.dart';
import '../api/NetworkApiService.dart';
import '../api/Objects.dart';
import 'FavoriteListWidget.dart';

class FavoriteWidget extends StatefulWidget{
  FavoriteWidget({Key? key}): super(key: key);
  @override
  State<StatefulWidget> createState() {
    return FavoriteState();
  }
}
class FavoriteState extends State<FavoriteWidget>{
  bool isEmpty=false;
  ApiHelper apiHelper = ApiHelper();
List<FavoriteListObject>favLists=[];
bool isApiContentLoading=true;
bool isApiCalling=false;
CollectionHelper collectionHelper=new CollectionHelper();
  @override
  void initState() {
    super.initState();
    isActionUpdate=false;
    print("initFav");
    Future.delayed(Duration.zero,(){
     getFavListApi(null);
    });
  }
  Future<void> getFavListApi(value) async {
    if(isActionUpdate){
      isApiCalling=true;
      setState(() {
      });
    }
    ApiResponse? apiResponse=null;
    collectionHelper.resetCollectionCount();
    apiResponse = await apiHelper.getFavList();
    if (apiResponse.status == Status.COMPLETED) {
      FavoriteList cList = FavoriteList.fromJson(apiResponse.data);
      if (cList.favList != null && cList.favList!.isNotEmpty) {
        favLists=[];
        favLists.addAll(cList.favList!);
        print("favList");
        print(favLists.length);
        collectionHelper.updateCollectionCount(favLists);
      }else{
        favLists=[];
      }
    }
    isApiContentLoading=false;
    isApiCalling=false;
    setState(() {

    });
  }

  @override
  Widget build(BuildContext context) {

    return  SafeArea(child: Scaffold(backgroundColor: Colors.black,body: Stack(children:[
      Container(child:Column(crossAxisAlignment: CrossAxisAlignment.start,children: [
        Container(margin: EdgeInsets.only(left: 15,top: 0),child: Text("Favorites",style: TextStyle(color: Colors.white,fontSize: 24,fontFamily: "Causten-Medium"),),)
        ,!isApiContentLoading&&favLists.isEmpty?Container(height: 500,alignment: Alignment.center,child: Column(crossAxisAlignment:CrossAxisAlignment.center,mainAxisAlignment: MainAxisAlignment.center,mainAxisSize: MainAxisSize.max,children: [
          Container(child: Image.asset("assets/images/book1.png"),height: 60,width: 60,),
          Container(margin: EdgeInsets.only(left: 15,top: 30),child: Text("No favorites in your library yet",style: TextStyle(color: Colors.white,fontSize: 20,fontFamily: "Causten-Medium"),),)

          ,Container(margin: EdgeInsets.only(left: 15,top: 10),child: Text("Any content you bookmark and add to \nyour favorites will appear here.",textAlign: TextAlign.center,style: TextStyle(color: Color(0xff888888),fontSize: 14,fontFamily: "Causten-Regular"),),)
          ,GestureDetector(child: Container(padding: EdgeInsets.only(left: 15,top: 8,right: 15,bottom: 8),margin: EdgeInsets.only(top: 25),decoration: BoxDecoration(border: Border.all(color: Color(0xff888888)),borderRadius: BorderRadius.circular(30)),child: Row(mainAxisSize: MainAxisSize.min,crossAxisAlignment: CrossAxisAlignment.center,mainAxisAlignment: MainAxisAlignment.center,children: [
            Container(child:SvgPicture.asset("assets/images/search1.svg"),),

            Container(margin: EdgeInsets.only(left: 8,top: 0),child: Text("Explore Experiences",textAlign: TextAlign.center,style: TextStyle(color: Colors.white,fontSize: 14,fontFamily: "Causten-Medium"),),)

          ],),),onTap: (){
            Navigator.of(context).pop();

          },)
        ],),):isApiContentLoading?Container(height: 220 ,child:/* Image.asset("assets/images/favLoader.png",height: 200,)*/Shimmer.fromColors( enabled:true ,
          baseColor:Colors.grey.withOpacity(0.5), highlightColor: Colors.grey.withOpacity(0.7),
          child: Container(child: Column(crossAxisAlignment: CrossAxisAlignment.start,mainAxisSize: MainAxisSize.min,children: [
            Container(child: Row(children: [
              Container(height: double.infinity,padding: EdgeInsets.only(left: 0,top: 0,right: 3,bottom: 0),child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.asset(
                    fit: BoxFit.cover,
                    "assets/images/fav9.png",width: 160
                ),
              ),)
            ],),height: 150,),
            Container(child:   Text(""),decoration: BoxDecoration(color: Colors.grey,borderRadius: BorderRadius.circular(8)),width: 160,margin: EdgeInsets.only(top: 10)),
            Container(child:  Text(""),decoration: BoxDecoration(color: Colors.grey,borderRadius: BorderRadius.circular(8)),width: 130,margin: EdgeInsets.only(top: 10)),

          ],),),),margin: EdgeInsets.only(top: 30,left: 15),):Expanded(child: Container(child:         favLists.isNotEmpty?Container(margin: EdgeInsets.only(top: 20,bottom: 0),child: GridView.builder(
          padding: EdgeInsets.all(16.0),shrinkWrap: true,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.7,
            crossAxisSpacing: 16.0,
            mainAxisSpacing: 16.0,

          ),scrollDirection: Axis.vertical,
          itemCount: favLists.length,
          itemBuilder: (context,int index) {
            return Container(height: 220,child: Column(crossAxisAlignment: CrossAxisAlignment.start,children: [
              Expanded(child:  Container(decoration: BoxDecoration(color: Color(0xff272727),border: Border.all(color: Color(0xff3D3D3D)),borderRadius: BorderRadius.circular(15)),child:
              getListWidgets(favLists[index]),padding: EdgeInsets.only(right: 7,left: 7,top: 7,bottom: 7),)),
              Container(child:  Text(
                favLists[index].collectionName[0].toUpperCase() + favLists[index].collectionName.substring(1),
                style: TextStyle(fontSize: 16.0, fontFamily: "Causten-Medium",color: Colors.white),
              ),margin: EdgeInsets.only(top: 10),),
              Container(child:  Text((favLists[index].contentList!.length.toString() +' experiences') as String,  style: TextStyle(fontSize: 12.0, fontFamily: "Causten-Regular",color: Color(0xff5D5D5D)),),margin: EdgeInsets.only(top: 2),),
            ],),);
          },
        ),):Container()
          ,))
      ],)),
      isApiCalling
          ? Positioned(
        top: 0,
        bottom: 0,
        left: 0,
        right: 0,
        child: Container(
          height: 150,
          width: 150,
          child: Center(
              child: Lottie.asset(
                  "assets/images/feed_preloader.json",
                  height: 150,
                  width: 150)),
        ),
      )
          : Positioned(
        top: 0,
        bottom: 0,
        left: 0,
        right: 0,
        child: Container(),
      )
    ] ,),));
  }
  Widget getListWidgets(FavoriteListObject favoriteListObject){
    if(favoriteListObject.contentList!.length>3){
      return getListWidget(favoriteListObject);
    }else  if(favoriteListObject.contentList!.length==2){
      return getListTwoWidget(favoriteListObject);
    }else  if(favoriteListObject.contentList!.length==1){
      return getListOneWidget(favoriteListObject);
    }else  if(favoriteListObject.contentList!.length==3){
      return getThreeListWidget(favoriteListObject);
    }else{
      return getEmptyWidget(favoriteListObject);
    }

  }
  Widget getListTwoWidget(FavoriteListObject favoriteListObject){
    return InkWell(child: Container(child: Row(children: [
      Expanded(child: Container(height: double.infinity,padding: EdgeInsets.only(left: 0,top: 0,right: 3,bottom: 0),child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.asset(

          fit: BoxFit.cover,
          "assets/images/fav8.png",

        ),
      ),)),
      Expanded(child: Container(height: double.infinity,padding: EdgeInsets.only(left: 3,top: 0,right: 0,bottom: 0),child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.asset(

          fit: BoxFit.cover,
          "assets/images/fav9.png",

        ),
      ),))
    ],),),onTap: (){
      Navigator.pushNamed(
          context,
          HomeWidgetRoutes
              .FavoriteListWidget,arguments: {"object":favoriteListObject}).then((value) =>
      {
        getFavListApi(value)
      });
    },);
  }
  Widget getListOneWidget(FavoriteListObject favoriteListObject){
    return InkWell(child: Container(child: Row(children: [
      Expanded(child: Container(height: double.infinity,padding: EdgeInsets.only(left: 0,top: 0,right: 3,bottom: 0),child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.asset(

          fit: BoxFit.cover,
          "assets/images/fav9.png",

        ),
      ),))
    ],),),onTap: (){
      Navigator.pushNamed(
          context,
          HomeWidgetRoutes
              .FavoriteListWidget,arguments: {"object":favoriteListObject}).then((value) =>
      {
        getFavListApi(value)
      });
    },);
  }
  Widget getEmptyWidget(FavoriteListObject favoriteListObject){
    return Container(child: SvgPicture.asset("assets/images/logo1.svg",height: 50,width: 50,  fit: BoxFit.scaleDown),width: double.infinity,);
  }
  Widget getThreeListWidget(FavoriteListObject favoriteListObject){
    return InkWell(child: Container(child: Row(children: [
      Expanded(child: Column(children: [
        Expanded(child: Container(padding: EdgeInsets.only(left: 0,top: 0,right: 2,bottom: 2),child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.asset(
            fit: BoxFit.cover,
            "assets/images/fav5.png",
          ),
        ),)),
        Expanded(child: Container(padding: EdgeInsets.only(left: 0,top: 2,right: 2,bottom: 0),child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.asset(
            fit: BoxFit.cover,
            "assets/images/fav7.png",
          ),
        ),))
      ],)),
      Expanded(child: Column(children: [
        Expanded(child: Container(padding: EdgeInsets.only(left: 2,top: 0,right: 0,bottom: 2),child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.asset(

            fit: BoxFit.cover,
            "assets/images/fav7.png",

          ),
        ),)),
      ],))
    ],),),onTap: (){
      Navigator.pushNamed(
          context,
          HomeWidgetRoutes
              .FavoriteListWidget,arguments: {"object":favoriteListObject}).then((value) =>
      {
        getFavListApi(value)
      });
    },);
  }
  Widget getListWidget(FavoriteListObject favoriteListObject){
    return InkWell(child: Container(child: Row(children: [
      Expanded(child: Column(children: [
        Expanded(child: Container(padding: EdgeInsets.only(left: 0,top: 0,right: 2,bottom: 2),child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.asset(
            fit: BoxFit.cover,
           "assets/images/fav1.png",
          ),
        ),)),
        Expanded(child: Container(padding: EdgeInsets.only(left: 0,top: 2,right: 2,bottom: 0),child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.asset(
            fit: BoxFit.cover,
            "assets/images/fav2.png",
          ),
        ),))
      ],)),
      Expanded(child: Column(children: [
        Expanded(child: Container(padding: EdgeInsets.only(left: 2,top: 0,right: 0,bottom: 2),child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.asset(

            fit: BoxFit.cover,
            "assets/images/fav3.png",

          ),
        ),)),
        Expanded(child: Container(padding: EdgeInsets.only(left: 2,top: 2,right: 0,bottom: 0),child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.asset(

            fit: BoxFit.cover,
            "assets/images/fav4.png",

          ),
        ),))
      ],))
    ],),),onTap: (){
      Navigator.pushNamed(
          context,
          HomeWidgetRoutes
              .FavoriteListWidget,arguments: {"object":favoriteListObject}).then((value) =>
      {
        getFavListApi(value)
      });
    },);
  }
}
/* Container(margin: EdgeInsets.only(top: 15,left: 15,right: 15),child: Row(crossAxisAlignment: CrossAxisAlignment.center,mainAxisAlignment: MainAxisAlignment.spaceBetween,children: [
          Container(padding: EdgeInsets.only(left: 10,top: 5,right: 10,bottom: 5),decoration: BoxDecoration(border: Border.all(color: Color(0xff454545)),borderRadius: BorderRadius.circular(30)),child: Row(mainAxisSize: MainAxisSize.min,crossAxisAlignment: CrossAxisAlignment.center,mainAxisAlignment: MainAxisAlignment.center,children: [

            Container(margin: EdgeInsets.only(left: 8,top: 0,right: 8),child: Text("Last saved to",textAlign: TextAlign.center,style: TextStyle(color: Colors.white,fontSize: 14,fontFamily: "Causten-Medium"),),)
            ,Container(child:Icon(Icons.keyboard_arrow_down_rounded,color: Colors.white,),),
          ],),),

          Container(child:SvgPicture.asset("assets/images/search2.svg"),),
        ],),),*/
/*
        isApiContentLoading?Container(child: Lottie.asset("assets/images/pre_loader.json",width: double.infinity),width: double.infinity,alignment: Alignment.topCenter,):Container()
*/