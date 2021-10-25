import 'dart:io';
import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_parse_html/download/download_util.dart';
import 'package:flutter_parse_html/model/button_bean.dart';
import 'package:flutter_parse_html/model/movie_bean.dart';
import 'package:flutter_parse_html/ui/douyin/dou_yin_page.dart';
import 'package:flutter_parse_html/ui/parse/book_page.dart';
import 'package:flutter_parse_html/ui/parse/video_list5_page.dart';
import 'package:flutter_parse_html/ui/porn/porn_forum_content_page.dart';
import 'package:flutter_parse_html/util/common_util.dart';
import 'package:flutter_parse_html/widget/dialog_page.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:html/parser.dart' as parse;
import 'package:flutter_parse_html/api/api_constant.dart';
import 'package:flutter_parse_html/net/net_util.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:flutter_parse_html/model/video_list_item.dart';
import 'package:flutter_parse_html/util/ya_se_helper.dart';
import 'dart:convert';
import 'package:flutter_parse_html/model/ya_se_video_entity.dart';
import '../video_play.dart';
class YaSePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return YaSeState();
  }
}

class YaSeState extends State<YaSePage>
    with SingleTickerProviderStateMixin {
  TabController _tabController;
  PageController _pageController;
  var isPageCanChanged = true;
  List<YaSeType> _titleValue = [
    YaSeType.self,
    YaSeType.book,
    YaSeType.video,
  ];
  List<String> _titleName = ["自拍", "小说", "视频", "视频1"];

  @override
  void initState() {
    _tabController = new TabController(length: _titleName.length, vsync: this);
    _pageController = new PageController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('老司机2'),
      ),
      body: Column(
        children: <Widget>[
          Container(
            color: Colors.blue,
            height: 38,
            width: double.infinity,
            child: TabBar(
              controller: _tabController,
              onTap: (index) {
                onPageChange(index, p: _pageController);
              },
              tabs: _titleName.map((item) {
                return Tab(
                  text: item,
                );
              }).toList(),
            ),
          ),
          Expanded(
            child: PageView.builder(
              itemCount: _titleName.length,
              onPageChanged: (index) {
                if (isPageCanChanged) {
                  //由于pageview切换是会回调这个方法,又会触发切换tabbar的操作,所以定义一个flag,控制pageview的回调
                  onPageChange(index);
                }
              },
              controller: _pageController,
              itemBuilder: getPageItem,
            ),
          )
        ],
      ),
    );
  }

  void onPageChange(int index, {PageController p, TabController t}) async {
    if (p != null) {
      //判断是哪一个切换
      isPageCanChanged = false;
      await _pageController.animateToPage(index,
          duration: Duration(milliseconds: 500),
          curve: Curves.ease); //等待pageview切换完毕,再释放pageivew监听
      isPageCanChanged = true;
    } else {
      _tabController.animateTo(index); //切换Tabbar
    }
  }

  Widget getPageItem(BuildContext context, int index) {
    if(index == 0){
      return VideoList5Page();
    }
    return YaSeItemPage(_titleValue[index - 1],'');
  }
}
class YaSeItemPage extends StatefulWidget {
  YaSeType _type = YaSeType.video;
  String _url ;
  YaSeItemPage(this._type, this._url);

  @override
  State<StatefulWidget> createState() {
    return YaSeItemState();
  }
}

class YaSeItemState extends State<YaSeItemPage> with AutomaticKeepAliveClientMixin {
  List<ButtonBean> _btns;

  List<VideoListItem> _data = [];

  String _currentKey;

  RefreshController _refreshController;

  TextEditingController _editingController;

  bool _isSearch = false;
  bool _isUser = false;
  int _page = 1;

