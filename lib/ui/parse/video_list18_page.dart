import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_parse_html/book/base/util/utils_screen.dart';
import 'package:flutter_parse_html/model/video_list8_bean_entity.dart';
import 'package:flutter_parse_html/model/video_list_item.dart';
import 'package:flutter_parse_html/ui/movie/movie_detail_page.dart';
import 'package:flutter_parse_html/ui/parse/fan_hao_content_page.dart';
import 'package:flutter_parse_html/ui/porn/porn_forum_content_page.dart';
import 'package:flutter_parse_html/ui/pornhub/pornhub_util.dart';
import 'package:flutter_parse_html/util/aes_util.dart';
import 'package:flutter_parse_html/util/common_util.dart';
import 'package:flutter_parse_html/util/escapeu_unescape.dart';
import 'package:flutter_parse_html/util/files.dart';
import 'package:flutter_parse_html/util/native_utils.dart';
import 'package:flutter_parse_html/widget/fade_in_image_without_auth.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:flutter_parse_html/model/button_bean.dart';
import 'package:flutter_parse_html/net/net_util.dart';
import 'package:flutter_parse_html/api/api_constant.dart';
import 'package:html/parser.dart' as parse;
import 'package:flutter_parse_html/widget/dialog_page.dart';
import 'package:flutter_parse_html/model/movie_bean.dart';

class VideoList18Page extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return VideoList17State();
  }
}

