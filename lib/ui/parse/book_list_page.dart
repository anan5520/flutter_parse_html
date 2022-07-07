import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_parse_html/book/novel/view/novel_book_intro.dart';
import 'package:flutter_parse_html/book/novel/view/novel_book_search_result.dart';
import 'package:flutter_parse_html/book/router/manager_router.dart';
import 'package:flutter_parse_html/model/video_list_item.dart';
import 'package:flutter_parse_html/ui/home_page.dart';
import 'package:flutter_parse_html/ui/movie/movie_detail_page.dart';
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

class BookListPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return BookListState();
  }
}

class BookListState extends State<BookListPage>
    with AutomaticKeepAliveClientMixin {
  List<VideoListItem> _data = [];
  List<ButtonBean> _btns;

  RefreshController _refreshController;
  int _page = 1;
  String _currentKey = HomePage.inLsj?'/modules/article/toplist.php?order=allvisit':'/ph/month';
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
      appBar: AppBar(
        title: Text(
          '排行榜',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: SmartRefresher(
          header: WaterDropHeader(waterDropColor: Colors.blue,),
              onRefresh: () {
                _page = 1;
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
                    return Padding(
                      padding: EdgeInsets.only(left: 10, right: 10, top: 10),
                      child: Container(
                        child: InkWell(
                          onTap: () {
                            Navigator.of(context).push(new MaterialPageRoute(
                                builder: (BuildContext context) {
                              return NovelBookIntroView(_data[index].targetUrl);
                            }));
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Expanded(
                                flex: 1,
                                child: CachedNetworkImage(
                                  imageUrl: Uri.decodeComponent(
                                      _data[index]?.imageUrl),
                                  errorWidget: (context, url, error) {
                                    return new Icon(Icons.book);
                                  },
                                ),
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Expanded(
                                  flex: 4,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text(
                                        _data[index]?.title,
                                        style: TextStyle(
                                            fontSize: 18, color: Colors.black),
                                      ),
                                      Divider(
                                        height: 5,
                                        color: Colors.transparent,
                                      ),
                                      Text(
                                        _data[index]?.des,
                                        style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.grey[600]),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Divider(
                                        height: 5,
                                        color: Colors.transparent,
                                      ),
                                      Row(
                                        children: <Widget>[
                                          Icon(Icons.account_circle),
                                          SizedBox(
                                            width: 5,
                                          ),
                                         Expanded(child:  Text(
                                           _data[index]?.author,
                                           style: TextStyle(
                                               fontSize: 14,
                                               color: Colors.grey),
                                           maxLines: 1,
                                         ))
                                        ],
                                      ),
                                    ],
                                  ))
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
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

  //获取数据
  void _getData() async {
    String url = HomePage.inLsj
        ? '${_currentKey.startsWith('http')?'':ApiConstant.bookUrl2}$_currentKey&page=$_page'
        : "${ApiConstant.bookUrl3}${_currentKey}_$_page.html";
    String response = await NetUtil.getHtmlData(url);
    if(HomePage.inLsj){
      parseDataBookLsj(response);
    }else{
      parseDataBook(response);
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
      _isSearch = false;
      _currentKey = buttonBean.value;
      _refreshController.requestRefresh();
    }
  }

  void goToDetail(VideoListItem data) async {
    showLoading();
    String response = await NetUtil.getHtmlData(data.targetUrl);
    var doc = parse.parse(response);
    MovieBean movieBean = MovieBean();
    try {
      var tbody = doc.getElementsByClassName('ibox').first;
      movieBean.imgUrl =
          tbody.getElementsByTagName('img').first.attributes['src'];
      movieBean.info = tbody.getElementsByClassName('vodInfo').first.text;
      movieBean.name = data.title;
      movieBean.des = '';
      movieBean.originUrl = data.targetUrl;
      var vodplayinfo = doc.getElementsByClassName('vodplayinfo');
      vodplayinfo.forEach((element) {
        if (element.text.contains('.m3u8')) {
          var playEles = element.getElementsByTagName('input');
          for (var value in playEles) {
            var title = value.attributes['value'];
            if (title.contains('.m3u8')) {
              MovieItemBean itemBean = MovieItemBean();
              itemBean.name = '播放';
              itemBean.targetUrl = title;
              movieBean.list = [itemBean];
            }
          }
        }
      });
    } catch (e) {
      print(e);
    }

    Navigator.pop(context);
    Navigator.of(context)
        .push(new MaterialPageRoute(builder: (BuildContext context) {
      return MovieDetailPage(1, movieBean);
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

  void parseDataBook(String response) {
    var doc = parse.parse(response);
    try {
      var tdElements = doc.getElementById('main').getElementsByTagName('div');
      for (var value in tdElements) {
        var aEles = value.getElementsByTagName('a');
        var aEle = aEles.first;
        VideoListItem item = VideoListItem();
        String href = aEle.attributes['href'];
        item.imageUrl =
        aEle.getElementsByTagName('img').first.attributes['data-original'];
        item.title = CommonUtil.replaceStr(
            aEle.getElementsByClassName('title').first.text);
        item.author = CommonUtil.replaceStr(
            aEle.getElementsByClassName('author').first.text);
        item.des = CommonUtil.replaceStr(
            value.getElementsByClassName('review').first.text);
        item.targetUrl = href;
        _data.add(item);
      }
      if (_btns == null) {
        _btns = [];
        var sddms = doc
            .getElementsByClassName('sortChannel_nav')
            .first
            .getElementsByTagName('a');
        sddms.forEach((value1) {
          ButtonBean buttonBean = ButtonBean();
          buttonBean.title = value1.text;
          buttonBean.value = value1.attributes['href'].replaceAll('.html', '');
          _btns.add(buttonBean);
        });
      }
    } catch (e) {
      print(e);
    }
  }

  void parseDataBookLsj(String response) {
    var doc = parse.parse(response);
    try {
      var tdElements = doc.getElementById('jieqi_page_contents').getElementsByTagName('tr');
      if(tdElements != null && tdElements.length <= 0){
        var divElements = doc.getElementsByClassName('c_row cf');
        divElements.forEach((value) {
          var aEles = value.getElementsByTagName('a');
          var aEle = aEles.first;
          VideoListItem item = VideoListItem();
          String href = aEle.attributes['href'];
          item.imageUrl = value.getElementsByTagName('img').first.attributes['src'];
          item.title = CommonUtil.replaceStr(
              value.getElementsByClassName('c_subject').first.text);
          item.author = CommonUtil.replaceStr(
              value.getElementsByClassName('c_tag').first.text);
          item.des = CommonUtil.replaceStr(
              value.getElementsByClassName('c_description').first.text);
          item.targetUrl = href;
          _data.add(item);
        });
      }else{
        for (var value in tdElements) {
          var aEles = value.getElementsByTagName('a');
          var aEle = aEles.first;
          VideoListItem item = VideoListItem();
          String href = aEle.attributes['href'];
          item.imageUrl = '';
          item.title = CommonUtil.replaceStr(
              value.getElementsByTagName('td').first.text);
          item.author = CommonUtil.replaceStr(
              value.getElementsByTagName('td')[2].text);
          item.des = CommonUtil.replaceStr(
              value.text);
          item.targetUrl = href;
          _data.add(item);
        }
      }

      if (_btns == null) {
        _btns = [];
        var sddms = doc
            .getElementsByClassName('subnav')
            .first
            .getElementsByTagName('a');
        sddms.forEach((value1) {
          try {
            ButtonBean buttonBean = ButtonBean();
            buttonBean.title = value1.text;
            if(!buttonBean.title.contains('首页')){
                        buttonBean.value = value1.attributes['href'];
                        buttonBean.value = buttonBean.value.replaceAll('&page=1', 'replace');
                        _btns.add(buttonBean);
                      }
          } catch (e) {
            print(e);
          }
        });
      }
    } catch (e) {
      print(e);
    }
  }
}
