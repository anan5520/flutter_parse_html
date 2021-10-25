import 'dart:convert';
import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_parse_html/api/api_constant.dart';
import 'package:flutter_parse_html/model/button_bean.dart';
import 'package:flutter_parse_html/model/movie_bean.dart';
import 'package:flutter_parse_html/net/net_util.dart';
import 'package:flutter_parse_html/ui/pornhub/pornhub_util.dart';
import 'package:flutter_parse_html/util/common_util.dart';
import 'package:flutter_parse_html/util/native_utils.dart';
import 'package:flutter_parse_html/widget/dialog_page.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:gbk2utf8/gbk2utf8.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:html/parser.dart' as parse;
import 'package:http/http.dart' as http;

import '../video_play.dart';

class GifPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return GifPageState();
  }
}

class GifPageState extends State with SingleTickerProviderStateMixin ,AutomaticKeepAliveClientMixin{
  TabController _tabController;

  List<String> titles = ['随机图片', 'gif1', 'gif2'];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _tabController = new TabController(length: titles.length, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: AppBar(
        title: Text("gif"),
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
          ],
          controller: _tabController,
        ),
      ),
      body: TabBarView(
        children: <Widget>[
          PhotoItemPage(),
          GifItemPage(GifType.gif1),
          GifItemPage(GifType.gif2),
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

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}

class GifItemPage extends StatefulWidget {
  GifType _gifType;

  @override
  State<StatefulWidget> createState() {
    return GifItemPageState(_gifType);
  }

  GifItemPage(this._gifType);
}

class GifItemPageState extends State with AutomaticKeepAliveClientMixin {
  List<GifItemBean> _data = [];

  RefreshController _refreshController;

  GifType _gifType;

  int _page = 1;

  String _url;

  String _currentKey;

  List<ButtonBean> childBtnValues;

  GifItemPageState(this._gifType);

  @override
  void initState() {
    _refreshController = new RefreshController(initialRefresh: true);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      body: new Container(
        color: Color(0xffeeeeee),
        child: SmartRefresher(
          controller: _refreshController,
          enablePullDown: true,
          enablePullUp: true,
          onRefresh: () {
            _data.clear();
            getData(true);
          },
          onLoading: () {
            _page++;
            getData(false);
          },
          child: GridView.builder(
            padding: EdgeInsets.all(10),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 0.6,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10),
            itemBuilder: (BuildContext context, int index) {
              return getItem(index);
            },
            itemCount: _data.length,
          ),
        ),
      ),
      floatingActionButton: new FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: () {
            _showDialog();
          }),
    );
  }

  Widget getItem(int index) {
    GifItemBean gifItemBean = _data[index];
    return GestureDetector(
      onTap: () {
        CommonUtil.showLoading(context);
        goToImage(gifItemBean.targetUrl,
            title: gifItemBean.name, imgUrl: gifItemBean.imageUrl);
      },
      child: new Container(
        color: Colors.white,
        child: new Column(
          children: <Widget>[
            Expanded(
              child: new CachedNetworkImage(
                imageUrl: gifItemBean.imageUrl,
                fit: BoxFit.cover,
              ),
            ),
            Text(
              gifItemBean.name,
              maxLines: 2,
            )
          ],
        ),
      ),
    );
  }

  void _showDialog() async {
    if (childBtnValues.length <= 0) return;
    ButtonBean buttonBean = await showDialog(
        context: context,
        builder: (context) {
          return new AlertDialog(
            content: GridViewDialog(childBtnValues),
          );
        });
    if (buttonBean != null) {
      _currentKey = buttonBean.value;
      if (_currentKey.contains('1.html')) {
        _currentKey = "/" + _currentKey.substring(0, _currentKey.length - 6);
      }
      _refreshController.requestRefresh();
    }
  }

  void getData(bool isRefresh) async {
    if (_gifType == GifType.gif1) {
      if (_currentKey != null && _currentKey != "") {
        _url = _page <= 1 ? _currentKey : '${_currentKey}p_$_page.html';
      } else {
        _url = _page <= 1
            ? '${ApiConstant.gif1}/gif'
            : '${ApiConstant.gif1}/gif/p_${_page}.html';
      }
    } else if (_gifType == GifType.gif2) {
      if (_currentKey == null || _currentKey.isEmpty)
        _currentKey = '/forum-37-';
      _url = '${ApiConstant.gif2}$_currentKey$_page.html';
    }

    String response = '';
    if (_gifType == GifType.gif1) {
      response =
          await NetUtil.getHtmlData(_url, isWeb: _gifType == GifType.gif1);
    } else {
      http.Response res = await http.get(Uri(path: _url));
      response = gbk.decode(res.bodyBytes);
    }
    _refreshController.refreshCompleted();
    _refreshController.loadComplete();
    var document = parse.parse(response);

    if (_gifType == GifType.gif1) {
      if (childBtnValues == null) {
        childBtnValues = [];
        var main = document.getElementsByClassName('nav');
        var aEles = main.first.getElementsByTagName('a');
        for (var value in aEles) {
          String url = value.attributes['href'];
          if (url != null && !value.text.contains('首页')) {
            ButtonBean buttonBean = new ButtonBean();
            buttonBean.value = url;
            buttonBean.title = value.text;
            childBtnValues.add(buttonBean);
          }
        }
      }

      var items = document.getElementsByClassName('xxl-item');
      for (var value1 in items) {
        var imgEles = value1.getElementsByTagName('img');
        if (imgEles.length > 0) {
          GifItemBean gifItemBean = new GifItemBean();
          var img = imgEles.first;
          gifItemBean.name = img.attributes['alt'];
          gifItemBean.imageUrl = img.attributes['src'];
          gifItemBean.targetUrl =
              value1.getElementsByTagName('a').first.attributes['href'];
          _data.add(gifItemBean);
        }
      }
    } else if (_gifType == GifType.gif2) {
      if (childBtnValues == null) {
        childBtnValues = [];
        var aEles = document.getElementById('lf_36').getElementsByTagName('dd');
        for (var value in aEles) {
          String url = value.getElementsByTagName('a').first.attributes['href'];
          ButtonBean buttonBean = new ButtonBean();
          buttonBean.value = url;
          buttonBean.title = value.text.replaceAll('\n', '');
          childBtnValues.add(buttonBean);
        }
      }

      var items =
          document.getElementById('waterfall').getElementsByTagName('li');
      for (var value1 in items) {
        GifItemBean gifItemBean = new GifItemBean();
        var img = value1.getElementsByTagName('img').first;
        gifItemBean.name = img.attributes['alt'];
        gifItemBean.imageUrl = '${ApiConstant.gif2}/${img.attributes['src']}';
        gifItemBean.targetUrl =
            '${ApiConstant.gif2}/${value1.getElementsByTagName('a').first.attributes['href']}';
        _data.add(gifItemBean);
      }
    }

    setState(() {});
  }

  void goToImage(String url, {String title, String imgUrl}) async {
    String response = '';
    List<String> images = [];
    String videoUrl = null;
    if (_gifType == GifType.gif2) {
      http.Response res = await http.get(Uri(path: url));
      response = gbk.decode(res.bodyBytes);
      var document = parse.parse(response);
      var imgs = document
          .getElementsByClassName('t_fsz')
          .first
          .getElementsByTagName('img');
      imgs.forEach((img) {
        images.add(img.attributes['src']);
      });
      Navigator.pop(context);
    } else {
      response = await PornHubUtil.getHtmlFromHttpDeugger(url,
          isMobile: _gifType != GifType.gif1);
      Navigator.pop(context);
      var document = parse.parse(response);
      var content = document.getElementsByClassName('content');
      content = content.length > 0
          ? content
          : document.getElementsByClassName('Article');
      if (content.length == 0) {
        images.add(imgUrl);
      } else {
        var imgs = content.first.getElementsByTagName('img');
        var videoEles = document.getElementsByTagName('video');
        if (videoEles.length > 0) {
          videoUrl = videoEles.first.attributes['src'];
        }
        imgs.forEach((img) {
          images.add(img.attributes['src']);
        });
      }
    }
    if (images.length > 0) {
      Navigator.pushNamed(context, "/ImagePage", arguments: {"list": images});
    } else if (videoUrl != null) {
      CommonUtil.toVideoPlay(videoUrl, context, title: title);
    }
  }

  @override
  bool get wantKeepAlive => true;
}

class PhotoItemPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return PhotoItemPageState();
  }
}

class PhotoItemPageState extends State with AutomaticKeepAliveClientMixin {
  List<GifItemBean> _data = [];

  RefreshController _refreshController;

  String _currentKey;

  List<ButtonBean> childBtnValues;

  var urlIndex = ['3', '3', '3', '2', '1'];

  var _widgetContent;

  var _shouldBuild = true;

  @override
  void initState() {
    _refreshController = new RefreshController(initialRefresh: true);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if(_widgetContent == null || _shouldBuild){
      _shouldBuild = false;
      _widgetContent = new Container(
        color: Color(0xffeeeeee),
        child: SmartRefresher(
          controller: _refreshController,
          enablePullDown: true,
          enablePullUp: true,
          onRefresh: () {
            _data.clear();
            getData(true);
          },
          onLoading: () {
            getData(false);
          },
          child: new StaggeredGridView.countBuilder(
            primary: true,
            crossAxisCount: 4,
            mainAxisSpacing: 4.0,
            crossAxisSpacing: 4.0,
            itemCount: _data.length,
            itemBuilder: (BuildContext context, int index) => new Container(
                color: Colors.grey,
                child: GestureDetector(
                  onTap: () {
                    _showDialog(_data[index].imageUrl);
                  },
                  child: new Center(
                    child: new CachedNetworkImage(
                      imageUrl:_data[index].imageUrl,
                    ),
                  ),
                )),
            staggeredTileBuilder: (int index) => new StaggeredTile.fit(2),
          ),
        ),
      );
    }
    return _widgetContent;
  }

  Widget getItem(int index) {
    GifItemBean gifItemBean = _data[index];
    return GestureDetector(
      onTap: () {
        CommonUtil.showLoading(context);
      },
      child: new Container(
        color: Colors.white,
        child: new Column(
          children: <Widget>[
            Expanded(
              child: new CachedNetworkImage(
                imageUrl: gifItemBean.imageUrl,
                fit: BoxFit.cover,
              ),
            ),
            Text(
              gifItemBean.name,
              maxLines: 2,
            )
          ],
        ),
      ),
    );
  }

  void _showDialog(var url) async {
    showDialog(
        context: context,
        builder: (context) {
          return new AlertDialog(
            content: ShowImageDialog(url),
          );
        });
  }

  void getData(bool isRefresh) async {
    for (var i = 0; i < 8; i++) {
      var response = await NetUtil.getHtmlData(
          'https://api.uomg.com/api/rand.img${urlIndex[Random().nextInt(urlIndex.length)]}&format=json');
      Map<String, dynamic> jsonStr = json.decode(response);
      GifItemBean gifItemBean = new GifItemBean();
      gifItemBean.imageUrl = jsonStr['imgurl'];
      _data.add(gifItemBean);
    }

    setState(() {
      _shouldBuild = true;
      _refreshController.refreshCompleted();
      _refreshController.loadComplete();
    });
  }

  @override
  bool get wantKeepAlive => true;
}
