import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_parse_html/book/main/book_view.dart';
import 'package:flutter_parse_html/book/main/main_page_view.dart';
import 'package:flutter_parse_html/book/widget/banner.dart';
import 'package:flutter_parse_html/download/history_page.dart';
import 'package:flutter_parse_html/model/button_bean.dart';
import 'package:flutter_parse_html/model/movie_bean.dart';
import 'package:flutter_parse_html/model/video_list_item.dart';
import 'package:flutter_parse_html/mvp/presenter/movie_presenter.dart';
import 'package:flutter_parse_html/mvp/presenter/movie_presenter_impl.dart';
import 'package:flutter_parse_html/net/net_util.dart';
import 'package:flutter_parse_html/resources/shared_preferences_keys.dart';
import 'package:flutter_parse_html/util/native_utils.dart';
import 'package:flutter_parse_html/util/shared_preferences.dart';
import 'package:flutter_parse_html/widget/dialog_page.dart';
import 'package:flutter_parse_html/widget/movie_search_bar.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:flutter_parse_html/ui/movie/movie_detail_page.dart';
import 'package:flutter_parse_html/api/api_constant.dart';
import 'package:flutter_parse_html/ui/home_other_page.dart';
import 'package:unicorndial/unicorndial.dart';

import '../home_page.dart';

class MoviePage extends StatefulWidget {
  final MovieType _type;

  MoviePage(this._type);

  @override
  _MyHomePageState createState() {
    _MyHomePageState view = _MyHomePageState();
    MoviePresenter presenter = MoviePresenterImpl(view);
    presenter.init();
    return view;
  }
}

