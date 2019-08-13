import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_parse_html/model/video_list_item.dart';
import 'package:flutter_parse_html/resources/shared_preferences_keys.dart';
import 'package:flutter_parse_html/ui/parse/webview_page.dart';
import 'package:flutter_parse_html/util/log_utils.dart';
import 'package:flutter_parse_html/util/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parse;
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_parse_html/ui/parse/book_page.dart';
import 'package:unicorndial/unicorndial.dart';
import 'package:flutter_parse_html/ui/video_play.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_parse_html/api/api_constant.dart';
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
  List<String> titles = ['图片', '小说', '视频','视频1'];

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
        title: Text("老司机"),
        bottom: TabBar(
          tabs: <Widget>[
            Tab(
              text: "${titles[0]}",
            ),
            Tab(
              text: "${titles[1]}",
            ),
            Tab(text: "${titles[2]}"),
            Tab(text: "${titles[3]}"),
          ],
          controller: _tabController,
        ),
      ),
      body: TabBarView(
        children: <Widget>[
          ParsePage(ParseType.image),
          ParsePage(ParseType.book),
          ParsePage(ParseType.video),
          VideoList1Page(),
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

class ParsePage extends StatefulWidget {
  final ParseType _type;

  ParsePage(this._type);

  @override
  State<StatefulWidget> createState() {
    return ParseState();
  }
}

class ParseState extends State<ParsePage> with AutomaticKeepAliveClientMixin {
  int _index = 1;
  RefreshController _refreshController;
  List<VideoListItem> _data = [];
  String baseUrl =
      'https://www.2019be.com'; //WWW.4455VW.COM WWW.2019TR.COM
  String parseUrl = '${ApiConstant.siSeUrl}/xiaoshuo/list-情感小说-';
  List<String> childBtnValues;
  List<UnicornButton> _childButtons;
  SpUtil sp;
  String _currentKey;

  @override
  void initState() {
    _refreshController = new RefreshController(initialRefresh: true);
    switch (widget._type) {
      case ParseType.image:
        childBtnValues = [
          '/tupian/list-卡通动漫',
          '/tupian/list-亚洲图片',
          '/tupian/list-欧美图片',
          '/tupian/list-偷拍自拍',
          '/tupian/list-乱伦熟女',
          '/tupian/list-精品套图',
          '/tupian/list-同性美图',
          '/tupian/list-美腿丝袜'
        ];
        break;
      case ParseType.book:
        childBtnValues = [
          '/xiaoshuo/list-情感小说',
          '/xiaoshuo/list-校园春色',
          '/xiaoshuo/list-武侠古典',
          '/xiaoshuo/list-家庭乱伦',
          '/xiaoshuo/list-另类小说',
          '/xiaoshuo/list-性爱技巧',
        ];
        break;
      case ParseType.video:
        childBtnValues = [
          '/shipin/list-亚洲电影',
          '/shipin/list-欧美电影',
          '/shipin/list-经典三级',
          '/shipin/list-偷拍自拍',
          '/shipin/list-动漫电影',
          '/shipin/list-乱伦电影',
          '/shipin/list-变态另类',
        ];
        break;
      default:
        childBtnValues = [];
        break;
    }
    initChildBtn();
    baseUrl = ApiConstant.siSeUrl;
    _currentKey = childBtnValues[0];
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
          _index = 1;
          initUrl();
        },
        onLoading: () {
          _index++;
          getData();
        },
        controller: _refreshController,
        child: getContentWidget(),
      ),
      floatingActionButton: UnicornDialer(
          backgroundColor: Color.fromRGBO(255, 255, 255, 0.6),
          parentButtonBackground: Colors.redAccent,
          orientation: UnicornOrientation.VERTICAL,
          parentButton: Icon(Icons.add),
          childButtons: _childButtons),
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
    parseUrl = '$baseUrl$_currentKey-';
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
    initUrl();
  }

  //从网络获取数据
  void getData() async {
    LogUtils.d('html', '加载url>>$parseUrl$_index.html');
    var response = await http.get('$parseUrl$_index.html');
    Utf8Decoder utf8decoder = new Utf8Decoder();
    var body = utf8decoder.convert(response.bodyBytes);
    var document = parse.parse(body);
    if (widget._type != ParseType.video) {
      var elements = document
          .getElementsByClassName('text-list-html')
          .first
          .getElementsByTagName('li');
      for (var value in elements) {
        var item = new VideoListItem();
        item.title = value.getElementsByTagName('a').first.attributes['title'];
        item.targetUrl =
            '$baseUrl${value.getElementsByTagName('a').first.attributes['href']}';
        _data.add(item);
      }
    } else {
      var elements = document
          .getElementsByClassName('text-list-html')
          .first
          .getElementsByTagName('li');
      for (var element in elements) {
        var imgElement = element.getElementsByTagName('img').first;
        VideoListItem item = new VideoListItem();
        item.imageUrl = imgElement.attributes['data-original'];
        String url = element.getElementsByTagName('a').first.attributes['href'];
        item.targetUrl = '$baseUrl$url';
        item.title =
            element.getElementsByTagName('a').first.attributes['title'];
        _data.add(item);
      }
    }

    setState(() {
      _refreshController.refreshCompleted();
      _refreshController.loadComplete();
    });
  }

  void initChildBtn() {
    _childButtons = List<UnicornButton>();
    _childButtons.add(UnicornButton(
        hasLabel: true,
        labelText: '更新地址',
        currentButton: FloatingActionButton(
          heroTag: '更新地址',
//            backgroundColor: Colors.redAccent,
          mini: true,
          child: Icon(Icons.update),
          onPressed: () {
            upDateUrl();
          },
        )));
    for (var value in childBtnValues) {
      _childButtons.add(UnicornButton(
          hasLabel: true,
          labelText: value,
          currentButton: FloatingActionButton(
            heroTag: value,
//            backgroundColor: Colors.redAccent,
            mini: true,
            child: Icon(Icons.directions_car),
            onPressed: () {
              _currentKey = value;
              initUrl();
            },
          )));
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
      case ParseType.image:
        getImg(item.targetUrl);
        break;
      case ParseType.book:
        Navigator.of(context)
            .push(new MaterialPageRoute(builder: (BuildContext context) {
          return BookPage(item.targetUrl, context);
        }));
        break;
      case ParseType.video:
        getVideo(item.targetUrl);
        break;
    }
  }

  void getImg(String targetUrl) async {
    showLoading();
    var response = await http.get(targetUrl);
    var document = parse.parse(response.body);
    var elments = document
        .getElementsByClassName("content")
        .first
        .getElementsByTagName("img");
    List<String> imgs = [];
    for (var value in elments) {
      imgs.add(value.attributes['data-original']);
    }
    Navigator.pop(context);
    Navigator.pushNamed(context, "/ImagePage", arguments: {"list": imgs});
  }

  void getVideo(String targetUrl) async {
    showLoading();
    var response = await http.get(targetUrl);
    Utf8Decoder utf8decoder = new Utf8Decoder();
    var body = utf8decoder.convert(response.bodyBytes);
    var document = parse.parse(body);
    var element =
        document.getElementsByClassName('btn btn-m btn-default').first;
    String url = element.attributes['href'];

    var response1 = await http.get('$baseUrl$url');
    var body1 = utf8decoder.convert(response1.bodyBytes);
    var document1 = parse.parse(body1);
    var elements = document1.getElementsByTagName('script');
    String playUrl = '';
    for (var value in elements) {
      if (value.text.contains('var video')) {
        String text = value.text;
        var urls = text.split("'");
        String url = '', host = '';
        for (var value1 in urls) {
          if (value1.contains('.m3u8')) {
            url = value1;
          } else if (value1.contains('https') && host.isEmpty) {
            host = value1;
          }
        }
        playUrl = '$host$url';
      }
    }
    LogUtils.d('', playUrl);
    Navigator.pop(context);
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return VideoPlayPage(playUrl);
    }));
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;

  getContentWidget() {
    if (widget._type != ParseType.video) {
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
              mainAxisSpacing: 10, crossAxisCount: 3),
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
                      fit: BoxFit.cover,
                    ),
                  ),
                  Text(_data[index].title,maxLines: 1,)
                ],
              ),
            );
          });
    }
  }
}

enum ParseType { image, book, video }
