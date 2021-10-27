import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_parse_html/model/button_bean.dart';
import 'package:flutter_parse_html/model/movie_bean.dart';
import 'package:flutter_parse_html/model/video_list_item.dart';
import 'package:flutter_parse_html/net/net_util.dart';
import 'package:flutter_parse_html/ui/parse/htm_parse_page1.dart';
import 'package:flutter_parse_html/ui/pornhub/pornhub_util.dart';
import 'package:flutter_parse_html/util/common_util.dart';
import 'package:flutter_parse_html/util/escapeu_unescape.dart';
import 'package:flutter_parse_html/util/log_utils.dart';
import 'package:flutter_parse_html/widget/dialog_page.dart';
import 'package:gbk2utf8/gbk2utf8.dart';
import 'package:html/dom.dart' as dom;
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parse;
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_parse_html/ui/parse/book_page.dart';
import 'package:unicorndial/unicorndial.dart';
import 'package:flutter_parse_html/ui/video_play.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_parse_html/api/api_constant.dart';

class HtmlParsePage2 extends StatelessWidget {
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

  List<String> titles = [
    '图片',
    '小说',
    '视频',
    '图片1',
    '小说1',
    '视频1',
    '图片2',
    '小说2',
    '视频2',
    // '图片3',
    // '小说3',
    // '视频3',
  ];

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
            Tab(text: "${titles[6]}"),
            Tab(text: "${titles[7]}"),
            Tab(text: "${titles[8]}"),
            // Tab(text: "${titles[9]}"),
            // Tab(text: "${titles[10]}"),
            // Tab(text: "${titles[11]}"),
          ],
          controller: _tabController,
        ),
      ),
      body: TabBarView(
        children: <Widget>[
          HtmlParse2Page(HtmlParse2Type.image),
          HtmlParse2Page(HtmlParse2Type.book),
          HtmlParse2Page(HtmlParse2Type.video),
          ParsePage(ParseType.image, Parse2BaseType.type4),
          ParsePage(ParseType.book, Parse2BaseType.type4),
          ParsePage(ParseType.video, Parse2BaseType.type4),
          ParsePage(ParseType.image, Parse2BaseType.type2),
          ParsePage(ParseType.book, Parse2BaseType.type2),
          ParsePage(ParseType.video, Parse2BaseType.type2),
          // ParsePage(ParseType.image, Parse2BaseType.type1),
          // ParsePage(ParseType.book, Parse2BaseType.type1),
          // ParsePage(ParseType.video, Parse2BaseType.type1),
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
  Parse2BaseType _parse2baseType;

  ParsePage(this._type, this._parse2baseType);

  @override
  State<StatefulWidget> createState() {
    return ParseState();
  }
}

class ParseState extends State<ParsePage> with AutomaticKeepAliveClientMixin {
  int _page = 1, buttonType = 0;
  RefreshController _refreshController;
  List<VideoListItem> _data = [];
  String baseUrl = 'https://www.2019be.com'; //WWW.4455VW.COM WWW.2019TR.COM
  String parseUrl = '${ApiConstant.siSeUrl}/xiaoshuo/list-情感小说-';
  List<ButtonBean> childBtnValues = [];
  List<UnicornButton> _childButtons;
  String _currentKey = '';

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
          _page = buttonType == 1 ? _page : 1;
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
    switch (widget._parse2baseType) {
      case Parse2BaseType.type1:
        baseUrl = ApiConstant.parse2Url;
        break;
      case Parse2BaseType.type2:
        baseUrl = ApiConstant.parse3Url;
        break;
      case Parse2BaseType.type4:
        baseUrl = ApiConstant.parse4Url;
        break;
    }
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
    } else if (widget._parse2baseType == Parse2BaseType.type4) {
      switch (widget._type) {
        case ParseType.video:
          _currentKey = "/dolan/index9.html";
          break;
        case ParseType.image:
          _currentKey = "/dohtml/part/index16.html";
          break;
        case ParseType.book:
          _currentKey = "/dohtml/part/index31.html";
          break;
      }
    }
  }

  //从网络获取数据
  void getData() async {
    // childBtnValues.clear();
    String url = '';
    if (widget._parse2baseType == Parse2BaseType.type1) {
      parseUrl = '$baseUrl$_currentKey';
      String temp = parseUrl.contains('?') ? '&' : '?';
      url = '$parseUrl${temp}page=$_page';
    } else if (widget._parse2baseType == Parse2BaseType.type2) {
      url = baseUrl +
          "${_currentKey != '' ? _currentKey.substring(0, _currentKey.lastIndexOf('/')) + "/$_page.html" : ''}";
    } else if (widget._parse2baseType == Parse2BaseType.type4) {
      if (_page > 1 && _currentKey.contains('.html')) {
        _currentKey = _currentKey.replaceAll('.html', '');
        url = '$baseUrl${_currentKey}_$_page.html';
      } else {
        url = '$baseUrl$_currentKey';
      }
    }
    String body = "";
    if (widget._parse2baseType == Parse2BaseType.type4) {
      body = await NetUtil.getHtmlData(url,
          isGbk: true,);
    } else {
      body = await PornHubUtil.getHtmlFromHttpDeugger(url);
    }
    _refreshController.refreshCompleted();
    _refreshController.loadComplete();
    var document = parse.parse(body);
    if (widget._parse2baseType == Parse2BaseType.type1) {
      var headerBody = await NetUtil.getHtmlData('$baseUrl/head_js.htm');
      var list = headerBody
          .split(new RegExp(r"<li class=\\'item\\'><a |</a></li>"))
          .where((element) => element.startsWith('href'))
          .toList();
      initBaseType1(document, list);
    } else if (widget._parse2baseType == Parse2BaseType.type2) {
      initBaseType2(document);
    } else {
      initBaseType4(document);
    }
    if (childBtnValues != null &&
        childBtnValues.length > 0 &&
        _data.length == 0) {
      _currentKey = childBtnValues[0].value;
      getData();
    }
    setState(() {});
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
      if (buttonBean.type == 1) {
        _page = buttonBean.page;
        buttonType = 1;
      } else {
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
      case ParseType.image:
        getImg(item.targetUrl);
        break;
      case ParseType.book:
        Navigator.of(context)
            .push(new MaterialPageRoute(builder: (BuildContext context) {
          return BookHomePage(
              item.targetUrl,
              widget._parse2baseType == Parse2BaseType.type4
                  ? 3
                  : widget._parse2baseType == Parse2BaseType.type2
                      ? 5
                      : 0);
        }));
        break;
      case ParseType.video:
        getVideo(item.targetUrl, item.title);
        break;
    }
  }

  void getImg(String targetUrl) async {
    showLoading();
    var response = await (widget._parse2baseType == Parse2BaseType.type2
        ? PornHubUtil.getHtmlFromHttpDeugger(targetUrl)
        : http.get(Uri(path: targetUrl)).then((value) => value.body));
    var document = parse.parse(response);
    String className = widget._parse2baseType == Parse2BaseType.type1
        ? "details-content text-justify"
        : 'content';
    switch (widget._parse2baseType) {
      case Parse2BaseType.type1:
        className = "details-content text-justify";
        break;
      case Parse2BaseType.type2:
        className = "content";
        break;
      case Parse2BaseType.type4:
        className = "novelContent";
        break;
    }
    var elments = document
        .getElementsByClassName(className)
        .first
        .getElementsByTagName("img");
    List<String> imgs = [];
    for (var value in elments) {
      imgs.add(value.attributes['src']);
    }
    Navigator.pop(context);
    Navigator.pushNamed(context, "/ShowStaggeredImagePage",
        arguments: {"list": imgs});
  }

  void getVideo(String targetUrl, String title) async {
    showLoading();
    var response = await http.get(Uri(path: targetUrl));
    Utf8Decoder utf8decoder = new Utf8Decoder();
    String body = widget._parse2baseType == Parse2BaseType.type4
        ? gbk.decode(response.bodyBytes)
        : utf8decoder.convert(response.bodyBytes);
    Navigator.pop(context);
    var document = parse.parse(body);
    if (widget._parse2baseType == Parse2BaseType.type1) {
      var playEle = document.getElementById('zanpiancms_player');
      String playUrl = '';
      if (playEle == null) {
        var source = document.getElementsByClassName('play-list');
        if (source == null || source.length == 0) {
          playUrl = document.getElementById('vpath')?.text;
          if (playUrl == null || playUrl == '') {
            playUrl =
                document.getElementsByTagName('source').first.attributes['src'];
          }
          if (!playUrl.startsWith("http")) {
            playUrl = 'https://m3u8.pps11.com/$playUrl';
          }
          playUrl.replaceAll('"', '');
        } else {
          var element = source.first;
          String url =
              element.getElementsByTagName("A").first.attributes['href'];

          var response1 = await http.get(Uri(path: '$baseUrl$url'));
          var body1 = utf8decoder.convert(response1.bodyBytes);
          var document1 = parse.parse(body1);
          var elements = document1.getElementsByTagName('script');
          for (var value in elements) {
            if (value.text.contains("unescape('")) {
              String text = value.text;
              var urls = text.split(new RegExp(r"unescape\('|m3u8'\); "));
              String m3u8Url = urls[1];
              if (!m3u8Url.contains('http')) {
                urls = text.split(new RegExp(r'3u8path="|/";'));
                urls.forEach((value) {
                  if (value.contains('http')) {
                    m3u8Url = value;
                  }
                });
              }
              playUrl = '$m3u8Url/m3u8';
            }
          }
        }
      } else {
        playUrl =
            playEle.getElementsByTagName('source').first.attributes['src'];
      }
      if (!playUrl.contains('http')) {
        String m3u8Url = '';
        var urls = body.split(new RegExp(r'3u8path="|/";'));
        urls.forEach((value) {
          if (value.startsWith('http')) {
            m3u8Url = value;
          }
        });
        playUrl = '$m3u8Url/$playUrl';
      }
      LogUtils.d('', playUrl);
      CommonUtil.toVideoPlay(playUrl, context, title: title);
    } else if (widget._parse2baseType == Parse2BaseType.type2) {
      var playList = document.getElementsByClassName('film_bar clearfix');
      String url = '';
      for (var value in playList) {
        url = value.getElementsByTagName('a').first.attributes['href'];
      }
      var respon = await PornHubUtil.getHtmlFromHttpDeugger(baseUrl + url);
      var playUrls = respon.split(new RegExp(r"unescape\('|.m3u8'\);"));
      String playUrl = EscapeUnescape.unescape('${playUrls[1]}.m3u8');
      if (playUrl != null) {
        if (playUrl.contains('\$\$\$')) {
          playUrl = playUrl.split('\$\$\$')[0];
        }
        if (playUrl.contains('\$')) {
          playUrl = playUrl.split('\$')[1];
        }
        CommonUtil.toVideoPlay(playUrl, context, title: title);
      }
    } else {
      var tbody = document.getElementsByTagName('tbody').first;
      String url =
          tbody.getElementsByTagName('input').first.attributes['value'];
      var response = await http.get(Uri(path: url));
      String body = gbk.decode(response.bodyBytes);
      var playLists = body.split(new RegExp('{"url":"|"}]'));
      if (playLists.length < 2) {
        playLists = body.split(new RegExp('main = "|";'));
      }
      var redirecturls = body.split(new RegExp('redirecturl = "|";'));
      String redirecturl;
      for (var value in redirecturls) {
        if (value.startsWith('http')) {
          redirecturl = value;
        }
      }
      if (redirecturl == null) {
        var urls = url.split('/');
        redirecturl = urls.length > 2 ? '${urls[0]}//${urls[2]}' : '';
      }
      String playUrl = '';
      playLists.forEach((value) {
        if (value.contains('.m3u8') && playUrl.isEmpty) {
          playUrl = '$redirecturl$value';
        }
      });
      if (playUrl != null) {
        CommonUtil.toVideoPlay(playUrl, context, title: title);
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
                      imageUrl: _data[index].imageUrl,
                      errorWidget: (context, url, error) {
                        return Icon(Icons.error);
                      },
                      placeholder: (context, url) {
                        return Icon(Icons.error);
                      },
                      fit: BoxFit.cover,
                    ),
                  ),
                  Text(
                    _data[index].title,
                    maxLines: 1,
                  )
                ],
              ),
            );
          });
    }
  }

  void initBaseType1(dom.Document document, List<String> header) {
    if (widget._type == ParseType.video) {
      if (header.length > 0 && childBtnValues.length == 0) {
        for (int i = 0; i < 32; i++) {
          var menuEle = header[i];
          var list = menuEle.split(new RegExp(r"href=\\'|\\' id=\\'|\\'>"));
          ButtonBean buttonBean = new ButtonBean();
          buttonBean.title = list.last;
          buttonBean.value = list[1];
          childBtnValues.add(buttonBean);
        }
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
            value.getElementsByTagName('a').first.attributes['data-original'];
        if (url == null || url == "") {
          url = value.getElementsByTagName('img').first.attributes['src'];
        }
        item.imageUrl = url;
        _data.add(item);
      }
    } else {
      if (widget._type == ParseType.image) {
        if (header.length > 0 && childBtnValues.length == 0) {
          for (int i = 32; i < 40; i++) {
            var menuEle = header[i];
            var list = menuEle.split(new RegExp(r"href=\\'|\\' id=\\'|\\'>"));
            ButtonBean buttonBean = new ButtonBean();
            buttonBean.title = list.last;
            buttonBean.value = list[1];
            childBtnValues.add(buttonBean);
          }
        }
      } else {
        if (header.length > 0 && childBtnValues.length == 0) {
          for (int i = 40; i < header.length; i++) {
            var menuEle = header[i];
            var list = menuEle.split(new RegExp(r"href=\\'|\\' id=\\'|\\'>"));
            ButtonBean buttonBean = new ButtonBean();
            buttonBean.title = list.last;
            buttonBean.value = list[1];
            childBtnValues.add(buttonBean);
          }
        }
      }
      var elements = document
          .getElementsByClassName('layout-box clearfix')
          .first
          .getElementsByTagName('li');
      try {
        for (var element in elements) {
          var aElement = element.getElementsByTagName('a').first;
          String title = aElement.attributes['title'];
          if (title != null && title != "") {
            VideoListItem item = new VideoListItem();
            item.title = aElement.attributes['title'];
            String url = aElement.attributes['href'];
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
    try {
      if (widget._type == ParseType.video) {
        if (menuItems.length > 2 && childBtnValues?.length == 0) {
          for (int i = 0; i < 3; i++) {
            var menuEle = menuItems[i];
            var items = menuEle.getElementsByTagName('li');
            items.forEach((element) {
              String value =
                  element.getElementsByTagName('a').first.attributes['href'];
              if (value != null && value != '/') {
                ButtonBean buttonBean = new ButtonBean();
                buttonBean.title = element.getElementsByTagName('a').first.text;
                buttonBean.value = value;
                childBtnValues.add(buttonBean);
              }
            });
          }
        }

        var items = document
            .getElementsByClassName('box movie_list')
            .first
            .getElementsByTagName('li');
        for (var value1 in items) {
          var item = new VideoListItem();
          item.imageUrl =
              value1.getElementsByTagName('img').first.attributes['src'];
          item.targetUrl = baseUrl +
              value1.getElementsByTagName('a').first.attributes['href'];
          item.title = value1.text;
          _data.add(item);
        }
      } else {
        if (childBtnValues?.length == 0) {
          var menuEle = menuItems[widget._type == ParseType.image ? 3 : 4];
          var menuItem = menuEle.getElementsByTagName('li');
          menuItem.forEach((element) {
            String value =
                element.getElementsByTagName('a').first.attributes['href'];
            if (value != null && value != '/') {
              ButtonBean buttonBean = new ButtonBean();
              buttonBean.title = element.getElementsByTagName('a').first.text;
              buttonBean.value = value;
              childBtnValues.add(buttonBean);
            }
          });
        }
        var listItem = document.getElementsByClassName('box list channel');
        if (listItem.length > 0) {
          var items = listItem.first.getElementsByTagName('li');
          for (var value1 in items) {
            var item = new VideoListItem();
            item.targetUrl =
                '$baseUrl${value1.getElementsByTagName('a').first.attributes['href']}';
            item.title = value1.text;
            _data.add(item);
          }
        }
      }
    } catch (e) {
      print(e);
    }
  }

  void initBaseType4(dom.Document document) {
    var menuItems = document
        .getElementsByClassName('mainArea px9')
        .first
        .getElementsByTagName('ul');
    if (childBtnValues.length == 0) {
      dom.Element menuItem;
      menuItems.forEach((menu) {
        var text = menu.text;
        if (widget._type == ParseType.image && text.contains('激情图区')) {
          menuItem = menu;
          addBtnData(menuItem);
        } else if (widget._type == ParseType.video &&
            (text.contains('在线视频') || text.contains('影音先锋'))) {
          menuItem = menu;
          addBtnData(menuItem);
        } else if (widget._type == ParseType.book && text.contains('激情文学')) {
          menuItem = menu;
          addBtnData(menuItem);
        }
      });
    }
    if (widget._type == ParseType.video) {
      var videoList = document.getElementsByClassName('movieList');
      var items = videoList.first.getElementsByTagName('li');
      for (var item in items) {
        var videoListItem = new VideoListItem();
        videoListItem.targetUrl =
            '$baseUrl${item.getElementsByTagName('a').first.attributes['href']}';
        videoListItem.title = item.text;
        videoListItem.imageUrl =
            baseUrl + item.getElementsByTagName('img').first.attributes['src'];
        _data.add(videoListItem);
      }
    } else {
      var textList = document.getElementsByClassName('textList');
      var items = textList.first.getElementsByTagName('li');
      for (var item in items) {
        var videoListItem = new VideoListItem();
        videoListItem.targetUrl =
            '$baseUrl${item.getElementsByTagName('a').first.attributes['href']}';
        videoListItem.title = item.text;
        _data.add(videoListItem);
      }
    }
    setState(() {});
  }

  void addBtnData(dom.Element menuItem) {
    var lis = menuItem.getElementsByTagName('li');
    lis.forEach((value) {
      String url = value.getElementsByTagName('a').first.attributes['href'];
      if ('/' != url) {
        ButtonBean buttonBean = new ButtonBean();
        buttonBean.title = value.getElementsByTagName('a').first.text;
        buttonBean.value = url;
        childBtnValues.add(buttonBean);
      }
    });
  }
}

enum ParseType { image, book, video }
enum Parse2BaseType { type1, type2, type4 }