  @override
  void initState() {
    _refreshController = new RefreshController(initialRefresh: true);
    _editingController = new TextEditingController(text: _currentKey);
    if(widget._url != null && widget._url != ''){
      _currentKey = widget._url;
      _isUser = true;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    super.build(context);
    Widget content = widget._type == YaSeType.video
        ? GridView.builder(
            padding: EdgeInsets.all(10),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 0.6,
            ),
            itemBuilder: getGridItem,
            itemCount: _data.length,
          )
        : ListView.builder(
            itemBuilder: getListItem,
            itemCount: _data.length,
          );
    //搜索控件
    Widget input = widget._type == YaSeType.book?Container(): Padding(
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
    );
    return Scaffold(
      body: Container(
        color: Color(0xffeeeeee),
        child: Column(children: <Widget>[
          input,
          Expanded(
            child: SmartRefresher(
              enablePullUp: true,
              controller: _refreshController,
              onRefresh: () {
                _page = 1;
                _loadData();
              },
              onLoading: () {
                _page++;
                _loadData();
              },
              child: content,
            ),
          )
        ],),
      ),
      floatingActionButton: FloatingActionButton(
          child: new Icon(Icons.add),
          onPressed: () {
            _showDialog();
          }),
    );
  }
  //加载数据
  void _loadData() async {
    String url = _getUrl();
    String html = await NetUtil.getHtmlData(url,isWeb: !_isSearch);
    _refreshController.loadComplete();
    _refreshController.refreshCompleted();
    var doc = parse.parse(html);
    try {
      if (_btns == null) {
            _btns = [];
            if(widget._type == YaSeType.book){
              var eles = doc.getElementsByClassName('top-category').first.getElementsByTagName('a');
              for (var aEle in eles) {
                ButtonBean buttonBean = new ButtonBean();
                buttonBean.title = aEle.text;
                buttonBean.value = aEle.attributes['href'];
                _btns.add(buttonBean);
              }
            }else{
              var typeEles = doc
                  .getElementsByClassName('child-nav fixed-div');
              if(typeEles == null || typeEles.length == 0){
                typeEles = doc
                    .getElementsByClassName('top-category').first.getElementsByTagName('a');
                for (var value in typeEles) {
                    ButtonBean buttonBean = new ButtonBean();
                    buttonBean.title = value.text;
                    buttonBean.value = value.attributes['href'];
                    _btns.add(buttonBean);
                  }
                }else{
                typeEles = typeEles.first.getElementsByTagName('li');
                for (var value in typeEles) {
                  var className = value.attributes['class'];
                  if (className != null && (className == '' || className == 'this')) {
                    var aEle = value.getElementsByTagName('a').first;
                    ButtonBean buttonBean = new ButtonBean();
                    buttonBean.title = aEle.text;
                    buttonBean.value = aEle.attributes['href'];
                    _btns.add(buttonBean);
                  }
                }
              }
            }

          }
    } catch (e) {
      print(e);
    }
    var list;
    if(widget._type == YaSeType.video){
      list = YaSeHelper.parseVideo(doc);
    }else if(widget._type == YaSeType.book){
      list = YaSeHelper.parseBook(doc);
    }else{
      list = YaSeHelper.parseSelf(doc);
    }
    setState(() {
      if (_page == 1) {
        _data.clear();
      }
      _data.addAll(list);
    });
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
      _isSearch = false;
      _currentKey = buttonBean.value;
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

  Widget getListItem(BuildContext context, int index) {
    VideoListItem item = _data[index];
    Widget imgWidget = item.imageUrl == null
        ? Container()
        : SizedBox(
            width: 160,
            height: 80,
            child: Padding(
              padding: EdgeInsets.only(right: 10),
              child: CachedNetworkImage(
                placeholder: (context, url) => new Icon(Icons.image),
                errorWidget: (context, url, error) => new Icon(Icons.image),
                imageUrl: item.imageUrl,
                fit: BoxFit.cover,
              ),
            ),
          );
    return GestureDetector(
      onTap: () async {
        //     点击跳转
        showLoading();
        Navigator.pop(context);
        if(widget._type == YaSeType.book){
          Navigator.of(context)
              .push(new MaterialPageRoute(builder: (BuildContext context) {
                if(item.targetUrl.contains("info")){
                  item.targetUrl = item.targetUrl.replaceAll('info', 'view');
                }
            return BookHomePage(item.targetUrl + '/1', 2);
          }));
        }else{
          print('跳转到>>>${item.targetUrl}');
          Navigator.push(context, MaterialPageRoute(builder: (context){
            return PornForumContentPage(0,1,item.targetUrl);
          }));
        }
      },
      child: Padding(
        padding: EdgeInsets.only(left: 10, right: 10, top: 5),
        child: Container(
          decoration: new BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(4),
            border: new Border.all(color: Color(0xFFEEEEEE), width: 0.5),
            // 边色与边宽度
// 生成俩层阴影，一层绿，一层黄， 阴影位置由offset决定,阴影模糊层度由blurRadius大小决定（大就更透明更扩散），阴影模糊大小由spreadRadius决定
            boxShadow: [
              BoxShadow(
                  color: Color(0xFFEEEEEE),
                  offset: Offset(5.0, 5.0),
                  blurRadius: 5.0,
                  spreadRadius: 2.0)
            ],
          ),
          child: Padding(padding: EdgeInsets.all(10),
          child: Row(
            children: <Widget>[
              imgWidget,
              Expanded(
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(bottom: 5),
                      child: Text(
                        '${item.title}(${item.title})',
                        style: TextStyle(color: Colors.blueAccent),
                      ),
                    ),
                   GestureDetector(
                     onTap: (){
                       if(widget._type == YaSeType.self && item.vid != null){
                          Navigator.push(context, MaterialPageRoute(builder: (context){
                            return YaSeItemPage(YaSeType.self,item.vid);
                          }));
                       }
                     },
                     child:  Text(
                       item.des,
                       style: TextStyle(color: Colors.red, fontSize: 11),
                     ),
                   )
                  ],
                ),
              ),
            ],
          ),),
        ),
      ),
    );
  }

  Widget getGridItem(BuildContext context, int position) {
    var item = _data[position];
    return new GestureDetector(
      onTap: () {
        showLoading();
        if(widget._type == YaSeType.video){
          goToPlayVideo(ApiConstant.yaSeUrl + item.targetUrl, item.title);
        }else{

        }
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(5),
        child: Container(
          color: Colors.white,
          child: new Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Expanded(
                child: ConstrainedBox(
                  child: CachedNetworkImage(
                    placeholder: (context, url) => new Icon(Icons.image),
                    errorWidget: (context, url, error) => new Icon(Icons.error),
                    imageUrl: item.imageUrl,
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

  void goToPlayVideo(String url, String title) async {
    try {
      var vids = url.split('/');
      if(vids.length>0){
        var html = await NetUtil.getHtmlData(url,isWeb: false);
        var jsonStr = await NetUtil.getHtmlData(
            '${ApiConstant.yaSeUrl}/api/video/player_domain?id=${vids[vids.length - 1]}',isWeb: false);

//      var videos = html.split(new RegExp(r"m3u8_url = '|', poster_url"));
//      var videoUrl = videos[1];
        var jsonMap = json.decode(jsonStr);
//      var domain = videoUrl.split('[')[1].split(']')[0];
//      videoUrl = videoUrl.replaceAll('[$domain]', jsonMap[domain]);
        Navigator.pop(context);
        int code = jsonMap['code'];
        if( code != null && code == 1){
          String videoUrl = jsonMap['data'];
          print(videoUrl);
//          DownloadUtil.downVideo(videoUrl,title,1);
          CommonUtil.toVideoPlay(videoUrl, context,title:title);
        }else{
          Fluttertoast.showToast(msg: '需要vip,看其他的吧',toastLength: Toast.LENGTH_SHORT);
//          //解析其他视频
//          var jsonStr = await NetUtil.getHtmlData(
//              '${ApiConstant.yaSeUrl}/api/video/like_video?id=${vids[vids.length - 1]}&page=1&from=web',isWeb: false);
//          YaSeVideoEntity yaSeVideoEntity = YaSeVideoEntity.fromJson(json.decode(jsonStr));
//          var postStr = await NetUtil.getHtmlData(
//              '${ApiConstant.yaSeUrl}/api/video/player_domain?id=1113614',isWeb: false);
//          String post = 'https://tou22.yyhdyl.com';
//          var jsonMap = json.decode(postStr);
//          int codePost = jsonMap['code'];
//          if( codePost != null && codePost == 1){
//            post = json.decode(postStr)['data'].toString().split('.com')[0] + '.com';
//          }
//          if(yaSeVideoEntity.code == 1){
//            String videoUrl = '$post/${yaSeVideoEntity.data.xList[0].videoHls}';
//            print(videoUrl);
//            Navigator.push(context, MaterialPageRoute(builder: (context) {
//              return VideoPlayPage(videoUrl, title);
//            }));
//          }

        }
      }


    } catch (e) {
      print(e);
//      Navigator.pop(context);
    }
  }

  @override
  bool get wantKeepAlive => true;

  String _getUrl() {
   String  url = ApiConstant.getYaSeVideoUrl();
    if (_currentKey == null) {
      switch (widget._type) {
        case YaSeType.video:
          url = ApiConstant.getYaSeVideoUrl();
          break;
        case YaSeType.self:
          url = ApiConstant.getYaSeSelf();
          break;
        case YaSeType.book:
          url = ApiConstant.bookList2Url;
          break;
      }
    } else {
      if(_isSearch){
          url = '${ApiConstant.yaSeUrl}${widget._type == YaSeType.video?'/search/?type=video&keyword=':'/search/?type=pic&keyword='}$_currentKey';
      }else{
        url = '${widget._type == YaSeType.book?ApiConstant.yaSeUrl:ApiConstant.yaSeUrl}$_currentKey';
      }

    }
    if(url.contains('.html') && widget._type == YaSeType.book){
      url = url.replaceAll('.html', '');
    }
    String division = _isSearch || _isUser?'&':'?';
    url = widget._type == YaSeType.book?'$url?page=$_page':'$url${division}page=$_page';
    return url;
  }
}

enum YaSeType { video, self, book }
