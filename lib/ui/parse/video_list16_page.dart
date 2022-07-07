import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_parse_html/model/video11_bean.dart';
import 'package:flutter_parse_html/model/video11_bean.dart';
import 'package:flutter_parse_html/model/video11_item_bean.dart';
import 'package:flutter_parse_html/model/video_list_item.dart';
import 'package:flutter_parse_html/ui/movie/movie_detail_page.dart';
import 'package:flutter_parse_html/ui/pornhub/pornhub_util.dart';
import 'package:flutter_parse_html/util/common_util.dart';
import 'package:flutter_parse_html/util/escapeu_unescape.dart';
import 'package:flutter_parse_html/util/files.dart';
import 'package:flutter_parse_html/util/native_utils.dart';
import 'package:flutter_parse_html/widget/fade_in_image_without_auth.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:flutter_parse_html/model/button_bean.dart';
import 'package:flutter_parse_html/net/net_util.dart';
import 'package:flutter_parse_html/api/api_constant.dart';
import 'package:html/parser.dart' as parse;
import 'package:flutter_parse_html/widget/dialog_page.dart';
import 'package:flutter_parse_html/model/movie_bean.dart';

class VideoList16Page extends StatefulWidget {
  VideoList16Page();

  static var videoBase = "http://www.34tn.com/";

  @override
  State<StatefulWidget> createState() {
    return VideoList16State();
  }
}

class VideoList16State extends State<VideoList16Page>
    with AutomaticKeepAliveClientMixin {
  List<VideoListItem> _data = [];
  List<ButtonBean> _btns;

  RefreshController _refreshController;
  int _page = 1, buttonType = 0;
  String _currentKey = '/vodlist/33';
  bool _isSearch = false;
  TextEditingController _editingController;

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
      body: Container(
        color: Color(0xffeeeeee),
        child: Column(
          children: <Widget>[
            Expanded(
              child: SmartRefresher(
                onRefresh: () {
                  _page = buttonType == 1 ? _page : 1;
                  _data.clear();
                  getBtn();
                },
                onLoading: () {
                  _page++;
                  _getData();
                },
                enablePullUp: true,
                enablePullDown: true,
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

  //跳转播放
  void goToPlay(VideoListItem data) async {
    showLoading();
    var response = await PornHubUtil.getHtmlFromHttpDeugger(data.targetUrl);
    try {
      var doc = parse.parse(response);
      var url = '';
      doc.getElementsByTagName('script').forEach((element) {
        if (element.text.contains('m3u8')) {
          url = '${element.text.split(RegExp(r'"url":"|m3u8'))[1]}m3u8'.replaceAll('\\', '');
        }
        if (element.text.contains('.mp4')) {
          url = '${element.text.split(RegExp(r'"url":"|mp4"'))[1]}mp4'.replaceAll('\\', '');
        }
      });
      Navigator.pop(context);
      if (url.startsWith('http'))
        CommonUtil.toVideoPlay(url, context, title: data.title);
    } catch (e) {
      Navigator.pop(context);
      print(e);
    }
  }

  getItem(int index) {
    var item = _data[index];
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
                  maxLines: 2,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  void getBtn() async {
    if (_btns == null || _btns.length == 0) {
      _btns = [];
      String response =
          await PornHubUtil.getHtmlFromHttpDeugger(VideoList16Page.videoBase);
      _refreshController.refreshCompleted();
      _refreshController.loadComplete();
      var doc = parse.parse(response);
      var oddEles = doc.getElementsByClassName('row-item odd');
      oddEles.forEach((element) {
        if (element.text.contains("视频")) {
          element.getElementsByTagName("li").forEach((liEle) {
            ButtonBean buttonBean = ButtonBean();
            buttonBean.title = liEle.text;
            buttonBean.value =
                liEle.getElementsByTagName('a').first.attributes['href'];
            _btns.add(buttonBean);
          });
        }
      });
      var evenEles = doc.getElementsByClassName('row-item even');
      evenEles.forEach((element) {
        if (element.text.contains("视频")) {
          element.getElementsByTagName("li").forEach((liEle) {
            ButtonBean buttonBean = ButtonBean();
            buttonBean.title = liEle.text;
            buttonBean.value =
                liEle.getElementsByTagName('a').first.attributes['href'];
            _btns.add(buttonBean);
          });
        }
      });
      if (_btns.length > 0) {
        _currentKey = _btns[0].value;
        _getData();
      }
    } else {
      _getData();
    }
  }

  //获取数据
  void _getData() async {
    String url = _isSearch
        ? '${VideoList16Page.videoBase}/api/videosort/0?page=$_page&serach=${Uri.encodeComponent(_currentKey)}&uuid=1'
        : "${VideoList16Page.videoBase}${_currentKey}${_page == 1?'':'index_$_page.html'}";
    String response = await PornHubUtil.getHtmlFromHttpDeugger(url);
    _refreshController.refreshCompleted();
    _refreshController.loadComplete();
    var doc = parse.parse(response);
    var liELes = doc
        .getElementById('tpl-img-content')
        ?.getElementsByTagName('li');
    liELes?.forEach((element) {
      var item = VideoListItem();
      item.imageUrl =
          element.getElementsByTagName('img').first.attributes['data-original'];
      item.title = element.text;
      item.targetUrl =
          '${VideoList16Page.videoBase}${element.getElementsByTagName('a').first.attributes['href']}';
      _data.add(item);
    });

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
      if (buttonBean.type == 1) {
        _page = buttonBean.page;
        buttonType = 1;
      } else {
        _isSearch = false;
        buttonType = 0;
        _currentKey = buttonBean.value;
      }
      _refreshController.requestRefresh();
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

  @override
  bool get wantKeepAlive => true;
}
