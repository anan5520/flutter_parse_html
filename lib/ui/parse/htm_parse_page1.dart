

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_parse_html/model/video_list_item.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parse;
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import 'package:flutter_parse_html/ui/parse/book_page.dart';


class HtmlParsePage1 extends StatelessWidget{

  
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return ParseHomePage();
  }
}

class ParseHomePage extends StatefulWidget{

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return HomePageState();
  }
}

class HomePageState extends State<ParseHomePage> with SingleTickerProviderStateMixin{

  static final String baseUrl = 'https://www.2019xi.com';
  final String bookUrl = '$baseUrl/xiaoshuo/list-情感小说-';
  final String imgUrl = '$baseUrl/tupian/list-偷拍自拍-';

  TabController _tabController;
  RefreshController _refreshController;

  List<VideoListItem> imgList = [];
  List<VideoListItem> bookList = [];
  List<String> titles = ['图片','小说'];
  var _showDialog = true;
  Future _future;

  var bookIndex = 1;
  var imgIndex = 1;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _tabController = new TabController(length: titles.length, vsync: this);
    _refreshController = new RefreshController();
    getData(bookUrl,bookIndex,bookList);
    getData(imgUrl,imgIndex,imgList);
  }


  @override
  Widget build(BuildContext context) {
//    if(_showDialog){
//      showLoading(context);
//    }
    return Scaffold(
      appBar: AppBar(title: Text("老司机"),
      bottom: TabBar(tabs: <Widget>[
        Tab(text: "${titles[0]}",),
        Tab(text: "${titles[1]}")
      ],
      controller: _tabController
        ,),),
      body: TabBarView(children:<Widget>[
        Stack(
          children:<Widget>[SmartRefresher(
            enablePullDown: true,
            enablePullUp: true,
            header: WaterDropMaterialHeader(),
            footer: ClassicFooter(),
            onRefresh: (){
              _showDialog = true;
              imgIndex = 1;
              getData(imgUrl,imgIndex,imgList);
            },
            onLoading: (){
              _showDialog = false;
              getData(imgUrl,++imgIndex,imgList);
            },
            controller: _refreshController,
            child:  ListView.builder(itemBuilder: (context,index){
              return new GestureDetector(onTap: (){
                getImg(imgList[index].targetUrl);
              },
              child: new ListTile(
                  title: Text('${imgList[index].title}')),
              );
              },
              itemCount: imgList.length,
            ),)
          ]
          ,),
        Center(
            child: SmartRefresher(controller: _refreshController,
            enablePullDown: true,
            enablePullUp: true,
            onRefresh: (){
              _showDialog = true;
              bookIndex = 1;
              bookList.clear();
              getData(bookUrl,bookIndex,bookList);
            },
              onLoading: (){
                _showDialog = false;
                getData(bookUrl,++bookIndex,bookList);
              },
            child: ListView.builder(itemBuilder: (context,index){
              return new GestureDetector(
                onTap: (){
                  Navigator.of(context).push(new MaterialPageRoute(
                      builder: (BuildContext context){return BookPage(bookList[index].targetUrl,context);}));
                },
                child: new ListTile(title: Text('${bookList[index].title}')),
              );
            }, itemCount: bookList.length,),)
        )
      ]
      ,controller: _tabController,),
    );
  }

  void getData(String url,int index,List<VideoListItem> list) async{
    var response = await http.get('${url}${index}.html');
    Utf8Decoder utf8decoder = new Utf8Decoder();
    var body = utf8decoder.convert(response.bodyBytes);
    var document = parse.parse(body);
    var elements = document.getElementsByClassName('text-list-html').first.getElementsByTagName('li');
    for (var value in elements) {
      var item = new VideoListItem();
      item.title = value.getElementsByTagName('a').first.attributes['title'];
      item.targetUrl = '${baseUrl}${value.getElementsByTagName('a').first.attributes['href']}';
      list.add(item);
    }
    setState(() {
      _showDialog = false;
      _refreshController.refreshCompleted();
      _refreshController.loadComplete();
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _refreshController.dispose();
  }
  
  void showLoading(){
    showDialog(context: context,barrierDismissible: true,builder: (context){
      return new SpinKitWave(color: Colors.blue,);
    });
  }

  void getImg(String targetUrl) async {
    showLoading();
    var response = await http.get(targetUrl);
    var document = parse.parse(response.body);
    var elments = document.getElementsByClassName("content").first.getElementsByTagName("img");
    List<String> imgs = [];
    for (var value in elments) {
      imgs.add(value.attributes['data-original']);

    }
    Navigator.pop(context);
    Navigator.pushNamed(context,"/ImagePage",arguments: {"list":imgs});
    }
  }









