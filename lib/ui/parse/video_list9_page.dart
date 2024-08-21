import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_parse_html/model/Video9_list_bean.dart';
import 'package:flutter_parse_html/model/video9_cate_bean.dart';
import 'package:flutter_parse_html/model/video9_detail_bean.dart';
import 'package:flutter_parse_html/model/video_list_item.dart';
import 'package:flutter_parse_html/ui/movie/movie_detail_page.dart';
import 'package:flutter_parse_html/ui/pornhub/pornhub_util.dart';
import 'package:flutter_parse_html/util/aes_util.dart';
import 'package:flutter_parse_html/util/common_util.dart';
import 'package:flutter_parse_html/util/files.dart';
import 'package:flutter_parse_html/util/native_utils.dart';
import 'package:flutter_parse_html/widget/fade_in_image_without_auth.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:flutter_parse_html/model/button_bean.dart';
import 'package:flutter_parse_html/net/net_util.dart';
import 'package:flutter_parse_html/api/api_constant.dart';
import 'package:html/parser.dart' as parse;
import 'package:flutter_parse_html/widget/dialog_page.dart';
import 'package:flutter_parse_html/model/movie_bean.dart';

class VideoList9Page extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return VideoList9State();
  }
}

class VideoList9State extends State<VideoList9Page>
    with AutomaticKeepAliveClientMixin {
  List<VideoListItem> _data = [];
  List<ButtonBean>? _btns;

  late RefreshController _refreshController;
  int _page = 1,buttonType = 0;
  String _currentKey = '';
  bool _isSearch = false;
  late TextEditingController _editingController;

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
      body: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.all(10),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: Container(
                padding: EdgeInsets.only(left: 10, right: 4),
                alignment: Alignment.centerLeft,
                color: Colors.white,
                child: TextField(
                  maxLines: 1,
                  autofocus: false,
                  controller: _editingController,
                  textInputAction: TextInputAction.go,
                  onSubmitted: (value) {
                    _page = 1;
                    _currentKey = value;
                    _isSearch = true;
                    _refreshController.requestRefresh();
                  },
                  style: TextStyle(color: Colors.blue),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: "搜索",
                    hintStyle: TextStyle(color: Colors.blue),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: SmartRefresher(
              onRefresh: () {
                _page = buttonType == 1?_page:1;
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
              child: GridView.builder(
                padding: EdgeInsets.all(10),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 0.6,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10),
                itemBuilder: (BuildContext context, int index) {
                  return getItem(index);
                },
                itemCount: _data.length,
              ),
            ),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_btns?.isNotEmpty ??false) {
            //有选项再显示
            _showDialog();
          }
        },
        child: Icon(Icons.add),
      ),
    );
  }

  void goToPlay(VideoListItem data) async {
    showLoading();
    var response = await PornHubUtil.getHtmlFromJsonp(data.targetUrl!);
    try {
      var doc = parse.parse(response);
      String playUrl = doc.getElementsByTagName('iframe').first.attributes['src']!.split('url=')[1];
      Navigator.pop(context);
      if (playUrl.startsWith('http')) {
        CommonUtil.toVideoPlay(playUrl, context,title:data.title!);
      }
    } catch (e) {
      Navigator.pop(context);
      print(e);
    }
  }

  getItem(int index) {
    VideoListItem item = _data[index];
    return ClipRRect(
      borderRadius: BorderRadius.circular(5),
      child: GestureDetector(
        onTap: () {
          goToDetail(item);
        },
        child: Container(
          color: Colors.white,
          child: new Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Expanded(
                child: ConstrainedBox(
                  child:  new CachedNetworkImage(
                    imageUrl: item.imageUrl!,
                    placeholder: (e,u){
                      return Image.asset('images/video_bg.png');
                    },
                    fit: BoxFit.cover,
                  ),
                  constraints: new BoxConstraints.expand(),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 4, bottom: 4, left: 3, right: 3),
                child: Text(
                  '${item.title}',
                  style: TextStyle(fontSize: 12),
                  maxLines: 1,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  String categoryKey = '/api/v1/index/tagsandcategory';
  String videoListKey = '/api/v1/bmlist/video-list';
  String videoDetailKey = '/api/v1/top/info';
  String videoSearchKey = '/api/v1/bmlist/search';
  String videoTopListKey = '/api/v1/top/top-list-page';
  var header = {
    'authority':'g52gf12633.5g4k6htc.xyz',
    'accept':' */*',
    'accept-language': 'zh-CN,zh;q=0.9',
    'content-type': 'application/x-www-form-urlencoded',
    'origin': 'https://www.g768x.com',
    'referer': 'https://www.g768x.com',
    'sec-ch-ua': '"Not_A Brand";v="8", "Chromium";v="120", "Google Chrome";v="120"',
    'sec-ch-ua-mobile': '?0',
    'sec-ch-ua-platform': '"macOS"',
    'sec-fetch-dest': 'empty',
    'sec-fetch-mode': 'cors',
    'sec-fetch-site': 'cross-site',
  };
  //获取数据
  void _getData() async {
    var encryptUtil = EncryptUtil();
    if(!_isSearch && _currentKey.isEmpty){
      String url = "${ApiConstant.videoList9Url}$categoryKey";
      String response =  await NetUtil.getHtmlDataPost(url,paras: {'encrypt_data':"s8P0nRpxt8Vff+8ZzlLRhGbBoNuU/7HmFyfFH8bPrD0="},header: header);
      String responseStr = encryptUtil.aesDecode1(json.decode(response)['data']);
      Video9CateBean video9cateBean =  Video9CateBean.fromJson(json.decode(responseStr));
      _currentKey = video9cateBean.categoryList![0].id!;
      if (_btns == null) {
        _btns = [];
        for (var value1 in video9cateBean.categoryList!) {
          ButtonBean buttonBean = ButtonBean();
          buttonBean.title = String.fromCharCodes(new Runes(value1.name!));
          buttonBean.value = value1.id;
          _btns?.add(buttonBean);
        }
        ButtonBean buttonBean = ButtonBean();
        buttonBean.title = '头条';
        buttonBean.value = '头条';
        _btns?.add(buttonBean);
      }
    }
    String url = _isSearch
        ? '${ApiConstant.videoList9Url}$videoSearchKey'
        : "${ApiConstant.videoList9Url}${_currentKey == '头条'?videoTopListKey:videoListKey}";

    String searchData = '{"page":$_page,"keyword":"$_currentKey","pagesize":6,"plat":"pc","type":"video","filter":"allorder,alltime,allsecond,allrange,all","idList":"269250,270350,268016,267990,239320,244592,235000,270221,270231,270232,270243,270251,270253,270257,251452","token":""}';
    String encryData = EncryptUtil().aesEncode1(_isSearch?searchData:'{"page":$_page,"category":"$_currentKey","tags":"all","order":"new","pagesize":36,"plat":"pc","token":""}');
    String response =  await NetUtil.getHtmlDataPost(url,paras: {'encrypt_data':Uri.encodeFull(encryData)},header: header);
    _refreshController.refreshCompleted();
    _refreshController.loadComplete();
    String videoResponse = encryptUtil.aesDecode1(json.decode(response)['data']);
    Video9ListBean video9listBean =  Video9ListBean.fromJson(json.decode(videoResponse));
    try {
      for (var value in video9listBean.list!) {
        VideoListItem item = VideoListItem();
        item.title = value.title;
        item.imageUrl = value.thumbimg;
        item.targetUrl = value.id;
        _data.add(item);
      }

    } catch (e) {
      print(e);
    }

    setState(() {

    });
  }

  void _showDialog() async {
    ButtonBean buttonBean = await showDialog(
        context: context,
        builder: (context) {
          return new AlertDialog(
            content: GridViewDialog(_btns!),
          );
        });
    if (buttonBean != null) {
      if(buttonBean.type == 1){
        _page = buttonBean.page;
        buttonType = 1;
      }else{
        _isSearch = false;
        buttonType = 0;
        _currentKey = buttonBean.value!;
      }
      _refreshController.requestRefresh();
    }
  }

  void goToDetail(VideoListItem data) async {
    showLoading();
    String url = "${ApiConstant.videoList9Url}$videoDetailKey";
    String encryData = EncryptUtil().aesEncode1('{"id":"${data.targetUrl}","token":""}');
    String response =  await NetUtil.getHtmlDataPost(url,paras: {'encrypt_data':Uri.encodeFull(encryData)},header: header);
    var decRes = EncryptUtil().aesDecode1(json.decode(response)['data']);
    var detail = Video9DetailBean.fromJson(json.decode(decRes));
    // MovieBean movieBean = MovieBean();
    // try {
    //   var tbody = doc.getElementsByClassName('ibox').first;
    //   movieBean.imgUrl = tbody
    //       .getElementsByTagName('img')
    //       .first
    //       .attributes['src'];
    //   movieBean.info = tbody.getElementsByClassName('vodInfo').first.text;
    //   movieBean.name = data.title;
    //   movieBean.des = '';
    //   movieBean.originUrl = data.targetUrl;
    //   var vodplayinfo = doc.getElementsByClassName('vodplayinfo');
    //   vodplayinfo.forEach((element) {
    //     if(element.text.contains('.m3u8')){
    //       var playEles = element.getElementsByTagName('input');
    //       for (var value in playEles) {
    //         var title = value.attributes['value'];
    //         if(title.contains('.m3u8')){
    //           MovieItemBean itemBean = MovieItemBean();
    //           itemBean.name = '播放';
    //           itemBean.targetUrl = title;
    //           movieBean.list = [itemBean];
    //         }
    //       }
    //     }
    //   });
    //
    // } catch (e) {
    //   print(e);
    // }

    Navigator.pop(context);
    CommonUtil.toVideoPlay(detail.info!.urlS, context,title: data.title!);
    // Navigator.of(context)
    //     .push(new MaterialPageRoute(builder: (BuildContext context) {
    //   return MovieDetailPage(1, movieBean);
    // }));
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
}
