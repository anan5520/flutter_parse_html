import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_gbk2utf8/flutter_gbk2utf8.dart';
import 'package:flutter_parse_html/model/video_list_item.dart';
import 'package:flutter_parse_html/model/xian_feng_bean_entity.dart';
import 'package:flutter_parse_html/ui/movie/movie_detail_page.dart';
import 'package:flutter_parse_html/ui/pornhub/pornhub_util.dart';
import 'package:flutter_parse_html/util/native_utils.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:flutter_parse_html/model/button_bean.dart';
import 'package:flutter_parse_html/net/net_util.dart';
import 'package:flutter_parse_html/api/api_constant.dart';
import 'package:html/parser.dart' as parse;
import 'package:http/http.dart' as http;
import 'package:html/dom.dart' as dom;
import 'package:flutter_parse_html/widget/dialog_page.dart';
import 'package:flutter_parse_html/model/movie_bean.dart';

class XianFengPage extends StatefulWidget {
  int _type = 0;

  XianFengPage(this._type);

  @override
  State<StatefulWidget> createState() {
    return XianFengState();
  }
}

class XianFengState extends State<XianFengPage>
    with AutomaticKeepAliveClientMixin {
  List<VideoListItem> _data = [];
  late List<ButtonBean> _btns;

  late RefreshController _refreshController;
  int _page = 1,buttonType = 0;
  String _currentKey = '/';
  String _searchKey = '';
  TextEditingController? _editingController;
  bool _isSearch = false;

  @override
  void initState() {
    _refreshController = new RefreshController(initialRefresh: true);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      body: Column(
        children: <Widget>[
          getSearchWidget(),
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
                        child: Text(_data[index].title!),
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
//        NativeUtils.toXfPlay('xfplay://dna=DwjbAwfdmwLWDZiWAZfdBdiZAZx2m0m4AGeXmeDXEdjbAZmYAZxZmt|dx=450062105|mz=JUY-794_CH_SD_onekeybatch.mp4|zx=nhE0pdOVl3P5AY5xqzD5Ac5wo206BGa4mc94MzXPozS|zx=nhE0pdOVl3Ewpc5xqzD4AF5wo206BGa4mc94MzXPozS');
          }
        },
        child: Icon(Icons.add),
      ),
    );
  }

  //获取数据
  void _getData() async {
    String url;
    if (widget._type == 0) {
      url = _isSearch
          ? ApiConstant.xianFengUrl +
              '/share/search?name=$_searchKey&page=$_page'
          : ApiConstant.xianFengUrl + _currentKey + 'index-$_page.html';
    } else {
      if (_page > 1 && _currentKey.contains('.html')) {
        _currentKey = _currentKey.replaceAll('.html', '');
        url = ApiConstant.xianFeng4Url + _currentKey + '_$_page.html';
      } else {
        url = ApiConstant.xianFeng4Url + _currentKey;
      }
    }
    String response;
    if (widget._type == 0) {
      response = await PornHubUtil.getHtmlFromHttpDeugger(url, isMobile: true);
    } else {
      var res = await http.get(Uri(path: url));
      response = gbk.decode(res.bodyBytes);
    }
    if (_isSearch) {
      List<XianFengBeanDataItem> items =
          XianFengBeanEntity.fromJson(json.decode(response)).data!.items!;
      for (var value in items) {
        VideoListItem item = VideoListItem();
        item.targetUrl = ApiConstant.xianFengUrl + value.urlpath!;
        item.title = value.name;
        _data.add(item);
      }
    } else {
      var doc = parse.parse(response);
      var btnElements = doc.getElementsByClassName('hypoMain clear');
      try {
        if (_btns == null) {
          _btns = [];
          for (var value in btnElements) {
            var eles = value.getElementsByTagName('li');
            for (var value1 in eles) {
              ButtonBean buttonBean = ButtonBean();
              var ems = value1.getElementsByTagName('em');
              if (ems.length > 0) {
                var em = ems[0];
                buttonBean.title = em.text;
                buttonBean.value =
                    em.getElementsByTagName('a').first.attributes['href'];
                _btns.add(buttonBean);
              }
            }
          }
        }
        List<dom.Element> tbodys = doc
            .getElementsByTagName('tbody')
            .first
            .getElementsByTagName('tbody');
        dom.Element tbody;
        if (tbodys.length > 2) {
          tbody = tbodys[1];
        } else {
          tbody = doc
              .getElementsByClassName('fullHNS')
              .first
              .getElementsByTagName('tbody')
              .first;
        }
        if (tbody != null) {
          if (widget._type == 0) {
            var trs = tbody.getElementsByTagName('tr');
            for (var value in trs) {
              String title =
                  value.text.replaceAll('\t', '').replaceAll('\n', '\t');
              if (!title.contains('上一页')) {
                VideoListItem item = VideoListItem();
                item.targetUrl = ApiConstant.xianFengUrl +
                    value.getElementsByTagName('a').first.attributes['href']!;
                item.title = title;
                _data.add(item);
              }
            }
          }else {
            var trs = tbody.getElementsByClassName('row');
            for (var value in trs) {
              String title =
              value.text.replaceAll('\t', '').replaceAll('\n', '\t');
              if (!title.contains('上一页')) {
                VideoListItem item = VideoListItem();
                item.targetUrl = ApiConstant.xianFeng4Url +
                    value.getElementsByTagName('a').first.attributes['href']!;
                item.title = title;
                _data.add(item);
              }
            }
          }
        }
      } catch (e) {
        print(e);
      }
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
      _isSearch = false;
      if(buttonBean.type == 1){
        _page = buttonBean.page;
        buttonType = 1;
      }else{
        buttonType = 0;
        _currentKey = buttonBean.value!;
      }
      _refreshController.requestRefresh();
    }
  }

  void goToDetail(VideoListItem data) async {
    showLoading();
    String response;
    if (widget._type == 0) {
      response = await PornHubUtil.getHtmlFromHttpDeugger(data.targetUrl!, isMobile: true);
    } else {
      var res = await http.get(Uri(path: data.targetUrl));
      response = gbk.decode(res.bodyBytes);
    }
    var doc = parse.parse(response);
    MovieBean movieBean = MovieBean();
    var tbodys = doc.getElementsByTagName('tbody');
    if (tbodys.length > 2) {
      var tbody = tbodys[1];
      movieBean.name = data.title;
      movieBean.imgUrl =
          tbody.getElementsByTagName('img').first.attributes['src'];
      if(widget._type == 1){
        movieBean.imgUrl = '${ApiConstant.xianFeng4Url}${movieBean.imgUrl}';
      }
      movieBean.info = tbody.getElementsByTagName('div').first.text;
      movieBean.des = tbody.getElementsByClassName('intro').first.text;
    }
    var inputs = doc.getElementsByTagName('input');
    for (var value in inputs) {
      String name = value.attributes['name']!;
      String targetUrl = value.attributes['value']!;
      if (name != null && (name == 'copy_yah' || name == 'copy_sel') && targetUrl.startsWith('xf')) {
        MovieItemBean movieItemBean = MovieItemBean();
        movieItemBean.targetUrl = targetUrl;
        movieItemBean.name = '先锋影音';
        movieBean.list = [movieItemBean];
      }
    }

    Navigator.pop(context);
    Navigator.of(context)
        .push(new MaterialPageRoute(builder: (BuildContext context) {
      return MovieDetailPage(2, movieBean);
    }));
  }

  getSearchWidget() {
    return Padding(
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
              _searchKey = value;
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
    );
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
