import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_parse_html/model/video_list_item.dart';
import 'package:flutter_parse_html/ui/movie/movie_detail_page.dart';
import 'package:flutter_parse_html/ui/pornhub/pornhub_util.dart';
import 'package:flutter_parse_html/util/native_utils.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:flutter_parse_html/model/button_bean.dart';
import 'package:flutter_parse_html/net/net_util.dart';
import 'package:flutter_parse_html/api/api_constant.dart';
import 'package:html/parser.dart' as parse;
import 'package:flutter_parse_html/widget/dialog_page.dart';
import 'package:flutter_parse_html/model/movie_bean.dart';
import 'package:screen/screen.dart';
import 'package:flutter_parse_html/model/parse3_search_bean_entity.dart';

class XianFeng3Page extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return XianFeng3State();
  }
}

class XianFeng3State extends State<XianFeng3Page>
    with AutomaticKeepAliveClientMixin {
  List<VideoListItem> _data = [];
  List<ButtonBean> _btns;

  RefreshController _refreshController;
  int _page = 1,buttonType = 0;
  String _currentKey = '/ribenAV';
  String _searchKey = '';
  TextEditingController _editingController;
  bool _isSearch = false;

  @override
  void initState() {
    _refreshController = new RefreshController(initialRefresh: true);
    _editingController = new TextEditingController(text: _searchKey);
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
            getSearchWidget(),
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
                child: ListView.separated(
                    separatorBuilder: (context, index) {
                      return Divider(
                        color: Colors.grey,
                      );
                    },
                    itemCount: _data.length,
                    itemBuilder: (context, index) {
                      VideoListItem videoListItem = _data[index];
                      return GestureDetector(
                        onTap: () {
                          goToDetail(_data[index]);
                        },
                        child: Padding(
                          padding: EdgeInsets.all(5),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(5),
                            child: Container(
                              color: Colors.white,
                              child: Column(
                                children: <Widget>[
                                  Padding(
                                    padding: EdgeInsets.all(5),
                                    child: Text(videoListItem.title),
                                  ),
                                  SizedBox(
                                    height:
                                        MediaQuery.of(context).size.width - 20,
                                    child: SizedBox.expand(
                                      child: CachedNetworkImage(
                                        placeholder: (context, url) =>
                                            new Icon(Icons.image),
                                        errorWidget: (context, url, error) =>
                                            new Icon(Icons.error),
                                        imageUrl: videoListItem.imageUrl,
                                        fit: BoxFit.fill,
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
              ),
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_btns.length > 0) {
            //有选项再显示
            _showDialog();
//        NativeUtils.toXfPlay('xfplay://dna=DwjbAwfdmwLWDZiWAZfdBdiZAZx2m0m4AGeXmeDXEdjbAZmYAZxZmt|dx=450062105|mz=JUY-794_CH_SD_onekeybatch.mp4|zx=nhE0pdOVl3P5AY5xqzD5Ac5wo206BGa4mc94MzXPozS|zx=nhE0pdOVl3Ewpc5xqzD4AF5wo206BGa4mc94MzXPozS');
          }
        },
        child: Icon(Icons.add),
      ),
    );
  }

  //获取数据
  void _getData() async {
    String url = _isSearch
        ? '${ApiConstant.xianFeng3Url}/share/search?name=$_searchKey&page=$_page'
        : ApiConstant.xianFeng3Url + _currentKey + '/page$_page/';
    String response = await PornHubUtil.getHtmlFromHttpDeugger(url,isMobile: _isSearch);

    if(_isSearch){
      Parse3SearchBeanEntity parse3searchBeanEntity = Parse3SearchBeanEntity.fromJson(json.decode(response));
      parse3searchBeanEntity.data.items.forEach((item){
        VideoListItem videoListItem = VideoListItem();
        videoListItem.imageUrl = item.picurl;
        videoListItem.title = item.name + item.createdAt;
        videoListItem.targetUrl = '${ApiConstant.xianFeng3Url}${item.urlpath}';
        _data.add(videoListItem);
      });
    }else{
      var doc = parse.parse(response);
      var btnElements = doc
          .getElementsByClassName('superfish')
          .first
          .getElementsByTagName('li');
      try {
        if (_btns == null) {
          _btns = [];
          for (var value in btnElements) {
            var eles = value.getElementsByTagName('a').first;
            ButtonBean buttonBean = ButtonBean();
            buttonBean.title = eles.text;
            if ('首页' != eles.text && '小说专区' != eles.text && '求片留言' != eles.text) {
              buttonBean.value = eles.attributes['href'];
              _btns.add(buttonBean);
            }
          }
          var tagElements = doc.getElementsByClassName('stag');
          tagElements.forEach((ele) {
            for (var value in ele.getElementsByTagName('li')) {
              ButtonBean buttonBean = ButtonBean();
              buttonBean.title = value.text;
              buttonBean.value =
              value.getElementsByTagName('a').first.attributes['href'];
              _btns.add(buttonBean);
            }
          });
        }
        var tbodys = doc
            .getElementsByClassName('mbox')
            .first
            .getElementsByClassName('list');
        tbodys.forEach((ele) {
          VideoListItem videoListItem = new VideoListItem();
          videoListItem.title =
          '${ele.getElementsByClassName('rtl').first.text}  ${ele.getElementsByClassName('info').first.text}';
          videoListItem.imageUrl =
          ele.getElementsByTagName('img').first.attributes['src'];
          videoListItem.des = ele.getElementsByTagName('p').first.text;
          videoListItem.targetUrl =
          '${ApiConstant.xianFeng3Url}${ele.getElementsByTagName('a').first.attributes['href']}';
          _data.add(videoListItem);
        });
      } catch (e) {
        print(e);
      }
    }

    setState(() {
      _refreshController.refreshCompleted();
      _refreshController.loadComplete();
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
    String response = await PornHubUtil.getHtmlFromHttpDeugger(data.targetUrl);
    Navigator.pop(context);
    var doc = parse.parse(response);
    MovieBean movieBean = MovieBean();
    var pbox = doc.getElementsByClassName('pbox').first;
    var listEle = doc.getElementsByClassName('list').first;
    movieBean.des = pbox.text;
    movieBean.info = listEle.getElementsByClassName('info').first.text;
    movieBean.imgUrl =
        listEle.getElementsByTagName('img').first.attributes['src'];
    movieBean.name = listEle.getElementsByClassName('rtl').first.text;
    movieBean.list = [];
    MovieItemBean movieItemBean = MovieItemBean();
    movieItemBean.name = '先锋影音';
    try {
      var plaEle = pbox
          .getElementsByClassName('pl')
          .first
          .getElementsByTagName('a')
          .first;
      movieItemBean.targetUrl =
          '${ApiConstant.xianFeng3Url}${plaEle.attributes['href']}';
      movieBean.list.add(movieItemBean);
      Navigator.of(context)
          .push(new MaterialPageRoute(builder: (BuildContext context) {
        return MovieDetailPage(5, movieBean);
      }));
    } catch (e) {
      print(e);
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

  getSearchWidget() {
    return Padding(padding: EdgeInsets.all(10),
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
            _searchKey = value;
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
    ),);
  }
}
