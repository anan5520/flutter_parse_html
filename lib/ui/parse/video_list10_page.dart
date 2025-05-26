import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_parse_html/model/video_list_item.dart';
import 'package:flutter_parse_html/ui/movie/movie_detail_page.dart';
import 'package:flutter_parse_html/ui/pornhub/pornhub_util.dart';
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
import 'package:http/http.dart' as http;
import 'package:encrypt/encrypt.dart' as encrypt;
import '../../model/api_bean.dart';
import '../../resources/shared_preferences_keys.dart';
import '../../util/shared_preferences.dart'; // 导入http包
class VideoList10Page extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return VideoList10State();
  }
}

class VideoList10State extends State<VideoList10Page>
    with AutomaticKeepAliveClientMixin {
  List<VideoListItem> _data = [];
  List<ButtonBean>? _btns;

  late RefreshController _refreshController;
  int _page = 1, buttonType = 0;
  String _currentKey = '/theme/detail/3/update';
  bool _isTheme = true;
  bool _isSearch = false;
  late TextEditingController _editingController;
  StreamController<String> imgeStream = StreamController.broadcast();
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
      body: Container(
        color: Color(0xffeeeeee),
        child: Column(
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
                      _isTheme = false;
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
                child: GridView.builder(
                  padding: EdgeInsets.all(10),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      childAspectRatio: 0.6,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10),
                  itemBuilder: (BuildContext context, int index) {
                    return StreamBuilder(stream: imgeStream.stream, builder: (_,snap){
                      return getItem(index);
                    });
                  },
                  itemCount: _data.length,
                ),
              ),
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_btns?.isNotEmpty == true) {
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
    var response = await NetUtil.getHtmlData(data.targetUrl!);
    try {
      var urls = response.split(RegExp(r'hlsUrl = "|";'));
      var playUrl = urls[1];
      Navigator.pop(context);
      if (playUrl?.startsWith('http') == true) {
        CommonUtil.toVideoPlay(playUrl, context, title: data.title!);
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
          goToPlay(item);
        },
        child: Container(
          color: Colors.white,
          child: new Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Expanded(
                child: ConstrainedBox(
                  child: item.index !> -1
                      ? Image.file(
                    File(item.base64Img!),
                    gaplessPlayback: true,
                    fit: BoxFit.cover,
                  )
                      : Image.asset('images/video_bg.png'),
                  constraints: new BoxConstraints.expand(),
                ),
              ),
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
    );
  }

  //获取数据
  void _getData() async {
    String url = _isSearch
        ? '${ApiConstant.videoList10Url}/search/${Uri.encodeComponent(_currentKey)}/${_page}'
        : _currentKey.isNotEmpty?"${ApiConstant.videoList10Url}$_currentKey${_isTheme?'/${_page}':'/page/${_page}'}":"${ApiConstant.videoList10Url}$_currentKey";
    String response = await NetUtil.getHtmlData(url);
    _refreshController.refreshCompleted();
    _refreshController.loadComplete();
    var doc = parse.parse(response);
    try {
      var rootEle = doc.getElementById('list_videos_common_videos_list');
      if(rootEle == null){
       rootEle = doc.getElementById('site-content');
      }
      var listEle = rootEle?.getElementsByClassName("col-6 col-sm-4 col-lg-3");
      listEle?.forEach((ele){
        var aEle = ele.getElementsByTagName("a").first;
        VideoListItem item = VideoListItem();
        var hrefs = aEle.attributes['href'];
        String href = '${ApiConstant.videoList10Url}$hrefs';
        var imgEle = aEle.getElementsByTagName('img').first;
        item.title = imgEle.attributes['alt'];
        item.imageUrl = imgEle.attributes['z-image-loader-url'];
        item.targetUrl = href;
        _data.add(item);
      });

      _btns = [];
      var menu = doc.getElementsByClassName('col-6 col-sm-4 col-lg-3 mb-3');
      _btns?.add(ButtonBean()..title = "中文字幕"..value = "/theme/detail/3/update"..isTheme = true);
      _btns?.add(ButtonBean()..title = "角色剧情"..value = "/theme/detail/2/update"..isTheme = true);
      _btns?.add(ButtonBean()..title = "主奴"..value = "/theme/detail/7/update"..isTheme = true);
      _btns?.add(ButtonBean()..title = "制服"..value = "/theme/detail/4/update"..isTheme = true);
      for (int i = 0; i < menu.length; i++) {
        var value1 = menu[i].getElementsByTagName("a").first;
        ButtonBean buttonBean = ButtonBean();
        buttonBean.title = value1.text;
        if (!value1.text.contains('区') && !value1.text.contains('会员')) {
          buttonBean.value =
              value1.attributes['href'];
          _btns?.add(buttonBean);
        }
      }
    } catch (e) {
      print(e);
    }

    setState(() {
      for(int i = 0;i<_data.length;i++){
        _getSiseImage(_data[i],i);
      }
    });
  }

  _getSiseImage(VideoListItem item, int index) async {
    String url = item?.imageUrl??'';
    Directory tempDir = await getTemporaryDirectory();
    var path = '${tempDir.path}/${md5.convert(new Utf8Encoder().convert(url))}';
    if(await File(path).exists()){
      item.index = index;
      item.base64Img = path;
      imgeStream.sink.add(url);
    }else{
      http.get(Uri.parse(url)).then((response) {
        if (response.statusCode == 200) {
          String base64Image = base64Encode(response.bodyBytes);
          String decryptedBase64 = _decryptImage(base64Image);
          new File(path).writeAsBytes(base64Decode(decryptedBase64)).then((value) {
            item.index = index;
            item.base64Img = path;
            imgeStream.sink.add(url);
          });

        } else {

        }

      });
    }

  }

  String _decryptImage(String base64Image) {
    final key = encrypt.Key.fromUtf8("102_53_100_57_54_53_100_102_55_53_51_51_54_50_55_48".split("_").map((e) => String.fromCharCode(int.parse(e))).join(""));
    final iv = encrypt.IV.fromUtf8("57_55_98_54_48_51_57_52_97_98_99_50_102_98_101_49".split("_").map((e) => String.fromCharCode(int.parse(e))).join(""));

    final encrypter = encrypt.Encrypter(encrypt.AES(key, mode: encrypt.AESMode.cbc, padding: null));
    final decrypted = base64Encode(encrypter.decryptBytes(encrypt.Encrypted.fromBase64(base64Image), iv: iv));

    return decrypted;
  }


  // 合并后的方法，返回重定向的URL
  Future<String> _startRedirectProcess() async {
    // 获取当前URL并修改主机名
    String currentUrl = ApiConstant.videoList10Url;
    String referrer1 = Uri.parse(ApiConstant.videoList10Url).host;
    String modifiedReferrer = referrer1.replaceAll('.', '');

    // 获取当前时间的日期和秒
    DateTime now = DateTime.now();
    String date = now.day.toString();
    String second = now.hour.toString();

    // 延迟3秒后开始执行重定向逻辑
    await Future.delayed(Duration(seconds: 3));

    // 检查网站是否可用并返回重定向的URL
    String redirectUrl = await _checkWebsitesAvailability(modifiedReferrer, date, second);

    return redirectUrl;
  }

  // 检查网站可用性并返回最终重定向的URL
  Future<String> _checkWebsitesAvailability(String modifiedReferrer, String date, String second) async {
    List<Map<String, dynamic>> websites = [
      {
        'url': 'http://$date$second${Uri.encodeComponent(modifiedReferrer)}.linhe99.cfd/',
      },
      {
        'url': 'http://$date$second${Uri.encodeComponent(modifiedReferrer)}.wuhai11.cfd/',
      },
    ];

    int failed = 0;

    // 遍历检查每个网站
    for (var site in websites) {
      bool isOnline = await _checkWebsiteOnline(site['url']);
      if (isOnline) {
        // 如果网站可用，返回重定向URL
        return site['url'];
      } else {
        failed++;
        if (failed == websites.length) {
          // 如果所有网站都不可用，返回备用URL
          return "";
        }
      }
    }

    // 默认返回备用URL
    return "";
  }

  // 检查一个网站是否在线，返回结果
  Future<bool> _checkWebsiteOnline(String url) async {
    try {
      // 发送GET请求来检测网站是否可用
      final response = await http.get(Uri.parse(url));

      // 如果响应的状态码是200，表示网站在线
      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      // 捕获异常，表示网站无法访问
      return false;
    }
  }


  void _showDialog() async {
    ButtonBean buttonBean = await showDialog(
        context: context,
        builder: (context) {
          return new AlertDialog(
            content: GridViewDialog(_btns??[]),
          );
        });
    if (buttonBean != null) {
      if (buttonBean.type == 1) {
        _page = buttonBean.page;
        buttonType = 1;
      } else {
        _isSearch = false;
        buttonType = 0;
        _currentKey = buttonBean.value!;
        _isTheme = buttonBean.isTheme;
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
}
