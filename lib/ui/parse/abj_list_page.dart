import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_parse_html/model/video_list_item.dart';
import 'package:flutter_parse_html/ui/movie/movie_detail_page.dart';
import 'package:flutter_parse_html/ui/porn/abj_content_page.dart';
import 'package:flutter_parse_html/ui/porn/porn_forum_content_page.dart';
import 'package:flutter_parse_html/ui/pornhub/pornhub_util.dart';
import 'package:flutter_parse_html/util/common_util.dart';
import 'package:flutter_parse_html/util/native_utils.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:flutter_parse_html/model/button_bean.dart';
import 'package:flutter_parse_html/net/net_util.dart';
import 'package:flutter_parse_html/api/api_constant.dart';
import 'package:html/parser.dart' as parse;
import 'package:http/http.dart' as http;
import 'package:flutter_parse_html/widget/dialog_page.dart';
import 'package:flutter_parse_html/model/movie_bean.dart';

import '../video_play.dart';

class AbjListPage extends StatefulWidget {
  AbjListPage();

  @override
  State<StatefulWidget> createState() {
    return AbjListState();
  }
}

class AbjListState extends State<AbjListPage>
    with AutomaticKeepAliveClientMixin {
  List<VideoListItem> _data = [];
  List<ButtonBean> _btns;
  RefreshController _refreshController;
  int _page = 1;
  String _currentKey = '/forum.php?mod=forumdisplay&fid=137';
  String _currentKeyName = '';

  bool _isSearch = false;
  TextEditingController _editingController;

  AbjListState();

  @override
  void initState() {
    _refreshController = new RefreshController(initialRefresh: true);
    _editingController = new TextEditingController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: AppBar(
        actions: [
          TextButton(
              child: Text(
                "复制论坛地址",
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () {
                Fluttertoast.showToast(
                    msg: '已复制到粘贴板', toastLength: Toast.LENGTH_SHORT);
                Clipboard.setData(new ClipboardData(text: ApiConstant.abjUrl));
              }),
        ],
        title: Text('谨慎去'),
      ),
      body: getContent(),
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
    String url = '${ApiConstant.abjUrl}$_currentKey&page=$_page';
    print('请求数据>>$url');
//
//    var response = await http.get(url);
//    Utf8Decoder utf8decoder = new Utf8Decoder();
    var body = await NetUtil.getHtmlData(url,
        isGbk: true,
        saveCookie: false,isWeb: false);
//    String body = await NetUtil.getHtmlData(url);
    _refreshController.refreshCompleted();
    _refreshController.loadComplete();
    var doc = parse.parse(body);

    var tdElements1 =
        doc.getElementById('threadlisttableid').getElementsByTagName('tbody');
    if (_page == 1) {
      var tdElements =
          doc.getElementById('top_lists_c').getElementsByTagName('tbody');
      for (var value in tdElements) {
        try {
          if (value.attributes['id'].contains('normalthread')) {
            VideoListItem item = VideoListItem();
            String title = value.getElementsByClassName('s xst').first.text;
            var xst = value.getElementsByClassName('s xst').first;
            String href =
                '${ApiConstant.abjUrl}/${value.getElementsByClassName('s xst').first.attributes['href']}';
            item.title = CommonUtil.replaceStr(title);
            item.targetUrl = href;
            item.des = value.getElementsByClassName('by').first.text;
            if (item.title.contains("大家好")) {
              _data.add(item);
            }
          }
        } catch (e) {
          print(e);
        }
      }
    }
    for (var value in tdElements1) {
      try {
        if (value.attributes['id'].contains('normalthread')) {
          VideoListItem item = VideoListItem();
          String title = value.getElementsByClassName('s xst').first.text;
          var xst = value.getElementsByClassName('s xst').first;
          String href =
              '${ApiConstant.abjUrl}/${value.getElementsByClassName('s xst').first.attributes['href']}';
          item.title = CommonUtil.replaceStr(title);
          item.targetUrl = href;
          item.des = value.getElementsByClassName('by').first.text;
          _data.add(item);
        }
      } catch (e) {
        print(e);
      }
    }

    setState(() {});
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
      String value = buttonBean.value;
      _isSearch = false;
      if (value.startsWith('/?k=')) {
        value = value.replaceAll('/?k=', '');
        _isSearch = true;
      }
      _currentKey = value;
      _currentKeyName = buttonBean.title;
      _refreshController.requestRefresh();
    }
  }

  void goToPlay(VideoListItem data) async {
    showLoading();
    var body = await PornHubUtil.getHtmlFromHttpDeugger(data.targetUrl,
        isMobile: false);
    try {
      var doc = parse.parse(body);
      String playUrl = doc.getElementById('videoUrl').attributes['value'];
      Navigator.pop(context);
      if (playUrl.startsWith('http')) {
        if (Platform.isIOS) {
          var movieItem = MovieItemBean();
          movieItem.name = "播放";
          movieItem.targetUrl = playUrl;
          MovieBean movieBean = new MovieBean();
          movieBean.playUrl = data.targetUrl;
          movieBean.name = data.title;
          movieBean.imgUrl = data.imageUrl;
          movieBean.des = data.title;
          movieBean.list = [movieItem];
          Navigator.of(context)
              .push(new MaterialPageRoute(builder: (BuildContext context) {
            return MovieDetailPage(6, movieBean);
          }));
        } else {
          CommonUtil.toVideoPlay(playUrl, context, title: data.title);
        }
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
    return Padding(
      padding: EdgeInsets.only(top: 10),
      child: GestureDetector(
        onTap: () {
          Navigator.of(context)
              .push(new MaterialPageRoute(builder: (BuildContext context) {
            return AbjForumContentPage(0, 2, item.targetUrl);
          }));
        },
        child: Container(
          color: Colors.white,
          child: new Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Expanded(
                child: Padding(
                  padding:
                      EdgeInsets.only(top: 4, bottom: 4, left: 3, right: 3),
                  child: Text(
                    '${item.title}',
                    style: TextStyle(fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              Text('${item.des}')
            ],
          ),
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;

  getContent() {
    return Container(
      color: Color(0xffeeeeee),
      child: Column(
        children: <Widget>[
          Expanded(
            child: Container(
              color: Color(0xffeeeeee),
              child: SmartRefresher(
                onRefresh: () {
                  _page = 1;
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
                child: ListView.builder(
                  padding: EdgeInsets.all(10),
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
    );
  }
}