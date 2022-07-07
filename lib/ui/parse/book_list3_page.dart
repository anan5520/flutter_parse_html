import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_parse_html/model/video_list_item.dart';
import 'package:flutter_parse_html/ui/movie/movie_detail_page.dart';
import 'package:flutter_parse_html/ui/pornhub/pornhub_util.dart';
import 'package:flutter_parse_html/util/common_util.dart';
import 'package:flutter_parse_html/util/native_utils.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:flutter_parse_html/model/button_bean.dart';
import 'package:flutter_parse_html/net/net_util.dart';
import 'package:flutter_parse_html/api/api_constant.dart';
import 'package:html/parser.dart' as parse;
import 'package:flutter_parse_html/widget/dialog_page.dart';
import 'package:flutter_parse_html/model/movie_bean.dart';

import 'book_page.dart';

class BookList3Page extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return BookList3State();
  }
}

class BookList3State extends State<BookList3Page>
    with AutomaticKeepAliveClientMixin {
  List<VideoListItem> _data = [];
  List<ButtonBean> _btns;

  RefreshController _refreshController;
  int _page = 1,buttonType = 0;
  String _currentKey = 'article.php?cate=1';
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
          Expanded(
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
              controller: _refreshController,
              child: ListView.builder(
                itemBuilder: (context, index) {
                  return new GestureDetector(
                    onTap: () {
                      Navigator.of(context)
                          .push(new MaterialPageRoute(builder: (BuildContext context) {
                        return BookHomePage(_data[index].targetUrl, 6);
                      }));
                    },
                    child: new ListTile(title: Text('${_data[index].title}')),
                  );
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

  void goToPlay(VideoListItem data) async {
    showLoading();
    var response = await NetUtil.getHtmlData(data.targetUrl);
    try {
      var strings = response.split(new RegExp(r'"url":"https|.m3u8'));
      String playUrl = '';
      for (var value in strings) {
        if (value.startsWith(':')) {
          playUrl = 'https$value.m3u8'.replaceAll('\\', '');
        }
      }
      Navigator.pop(context);
      if (playUrl.startsWith('http')) {
        CommonUtil.toVideoPlay(playUrl, context,title:data.title);
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
          Navigator.of(context)
              .push(new MaterialPageRoute(builder: (BuildContext context) {
            return BookHomePage(item.targetUrl, 6);
          }));
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

  //获取数据
  void _getData() async {
    String url = _isSearch
        ? '${ApiConstant.bookList3}/vodsearch/${Uri.encodeComponent(_currentKey)}----------$_page---.html'
        : "${ApiConstant.bookList3}$_currentKey&page=$_page";
    if(_currentKey.endsWith(".htm")){
      var key = _currentKey.replaceAll(".htm", '');
      url = "${ApiConstant.bookList3}${key}_$_page.htm";
    }
    String response =  await PornHubUtil.getHtmlFromHttpDeugger(url);
    _refreshController.refreshCompleted();
    _refreshController.loadComplete();
    var doc = parse.parse(response);
    try {
      var tdElements = doc
          .getElementsByClassName('articleList');
      for (var value in tdElements) {
        var aEles = value.getElementsByTagName('a');
        if (aEles.length > 0) {
          var aEle = aEles.first;
          VideoListItem item = VideoListItem();
          String href = ApiConstant.bookList3 +  aEle.attributes['href'];
          item.title = aEle.text;
          item.targetUrl = href;
          _data.add(item);
        }
      }
      if (_btns == null) {
        _btns = [];
      }else{
        _btns.clear();
      }

      var menu = doc.getElementsByClassName('container-fluid').first.getElementsByClassName('nav nav-pills').first;
      var hots = doc.getElementsByClassName('hot-search').first.getElementsByTagName('a');
      var liEles = menu.getElementsByTagName('li');
      liEles.forEach((element) {
        var btnEles = element.getElementsByTagName('a');
        for (var value1 in btnEles) {
          if(!value1.text.contains('首页')){
            ButtonBean buttonBean = ButtonBean();
            buttonBean.title = value1.text;
            buttonBean.value = value1.text.contains('首页')
                ? ''
                : value1.attributes['href'];
            _btns.add(buttonBean);
          }
        }
      });
      hots.forEach((element) {
        ButtonBean buttonBean = ButtonBean();
        buttonBean.title = element.text;
        buttonBean.value = element.attributes['href'];
        _btns.add(buttonBean);
      });
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
      }
      _refreshController.requestRefresh();
    }
  }

  void goToDetail(VideoListItem data) async {
    showLoading();
    String response = await PornHubUtil.getHtmlFromHttpDeugger(data.targetUrl);
    var doc = parse.parse(response);
    MovieBean movieBean = MovieBean();
    try {
      var tbody = doc.getElementsByClassName('stui-pannel clearfix').first;
      movieBean.imgUrl = data.imageUrl;
      movieBean.info = tbody.getElementsByClassName('title').first.text;
      movieBean.name = data.title;
      movieBean.des = '';
      movieBean.originUrl = data.targetUrl;
      movieBean.list = [];
      var ukMargin = doc.getElementsByClassName('stui-content__playlist clearfix');
      ukMargin.forEach((aEle) {
        MovieItemBean itemBean = MovieItemBean();
        itemBean.name = aEle.getElementsByTagName('a').first.text;
        itemBean.targetUrl = ApiConstant.bookList3 +  aEle.getElementsByTagName('a').first.attributes['href'];
        movieBean.list.add(itemBean);
      });
    } catch (e) {
      print(e);
    }

    Navigator.pop(context);
    Navigator.of(context)
        .push(new MaterialPageRoute(builder: (BuildContext context) {
      return MovieDetailPage(8, movieBean);
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
