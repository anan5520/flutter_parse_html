import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_parse_html/model/video14_button_bean.dart';
import 'package:flutter_parse_html/model/video14_detail_bean.dart';
import 'package:flutter_parse_html/model/video14_item_bean.dart';
import 'package:flutter_parse_html/util/common_util.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:flutter_parse_html/model/button_bean.dart';
import 'package:flutter_parse_html/net/net_util.dart';
import 'package:html/parser.dart' as parse;
import 'package:flutter_parse_html/widget/dialog_page.dart';

class VideoList14Page extends StatefulWidget {

  final type;


  VideoList14Page(this.type);

  static var videoBase = "http://liulianshipin10.xyz";
  @override
  State<StatefulWidget> createState() {
    switch(type){
      case 0:
        videoBase = "http://mrtzx.vip";
        break;
      case 1:
        videoBase = "http://fsfapermanentcosmeticartistry.com";
        break;
      case 2:
        videoBase = "http://api.klpqk.com";
        break;
      case 3:
        videoBase = "http://fsfanteriormanagement.com";
        break;
      case 4:
        videoBase = "https://api.cmbe2.xyz";
        break;
      case 5:
        videoBase = "http://fsvibrantnutritionandhealth.com";
        break;
    }
    return VideoList11State();
  }
}

class VideoList11State extends State<VideoList14Page>
    with AutomaticKeepAliveClientMixin {
  List<Video14ItemInfo> _data = [];
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
  void goToPlay(Video14ItemInfo data) async {
    showLoading();
    var response = await NetUtil.getHtmlData("${VideoList14Page.videoBase}/appapi/?service=video.gethvideoDetail&hvideoid=${data.id}&uid");
    try {
      var rescont = Video14DetailBean.fromJson(json.decode(response));
      var url = rescont.data.info.details.m3u8Url;
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
                  child: CachedNetworkImage(
                    placeholder: (context, url) => new Icon(Icons.image),
                    errorWidget: (context, url, error) => new Icon(Icons.error),
                    imageUrl: item.imgpath,
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


  void getBtn() async{
    if (_btns == null || _btns.length == 0) {
      _btns = [];
      String response = await NetUtil.getHtmlData('${VideoList14Page.videoBase}/appapi/?service=Video.getHvideoclass');
      _refreshController.refreshCompleted();
      _refreshController.loadComplete();
      var video11bean = Video14ButtonBean.fromJson(json.decode(response.replaceAll("-2", "\"-2\"")));
      video11bean.data.info.forEach((value1) {
        ButtonBean buttonBean = ButtonBean();
        buttonBean.title = value1.name;
        buttonBean.value = value1.id.toString();
        _btns.add(buttonBean);
      });
      if(_btns.length > 0){
        _currentKey = _btns[0].value;
        _getData();
      }
    }else{
      _getData();
    }

  }


  //获取数据
  void _getData() async {
    String url = _isSearch
        ? '${VideoList14Page.videoBase}/appapi/?service=Video.getHvideoListByclass&p=$_page&keyword=${Uri.encodeComponent(_currentKey)}'
        : "${VideoList14Page.videoBase}/appapi/?service=Video.getHvideoListByclass&hclassid=$_currentKey&p=$_page";
    String response = await NetUtil.getHtmlData(url);
    _refreshController.refreshCompleted();
    _refreshController.loadComplete();
    var video11itemBean = Video14ItemBean.fromJson(json.decode(response));
    try {
      _data.addAll(video11itemBean.data.info);
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
