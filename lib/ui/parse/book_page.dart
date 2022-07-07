import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_parse_html/ui/pornhub/pornhub_util.dart';
import 'package:flutter_parse_html/widget/dialog_page.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parse;
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_parse_html/api/api_constant.dart';
import 'package:flutter_parse_html/net/net_util.dart';
import 'package:gbk2utf8/gbk2utf8.dart';

class BookHomePage extends StatefulWidget {
  var url;
  int type = 0;


  BookHomePage(this.url, this.type);

  @override
  State<StatefulWidget> createState() {
    return BookState(url);
  }
}

class BookState extends State<BookHomePage> {
  String content = '';
  var url;
  var showLoading = true;
  ScrollController _controller;
  BookState(this.url);

  @override
  void initState() {
    _controller = ScrollController();
    super.initState();
    if (widget.type == 0) {
      getData();
    } else if (widget.type == 1) {
      getBookList1Data();
    } else if (widget.type == 2) {
      getBookList2Data();
    } else if (widget.type == 3) {
      getData3();
    } else if (widget.type == 4) {
      getData4();
    } else if (widget.type == 5) {
      getData5();
    } else if (widget.type == 6) {
      getBookList4Data();
    } else if (widget.type == 7) {
      getBookList7Data();
    } else {
      getBookList3Data();
    }
  }

  @override
  Widget build(BuildContext context) {

    Widget contentWidge =
        widget.type == 1 || widget.type == 7 ? Text(content) : Html(data: content);
    return Scaffold(
      appBar: AppBar(
        title: Text('text'),
        leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            }),
      ),
      body: Center(
        child: Column(
          children: [
            Text('文字总数:${content.length}字'),
            Expanded(
              child: Stack(
                children: <Widget>[
                  new CustomScrollView(
                    controller: _controller,
                    shrinkWrap: true,
                    // 内容
                    slivers: <Widget>[
                      new SliverPadding(
                        padding: const EdgeInsets.all(20.0),
                        sliver: new SliverList(
                          delegate: new SliverChildListDelegate(
                            <Widget>[
                              contentWidge,
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  showLoading
                      ? SpinKitWave(
                          color: Colors.blue,
                        )
                      : Center()
                ],
              ),
            )
          ],
        ),
      ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            _showDialog();
          },
          child: Icon(Icons.menu),
        )
    );
  }

  void getData() async {
    var response = await http.get(url);
    Utf8Decoder utf8decoder = new Utf8Decoder();
    var body = utf8decoder.convert(response.bodyBytes);
    var document = parse.parse(body);
    var eles = document.getElementsByClassName("content");
    if (eles.length > 0) {
      content = document.getElementsByClassName("content").first.outerHtml;
    } else {
      content = document
          .getElementsByClassName("xs-details-content text-xs")
          .first
          .outerHtml;
    }

    setState(() {
      showLoading = false;
    });
  }
  void getData5() async {
    var body = await PornHubUtil.getHtmlFromHttpDeugger(url);
    var document = parse.parse(body);
    var eles = document.getElementsByClassName("content");
    if (eles.length > 0) {
      content = document.getElementsByClassName("content").first.outerHtml;
    } else {
      content = document
          .getElementsByClassName("xs-details-content text-xs")
          .first
          .outerHtml;
    }

    setState(() {
      showLoading = false;
    });
  }

  void getData3() async {
    var response = await http.get(url);
    var body = gbk.decode(response.bodyBytes);
    var document = parse.parse(body);
    content = document.getElementsByClassName("mainAreaBlack").first.outerHtml;
    setState(() {
      showLoading = false;
    });
  }

  void getData4() async {
    var response = await PornHubUtil.getHtmlFromHttpDeugger(url);
    var document = parse.parse(response);
    content = document.getElementsByClassName("nbodys").first.outerHtml;
    setState(() {
      showLoading = false;
    });
  }

  void getBookList1Data() async {
    var response = await http.get(url);
    content = gbk.decode(response.bodyBytes);
    content =
        content.replaceAll('&nbsp', '').replaceAll(new RegExp(r'(<br />)'), '');
    setState(() {
      showLoading = false;
    });
  }

  void getBookList2Data() async {
    var response = await http.get(url);
    Utf8Decoder utf8decoder = new Utf8Decoder();
    var body = utf8decoder.convert(response.bodyBytes);
    var document = parse.parse(body);
    content = document
        .getElementsByClassName("novel-view-page-content")
        .first
        .outerHtml;
    setState(() {
      showLoading = false;
    });
  }

  void getBookList3Data() async {
    var response = await http.get(url);
    Utf8Decoder utf8decoder = new Utf8Decoder();
    var body = utf8decoder.convert(response.bodyBytes);
    var document = parse.parse(body);
    content =
        document.getElementsByClassName("layout-box clearfix").first.outerHtml;
    setState(() {
      showLoading = false;
    });
  }

  void getBookList4Data() async {
    var body = await PornHubUtil.getHtmlFromHttpDeugger(url);
    var document = parse.parse(body);
    var articles = document.getElementsByClassName("articleList");
    articles.forEach((element) { 
      if(element.getElementsByClassName('nav nav-pills').length == 0){
        content = element.outerHtml;
      }
    });
    setState(() {
      showLoading = false;
    });
  }

  void getBookList7Data() async {
    var body = await PornHubUtil.getHtmlFromHttpDeugger(url);
    var document = parse.parse(body);
    var articles = document.getElementsByClassName("post-content-post").first;
    content = articles.text;
    setState(() {
      showLoading = false;
    });
  }

  void _showDialog() async {
    double progress = await showDialog(
        context: context,
        builder: (context) {
          return new AlertDialog(
            content: ProgressDialog(_controller.offset / _controller.position.maxScrollExtent),
          );
        });
      if(progress > 0){
        print("进度>>$progress");
        _controller.animateTo(_controller.position.maxScrollExtent * progress, duration: Duration(milliseconds: 500), curve: Curves.ease);
      }
  }
}
