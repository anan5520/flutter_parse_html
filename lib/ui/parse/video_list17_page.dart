import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_parse_html/model/video_list8_bean_entity.dart';
import 'package:flutter_parse_html/model/video_list_item.dart';
import 'package:flutter_parse_html/ui/movie/movie_detail_page.dart';
import 'package:flutter_parse_html/ui/parse/fan_hao_content_page.dart';
import 'package:flutter_parse_html/ui/porn/porn_forum_content_page.dart';
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

class VideoList17Page extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return VideoList17State();
  }
}

class VideoList17State extends State<VideoList17Page>
    with AutomaticKeepAliveClientMixin {
  List<VideoListItem> _data = [];
  List<ButtonBean> _btns;

  RefreshController _refreshController;
  int _page = 1, buttonType = 0;
  String _currentKey = '';
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
                      _page = 1;
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
              child: SmartRefresher(
                onRefresh: () {
                  _page = buttonType == 1 ? _page : 1;
                  _data.clear();
                  _getData();
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
    if(data.isVideo){
      var response = await PornHubUtil.getHtmlFromHttpDeugger(data.targetUrl);
      try {
        var doc = parse.parse(response);
        String playUrl = doc.getElementsByClassName('danmu').first.attributes['src'].split('url=')[1];
        Navigator.pop(context);
        if (playUrl.startsWith('http')) {
          CommonUtil.toVideoPlay(playUrl, context, title: data.title);
        }
      } catch (e) {
        Navigator.pop(context);
        print(e);
      }
    }else{
      Navigator.pop(context);
      Navigator.of(context).push(
          new MaterialPageRoute(builder: (BuildContext context) {
            return FanHaoContentPage(data.targetUrl);
          }));
    }

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
                  child: Stack(children: [
                    CachedNetworkImage(
                      placeholder: (context, url) => new Icon(Icons.image),
                      errorWidget: (context, url, error) => new Icon(Icons.error),
                      imageUrl: item.imageUrl,
                      fit: BoxFit.cover,
                    ), item.isVideo?Icon(Icons.play_circle_outline,color: Colors.white,):Container()
                  ],fit: StackFit.expand,),
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

  //获取数据
  void _getData() async {
    String url = _isSearch
        ? '${ApiConstant.videoList17Url}/page/$_page?s=$_currentKey'
        : "${ApiConstant.videoList17Url}$_currentKey${_currentKey.isEmpty?"":"/page/$_page"}";
    String response = await PornHubUtil.getHtmlFromHttpDeugger(url);
    _refreshController.refreshCompleted();
    _refreshController.loadComplete();
    var doc = parse.parse(response);
    try {
      var contentEle = doc.getElementsByClassName('excerpts-wrapper');
      if(contentEle.length > 0){
        var listEle = doc.getElementsByClassName('excerpts-wrapper').first.getElementsByTagName("article");
        for (var value in listEle) {
          var aEles = value.getElementsByTagName('a');
          if (aEles.length > 0) {
            var aEle = aEles.first;
            VideoListItem item = VideoListItem();
            var hrefs = aEle.attributes['href'];
            String href = '${ApiConstant.videoList17Url}$hrefs';
            var imgEle = aEle.getElementsByTagName('img').first;
            item.title = CommonUtil.replaceStr(value.text);
            item.isVideo = aEle.getElementsByClassName("thumb-video").length > 0;
            item.imageUrl = imgEle.attributes['data-src'] == null
                ? imgEle.attributes['src']
                : imgEle.attributes['data-src'];
            item.imageUrl = item.imageUrl.startsWith('http')
                ? item.imageUrl
                : '${ApiConstant.videoList17Url}${item.imageUrl}';
            item.targetUrl = href;
            _data.add(item);
          }
        }
      }
      if (_btns == null) {
        _btns = [];
        var menus = doc.getElementsByClassName('sub-menu');
        menus.forEach((element) {
          element.getElementsByTagName('a').forEach((value1) {
            ButtonBean buttonBean = ButtonBean();
            buttonBean.title = value1.text;
            if (!value1.text.contains('区') && !value1.text.contains('会员')) {
              buttonBean.value =
                  value1.attributes['href'].replaceAll('.html', '');
              _btns.add(buttonBean);
            }
          });

        });
        _currentKey = _btns[0].value;
        _getData();
      }
    } catch (e) {
      print(e);
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
