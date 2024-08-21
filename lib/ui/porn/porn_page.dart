import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:flutter_parse_html/model/porn_bean.dart';
import 'package:flutter_parse_html/util/common_util.dart';
import 'package:flutter_parse_html/util/escapeu_unescape.dart';
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
    return PornHomePageState();
  }
}

class PornHomePageState extends State<PornHomePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<String> titles = ['最近加精', '最热', '最新', '10分钟以上', '高清'];

  @override
  void initState() {
    super.initState();
    _tabController = new TabController(length: titles.length, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("porn(国内播放慢可以挂vpn)"),
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

  late String _authorId;

  PornPage(this._type, this._authorId);

  PornPage.authorId(String _authorId) : this(5, _authorId);

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
  late RefreshController _controller;

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
        child: ListView.builder(itemCount: _data.length, itemBuilder: getItem),
      ),
    );
    return widget._type == 5
        ? Scaffold(
            appBar: AppBar(
              title: Text("用户的视频"),
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return PornForumPage();
                }));
              },
              child: Text(
                '论坛',
                style: TextStyle(color: Colors.white),
              ),
            ),
            body: container,
          )
        : Scaffold(

            floatingActionButton: FloatingActionButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return PornForumPage();
                }));
              },
              child: Text(
                '论坛',
                style: TextStyle(color: Colors.white),
              ),
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
                    imageUrl: item.imgUrl!,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Expanded(
                child: Column(
                  children: <Widget>[
                    item.title!.startsWith("http")
                        ? CachedNetworkImage(imageUrl: item.title!)
                        : Text(
                            '${item.title}',
                            style: TextStyle(color: Colors.blueAccent),
                          ),
                    Padding(
                      padding: EdgeInsets.only(bottom: 5),
                      child: Text(
                        '(${item.duration})',
                        style: TextStyle(color: Colors.blueAccent),
                      ),
                    ),
                    Text(
                      item.info!,
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
    switch (widget._type) {
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
    Map<String, dynamic> param = widget._type != 5
        ? {'category': key, 'page': '$_page'}
        : {'page': '$_page'};
    var url = widget._type == 5
        ? ApiConstant.getAuthorVideosUrl(widget._authorId)
        : ApiConstant.getPornVideoUrl();
    String data = await NetUtil.getHtmlData(
      url,paras: param);
    _controller.loadComplete();
    _controller.refreshCompleted();
    LogUtils.d('porn', data);
    _data.addAll(parseByCategory(data));
    setState(() {});
  }

  List<PornItem> parseByCategory(String html) {
    List<PornItem> list = [];
    var document = parse.parse(html);
    var body =
        document.getElementsByClassName('col-xs-12 col-sm-4 col-md-3 col-lg-3');
    if (body.length > 0) {
      var items = document
          .getElementsByClassName('col-xs-12 col-sm-4 col-md-3 col-lg-3');
      for (var value in items) {
        try {
          String title = '';
          var titleEle =
              value.getElementsByClassName('video-title title-truncate m-t-5');
          if (titleEle.length > 0) {
            var titleImg = titleEle.first.getElementsByTagName('img');
            if(titleImg.length > 0){
              title = titleEle.first
                  .getElementsByTagName('img')
                  .first
                  .attributes['src']!;
            }else{
              title = CommonUtil.replaceStr(titleEle.first.text);
            }

          } else {
            title = value
                .querySelectorAll('a')
                .first
                .text
                .replaceAll(new RegExp('\t|\n| '), '');
          }
          String imgUrl = value
              .querySelectorAll('a')
              .first
              .querySelectorAll('img')
              .first
              .attributes['src']!;
          String contentUrl =
              value.querySelectorAll('a').first.attributes['href']!;
          String viewKey = '';
          if (contentUrl.contains("?viewkey")) {
            contentUrl = contentUrl.substring(0, contentUrl.indexOf('&'));
            viewKey = contentUrl.substring(contentUrl.indexOf('=') + 1);
          } else {
            viewKey = contentUrl.split("viewkey=")[1];
          }
          String allInfo = value.text;
          String duration =
              '时长:${value.getElementsByClassName('duration').first.text}';
          String info = '';
          if (allInfo.contains('添加时间')) {
            info = allInfo.substring(allInfo.indexOf('添加时间'));
            info = info.replaceAll('\n', '');
            info = info.replaceAll('\s', '');
            info = info.replaceAll('\t', '');
            info = info.replaceAll(' ', '').trim();
          }
          PornItem pornItem =
              new PornItem(viewKey, title, imgUrl, duration, info);
          list.add(pornItem);
        } catch (e) {
          print(e);
        }
      }
    } else {
      var items = document.getElementsByTagName('script');
      var first = true;
      for (var i = 0; i < items.length; i++) {
        var value = items[i];
        if (value.outerHtml.contains('strencode')) {
          value.innerHtml = _getStrCode(value.outerHtml);
        }
      }
      document = parse.parse(
          document.outerHtml.replaceAll(RegExp(r'<script>|<\script>'), ''));
      var bodyHtml = document.outerHtml;
      var divs =
          document.getElementsByClassName('well well-sm videos-text-align');
      for (var i = 0; i < divs.length; i++) {
        var value = divs[i];
        String viewKey = '';
        String imgUrl = "";
        String contentUrl =
            value.getElementsByTagName('a')[i == 0 ? 0 : 1].attributes['href']!;
        if (contentUrl.contains("?viewkey")) {
          contentUrl = contentUrl.substring(0, contentUrl.indexOf('&'));
          viewKey = contentUrl.substring(contentUrl.indexOf('=') + 1);
        } else {
          viewKey = contentUrl.split("viewkey=")[1];
        }
        imgUrl = value.getElementsByTagName('img').first.attributes['src']!;
        String title = '';
        value.getElementsByTagName("span").forEach((element) {
          var childTitle = element.text;
          if (!childTitle.contains('添加时间:') &&
              !childTitle.contains('作者:') &&
              !childTitle.contains('查看:') &&
              !childTitle.contains('收藏:') &&
              !childTitle.contains('留言:') &&
              !childTitle.contains('积分:'))
            title = title + CommonUtil.replaceStr(childTitle);
        });
        var scripts = value.getElementsByTagName('script');

        scripts.forEach((script) {
          String scriptStr = _getStrCode(script.text);
          var scriptEle = parse.parse(scriptStr);
          if (scriptStr.contains("<a")) {
          } else if (scriptStr.contains("<img")) {
            imgUrl =
                scriptEle.getElementsByTagName('img').first.attributes['src']!;
          }
        });

        String allInfo = value.text;
        String duration =
            '时长:${value.getElementsByClassName('duration').first.text}';
        String info = '';
        if (allInfo.contains('添加时间')) {
          info = allInfo.substring(allInfo.indexOf('添加时间'));
          info = info.replaceAll('\n', '');
          info = info.replaceAll('\s', '');
          info = info.replaceAll('\t', '');
          info = info.replaceAll(' ', '').trim();
        }
        PornItem pornItem =
            new PornItem(viewKey, title, imgUrl, duration, info);
        list.add(pornItem);
      }
    }
    return list;
  }

  String _getStrCode(String html) {
    var reg;
    if (html.contains("strencode2")) {
      reg = RegExp(r'document.write\(strencode2\("|"\)\);');
    } else {
      reg = RegExp(r'document.write\(strencode\("|"\)\);');
    }
    var strings = html.split(reg);

    if (strings.length > 1) {
      String s = strings[1];
      if (html.contains("strencode2")) {
        s = EscapeUnescape.unescape(s);
      } else {
        var urlArray = s.split('","');
        s = urlArray[0];
        var s1 = urlArray[1];
        var s2 = urlArray[2];
        if (s2.substring(s2.length - 1) == "2") {
          var t = s;
          s = s1;
          s1 = t;
        }
        s = String.fromCharCodes(base64Decode(s));
        var len = s1.length;
        var code = "";
        for (var i = 0; i < s.length; i++) {
          var k = i % len;
          code += String.fromCharCode(s.codeUnitAt(i) ^ s1.codeUnitAt(k));
        }
        s = String.fromCharCodes(base64Decode(code));
      }

      return s;
    }
    return "";
  }

  List<PornItem> parseHome(String html) {
    List<PornItem> list = [];
    var document = parse.parse(html);
    var body = document.getElementById('tab-featured');
    var items = body!.querySelectorAll('p');
    for (var value in items) {
      String title = value.getElementsByClassName('title').first.text;
      String imgUrl = value.querySelectorAll('img').first.attributes['src']!;
      String duration = value.getElementsByClassName('duration').first.text;
      String contentUrl = value.querySelectorAll('a').first.attributes['href']!;
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
