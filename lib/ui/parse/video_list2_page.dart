import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_parse_html/model/video_list_item.dart';
import 'package:flutter_parse_html/ui/movie/movie_detail_page.dart';
import 'package:flutter_parse_html/ui/parse/webview_page.dart';
import 'package:flutter_parse_html/ui/pornhub/pornhub_util.dart';
import 'package:flutter_parse_html/util/common_util.dart';
import 'package:flutter_parse_html/util/native_utils.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:flutter_parse_html/model/button_bean.dart';
import 'package:flutter_parse_html/net/net_util.dart';
import 'package:flutter_parse_html/api/api_constant.dart';
import 'package:html/parser.dart' as parse;
import 'package:http/http.dart' as http;
import 'package:flutter_parse_html/widget/dialog_page.dart';
import 'package:flutter_parse_html/model/movie_bean.dart';

import '../video_play.dart';

class VideoList2Page extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return VideoList2State();
  }
}

class VideoList2State extends State<VideoList2Page>
    with AutomaticKeepAliveClientMixin {
  List<VideoListItem> _data = [];
  List<ButtonBean> _btns;

  RefreshController _refreshController;
  int _page = 0,buttonType = 0;
  String _currentKey = ApiConstant.xVideosKey;
  bool _isSearch = true;
  TextEditingController _editingController;

  @override
  void initState() {
    _refreshController = new RefreshController(initialRefresh: true);
    _editingController = new TextEditingController(text: _currentKey);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      body: Container(
        color: Color(0xffeeeeee),
        child: Column(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.all(10),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Container(
                  padding: EdgeInsets.only(left: 10, right: 4),
                  alignment: Alignment.centerLeft,
                  color: Colors.white,
                  child: TextField(
                    maxLines: 1,
                    autofocus: false,
                    controller: _editingController,
                    textInputAction: TextInputAction.go,
                    onSubmitted: (value) {
                      _page = 0;
                      _currentKey = value;
                      _isSearch = true;
                      _refreshController.requestRefresh();
                    },
                    style: TextStyle(color: Colors.blue),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: "搜索",
                      hintStyle: TextStyle(color: Colors.blue),
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Container(
                color: Color(0xffeeeeee),
                child: SmartRefresher(
                  onRefresh: () {
                    _page = buttonType == 1?_page:1;
                    _data.clear();
                    _getData();
                  },
                  onLoading: () {
                    _page++;
                    _getData();
                  },
                  enablePullUp: true,
                  enablePullDown: true,
                  header: WaterDropHeader(),
                  controller: _refreshController,
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
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_btns.length > 0) {
            //有选项再显示
            _showDialog();
          }
        },
        child: Icon(Icons.add),
      ),
    );
  }

  //获取数据
  void _getData() async {
    String url = _isSearch
        ? '${ApiConstant.videoList2Url}/?k=${Uri.encodeComponent(_currentKey)}&p=$_page'
        : '${ApiConstant.videoList2Url}/c/$_page/$_currentKey';
    print('请求数据>>$url');
//
//    var response = await http.get(url);
//    Utf8Decoder utf8decoder = new Utf8Decoder();
    var body = await PornHubUtil.getHtmlFromHttpDeugger(url,isMobile: false,isXvideos: true);
//    String body = await NetUtil.getHtmlData(url);
    _refreshController.refreshCompleted();
    _refreshController.loadComplete();
    var doc = parse.parse(body);
    try {
      var tdElements = doc
          .getElementsByClassName('mozaique')
          .first
          .getElementsByClassName('thumb-block');
      for (var value in tdElements) {
        var aEle = value.getElementsByClassName('thumb-under').first;
        var imgEle = value.getElementsByTagName('img').first;
        VideoListItem item = VideoListItem();
        String title = aEle.text;
        String href = ApiConstant.videoList2Url +
            aEle.getElementsByTagName('a').first.attributes['href'];
        item.title = title;
        item.targetUrl = href;
        item.imageUrl = imgEle.attributes['data-src'];
        _data.add(item);
      }
      if (_btns == null) {
        _btns = [];
        var btnEles =
            doc.getElementById('main-cat-sub-list').getElementsByTagName('li');
        for (var value1 in btnEles) {
          String value =
              value1.getElementsByTagName('a').first.attributes['href'];
          if (value != '#' && value != '/lang') {
            ButtonBean buttonBean = ButtonBean();
            buttonBean.title = value1.text;
            if (value.endsWith('&top')) {
              value = value.replaceAll('&top', '');
            } else if (value.startsWith('/c/')) {
              value = value.replaceAll('/c/', '');
            }
            buttonBean.value = value;
            _btns.add(buttonBean);
          }
        }
      }
    } catch (e) {
      print(e);
    }

    setState(() {
    });
  }

  void _showDialog() async {
    ButtonBean buttonBean = await showDialog(
        context: context,
        builder: (context) {
          return new AlertDialog(
            content: GridViewDialog(_btns),
          );
        });
    if (buttonBean != null) {
      if(buttonBean.type == 1){
        _page = buttonBean.page;
        buttonType = 1;
      }else{
        _isSearch = false;
        buttonType = 0;
        String value = buttonBean.value;
        if (value.startsWith('/?k=')) {
          value = value.replaceAll('/?k=', '');
          _isSearch = true;
        }
        _currentKey = value;
      }
      _refreshController.requestRefresh();
    }
  }

  void goToPlay(VideoListItem data) async {
    showLoading();
    var body = await PornHubUtil.getHtmlFromHttpDeugger(data.targetUrl,isMobile: false,isXvideos: true);
    try {
      var strings = body.split(new RegExp(r"setVideoUrlLow\(\'|\'\);"));
      String playUrl = '';
      for (var value in strings) {
        if (value.startsWith('http')) {
          playUrl = value;
        }
      }
      Navigator.pop(context);
      if (playUrl.startsWith('http')) {
        CommonUtil.toVideoPlay(playUrl, context,title:data.title);
      }
    } catch (e) {
      Navigator.pop(context);
      print(e);
    }
  }

  void showLoading() {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return SpinKitWave(
            color: Colors.blue,
          );
        });
  }

  getItem(int index) {
    VideoListItem item = _data[index];
    return ClipRRect(
      borderRadius: BorderRadius.circular(5),
      child: GestureDetector(
        onTap: () {
          goToPlay(item);
        },
        child: Container(
          color: Colors.white,
          child: new Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Expanded(
                child: ConstrainedBox(
                  child: CachedNetworkImage(
                    placeholder: (context, url) => new Icon(Icons.image),
                    errorWidget: (context, url, error) => new Icon(Icons.error),
                    imageUrl: item.imageUrl,
                    fit: BoxFit.cover,
                  ),
                  constraints: new BoxConstraints.expand(),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 4, bottom: 4, left: 3, right: 3),
                child: Text(
                  '${item.title}',
                  style: TextStyle(fontSize: 12),
                  maxLines: 1,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
