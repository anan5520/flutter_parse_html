import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_parse_html/book/main/book_view.dart';
import 'package:flutter_parse_html/ui/parse/video_list11_page.dart';
import 'package:flutter_parse_html/ui/parse/video_list12_page.dart';
import 'package:flutter_parse_html/ui/parse/video_list13_page.dart';
import 'package:flutter_parse_html/ui/parse/video_list14_page.dart';
import 'package:flutter_parse_html/ui/parse/video_list15_page.dart';
import 'package:flutter_parse_html/ui/parse/video_list17_page.dart';
import 'package:flutter_parse_html/ui/parse/video_list3_page.dart';
import 'package:flutter_parse_html/util/native_utils.dart';

import 'abj_list_page.dart';
import 'gif_list_lsj_page.dart';

class HtmlParsePage5 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ParseHomePage();
  }
}

class ParseHomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return HomePage5State();
  }
}

class HomePage5State extends State<ParseHomePage>
    with SingleTickerProviderStateMixin {
  TabController _tabController;
  List<String> titles = ['视频1', '国产','视频2','番号','视频4','视频5','视频6','视频7','视频8'];

  @override
  void initState() {
    super.initState();
    _tabController = new TabController(length: titles.length, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("老司机"),
        actions: [
          TextButton(
              child: Text("帝都",style: TextStyle(color: Colors.white),),
              onPressed: () {
                Navigator.push(context,
                    new MaterialPageRoute(builder: (context) {
                      return AbjListPage();
                    }));
              }),
          TextButton(
              child: Text("图片gif",style: TextStyle(color: Colors.white),),
              onPressed: () {
                Navigator.push(context,
                    new MaterialPageRoute(builder: (context) {
                      return GifListLsjPage();
                    }));
              }),
          IconButton(
              icon: Icon(Icons.book),
              onPressed: () {
                Navigator.push(context,
                    new MaterialPageRoute(builder: (context) {
                      return BookView();
                    }));
              })
        ],
        bottom: TabBar(
          isScrollable: true,
          tabs: <Widget>[
            Tab(
              text: "${titles[0]}",
            ),
            Tab(
              text: "${titles[1]}",
            ),
            Tab(text: "${titles[2]}"),
            Tab(text: "${titles[3]}"),
            Tab(text: "${titles[4]}"),
            Tab(text: "${titles[5]}"),
            Tab(text: "${titles[6]}"),
            Tab(text: "${titles[7]}"),
            Tab(text: "${titles[8]}"),

          ],
          controller: _tabController,
        ),
      ),
      body: TabBarView(
        children: <Widget>[
          VideoList11Page(0),
          VideoList3Page(),
          VideoList15Page(),
          VideoList17Page(),
          VideoList11Page(1),
          VideoList11Page(2),
          VideoList11Page(3),
          VideoList11Page(4),
          VideoList13Page(),
          // HtmlParse2Page(HtmlParse2Type.video),
        ],
        controller: _tabController,
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}