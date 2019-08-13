import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_parse_html/model/button_bean.dart';
import 'package:flutter_parse_html/model/movie_bean.dart';
import 'package:flutter_parse_html/model/video_list_item.dart';
import 'package:flutter_parse_html/mvp/presenter/movie_presenter.dart';
import 'package:flutter_parse_html/mvp/presenter/movie_presenter_impl.dart';
import 'package:flutter_parse_html/ui/video_play.dart';
import 'package:flutter_parse_html/widget/movie_search_bar.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:flutter_parse_html/ui/parse/htm_parse_page1.dart';
import 'package:flutter_parse_html/ui/movie/movie_detail_page.dart';
import 'package:flutter_parse_html/api/api_constant.dart';
import 'package:flutter_parse_html/ui/home_other_page.dart';
import 'package:unicorndial/unicorndial.dart';

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

  // 放大动画
  Animation<double> animationCurved;
  Animation<EdgeInsets> movement;
  List<VideoListItem> data = [];
  var _index = 1;
  RefreshController _refreshController;
  Future dialogCall;
  String _videoUrl = '${ApiConstant.movieBaseUrl}/index.php/vod/show/id/1/';
  String _title = '电影';
  List<UnicornButton> _childButtons;

  @override
  void initState() {
    super.initState();
    initUrl();
    _refreshController = new RefreshController();
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
    _presenter.loadMovieList(_videoUrl, _index,widget._type, true);
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
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: GestureDetector(
          onLongPress: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) {
              return HomeOtherPage();
            }));
          },
          child: Text(_title),
        ),
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.search),
              onPressed: () {
                // 调用写好的方法
                showSearch(context: context, delegate: SearchBar());
              })
        ],
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: SmartRefresher(
          controller: _refreshController,
          header: WaterDropMaterialHeader(),
          footer: ClassicFooter(),
          enablePullDown: true,
          enablePullUp: true,
          onRefresh: () {
            _index = 1;
            _presenter.loadMovieList(_videoUrl, _index,widget._type, true);
          },
          onLoading: () {
            _index++;
            _presenter.loadMovieList(_videoUrl, _index,widget._type, false);
          },
          child: GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 0.6,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10),
            itemBuilder: (BuildContext context, int index) {
              return getItem(index);
            },
            itemCount: data.length,
          ),
        ),
      ),
      floatingActionButton: UnicornDialer(
          backgroundColor: Color.fromRGBO(255, 255, 255, 0.6),
          parentButtonBackground: Colors.redAccent,
          orientation: UnicornOrientation.VERTICAL,
          parentButton: Icon(Icons.add),
          childButtons:
              _childButtons), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  Widget getItem(int position) {
    var item = data[position];
    return new GestureDetector(
      onTap: () {
        showLoading();
        _presenter.getVideoUrl(item.targetUrl);
      },
      child: new Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Expanded(
            child: Stack(
              children: <Widget>[
                ConstrainedBox(
                  child: CachedNetworkImage(
                    placeholder: (context, url) => new Icon(Icons.image),
                    errorWidget: (context, url, error) => new Icon(Icons.error),
                    imageUrl: item.imageUrl,
                    fit: BoxFit.cover,
                  ),
                  constraints: new BoxConstraints.expand(),
                ),
                Text(
                  item.des,
                  style: TextStyle(color: Colors.white),
                )
              ],
              alignment: AlignmentDirectional.bottomEnd,
            ),
          ),
          Text(
            '${item.title}',
            maxLines: 1,
          )
        ],
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
      List<VideoListItem> list, List<ButtonBean> btns, bool isRefresh) {
    if (isRefresh) {
      data.clear();
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
      return MovieDetailPage(1,movieBean);
    }));
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;

  void initUrl() {
    switch (widget._type) {
      case MovieType.movie:
        _title = '电影';
        _videoUrl = '${ApiConstant.movieBaseUrl}/index.php/vod/show/by/hits/id/1/';
        break;
      case MovieType.tv:
        _title = '电视剧';
        _videoUrl = '${ApiConstant.movieBaseUrl}/index.php/vod/show/by/hits/id/2/';
        break;
      case MovieType.variety:
        _title = '综艺';
        _videoUrl = '${ApiConstant.movieBaseUrl}/index.php/vod/show/by/hits/id/3/';
        break;
      case MovieType.comic:
        _title = '动漫';
        _videoUrl = '${ApiConstant.movieBaseUrl}/index.php/vod/show/by/hits/id/4/';
        break;
    }
  }

  void initChildBtn(List<ButtonBean> btns) {
    if (_childButtons == null) {
      _childButtons = List<UnicornButton>();
    } else {
      _childButtons.clear();
    }
    for (var value in btns) {
      _childButtons.add(UnicornButton(
          hasLabel: true,
          labelText: value.title,
          currentButton: FloatingActionButton(
            heroTag: value,
            mini: true,
            child: Icon(Icons.directions_car),
            onPressed: () {
              List<String> Strings = value.value.replaceAll('.html', '/').split('/id');
              value.value = '${Strings[0]}/by/hits/id${Strings[1]}';
              _videoUrl = '${ApiConstant.movieBaseUrl}${value.value}';
              _presenter.loadMovieList(_videoUrl, _index,widget._type, true);
            },
          )));
    }
  }

}

enum MovieType { movie, tv, variety, comic }
