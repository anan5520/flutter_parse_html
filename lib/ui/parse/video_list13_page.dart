import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_parse_html/book/base/util/utils_toast.dart';
import 'package:flutter_parse_html/model/video_list13_bean.dart';
import 'package:flutter_parse_html/model/video_list13_play_bean.dart';
import 'package:flutter_parse_html/model/video_list13_search_bean.dart';
import 'package:flutter_parse_html/model/video_list_item.dart';
import 'package:flutter_parse_html/ui/movie/movie_detail_page.dart';
import 'package:flutter_parse_html/ui/pornhub/pornhub_util.dart';
import 'package:flutter_parse_html/util/common_util.dart';
import 'package:flutter_parse_html/util/native_utils.dart';
import 'package:flutter_parse_html/util/porn_helper.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:flutter_parse_html/model/button_bean.dart';
import 'package:flutter_parse_html/net/net_util.dart';
import 'package:flutter_parse_html/api/api_constant.dart';
import 'package:html/parser.dart' as parse;
import 'package:flutter_parse_html/widget/dialog_page.dart';
import 'package:flutter_parse_html/model/movie_bean.dart';

class VideoList13Page extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return VideoList13State();
  }
}

class VideoList13State extends State<VideoList13Page>
    with AutomaticKeepAliveClientMixin {
  List<VideoListItem> _data = [];
  List<ButtonBean> _btns;

  RefreshController _refreshController;
  int _page = 1,buttonType = 0;
  String _currentKey = '0';
  bool _isSearch = false;
  TextEditingController _editingController;
  var _keys = {'全部':'0','自拍':'4','制服':'5','素人':'9','女同':'8','经典':'14','动漫':'11'};
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
      body: Column(
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
           child:  SmartRefresher(
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
             controller: _refreshController,
             child:  GridView.builder(
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

  getItem(int index) {
    VideoListItem item = _data[index];
    return ClipRRect(
      borderRadius: BorderRadius.circular(5),
      child: GestureDetector(
        onTap: () {
          goToDetail(item);
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


  //获取数据
  void _getData() async {
    String url = _isSearch?'${ApiConstant.videoList13Url}/search?wd=${Uri.encodeComponent(_currentKey)}&page=$_page':
    ApiConstant.videoList13Url +'/vod/listing-$_currentKey-0-0-0-0-0-0-0-0-$_page';
    String response = await NetUtil.getHtmlData(url,isWeb: !_isSearch);
    List<VideoListItem> list = [];
    if(_isSearch){
      VideoList13SearchBean videoList13SearchBean = VideoList13SearchBean.fromJson(json.decode(response));
      videoList13SearchBean.data.vodrows.forEach((element) {
        var item = VideoListItem();
        item.title = element.title;
        item.targetUrl = element.playUrl;
        item.imageUrl = element.coverpic;
        list.add(item);
      });
    }else{
      VideoList13Bean list13bean = VideoList13Bean.fromJson(json.decode(response));
      list13bean.data.vodrows.forEach((element) {
        var item = VideoListItem();
        item.title = element.title;
        item.targetUrl = element.playUrl;
        item.imageUrl = element.coverpic;
        list.add(item);
      });
    }

    if (_btns == null) {
      _btns = [];
      _keys.entries.forEach((element) {
        ButtonBean buttonBean = ButtonBean();
        buttonBean.title = element.key;
        buttonBean.value = element.value;
        _btns.add(buttonBean);
      });
    }

    _data.addAll(list);

    setState(() {
      _refreshController.refreshCompleted();
      _refreshController.loadComplete();
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
      }
      _refreshController.requestRefresh();
    }
  }

  void goToDetail(VideoListItem data) async {
    showLoading();
    String response = await NetUtil.getHtmlData(ApiConstant.videoList13Url + data.targetUrl);
    VideoList13PlayBean list13playBean = VideoList13PlayBean.fromJson(json.decode(response));
    if(list13playBean.data.httpurl == null || !list13playBean.data.httpurl.startsWith("http")){
      ToastUtils.showToast("播放地址无效");
      Navigator.pop(context);
      return;
    }
    Navigator.pop(context);
    CommonUtil.toVideoPlay(list13playBean.data.httpurl, context,title: data.title);
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
