import 'package:quilt/src/api/ApiHelper.dart';
import 'package:quilt/src/api/NetworkApiService.dart';
import 'package:quilt/src/api/Objects.dart';

import '../PrefUtils.dart';
import '../Utility.dart';

class CollectionHelper{
  static final CollectionHelper _instance = CollectionHelper._internal();
  ApiHelper apiHelper=ApiHelper();
  List<CollectionObject> collectionList = [];
  factory CollectionHelper() {
    return _instance;
  }
  Future<void> init() async {
    getCollectionList();
  }

  Future< List<CollectionObject>> getCollectionList() async {
    print("collectionApiRequest");
    print(DateTime.timestamp());
    ApiResponse? apiResponse = await apiHelper.getCollections();
    CollectionList sCollectionList = CollectionList.fromJson(apiResponse.data);
    print("collectionListResponse");
    print(DateTime.timestamp());
    collectionList = [];
    if (sCollectionList.collectionList!.isNotEmpty) {
      collectionList.addAll(sCollectionList.collectionList!);
      print("collectionList");
      print(collectionList.length);
      if (Utility.isEmpty(PreferenceUtils.getString("collectionID", ""))) {
        PreferenceUtils.setString(
            "collectionID", collectionList[0].collectionId!);
        PreferenceUtils.setString(
            "collectionName", collectionList[0].collectionName!);
      } else {
        if (collectionList
            .where((element) =>
        element.collectionId ==
            PreferenceUtils.getString("collectionID", ""))
            .toList()
            .isEmpty) {
          PreferenceUtils.setString(
              "collectionID", collectionList[0].collectionId!);
          PreferenceUtils.setString(
              "collectionName", collectionList[0].collectionName!);
        }else{
          CollectionObject collectionObject= collectionList
              .where((element) =>
          element.collectionId ==
              PreferenceUtils.getString("collectionID", ""))
              .toList()[0];
          PreferenceUtils.setString(
              "collectionName", collectionObject.collectionName!);
        }
      }
      // setState(() {});
    } else {
      await createCollectionApi("Your Library");
    }
    return collectionList;
  }
  void resetCollectionCount(){
    for(int i=0;i<collectionList.length;i++){
      collectionList[i].collectionCount="0";
    }
  }
  void updateCollectionCount(List<FavoriteListObject>favLists){
    for(int i=0;i<favLists.length;i++){
      int index=collectionList.indexWhere((element) => element.collectionId==favLists[i].collectionId);
      if(favLists[i].contentList!=null){
        int count=favLists[i].contentList!.length;
        collectionList[index].collectionCount=count.toString();
      }
    }

  }
  void updateCollectionCountById(String collectionId,bool isAdd){
    int index=collectionList.indexWhere((element) => element.collectionId==collectionId);
    int count=int.parse(collectionList[index].collectionCount);
    if(isAdd){
      count=count+1;
    }else{
      count=count-1;
    }
    collectionList[index].collectionCount=count.toString();

  }
  Future<void> createCollectionApi(String collectionName) async {
    print("createCollectionApi");
    print(DateTime.timestamp());
    ApiResponse? apiResponse =
    await apiHelper.createCollection(collectionName, "");
    CreateCollectionObject collectionObject =
    CreateCollectionObject.fromJson(apiResponse.data);
    print("createCollectionApiResponse");
    print(DateTime.timestamp());
    if (collectionObject.collectionObject != null) {
      if (collectionList.isEmpty) {
        PreferenceUtils.setString(
            "collectionID", collectionObject.collectionObject!.collectionId!);
        PreferenceUtils.setString("collectionName",
            collectionObject.collectionObject!.collectionName!);
      } else {
        if (collectionList
            .where((element) =>
        element.collectionId ==
            PreferenceUtils.getString("collectionID", ""))
            .toList()
            .isEmpty) {
          PreferenceUtils.setString(
              "collectionID", collectionList[0].collectionId!);
          PreferenceUtils.setString(
              "collectionName", collectionList[0].collectionName!);
        }
      }
      collectionList.add(collectionObject.collectionObject!);
    }
  }
  Future<CreateCollectionObject> createNewCollection(String collectionName) async {
    ApiResponse? apiResponse = await apiHelper.createCollection(collectionName,"");
    CreateCollectionObject collectionObject=CreateCollectionObject.fromJson(apiResponse.data);
    return collectionObject;
  }
  Future<CreateCollectionObject> updateCollectionName(String collectionName,String collectionId) async {
    ApiResponse? apiResponse = await apiHelper.createCollection(collectionName,collectionId);
    CreateCollectionObject collectionObject=CreateCollectionObject.fromJson(apiResponse.data);
    return collectionObject;
  }
  Future<LoginResponse> deleteCollection(String collectionId) async {
    ApiResponse? apiResponse = await apiHelper.deleteCollection(collectionId);
    LoginResponse loginResponse=LoginResponse.fromJson(apiResponse.data);
    return loginResponse;
  }
  CollectionHelper._internal();

}