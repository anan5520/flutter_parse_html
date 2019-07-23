import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_parse_html/model/live_bean.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter_parse_html/api/api_constant.dart';
import 'dart:convert';

import '../video_play.dart';
import 'live_detail.dart';
class LiveDetailPage extends StatefulWidget {
  String _url;


  LiveDetailPage(this._url);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return LiveState();
  }
}

class LiveState extends State<LiveDetailPage> {
  List<Zhubo> _data = [];
  Dio _dio;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _dio = new Dio();
    getLiveData();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(title: Text('直播详情'),),
      body: GridView.builder(
    itemCount: _data.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3, //每行个数
            mainAxisSpacing: 10,
            childAspectRatio: 0.6,
            crossAxisSpacing: 10), //子组件宽高长度比例
        itemBuilder: getItem),
    );
  }

  Widget getItem(BuildContext context, int index) {
    Zhubo item = _data[index];
    return GestureDetector(
      onTap: (){
        Navigator.push(context, MaterialPageRoute(builder: (context){
          return VideoPlayPage(item.address);
        }));
      },
      child: Column(
        children: <Widget>[
          Expanded(
              child: CachedNetworkImage(
                imageUrl: item.img,
                fit: BoxFit.cover,
              )),
          Padding(
            padding: EdgeInsets.only(top: 10),
            child: Text(item.title),
          )
        ],
      ),
    );
  }


  void getLiveData()async{
    Response response = await _dio.get(widget._url);
    String jsonStr = response.data;
    List<Zhubo> list = LiveDetail.fromJson(json.decode(jsonStr)).zhubo;
    _data.addAll(list);
    setState(() {

    });
  }
}
