import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_parse_html/util/common_util.dart';
import 'package:flutter_parse_html/util/porn_helper.dart';
import 'package:flutter_parse_html/model/porn_bean.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_parse_html/ui/parse/image_page.dart';
import 'package:flutter_parse_html/util/ya_se_helper.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
class AbjForumContentPage extends StatefulWidget {
  final int _tid;
  final int _type;
  final String _url;


  AbjForumContentPage(this._tid, this._type, this._url);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return AbjForumContentState();
  }
}

class AbjForumContentState extends State<AbjForumContentPage> {

  PornForumContent _forumContent;
  Widget content;

  RefreshController _refreshController;
  List<VideoComment> _data = [];
  int _page = 1;
  @override
  void initState() {
    _refreshController = RefreshController(initialRefresh: true);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('帖子详情'),
      ),
      floatingActionButton: FloatingActionButton(onPressed: (){
        if(_forumContent != null){
          Navigator.pushNamed(context, "/ShowStaggeredImagePage", arguments: {"list": _forumContent.imageList});
        }
      },
        child: Icon(Icons.image),
      ),
      body: getCommentWidget(),
    );
  }
//  @override
//  Widget build(BuildContext context) {
//    // TODO: implement build
//    return WebviewScaffold(
//      appBar: AppBar(
//        title: Text('帖子详情'),
//      ),
//      withJavascript: true,
//      allowFileURLs: true,
//      appCacheEnabled: true,
//      hidden: true,
////      url: '${ApiConstant.getPornForumContentUrl()}?tid=${widget._tid}' ,
//      url: _content,
//      withLocalUrl: true,
//    );
//  }

  Widget getCommentWidget() {
    return SmartRefresher(
      enablePullUp: true,
      enablePullDown: true,
      onRefresh: () {
        _page = 1;
        _data.clear();
        getData();
      },
      onLoading: () {
        _page++;
        getData();
      },
      controller: _refreshController,
      child: ListView.separated(
          itemBuilder: (context, index) {
            VideoComment videoComment = _data[index];
            return index == 0?HtmlWidget( videoComment.pornForumContent != null?videoComment.pornForumContent.content:""): Padding(
              padding: EdgeInsets.all(5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(bottom: 5, top: 5),
                    child: Text(
                      '${CommonUtil.replaceStr(videoComment.uName == null?'':videoComment.uName)}----'
                          '${CommonUtil.replaceStr(videoComment.replyTime == null?'':videoComment.replyTime)}',
                      style: TextStyle(color: Colors.blueAccent),
                    ),
                  ),
                  Text(CommonUtil.replaceStr(videoComment.content == null?'':videoComment.content))
                ],
              ),
            );
          },
          separatorBuilder: (BuildContext context, int index) {
            return new Container(height: 1.0, color: Colors.grey);
          },
          itemCount: _data.length),
    );
  }

  void getData() async {

    var list = await YaSeHelper.parseAbjContent(widget._url,_page);
    _data.addAll(list);
    _forumContent = _data[0].pornForumContent;
    setState(() {
      _refreshController.refreshCompleted();
      _refreshController.refreshCompleted();
    });
  }
}
