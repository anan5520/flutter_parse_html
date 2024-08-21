import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'package:byte_util/byte_util.dart';
import 'package:crypto/crypto.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_parse_html/model/api_bean.dart';
import 'package:flutter_parse_html/model/sise_search_entity.dart';
import 'package:flutter_parse_html/model/video_list_item.dart';
import 'package:flutter_parse_html/resources/shared_preferences_keys.dart';
import 'package:flutter_parse_html/ui/movie/movie_detail_page.dart';
import 'package:flutter_parse_html/ui/pornhub/pornhub_util.dart';
import 'package:flutter_parse_html/util/common_util.dart';
import 'package:flutter_parse_html/util/escapeu_unescape.dart';
import 'package:flutter_parse_html/util/files.dart';
import 'package:flutter_parse_html/util/native_utils.dart';
import 'package:flutter_parse_html/util/shared_preferences.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:flutter_parse_html/model/button_bean.dart';
import 'package:flutter_parse_html/net/net_util.dart';
import 'package:flutter_parse_html/api/api_constant.dart';
import 'package:html/parser.dart' as parse;
import 'package:flutter_parse_html/widget/dialog_page.dart';
import 'package:flutter_parse_html/model/movie_bean.dart';
import 'package:encrypt/encrypt.dart' as Encrypt;
import 'package:http/http.dart' as http;

class VideoList8Page extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return VideoList8State();
  }
}

