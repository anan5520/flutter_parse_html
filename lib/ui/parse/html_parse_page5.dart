import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_parse_html/ui/parse/video_list10_page.dart';
import 'package:flutter_parse_html/ui/parse/video_list11_page.dart';
import 'package:flutter_parse_html/ui/parse/video_list18_page.dart';
import 'package:flutter_parse_html/ui/parse/video_list9_page.dart';
import 'package:flutter_parse_html/util/native_utils.dart';

import 'abj_list_page.dart';
import 'gif_list_lsj_page.dart';
import 'video_list8_page.dart';

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
  late TabController _tabController;
  List<String> titles = ['视频1','视频2','番号','视频4','视频5',];

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
        ],
        bottom: TabBar(
          unselectedLabelStyle:TextStyle(color: Colors.white),
          labelStyle: TextStyle(color: Colors.white),
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
            // Tab(text: "${titles[6]}"),
            // Tab(text: "${titles[7]}"),
            // Tab(text: "${titles[8]}"),

          ],
          controller: _tabController,
        ),
      ),
      body: TabBarView(
        children: <Widget>[
          VideoList18Page(),
          // VideoList3Page(),
          VideoList11Page(3),
          VideoList8Page(),
          VideoList11Page(1),
          VideoList9Page(),
          // VideoList11Page(4),
          // VideoList13Page(),
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