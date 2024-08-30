import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:lottie/lottie.dart';
import 'package:quilt/src/Utility.dart';
import 'package:quilt/src/api/Objects.dart';
import 'package:shimmer/shimmer.dart';

import '../../main.dart';
import '../api/ApiHelper.dart';
import '../api/BaseApiService.dart';
import '../api/NetworkApiService.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:html/dom.dart' as dom;
class JournalListWidget extends StatefulWidget {
  ContentObj? contentObj;
  JournalListWidget({this.contentObj});
  @override
  JournalListWidgetState createState() => JournalListWidgetState();
}

class JournalListWidgetState extends State<JournalListWidget> {
  DateTime? selectedDate;
  DateTime? currentWeekStart;
  ApiHelper apiHelper = ApiHelper();
  List<JournalObject>journalList=[];
bool isLoaded=false;
  @override
  void initState() {
    super.initState();
    selectedDate = DateTime.now();
    currentWeekStart = _startOfWeek(selectedDate!);
    getJournalListApi();
  }
  DateTime _startOfWeek(DateTime date) {
    int daysFromMonday = (date.weekday - DateTime.monday) % 7;
    return date.subtract(Duration(days: daysFromMonday));
  }

  void _onDaySelected(DateTime date) {
    setState(() {
      isLoaded=false;
      journalList=[];
      selectedDate = date;
    });
    getJournalListApi();
  }

  void _goToPreviousWeek() {
    setState(() {
      currentWeekStart = currentWeekStart!.subtract(Duration(days: 7));
      isLoaded=false;
      journalList=[];
      selectedDate=currentWeekStart;
    });
    getJournalListApi();
  }

