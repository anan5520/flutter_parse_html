import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_parse_html/download/download_page.dart';
import 'package:flutter_parse_html/resources/shared_preferences_keys.dart';
import 'package:flutter_parse_html/ui/douyin/dou_yin_page.dart';
import 'package:flutter_parse_html/ui/home_page.dart';
import 'package:flutter_parse_html/ui/parse/htm_parse_page2.dart';
import 'package:flutter_parse_html/ui/parse/html_parse_page5.dart';
import 'package:flutter_parse_html/ui/xianfeng/xian_feng_2_page.dart';
import 'package:flutter_parse_html/ui/yaSe/ya_se.dart';
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
import 'package:flutter_parse_html/ui/parse/htm_parse_page1.dart';
import 'package:flutter_parse_html/ui/xianfeng/xian_feng_page.dart';
//老司机页面
class HomeOtherPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return HomeOtherState();
  }
}

class HomeOtherState extends State<HomeOtherPage> {
  List _tabData = [
    {'text': '老司机', 'icon': Icon(Icons.directions_car)},
    {'text': '91porn', 'icon': Icon(Icons.music_video)},
    {'text': '视频', 'icon': Icon(Icons.music_video)},
    {'text': '直播', 'icon': Icon(Icons.live_tv)},
    {'text': '里番', 'icon': Icon(Icons.videocam)},
    {'text': '老司机3', 'icon': Icon(Icons.directions_bus)},
    // {'text': '下载', 'icon': Icon(Icons.file_download)},
  ];
  List<BottomNavigationBarItem> _bottomItems = [];
  int _currentIndex = 0;
  PageController _controller;
  @override
  void initState() {
    super.initState();
    _initTables();
    _controller = new PageController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        children: <Widget>[
          new HtmlParsePage5(),
          new PornHomePage(),
          new HtmlParsePage1(),
          new LivePage(),
          new XianFeng2Page(),
          new HtmlParsePage2(),
          // new DownloadPage(),
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
      if(index != 1){
        // _douYinPage.startOrStopPlay(false);
      }
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

  @override
  void dispose() {
    HomePage.inLsj = false;
    super.dispose();
    // _douYinPage.dispose();
  }
}
