import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_parse_html/model/movie_bean.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_parse_html/util/native_utils.dart';
import 'package:html/parser.dart' as parse;
import 'package:flutter_parse_html/util/escapeu_unescape.dart';
import 'package:flutter_parse_html/util/log_utils.dart';
import 'package:flutter_parse_html/net/net_util.dart';
import 'dart:convert' as convert;
import 'package:flutter_parse_html/ui/video_play.dart';

class MovieDetailPage extends StatefulWidget {
  int _type = 1;
  final MovieBean _movieBean;

  MovieDetailPage(this._type, this._movieBean);

  @override
  State<StatefulWidget> createState() {
    return MovieDetailState();
  }
}

class MovieDetailState extends State<MovieDetailPage> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            pinned: true,
            title: Text(widget._movieBean.name),
            expandedHeight: MediaQuery
                .of(context)
                .size
                .width * 1.2,
            flexibleSpace: FlexibleSpaceBar(
              background: CachedNetworkImage(
                imageUrl: widget._movieBean.imgUrl,
                fit: BoxFit.cover,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              color: Colors.white,
              child: Padding(
                padding: EdgeInsets.all(10),
                child: Column(
                  children: <Widget>[
                    Text(
                      widget._movieBean.info,
                      style: TextStyle(
                          height: 1.1,
                          fontSize: 13,
                          color: Colors.black54,
                          decoration: TextDecoration.none),
                    ),
                    Text(widget._movieBean.des,
                        style: TextStyle(
                            height: 1.1,
                            fontSize: 13,
                            color: Colors.black54,
                            decoration: TextDecoration.none))
                  ],
                ),
              ),
            ),
          ),
          SliverGrid.count(
            childAspectRatio: 2,
            crossAxisCount: 3,
            children: getWidgetList(),
          )
        ],
      ),
    );
  }

  getWidgetList() {
    List<Widget> list = List();
    for (var value in widget._movieBean.list) {
      list.add(Container(
        height: 20,
        color: Colors.white,
        child: Padding(
          padding: EdgeInsets.only(top: 10, bottom: 10, left: 20, right: 20),
          child: MaterialButton(
            color: Colors.blue,
            textColor: Colors.white,
            child: Text(value.name),
            onPressed: () {
              if (widget._type == 1) {
                goToPlay(value.targetUrl);
              } else if (widget._type == 2) {
                if (Platform.isAndroid) {
                  NativeUtils.toXfPlay(value.targetUrl);
                } else {
                  Clipboard.setData(new ClipboardData(text: value.targetUrl));
                }
              } else if (widget._type == 3) {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return VideoPlayPage(value.targetUrl);
                }));
              }
            },
          ),
        ),
      ));
    }
    return list;
  }

  void goToPlay(String targetUrl) async {
    var pageBody = await NetUtil.getHtmlData(targetUrl);
    var pageDocument = parse.parse(pageBody);
    String playData = pageDocument
        .getElementsByClassName('pl-l')
        .first
        .getElementsByTagName('script')
        .first
        .text;
    String data = playData.split('var player_data=')[1];
    LogUtils.d("json", "播放数据>>>${data}");
    var map = convert.json.decode(data);
    int encrypt = map['encrypt'];
    String playUrl = map['url'];
    if (playUrl.isNotEmpty) {
      if (encrypt == 1) {
        playUrl = EscapeUnescape.unescape(playUrl);
      } else {
        playUrl = EscapeUnescape.unescape(String.fromCharCodes(
            new Runes(convert.utf8.decode(convert.base64.decode(playUrl)))));
      }
      var itemElements = pageDocument
          .getElementsByClassName('stui-content__playlist clearfix')
          .first
          .getElementsByTagName('li');
    }
    if (playUrl.isNotEmpty) {
      Navigator.push(context, MaterialPageRoute(builder: (context) {
        return VideoPlayPage(playUrl);
      }));
    }
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate({
    @required this.minHeight,
    @required this.maxHeight,
    @required this.child,
  });

  final double minHeight;
  final double maxHeight;
  final Widget child;

  @override
  double get minExtent => minHeight;

  @override
  double get maxExtent => maxHeight;

  @override
  Widget build(BuildContext context, double shrinkOffset,
      bool overlapsContent) {
    return new SizedBox.expand(child: child);
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return maxHeight != oldDelegate.maxHeight ||
        minHeight != oldDelegate.minHeight ||
        child != oldDelegate.child;
  }
}
