import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
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
import 'package:http/http.dart' as http;

import '../../model/api_bean.dart';
import '../../resources/shared_preferences_keys.dart';
import '../../util/shared_preferences.dart'; // 导入http包
class VideoList10Page extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return VideoList10State();
  }
}

class VideoList10State extends State<VideoList10Page>
    with AutomaticKeepAliveClientMixin {
  List<VideoListItem> _data = [];
  List<ButtonBean>? _btns;

  late RefreshController _refreshController;
  int _page = 1, buttonType = 0;
  String _currentKey = '';
  bool _isSearch = false;
  late TextEditingController _editingController;

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
          if (_btns?.isNotEmpty == true) {
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
    var response = await NetUtil.getHtmlData(data.targetUrl!);
    try {
      var doc = parse.parse(response);
      var gotoEles = doc.getElementsByClassName("full-top btn-submit");
      var gotoEle = gotoEles.length == 0
          ? doc.getElementsByClassName('series_body').first
          : gotoEles.first;
      String url =
          '${ApiConstant.videoList10Url}${gotoEle.attributes['onclick']?.replaceAll("location.href='", '')?.replaceAll("';", '')}';
      var detailResponse = await NetUtil.getHtmlData(url);
      var playDoc = parse.parse(detailResponse);
      var playUrl = playDoc.getElementsByClassName("player").first.getElementsByTagName('iframe').first.attributes['src']?.split(RegExp(r'url='))?[1];
      Navigator.pop(context);
      if (playUrl?.startsWith('http') == true) {
        CommonUtil.toVideoPlay(playUrl, context, title: data.title!);
      }
    } catch (e) {
      Navigator.pop(context);
      print(e);
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
                  child: CachedNetworkImage(
                    placeholder: (context, url) => new Icon(Icons.image),
                    errorWidget: (context, url, error) => new Icon(Icons.error),
                    imageUrl: item.imageUrl!,
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

  //获取数据
  void _getData() async {
    String url = _isSearch
        ? '${ApiConstant.videoList10Url}/?m=video_search*${Uri.encodeComponent(_currentKey)}*${_page}'
        : _currentKey.isNotEmpty?"${ApiConstant.videoList10Url}$_currentKey${_page}/index.htm":"${ApiConstant.videoList10Url}$_currentKey";
    String response = await NetUtil.getHtmlData(url);
    _refreshController.refreshCompleted();
    _refreshController.loadComplete();
    var doc = parse.parse(response);
    try {
      var listEle = doc.getElementsByClassName('wall');
      if(listEle.isEmpty){
        var tempUrl =  await _startRedirectProcess();
        if(tempUrl.isNotEmpty){
          SpUtil sp = await SpUtil.getInstance();
          ApiConstant.videoList10Url = tempUrl;
          String localStr = sp.getString(SharedPreferencesKeys.urls);
          UrlsBean localUrl;
          if (localStr != null && localStr.isNotEmpty) {
            localUrl = UrlsBean.fromJson(json.decode(localStr));
            localUrl.videoList10Url = ApiConstant.videoList10Url;
            sp.putString(SharedPreferencesKeys.urls, json.encode(localUrl));
          }
          _refreshController.requestRefresh();
        }

      }
      listEle = listEle.length == 0
          ? doc.getElementsByClassName('ilist_box')
          : listEle;
      var tdElements = listEle.first
          .getElementsByClassName('article');
      for (var value in tdElements) {
        var aEles = value.getElementsByTagName('a');
        if (aEles.length > 0) {
          var aEle = aEles.first;
          VideoListItem item = VideoListItem();
          var hrefs = aEle.attributes['href'];
          String href = '${ApiConstant.videoList10Url}$hrefs';
          var imgEle = aEle.getElementsByTagName('img').first;
          item.title = aEle.attributes['title'];
          item.imageUrl = imgEle.attributes['data-original'] == null
              ? imgEle.attributes['src']
              : imgEle.attributes['data-original'];
          item.imageUrl = item.imageUrl!.startsWith('http')
              ? item.imageUrl
              : 'http:${item.imageUrl}';
          item.targetUrl = href;
          _data.add(item);
        }
      }
      _btns = [];
      var menu = doc.getElementsByClassName('aui-palace-grid aui-phpasp');
      for (int i = 0; i < menu.length; i++) {
        var value1 = menu[i];
        ButtonBean buttonBean = ButtonBean();
        buttonBean.title = value1.text;
        if (!value1.text.contains('区') && !value1.text.contains('会员')) {
          buttonBean.value =
              value1.attributes['href']!.replaceAll('1/index.htm', '');
          _btns?.add(buttonBean);
        }
      }
    } catch (e) {
      print(e);
    }

    setState(() {});
  }

  // 合并后的方法，返回重定向的URL
  Future<String> _startRedirectProcess() async {
    // 获取当前URL并修改主机名
    String currentUrl = ApiConstant.videoList10Url;
    String referrer1 = Uri.parse(ApiConstant.videoList10Url).host;
    String modifiedReferrer = referrer1.replaceAll('.', '');

    // 获取当前时间的日期和秒
    DateTime now = DateTime.now();
    String date = now.day.toString();
    String second = now.hour.toString();

    // 延迟3秒后开始执行重定向逻辑
    await Future.delayed(Duration(seconds: 3));

    // 检查网站是否可用并返回重定向的URL
    String redirectUrl = await _checkWebsitesAvailability(modifiedReferrer, date, second);

    return redirectUrl;
  }

  // 检查网站可用性并返回最终重定向的URL
  Future<String> _checkWebsitesAvailability(String modifiedReferrer, String date, String second) async {
    List<Map<String, dynamic>> websites = [
      {
        'url': 'http://$date$second${Uri.encodeComponent(modifiedReferrer)}.linhe99.cfd/',
      },
      {
        'url': 'http://$date$second${Uri.encodeComponent(modifiedReferrer)}.wuhai11.cfd/',
      },
    ];

    int failed = 0;

    // 遍历检查每个网站
    for (var site in websites) {
      bool isOnline = await _checkWebsiteOnline(site['url']);
      if (isOnline) {
        // 如果网站可用，返回重定向URL
        return site['url'];
      } else {
        failed++;
        if (failed == websites.length) {
          // 如果所有网站都不可用，返回备用URL
          return "";
        }
      }
    }

    // 默认返回备用URL
    return "";
  }

  // 检查一个网站是否在线，返回结果
  Future<bool> _checkWebsiteOnline(String url) async {
    try {
      // 发送GET请求来检测网站是否可用
      final response = await http.get(Uri.parse(url));

      // 如果响应的状态码是200，表示网站在线
      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      // 捕获异常，表示网站无法访问
      return false;
    }
  }


  void _showDialog() async {
    ButtonBean buttonBean = await showDialog(
        context: context,
        builder: (context) {
          return new AlertDialog(
            content: GridViewDialog(_btns??[]),
          );
        });
    if (buttonBean != null) {
      if (buttonBean.type == 1) {
        _page = buttonBean.page;
        buttonType = 1;
      } else {
        _isSearch = false;
        buttonType = 0;
        _currentKey = buttonBean.value!;
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
