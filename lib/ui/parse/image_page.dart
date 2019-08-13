

import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parse;
class ImagePage  extends StatefulWidget{

  List<String> imgs;
  bool addHeader = false;
  var parentContext;
  final Map arguments;
  ImagePage(this.arguments);



  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    imgs = arguments['list'];
    addHeader = arguments['addHeader'] == null?false:arguments['addHeader'];
    return BookState(imgs,parentContext);
  }
}

class BookState extends State<ImagePage>{

  String content = '';
  List<String> imgs;

  PageController _pageController;
  var parentContext;
  Map<String,String> header;

  BookState(this.imgs, this.parentContext);

  @override
  void initState() {
    super.initState();
    header = widget.addHeader? {
    'Accept-Language': 'zh-CN,zh;q=0.9,zh-TW;q=0.8',
    'Host': 'i.meizitu.net',
    'User-Agent':
    'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/63.0.3239.132 Safari/537.36',
    'Referer': 'http://www.mzitu.com/'
    }:{};
    _pageController = new PageController(viewportFraction: 0.8);
  }

  @override
  Widget build(BuildContext context) {
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
                httpHeaders:header,
                  placeholder: (context, url) => SpinKitChasingDots(color: Colors.blue,),
                  errorWidget: (context, url, error) => new Icon(Icons.error),
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