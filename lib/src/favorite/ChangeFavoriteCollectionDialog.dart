import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lottie/lottie.dart';
import 'package:quilt/src/PrefUtils.dart';
import 'package:quilt/src/api/Objects.dart';
import 'package:quilt/src/favorite/CollectionHelper.dart';

import '../api/ApiHelper.dart';
import '../api/NetworkApiService.dart';

class ChangeFavoriteCollectionDialog extends StatefulWidget {
  List<CollectionObject> collectionList = [];
  String collectionId = "";
  String contentId = "";

  ChangeFavoriteCollectionDialog(this.collectionList, this.collectionId, this.contentId);

  @override
  _ChangeFavoriteCollectionDialogState createState() => _ChangeFavoriteCollectionDialogState();
}

class _ChangeFavoriteCollectionDialogState extends State<ChangeFavoriteCollectionDialog> {
  // Add state variables here if needed
  bool isNewCollection = false;
  bool isEnable = false;
  ApiHelper apiHelper = ApiHelper();
  List<CollectionObject> collectionList = [];
  String collectionId = "";
  bool isApiCalling = false;
  TextEditingController mobileNumberCntrl = new TextEditingController();
  CollectionHelper collectionHelper = CollectionHelper();


  Future<void> updateFavorite(
      String id, String collectionId, bool isFav) async {
    ApiResponse? apiResponse =
    await apiHelper.updateFavorite(id, collectionId, isFav);
    LoginResponse loginResponse = LoginResponse.fromJson(apiResponse.data);
    if (loginResponse.status == 200) {
      collectionHelper.updateCollectionCountById(collectionId,true);
      Navigator.of(context).pop({"isUpdated": true, "cList": collectionList});
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.collectionList.isEmpty) {
      collectionHelper
          .getCollectionList()
          .then((value) => {collectionList = [], collectionList.addAll(value)});
    } else {
      collectionList = widget.collectionList;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16.0),
          topRight: Radius.circular(16.0),
        ),
      ),
      child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Stack(
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Container(
                    width: 30,
                    height: 5,
                    decoration: BoxDecoration(
                      color:Color(0xff3D3D3D),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  SizedBox(height: 5),
                  Container(
                    child: ListView.builder(
                      itemBuilder: (BuildContext context, int position) {
                        return Container(
                          margin: EdgeInsets.only(
                              left: 15, right: 15, top: 10, bottom: 10),
                          child: Row(
                            children: [
                              SvgPicture.asset(
                                  "assets/images/fav_your_library.svg"),
                              Expanded(
                                  child: Container(
                                    child: Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          collectionList[position]
                                              .collectionName!,
                                          style: TextStyle(
                                              fontFamily: "Causten-Medium",
                                              fontSize: 14,
                                              color: Colors.white),
                                        ),
                                        Container(
                                          child: Text(
                                              collectionList[position].collectionCount+ ' experience',
                                              style: TextStyle(
                                                  fontFamily:
                                                  "Causten-Regular",
                                                  fontSize: 14,
                                                  color: Color(
                                                      0xffB0B0B0))),
                                          margin:
                                          EdgeInsets.only(top: 2),
                                        ),
                                      ],
                                    ),
                                    margin: EdgeInsets.only(left: 15),
                                  )),
                              InkWell(
                                child:  SvgPicture.asset(
                                    widget.collectionId ==
                                        collectionList[position]
                                            .collectionId?"assets/images/fav_check.svg":"assets/images/fav_plus_circle.svg")/*Icon(
                                    widget.collectionId ==
                                        collectionList[position]
                                            .collectionId
                                        ? Icons.bookmark
                                        : Icons.bookmark_border,
                                    color:  widget.collectionId==
                                        collectionList[position]
                                            .collectionId
                                        ? Color(0xff40A1FB)
                                        : Color(0xff888888))*/,
                                onTap: () async {
                                  if(widget.collectionId!=collectionList[position].collectionId){
                                    isApiCalling = true;
                                    setState(() {});
                                    LoginResponse loginResponse;
                                    await apiHelper
                                        .updateFavorite(
                                        widget.contentId,
                                        widget.collectionId,
                                        false)
                                        .then((value) => {
                                      loginResponse =
                                          LoginResponse.fromJson(
                                              value.data),
                                      if (loginResponse.status ==
                                          200)
                                        {
                                          collectionHelper.updateCollectionCountById(widget.collectionId,false),
                                          collectionId =
                                          collectionList[
                                          position]
                                              .collectionId!,
                                          updateFavorite(
                                              widget.contentId,
                                              collectionId,
                                              true),
                                          setState(() {})
                                        }
                                      else
                                        {
                                          isApiCalling = false,
                                          setState(() {})
                                        }
                                    });
                                  }else{
                                    isApiCalling = true;
                                    setState(() {});
                                    LoginResponse loginResponse;
                                    await apiHelper
                                        .updateFavorite(
                                        widget.contentId,
                                        widget.collectionId,
                                        false)
                                        .then((value) => {
                                      loginResponse =
                                          LoginResponse.fromJson(
                                              value.data),
                                      if (loginResponse.status ==
                                          200)
                                        {
                                          collectionHelper.updateCollectionCountById( widget.collectionId,false),
                                        Navigator.of(context).pop({"isUpdated": true})
                                        }
                                      else
                                        {
                                          isApiCalling = false,
                                          setState(() {})
                                        }
                                    });
                                  }
                                },
                              ),
                            ],
                          ),
                        );
                      },
                      itemCount: collectionList.length,
                      shrinkWrap: true,
                    ),
                    height: collectionList.length > 6 ? 400 : null,
                  ),
                  SizedBox(height: 5),

                ],
              ),
              isApiCalling
                  ? Positioned(
                top: 0,
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 100,
                  width: 100,
                  child: Center(
                      child: Lottie.asset(
                          "assets/images/feed_preloader.json",
                          height: 100,
                          width: 100)),
                ),
              )
                  : Positioned(
                top: 0,
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(),
              )
            ],
          )),
    );
  }
}
