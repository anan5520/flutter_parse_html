

import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parse;
import 'package:flutter_html_textview_render/html_text_view.dart';
class ImagePage  extends StatefulWidget{

  List<String> imgs;
  var parentContext;
  final Map arguments;
  ImagePage(this.arguments);



  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    imgs = arguments['list'];
    return BookState(imgs,parentContext);
  }
}

class BookState extends State<ImagePage>{

  String content = '';
  List<String> imgs;

  PageController _pageController;
  var parentContext;


  BookState(this.imgs, this.parentContext);

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _pageController = new PageController(viewportFraction: 0.8);
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(title: Text('图片'),
      leading: IconButton(icon: Icon(Icons.arrow_back), onPressed: (){
        Navigator.pop(context);
      }),),
      body: Center(
        child: PageView.builder(
          itemCount: imgs.length,
          scrollDirection: Axis.horizontal,
          controller: _pageController,
          itemBuilder: (context,index){
            return Padding(
              padding: EdgeInsets.only(left: 10,right: 10),
              child: CachedNetworkImage(
                  imageUrl: imgs[index]
              ),
            );
          },
        )
      ),
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _pageController.dispose();
  }

}