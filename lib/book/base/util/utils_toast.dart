import 'package:flutter/material.dart';
import 'package:flutter_parse_html/book/constant/custom_color.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ToastUtils{

  static void showToast(String msg){
    Fluttertoast.showToast(
        msg: msg,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: CustomColor.blackA99,
        textColor: Colors.white,
        fontSize: 16.0
    );
  }

}