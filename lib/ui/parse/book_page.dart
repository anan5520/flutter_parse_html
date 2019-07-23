

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parse;
import 'package:flutter_html_textview_render/html_text_view.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
class BookPage extends StatelessWidget{
  var url;
  final parentContext;


  BookPage(this.url, this.parentContext);


  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return MaterialApp(
      title: "页面解析",
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
      home: BookHomePage(url,parentContext),
    );
  }
}

class BookHomePage  extends StatefulWidget{

  var url;
  var parentContext;

  BookHomePage(this.url, this.parentContext);


  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return BookState(url,parentContext);
  }
}

class BookState extends State<BookHomePage>{

  String content = '';
  var url;
  var showLoading = true;
  var parentContext;

  BookState(this.url, this.parentContext);


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getData();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text('text'),
        leading: IconButton(icon: Icon(Icons.arrow_back), onPressed: (){
          Navigator.pop(parentContext);
        }),
      ),
      body: Center(
        child: Stack(children: <Widget>[new CustomScrollView(
          shrinkWrap: true,
          // 内容
          slivers: <Widget>[
            new SliverPadding(
              padding: const EdgeInsets.all(20.0),
              sliver: new SliverList(
                delegate: new SliverChildListDelegate(
                  <Widget>[
                    HtmlTextView(data: content),
                  ],
                ),
              ),
            ),
          ],
        ),
        showLoading?SpinKitWave(color: Colors.blue,):Center()],),
      ),
    );
  }


  void getData()async{
    var response = await http.get(url);
    Utf8Decoder utf8decoder = new Utf8Decoder();
    var body = utf8decoder.convert(response.bodyBytes);
    var document = parse.parse(body);
    content = document.getElementsByClassName("content").first.outerHtml;
    setState(() {
        showLoading = false;
    });
  }
}