class _MyHomePageState extends State<MoviePage>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin
    implements MovieView {
  AnimationController controller;
  CurvedAnimation curvedAnimation;
  MoviePresenter _presenter;
  SpUtil sp;

  // 放大动画
  Animation<double> animationCurved;
  Animation<EdgeInsets> movement;
  List<VideoListItem> data = [];
  var _index = 1;
  RefreshController _refreshController;
  String _videoUrl = '${ApiConstant.movieBaseUrl}/index.php/vod/show/id/1/';
  String _title = '电影';
  List<ButtonBean> _childButtons;
  int _type = -1; // 1 4k     2 ok
  String _currentKey = '';
  int buttonType = 0;
  List<VideoListItem> bannerList = [];
  bool _isType = false;

  @override
  void initState() {
    super.initState();
    _refreshController = new RefreshController(initialRefresh: true);
    controller = new AnimationController(
        duration: new Duration(seconds: 3), vsync: this);
    curvedAnimation =
        new CurvedAnimation(parent: controller, curve: Curves.elasticOut);
    animationCurved =
        new Tween(begin: 100.0, end: 350.0).animate(curvedAnimation);
    movement = EdgeInsetsTween(
      begin: EdgeInsets.only(top: 0.0),
      end: EdgeInsets.only(top: 100.0),
    ).animate(
      CurvedAnimation(
        parent: controller,
        curve: Interval(
          0.2,
          0.375,
          curve: Curves.fastOutSlowIn,
        ),
      ),
    );
    controller.addListener(() {
      print("ppp:${movement.value}");
      setState(() {});
    });
  }

  @override
  void dispose() {
    controller.dispose();
    _refreshController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: GestureDetector(
          onLongPress: () {
            if (HomePage.goToFuLi) {
              HomePage.inLsj = true;
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return HomeOtherPage();
              }));
            }
          },
          child: Text(_title),
        ),
        actions: <Widget>[
          new DropdownButtonHideUnderline(
              child: new DropdownButton(
                  hint: new Text(
                    '切换源(建议2)',
                    style: TextStyle(color: Colors.white),
                  ),
                  items: generateItemList(),
                  onChanged: (value) {
                    switch (value) {
                      case '1':
                        if (_type == 1) return;
                        _type = 1;
                        break;
                      case '2':
                        if (_type == 2) return;
                        _type = 2;
                        break;
                    }
                    if (sp != null)
                      sp.putString(SharedPreferencesKeys.movieType, '$_type');
                    initUrl();
                    _refreshController.requestRefresh();
                  })),
          IconButton(
              icon: Icon(Icons.book),
              onPressed: () {
                Navigator.push(context,
                    new MaterialPageRoute(builder: (context) {
                  return BookView();
                }));
              }),
          IconButton(
              icon: Icon(Icons.history),
              onPressed: () {
                Navigator.push(context,
                    new MaterialPageRoute(builder: (context) {
                  return HistoryPage();
                }));
              }),
          IconButton(
              icon: Icon(Icons.search),
              onPressed: () {
                // 调用写好的方法
                showSearch(context: context, delegate: SearchBar(_type));
              })
        ],
      ),
      body: Container(
          color: Color(0xffeeeeee),
          // Center is a layout widget. It takes a single child and positions it
          // in the middle of the parent.
          child: Stack(
            children: [
              SmartRefresher(
                controller: _refreshController,
                header: WaterDropMaterialHeader(),
                footer: ClassicFooter(),
                enablePullDown: true,
                enablePullUp: true,
                onRefresh: () {
                  _index = buttonType == 1 ? _index : 1;
                  initType(false);
//            _presenter.loadMovieList(
//                _videoUrl, _index, widget._type, true, _type);
                },
                onLoading: () {
                  _index++;
                  _presenter.loadMovieList(
                      _videoUrl, _index, widget._type, false, _type,isType:_isType);
                },
                child: _type == 1 ? getGridView() : getListView(),
              ),
              Positioned(
                bottom: 20,
                right: 1,
                child: Column(
                  children: [
                    RaisedButton(
                      padding: EdgeInsets.all(20),
                      color: Colors.blue,
                      textColor: Colors.white,
                      elevation: 10,
                      splashColor: Colors.grey,
                      shape: CircleBorder(side: BorderSide(color: Colors.blue)),
                      onPressed: () {
                        NativeUtils.goToDouYin("0");
                      },
                      child: Text("抖音"),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 10),
                      child: RaisedButton(
                        padding: EdgeInsets.all(17),
                        color: Colors.blue,
                        textColor: Colors.white,
                        elevation: 10,
                        splashColor: Colors.grey,
                        shape:
                            CircleBorder(side: BorderSide(color: Colors.blue)),
                        onPressed: () {
                          // NativeUtils.goToDouYin("1");
                          _showDialog();
                        },
                        child: Icon(Icons.add),
                      ),
                    )
                  ],
                ),
              )
            ],
          )),
    );
  }

  void _showDialog() async {
    ButtonBean buttonBean = await showDialog(
        context: context,
        builder: (context) {
          return new AlertDialog(
            content: GridViewDialog(_childButtons),
          );
        });
    if (buttonBean != null) {
      if (buttonBean.type == 1) {
        _index = buttonBean.page;
        buttonType = 1;
      } else {
        buttonType = 0;
        _currentKey = buttonBean.value;
      }
      if (_type == 1) {
        if (buttonBean.type == 0) {
          _videoUrl = '${ApiConstant.movieBaseUrl}${buttonBean.value}';
        }
        _refreshController.requestRefresh();
      } else {
        if (buttonBean.type == 0) {
          _isType = true;
          _videoUrl = '${ApiConstant.movieBaseUrl1}${buttonBean.value.replaceAll('--------.html', '')}';
        }
        _refreshController.requestRefresh();
      }
    }
  }

  Widget getItem(int position) {
    var item = data[position];
    return new GestureDetector(
      onTap: () {
        showLoading();
        _presenter.getVideoUrl(item.targetUrl, _type);
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(5),
        child: Container(
          color: Colors.white,
          child: new Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Expanded(
                child: Stack(
                  children: <Widget>[
                    ConstrainedBox(
                      child: CachedNetworkImage(
                        placeholder: (context, url) => new Icon(Icons.image),
                        errorWidget: (context, url, error) =>
                            new Icon(Icons.error),
                        imageUrl: item.imageUrl,
                        fit: BoxFit.cover,
                      ),
                      constraints: new BoxConstraints.expand(),
                    )
                  ],
                  alignment: AlignmentDirectional.bottomEnd,
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
  loadMovieListFail() {
    _refreshController.refreshCompleted();
    _refreshController.loadComplete();
  }

  @override
  loadMovieListSuc(
      List<VideoListItem> list, List<ButtonBean> btns, bool isRefresh,
      {List<VideoListItem> bannerList}) {
    if (isRefresh) {
      data.clear();
    }
    this.bannerList?.clear();
    if (bannerList != null) {
      for (var i = 0;
          i < (bannerList.length < 15 ? bannerList.length : 15);
          i++) {
        this.bannerList?.add(bannerList[i]);
      }
    }
    _refreshController.refreshCompleted();
    _refreshController.loadComplete();
    data.addAll(list);
    initChildBtn(btns);
    setState(() {});
  }

  @override
  setPresenter(MoviePresenter presenter) {
    _presenter = presenter;
  }

  @override
  getVideoUrlSuc(MovieBean movieBean) {
    Navigator.pop(context);
    Navigator.of(context)
        .push(new MaterialPageRoute(builder: (BuildContext context) {
      return MovieDetailPage(_type == 2?9:1, movieBean);
    }));
  }

  @override
  bool get wantKeepAlive => true;

  void initUrl() {
    if (_type == 1) {
      switch (widget._type) {
        case MovieType.movie:
          _title = '电影';
          _videoUrl = '${ApiConstant.movieBaseUrl}/list/?5.html';
          break;
        case MovieType.tv:
          _title = '电视剧';
          _videoUrl = '${ApiConstant.movieBaseUrl}/list/?2.html';
          break;
        case MovieType.variety:
          _title = '综艺';
          _videoUrl = '${ApiConstant.movieBaseUrl}/list/?3.html';
          break;
        case MovieType.comic:
          _title = '动漫';
          _videoUrl = '${ApiConstant.movieBaseUrl}/list/?4.html';
          break;
      }
    } else {
      switch (widget._type) {
        case MovieType.movie:
          _title = '电影';
          _videoUrl = '${ApiConstant.movieBaseUrl1}/vodtype/dianying-';
          break;
        case MovieType.tv:
          _title = '电视剧';
          _videoUrl = '${ApiConstant.movieBaseUrl1}/vodtype/lianxuju-';
          break;
        case MovieType.variety:
          _title = '综艺';
          _videoUrl = '${ApiConstant.movieBaseUrl1}/vodtype/zongyi-';
          break;
        case MovieType.comic:
          _title = '动漫';
          _videoUrl = '${ApiConstant.movieBaseUrl1}/vodtype/dongman-';
          break;
      }
    }
  }

  void initChildBtn(List<ButtonBean> btns) {
    if (_childButtons == null) {
      _childButtons = List<ButtonBean>();
    } else {
      _childButtons.clear();
    }
    for (var value in btns) {
      _childButtons.add(value);
    }
  }

  getGridView() {
    return SingleChildScrollView(
      child: Column(
        children: [
          widget._type == MovieType.movie
              ? SizedBox(
                  height: 250,
                  child: Swiper(
                    autoplay: true,
                    autoplayDelay: 3000,
                    loop: true,
                    itemCount: bannerList.length,
                    viewportFraction: 0.5,
                    scale: 0.75,
                    itemBuilder: (context, index) {
                      return geBannerItem(index);
                    },
                  ),
                )
              : Container(),
          GridView.builder(
            physics: new NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            padding: EdgeInsets.all(10),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 0.6,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10),
            itemBuilder: (BuildContext context, int index) {
              return getItem(index);
            },
            itemCount: data.length,
          )
        ],
      ),
    );
  }

  getListView() {
    return  GridView.builder(
      shrinkWrap: true,
      padding: EdgeInsets.all(10),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 0.6,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10),
      itemBuilder: (BuildContext context, int index) {
        return getItem(index);
      },
      itemCount: data.length,
    ) ;
  }

  generateItemList() {
    List<DropdownMenuItem> items = new List();
    DropdownMenuItem item1 =
        new DropdownMenuItem(value: '1', child: new Text('数据源1'));
    DropdownMenuItem item2 =
        new DropdownMenuItem(value: '2', child: new Text('数据源2'));
    items.add(item1);
    items.add(item2);
    return items;
  }

  void initType(bool isInit) async {
    if (_type == -1) {
      sp = await SpUtil.getInstance();
      String ty = await sp.getString(SharedPreferencesKeys.movieType);
      if (ty != null) {
        int type = int.parse(ty);
        _type = type == null ? 2 : type;
      } else {
        _type = 2;
      }
    }

    if (_currentKey.isEmpty) initUrl();

    _presenter?.loadMovieList(_videoUrl, _index, widget._type, true, _type,isType:_isType);
  }

  geBannerItem(int index) {
    var item = bannerList[index];
    return new GestureDetector(
      onTap: () {
        showLoading();
        _presenter.getVideoUrl(item.targetUrl, _type);
      },
      child: Padding(
        padding: EdgeInsets.only(left: 10, right: 10, top: 20),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(5),
          child: Container(
            color: Colors.white,
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
        ),
      ),
    );
  }
}

enum MovieType { movie, tv, variety, comic }
