
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class LTheme{
  static var dartTheme = ThemeData(
    primarySwatch: Colors.blue,
    appBarTheme: AppBarTheme(
      color: Colors.blue, // 设置深色背景
      titleTextStyle: TextStyle(
        color: Colors.white, // 设置白色文字
      ),
      iconTheme: IconThemeData(color: Colors.white),
      toolbarTextStyle: TextStyle(
        color: Colors.white, // 设置白色文字
      ), systemOverlayStyle: SystemUiOverlayStyle.dark,
    ),
  );
}