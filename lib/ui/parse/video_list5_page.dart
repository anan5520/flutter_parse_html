import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_parse_html/model/video_list_item.dart';
import 'package:flutter_parse_html/ui/movie/movie_detail_page.dart';
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

class VideoList5Page extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return VideoList5State();
  }
}

class VideoList5State extends State<VideoList5Page>
    with AutomaticKeepAliveClientMixin {
  List<VideoListItem> _data = [];
  List<ButtonBean> _btns;

  RefreshController _refreshController;
  int _page = 1,buttonType = 0;
  String _currentKey = '/vodtypehtml/1';
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
    if(_page > 1 && !_isSearch && _currentKey.isEmpty && _btns != null){
      _currentKey = _btns[0].value;
    }
    String url = _isSearch?'${ApiConstant.videoList5Url}/vod-search-pg-${_page < 3?2:_page}-wd-$_currentKey.html':
        '${ApiConstant.videoList5Url}${_currentKey.isNotEmpty?'$_currentKey${_page >1?'-$_page':''}.html':''}';
    print('请求数据>>$url');
//
    var response = await http.get(Uri(path: url));
    Utf8Decoder utf8decoder = new Utf8Decoder();
    var body = utf8decoder.convert(response.bodyBytes);
//    String body = await NetUtil.getHtmlData(url);
    _refreshController.refreshCompleted();
    _refreshController.loadComplete();
    var doc = parse.parse(body);
    try {
      var tdElements = doc
          .getElementsByClassName('row row-boder')
          .first.getElementsByClassName('col-sm-6 col-md-4 col-lg-4');
      for (var value in tdElements) {
        var aEle = value.getElementsByTagName('a').first;
        var imgEle = value.getElementsByTagName('img').first;
        VideoListItem item = VideoListItem();
        String title = imgEle.attributes['title'];
        String href = ApiConstant.videoList5Url +
            aEle.attributes['href'];
        item.title = title;
        item.targetUrl = href;
        item.imageUrl = ApiConstant.videoList5Url + imgEle.attributes['src'];
        _data.add(item);
      }
      if (_btns == null) {
        _btns = [];
        var btnEles =
            doc.getElementsByClassName('mobile_navbar_collapse  visible-xs').first.getElementsByTagName('li');
        for (var value1 in btnEles) {
          String value =
              value1.getElementsByTagName('a').first.attributes['href'];
          if(value.contains('.html') && !value.contains('arttypehtml')){
            ButtonBean buttonBean = ButtonBean();
            buttonBean.title = value1.text;
            if (value.endsWith('.html')) {
              value = value.replaceAll('.html', '');
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
    var response = await http.get(Uri(path: data.targetUrl));
    Utf8Decoder utf8decoder = new Utf8Decoder();
    var body = utf8decoder.convert(response.bodyBytes);
    try {
      var doc = parse.parse(body);
      String jsUrl = ApiConstant.videoList5Url + doc.getElementById('video-body').getElementsByTagName('script').first.attributes['src'];
      String js = await NetUtil.getHtmlData(jsUrl);
      var strings = js.split(new RegExp(r"\'\);|unescape\(\'"));
      String playUrl = '';
      if(strings.length > 1){
        playUrl = 'http://yunbo1.gongyongplayer.science:2100/${strings[1]}/index.m3u8';
        Navigator.pop(context);
        if (playUrl.startsWith('http')) {
          CommonUtil.toVideoPlay(playUrl,context,title :data.title);
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
