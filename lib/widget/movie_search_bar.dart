import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_parse_html/api/api_constant.dart';
import 'package:flutter_parse_html/model/video_list_item.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_parse_html/ui/video_play.dart';
import 'package:flutter_parse_html/util/log_utils.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:dio/dio.dart';
import 'dart:convert' as convert;
import 'package:html/parser.dart' as parse;
import 'package:flutter_parse_html/util/escapeu_unescape.dart';

class SearchBar extends SearchDelegate<String> {
  // 点击清楚的方法
  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        // 点击把文本空的内容清空
        onPressed: () {
          query = "";
        },
      )
    ];
  }

  // 点击箭头返回
  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: AnimatedIcon(
        // 使用动画效果返回
        icon: AnimatedIcons.menu_arrow, progress: transitionAnimation,
      ),
      // 点击的时候关闭页面（上下文）
      onPressed: () {
        close(context, null);
      },
    );
  }

  // 点击搜索出现结果
  @override
  Widget buildResults(BuildContext context) {
    return SearchResultPage(query);
  }

  // 搜索下拉框提示的方法
  @override
  Widget buildSuggestions(BuildContext context) {
    return new Center();
  }
}

class SearchResultPage extends StatefulWidget {
  final String _query;

  SearchResultPage(this._query);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return SearchState(_query);
  }
}

class SearchState extends State<SearchResultPage> {
  final String _query;

  SearchState(this._query);

  List<VideoListItem> _data = new List();

  Dio _dio;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _dio = new Dio();
    getData(_query);
  }

  @override
  Widget build(BuildContext context) {
    Widget content;
    if (_data.length > 0) {
      content = ListView.builder(
        itemBuilder: getItem,
        itemCount: _data.length,
      );
    } else {
      content = SpinKitWave(
        color: Colors.blue,
        size: 50,
      );
    }

    return content;
  }

  Widget getItem(BuildContext context, int index) {
    VideoListItem videoListItem = _data[index];
    return new Padding(
      padding: EdgeInsets.all(10),
      child: GestureDetector(
        onTap: () {
          showLoading();
          getVideoUrl(videoListItem.targetUrl);
        },
        child: new Row(
          children: <Widget>[
            CachedNetworkImage(
              imageUrl: videoListItem.imageUrl,
              fit: BoxFit.cover,
              height: 80,
            ),
            new Padding(
              padding: EdgeInsets.only(left: 10),
              child: Text(videoListItem.title),
            )
          ],
        ),
      ),
    );
  }

  void getData(String query) async {
    var videoUrl = ApiConstant.movieSearchUrl;
    try {
      Map<String, String> param = {'submit': '', 'wd': query};
      var response = await _dio.post(videoUrl, queryParameters: param);
      if (response.statusCode == HttpStatus.ok) {
        var body = response.data;
        var document = parse.parse(body);
        var elements = document.getElementsByClassName("stui-vodlist__item");
        List<VideoListItem> list = [];
        for (var value in elements) {
          VideoListItem videoListItem = new VideoListItem();
          var imgElement = value
              .getElementsByClassName("stui-vodlist__thumb lazyload")
              .first;
          videoListItem.imageUrl =
          imgElement.attributes["data-original"]; //图片地址
          videoListItem.title = value
              .getElementsByClassName("stui-vodlist__title")
              .first
              .getElementsByTagName("a")
              .first
              .text; //标题
          videoListItem.targetUrl =
          '${ApiConstant.movieBaseUrl}${imgElement.attributes['href']
              .trim()}'; //跳转地址
          list.add(videoListItem);
        }
        LogUtils.d("http", "返回${list}");
        _data.addAll(list);
        setState(() {});
      }
    } catch (e) {
      print(e);
    }
  }

  void getVideoUrl(String url) async {
    var response = await _dio.get(url);
    String body = response.data;
    var document = parse.parse(body);
    var element = document
        .getElementsByClassName("btn btn-primary")
        .first;
    if (element != null) {
      String pageUrl = '${ApiConstant.movieBaseUrl}${element
          .attributes['href']}';
      var response = await _dio.get(pageUrl);
      String pageBody = response.data;
      var pageDocument = parse.parse(pageBody);
      String playData = pageDocument
          .getElementsByClassName('pl-l')
          .first
          .getElementsByTagName('script')
          .first
          .text;
      String data = playData.split('var player_data=')[1];
      LogUtils.d("json", "播放数据>>>${data}");
      var map = convert.json.decode(data);
      int encrypt = map['encrypt'];
      String playUrl = map['url'];
      if (playUrl.isNotEmpty) {
        if (encrypt == 1) {
          playUrl = EscapeUnescape.unescape(playUrl);
        } else {
          playUrl = EscapeUnescape.unescape(String.fromCharCodes(
              new Runes(convert.utf8.decode(convert.base64.decode(playUrl)))));
        }
        LogUtils.d("json", "播放地址>>>${playUrl}");
        Navigator.pop(context);
        Navigator.of(context)
            .push(new MaterialPageRoute(builder: (BuildContext context) {
          return VideoPlayPage(playUrl);
        }));
      }
    }
  }


  void showLoading() {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return SpinKitWave(
            color: Colors.blue,
          );
        });
  }

}
