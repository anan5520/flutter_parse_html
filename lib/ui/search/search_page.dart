import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_parse_html/api/api_constant.dart';
import 'package:html/parser.dart' as parse;
import 'package:flutter_parse_html/model/search_bean.dart';
import 'package:flutter_parse_html/util/native_utils.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class SearchPage extends StatefulWidget {
  final String _key;

  SearchPage(this._key);

  @override
  State<StatefulWidget> createState() {
    return SearchSate();
  }
}

class SearchSate extends State<SearchPage> {
  TextEditingController controller = TextEditingController();
  List<SearchBean> _data = [];
  int _page = 1;

  RefreshController _refreshController;

  @override
  void initState() {
    _refreshController = new RefreshController(initialRefresh: true);
    controller.text = widget._key;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          autofocus: false,
          controller: controller,
          textInputAction: TextInputAction.go,
          onSubmitted: search,
          style: TextStyle(color: Colors.white),
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: "搜索",
            hintStyle: TextStyle(color: Colors.white),
          ),
        ),
      ),
      body: SmartRefresher(
        controller: _refreshController,
        enablePullDown: true,
        enablePullUp: true,
        onRefresh: () {
          _page = 1;
          _data.clear();
          search(widget._key);
        },
        onLoading: () {
          _page++;
          search(widget._key);
        },
        child: ListView.separated(
          itemBuilder: getItem,
          itemCount: _data.length,
          separatorBuilder: (BuildContext context, int index) {
            return new Container(height: 1.0, color: Colors.grey);
          },
        ),
      ),
    );
  }

  search(String value) async {
    var response =
        await http.get('${ApiConstant.searchUrl}$value&m=&f=_all&s=&p=$_page');
    Utf8Decoder utf8decoder = new Utf8Decoder();
    var html = utf8decoder.convert(response.bodyBytes);
    var doc = parse.parse(html);
    var elements = doc.getElementsByClassName('list-group-item');
    List<SearchBean> list = [];
    for (var value1 in elements) {
      SearchBean searchBean = new SearchBean();
      searchBean.title = value1.text;
      var aElements = value1.getElementsByTagName('a');
      for (var element in aElements) {
        String s = element.attributes['href'];
        if (s != null && s.isNotEmpty) {
          searchBean.magnet = s;
        }
      }
      if (searchBean.magnet != null) {
        list.add(searchBean);
      }
    }
    if (list.length <= 0) {
      var response1 = await http.get(ApiConstant.getNiMaUrl(value, _page));
      var html1 = utf8decoder.convert(response1.bodyBytes);
      var doc1 = parse.parse(html1);
      var elements1 = doc1.getElementsByClassName('x-item');
      for (var element in elements1) {
        SearchBean searchBean = SearchBean();
        searchBean.title = element.getElementsByTagName('div').first.text;
        searchBean.magnet = element
            .getElementsByClassName('tail')
            .first
            .getElementsByClassName('title')
            .first
            .attributes['href'];
        list.add(searchBean);
      }
    }
    _data.addAll(list);
    setState(() {
      _refreshController.refreshCompleted();
      _refreshController.loadComplete();
    });
  }

  Widget getItem(BuildContext context, int index) {
    SearchBean searchBean = _data[index];
    return GestureDetector(
      onTap: () {
        if (Platform.isAndroid) {
          NativeUtils.toAct(searchBean.magnet);
        } else {
          Clipboard.setData(new ClipboardData(text: searchBean.magnet));
//          Fluttertoast.showToast(
//              msg: "复制成功",
//              toastLength: Toast.LENGTH_SHORT,
//              gravity: ToastGravity.CENTER,
//              timeInSecForIos: 1,
//              backgroundColor: Colors.black,
//              textColor: Colors.white
//          );
        }
      },
      child: Padding(
        padding: EdgeInsets.all(10),
        child: Text(searchBean.title),
      ),
    );
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }
}
