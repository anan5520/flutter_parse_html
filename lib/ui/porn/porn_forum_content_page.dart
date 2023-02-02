import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_parse_html/model/heiliao_video_entity.dart';
import 'package:flutter_parse_html/ui/pornhub/pornhub_util.dart';
import 'package:flutter_parse_html/util/common_util.dart';
import 'package:flutter_parse_html/util/porn_helper.dart';
import 'package:flutter_parse_html/model/porn_bean.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_parse_html/ui/parse/image_page.dart';
import 'package:flutter_parse_html/util/ya_se_helper.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:html/parser.dart' as parse;

class PornForumContentPage extends StatefulWidget {
  final int _tid;
  final int _type;
  final String _url;

  PornForumContentPage(this._tid, this._type, this._url);

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
    content = _showLoading
        ? SpinKitWave(
            color: Colors.blue,
          )
        : Center(
            child: Stack(
              children: <Widget>[
                new CustomScrollView(
                  shrinkWrap: true,
                  // 内容
                  slivers: <Widget>[
                    new SliverPadding(
                      padding: const EdgeInsets.all(20.0),
                      sliver: new SliverList(
                        delegate: new SliverChildListDelegate(
                          <Widget>[
                            HtmlWidget(_forumContent != null
                                ? _forumContent.content
                                : ""),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
    return Scaffold(
      appBar: AppBar(
        title: Text('帖子详情'),
      ),
      body: Stack(
        children: [
          content,
          Positioned(
              bottom: 20,
              right: 20,
              child: Column(
            children: [
              MaterialButton(
                  color: Colors.blue,
                  textColor: Colors.white,
                  onPressed: () {
                    if (_forumContent != null) {
                      Navigator.pushNamed(context, "/ShowStaggeredImagePage",
                          arguments: {"list": _forumContent.imageList,'type':widget._type == 2?1:0});
                    }
                  },
                  child: Text('看图片')),
              Visibility(
                  visible:_forumContent != null &&  _forumContent.videoUrl != null && _forumContent.videoUrl.isNotEmpty,
                  child: MaterialButton(
                      color: Colors.blue,
                      textColor: Colors.white,
                      onPressed: () {
                        CommonUtil.toVideoPlay(_forumContent.videoUrl, context);
                      },
                      child: Text('看视频')))
            ],
          ))
        ],
      ),
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
    if (widget._type == 0) {
      _forumContent = await PornHelper.parsePornForumContent(widget._tid);
    } else if (widget._type == 1) {
      _forumContent = await YaSeHelper.parseAVContent(widget._url);
    } else if (widget._type == 2) {
      _forumContent = await getContent();
    }

    setState(() {
      _showLoading = false;
    });
  }

  getContent() {
    return PornHubUtil.getHtmlFromHttpDeugger(widget._url).then((value) {
      var doc = parse.parse(value);
      PornForumContent content = PornForumContent();
      content.content = doc.getElementById('post').outerHtml;
      try {
        List<String> imgs = [];
        doc
                  .getElementsByClassName('post-content')
                  .first
                  .getElementsByTagName('img')
                  .forEach((element) {
                imgs.add(element.attributes['data-src']);
              });
        content.imageList = imgs;
        var videoDataConfig =
                  doc.getElementsByClassName('dplayer').first.attributes['data-config'];
        HeiliaoVideoEntity videoEntity =
                  HeiliaoVideoEntity.fromJson(json.decode(videoDataConfig));
        content.videoUrl = videoEntity.video.url == null?'':videoEntity.video.url;
      } catch (e) {
        print(e);
      }
      return content;
    });
  }
}