class VideoList17State extends State<VideoList18Page>
    with AutomaticKeepAliveClientMixin {
  List<VideoListItem> _data = [];
  List<ButtonBean> _btns;

  RefreshController _refreshController;
  int _page = 1, buttonType = 0;
  String _currentKey = '';
  bool _isSearch = false;
  TextEditingController _editingController;
  StreamController<VideoListItem> imgeStream = StreamController.broadcast();

  @override
  void initState() {
    _refreshController = new RefreshController(initialRefresh: true);
    _editingController = new TextEditingController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      body: SmartRefresher(
        onRefresh: () {
          _page = buttonType == 1 ? _page : 1;
          _data.clear();
          _getData();
        },
        onLoading: () {
          _page++;
          _getData();
        },
        enablePullUp: true,
        enablePullDown: true,
        controller: _refreshController,
        child:ListView.builder(
          padding: EdgeInsets.all(10),
          itemBuilder: (BuildContext context, int index) {
            return getItem(index);
          },
          itemCount: _data.length,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_btns.length > 0) {
            //有选项再显示
            _showDialog();
          }
        },
        child: Icon(Icons.add),
      ),
    );
  }

  //跳转播放
  void goToPlay(VideoListItem data) async {
    showLoading();
    if(data.isVideo){
      var response = await PornHubUtil.getHtmlFromHttpDeugger(data.targetUrl);
      try {
        var doc = parse.parse(response);
        String playUrl = doc.getElementsByClassName('danmu').first.attributes['src'].split('url=')[1];
        Navigator.pop(context);
        if (playUrl.startsWith('http')) {
          CommonUtil.toVideoPlay(playUrl, context, title: data.title);
        }
      } catch (e) {
        Navigator.pop(context);
        print(e);
      }
    }else{
      Navigator.pop(context);
      Navigator.of(context).push(
          new MaterialPageRoute(builder: (BuildContext context) {
            return FanHaoContentPage(data.targetUrl);
          }));
    }

  }

  getItem(int index) {
    VideoListItem item = _data[index];
    _getImage(item,index);
    return Container(
      margin: EdgeInsets.only(top: 10),
      child: ClipRRect(
      borderRadius: BorderRadius.circular(5),
      child: GestureDetector(
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context){
            return PornForumContentPage(0,2,item.targetUrl);
          }));
        },
        child: Container(
          color: Colors.white,
          child: new Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Stack(
                alignment: Alignment.center,
                children: [
                  StreamBuilder<VideoListItem>(
                    builder: (context,snap){
                      return Container(height: (ScreenUtils.getScreenWidth() -20)/2,width: double.infinity,
                      child: item.index > -1? Image.file(
                        File(item.imageUrl),
                        gaplessPlayback: true,
                        fit: BoxFit.cover,
                      ):Image.asset('images/video_bg.png'),);
                    },stream: imgeStream.stream,initialData: item,),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Text(item.title,style: TextStyle(color: Colors.white,fontSize: 20),),)
                ],),
              Padding(
                padding: EdgeInsets.only(top: 4, bottom: 4, left: 3, right: 3),
                child: Text(
                  '${item.title}',
                  style: TextStyle(fontSize: 12),
                  maxLines: 2,
                ),
              )
            ],
          ),
        ),
      ),
    ),);
  }

  //获取数据
  void _getData() async {
    String url = _isSearch
        ? '${ApiConstant.videoList18Url}/page/$_page?s=$_currentKey'
        : "${ApiConstant.videoList18Url}/page/$_page";
    String response = await PornHubUtil.getHtmlFromHttpDeugger(url);
    _refreshController.refreshCompleted();
    _refreshController.loadComplete();
    var doc = parse.parse(response);
    try {
      var contentEle = doc.getElementById('index').getElementsByTagName('article');
      for (var value in contentEle) {
        var classStr = value.attributes['class'];
        if (classStr.isEmpty) {
          var aEle = value.getElementsByTagName('a').first;
          VideoListItem item = VideoListItem();
          var hrefs = aEle.attributes['href'];
          String href = hrefs;
          var imgEle = aEle.getElementsByClassName('post-card').first;
          var titleELe = value.getElementsByClassName('post-card-title').first;
          if(titleELe.getElementsByTagName('style').length > 0){
            titleELe.getElementsByTagName('style').first.remove();
          }
          item.title = CommonUtil.replaceStr(titleELe.text);
          item.isVideo = aEle.getElementsByClassName("thumb-video").length > 0;
          item.imageUrl = imgEle.attributes['data-url'];
          String s = await NetUtil.getHtmlData(item.imageUrl);
          item.targetUrl = href;
          _data.add(item);
        }
      }
      if (_btns == null) {
        _btns = [];
        var menus = doc.getElementsByClassName('sub-menu');
        menus.forEach((element) {
          element.getElementsByTagName('a').forEach((value1) {
            ButtonBean buttonBean = ButtonBean();
            buttonBean.title = value1.text;
            if (!value1.text.contains('区') && !value1.text.contains('会员')) {
              buttonBean.value =
                  value1.attributes['href'].replaceAll('.html', '');
              _btns.add(buttonBean);
            }
          });

        });
        _currentKey = _btns[0].value;
        _getData();
      }
    } catch (e) {
      print(e);
    }

    setState(() {});
  }

  void _showDialog() async {
    ButtonBean buttonBean = await showDialog(
        context: context,
        builder: (context) {
          return new AlertDialog(
            content: GridViewDialog(_btns),
          );
        });
    if (buttonBean != null) {
      if (buttonBean.type == 1) {
        _page = buttonBean.page;
        buttonType = 1;
      } else {
        _isSearch = false;
        buttonType = 0;
        _currentKey = buttonBean.value;
      }
      _refreshController.requestRefresh();
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

  @override
  bool get wantKeepAlive => true;
  _getImage(VideoListItem item,int index) async{
    Directory tempDir = await getTemporaryDirectory();
    var path = '${tempDir.path}/${md5.convert(new Utf8Encoder().convert(item.imageUrl))}';
    Widget image = await NetUtil.dio.download(item.imageUrl,path).then((value) async{
      var file = File(path);
      return await file.readAsBytes().then((value){
        String old = base64Encode(value);
        String base64 = EncryptUtil().aesDecode(old);
        file.writeAsBytes(base64Decode(base64)).then((value){
          item.index = index;
          imgeStream.sink.add(item..imageUrl = path);
        });
        return;
      });
    });
   return image;

  }

  @override
  void dispose() {
    imgeStream.close();
    super.dispose();
  }
}
