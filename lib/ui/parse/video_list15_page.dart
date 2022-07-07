import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_parse_html/model/video14_button_bean.dart';
import 'package:flutter_parse_html/model/video14_detail_bean.dart';
import 'package:flutter_parse_html/model/video14_item_bean.dart';
import 'package:flutter_parse_html/model/video15_detail_bean.dart';
import 'package:flutter_parse_html/model/video15_item_bean.dart';
import 'package:flutter_parse_html/util/common_util.dart';
import 'package:flutter_parse_html/widget/fade_in_image_without_auth.dart';
import 'package:flutter_parse_html/widget/image_provider_net_memory.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:flutter_parse_html/model/button_bean.dart';
import 'package:flutter_parse_html/net/net_util.dart';
import 'package:html/parser.dart' as parse;
import 'package:flutter_parse_html/widget/dialog_page.dart';

class VideoList15Page extends StatefulWidget {
  VideoList15Page();

  static var videoBase = "https://api.bldd4.xyz";

  @override
  State<StatefulWidget> createState() {
    return VideoList11State();
  }
}

class VideoList11State extends State<VideoList15Page>
    with AutomaticKeepAliveClientMixin {
  List<Video15Data> _data = [];
  List<ButtonBean> _btns;
  var btnData = {
    "国产": "58",
    "av剧情": "29",
    "职场同事": "44",
    "小编推荐": "30",
    "制服诱惑": "5",
    "人妻": "6",
    "巨乳": "42",
    "女教师": "48",
    "主播": "17",
    "欧美": "16",
    "无码": "1",
    "飞机": "54",
    "三级": "25",
    "自拍": "10",
    "痴女": "22",
    "无码破坏版": "47",
    "名优": "9",
    "drp出品": "55",
    "痴汉": "46",
    "素人": "24",
    "乱伦": "45",
    "萝莉": "51",
    "外流视频": "32",
    "嫩模": "37",
    "长腿": "11",
    "重口味": "23",
    "人妖": "56",
    "女同": "38",
    "角色": "4",
    "偷拍": "53",
    "明星": "40",
    "自慰": "57",
    "动漫": "14"
  };
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
  void goToPlay(Video15Data data) async {
    showLoading();
    var response = await NetUtil.getHtmlDataPost("${VideoList15Page.videoBase}/api/v1/video/videoinfo?device=0", paras: {
      "videoId":data.id
    }, header: {
      "Host": "api.blee5.xyz",
      "Pragma": "no-cache",
      "Accept-Language": "zh-CN,zh;q=0.9",
    });
    try {
      var detailRes = Video15DetailBean.fromJson(json.decode(response));
      var url = detailRes.result.url;
      Navigator.pop(context);
      CommonUtil.toVideoPlay(url, context,title: data.title);
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
                  child: FadeInImageWithoutAuth.base64Network(image: item.coverbase64.url,placeholder: 'images/video_bg.png',
                    fit: BoxFit.cover),
                  constraints: new BoxConstraints.expand(),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 4, bottom: 4, left: 3, right: 3),
                child: Text(
                  '${item.title}',
                  style: TextStyle(fontSize: 12),
                  maxLines: 3,
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
      btnData.forEach((key, value) {
        ButtonBean buttonBean = ButtonBean();
        buttonBean.title = key;
        buttonBean.value = value;
        _btns.add(buttonBean);
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
        ? '${VideoList15Page.videoBase}/api/v1/video/searchbywords?page=$_page'
        : "${VideoList15Page.videoBase}/api/v1/video/list?page=$_page";
    var response = await NetUtil.getHtmlDataPost(url, paras: {
      _isSearch ? "keyWords" : "sortId":_currentKey
    }, header: {
      "Host": "api.blee5.xyz",
      "Origin": "http://www.httpdebugger.com",
      "Pragma": "no-cache",
      "Accept-Language": "zh-CN,zh;q=0.9",
    });
    _refreshController.refreshCompleted();
    _refreshController.loadComplete();
    var itemBean = Video15ItemBean.fromJson(json.decode(response));
    try {
      _data.addAll(itemBean.result.data);
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
