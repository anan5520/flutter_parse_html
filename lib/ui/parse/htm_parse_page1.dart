import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_parse_html/book/main/book_view.dart';
import 'package:flutter_parse_html/model/button_bean.dart';
import 'package:flutter_parse_html/model/movie_bean.dart';
import 'package:flutter_parse_html/model/video_list_item.dart';
import 'package:flutter_parse_html/resources/shared_preferences_keys.dart';
import 'package:flutter_parse_html/ui/parse/abj_list_page.dart';
import 'package:flutter_parse_html/ui/parse/video_list10_page.dart';
import 'package:flutter_parse_html/ui/parse/video_list2_page.dart';
import 'package:flutter_parse_html/ui/parse/video_list3_page.dart';
import 'package:flutter_parse_html/ui/parse/video_list4_page.dart';
import 'package:flutter_parse_html/ui/parse/video_list5_page.dart';
import 'package:flutter_parse_html/ui/parse/video_list6_page.dart';
import 'package:flutter_parse_html/ui/parse/video_list7_page.dart';
import 'package:flutter_parse_html/ui/parse/video_list8_page.dart';
import 'package:flutter_parse_html/ui/parse/video_list9_page.dart';
import 'package:flutter_parse_html/ui/parse/webview_page.dart';
import 'package:flutter_parse_html/ui/pornhub/pornhub_util.dart';
import 'package:flutter_parse_html/util/common_util.dart';
import 'package:flutter_parse_html/util/log_utils.dart';
import 'package:flutter_parse_html/util/native_utils.dart';
import 'package:flutter_parse_html/util/shared_preferences.dart';
import 'package:flutter_parse_html/widget/dialog_page.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parse;
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_parse_html/ui/parse/book_page.dart';
import 'package:unicorndial/unicorndial.dart';
import 'package:flutter_parse_html/ui/video_play.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_parse_html/api/api_constant.dart';
import 'book_list_1_page.dart';
import 'video_list1_page.dart';

class HtmlParsePage1 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return ParseHomePage();
  }
}

class ParseHomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return HomePageState();
  }
}

