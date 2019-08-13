import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_parse_html/model/video_list_item.dart';
import 'package:flutter_parse_html/ui/search/search_page.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:flutter_parse_html/util/fanhao_helper.dart';
import 'package:unicorndial/unicorndial.dart';

import 'fanhao_content_page.dart';

class FanHaoHomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return FanHaoHomeState();
  }
}

class FanHaoHomeState extends State<FanHaoHomePage>
    with SingleTickerProviderStateMixin {
  TabController _tabController;
  List<String> _titles;

  @override
  void initState() {
    _titles = ['番号1', '番号2', '番号3'];
    _tabController = new TabController(length: _titles.length, vsync: this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('番号'),
        bottom: TabBar(
          tabs: <Widget>[
            Tab(
              text: "${_titles[0]}",
            ),
            Tab(
              text: "${_titles[1]}",
            ),
            Tab(text: "${_titles[2]}")
          ],
          controller: _tabController,
        ),
      ),
      body: TabBarView(
        children: <Widget>[
          FanHaoPage(FanHaoType.fanHao1),
          FanHaoPage(FanHaoType.fanHao2),
          FanHaoPage(FanHaoType.fanHao3),
        ],
        controller: _tabController,
      ),
    );
  }
}

class FanHaoPage extends StatefulWidget {
  FanHaoType _type;

  FanHaoPage(this._type);

  @override
  State<StatefulWidget> createState() {
    return FanHaoState();
  }
}

class FanHaoState extends State<FanHaoPage> with AutomaticKeepAliveClientMixin {
  List<VideoListItem> _data = [];
  RefreshController _refreshController;
  List<String> typeName = [];
  List<String> typeValue = [];
  int _page = 1;
  String _currentKey;
  String _url;
  List<UnicornButton> _childButtons;

  @override
  void initState() {
    _refreshController = new RefreshController(initialRefresh: true);
    initValue();
    initChildBtn();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      body: SmartRefresher(
        controller: _refreshController,
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
        child: GridView.builder(
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
            }),
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

  void itemClick(VideoListItem data) {
    if (widget._type == FanHaoType.fanHao1) {
      Navigator.push(context, MaterialPageRoute(builder: (context) {
        return FanHaoContentPage(widget._type, data.targetUrl);
      }));
    } else if (widget._type == FanHaoType.fanHao3 && _currentKey == 'yo') {
      Navigator.push(context, MaterialPageRoute(builder: (context) {
        return FanHao3List(data.targetUrl);
      }));
    } else {
      if (widget._type == FanHaoType.fanHao2) {
        try {
          List<String> strings = data.title.split(new RegExp(r'[\[\]]'));
          String title = strings[2].trim();
          if (title == null || title.isEmpty) title = strings[3];
          if ("无修版" == title.trim() || "肉番动漫" == title.trim())
            title = strings[4];
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return SearchPage(title);
          }));
        } catch (e) {
          e.printStackTrace();
        }
      }else{
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return SearchPage(data.title);
        }));
      }

    }
  }

  void getData() async {
    List<VideoListItem> list;
    switch (widget._type) {
      case FanHaoType.fanHao1:
        list = await FanHaoHelper.getFanHao1List(_page);
        break;
      case FanHaoType.fanHao2:
        list = await FanHaoHelper.getFanHao2List(_currentKey, _page);
        break;
      case FanHaoType.fanHao3:
        list = await FanHaoHelper.getFanHao3List(_currentKey, _page);
        break;
    }
    if (list != null) _data.addAll(list);
    setState(() {
      _refreshController.refreshCompleted();
      _refreshController.loadComplete();
    });
  }

  void initChildBtn() {
    _childButtons = List<UnicornButton>();

    for (int i = 0; i < typeValue.length; i++) {
      String value = typeValue[i];
      _childButtons.add(UnicornButton(
          hasLabel: true,
          labelText: value,
          currentButton: FloatingActionButton(
            heroTag: typeName[i],
//            backgroundColor: Colors.redAccent,
            mini: true,
            child: Icon(Icons.directions_car),
            onPressed: () {
              _currentKey = value;
              _data.clear();
              getData();
            },
          )));
    }
  }

  void initValue() {
    switch (widget._type) {
      case FanHaoType.fanHao1:
        break;
      case FanHaoType.fanHao2:
        typeName = [
          "肉番",
          "里番",
        ];
        typeValue = [
          "13",
          "14",
        ];
        _currentKey = typeValue[0];
        break;
      case FanHaoType.fanHao3:
        typeName = [
          "首页",
          "女优",
        ];
        typeValue = [
          "ho",
          "yo",
        ];
        _currentKey = typeValue[0];
        break;
    }
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }
}

enum FanHaoType { fanHao1, fanHao2, fanHao3 }
