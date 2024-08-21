import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_parse_html/ui/home_page.dart';
import 'package:flutter_parse_html/ui/parse/htm_parse_page2.dart';
import 'package:flutter_parse_html/ui/parse/html_parse_page5.dart';
import 'package:flutter_parse_html/ui/xianfeng/xian_feng_2_page.dart';
import 'live/live_page.dart';
import 'package:flutter_parse_html/ui/porn/porn_page.dart';
import 'package:flutter_parse_html/ui/parse/htm_parse_page1.dart';
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
    {'text': '老司机3', 'icon': Icon(Icons.directions_bus)},
    // {'text': '下载', 'icon': Icon(Icons.file_download)},
  ];
  List<BottomNavigationBarItem> _bottomItems = [];
  int _currentIndex = 0;
  late PageController _controller;
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
          icon: value['icon'], label: '${value['text']}'));
    }
  }

  @override
  void dispose() {
    HomePage.inLsj = false;
    super.dispose();
    // _douYinPage.dispose();
  }
}
