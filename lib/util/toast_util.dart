import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ToastUtils {

  static void showToast(String msg,
      {Toast toast = Toast.LENGTH_LONG,
      ToastGravity gravity = ToastGravity.TOP,
      Color backgroundColor = const Color(0xFF445973),
      Color textColor = Colors.white,
      double fontSize = 16}) {
    if(msg.isEmpty){
      return;
    }
    Fluttertoast.showToast(
        msg: msg,
        toastLength: toast,
        gravity: gravity,
        backgroundColor: backgroundColor,
        textColor: textColor,
        fontSize: fontSize);
  }

  static void showLongToast(String msg,
      {Toast toast = Toast.LENGTH_LONG,
        ToastGravity gravity = ToastGravity.TOP,
        Color backgroundColor = const Color(0xFF445973),
        Color textColor = Colors.white,
        double fontSize = 16}) {
    if(msg.isEmpty){
      return;
    }
    Fluttertoast.showToast(
        msg: msg,
        toastLength: toast,
        gravity: gravity,
        backgroundColor: backgroundColor,
        textColor: textColor,
        fontSize: fontSize);
  }

  static void showErrorToast(String? msg,
      {Toast toast = Toast.LENGTH_LONG,
      ToastGravity gravity = ToastGravity.TOP,
      Color backgroundColor = const Color(0xFFEF6549),
      Color textColor = Colors.white,
      double fontSize = 16}) {

    if(msg?.isEmpty ?? true){
      return;
    }

    Fluttertoast.showToast(
        msg: msg!,
        toastLength: toast,
        gravity: gravity,
        backgroundColor: backgroundColor,
        textColor: textColor,
        fontSize: fontSize);
  }
}
