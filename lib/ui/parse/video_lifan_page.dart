import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_parse_html/model/video_list_item.dart';
import 'package:flutter_parse_html/ui/movie/movie_detail_page.dart';
import 'package:flutter_parse_html/ui/pornhub/pornhub_util.dart';
import 'package:flutter_parse_html/util/common_util.dart';
import 'package:flutter_parse_html/util/native_utils.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:flutter_parse_html/model/button_bean.dart';
import 'package:flutter_parse_html/net/net_util.dart';
import 'package:flutter_parse_html/api/api_constant.dart';
import 'package:html/parser.dart' as parse;
import 'package:flutter_parse_html/widget/dialog_page.dart';
import 'package:flutter_parse_html/model/movie_bean.dart';

class VideoLiFanPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return VideoLiFanState();
  }
}

class VideoLiFanState extends State<VideoLiFanPage>
    with AutomaticKeepAliveClientMixin {
  List<VideoListItem> _data = [];
  List<ButtonBean> _btns;

  RefreshController _refreshController;
  int _page = 1,buttonType = 0;
  String _currentKey = '/vodtype/1';
  bool _isSearch = false;
  TextEditingController _editingController;

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
      var strings = response.split(new RegExp(r'"url":"https|.m3u8'));
      String playUrl = '';
      for (var value in strings) {
        if (value.startsWith(':')) {
          playUrl = 'https$value.m3u8'.replaceAll('\\', '');
        }
      }
      Navigator.pop(context);
      if (playUrl.startsWith('http')) {
        CommonUtil.toVideoPlay(playUrl, context,title:data.title);
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

  //获取数据
  void _getData() async {
    String url = _isSearch
        ? '${ApiConstant.liFanUrl1}/vodsearch/${Uri.encodeComponent(_currentKey)}----------$_page---.html'
        : "${ApiConstant.liFanUrl1}/category/lifan/$_page/";
    String response =  await NetUtil.getHtmlData(url);
    _refreshController.refreshCompleted();
    _refreshController.loadComplete();
    var doc = parse.parse(response);
    try {
      var tdElements = doc
          .getElementsByClassName('uk-animation-slide-bottom-small');
      for (var value in tdElements) {
        var aEles = value.getElementsByTagName('a');
        if (aEles.length > 0) {
          var aEle = aEles.first;
          VideoListItem item = VideoListItem();
          String href = aEle.attributes['href'];
          item.title = CommonUtil.replaceStr(value.getElementsByClassName('video-post-content').first.text);
          item.imageUrl = 'https://api.uomg.com/api/rand.img1';
          item.targetUrl = href;
          _data.add(item);
        }
      }
      // if (_btns == null) {
      //   _btns = [];
      //   var menu = doc.getElementsByClassName('nav nav-stacked navigation').first;
      //   var liEles = menu.getElementsByTagName('li');
      //   liEles.forEach((element) {
      //     var btnEles = element.getElementsByTagName('a');
      //     for (var value1 in btnEles) {
      //       ButtonBean buttonBean = ButtonBean();
      //       buttonBean.title = value1.text;
      //       buttonBean.value = value1.text.contains('首页')
      //           ? ''
      //           : value1.attributes['href'].replaceAll('.html', '');
      //       _btns.add(buttonBean);
      //     }
      //   });
      // }
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
        _currentKey = buttonBean.value;
      }
      _refreshController.requestRefresh();
    }
  }

  void goToDetail(VideoListItem data) async {
    showLoading();
    String response = await NetUtil.getHtmlData(data.targetUrl);
    var doc = parse.parse(response);
    MovieBean movieBean = MovieBean();
    try {
      var info = '';
      var tbody = doc.getElementsByClassName('video-info mt-3').first;
      var strongEles = tbody.getElementsByTagName('strong');
      for(var i = 0;i < strongEles.length;i ++ ){
        info = '$info第${i + 1}集：${strongEles[i].text}\n';
      }

      movieBean.imgUrl = data.imageUrl;
      movieBean.info = info;
      movieBean.name = data.title;
      movieBean.des = '';
      movieBean.originUrl = data.targetUrl;
      MovieItemBean itemBean = MovieItemBean();
      itemBean.name = '1';
      itemBean.targetUrl = data.targetUrl;
      movieBean.list = [itemBean];
      var ukMargin = doc.getElementsByClassName('uk-margin').first.getElementsByTagName('a');
      ukMargin.forEach((aEle) {
        MovieItemBean itemBean = MovieItemBean();
        itemBean.name = aEle.text;
        itemBean.targetUrl = aEle.attributes['href'];
        movieBean.list.add(itemBean);
      });
    } catch (e) {
      print(e);
    }

    Navigator.pop(context);
    Navigator.of(context)
        .push(new MaterialPageRoute(builder: (BuildContext context) {
      return MovieDetailPage(7, movieBean);
    }));
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
