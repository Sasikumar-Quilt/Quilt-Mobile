import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lottie/lottie.dart';
import 'package:quilt/src/Utility.dart';
import 'package:quilt/src/base/BaseState.dart';
import 'package:quill_html_converter/quill_html_converter.dart';
import 'package:quilt/src/feedback/FeedbackWidget.dart';

import '../../main.dart';
import '../api/ApiHelper.dart';
import '../api/BaseApiService.dart';
import '../api/NetworkApiService.dart';
import '../api/Objects.dart';
import '../userBloc/UserBloc.dart';
import 'dart:math' as math;

class JournalEditorWidget extends BasePage {
  @override
  JournalEditorWidgetState createState() => JournalEditorWidgetState();
}

class JournalEditorWidgetState extends BasePageState<JournalEditorWidget> {

  ApiHelper apiHelper = ApiHelper();
  bool isArg = false;
  bool isEnable=false;
  ContentObj? contentObj;
  JournalObject? journalObj;
  final _controller = QuillController.basic();
FocusNode focusNode=new FocusNode();
bool isEdit=false;
  @override
  void initState() {
    super.initState();

  }

  getArgs() {
    if (!isArg) {
      isArg = true;
      final args = ModalRoute.of(context)?.settings.arguments as Map;
      contentObj = args["url"];
      if(args["journalObj"]!=null){
        journalObj = args["journalObj"];

        _controller.document = Document.fromHtml(journalObj!.response!);
        isEnable=true;
        isEdit=true;
        _controller.readOnly=true;
      }

      _controller.changes.listen((event) {
        String text=_controller.document.toPlainText();
        isEnable=false;
        print("object123");
        if(!Utility.isEmpty(text.trim())){
          isEnable=true;
        }
        setState(() {
        });
      });
    }
  }
  Future<void> addOrUpdateJournal() async {
    String date=DateTime.now().toUtc().millisecondsSinceEpoch.toString();
    String text=_controller.document.toDelta().toHtml();
   // ApiResponse? apiRespons;
    if(journalObj!=null){
    /*  DateTime dateTime=Utility.utcFormatted("yyyy-MM-ddTHH:mm:ss.SSSZ",journalObj!.date!);
      date=dateTime.millisecondsSinceEpoch.toString();*/
      apiHelper.updateJournal(journalObj!.id!,text);
    }else{
      apiHelper.addJournal(contentObj!.contentId!,text,date);
    }
    //if (apiRespons!.status == Status.COMPLETED) {
      //LoginResponse loginResponse = LoginResponse.fromJson(apiRespons.data);
      //if(loginResponse.status==200){
    Navigator.pushNamed(context, HomeWidgetRoutes.VideoCompletedWidget,arguments: {"object":contentObj,"fromJournal":1}) .then((value) => {replayVideo(value)});
        //showFeedbackDialog();
      //}
    }
  Future<void> deleteJournal() async {
    Navigator.of(context).pop();
    String text=_controller.document.toDelta().toHtml();
     ApiResponse? apiRespons;
    apiRespons=await apiHelper.deleteJournal(journalObj!.id!,text);
    Navigator.of(context).pop();
  }
  //}
  @override
  Widget build(BuildContext context) {
getArgs();
    return SafeArea(
        child: Scaffold(
      appBar: null,
      backgroundColor: Colors.white,
      body: Container(child: Column(
        children: [
          Container(padding: EdgeInsets.all(0),margin: EdgeInsets.only(top: 30, left: 10,right: 10),child: Row(children: [
            InkWell(child: SvgPicture.asset("assets/images/close_black.svg"),onTap: (){
              Navigator.of(context).pop();
            },),
            Expanded(child: Container(margin: EdgeInsets.only(left: 20),child: Text(journalObj!=null?Utility.sFormattedDate("yyyy-MM-ddTHH:mm:ss.SSSZ","EEE, dd MMM",journalObj!.date!):Utility.getDate("EEE, dd MMM"),textAlign: TextAlign.center,style: TextStyle(color: Color(0xff877B83),fontFamily: "Causten-Regular"),),alignment: Alignment.center,))

            ,isEdit?GestureDetector(onTapDown: (dertails){
              _showPopupMenu(context, dertails.globalPosition);
            },child: Container(padding: EdgeInsets.only(left: 15,right: 15,top: 10,bottom: 10),child: Text("More",style: TextStyle(color: Colors.black,fontSize: 12,fontFamily: "Causten-Bold"),),decoration: BoxDecoration(color: Color(0xffE6E4E6),borderRadius: BorderRadius.circular(20)),),):Container(child: GestureDetector(child: Container(alignment: Alignment.center,padding: EdgeInsets.only(left: 20,right: 20),
              /* onPressed: () {
               if(isEnable){
                 focusNode.unfocus();
                 addOrUpdateJournal();

               }
              },*/decoration: BoxDecoration(color: isEnable?Colors.black:Color(0xffECECEC),borderRadius: BorderRadius.circular(30)),
              child: Text('Save',textAlign: TextAlign.center,style:  TextStyle(
                  color: isEnable?Colors.white:Color(0xffB0B0B0),
                  fontFamily: "Causten-Bold",
                  fontWeight: FontWeight.bold,
                  fontSize: 12),),
            ),onTap: (){
               if(isEnable){
                 focusNode.unfocus();
                 addOrUpdateJournal();

               }
            },),margin: EdgeInsets.only(top: 0),height: 37,)
          ],),),
          Container(alignment: Alignment.topLeft,height: isEdit?journalObj!.question!.length>200?150:null:contentObj!.contentUrl!.length>200?150:null,child: SingleChildScrollView(child: Text(isEdit?journalObj!.question!:contentObj!.contentUrl!,textAlign: TextAlign.start,style: TextStyle(fontFamily: "Causten-Medium",fontSize: 18),),),margin: EdgeInsets.only(left: 15,right: 15,top: 20),),
          Expanded(
            child: QuillEditor.basic(focusNode: focusNode,
              configurations: QuillEditorConfigurations(
                controller: _controller,showCursor: !isEdit,autoFocus: true,
                padding: const EdgeInsets.all(16),placeholder: "Start writing...",
              ),
            ),
          ),

          !isEdit?QuillToolbar(
          configurations: const QuillToolbarConfigurations(),
        child: Container(child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Wrap(
            children: [
              /* IconButton(
                onPressed: () => context
                    .read<SettingsCubit>()
                    .updateSettings(
                    state.copyWith(useCustomQuillToolbar: false)),
                icon: const Icon(
                  Icons.width_normal,
                ),
              ),*/

              QuillToolbarToggleStyleButton(
                options: const QuillToolbarToggleStyleButtonOptions(),
                controller: _controller,
                attribute: Attribute.bold,
              ),
              QuillToolbarToggleStyleButton(
                options: const QuillToolbarToggleStyleButtonOptions(),
                controller: _controller,
                attribute: Attribute.italic,
              ),
              QuillToolbarToggleStyleButton(
                controller: _controller,
                attribute: Attribute.underline,
              ),
              /*QuillToolbarClearFormatButton(
                controller: _controller,
              ),*/
              /*  QuillToolbarImageButton(
                controller: _controller,
              ),
              QuillToolbarCameraButton(
                controller: _controller,
              ),
              QuillToolbarVideoButton(
                controller: _controller,
              ),*/
              QuillToolbarColorButton(
                controller: _controller,
                isBackground: false,
              ),

              QuillToolbarLinkStyleButton(controller: _controller),
              QuillToolbarSelectHeaderStyleDropdownButton(
                controller: _controller,options: QuillToolbarSelectHeaderStyleDropdownButtonOptions(afterButtonPressed:(){
                  print("object");
                  focusNode.unfocus();
              }),
              ),
              QuillToolbarColorButton(
                controller: _controller,
                isBackground: true,
              ),

              QuillToolbarToggleCheckListButton(
                controller: _controller,
              ),
              QuillToolbarToggleStyleButton(
                controller: _controller,
                attribute: Attribute.ol,
              ),
              QuillToolbarToggleStyleButton(
                controller: _controller,
                attribute: Attribute.ul,
              ),
              QuillToolbarToggleStyleButton(
                controller: _controller,
                attribute: Attribute.inlineCode,
              ),
              QuillToolbarToggleStyleButton(
                controller: _controller,
                attribute: Attribute.blockQuote,
              ),
              QuillToolbarIndentButton(
                controller: _controller,
                isIncrease: true,
              ),
              QuillToolbarIndentButton(
                controller: _controller,
                isIncrease: false,
              ),

              QuillToolbarHistoryButton(
                isUndo: true,
                controller: _controller,
              ),
              QuillToolbarHistoryButton(
                isUndo: false,
                controller: _controller,
              ),
            ],
          ),
        ),color: Color(0xffF8F7F8),),
      ):Container(),


        ],
      ),),
    ));
  }
  void showDeleteDialog(){
    showDialog(
      context: context,barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (builder,setState){
          return Dialog(child: Container(child: Column(mainAxisSize: MainAxisSize.min,children: [
            Container(child: SvgPicture.asset("assets/images/delete.svg",height: 40,width: 40,),margin: EdgeInsets.only(top: 20),),
            Container(child: Text("Delete journal entry?",style: TextStyle(color: Colors.black,fontSize: 20,fontFamily: "Causten-SemiBold"),),margin: EdgeInsets.only(top: 10),)
            ,Container(child: Text("This action cannot be undone.",style: TextStyle(color:Color(0xff71656D),fontSize: 14,fontFamily: "Causten-SemiBold"),),margin: EdgeInsets.only(top: 10),)
           , GestureDetector(onTapDown: (dertails){

              deleteJournal();
            },child: Container(width: double.infinity,margin: EdgeInsets.only(left: 10,right:10,top: 20,bottom: 10),padding: EdgeInsets.only(left: 15,right: 15,top: 15,bottom: 15),child: Text("Delete",style: TextStyle(color: Colors.white,fontSize: 16,fontFamily: "Causten-Bold"),textAlign: TextAlign.center,),decoration: BoxDecoration(color: Color(0xffC84040),borderRadius: BorderRadius.circular(30)),),)
           , GestureDetector(onTapDown: (dertails){
             Navigator.of(context).pop();
            },child: Container(width: double.infinity,margin: EdgeInsets.only(left: 10,right:10,top: 0,bottom: 20),padding: EdgeInsets.only(left: 15,right: 15,top: 15,bottom: 15),child: Text("Cancel",style: TextStyle(color: Colors.black,fontSize: 16,fontFamily: "Causten-Bold"),textAlign: TextAlign.center),decoration: BoxDecoration(color: Color(0xffE6E4E6),borderRadius: BorderRadius.circular(30)),),)
          ],),),);
        }); // Custom dialog widget
      },
    );
  }
  void _showPopupMenu(BuildContext context, Offset offset) async {
    await showMenu(
      context: context,shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(15.0))
    ),constraints: BoxConstraints(
      minWidth: 170,
      maxWidth: MediaQuery.of(context).size.width,
    ),color: Colors.white,
      position: RelativeRect.fromLTRB(offset.dx, offset.dy, offset.dx, offset.dy),
      items: [

        PopupMenuItem<String>(
          value: 'Edit',
          child:Container(child: Row(children: [
            Expanded(child: Text("Edit",style: TextStyle(color: Colors.black,fontSize: 16,fontFamily: "Causten-Medium"),))
           ,SvgPicture.asset("assets/images/edit.svg")
          ],),) ,onTap: (){
            isEdit=false;
            _controller.readOnly=false;
            setState(() {

            });
        },
        ),
        PopupMenuItem<String>(
          value: 'Edit',onTap: (){
            showDeleteDialog();
        },
          child:Container(child: Row(children: [
            Expanded(child: Text("Delete",style: TextStyle(color: Color(0xffC84040),fontSize: 16,fontFamily: "Causten-Medium"),))
            ,SvgPicture.asset("assets/images/delete.svg")
          ],),) ,
        ),
      ],
      elevation: 8.0,
    );
  }
  replayVideo(value) {
    if(value!=null&&value["isReplay"]){
       Navigator.of(context).pop();
    }else{
      Navigator.of(context).pop({"isReplay":true});
    }
  }

  checkFeedback(value) {
    print(value["isFeedback"]);
    print("checkFeedback");
    if(value!=null&&value["isFeedback"]==true){
      Navigator.of(context).pop();
    }
  }
}