class VideoList8State extends State<VideoList8Page>
    with AutomaticKeepAliveClientMixin {
  List<VideoListItem> _data = [];
  List<ButtonBean>? _btns;
  List<ButtonBean> _tags = [];
  List<ButtonBean>? _commonBtns;

  late RefreshController _refreshController;
  int _page = 1,
      buttonType = 0;
  String _currentKey = '/index/home.html';
  String _nextKey = '';
  String _searchTag = 'jingpin';
  bool _isSearch = false;
  late TextEditingController _editingController;
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
          Visibility(
            visible: _tags != null && _tags.isNotEmpty,
              child: Padding(
            padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
            child: GridView.count(
              shrinkWrap: true,
              childAspectRatio: 2.5,
              crossAxisCount: 4,
              mainAxisSpacing: 5,
              crossAxisSpacing: 5,
              children: getTagItem(context),
            ),
          )),
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
          if (_btns?.isNotEmpty ?? false) {
            //有选项再显示
            _showDialog();
          }
        },
        child: Icon(Icons.add),
      ),
    );
  }

  @override
  void dispose() {
    imgeStream.close();
    super.dispose();
  }

  void goToPlay(VideoListItem data) async {
    showLoading();
    var response = await PornHubUtil.getHtmlFromHttpDeugger(data.targetUrl!);
    try {
      var doc = parse.parse(response);
      var playUrl = '';
      doc.getElementsByTagName('script').forEach((element) {
        if (element.text.contains('m3u8')) {
          playUrl = CommonUtil.replaceStr(element.text
              .replaceAll(RegExp(r"var|video|=|m3u8_host1|m3u8_host"), '')
              .replaceAll("decodeString('", '')
              .replaceAll("')", '')
              .trim());
          var urls = playUrl.replaceAll(' ', '').split(';');
          var hostBase64 = padBase64(urls[1]);
          var host = String.fromCharCodes(base64Decode(hostBase64));

          var url = String.fromCharCodes(base64Decode(padBase64(urls[0])));
          playUrl = '$host$url';
        }
      });
      Navigator.pop(context);
      if (playUrl.startsWith('http')) {
        CommonUtil.toVideoPlay(playUrl, context, title: data.title!);
      }
    } catch (e) {
      Navigator.pop(context);
      print(e);
    }
  }

  String padBase64(String rawBase64) {
    if (rawBase64.length % 4 != 0) {
      rawBase64 += "=";
      return padBase64(rawBase64);
    } else {
      return rawBase64;
    }
  }

  getTagItem(BuildContext context) {
    List<Widget> list = [];
    if(_tags == null)
      return list;
    for (ButtonBean value in _tags) {
      list.add(SizedBox(
        width: 10,
        height: 5,
        child: MaterialButton(
          height: 4,
          padding: EdgeInsets.all(0),
          onPressed: () {
            if(_isSearch){
              _searchTag = value.value!;
            }else{
              _currentKey = value.value!;
            }
            _refreshController.requestRefresh();
          },
          color: Colors.blue,
          child: Text(value.title!,
              maxLines: 1,
              style: TextStyle(
                  fontSize: 13,
                  color: Colors.white,
                  decoration: TextDecoration.none)),
          textColor: Colors.black,
        ),
      ));
    }
    return list;
  }

  getItem(int index) {
    VideoListItem item = _data[index];
    _getImageBase64(item, index);
    return ClipRRect(
      borderRadius: BorderRadius.circular(5),
      child: GestureDetector(
        onTap: () {
          if(item.isVideo!){
            goToPlay(item);
          }else{
            goToDetail(item);
          }
        },
        child: Container(
          color: Colors.white,
          child: new Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Expanded(
                child: ConstrainedBox(
                  child: StreamBuilder<VideoListItem>(
                    builder: (_, _snap) {
                      return item.index !> -1
                          ? Image.file(
                        File(item.imageUrl!),
                        gaplessPlayback: true,
                        fit: BoxFit.cover,
                      )
                          : Image.asset('images/video_bg.png');
                    },
                    stream: imgeStream.stream,
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

  //获取数据
  void _getData() async {
    if (_isSearch) {
      searchData();
      return;
    }
    String url = _isSearch
        ? '${ApiConstant
        .videoList8Url}/search/video/?s=$_currentKey&page=$_page'
        : "${ApiConstant.videoList8Url}${_page > 1 ? _nextKey : _currentKey}";
    String response = await NetUtil.getHtmlData(url);
    _refreshController.refreshCompleted();
    _refreshController.loadComplete();
    var doc = parse.parse(response);
    try {
      var tdElements = doc.getElementsByClassName('video-list');
      if(tdElements.length == 0){
        _resetUrl(url);
        return;
      }
      var imageBaseUrls = response.split(RegExp(r"var pic_image_url = '|';"));
      var imgBaseUrl = 'https://base.jingmin.wang/';
      if(imageBaseUrls.length > 1){
        imgBaseUrl = imageBaseUrls[1];
      }
      for (var value in tdElements) {
        var aEles = value.getElementsByClassName('video-item');
        aEles.forEach((aEle) {
          VideoListItem item = VideoListItem();
          var hrefTemp = aEle.attributes['href'];
          String href = '${ApiConstant.videoList8Url}$hrefTemp';
          var imgEle = aEle
              .getElementsByTagName('img')
              .first;
          item.title = CommonUtil.replaceStr(aesEncode(aEle
              .getElementsByClassName('video-item-title dec-ti')
              .first
              .attributes['title']!));
          if(imgEle.attributes.containsKey('data-pic-base64')){
            item.isVideo = false;
            item.imageUrl = _getImgUrl(imgBaseUrl,imgEle.attributes['data-pic-base64']!);
          }else{
            item.isVideo = true;
            item.imageUrl = _getImgUrl(imgBaseUrl,imgEle.attributes['data-base64']!);
          }

          item.targetUrl = href;
          _data.add(item);
        });
      }
      var nextEles = doc.getElementsByClassName('pagination');
      if (nextEles.length > 0) {
        try {
          nextEles.first.getElementsByTagName('a').forEach((element) {
            if (element.attributes['title'] == '下一页') {
              _nextKey = element.attributes['href']!;
            }
          });
        } catch (e) {
          print(e);
        }
      }
      _btns = [];
      _tags = [];
      var cates = doc.getElementsByClassName('category-list');
      if (cates.length > 0) {
        var aEles = cates.first.getElementsByTagName('a');
        aEles.forEach((element) {
          ButtonBean buttonBean = ButtonBean();
          buttonBean.title = aesEncode(element.attributes['title']!);
          buttonBean.value = aesEncode(element.attributes['data-link']!);
          _tags.add(buttonBean);
        });
      }
      if (_commonBtns == null) {
        _commonBtns = [];
        var menu = doc
            .getElementsByClassName('menu-common')
            .first;
        var liEles = menu.getElementsByTagName('div');
        liEles.forEach((element) {
          ButtonBean buttonBean = ButtonBean();
          buttonBean.title = aesEncode(element.attributes['title']!);
          buttonBean.value = aesEncode(element.attributes['onclick']
              !.replaceAll("onMenuItemClick('", '')
              .replaceAll("')", ''));
          _commonBtns?.add(buttonBean);
        });
      }
      _btns?.addAll(_commonBtns!);
    } catch (e) {
      print(e);
    }

    setState(() {});
  }


  void searchData() async {
    String url = '${ApiConstant.videoList8Url}/cYc${encodeString(
        '/search/$_searchTag-$_currentKey-$_page.html')}.html';
    String response = await NetUtil.getHtmlData(url);
    _refreshController.refreshCompleted();
    _refreshController.loadComplete();
    _tags = [];
    var cates = {'剧情':'juqing','视频':'shipin','精品':'jingpin','图片':'tupian','美女':'meinv','小说':'xiaoshuo','有声':'yousheng'};
    if (cates.length > 0) {
      cates.forEach((key, value) {
        ButtonBean buttonBean = ButtonBean();
        buttonBean.title = key;
        buttonBean.value = value;
        _tags.add(buttonBean);
      });
    }
    try {
      List<dynamic> jsons = json.decode(response);
      var imageBaseUrls = response.split(RegExp(r"var pic_image_url = '|';"));
      var imgBaseUrl = 'https://base.jingmin.wang/';
      if(imageBaseUrls.length > 1){
        imgBaseUrl = imageBaseUrls[1];
      }
      jsons.forEach((element) {
        var siseEntity = SiseSearchEntity.fromJson(element);
        VideoListItem listItem = VideoListItem();
        listItem.title = aesEncode(siseEntity.title!);
        listItem.imageUrl = _getImgUrl(imgBaseUrl,siseEntity.thumb!);
        listItem.isVideo = _searchTag != 'tupian';
        listItem.targetUrl = _searchTag != 'tupian'? '${ApiConstant.videoList8Url}/cYc${encodeString(
            '/$_searchTag/play-${siseEntity.id}')}.html': '${ApiConstant.videoList8Url}/cYc${encodeString(
            '/$_searchTag/${siseEntity.id}')}.html';
        _data.add(listItem);
      });
      setState(() {

      });
    } catch (e) {
      print(e);
    }
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
      if (buttonBean.type == 1) {
        _page = buttonBean.page;
        buttonType = 1;
      } else {
        _isSearch = false;
        buttonType = 0;
        _currentKey = buttonBean.value!;
      }
      _refreshController.requestRefresh();
    }
  }

  String _getImgUrl(String? baseUrl,String url){
    return '${baseUrl??'https://www.xlrdcgrgs.xyz'}${url
          .startsWith('/') ?
    url : '/$url'}';
  }

  void goToDetail(VideoListItem data) async {
    showLoading();
    String response = await NetUtil.getHtmlData(data.targetUrl);
    var doc = parse.parse(response);
    var url = '';
    List<String> imageList = [];
    var imageBaseUrls = response.split(RegExp(r"var pic_image_url = '|';"));
    var imgBaseUrl = 'https://base.jingmin.wang/';
    if(imageBaseUrls.length > 1){
      imgBaseUrl = imageBaseUrls[1];
    }
    doc.getElementsByClassName('tupian-detail-content').first.getElementsByTagName('img').forEach((element) {
      imageList.add(_getImgUrl(imgBaseUrl,element.attributes['data-pic-base64']!));
    });
    Navigator.pop(context);
    Navigator.pushNamed(
        context, "/ShowStaggeredImagePage", arguments: {
      "list": imageList,
      'type': 2
    });

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

  String aesEncode(String content) {
    //加密key
    final key = Encrypt.Key.fromUtf8('IdTJq0HklpuI6mu8iB%OO@!vd^4K&uXW');
    //偏移量 - 注意这里
    final iv = Encrypt.IV.fromUtf8('\$0v@krH7V2883346');

    //设置cbc模式
    final encrypter = Encrypt.Encrypter(
        Encrypt.AES(key, mode: Encrypt.AESMode.cbc, padding: 'PKCS7'));
    //加密
    final encrypted = encrypter.decrypt64(content, iv: iv);
    return encrypted;
  }

  void _getImageBase64(VideoListItem item, int index) async {
    Directory tempDir = await getTemporaryDirectory();
    var path =
        '${tempDir.path}/${md5.convert(
        new Utf8Encoder().convert(item.imageUrl!))}';
    if (await File(path).exists()) {
      item.index = index;
      imgeStream.sink.add(item..imageUrl = path);
    } else {
      NetUtil.getHtmlData(item.imageUrl).then((value) {
        value = value.replaceAll('data:image/jpg;base64,', '');
        new File(path).writeAsBytes(base64Decode(value)).then((value) {
          item.index = index;
          item.imageUrl = path;
          imgeStream.sink.add(item);
        });
      });
    }
  }

  String encodeString(String str) {
    var url = Uri.encodeComponent(str);
    var escap = EscapeUnescape.unescape(url);
    return base64Encode(escap.codeUnits);
  }

  void _resetUrl(String url,{bool useFanhao = true})  async{
    SpUtil sp = await SpUtil.getInstance();
    String localStr = sp.getString(SharedPreferencesKeys.urls);
    UrlsBean? localUrl;
    if (localStr != null && localStr.isNotEmpty) {
      localUrl = UrlsBean.fromJson(json.decode(localStr));
    }
    http.Request req = http.Request("Get", Uri.parse(url))..followRedirects = false;
    http.Client baseClient = http.Client();
    http.StreamedResponse redirectResponse = await baseClient.send(req);
    if(redirectResponse.statusCode == 302){
      Uri redirectUri = Uri.parse(redirectResponse.headers['location']!);
      url = redirectUri.origin;
      _resetUrl(url,useFanhao: false);
      return;
    }
    if(url.isNotEmpty){
      ApiConstant.videoList8Url = url.replaceAll('/index/home.html', '');
      UrlsBean localUrl;
      if (localStr != null && localStr.isNotEmpty) {
        localUrl = UrlsBean.fromJson(json.decode(localStr));
        localUrl.videoList8Url = ApiConstant.videoList8Url;
        sp.putString(SharedPreferencesKeys.urls, json.encode(localUrl));
      }
      _refreshController.requestRefresh();
    }
  }
}
