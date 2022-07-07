import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_parse_html/model/video12_bean.dart';
import 'package:flutter_parse_html/model/video12_bean2.dart';
import 'package:flutter_parse_html/model/video12_info_bean.dart';
import 'package:flutter_parse_html/util/common_util.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:flutter_parse_html/model/button_bean.dart';
import 'package:flutter_parse_html/net/net_util.dart';
import 'package:flutter_parse_html/api/api_constant.dart';
import 'package:html/parser.dart' as parse;
import 'package:flutter_parse_html/widget/dialog_page.dart';

class VideoList12Page extends StatefulWidget {
  var type = 1;
  static var videoBase = "https://apiet.cdzxjc.com/api/huajiao.php";


  VideoList12Page(this.type);

  @override
  State<StatefulWidget> createState() {
    switch(type){
      case 1:
        videoBase = "https://apiet.cdzxjc.com/api/huajiao.php";
        break;
      case 2:
        videoBase = "https://bljk3.com";
        break;
    }
    return VideoList12State();
  }
}

class VideoList12State extends State<VideoList12Page>
    with AutomaticKeepAliveClientMixin {
  List<Data> _data = [];
  List<ButtonBean> _btns;

  RefreshController _refreshController;
  int _page = 1, buttonType = 0;
  String _currentKey = '精品推荐';
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
  void goToPlay(Data data) async {
    showLoading();
    if(widget.type == 1){
      try {
        var url = data.dizhi;
        Navigator.pop(context);
        CommonUtil.toVideoPlay(url, context,title: data.biaoti);
      } catch (e) {
        Navigator.pop(context);
        print(e);
      }
    }else{
      String response = await NetUtil.getHtmlDataPost("${VideoList12Page.videoBase}/api/v1/video/videoinfo?uuid=81737333ab7961f0&device=0",
          paras: {'videoId':data.dizhi});

      Video12InfoBean video12infoBean = Video12InfoBean.fromJson(json.decode(response));
      Navigator.pop(context);
      CommonUtil.toVideoPlay(video12infoBean.result.url, context,title: video12infoBean.result.title);
    }

  }

  getItem(int index) {
    Data item = _data[index];
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
                    imageUrl: item.tupian,
                    fit: BoxFit.cover,
                  ),
                  constraints: new BoxConstraints.expand(),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 4, bottom: 4, left: 3, right: 3),
                child: Text(
                  '${item.biaoti}',
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
    if (_btns == null) {
      _btns = [];
      if(widget.type == 1){
        var titles = ["精品推荐","亚洲有码","中文字幕","日本无码","网红主播","美乳巨乳","萝莉少女","制服诱惑",
          "人妻熟女","三级伦理","成人动画"];
        titles.forEach((value1) {
          ButtonBean buttonBean = ButtonBean();
          buttonBean.title = value1;
          buttonBean.value = value1;
          _btns.add(buttonBean);
        });
      }else{
        var titles = {'自拍':'37','人妻':'36','外流':'32','三级':'25','中字':'29','极品':'17','欧美':'16','女同':'38','角色':'57','飞机':'54',};
        titles.forEach((key,value) {
          ButtonBean buttonBean = ButtonBean();
          buttonBean.title = key;
          buttonBean.value = value;
          _btns.add(buttonBean);
        });
      }
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
    if(widget.type == 1){
      String url = _isSearch
          ? '${ApiConstant.videoList10Url}/vodtag/$_currentKey/index-$_page.html'
          : "${VideoList12Page.videoBase}?t=${Uri.encodeComponent(_currentKey)}&p=$_page&sj=0";
      String response = await NetUtil.getHtmlData(url);
      _refreshController.refreshCompleted();
      _refreshController.loadComplete();
      Video12Bean bean = Video12Bean.fromJson(json.decode(response));
      try {
        _data.addAll(bean.data);
      } catch (e) {
        print(e);
      }
      setState(() {});
    }else{
      _getData2();
    }

  }

  //获取数据
  void _getData2() async {
    String url = _isSearch
        ? '${ApiConstant.videoList10Url}/vodtag/$_currentKey/index-$_page.html'
        : "${VideoList12Page.videoBase}/api/v1/video/list?page=$_page&uuid=81737333ab7961f0&device=0";
    String response = await NetUtil.getHtmlDataPost(url,paras: {'sortId':_currentKey});
    _refreshController.refreshCompleted();
    _refreshController.loadComplete();
    Video12Bean2 bean = Video12Bean2.fromJson(json.decode(response));
    try {
      bean.result.data.forEach((element) {
        _data.add(new Data(tupian: element.image,biaoti: element.title,dizhi: element.id.toString()));
      });
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
