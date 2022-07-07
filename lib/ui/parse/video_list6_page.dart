import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_parse_html/model/video_list_item.dart';
import 'package:flutter_parse_html/ui/movie/movie_detail_page.dart';
import 'package:flutter_parse_html/ui/porn/porn_forum_content_page.dart';
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

class VideoList6Page extends StatefulWidget {

  String _videoListUrl;


  VideoList6Page(this._videoListUrl);

  @override
  State<StatefulWidget> createState() {
    return VideoList6State(this._videoListUrl);
  }
}

class VideoList6State extends State<VideoList6Page>
    with AutomaticKeepAliveClientMixin {
  List<VideoListItem> _data = [];
  List<ButtonBean> _btns;
  String _videoListUrl;
  RefreshController _refreshController;
  int _page = 1,buttonType = 0;
  String _currentKey = '/';
  String _currentKeyName = '' ;
  bool _isSearch = false;
  TextEditingController _editingController;


  VideoList6State(this._videoListUrl);

  @override
  void initState() {
    _refreshController = new RefreshController(initialRefresh: true);
    _editingController = new TextEditingController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    bool showTopBar = (_videoListUrl != null && _videoListUrl.isNotEmpty);
    super.build(context);
    return showTopBar?Scaffold(
      appBar: AppBar(title: Text('视频列表'),),
      body: getContent(showTopBar),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_btns.length > 0) {
            //有选项再显示
            _showDialog();
          }
        },
        child: Icon(Icons.add),
      ),
    ):Scaffold(
      body: getContent(showTopBar),
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
    String url = (_videoListUrl != null && _videoListUrl.isNotEmpty)?_videoListUrl:_isSearch
        ? '${ApiConstant.videoList6Url}/search/?searchtypeval=&keyword=$_currentKey&page=$_page'
        : '${ApiConstant.videoList6Url}$_currentKey?page=$_page';
    print('请求数据>>$url');
//
//    var response = await http.get(url);
//    Utf8Decoder utf8decoder = new Utf8Decoder();
    var body = await PornHubUtil.getHtmlFromHttpDeugger(url,isMobile: false);
//    String body = await NetUtil.getHtmlData(url);
    _refreshController.refreshCompleted();
    _refreshController.loadComplete();
    var doc = parse.parse(body);
    try {
      var tdElements = doc
          .getElementsByClassName('grid_item');
      for (var value in tdElements) {
        var aEle = value.getElementsByTagName('a').first;
        var imgEle = aEle.getElementsByTagName('img').first;
        String imgUrl = imgEle.attributes['data-src'];
        VideoListItem item = VideoListItem();
        String title = aEle.text;
        String href = ApiConstant.videoList6Url +
            aEle.attributes['href'];
        item.title = CommonUtil.replaceStr(title);
        item.targetUrl = href;
        item.imageUrl = imgUrl.startsWith('http')?imgUrl:'${ApiConstant.videoList6Url}$imgUrl';
        _data.add(item);
      }
      if (_btns == null) {
        _btns = [];
        var btnEles =
            doc.getElementsByClassName('nav icont icon_slide').first.getElementsByTagName('a');
        for (var value1 in btnEles) {
          var notContains = ['领取福利','电影下载','代理赚钱','发布地址','发布地址','分类标签','名优采集API'];
          String title = value1.text;
          if(!notContains.contains(title)){
            String value = value1.attributes['href'];
            ButtonBean buttonBean = ButtonBean();
            buttonBean.title = title;
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
        _currentKey = buttonBean.value;
        _currentKeyName = buttonBean.title;
      }
      _refreshController.requestRefresh();
    }
  }

  void goToPlay(VideoListItem data) async {
    showLoading();
    var body = await PornHubUtil.getHtmlFromHttpDeugger(data.targetUrl,isMobile: false);
    try {
      var doc = parse.parse(body);
      String playUrl = doc.getElementById('videoUrl').attributes['value'];
      Navigator.pop(context);
      if (playUrl.startsWith('http')) {
        if(Platform.isIOS){
          var movieItem = MovieItemBean();
          movieItem.name = "播放";
          movieItem.targetUrl = playUrl;
          MovieBean movieBean = new MovieBean();
          movieBean.playUrl = data.targetUrl;
          movieBean.name = data.title;
          movieBean.imgUrl = data.imageUrl;
          movieBean.des = data.title;
          movieBean.list = [movieItem];
          Navigator.of(context).push(
              new MaterialPageRoute(builder: (BuildContext context) {
                return MovieDetailPage(6,movieBean);
              }));
        }else{
          CommonUtil.toVideoPlay(playUrl, context,title:data.title);
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
    return ClipRRect(
      borderRadius: BorderRadius.circular(5),
      child: GestureDetector(
        onTap: () {
          var toAvTitles = ['女优研习社','番号库','女优快报','女优写真'];
          if(_currentKeyName == '女优名鉴'){
            Navigator.of(context).push(
                new MaterialPageRoute(builder: (BuildContext context) {
                  return VideoList6Page(item.targetUrl);
                }));
          }else if(toAvTitles.contains(_currentKeyName)){
            Navigator.of(context).push(
                new MaterialPageRoute(builder: (BuildContext context) {
                  return PornForumContentPage(0,1,item.targetUrl);
                }));

          }else{
            goToPlay(item);
          }

        },
        child: Container(
          color: Colors.white,
          child: new Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Platform.isAndroid?Expanded(
                child: CachedNetworkImage(
                  placeholder: (context, url) => new Icon(Icons.image),
                  errorWidget: (context, url, error) => new Icon(Icons.error),
                  imageUrl: item.imageUrl,
                  memCacheHeight: 200,
                  height: 200,
                  fit: BoxFit.cover,
                ),
              ):Container(),
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

  getContent(bool showTopBar) {
    return Container(
      color: Color(0xffeeeeee),
      child: Column(
        children: <Widget>[
          showTopBar?new Container():
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
    );
  }
}
