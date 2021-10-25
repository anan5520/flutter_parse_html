import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:flutter_parse_html/model/video_list_item.dart';
import 'package:flutter_parse_html/model/book_bean.dart';
import 'package:flutter_parse_html/net/net_util.dart';
import 'package:flutter_parse_html/api/api_constant.dart';
import 'package:unicorndial/unicorndial.dart';
import 'dart:convert';

import 'book_page.dart';
class BookList1Page extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return BookList1State();
  }
}

class BookList1State extends State<BookList1Page>
    with AutomaticKeepAliveClientMixin {
  String _currentKey = '1';
  int _page = 1;
  RefreshController _controller;
  List<Data> _data = [];
  Map<String,String> childBtnValues = {'都是激情':'1','人妻交换':'2','校园春色':'4','家庭乱伦':'5','武侠古典':'9','另类':'10',};
  List<UnicornButton> _childButtons;
  @override
  void initState() {
    _controller = new RefreshController(initialRefresh: true);
    initChildBtn();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      body: SmartRefresher(
        controller: _controller,
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
      ),
      floatingActionButton: UnicornDialer(
          backgroundColor: Color.fromRGBO(255, 255, 255, 0.6),
          parentButtonBackground: Colors.redAccent,
          orientation: UnicornOrientation.VERTICAL,
          parentButton: Icon(Icons.add),
          childButtons: _childButtons),
    );
  }

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget getItem(BuildContext context, int index) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context){
          return BookHomePage('${ApiConstant.bookList1Url}?action=bookfile&id=${_data[index].id}',1);
        }));
      },
      child: Padding(
        padding: EdgeInsets.only(top: 10,bottom: 10,left: 5,right: 5),
        child: Text('${_data[index].title}  (${_data[index].times})'),
      ),
    );
  }

  getData() async{
    String url = '${ApiConstant.bookList1Url}?action=list&pagesize=20&pageindex=$_page&type=$_currentKey';
    String response = await NetUtil.getHtmlData(url);
    BookList1Bean bookList1Bean = BookList1Bean.fromJson(json.decode(response));
    if(bookList1Bean.success){
      _data.addAll(bookList1Bean.data);
    }
    setState(() {
      _controller.refreshCompleted();
      _controller.loadComplete();
    });
  }

  void initChildBtn() {
    _childButtons = List<UnicornButton>();
    childBtnValues.forEach((key,value){
      _childButtons.add(UnicornButton(
          hasLabel: true,
          labelText: key,
          currentButton: FloatingActionButton(
            heroTag: key,
//            backgroundColor: Colors.redAccent,
            mini: true,
            child: Icon(Icons.directions_car),
            onPressed: () {
              _currentKey = value;
              _controller.requestRefresh();
            },
          )));
    });
  }
}
