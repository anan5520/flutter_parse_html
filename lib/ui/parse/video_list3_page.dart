import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_parse_html/model/video_list_item.dart';
import 'package:flutter_parse_html/ui/movie/movie_detail_page.dart';
import 'package:flutter_parse_html/ui/pornhub/pornhub_util.dart';
import 'package:flutter_parse_html/util/common_util.dart';
import 'package:flutter_parse_html/util/native_utils.dart';
import 'package:flutter_parse_html/widget/fade_in_image_without_auth.dart';
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

class VideoList3Page extends StatefulWidget {

  String _videoListUrl;


  VideoList3Page();

  VideoList3Page.withVideoListUrl(this._videoListUrl);

  @override
  State<StatefulWidget> createState() {
    return VideoList3State();
  }
}

class VideoList3State extends State<VideoList3Page>
    with AutomaticKeepAliveClientMixin {
  List<VideoListItem> _data = [];
  List<ButtonBean> _btns;

  RefreshController _refreshController;
  int _page = 1,buttonType = 0;
  String _currentKey = '';
  bool _isSearch = false;
  TextEditingController _editingController;
  String _baseUrl = ApiConstant.videoList3Url;
  bool _isVideoList = false;
  bool _isUserList = false;
  bool _isUserVideoList = false;

  @override
  void initState() {
    _refreshController = new RefreshController(initialRefresh: true);
    _editingController = new TextEditingController(text: _currentKey);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    bool showTopBar = (widget._videoListUrl != null && widget._videoListUrl.isNotEmpty);
    super.build(context);
    return showTopBar ?Scaffold(
      appBar: AppBar(title: Text('视频列表'),),
      body: Container(
        color: Color(0xffeeeeee),
        child: getContentWidget(),
      )):Scaffold(
      body: Container(
        color: Color(0xffeeeeee),
        child: getContentWidget(),
      ),
      floatingActionButton: widget._videoListUrl?.isNotEmpty != null?Container():FloatingActionButton(
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
    if(_page > 1 && !_isSearch && _currentKey.isEmpty && _btns != null){
      _currentKey = _btns[0].value;
    }
    String pageTag = (_isUserVideoList || _isUserList)?'?page=$_page':_page > 1?'$_page/':'';
    String listUrl = widget._videoListUrl?.isNotEmpty != null?'${widget._videoListUrl}$pageTag':
    '$_baseUrl${_currentKey.isNotEmpty?'$_currentKey$pageTag':'/html/index_m.html'}';
    String url = _isSearch?'$_baseUrl/search/video/?s=$_currentKey&page=$_page': listUrl ;

    print('请求数据>>$url');
//
    var body = await PornHubUtil.getHtmlFromHttpDeugger(url);
    _refreshController.refreshCompleted();
    _refreshController.loadComplete();
    var doc = parse.parse(body);
    try {
      var videos = doc.getElementsByClassName('cell video');
      if(videos.length > 0){
        _isUserVideoList = doc.getElementById('model') != null;
        _isVideoList = true;
        for (var value in videos) {
          try {
            var aEle = value.getElementsByTagName('a').first;
            var imgEle = value.getElementsByTagName('img').first;
            VideoListItem item = VideoListItem();
            String title = aEle.attributes['title'];
            String href = _baseUrl +
                aEle.attributes['href'];
            item.title = title;
            item.targetUrl = href;
            item.imageUrl = '$_baseUrl${imgEle.attributes['data-src']}';
            _data.add(item);
          } catch (e) {
            print(e);
          }
        }
      }
      var tdElements = doc.getElementsByClassName('category-thumb');
      _isUserList = false;
      if(tdElements.length == 0){
        tdElements = doc.getElementsByClassName('model-thumb');
        _isUserList = tdElements.length > 0;
      }
      if(tdElements.length > 0){//专题
        _isUserVideoList = false;
        _isVideoList = false;
        for (var value in tdElements) {
          try {
            var aEle = value.getElementsByTagName('a').first;
            var imgEle = value.getElementsByTagName('img').first;
            VideoListItem item = VideoListItem();
            String title = aEle.attributes['title'];
            String href = aEle.attributes['href'];
            item.title = title;
            item.targetUrl = href.contains(_baseUrl)?href:'$_baseUrl$href';
            item.imageUrl = '$_baseUrl${imgEle.attributes['data-src']}';
            _data.add(item);
          } catch (e) {
            print(e);
          }
        }
      }

      if (_btns == null) {
        _btns = [];
        var btnEles =
            doc.getElementsByClassName('menus menus-tabs').first.getElementsByTagName('li');
        for (var value1 in btnEles) {
          String value =
              value1.getElementsByTagName("a").first.attributes['href'];
          ButtonBean buttonBean = ButtonBean();
          buttonBean.title = CommonUtil.replaceStr(value1.text);
          if(!buttonBean.title.contains("女优大全") && !buttonBean.title.contains('导航')){
            buttonBean.value = value;
            _btns.add(buttonBean);
          }
        }
        var menuLists =
            doc.getElementById('main-menu').getElementsByClassName('menu-list').first.getElementsByTagName('a');
        for (var value1 in menuLists) {
          String value =
              value1.attributes['href'];
          ButtonBean buttonBean = ButtonBean();
          buttonBean.title = CommonUtil.replaceStr(value1.text);
          buttonBean.value = value;
          _btns.add(buttonBean);
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
    var body = await PornHubUtil.getHtmlFromHttpDeugger(data.targetUrl);
    try {
      var doc = parse.parse(body);
      var sources = doc.getElementById('player-fluid');
      String playUrl = '';
      var src = sources.attributes['style'];
      if(src.contains('player')){
        var urls = src.split(new RegExp(r'/tmb|player'));
        playUrl = 'https://storage.banyinjia8.com/media/videos/hls${urls[1]}playlist.m3u8';
      }else if(src.contains('.m3u8')){
        playUrl = src;
      }
      if(playUrl.contains('.trailer')){
        playUrl = playUrl.replaceAll('.trailer', '');
      }
      Navigator.pop(context);
      if (playUrl.startsWith('http')) {
        CommonUtil.toVideoPlay(playUrl, context,title:data.title,isDownLoad: true);
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
          if(_isVideoList){
            goToPlay(item);
          }else{
            Navigator.of(context).push(
                new MaterialPageRoute(builder: (BuildContext context) {
                  return VideoList3Page.withVideoListUrl(item.targetUrl);
                }));
          }
        },
        child: Container(
          color: Colors.white,
          child: new Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children:  <Widget>[
              Expanded(
                child: ConstrainedBox(
                  child:  new FadeInImageWithoutAuth.assetNetwork(
                    image: item.imageUrl,
                    placeholder: 'images/video_bg.png',
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
                  maxLines: _isVideoList?2:1,
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

  getContentWidget() {
    return Column(
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
                    crossAxisCount: 2,
                    childAspectRatio: _isUserList?0.6:1.5,
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
    );
  }
}
