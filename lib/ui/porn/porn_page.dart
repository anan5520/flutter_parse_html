import 'package:flutter/widgets.dart';
import 'package:flutter_parse_html/model/porn_bean.dart';
import 'package:flutter_parse_html/ui/pornhub/porn_hub_page.dart';
import 'package:flutter_parse_html/ui/pornhub/pornhub_util.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_parse_html/net/net_util.dart';
import 'package:flutter_parse_html/api/api_constant.dart';
import 'package:flutter_parse_html/util/log_utils.dart';
import 'package:html/parser.dart' as parse;
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:flutter_parse_html/util/porn_helper.dart';
import 'package:flutter_parse_html/ui/video_play.dart';
import 'porn_video_detail.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'porn_forum_page.dart';

class PornHomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return PornHomePageState();
  }
}

class PornHomePageState extends State<PornHomePage>
    with SingleTickerProviderStateMixin {
  TabController _tabController;
  List<String> titles = ['最近加精','最热', '最新', '10分钟以上', '高清'];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _tabController = new TabController(length: titles.length, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("porn"),
        bottom: TabBar(
          isScrollable: true,
          tabs: <Widget>[
            Tab(
              text: "${titles[0]}",
            ),
            Tab(
              text: "${titles[1]}",
            ),
            Tab(
              text: "${titles[2]}",
            ),
            Tab(
              text: "${titles[3]}",
            ),
            Tab(
              text: "${titles[4]}",
            ),
          ],
          controller: _tabController,
        ),
      ),
      body: TabBarView(
        children: <Widget>[
          PornPage.type(2),
          PornPage.type(1),
          PornPage.type(0),
          PornPage.type(3),
          PornPage.type(4),
        ],
        controller: _tabController,
      ),
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }
}


class PornPage extends StatefulWidget {
  // v.php?category=hot&viewtype=basic

  int _type = 0;

  String _authorId;


  PornPage(this._type, this._authorId);
  PornPage.authorId(String _authorId):this(5,_authorId);
  PornPage.type(this._type);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return PornState();
  }
}

class PornState extends State<PornPage> with AutomaticKeepAliveClientMixin {
  List<PornItem> _data = [];
  int _page = 1;
  RefreshController _controller;

