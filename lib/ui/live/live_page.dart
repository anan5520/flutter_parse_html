import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_parse_html/model/live_bean.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter_parse_html/api/api_constant.dart';
import 'dart:convert';

import 'live_detail_page.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class LivePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return LiveState();
  }
}

class LiveState extends State<LivePage> with AutomaticKeepAliveClientMixin {
  List<Pingtai> _data = [];
  Dio _dio;
  RefreshController _refreshController;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _dio = new Dio();
    _dio.options.connectTimeout = 5000;
    _dio.options.receiveTimeout = 3000;
    _refreshController = new RefreshController(initialRefresh: true);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    // TODO: implement build
    return Scaffold(
        appBar: AppBar(
          title: Text('直播'),
        ),
        body: SmartRefresher(controller: _refreshController,
            enablePullDown: true,
            enablePullUp: false,
            onRefresh: () {
              _data.clear();
              getLiveData();
            },
            child: GridView.builder(
                itemCount: _data.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3, //每行个数
                    mainAxisSpacing: 10,
                    childAspectRatio: 0.6,
                    crossAxisSpacing: 10), //子组件宽高长度比例
                itemBuilder: getItem),
            )
    );
  }

  Widget getItem(BuildContext context, int index) {
    Pingtai item = _data[index];
    return GestureDetector(
      onTap: () {
        Navigator.push(context, new MaterialPageRoute(builder: (context) {
          return LiveDetailPage('http://api.hclyz.com:81/mf/${item.address}');
        }));
      },
      child: Column(
        children: <Widget>[
          Expanded(
              child: CachedNetworkImage(
                imageUrl: item.xinimg,
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

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  void getLiveData() async {
    Response response = await _dio.get(ApiConstant.liveUrl);
    String jsonStr = response.data;
    List<Pingtai> list = LiveBean
        .fromJson(json.decode(jsonStr))
        .pingtai;
    _data.addAll(list);
    setState(() {
      _refreshController.refreshCompleted();
    });
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
