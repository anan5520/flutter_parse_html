import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_parse_html/api/api_constant.dart';
import 'package:flutter_parse_html/ui/pornhub/pornhub_util.dart';
import 'package:flutter_parse_html/util/native_utils.dart';
import 'package:flutter_parse_html/util/porn_helper.dart';
import 'package:flutter_parse_html/model/porn_bean.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_parse_html/ui/parse/image_page.dart';
import 'package:flutter_parse_html/util/ya_se_helper.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:html/parser.dart' as parse;
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';

class FanHaoContentPage extends StatefulWidget {
  final String _url;

  FanHaoContentPage(this._url);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return FanHaoContentState();
  }
}

class FanHaoContentState extends State<FanHaoContentPage> {
  late PornForumContent _forumContent;
  bool _showLoading = true;
  late Widget content;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    getData();
  }

  @override
  Widget build(BuildContext context) {
    content = _showLoading
        ? SpinKitWave(
            color: Colors.blue,
          )
        : Center(
            child: ListView.builder(
            itemBuilder: _getImageItem,
            itemCount: _forumContent.imageList!.length + _forumContent.ciLiList!.length + 1,
          ));
    return Scaffold(
      appBar: AppBar(
        title: Text('帖子详情'),
        actions: [
          TextButton(
            child: Text(
              '下载磁力软件',
              style: TextStyle(color: Colors.white, fontSize: 12),
            ),
            onPressed: () {
              NativeUtils.toBrowser('https://bbs.flashdown365.com');
            },
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_forumContent != null) {
            Navigator.pushNamed(context, "/ShowStaggeredImagePage",
                arguments: {"list": _forumContent.imageList});
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
    var response = await PornHubUtil.getHtmlFromHttpDeugger(widget._url);
    var doc = parse.parse(response);
    _forumContent = PornForumContent();
    var contentEle = doc.getElementsByClassName("article-content").first;
    _forumContent.imageList = [];
    contentEle.getElementsByTagName('img').forEach((element) {
      element.attributes['src'] =
          "${ApiConstant.videoList17Url}${element.attributes['src']}";
      _forumContent.imageList!.add(element.attributes['src']);
    });
    _forumContent.content =
        contentEle.getElementsByTagName('blockquote').first.text;
    _forumContent.ciLiList = [];

    try {
      var clililian = doc.getElementsByClassName("cililian")
          .first;
      var blocks = clililian
          .getElementsByTagName("blockquote");
      var scripts = clililian
          .getElementsByTagName("script");
      var ciliUrls = [];
      scripts.forEach((element) {
        if(element.text.contains('reurl')){
          ciliUrls.add(element.text.split(RegExp(r"reurl\('|'\)\)"))[1]);

      }});
      for(var i = 0;i < blocks.length;i ++){
        var element = blocks[i];
        var ciLiUrl = CiLiUrl();
        ciLiUrl.title = element.text;
        var jsStr =  ciliUrls[i];
        ciLiUrl.url = 'magnet:?xt=urn:btih:${_reurl(jsStr)}';
        _forumContent.ciLiList!.add(ciLiUrl);
      }

    } catch (e) {
      print(e);
    }

    setState(() {
      _showLoading = false;
    });
  }

  Widget _getImageItem(BuildContext context, int index) {
    if(index == 0){
      return Text(_forumContent.content!);
    }else if(index > 0 && index <= _forumContent.ciLiList!.length){
      var ciLiIndex = index - 1;
      var item = _forumContent.ciLiList![ciLiIndex];
      return GestureDetector(
        onTap: () {
          Fluttertoast.showToast(
              msg: '磁力链接已复制到粘贴板', toastLength: Toast.LENGTH_SHORT);
          Clipboard.setData(new ClipboardData(text: item.url!));
        },
        child: Padding(
          padding: EdgeInsets.only(top: 10, bottom: 10, left: 5, right: 5),
          child: Row(children: [ Text("点击复制磁力链接：",style: TextStyle(color: Colors.blue),),Text('${item.title}')],),
        ),
      );
    }else {
      var imageIndex = index - 1 - _forumContent.ciLiList!.length;
      return CachedNetworkImage(imageUrl: _forumContent.imageList![imageIndex]!);
    }

  }

  String _csplit(String a, String b,{c = ''}){
       var  intB = int.parse(b,radix: 10)|76;
        c = c | "\r\n";

        if(intB < 1){
          return "";
        }

        return a.replaceAll(RegExp(".{0," + b + "}"), "g");
  }

  String _reurl(String a){
    var b = '';
    for (var i = 0; i < 40; i++) {
      var start = i * 8;
      var end = start + 8;
      if(end <= a.length){
        var str = a.substring(start, end);
        b = b + String.fromCharCode((int.parse(str, radix: 2) - 10));
      }
    }
    return b;
  }
}
