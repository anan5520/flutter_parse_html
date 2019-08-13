import 'package:flutter/widgets.dart';
import 'package:flutter_parse_html/model/porn_bean.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_parse_html/net/net_util.dart';
import 'package:flutter_parse_html/api/api_constant.dart';
import 'package:flutter_parse_html/util/log_utils.dart';
import 'package:html/parser.dart' as parse;
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:flutter_parse_html/util/porn_helper.dart';
import 'package:flutter_parse_html/ui/video_play.dart';
import 'porn_video_detail.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'porn_forum_page.dart';
class PornPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return PornState();
  }
}

class PornState extends State<PornPage> with AutomaticKeepAliveClientMixin {
  List<PornItem> _data = [];
  int _page = 1;
  RefreshController _controller;

  @override
  void initState() {
    // TODO: implement initState
    _controller = new RefreshController(initialRefresh: true);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text('91'),
      ),
      floatingActionButton: FloatingActionButton(onPressed: (){
        Navigator.push(context, MaterialPageRoute(builder: (context){
          return PornForumPage();
        }));
      },child: Icon(Icons.forum),),
      body: SmartRefresher(
        header: WaterDropMaterialHeader(),
        footer: ClassicFooter(),
        enablePullDown: true,
        enablePullUp: true,
        controller: _controller,
        onRefresh: () {
          _page = 1;
          _data.clear();
          getData();
        },
        onLoading: () {
          _page++;
          getData();
        },
        child: ListView.builder(itemCount: _data.length, itemBuilder: getItem),
      ),
    );
  }

  Widget getItem(BuildContext context, int index) {
    PornItem item = _data[index];
    return GestureDetector(
      onTap: () async {
        showLoading();
        VideoResult videoResult = await PornHelper.parseVideoPage(item.viewKey);
        LogUtils.d('videoPage', videoResult.toString());
        Navigator.pop(context);
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return PornVideoDetailPage(videoResult);
        }));
      },
      child: Padding(
        padding: EdgeInsets.only(left: 10,right: 10,top: 5),
        child: Row(
          children: <Widget>[
            SizedBox(
              width: 160,
              height: 80,
              child: Padding(
                padding: EdgeInsets.only(right: 10),
                child: CachedNetworkImage(
                  imageUrl: item.imgUrl,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Expanded(
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(bottom: 5),
                    child: Text('${item.title}(${item.duration})',
                    style: TextStyle(color: Colors.blueAccent),),
                  ),
                  Text(item.info,
                  style: TextStyle(color: Colors.grey,fontSize: 11),)
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void getData() async {
    Map<String, dynamic> param = {'category': 'rf', 'page': '$_page'};
    String data =
        await NetUtil.getHtmlData(ApiConstant.getPornVideoUrl(), paras: param);
    LogUtils.d('porn', data);
    _data.addAll(parseByCategory(data));
    setState(() {
      _controller.loadComplete();
      _controller.refreshCompleted();
    });
  }

  List<PornItem> parseByCategory(String html) {
    List<PornItem> list = [];
    var document = parse.parse(html);
    var body = document.getElementById('fullside');
    var items = body.getElementsByClassName('listchannel');
    for (var value in items) {
      String title = value
          .querySelectorAll('a')
          .first
          .querySelectorAll('img')
          .first
          .attributes['title'];
      String imgUrl = value
          .querySelectorAll('a')
          .first
          .querySelectorAll('img')
          .first
          .attributes['src'];
      String contentUrl = value.querySelectorAll('a').first.attributes['href'];
      contentUrl = contentUrl.substring(0, contentUrl.indexOf('&'));
      String viewKey = contentUrl.substring(contentUrl.indexOf('=') + 1);
      String allInfo = value.text;
      int index = allInfo.indexOf('时长');
      String duration = allInfo.substring(index + 3, index + 8);
      String info = allInfo.substring(allInfo.indexOf('添加时间'));
      info = info.replaceAll('\n', '');
      info = info.replaceAll('\s', '');
      info = info.replaceAll('\t', '');
      info = info.replaceAll(' ', '').trim();
      PornItem pornItem = new PornItem(viewKey, title, imgUrl, duration, info);
      list.add(pornItem);
    }
    return list;
  }

  List<PornItem> parseHome(String html) {
    List<PornItem> list = [];
    var document = parse.parse(html);
    var body = document.getElementById('tab-featured');
    var items = body.querySelectorAll('p');
    for (var value in items) {
      String title = value.getElementsByClassName('title').first.text;
      String imgUrl = value.querySelectorAll('img').first.attributes['src'];
      String duration = value.getElementsByClassName('duration').first.text;
      String contentUrl = value.querySelectorAll('a').first.attributes['href'];
      String viewKey = contentUrl.substring(contentUrl.indexOf('=') + 1);
      String allInfo = value.text;
      String info = allInfo.substring(allInfo.indexOf('添加时间'));
      info = info.replaceAll('\n', '');
      info = info.replaceAll('\s', '');
      info = info.replaceAll('\t', '');
      info = info.replaceAll(' ', '').trim();
      PornItem pornItem = new PornItem(viewKey, title, imgUrl, duration, info);
      list.add(pornItem);
    }
    return list;
  }


  void showLoading() {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return SpinKitWave(
            color: Colors.blue,
          );
        });
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
