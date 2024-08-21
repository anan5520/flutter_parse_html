import 'dart:collection';

import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_parse_html/model/button_bean.dart';
import 'package:flutter_parse_html/util/common_util.dart';
import 'package:flutter_parse_html/widget/dialog_page.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:flutter_parse_html/model/video_list_item.dart';
import 'package:flutter_parse_html/model/book_bean.dart';
import 'package:flutter_parse_html/net/net_util.dart';
import 'package:flutter_parse_html/api/api_constant.dart';
import 'package:html/parser.dart' as parse;
import 'dart:convert';

import 'book_page.dart';

class BookList4Page extends StatefulWidget {
  var url = "";

  BookList4Page(this.url);

  @override
  State<StatefulWidget> createState() {
    return BookList4State();
  }
}

class BookList4State extends State<BookList4Page>
    with AutomaticKeepAliveClientMixin {
  String _currentKey = '';
  int _page = 1;
  late RefreshController _refreshController;
  late TextEditingController _editingController;
  List<VideoListItem> _data = [];
  late List<ButtonBean> _btns;
  bool _isSearch = false;

  @override
  void initState() {
    _refreshController = new RefreshController(initialRefresh: true);
    _editingController = new TextEditingController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return _getContent();
  }

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  Widget getItem(BuildContext context, int index) {
    return GestureDetector(
      onTap: () {
        if (_data[index].show!) {
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return BookList4Page(_data[index].targetUrl!);
          }));
        } else {
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return BookHomePage(_data[index].targetUrl, 7);
          }));
        }
      },
      child: Padding(
        padding: EdgeInsets.only(top: 10, bottom: 10, left: 5, right: 5),
        child: Column(children: [
          Text(_data[index].title!,style: TextStyle(color: Colors.blue),),
          Text(_data[index].des == null?"":_data[index].des!)
        ],),
      ),
    );
  }

  getData() async {
    String url = widget.url.isEmpty
        ? _isSearch
            ? "${ApiConstant.bookList4Url}/page/$_page?s=${Uri.encodeComponent(_currentKey)}"
            : '${ApiConstant.bookList4Url}$_currentKey/page/$_page'
        : widget.url;
    String response = await NetUtil.getHtmlData(url);

    setState(() {
      _refreshController.refreshCompleted();
      _refreshController.loadComplete();
    });
    var doc = parse.parse(response);
    var menus = doc
        .getElementsByClassName("menu-mobile-header-list")
        ?.first
        ?.getElementsByTagName('li');
    var contentEle = doc.getElementsByClassName("post-list");
    if (contentEle.length > 0) {
      var itemEles = contentEle?.first?.getElementsByTagName('li');
      itemEles!.forEach((element) {
        var contentItem =
            element.getElementsByClassName('post-item-main').first;
        var item = VideoListItem()
          ..des = CommonUtil.replaceStr(contentItem.getElementsByClassName('post-item-content').first.text)
          ..title = contentItem.getElementsByTagName('a').first.text
          ..targetUrl =
              contentItem.getElementsByTagName('a').first.attributes['href']
          ..show = contentItem.text.contains("置顶");
        _data.add(item);
      });
    }

    var suijiRoot = doc.getElementsByClassName('post-content-post');
    if (suijiRoot.length > 0) {
      var suijiEles = suijiRoot?.first?.getElementsByTagName('li');
      suijiEles!.forEach((element) {
        var item = VideoListItem()
          ..title = CommonUtil.replaceStr(element.text)
          ..targetUrl =
              '${ApiConstant.bookList4Url}${element.getElementsByTagName('a').first.attributes['href']}'
          ..show = element.text.contains("置顶");
        _data.add(item);
      });
    }

    if (_btns == null) {
      _btns = [];
      menus?.forEach((element) {
        var aEle = element.getElementsByTagName('a').first;
        _btns.add(ButtonBean()
          ..title = aEle.text
          ..value = aEle.attributes['href']!.replaceAll(ApiConstant.bookList4Url, ''));
      });
    }
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
      _currentKey = buttonBean.value!;
      _refreshController.requestRefresh();
    }
  }

  _getBody() {
    return Column(
      children: [
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
              controller: _refreshController,
              enablePullDown: true,
              enablePullUp: true,
              header: WaterDropMaterialHeader(),
              footer: ClassicFooter(),
              onRefresh: () {
                _data.clear();
                _page = 1;
                getData();
              },
              onLoading: () {
                _page++;
                getData();
              },
              child: ListView.separated(
                  itemBuilder: getItem,
                  separatorBuilder: (BuildContext context, int index) {
                    return new Container(height: 1.0, color: Colors.grey);
                  },
                  itemCount: _data.length),
            ))
      ],
    );
  }

  Widget _getContent() {
    return widget.url.isEmpty? Scaffold(
      body: _getBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_btns.length > 0) {
            //有选项再显示
            _showDialog();
          }
        },
        child: Icon(Icons.menu),
      ),
    ):Scaffold(
      appBar: AppBar(title: Text('列表'),),
      body: _getBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_btns.length > 0) {
            //有选项再显示
            _showDialog();
          }
        },
        child: Icon(Icons.menu),
      ),
    );
  }
}
