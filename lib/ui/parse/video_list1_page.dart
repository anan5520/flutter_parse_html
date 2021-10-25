import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_parse_html/model/video_list_item.dart';
import 'package:flutter_parse_html/ui/movie/movie_detail_page.dart';
import 'package:flutter_parse_html/ui/pornhub/pornhub_util.dart';
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

class VideoList1Page extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return VideoList1State();
  }
}

class VideoList1State extends State<VideoList1Page>
    with AutomaticKeepAliveClientMixin {
  List<VideoListItem> _data = [];
  List<ButtonBean> _btns;

  RefreshController _refreshController;
  int _page = 1,buttonType = 0;
  String _currentKey = '/';
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
             child: ListView.separated(
                 separatorBuilder: (context, index) {
                   return Divider(
                     color: Colors.grey,
                   );
                 },
                 itemCount: _data.length,
                 itemBuilder: (context, index) {
                   return GestureDetector(
                     onTap: () {
                       goToDetail(_data[index]);
                     },
                     child: Padding(
                       padding: EdgeInsets.all(5),
                       child: Text(_data[index].title),
                     ),
                   );
                 }),
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

  //获取数据
  void _getData() async {
    String url = _isSearch?'${ApiConstant.videoList1Url}/search?wd=${_currentKey}&page=$_page':
    ApiConstant.videoList1Url +
        _currentKey +
        '${_currentKey == '/' ? 'index' : ''}-$_page.html';
    String response = await NetUtil.getHtmlData(url,isWeb: !_isSearch);
    var doc = parse.parse(response);
    try {
      var tdElements = doc
          .getElementsByClassName('mainbox')
          .first
          .getElementsByClassName('td');
      for (var value in tdElements) {
        var aEle = value.getElementsByTagName('a').first;
        VideoListItem item = VideoListItem();
        String title = aEle.text;
        String href = ApiConstant.videoList1Url + aEle.attributes['href'];
        item.title = title;
        item.targetUrl = href;
        _data.add(item);
      }
      if (_btns == null) {
        _btns = [];
        var btnEles =
            doc.getElementsByClassName('nav').first.getElementsByTagName('a');
        for (var value1 in btnEles) {
          ButtonBean buttonBean = ButtonBean();
          buttonBean.title = value1.text;
          buttonBean.value = value1.attributes['href'].replaceAll('.html', '');
          _btns.add(buttonBean);
        }
      }
    } catch (e) {
      print(e);
    }

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
    String response = await NetUtil.getHtmlData(data.targetUrl);
    var doc = parse.parse(response);
    MovieBean movieBean = MovieBean();
    try {
      var tbody = doc.getElementsByClassName('vssbox clearfix').first;
      movieBean.imgUrl = tbody
          .getElementsByClassName('vleft')
          .first
          .getElementsByTagName('img')
          .first
          .attributes['src'];
      movieBean.info = tbody.getElementsByClassName('vmid').first.text;
      movieBean.name = data.title;
      movieBean.des = '';
      movieBean.originUrl = data.targetUrl;
      var url = doc.getElementsByClassName('vtext').first.text.split('\$');
      MovieItemBean itemBean = MovieItemBean();
      itemBean.name = url[0];
      itemBean.targetUrl = url[1];
      movieBean.list = [itemBean];
    } catch (e) {
      print(e);
    }

    Navigator.pop(context);
    Navigator.of(context)
        .push(new MaterialPageRoute(builder: (BuildContext context) {
      return MovieDetailPage(3, movieBean);
    }));
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