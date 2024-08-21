import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_parse_html/model/button_bean.dart';
import 'package:flutter_parse_html/model/movie_bean.dart';
import 'package:flutter_parse_html/model/video_list_item.dart';
import 'package:flutter_parse_html/net/net_util.dart';
import 'package:flutter_parse_html/util/common_util.dart';
import 'package:flutter_parse_html/util/escapeu_unescape.dart';
import 'package:flutter_parse_html/util/log_utils.dart';
import 'package:flutter_parse_html/widget/dialog_page.dart';
import 'package:html/dom.dart' as dom;
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parse;
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_parse_html/ui/parse/book_page.dart';
import 'package:flutter_parse_html/ui/video_play.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_parse_html/api/api_constant.dart';

class HtmlParsePage4 extends StatelessWidget {
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
  late TabController _tabController;

  List<String> titles = ['图片', '小说', '视频','图片1', '小说1', '视频1'];

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
            Tab(
              text: "${titles[3]}",
            ),
            Tab(
              text: "${titles[4]}",
            ),
            Tab(text: "${titles[5]}"),
          ],
          controller: _tabController,
        ),
      ),
      body: TabBarView(
        children: <Widget>[
          ParsePage(ParseType.image, Parse2BaseType.type1),
          ParsePage(ParseType.book, Parse2BaseType.type1),
          ParsePage(ParseType.video, Parse2BaseType.type1),
          ParsePage(ParseType.image, Parse2BaseType.type2),
          ParsePage(ParseType.book, Parse2BaseType.type2),
          ParsePage(ParseType.video, Parse2BaseType.type2),
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
  final Parse2BaseType _parse2baseType;

  ParsePage(this._type, this._parse2baseType);

  @override
  State<StatefulWidget> createState() {
    return ParseState();
  }
}

class ParseState extends State<ParsePage> with AutomaticKeepAliveClientMixin {
  int _page = 1,buttonType = 0;
  late RefreshController _refreshController;
  List<VideoListItem> _data = [];
  String baseUrl = 'https://www.2019be.com'; //WWW.4455VW.COM WWW.2019TR.COM
  String parseUrl = '${ApiConstant.siSeUrl}/xiaoshuo/list-情感小说-';
  List<ButtonBean> childBtnValues = [];
  late String _currentKey;

  @override
  void initState() {
    _refreshController = new RefreshController(initialRefresh: true);
    initUrl();
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
          LogUtils.d('html', 'baseUrl>>>$baseUrl');
          _data.clear();
          getData();
        },
        onLoading: () {
          _page++;
          getData();
        },
        controller: _refreshController,
        child: getContentWidget(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (childBtnValues.length > 0) {
            //有选项再显示
            _showDialog();
//        NativeUtils.toXfPlay('xfplay://dna=DwjbAwfdmwLWDZiWAZfdBdiZAZx2m0m4AGeXmeDXEdjbAZmYAZxZmt|dx=450062105|mz=JUY-794_CH_SD_onekeybatch.mp4|zx=nhE0pdOVl3P5AY5xqzD5Ac5wo206BGa4mc94MzXPozS|zx=nhE0pdOVl3Ewpc5xqzD4AF5wo206BGa4mc94MzXPozS');
          }
        },
        child: Icon(Icons.add),
      ),
    );
  }

  void initUrl() async {
    baseUrl = widget._parse2baseType == Parse2BaseType.type1
        ? ApiConstant.parse2Url
        : ApiConstant.parse3Url;
    if (widget._parse2baseType == Parse2BaseType.type1) {
      switch (widget._type) {
        case ParseType.image:
          _currentKey = "/piclist.x?classid=9";
          break;
        case ParseType.book:
          _currentKey = "/novellist.x?classid=1";
          break;
        case ParseType.video:
          _currentKey = "/mlvideolist.x?tagid=3";
          break;
      }
    } else {
      switch (widget._type) {
        case ParseType.video:
          _currentKey = "/68mk/16/1.html";
          break;
        case ParseType.image:
          _currentKey = "/65mk/7/1.html";
          break;
        case ParseType.book:
          _currentKey = "/65mk/15/1.html";
          break;
      }
    }
  }

  //从网络获取数据
  void getData() async {
    childBtnValues.clear();
    String url = '';
    if (widget._parse2baseType == Parse2BaseType.type1) {
      parseUrl = '$baseUrl$_currentKey';
      String temp = parseUrl.contains('?') ? '&' : '?';
      url = '$parseUrl${temp}page=$_page';
    } else {
      url = baseUrl + _currentKey.substring(0, _currentKey.lastIndexOf('/')) + "/$_page.html";
    }
    var response = await http.get(Uri(path: url));
    Utf8Decoder utf8decoder = new Utf8Decoder();
    var body = utf8decoder.convert(response.bodyBytes);
    var document = parse.parse(body);
    setState(() {
      _refreshController.refreshCompleted();
      _refreshController.loadComplete();
    });
    if (widget._parse2baseType == Parse2BaseType.type1) {
      initBaseType1(document);
    } else {
      initBaseType2(document);
    }

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
        _currentKey = buttonBean.value!;
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
      case ParseType.image:
        getImg(item.targetUrl!);
        break;
      case ParseType.book:
        Navigator.of(context)
            .push(new MaterialPageRoute(builder: (BuildContext context) {
          return BookHomePage(item.targetUrl, widget._parse2baseType == Parse2BaseType.type1?3:0);
        }));
        break;
      case ParseType.video:
        getVideo(item.targetUrl!, item.title!);
        break;
    }
  }

  void getImg(String targetUrl) async {
    showLoading();
    var response = await http.get(Uri(path: targetUrl));
    var document = parse.parse(response.body);
    String className = widget._parse2baseType == Parse2BaseType.type1?"details-content text-justify":'content';
    var elments = document
        .getElementsByClassName(className)
        .first
        .getElementsByTagName("img");
    List<String> imgs = [];
    for (var value in elments) {
      imgs.add(value.attributes['src']!);
    }
    Navigator.pop(context);
    Navigator.pushNamed(context, "/ShowStaggeredImagePage", arguments: {"list": imgs});
  }

  void getVideo(String targetUrl, String title) async {
    showLoading();
    var response = await http.get(Uri(path: targetUrl));
    Utf8Decoder utf8decoder = new Utf8Decoder();
    var body = utf8decoder.convert(response.bodyBytes);
    Navigator.pop(context);
    var document = parse.parse(body);
    if(widget._parse2baseType == Parse2BaseType.type1){
      var playEle = document.getElementById('zanpiancms_player');
      String playUrl = '';
      if (playEle == null) {
        var source = document.getElementsByClassName('play-list');
        if(source == null || source.length == 0){
          playUrl = document.getElementById('vpath')!.text;
          playUrl.replaceAll('"', '');
        }else{
          var element = source.first;
          String url = element.getElementsByTagName("A").first.attributes['href']!;

          var response1 = await http.get(Uri(path: '$baseUrl$url'));
          var body1 = utf8decoder.convert(response1.bodyBytes);
          var document1 = parse.parse(body1);
          var elements = document1.getElementsByTagName('script');
          for (var value in elements) {
            if (value.text.contains("unescape('")) {
              String text = value.text;
              var urls = text.split(new RegExp(r"unescape\('|m3u8'\); "));
              String  m3u8Url = urls[1];
              if(!m3u8Url.contains('http')){
                urls = text.split(new RegExp(r'3u8path="|/";'));
                urls.forEach((value){
                  if(value.contains('http')){
                    m3u8Url = value;
                  }
                });
              }
              playUrl = '$m3u8Url/m3u8';
            }
          }
        }
      } else {
        playUrl = playEle.getElementsByTagName('source').first.attributes['src']!;
      }
      if(!playUrl.contains('http')){
        String  m3u8Url = '';
        var urls = body.split(new RegExp(r'3u8path="|/";'));
        urls.forEach((value){
          if(value.startsWith('http')){
            m3u8Url = value;
          }
        });
        playUrl = '$m3u8Url/$playUrl';
      }
      LogUtils.d('', playUrl);
      CommonUtil.toVideoPlay(playUrl, context,title:title);
    }else{
      var playList = document.getElementsByClassName('film_bar clearfix');
      String url = '';
      for(var value in playList){
         url = value.getElementsByTagName('a').first.attributes['href']!;
      }
      var respon = await NetUtil.getHtmlData(baseUrl + url);
      var playUrls = respon.split(new RegExp(r"unescape\('|.m3u8'\);"));
      String playUrl = EscapeUnescape.unescape('${playUrls[1]}.m3u8');
      if(playUrl != null){
        if(playUrl.contains('\$\$\$')){
          playUrl = playUrl.split('\$\$\$')[0];
        }
        if(playUrl.contains('\$')){
          playUrl = playUrl.split('\$')[1];
        }
        CommonUtil.toVideoPlay(playUrl, context,title:title);
      }

    }

  }

  @override
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
          padding: EdgeInsets.only(left: 10, right: 10),
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
                      imageUrl: _data[index].imageUrl!,
                      errorWidget: (context,url,error){
                        return Icon(Icons.error);
                      },
                      placeholder: (context,url){
                        return Icon(Icons.error);
                      },
                      fit: BoxFit.cover,
                    ),
                  ),
                  Text(
                    _data[index].title!,
                    maxLines: 1,
                  )
                ],
              ),
            );
          });
    }
  }

  void initBaseType1(dom.Document document) {
    var menuItems = document.getElementsByClassName('row-item-content');
    if (widget._type == ParseType.video) {
      for (int i = 0; i < 3; i++) {
        var menuEle = menuItems[i];
        var items = menuEle.getElementsByClassName('item');
        items.forEach((element) {
          ButtonBean buttonBean = new ButtonBean();
          buttonBean.title = element.getElementsByTagName('a').first.text;
          buttonBean.value =
              element.getElementsByTagName('a').first.attributes['href'];
          childBtnValues.add(buttonBean);
        });
      }
      var elements = document
          .getElementsByClassName('box-video-list')
          .first
          .getElementsByTagName('li');
      for (var value in elements) {
        var item = new VideoListItem();
        var titleEle = value.getElementsByClassName('title').first;
        item.title =
            titleEle.getElementsByTagName('a').first.attributes['title'];
        item.targetUrl =
            '$baseUrl${titleEle.getElementsByTagName('a').first.attributes['href']}';
        String url =
            value.getElementsByTagName('a').first.attributes['data-original']!;
        if (url == null || url == "") {
          url = value.getElementsByTagName('img').first.attributes['src']!;
        }
        item.imageUrl = url;
        _data.add(item);
      }
    } else {
      if (widget._type == ParseType.image) {
        if (menuItems.length > 3) {
          var menuEle = menuItems[3];
          var items = menuEle.getElementsByClassName('item');
          items.forEach((element) {
            ButtonBean buttonBean = new ButtonBean();
            buttonBean.title = element.getElementsByTagName('a').first.text;
            buttonBean.value =
                element.getElementsByTagName('a').first.attributes['href'];
            childBtnValues.add(buttonBean);
          });
        }
      } else {
        if (menuItems.length > 4) {
          var menuEle = menuItems[4];
          var items = menuEle.getElementsByClassName('item');
          items.forEach((element) {
            ButtonBean buttonBean = new ButtonBean();
            buttonBean.title = element.getElementsByTagName('a').first.text;
            buttonBean.value =
                element.getElementsByTagName('a').first.attributes['href'];
            childBtnValues.add(buttonBean);
          });
        }
      }
      var elements = document
          .getElementsByClassName('layout-box clearfix')
          .first
          .getElementsByTagName('li');
      try {
        for (var element in elements) {
          var aElement = element.getElementsByTagName('a').first;
          String title = aElement.attributes['title']!;
          if (title != null && title != "") {
            VideoListItem item = new VideoListItem();
            item.title = aElement.attributes['title'];
            String url = aElement.attributes['href']!;
            item.targetUrl = '$baseUrl$url';
            _data.add(item);
          }
        }
      } catch (e) {
        print(e);
      }
    }
  }
  //type2  获取内容
  void initBaseType2(dom.Document document) {
    var menuItems = document
        .getElementsByClassName('wrap mt20 nav')
        .first
        .getElementsByTagName('ul');
    if (widget._type == ParseType.video) {
      if(menuItems.length > 2){
        for (int i = 0; i < 3; i++) {
          var menuEle = menuItems[i];
          var items = menuEle.getElementsByTagName('li');
          items.forEach((element) {
            String value =
            element.getElementsByTagName('a').first.attributes['href']!;
            if (value != null && value != '/') {
              ButtonBean buttonBean = new ButtonBean();
              buttonBean.title = element.getElementsByTagName('a').first.text;
              buttonBean.value = value;
              childBtnValues.add(buttonBean);
            }
          });
        }
      }

      var items = document.getElementsByClassName('box movie_list').first.getElementsByTagName('li');
      for (var value1 in items) {
        var item = new VideoListItem();
        item.imageUrl = value1.getElementsByTagName('img').first.attributes['src'];
        item.targetUrl = baseUrl +  value1.getElementsByTagName('a').first.attributes['href']!;
        item.title = value1.text;
        _data.add(item);
      }

    } else {
      var menuEle = menuItems[widget._type == ParseType.image?3:4];
      var menuItem = menuEle.getElementsByTagName('li');
      menuItem.forEach((element) {
        String value =
        element.getElementsByTagName('a').first.attributes['href']!;
        if (value != null && value != '/') {
          ButtonBean buttonBean = new ButtonBean();
          buttonBean.title = element.getElementsByTagName('a').first.text;
          buttonBean.value = value;
          childBtnValues.add(buttonBean);
        }
      });
      var listItem = document.getElementsByClassName('box list channel');
      if(listItem.length > 0){
        var items = listItem.first.getElementsByTagName('li');
        for (var value1 in items) {
          var item = new VideoListItem();
          item.targetUrl ='$baseUrl${value1.getElementsByTagName('a').first.attributes['href']}';
          item.title = value1.text;
          _data.add(item);
        }
      }

    }
  }
}

enum ParseType { image, book, video }
enum Parse2BaseType { type1, type2 }