  void _goToNextWeek() {
    setState(() {
      currentWeekStart = currentWeekStart!.add(Duration(days: 7));
      isLoaded=false;
      journalList=[];
      selectedDate=currentWeekStart;
    });
    getJournalListApi();
  }
void getJournalListApi() async{
  DateTime dateTime=selectedDate!.toUtc();
  ApiResponse apiResponse= await apiHelper.getJournalList(dateTime.millisecondsSinceEpoch);
  isLoaded=true;
  if(apiResponse.status==Status.COMPLETED){
    JournalList sJournalList=JournalList.fromJson(apiResponse.data);
    if(sJournalList.journalList!=null&&sJournalList.journalList!.isNotEmpty){
      print(sJournalList.journalList!.length);
      journalList=[];
      journalList.addAll(sJournalList.journalList!);
      print("journalList");
      print(journalList.length);
      setState(() {
      });
    }else{
      journalList=[];
      setState(() {

      });
    }

  }
}
  /*String removeAllHtmlTags(String htmlText) {
    RegExp exp = RegExp(r"<[^>]*>", multiLine: true, caseSensitive: true);
    return htmlText.replaceAll(exp, '');
  }*/
  String removeAllHtmlTags(String htmlText) {
    // Parse the HTML string
    dom.Document document = html_parser.parse(htmlText);
    // Extract the text content
    String parsedString = document.body?.text ?? '';

    // Decode HTML entities
    String decodedString = HtmlUnescape().convert(parsedString);

    return decodedString;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,left: 5,right: 5),child: Column(
      children: [
        Container(
          child: SvgPicture.asset("assets/images/Indicator.svg"),
          alignment: Alignment.center,
          margin: EdgeInsets.only(top: 5, bottom: 5),
        ),
        Container(margin: EdgeInsets.only(top: 10,bottom: 10),child: Row(children: [
          Container(child: IconButton(icon: Icon(Icons.keyboard_arrow_left_rounded),onPressed: (){
            _goToPreviousWeek();
          },),),
          Expanded(child: Container(child: Text(
            Utility.formattedDate("MMM dd", currentWeekStart!.add(Duration(days: 0)))+"-"+ Utility.formattedDate("MMM dd", currentWeekStart!.add(Duration(days: 6))),textAlign: TextAlign.center,
            style: TextStyle(
                color: Colors.black,fontSize: 12,fontFamily: "Causten-Regular"
            ),
          ),)),
          Container(child: IconButton(icon: Icon(Icons.keyboard_arrow_right_rounded),onPressed: (){
            _goToNextWeek();

          },),),
        ],),),
        Container(
          height: 100,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(7, (index) {
              DateTime date = currentWeekStart!.add(Duration(days: index));
              bool isSelected = selectedDate!.day == date.day &&
                  selectedDate!.month == date.month &&
                  selectedDate!.year == date.year;
              return Column(children: [
                Container(child: Text(
                  ['M', 'T', 'W', 'T', 'F', 'S', 'S'][index],
                  style: TextStyle(
                      color: isSelected ? Colors.black : Color(0xffB7AFB5),fontSize: 15,fontFamily: "Causten-Regular"
                  ),
                ),margin: EdgeInsets.only(bottom: 5),),
                GestureDetector(
                  onTap: () => _onDaySelected(date),
                  child: Container(child: Container(
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.black : Color(0xffE6E4E6),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: EdgeInsets.only(top: 7,bottom: 7,left: 0,right: 0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          date.day.toString().length==1?"0"+date.day.toString():date.day.toString(),
                          style: TextStyle(
                              color: isSelected ? Colors.white : Color(0xffB7AFB5),fontSize: 15,fontFamily: "Causten-Regular"
                          ),
                        ),

                      ],
                    ),width: 40,
                  ),decoration: BoxDecoration(border: isSelected?Border.all(color:  Colors.black ):null,borderRadius: BorderRadius.circular(8)),padding: EdgeInsets.all(3),),
                )
              ],);
            }),
          ),
        ),
        Expanded(
          child: journalList.isNotEmpty?ListView.builder(itemBuilder: (BuildContext context,int index){
            return GestureDetector(child: Container(margin: EdgeInsets.only(left: 10,right: 10,bottom: 15),decoration: BoxDecoration(color: Color(0xffE6E4E6),borderRadius: BorderRadius.circular(10)),padding: EdgeInsets.only(left: 15,top: 15,bottom: 15,right: 15),child: Column(children: [
              Row(children: [
                Expanded(child: Container(child: Text(Utility.sFormattedDate("yyyy-MM-ddTHH:mm:ss.SSSZ","EEE dd MMM, yyyy",journalList[index].date!),style:  TextStyle(
                    color: Color(0xff877B83),
                    fontFamily: "Causten-Regular",
                    fontSize: 12)),)),
                Text(Utility.sFormattedDate("yyyy-MM-ddTHH:mm:ss.SSSZ","HH:mm",journalList[index].date!),style:  TextStyle(
                    color: Color(0xff877B83),
                    fontFamily: "Causten-Regular",
                    fontSize: 12))
              ],),
              Container(margin: EdgeInsets.only(top: 10),child: Row(children: [
                SvgPicture.asset("assets/images/feather.svg"),
                Expanded(child: Container(margin: EdgeInsets.only(left: 20,right: 20),child: Text(removeAllHtmlTags(journalList[index].response!),style:  TextStyle(
                    color: Colors.black,
                    fontFamily: "Causten-Medium",
                    fontSize: 16)),)),
                Icon(Icons.chevron_right,color:Color(0xff2E292C),)
              ],),)
            ],),),onTap: (){
              Navigator.pushNamed(
                  context,
                  HomeWidgetRoutes
                      .JournalEditorWidget,
                  arguments: {
                    "journalObj":journalList[index],"url":widget.contentObj
                  }).then((value) => getJournalListApi());
            },);
          },itemCount:journalList.length,):!isLoaded?Container(child: Lottie.asset("assets/images/pre_loader.json",width: double.infinity),width: double.infinity,alignment: Alignment.topCenter,):Container(alignment: Alignment.center,child: Column(crossAxisAlignment: CrossAxisAlignment.center,mainAxisSize: MainAxisSize.min,children: [
            SvgPicture.asset("assets/images/feather1.svg"),
            Container(child: Text("No journal entries for this day",style:  TextStyle(
                color: Colors.black,
                fontFamily: "Causten-SemiBold",
                fontSize: 20)),margin: EdgeInsets.only(top: 10),),
            Container(child: Text("Start journaling today to document your \nthoughts and experiences.",textAlign: TextAlign.center,style:  TextStyle(
                color: Color(0xff71656D),
                fontFamily: "Causten-Regular",
                fontSize: 14)),margin: EdgeInsets.only(top: 10),)
          ],),),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(child: ElevatedButton(
            onPressed: () {
Navigator.of(context).pop();
            },style: ElevatedButton.styleFrom(backgroundColor:Colors.black),
            child: Text('Done',style:  TextStyle(
                color: Colors.white,
                fontFamily: "Causten-Bold",
                fontWeight: FontWeight.bold,
                fontSize: 16),),
          ),margin: EdgeInsets.only(top: 0,bottom: 20),width: double.infinity,height: 50,),
        ),
      ],
    ),);
  }
}
class ShimmerList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: ListView.builder(
        itemCount: 5, // Adjust the count based on your needs
        itemBuilder: (context, index) {
          return ListTile(
            title: Container(
              height: 20,
              width: 200,
              color: Colors.white,
            ),
          );
        },
      ),
    );
  }
}
class HtmlUnescape {
  String convert(String text) {
    return text
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&apos;', "'");
  }
}