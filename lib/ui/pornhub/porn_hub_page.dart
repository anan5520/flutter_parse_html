import 'package:flutter/widgets.dart';
import 'package:flutter_parse_html/model/button_bean.dart';
import 'package:flutter_parse_html/model/movie_bean.dart';
import 'package:flutter_parse_html/model/porn_bean.dart';
import 'package:flutter_parse_html/model/video_list_item.dart';
import 'package:flutter_parse_html/ui/parse/webview_page.dart';
import 'package:flutter_parse_html/ui/pornhub/pornhub_util.dart';
import 'package:flutter_parse_html/util/common_util.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'package:flutter_parse_html/widget/dialog_page.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_parse_html/net/net_util.dart';
import 'package:flutter_parse_html/api/api_constant.dart';
import 'package:flutter_parse_html/util/log_utils.dart';
import 'package:html/parser.dart' as parse;
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:flutter_parse_html/util/porn_helper.dart';
import 'package:flutter_parse_html/ui/video_play.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class PornHubPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return PornState();
  }
}

class PornState extends State<PornHubPage> with AutomaticKeepAliveClientMixin {
  List<VideoListItem> _data = [];
  int _page = 1,buttonType = 0;
  String _currentKey = '';
  RefreshController _controller;
  bool _isSearch = false;
  TextEditingController _editingController;
  List<ButtonBean> _btns;
  bool _hasGetData = false;
  @override
  void initState() {
    // TODO: implement initState
    _controller = new RefreshController(initialRefresh: true);
    _editingController = new TextEditingController(text: _currentKey);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    // TODO: implement build
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showDialog();
        },
        child: Icon(Icons.forum),
      ),
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
                      _controller.requestRefresh();
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
                header: WaterDropMaterialHeader(),
                footer: ClassicFooter(),
                enablePullDown: true,
                enablePullUp: true,
                controller: _controller,
                onRefresh: () {
                  _page = buttonType == 1?_page:1;
                  _data.clear();
                  _hasGetData = false;
                  getData();
                },
                onLoading: () {
                  _hasGetData = false;
                  _page++;
                  getData();
                },
                child: ListView.builder(
                    itemCount: _data.length, itemBuilder: getItem),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget getItem(BuildContext context, int index) {
    VideoListItem item = _data[index];
    return GestureDetector(
      onTap: () async {
        showLoading();
       MovieBean movieBean = await PornHubUtil.getVideoUrl(item. targetUrl);
        // List<MovieItemBean> movieList = await Navigator.push(context, MaterialPageRoute(builder: (_) {
        //   return WebViewPage('https://www.vlogdownloader.com/#${item.targetUrl}');
        // }));
        Navigator.pop(context);
        if (movieBean != null ) {
          CommonUtil.toVideoPlay(movieBean.playUrl, context,title:movieBean.name,movieList: movieBean.list);
        }
      },
      child: Padding(
        padding: EdgeInsets.only(left: 10, right: 10, top: 5),
        child: Container(
          decoration: new BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(4),
            border: new Border.all(color: Color(0xFFEEEEEE), width: 0.5),
            // 边色与边宽度
// 生成俩层阴影，一层绿，一层黄， 阴影位置由offset决定,阴影模糊层度由blurRadius大小决定（大就更透明更扩散），阴影模糊大小由spreadRadius决定
            boxShadow: [
              BoxShadow(
                  color: Color(0xFFEEEEEE),
                  offset: Offset(5.0, 5.0),
                  blurRadius: 5.0,
                  spreadRadius: 2.0)
            ],
          ),
          child: Row(
            children: <Widget>[
              SizedBox(
                width: 160,
                height: 80,
                child: Padding(
                  padding: EdgeInsets.only(right: 10),
                  child: CachedNetworkImage(
                    placeholder: (context, url) => new Icon(Icons.image),
                    errorWidget: (context, url, error) => new Icon(Icons.image),
                    imageUrl: item.imageUrl,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Expanded(
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(bottom: 5),
                      child: Text(
                        '${item.title}(${item.title})',
                        style: TextStyle(color: Colors.blueAccent,),
                        maxLines: 4,
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void getData() async {
//    var data =
//        await PornHubUtil.getCategories();
    String url = _isSearch
        ? "${PornHubUtil.pornHubUrl}/video/search?search=$_currentKey&page=$_page"
        : _currentKey.isNotEmpty?'${PornHubUtil.pornHubUrl}$_currentKey&page=$_page':"https://cn.pornhub.com/video?page=$_page";
    initBtns();
    List<VideoListItem> list = [];
    if(_isSearch){
      list = await PornHubUtil.search(_currentKey,page: _page);
      _data.addAll(list);
      setState(() {
        _controller.loadComplete();
        _controller.refreshCompleted();
      });
    }else{
      getVideoUrls1(url);

      getVideoUrls2(url);
    }

//    var list = await NetUtil.getHtmlData('https://www.savido.net/download?url=https%3a%2f%2fcn.pornhub.com%2fview_video.php%3fviewkey%3dph5b47aeacae2ab',isWeb: true);
//    var playUrl = await PornHubUtil.getVideoUrl('https://cn.pornhub.com/view_video.php?viewkey=ph5b47aeacae2ab');
    LogUtils.d('porn', list.toString());


  }

  void showLoading() {
    showDialog(
        context: context,
        barrierDismissible: true,
        builder: (context) {
          return SpinKitWave(
            color: Colors.blue,
          );
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
      _controller.requestRefresh();
    }
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;

  void initBtns() async{
    if (_btns == null) {
      _btns = [];
      var btnList = await PornHubUtil.getCategories();
      _btns.addAll(btnList);
    }
  }

  void getVideoUrls1(String url) async{
    var list = await PornHubUtil.getViewUrlsFromCors(url);
    if(!_hasGetData){
      _hasGetData = true;
      _data.addAll(list);
      setState(() {
        _controller.loadComplete();
        _controller.refreshCompleted();
      });
    }
  }

  void getVideoUrls2(String url) async{
    var list = await PornHubUtil.getViewUrlsFromHttpDebugger(url,isMobile: false);
    if(!_hasGetData){
      _hasGetData = true;
      _data.addAll(list);
      setState(() {
        _controller.loadComplete();
        _controller.refreshCompleted();
      });
    }

  }
}
