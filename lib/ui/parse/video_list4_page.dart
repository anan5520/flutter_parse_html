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
import 'package:flutter_parse_html/util/native_utils.dart';
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
import 'package:flutter/services.dart' show rootBundle;
import '../../model/api_bean.dart';
import '../../resources/shared_preferences_keys.dart';
import '../../util/shared_preferences.dart';
import 'book_page.dart';
import 'package:html/dom.dart' as dom;
class VideoList4Page extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return VideoList4State();
  }
}

class VideoList4State extends State<VideoList4Page>
    with AutomaticKeepAliveClientMixin {
  List<VideoListItem> _data = [];
  late List<ButtonBean> _btns = [];

  late RefreshController _refreshController;
  int _page = 1,buttonType = 0;
  String _currentKey = '/video/html64/';
  bool _isSearch = false;
  int _type = 0;
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
                    _page = 0;
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
          if (_btns.length > 0) {
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
    var response = await NetUtil.getHtmlData(data.targetUrl);
    try {
      var strings = response.split(new RegExp(r'play\+"|.m3u8'));
      String playUrl = '';
      var base = 'https://tb08362.gjrvpf.com';
      if(response.contains("javplay")){
        base = 'https://m3u8.73cdn.com';
      }
      playUrl = '$base${strings[1]}.m3u8'.replaceAll('\\', '');
      Navigator.pop(context);
      if (playUrl.startsWith('http')) {
        CommonUtil.toVideoPlay(playUrl, context,title:data.title!);
      }
    } catch (e) {
      Navigator.pop(context);
      print(e);
    }
  }

  void _getImageBase64(VideoListItem item, int index) async {
    if(_type != 0 || _isSearch){
      return;
    }
    Directory tempDir = await getTemporaryDirectory();
    var path =
        '${tempDir.path}/${md5.convert(
        new Utf8Encoder().convert(item.imageUrl!))}';
    if (await File(path).exists()) {
      item.index = index;
      imgeStream.sink.add(item..base64Img = path);
    } else {
      NetUtil.getHtmlData(item.imageUrl).then((value) {
        value = value.replaceAll('data:image/jpg;base64,', '');
        new File(path).writeAsBytes(base64Decode(value)).then((value) {
          item.index = index;
          item.base64Img = path;
          imgeStream.sink.add(item);
        });
      });
    }
  }

  getItem(int index) {
    VideoListItem item = _data[index];
    _getImageBase64(item, index);
    return ClipRRect(
      borderRadius: BorderRadius.circular(5),
      child: GestureDetector(
        onTap: () {
          if(_isSearch){
            toSearchDetail(item);
          }else{
            if(_type == 0){
              goToPlay(item);
            }else if(_type == 1){
              getImg(item.targetUrl!);
            }else{
              Navigator.of(context)
                  .push(new MaterialPageRoute(builder: (BuildContext context) {
                return BookHomePage(_data[index].targetUrl, 9);
              }));
            }
          }
        },
        child: Container(
          color: Colors.white,
          child: new Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Expanded(
                child: ConstrainedBox(
                  child: StreamBuilder(stream:imgeStream.stream,builder: (_,_snap){
                    return item.imageUrl!.endsWith("jpg")?
                    CachedNetworkImage(
                      placeholder: (context, url) => new Icon(Icons.image),
                      errorWidget: (context, url, error) => new Icon(Icons.error),
                      imageUrl: item.imageUrl!,
                      fit: BoxFit.cover,
                    ): (item.index !> -1 && item.imageUrl!.isNotEmpty)
                        ? Image.file(
                      File(item.base64Img!),
                      gaplessPlayback: true,
                      fit: BoxFit.cover,
                    )
                        : _getDefaultImg(item);
                  },),
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
    String url = _isSearch
        ? '${ApiConstant.videoList4Url}/searchs/?page=${_page}&keyboard=${Uri.encodeComponent(_currentKey)}&classid=0'
        : "${ApiConstant.videoList4Url}${_currentKey.isNotEmpty?'${_currentKey}${_page==1?"":'index_${_page}.html'}':''}";
    var menuStr = await rootBundle.loadString("assets/menu.txt");
    String response =  await NetUtil.getHtmlData(url);
    _refreshController.refreshCompleted();
    _refreshController.loadComplete();
    var doc = parse.parse(response);
    var menuDoc = parse.parse(menuStr);
    try {
      if(_isSearch){
        var rootEles = doc
            .getElementsByClassName('row-book clearfix');
        if(rootEles.isEmpty){
          resetUrl(url);
          return;
        }
        var tdElements =
        rootEles.first
            .getElementsByTagName('dl');
        for (var value in tdElements) {
          try {
            var h2Ele = value.getElementsByTagName("h2");
            if(h2Ele.isEmpty){
              continue;
            }
            var aEles = value.getElementsByTagName("a");
            if (aEles.length > 0) {
              var aEle = aEles.first;
              VideoListItem item = VideoListItem();
              String href = aEle.attributes['href']!;
              var imgs = value.getElementsByTagName('img');
              var tag = value.getElementsByClassName('url').first.text;
              var imgTags = ["自拍偷拍","美腿丝袜","欧美色图","卡通图片"];
              for (var value in imgTags) {
                if(tag!.contains(value)){
                  item.isImage = true;
                }
              }
              if(tag.contains("小说")){
                item.isBook = true;
              }else if(item.isImage != true){
                item.isVideo = true;
              }
              if(imgs.isNotEmpty){
                var imgEle = imgs.first;
                item.imageUrl = imgEle.attributes['data-original'];
              }else{
                item.imageUrl = "";
              }
              item.title = aEle.text;
              item.targetUrl = href;
              _data.add(item);
            }
          } catch (e) {
            print(e);
          }
        }
      }else{
        var rootEles = doc
            .getElementsByClassName('mod channel-list');
        if(rootEles.isEmpty){
          resetUrl(url);
          return;
        }
        var tdElements =
        rootEles.first
            .getElementsByTagName('dl');
        for (var value in tdElements) {
          try {
            List<dom.Element> aEles ;
            if(_type != 0){
              aEles = value.getElementsByTagName("a");
            }else{
              aEles = value.getElementsByTagName('dd').first.getElementsByTagName("a");
            }

            if (aEles.length > 0) {
              var aEle = aEles.first;
              VideoListItem item = VideoListItem();
              String href = ApiConstant.videoList4Url + aEle.attributes['href']!;
              var imgs = value.getElementsByTagName('img');
              if(imgs.isNotEmpty){
                var imgEle = imgs.first;
                item.imageUrl = imgEle.attributes['data-original'];
              }else{
                item.imageUrl = "";
              }
              if(aEle.text.contains("document.write")){
                var base= aEle.text.replaceAll("document.write(d('", '').replaceAll("'));", '').replaceAll('\n', '');
                item.title = utf8.decode(base64Decode(base));
              }else{
                item.title = aEle.text;
              }
              item.targetUrl = href;
              _data.add(item);
            }
          } catch (e) {
            print(e);
          }
        }
      }

      if (_btns.isEmpty) {
        _btns.clear();
        var menu = menuDoc.getElementsByClassName('menu clearfix').first;
        var liEles = menu.getElementsByTagName('dd');
        liEles.forEach((element) {
          var btnEles = element.getElementsByTagName('a');
          for (var value1 in btnEles) {
            ButtonBean buttonBean = ButtonBean();
            buttonBean.title = value1.text;
            buttonBean.value = value1.text.contains('首页')
                ? ''
                : value1.attributes['href'];
            if(!(buttonBean.value?.startsWith("http") == true)){
              _btns.add(buttonBean);
            }
          }
        });
      }
    } catch (e) {
      print(e);
    }

    setState(() {

    });
  }
  void getImg(String targetUrl) async {
    showLoading();
    var response = await NetUtil.getHtmlData(targetUrl);
    var document = parse.parse(response);
    var elments = document
        .getElementsByClassName("pic")
        .first
        .getElementsByTagName("img");
    List<String> imgs = [];
    for (var value in elments) {
      imgs.add(value.attributes['src']!);
    }
    Navigator.pop(context);
    Navigator.pushNamed(context, "/ShowStaggeredImagePage", arguments: {"list": imgs});
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
      if(buttonBean.type == 1){
        _page = buttonBean.page;
        buttonType = 1;
      }else{
        _isSearch = false;
        buttonType = 0;
        _currentKey = buttonBean.value!;
      }
      _type = 0;
      var imgs = ["自拍偷拍","美腿丝袜","欧美色图","卡通图片"];
      for (var value in imgs) {
        if(buttonBean.title!.contains(value)){
          _type = 1;
        }
      }
      if(buttonBean.title!.contains('小说')){
        _type = 2;
      }

      _refreshController.requestRefresh();
    }
  }

  void goToDetail(VideoListItem data) async {
    showLoading();
    String response = await NetUtil.getHtmlData(data.targetUrl);
    var doc = parse.parse(response);
    var urls = response.split(new RegExp(r'"url":"https|.m3u8",'));
    String url = urls[0];
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
    CommonUtil.toVideoPlay(url, context,title: data.title!);
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

  // **解混淆函数**：跳过每两个字符中的一个
  String deobfuscate(String text) {
    StringBuffer deobfuscated = StringBuffer();
    for (int i = 0; i < text.length; i += 2) {
      deobfuscated.write(text[i]);
    }
    return deobfuscated.toString();
  }

  void resetUrl(String original) async{
    // 1️⃣ 获取当前 URL
    var url = Uri.parse(original);

    // 2️⃣ 提取协议、主机、路径
    var result = "${url.scheme}://${url.host}${url.path}";

    // 3️⃣ 构造 Base64 编码的 URL 参数
    String encodeBase64(String input) {
      return base64Encode(utf8.encode(input));
    }

    var u = encodeBase64(result);
    var p = encodeBase64("${url.path}${url.query}");

    // 4️⃣ 构造重定向 URL
    var redirectUrl = "${ApiConstant.videoList4Url}/Index/Inform.html?u=$u&p=$p";

    print("重定向 URL: $redirectUrl");
    var requestUrl = "";
    http.Request req = http.Request("Get", Uri.parse(redirectUrl))..followRedirects = false;
    http.Client baseClient = http.Client();
    http.StreamedResponse redirectResponse = await baseClient.send(req);
    final responseBody = await redirectResponse.stream.bytesToString();
    if(redirectResponse.statusCode == 302){
      Uri redirectUri = Uri.parse(redirectResponse.headers['location']!);
      requestUrl = redirectUri.origin;
      _resetBaseUrl(requestUrl);
      return;
    }
    // 5️⃣ 执行跳转
    // window.location.href = redirectUrl;
  }

  void _resetBaseUrl(String url,{bool useFanhao = true})  async{
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
      _resetBaseUrl(url,useFanhao: false);
      return;
    }
    if(url.isNotEmpty){
      ApiConstant.videoList4Url = url.replaceAll('/index/home.html', '');
      UrlsBean localUrl;
      if (localStr != null && localStr.isNotEmpty) {
        localUrl = UrlsBean.fromJson(json.decode(localStr));
        localUrl.videoList4Url = ApiConstant.videoList4Url;
        sp.putString(SharedPreferencesKeys.urls, json.encode(localUrl));
      }
      _refreshController.requestRefresh();
    }
  }

  @override
  void dispose() {
    imgeStream.close();
    super.dispose();
  }

  void toSearchDetail(VideoListItem item) {
    if(item.isVideo == true){
      goToPlay(item);
    }else if(item.isImage == true){
      getImg(item.targetUrl!);
    }else{
      Navigator.of(context)
          .push(new MaterialPageRoute(builder: (BuildContext context) {
        return BookHomePage(item.targetUrl, 9);
      }));
    }
  }

  _getDefaultImg(VideoListItem item) {
    if(item.isVideo == true){
      return Icon(Icons.play_circle,color: Colors.blue,size: 50,);
    }

    if(item.isImage == true){
      return Icon(Icons.image,color: Colors.blue,size: 50,);
    }
    if(item.isBook == true){
      return Icon(Icons.menu_book_outlined,color: Colors.blue,size: 50,);
    }

    return Image.asset('images/video_bg.png');
  }

}