class HomePageState extends State<ParseHomePage>
    with SingleTickerProviderStateMixin {
  TabController _tabController;
  List<String> titles = ['视频1','视频2', '国产', '视频4','番号', '视频5', '视频10', '视频7', '视频8'];

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
              child: Text("抖音",style: TextStyle(color: Colors.white),),
              onPressed: () {
                NativeUtils.goToDouYin("1");
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
          VideoList10Page(),
          VideoList2Page(),
          VideoList3Page(),
          VideoList4Page(),
          VideoList6Page(''),
          VideoList8Page(),
          VideoList7Page(),
          VideoList9Page(),
          VideoList1Page(),

          // HtmlParse2Page(HtmlParse2Type.video),
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

class HtmlParse2Page extends StatefulWidget {
  final HtmlParse2Type _type;

  HtmlParse2Page(this._type);

  @override
  State<StatefulWidget> createState() {
    return ParseState();
  }
}

class ParseState extends State<HtmlParse2Page> with AutomaticKeepAliveClientMixin {
  int _page = 1,buttonType = 0;
  RefreshController _refreshController;
  List<VideoListItem> _data = [];
  String baseUrl = 'https://www.2019be.com'; //WWW.4455VW.COM WWW.2019TR.COM
  String parseUrl = '${ApiConstant.parse5Url}/xiaoshuo/list-情感小说-';
  List<ButtonBean> childBtnValues;
  SpUtil sp;
  String _currentKey = "/arttypehtml/28/";
  int _typeIndex = 0;
  @override
  void initState() {
    _refreshController = new RefreshController(initialRefresh: true);
    switch (widget._type) {
      case HtmlParse2Type.image:
        _typeIndex = 2;
        _currentKey = "/arttypehtml/17/";
        break;
      case HtmlParse2Type.book:
        _typeIndex = 3;
        _currentKey = "/arttypehtml/27/";
        break;
      case HtmlParse2Type.video:
        _typeIndex = 0;
        _currentKey = "/vodtypehtml/82/";
        break;
      default:
        _typeIndex = 0;
        break;
    }
    // initChildBtn();
    baseUrl = ApiConstant.parse5Url;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      body: SmartRefresher(
        enablePullDown: true,
        enablePullUp: true,
        header: WaterDropMaterialHeader(),
        footer: ClassicFooter(),
        onRefresh: () {
          _page = buttonType == 1?_page:1;
          initUrl();
        },
        onLoading: () {
          _page++;
          getData();
        },
        controller: _refreshController,
        child: _getContentWidget(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (childBtnValues.length > 0) {
            //有选项再显示
            _showDialog();
          }
        },
        child: Icon(Icons.add),
      ),
    );
  }

  void initUrl() async {
    sp = await SpUtil.getInstance();
    String url = sp.getString(SharedPreferencesKeys.htmlUrl1);
    if (url != null) {
      if (url.endsWith('/')) {
        url = url.substring(0, url.length - 1);
      }
      baseUrl = url.isEmpty ? baseUrl : url;
    }
    LogUtils.d('html', 'baseUrl>>>$baseUrl');

    _data.clear();
    getData();
  }

  void upDateUrl() async {
    String url = await Navigator.push(context, MaterialPageRoute(builder: (_) {
      return WebViewPage(baseUrl);
    }));
    print('返回url>>>$url');
    if (url.isNotEmpty) {
      sp.putString(SharedPreferencesKeys.htmlUrl1, url);
    }
    _refreshController.requestRefresh();
  }

  //从网络获取数据
  void getData() async {
    parseUrl = '$baseUrl$_currentKey';
    LogUtils.d('html', '加载url>>$parseUrl$_page.html');
    var url = '${parseUrl}${_page == 1?"":'index_$_page.html'}';
    var body = await PornHubUtil.getHtmlFromHttpDeugger(url,isXvideos: true);
    var document = parse.parse(body);
    _refreshController.refreshCompleted();
    _refreshController.loadComplete();
    if(childBtnValues == null){
      var menu = document.getElementById("menu");
      var menuEles = menu.getElementsByTagName('ul');
      var liEles = menuEles[_typeIndex].getElementsByTagName("li");
      if(widget._type == HtmlParse2Type.video){
        liEles.addAll(menuEles[1].getElementsByTagName("li"));
      }
      childBtnValues = [];
      for (var value in liEles) {
        String href = value.getElementsByTagName('a').first.attributes['href'];
        if('/' != href){
          var btn = ButtonBean();
          btn.title = value.text;
          btn.value = href;
          childBtnValues.add(btn);
        }

      }
    }
    if (widget._type == HtmlParse2Type.book) {
      var elements = document
          .getElementsByClassName('newslist textlist')
          .first
          .getElementsByTagName('ul');
      for (var value in elements) {
        var item = new VideoListItem();
        item.title = value.getElementsByTagName('a').first.text;
        item.targetUrl =
            '$baseUrl${value.getElementsByTagName('a').first.attributes['href']}';
        _data.add(item);
      }
    } else {
      var elements = document
          .getElementsByClassName('vodlist dylist')
          .first
          .getElementsByTagName('div');
      for (var element in elements) {
        try {
          var imgElement = element.getElementsByClassName('vodpic lazyload').first;
          VideoListItem item = new VideoListItem();
          item.imageUrl = imgElement.attributes['data-original'].startsWith("http")?imgElement.attributes['data-original']
          :"https:${imgElement.attributes['data-original']}";
          String url = element.getElementsByTagName('a').first.attributes['href'];
          item.targetUrl = '$baseUrl${url}${widget._type == HtmlParse2Type.video?'index_1_1.html':''}'.replaceAll("vodhtml", 'vodplayhtml');
          item.title =
                      CommonUtil.replaceStr(element.getElementsByTagName('a').first.text);
          _data.add(item);
        } catch (e) {
          print(e);
        }
      }
    }

    setState(() {
      _refreshController.refreshCompleted();
      _refreshController.loadComplete();
    });
  }

  void _showDialog() async {
    ButtonBean buttonBean = await showDialog(
        context: context,
        builder: (context) {
          return new AlertDialog(
            content: GridViewDialog(childBtnValues),
          );
        });
    if (buttonBean != null) {
      if(buttonBean.type == 1){
        _page = buttonBean.page;
        buttonType = 1;
      }else{
        buttonType = 0;
        _currentKey = buttonBean.value;
      }
      _refreshController.requestRefresh();
    }
  }

  void showLoading() {
    showDialog(
        context: context,
        barrierDismissible: true,
        builder: (context) {
          return new SpinKitWave(
            color: Colors.blue,
          );
        });
  }

  void itemClick(VideoListItem item) {
    switch (widget._type) {
      case HtmlParse2Type.image:
        getImg(item.targetUrl);
        break;
      case HtmlParse2Type.book:
        Navigator.of(context)
            .push(new MaterialPageRoute(builder: (BuildContext context) {
          return BookHomePage(item.targetUrl, 4);
        }));
        break;
      case HtmlParse2Type.video:
        getVideo(item.targetUrl, item.title);
        break;
    }
  }

  void getImg(String targetUrl) async {
    showLoading();
    var response = await PornHubUtil.getHtmlFromHttpDeugger(targetUrl,isXvideos: true);
    var document = parse.parse(response);
    var elments = document
        .getElementsByClassName("nbodys")
        .first
        .getElementsByTagName("img");
    List<String> imgs = [];
    for (var value in elments) {
      imgs.add(value.attributes['src']);
    }
    Navigator.pop(context);
    Navigator.pushNamed(context, "/ShowStaggeredImagePage", arguments: {"list": imgs});
  }

  void getVideo(String targetUrl, String title) async {
    showLoading();
    var response = await PornHubUtil.getHtmlFromHttpDeugger(targetUrl,isXvideos: true);
    Navigator.pop(context);
    var document = parse.parse(response);
    var element =
        document.getElementsByTagName('source').first;
    String playUrl = element.attributes['src'];
    LogUtils.d('', playUrl);
    CommonUtil.toVideoPlay(playUrl, context, title: title);
  }

  @override
  bool get wantKeepAlive => true;

  //获取内容widget
  _getContentWidget() {
    if (widget._type == HtmlParse2Type.book) {
      return ListView.builder(
        itemBuilder: (context, index) {
          return new GestureDetector(
            onTap: () {
              itemClick(_data[index]);
            },
            child: new ListTile(title: Text('${_data[index].title}')),
          );
        },
        itemCount: _data.length,
      );
    } else {
      return GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              childAspectRatio: 0.6,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              crossAxisCount: 3),
          itemCount: _data.length,
          itemBuilder: (context, index) {
            return new GestureDetector(
              onTap: () {
                itemClick(_data[index]);
              },
              child: new Column(
                children: <Widget>[
                  Expanded(
                    child: CachedNetworkImage(
                      imageUrl: _data[index].imageUrl,
                      placeholder: (context, url) => new Icon(Icons.image),
                      errorWidget: (context, url, error) => new Icon(Icons.error),
                      fit: BoxFit.cover,
                    ),
                  ),
                  Text(
                    _data[index].title,
                    maxLines: 2,
                  )
                ],
              ),
            );
          });
    }
  }
}

enum HtmlParse2Type { image, book, video }
