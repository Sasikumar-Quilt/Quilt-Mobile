
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';

class Utility{
  static void showAlertDialog({
    required BuildContext context,
    required Widget body,
    List<Widget>? actions,
    Widget? title,
  }) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return AlertDialog(
          alignment: Alignment.center,
          insetPadding: const EdgeInsets.all(16.0),
          actionsPadding: const EdgeInsets.symmetric(
            vertical: 8.0,
            horizontal: 16.0,
          ),
          title: title,
          content: SingleChildScrollView(
            child: SizedBox(
              width: MediaQuery.of(context).size.width,
              child: body,
            ),
          ),
          actions: actions,
        );
      },
    );
  }
  static String getDate(String format) {
    DateTime today = DateTime.now();
    var outputFormat = DateFormat(format);
    return outputFormat.format(today);
  }
  static String formattedDate(String format,DateTime dateTime) {
    var outputFormat = DateFormat(format);
    return outputFormat.format(dateTime);
  }
  static String sFormattedDate(String format,String newFormat,String dateTime) {
    var outputFormat = DateFormat(format);
    var newFormatOutput = DateFormat(newFormat);
    var parseDate=outputFormat.parse(dateTime,true);
    var sOutPutFormat=newFormatOutput.format(parseDate.toLocal());
    return sOutPutFormat;
  }
  static DateTime utcFormatted(String format,String dateTime) {
    var outputFormat = DateFormat(format);
    var parseDate=outputFormat.parse(dateTime,true);
    return parseDate;
  }
  static String getDateWithFormatted(String dob, String format) {
    var outputFormat = DateFormat(format);
    var inputFormat = DateFormat("yyyy-MM-dd");
    return outputFormat.format(inputFormat.parse(dob));
  }
  static String getDateWithAdditional(String format,int subtract) {
    DateTime today = DateTime.now().subtract(Duration(days: subtract));
    var outputFormat = DateFormat(format);
    return outputFormat.format(today);
  }
  static void showSnackBar({
    required BuildContext context,
    required String message,
    Duration? duration,
  }) {
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(

        content: Text(message),
        backgroundColor: Colors.black,
        duration: duration ?? const Duration(seconds: 3),
      ),
    );
  }
  static void showToast(String message){
    Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_SHORT,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.white,
        textColor: Colors.black,
        fontSize: 16.0
    );
  }
  static void showTopSnackBar({
    required BuildContext context,
    required String message,
    Duration? duration,
  }) {
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.only(
            bottom: MediaQuery.of(context).size.height - 100,
            right: 20,
            left: 20),
        content: Text(message),
        backgroundColor: Colors.black,
        duration: duration ?? const Duration(seconds: 3),
      ),
    );
  }
  static bool isValidEmail(email){
    String pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regex = RegExp(pattern);
    return regex.hasMatch(email);
  }
  static bool isNameValid(String name) {
    // This pattern matches only letters and spaces.
    String pattern = r'^[a-zA-Z ]+$';
    RegExp regex = RegExp(pattern);
    return regex.hasMatch(name);
  }
  static bool isEmpty(text){
    return text==null||text==""||text==" ";
  }
}