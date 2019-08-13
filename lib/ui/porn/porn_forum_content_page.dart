import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_parse_html/util/porn_helper.dart';
import 'package:flutter_parse_html/model/porn_bean.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_parse_html/ui/parse/image_page.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
class PornForumContentPage extends StatefulWidget {
  final int _tid;

  PornForumContentPage(this._tid);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return PornForumContentState();
  }
}

class PornForumContentState extends State<PornForumContentPage> {

  PornForumContent _forumContent;
  bool _showLoading = true;
  Widget content;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    getData();
  }

  @override
  Widget build(BuildContext context) {
    content = _showLoading? SpinKitWave(color: Colors.blue,): Center(
      child: Stack(children: <Widget>[new CustomScrollView(
        shrinkWrap: true,
        // 内容
        slivers: <Widget>[
          new SliverPadding(
            padding: const EdgeInsets.all(20.0),
            sliver: new SliverList(
              delegate: new SliverChildListDelegate(
                <Widget>[
                  Html(data: _forumContent != null?_forumContent.content:""),
                ],
              ),
            ),
          ),
        ],
      ),],),
    );
    return Scaffold(
      appBar: AppBar(
        title: Text('帖子详情'),
      ),
      floatingActionButton: FloatingActionButton(onPressed: (){
        if(_forumContent != null){
          Navigator.pushNamed(context, "/ImagePage", arguments: {"list": _forumContent.imageList});
        }
      },
        child: Icon(Icons.image),
      ),
      body: content,
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

  void getData() async {
     _forumContent = await PornHelper.parsePornForumContent(widget._tid);
    setState(() {
      _showLoading = false;
    });
  }
}
