import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:quilt/src/PrefUtils.dart';
import 'package:quilt/src/api/Objects.dart';

import '../api/ApiHelper.dart';
import '../api/NetworkApiService.dart';


class ModalContent extends StatefulWidget {
  List<CollectionObject>collectionList=[];
  String id="";
  bool isFav=false;
  ModalContent(this.collectionList,this.id,this.isFav);
  @override
  _ModalContentState createState() => _ModalContentState();
}

class _ModalContentState extends State<ModalContent> {
  // Add state variables here if needed
bool isNewCollection=false;
bool isEnable=false;
ApiHelper apiHelper = ApiHelper();
List<CollectionObject>collectionList=[];
String collectionId="";

TextEditingController mobileNumberCntrl = new TextEditingController();
Future<void> createCollectionApi(String collectionName) async {
  ApiResponse? apiResponse = await apiHelper.createCollection(collectionName,"");
  CreateCollectionObject collectionObject=CreateCollectionObject.fromJson(apiResponse.data);
  if(collectionObject.collectionObject!=null){
    isNewCollection=false;
    PreferenceUtils.setString("collectionName", collectionObject.collectionObject!.collectionName!);
    PreferenceUtils.setString("collectionID", collectionObject.collectionObject!.collectionId!);
    collectionList.add(collectionObject.collectionObject!);
    updateFavorite(widget.id, collectionObject.collectionObject!.collectionId!,true);
  }
}
Future<void> updateFavorite(String id,String collectionId,bool isFav) async {
  ApiResponse? apiResponse = await apiHelper.updateFavorite(id,collectionId,isFav);
  LoginResponse loginResponse=LoginResponse.fromJson(apiResponse.data);
  if(loginResponse.status==200){
    if(isFav){
      Navigator.of(context).pop({"isUpdated":true,"cList":collectionList});
    }

  }
}
Future<void> getCollectionList() async {
  ApiResponse? apiResponse = await apiHelper.getCollections();
  CollectionList sCollectionList=CollectionList.fromJson(apiResponse.data);
  if(sCollectionList.collectionList!.isNotEmpty){
    collectionList=[];
    collectionList.addAll(sCollectionList.collectionList!);
    setState(() {
    });
  }
}
@override
  void initState() {
    // TODO: implement initState
    super.initState();
    if(widget.collectionList.isEmpty){
      getCollectionList();
    }else{
      collectionList=widget.collectionList;
    }
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16.0),
          topRight: Radius.circular(16.0),
        ),
      ),
      child: Padding(

        padding: const EdgeInsets.all(8.0),
        child: isNewCollection?Column( mainAxisSize: MainAxisSize.min,children: [
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
            InkWell(child: Icon(Icons.arrow_back_ios_rounded,color: Color(0xff888888), size: 20),onTap: (){
              isNewCollection=false;
              setState(() {

              });
            },),
            Container(child: Text('New collection',style: TextStyle(fontFamily: "Causten-Medium",fontSize: 18,color: Colors.black),),)
            ,InkWell(child: Icon(Icons.close,color: Color(0xff888888), size: 20),onTap: (){
              Navigator.of(context).pop({"cList":collectionList});
            },),
          ],),),
          Container( margin: const EdgeInsets.only(
              left: 15, right: 15, bottom: 5, top: 0),alignment: Alignment.topLeft,child: Text('Name',style: TextStyle(fontFamily: "Causten-Medium",fontSize: 14,color: Color(0xff5D5D5D)),),),
          Container(
            margin: const EdgeInsets.only(
                left: 15, right: 15, bottom: 5, top: 0),
            padding: const EdgeInsets.all(3.0),
            child: TextField(
              controller: mobileNumberCntrl,inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp("[a-z A-Z 0-9]")),
            ],maxLength: 50,
              keyboardType: TextInputType.text,style: TextStyle(fontFamily: "Causten-Medium",fontSize: 14),
              onChanged: (text) {
                if (text.isNotEmpty) {
                  isEnable = true;
                } else {
                  isEnable = false;
                }
                setState(() {});
              },

              decoration: InputDecoration( counterText: "",
                enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Color(0xffCED2D6), width: 0.7), // No border
                    borderRadius: BorderRadius.circular(30)
                ),focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Color(0xffCED2D6), width: 0.7), // No border
                  borderRadius: BorderRadius.circular(30)
              ),
                filled: true,
                fillColor: Colors.white,
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
                  createCollectionApi(mobileNumberCntrl.text.toString());
                }
              },
              child: Text(
                "Create collection",
                style: TextStyle(
                    color: isEnable?Colors.white:Color(0xffB0B0B0),
                    fontSize: 14,
                    fontFamily: "Causten-Medium"),
              ),
              style: ElevatedButton.styleFrom(
                  backgroundColor:
                  isEnable?Colors.black:Color(0xffECECEC),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30), // <-- Radius
                  )),
            ),
            width: double.infinity,
            margin: EdgeInsets.only(left: 15, right: 15, bottom: 10,top: 0),
          ),
        ],):Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              width: 30,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            SizedBox(height: 5),
            Container(child: ListView.builder(itemBuilder: (BuildContext context,int position){
              return Container(margin: EdgeInsets.only(left: 15,right: 15,top: 10,bottom: 10),child: Row(children: [
                SvgPicture.asset("assets/images/your_library.svg"),
                Expanded(child:  Container(child: Column(crossAxisAlignment: CrossAxisAlignment.start,children: [
                  Text(collectionList[position].collectionName!,style: TextStyle(fontFamily: "Causten-Medium",fontSize: 14,color: Color(0xff131314)),),
                  position==0?Container(child: Text(position==0?'Quick save':"",style: TextStyle(fontFamily: "Causten-Regular",fontSize: 14,color: Color(0xff5D5D5D))),margin: EdgeInsets.only(top: 5),):Container(),
                ],),margin: EdgeInsets.only(left:15),)),
                InkWell(child: Icon(PreferenceUtils.getString("collectionID", "")==collectionList[position].collectionId?Icons.bookmark:Icons.bookmark_border,color: PreferenceUtils.getString("collectionID", "")==collectionList[position].collectionId?Colors.black:Color(0xff888888)),onTap: (){
                 if(widget.isFav){
                   updateFavorite(widget.id, PreferenceUtils.getString("collectionID", ""),false);
                 }
                  PreferenceUtils.setString("collectionID", collectionList[position].collectionId!);
                  PreferenceUtils.setString("collectionName", collectionList[position].collectionName!);
                  collectionId=collectionList[position].collectionId!;
                  updateFavorite(widget.id, collectionId,true);
                  setState(() {

                  });
                },),
              ],),

              );
            },itemCount: collectionList.length,shrinkWrap: true,),height: collectionList.length>6?400:null,),

            Container(child: ListTile(
              leading: SvgPicture.asset("assets/images/new_add.svg"),
              title: Text('New collection',style: TextStyle(fontFamily: "Causten-Medium",fontSize: 16,color: Color(0xff131314))),
              onTap: () {
                isNewCollection=true;
                setState(() {

                });
              },
            ),margin: EdgeInsets.only(top: 8),),
            SizedBox(height: 5),
            Container(
              height: 45,
              child: ElevatedButton(
                onPressed: () async {
                  Navigator.of(context).pop({"cList":collectionList});
                },
                child: Text(
                  "Close",
                  style: TextStyle(
                      color: Colors.black,
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
              margin: EdgeInsets.only(left: 15, right: 15, bottom: 10,top: 10),
            ),
          ],
        ),
      ),
    );
  }
}