  @override
  void initState() {
    // TODO: implement initState
    _controller = new RefreshController(initialRefresh: true);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    var container = Container(
      color: Colors.white,
      child: SmartRefresher(
        header: WaterDropMaterialHeader(),
        footer: ClassicFooter(),
        enablePullDown: true,
        enablePullUp: true,
        controller: _controller,
        onRefresh: () {
          _page = 1;
          _data.clear();
          getData();
        },
        onLoading: () {
          _page++;
          getData();
        },
        child:
        ListView.builder(itemCount: _data.length, itemBuilder: getItem),
      ),
    );
    return widget._type == 5?Scaffold(
        appBar: AppBar(
          title: Text("用户的视频"),),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return PornForumPage();
          }));
        },
        child: Text('论坛',style: TextStyle(color: Colors.white),),
      ),
      body: container,
    ):Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return PornForumPage();
          }));
        },
        child: Text('论坛',style: TextStyle(color: Colors.white),),
      ),
      body: container,
    );
  }

  Widget getItem(BuildContext context, int index) {
    PornItem item = _data[index];
    return GestureDetector(
      onTap: () async {
        showLoading();
        VideoResult videoResult = await PornHelper.parseVideoPage(item);
        LogUtils.d('videoPage', videoResult.toString());
        Navigator.pop(context);
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return PornVideoDetailPage(videoResult);
        }));
      },
      child: Padding(
        padding: EdgeInsets.only(left: 10, right: 10, top: 5),
        child: Container(
          decoration: new BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(4),
            border: new Border.all(color: Color(0xFFEEEEEE), width: 0.5),
            // 边色与边宽度
// 生成俩层阴影，一层绿，一层黄， 阴影位置由offset决定,阴影模糊层度由blurRadius大小决定（大就更透明更扩散），阴影模糊大小由spreadRadius决定
            boxShadow: [
              BoxShadow(
                  color: Color(0xFFEEEEEE),
                  offset: Offset(5.0, 5.0),
                  blurRadius: 5.0,
                  spreadRadius: 2.0)
            ],
          ),
          child: Row(
            children: <Widget>[
              SizedBox(
                width: 160,
                height: 80,
                child: Padding(
                  padding: EdgeInsets.only(right: 10),
                  child: CachedNetworkImage(
                    placeholder: (context, url) => new Icon(Icons.image),
                    errorWidget: (context, url, error) => new Icon(Icons.image),
                    imageUrl: item.imgUrl,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Expanded(
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(bottom: 5),
                      child: Text(
                        '${item.title}(${item.duration})',
                        style: TextStyle(color: Colors.blueAccent),
                      ),
                    ),
                    Text(
                      item.info,
                      style: TextStyle(color: Colors.grey, fontSize: 11),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void getData() async {
    var key = '';
    switch(widget._type){
      case 1:
        key = 'hot';
        break;
      case 2:
        key = 'rf';
        break;
      case 3:
        key = 'long';
        break;
      case 4:
        key = 'hd';
        break;
    }
    Map<String, dynamic> param = widget._type != 5?{'category': key, 'page': '$_page'}:{'page': '$_page'};
    String data =
        await NetUtil.getHtmlData(widget._type == 5?ApiConstant.getAuthorVideosUrl(widget._authorId):
        ApiConstant.getPornVideoUrl(), paras: param,header: {"Cookie":ApiConstant.pornCookie},isWeb: true);
    _controller.loadComplete();
    _controller.refreshCompleted();
    LogUtils.d('porn', data);
    _data.addAll(parseByCategory(data));
    setState(() {

    });
  }

  List<PornItem> parseByCategory(String html) {
    List<PornItem> list = [];
    var document = parse.parse(html);
    var body = document.getElementById('wrapper');
    var items =
        body.getElementsByClassName('col-xs-12 col-sm-4 col-md-3 col-lg-3');
    for (var value in items) {
      String title = value.querySelectorAll('a').first.text.replaceAll(new RegExp('\t|\n| '), '');
      String imgUrl = value
          .querySelectorAll('a')
          .first
          .querySelectorAll('img')
          .first
          .attributes['src'];
      String contentUrl = value.querySelectorAll('a').first.attributes['href'];
      String viewKey = '';
      if(contentUrl.contains("&")){
        contentUrl = contentUrl.substring(0, contentUrl.indexOf('&'));
        viewKey = contentUrl.substring(contentUrl.indexOf('=') + 1);
      }else{
        viewKey = contentUrl.split("viewkey=")[1];
      }
      String allInfo = value.text;
      int index = allInfo.indexOf('时长');
      String duration = allInfo.substring(index + 3, index + 8);
      String info = '';
      if(allInfo.contains('添加时间')){
        info = allInfo.substring(allInfo.indexOf('添加时间'));
        info = info.replaceAll('\n', '');
        info = info.replaceAll('\s', '');
        info = info.replaceAll('\t', '');
        info = info.replaceAll(' ', '').trim();
      }
      PornItem pornItem = new PornItem(viewKey, title, imgUrl, duration, info);
      list.add(pornItem);
    }
    return list;
  }

  List<PornItem> parseHome(String html) {
    List<PornItem> list = [];
    var document = parse.parse(html);
    var body = document.getElementById('tab-featured');
    var items = body.querySelectorAll('p');
    for (var value in items) {
      String title = value.getElementsByClassName('title').first.text;
      String imgUrl = value.querySelectorAll('img').first.attributes['src'];
      String duration = value.getElementsByClassName('duration').first.text;
      String contentUrl = value.querySelectorAll('a').first.attributes['href'];
      String viewKey = contentUrl.substring(contentUrl.indexOf('=') + 1);
      String allInfo = value.text;
      String info = allInfo.substring(allInfo.indexOf('添加时间'));
      info = info.replaceAll('\n', '');
      info = info.replaceAll('\s', '');
      info = info.replaceAll('\t', '');
      info = info.replaceAll(' ', '').trim();
      PornItem pornItem = new PornItem(viewKey, title, imgUrl, duration, info);
      list.add(pornItem);
    }
    return list;
  }

  void showLoading() {
    showDialog(
        context: context,
        barrierDismissible: true,
        builder: (context) {
          return SpinKitWave(
            color: Colors.blue,
          );
        });
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
