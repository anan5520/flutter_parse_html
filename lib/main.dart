
import 'package:flutter_parse_html/ui/home_page.dart';
import 'package:flutter_parse_html/ui/parse/image_page.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_parse_html/ui/movie/movie_page.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      onGenerateRoute: (setting){
        if(setting.name == '/ImagePage'){
          return MaterialPageRoute(builder: (context) => ImagePage(setting.arguments));
        }
      },
      home: HomePage(),
    );
  }
}

class MySecondPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _MySecondPageState();
}

class _MySecondPageState extends State<MySecondPage> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return null;
  }
}

