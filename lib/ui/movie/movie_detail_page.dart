import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_parse_html/model/YsgcVideoBean.dart';
import 'package:flutter_parse_html/model/movie_bean.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_parse_html/model/xian_feng6_bean_entity.dart';
import 'package:flutter_parse_html/ui/parse/webview_page.dart';
import 'package:flutter_parse_html/ui/pornhub/pornhub_util.dart';
import 'package:flutter_parse_html/util/common_util.dart';
import 'package:flutter_parse_html/util/native_utils.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:html/parser.dart' as parse;
import 'package:flutter_parse_html/util/escapeu_unescape.dart';
import 'package:flutter_parse_html/util/log_utils.dart';
import 'package:flutter_parse_html/net/net_util.dart';
import 'dart:convert' as convert;
import 'package:flutter_parse_html/ui/video_play.dart';
import 'package:flutter_parse_html/api/api_constant.dart';

import '../../util/toast_util.dart';
class MovieDetailPage extends StatefulWidget {
  int _type = 1;
  final MovieBean _movieBean;

  //type: 7里番
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
            title: Text(widget._movieBean.name!),
            expandedHeight: MediaQuery
                .of(context)
                .size
                .width * 1.2,
            flexibleSpace: FlexibleSpaceBar(
              background: CachedNetworkImage(
                imageUrl: widget._movieBean.imgUrl!,
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
                      widget._movieBean.info!,
                      style: TextStyle(
                          height: 1.1,
                          fontSize: 13,
                          color: Colors.black54,
                          decoration: TextDecoration.none),
                    ),
                    Text(widget._movieBean.des!,
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
    List<Widget> list = [];
    for (var value in widget._movieBean.list!) {
      list.add(Container(
        height: 20,
        color: Colors.white,
        child: Padding(
          padding: EdgeInsets.only(top: 10, bottom: 10, left: 20, right: 20),
          child: MaterialButton(
            color: Colors.blue,
            textColor: Colors.white,
            child: Text(value.name!),
            onPressed: () {
              widget._movieBean.number = value.name;
              if (widget._type == 1) {
                goToPlay(value.targetUrl!);
              } else if (widget._type == 2) {
                if (Platform.isAndroid) {
                  NativeUtils.startFromNativeLis(onEvent);
                  NativeUtils.toXfPlay(value.targetUrl!);
                } else {
                  Clipboard.setData(new ClipboardData(text: value.targetUrl!));
                }
              } else if (widget._type == 3) {
                getVideoUrlWithType3(value.targetUrl!);
              }else if (widget._type == 4) {
                getVideoUrlWithType4(value.targetUrl!);
              }else if (widget._type == 5) {
                getVideoUrlWithType5(value.targetUrl!);
              }else if (widget._type == 6) {
                getVideoUrlWithType6(value.targetUrl!);
              }else if (widget._type == 7) {
                getVideoUrlWithType7(value.targetUrl!);
              }else if (widget._type == 8) {
                getVideoUrlWithType8(value.targetUrl!);
              }else if (widget._type == 9) {
                getVideoUrlWithType9(value.targetUrl!);
              }else{
                CommonUtil.toVideoPlay(value.targetUrl, context);
              }
            },
          ),
        ),
      ));
    }
    return list;
  }

  void getVideoUrlWithType3(String url)async{
    print(url);
    showLoading();
    var pageBody = await NetUtil.getHtmlData(url);
    var strings =  pageBody.split(new RegExp(r'(playurl = "|\"\+hash)'));
    var urls = url.split('/player/');
    if(strings.length > 1 && urls.length > 1){
      String playUrl = strings[1];
      widget._movieBean.isM3u8 = true;
      Navigator.pop(context);
      CommonUtil.toVideoPlay(playUrl + urls[1], context);
    }
  }
  void getVideoUrlWithType4(String url)async{
    print(url);
    showLoading();
    var pageBody = await NetUtil.getHtmlData(url);
    var strings =  pageBody.split(new RegExp(r'(Player.Url = "|}else{)'));
    String playUrl = '';
    for (var value in strings) {
      value =  value.trim().replaceAll('\n', '').replaceAll("\t", '');
      if(value.startsWith('xf') && value.endsWith('";')){
        playUrl = value.replaceAll('";', '');
      }
    }
    Navigator.pop(context);
    if(playUrl.isNotEmpty ){
      if (Platform.isAndroid) {
        NativeUtils.startFromNativeLis(onEvent);
        NativeUtils.toXfPlay(playUrl);
      } else {
        Fluttertoast.showToast(msg: '已复制到粘贴板,打开先锋播放即可',toastLength: Toast.LENGTH_SHORT);
        Clipboard.setData(new ClipboardData(text: playUrl));
      }
    }
  }
  void getVideoUrlWithType5(String url)async{
    print(url);
    showLoading();
    var pageBody = await NetUtil.getHtmlData(url);
    var strings =  pageBody.split(new RegExp(r'(var nurl = "|";)'));
    String playUrl = '';
    for (var value in strings) {
      if(value.startsWith('xfplay'))
        playUrl = value;
    }
    Navigator.pop(context);
    if(playUrl.isNotEmpty ){
      if (Platform.isAndroid) {
        NativeUtils.startFromNativeLis(onEvent);
        NativeUtils.toXfPlay(playUrl);
      } else {
        Fluttertoast.showToast(msg: '已复制到粘贴板,打开先锋播放即可',toastLength: Toast.LENGTH_SHORT);
        Clipboard.setData(new ClipboardData(text: playUrl));
      }
    }
  }
  void getVideoUrlWithType6(String url)async{
    print(url);
    showLoading();
    var pageBody = await NetUtil.getHtmlData(url);
    var doc = parse.parse(pageBody);
    var content = doc.getElementsByClassName('playLeft').first.text.replaceAll('var ff_urls=\'', '').replaceAll('\';', '');
    var bean = XianFeng6BeanEntity.fromJson(convert.json.decode(content));
    var playUrl = bean.data![0].playurls![0][1];
    Navigator.pop(context);
    if(playUrl!.isNotEmpty ){
      if (Platform.isAndroid) {
        NativeUtils.startFromNativeLis(onEvent);
        NativeUtils.toXfPlay(playUrl);
      } else {
        Fluttertoast.showToast(msg: '已复制到粘贴板,打开先锋播放即可',toastLength: Toast.LENGTH_SHORT);
        Clipboard.setData(new ClipboardData(text: playUrl));
      }
    }
  }

  void getVideoUrlWithType7(String url)async{
    print(url);
    showLoading();
    var pageBody = await NetUtil.getHtmlData(url);
    var doc = parse.parse(pageBody);
    var playUrl = doc.getElementsByTagName('iframe').first.attributes['src']!.replaceAll('&zimu=', '').split('url=')[1];
    Navigator.pop(context);
    if(playUrl.isNotEmpty ){
      CommonUtil.toVideoPlay(playUrl, context);
    }
  }
  //player_aaaa= </script>
  void getVideoUrlWithType9(String url)async{
    print(url);
    showLoading();
    var pageBody = await NetUtil.getHtmlData(url);
    var urls = pageBody.split(RegExp(r'player_aaaa=|}</script>'));
    var jsonStr = '${urls[1]}}';
    YsgcVideoBean ysgcVideoBean = YsgcVideoBean.fromJson(json.decode(jsonStr));
    var key = await NetUtil.getHtmlData('${ApiConstant.movieBaseUrl}/static/player/ffzy.php?url=${ysgcVideoBean.url}');
    var playUrls = key.split(RegExp(r"urls = '|=';"));
    if(playUrls.length <= 2){
      playUrls = key.split(RegExp(r"urls = '|';"));
    }
    Navigator.pop(context);
    String tempPlayUrl = '';
    try {
      List<int> bytes = base64Decode('${playUrls[1]}=');
      tempPlayUrl = String.fromCharCodes(bytes);
    } catch (e) {
      print(e);
      List<int> bytes = base64Decode('${playUrls[1].substring(8)}');
      tempPlayUrl = String.fromCharCodes(bytes);
    }
    if(tempPlayUrl.contains('url=')){
      var playUrl = '${tempPlayUrl.split(RegExp(r'url=|\.m3u8'))[1]}.m3u8';
      if(playUrl.isNotEmpty ){
        CommonUtil.toVideoPlay(playUrl, context);
      }
    }else{
      var playUrl = 'https${tempPlayUrl.split(RegExp(r'https|\.m3u8'))[1]}.m3u8';
      if(playUrl.isNotEmpty ){
        CommonUtil.toVideoPlay(playUrl, context);
      }
    }


  }

  void getVideoUrlWithType8(String url)async{
    print(url);
    showLoading();
    var pageBody = await PornHubUtil.getHtmlFromHttpDeugger(url);
    var playUrls = pageBody.split(RegExp(r'var now=unescape\(\"|.m3u8'));
    Navigator.pop(context);
    if(playUrls.length > 0){
      var playUrl = '${EscapeUnescape.unescape(playUrls[1])}.m3u8';
      if(playUrl.isNotEmpty ){
        CommonUtil.toVideoPlay(playUrl, context);
      }
    }

  }

  void goToPlay(String targetUrl) async {
    String playUrl = '';
    if(targetUrl.contains('.mp4')||targetUrl.contains('.m3u8')||!targetUrl.contains("4k")){
      playUrl = targetUrl;
    }else{
      var pageBody = await NetUtil.getHtmlData(targetUrl);
      var pageDocument = parse.parse(pageBody);
      String playData = pageDocument
          .getElementsByClassName('embed-responsive clearfix')
          .first
          .getElementsByTagName('script')
          .first
          .text;
      if(playData.contains('.m3u8')){
        String data = playData.split(new RegExp(r'now="|.m3u8'))[1];
        LogUtils.d("json", "播放数据>>>${data}");
        playUrl = '$data.m3u8';
      }else{
        ToastUtils.showToast("获取播放地址失败");
      }
      // if (playUrl.isNotEmpty) {
      //   // if (encrypt == 1) {
      //   //   playUrl = EscapeUnescape.unescape(playUrl);
      //   // } else {
      //   //   playUrl = EscapeUnescape.unescape(String.fromCharCodes(
      //   //       new Runes(convert.utf8.decode(convert.base64.decode(playUrl)))));
      //   // }
      //   var itemElements = pageDocument
      //       .getElementsByClassName('stui-content__playlist clearfix')
      //       .first
      //       .getElementsByTagName('li');
      // }
    }

    if (playUrl.isNotEmpty) {
      CommonUtil.toVideoPlay(playUrl,context);
    }
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

  void onEvent(dynamic event) {
    AlertDialog(
      title: Text('提示'),
      content: Text('没有安装影音先锋，是否安装'),
      contentPadding: EdgeInsets.all(10),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            NativeUtils.toBrowser(ApiConstant.xianFengDownUrl);
          },
          child: Text(
            "是",
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    NativeUtils.cancelFromNativeLis();
    super.dispose();
  }
}

