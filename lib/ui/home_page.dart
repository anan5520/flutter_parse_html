import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_parse_html/resources/shared_preferences_keys.dart';
import 'package:flutter_parse_html/util/shared_preferences.dart';
import 'live/live_page.dart';
import 'movie/movie_page.dart';
import 'package:flutter_parse_html/ui/porn/porn_page.dart';
import 'girl/girl_page.dart';
import 'porn/porn_forum_page.dart';
import 'fanhao/fanhao_parse_page.dart';
import 'package:flutter_parse_html/net/net_util.dart';
import 'package:flutter_parse_html/api/api_constant.dart';
import 'package:flutter_parse_html/model/api_bean.dart';
import 'dart:io';
import 'dart:convert';
import 'package:flutter_parse_html/util/native_utils.dart';
import 'package:package_info/package_info.dart';
class HomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    initUrl();
    return HomeState();
  }

  void initUrl() async {
    SpUtil sp = await SpUtil.getInstance();
    String localStr = sp.getString(SharedPreferencesKeys.urls);
    UrlsBean localUrl;
    if (localStr != null && localStr.isNotEmpty) {
      localUrl = UrlsBean.fromJson(json.decode(localStr));
      updateUrl(localUrl);
    }
    String urlJson = await NetUtil.getHtmlData(ApiConstant.urlsUrl);
    UrlsBean urlsBean = UrlsBean.fromJson(json.decode(urlJson));
    if (localUrl == null || urlsBean.version > localUrl.version) {
      sp.putString(SharedPreferencesKeys.urls, json.encode(urlsBean));
      updateUrl(urlsBean);
      if (urlsBean.isUpSiSeUrl != null && urlsBean.isUpSiSeUrl) {
        sp.putString(SharedPreferencesKeys.htmlUrl1, '');
      }
    }
  }

  void updateUrl(UrlsBean urls) {
    ApiConstant.movieBaseUrl = urls.s4kMovie;
    ApiConstant.pornForumBaseUrl = urls.pornForum;
    ApiConstant.pornBaseUrl = urls.pornVideo;
    ApiConstant.siSeUrl = urls.lsjUrl;
    ApiConstant.liveUrl = urls.liveUrl;
    ApiConstant.searchUrl = urls.searchUrl;
    ApiConstant.fanHao1 = urls.fanHao1;
    ApiConstant.fanHao2 = urls.fanHao2;
    ApiConstant.fanHao3 = urls.fanHao3;
  }
}

class HomeState extends State<HomePage> {
  List _tabData = [
    {'text': '电影', 'icon': Icon(Icons.movie)},
    {'text': '电视剧', 'icon': Icon(Icons.live_tv)},
    {'text': '综艺', 'icon': Icon(Icons.play_circle_filled)},
    {'text': '动漫', 'icon': Icon(Icons.tv)},
  ];
  List<BottomNavigationBarItem> _bottomItems = [];
  int _currentIndex = 0;
  PageController _controller;

  @override
  void initState() {
    super.initState();
    _initTables();
    initNotice();
    if(Platform.isAndroid){
      initUpdate();
    }
    _controller = new PageController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        children: <Widget>[
          new MoviePage(MovieType.movie),
          new MoviePage(MovieType.tv),
          new MoviePage(MovieType.variety),
          new MoviePage(MovieType.comic),
        ],
        controller: _controller,
        onPageChanged: _onPageChanged,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: _bottomItems,
        onTap: _itemOnPress,
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        fixedColor: Colors.blue,
      ),
    );
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _itemOnPress(int index) {
    _controller.animateToPage(index,
        duration: new Duration(milliseconds: 500), curve: Curves.ease);
  }

  void _initTables() {
    for (var value in _tabData) {
      _bottomItems.add(BottomNavigationBarItem(
          icon: value['icon'], title: Text('${value['text']}')));
    }
  }

  void initNotice() async {
    String jsonStr = await NetUtil.getHtmlData(ApiConstant.noticeUrl);
    NoticeBean noticeBean = NoticeBean.fromJson(json.decode(jsonStr));
    if (noticeBean.isShow) {
      showDialog(
          context: context,
          barrierDismissible: noticeBean.canCancel,
          builder: (context) {
            return AlertDialog(
              title: Text(noticeBean.title),
              content: Text(noticeBean.content),
              contentPadding: EdgeInsets.all(10),
              actions: <Widget>[
                RaisedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text(
                    "确定",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            );
          });
    }
  }

  void initUpdate() async {
    String jsonStr = await NetUtil.getHtmlData(ApiConstant.updateUrl);
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    UpdateBean updateBean = UpdateBean.fromJson(json.decode(jsonStr));
    int version = int.parse(packageInfo.buildNumber);
    if (updateBean.version > version) {
      showDialog(
          context: context,
          barrierDismissible: updateBean.isForce,
          builder: (context) {
            return AlertDialog(
              title: Text('提示'),
              content: Text(updateBean.des),
              contentPadding: EdgeInsets.all(10),
              actions: <Widget>[
                RaisedButton(
                  onPressed: () {
                    NativeUtils.toBrowser(updateBean.url);
                  },
                  child: Text(
                    "确定",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            );
          });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
