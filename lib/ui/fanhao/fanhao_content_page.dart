import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_parse_html/model/video_list_item.dart';
import 'package:flutter_parse_html/ui/search/search_page.dart';
import 'package:flutter_parse_html/util/fanhao_helper.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:unicorndial/unicorndial.dart';
import 'fanhao_parse_page.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_parse_html/model/fanhao_bean.dart';

class FanHaoContentPage extends StatefulWidget {
  FanHaoType _type;
  final String _url;

  FanHaoContentPage(this._type, this._url);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return FanHaoContentState();
  }
}

class FanHaoContentState extends State<FanHaoContentPage> {
  FanHaoContent _forumContent;
  bool _showLoading = true;
  Widget content;
  List<UnicornButton> _childButtons;

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
                            Html(
                                data: _forumContent != null
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
        title: Text('详情'),
      ),
      floatingActionButton: UnicornDialer(
          backgroundColor: Color.fromRGBO(255, 255, 255, 0.6),
          parentButtonBackground: Colors.redAccent,
          orientation: UnicornOrientation.VERTICAL,
          parentButton: Icon(Icons.add),
          childButtons: _childButtons),
      body: content,
    );
  }

  void initChildBtn() {
    _childButtons = List<UnicornButton>();
    for (var value in _forumContent.items) {
      _childButtons.add(UnicornButton(
          hasLabel: true,
          labelText: value,
          currentButton: FloatingActionButton(
            heroTag: value,
//            backgroundColor: Colors.redAccent,
            mini: true,
            child: Icon(Icons.directions_car),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return SearchPage(value);
              }));
            },
          )));
    }
  }

  void getData() async {
    var response = await http.get(widget._url);
    Utf8Decoder utf8decoder = new Utf8Decoder();
    var html = utf8decoder.convert(response.bodyBytes);
    _forumContent = FanHaoHelper.parseFanHaoContent(widget._type, html);
    initChildBtn();
    setState(() {
      _showLoading = false;
    });
  }
}

class FanHao3List extends StatefulWidget {
  String _url;

  FanHao3List(this._url);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return FanHao3State();
  }
}

class FanHao3State extends State<FanHao3List> {
  List<VideoListItem> _data = [];

  @override
  void initState() {
    getData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('番号列表'),
        ),
        body: GridView.builder(
            itemCount: _data.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 0.6),
            itemBuilder: (context, index) {
              return new GestureDetector(
                onTap: () {
                  itemClick(_data[index]);
                },
                child: new Column(
                  children: <Widget>[
                    Expanded(
                      child: CachedNetworkImage(
                        placeholder: (context, url) => new Icon(Icons.image),
                        errorWidget: (context, url, error) =>
                            new Icon(Icons.error),
                        imageUrl: _data[index].imageUrl,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Text(
                      _data[index].title,
                      maxLines: 1,
                    )
                  ],
                ),
              );
            }));
  }

  void getData() async {
    var response = await http.get(widget._url);
    Utf8Decoder utf8decoder = new Utf8Decoder();
    var html = utf8decoder.convert(response.bodyBytes);
    var list = FanHaoHelper.parseFanHao3List('', html);
    _data.addAll(list);
    setState(() {});
  }

  void itemClick(VideoListItem data) {}
}
