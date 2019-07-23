import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_parse_html/model/video_list_item.dart';
import 'package:flutter_parse_html/mvp/presenter/movie_presenter.dart';
import 'package:flutter_parse_html/mvp/presenter/movie_presenter_impl.dart';
import 'package:flutter_parse_html/ui/video_play.dart';
import 'package:flutter_parse_html/widget/movie_search_bar.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:flutter_parse_html/ui/parse/htm_parse_page1.dart';

class MoviePage extends StatefulWidget {

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".


  @override
  _MyHomePageState createState() {
    _MyHomePageState view = _MyHomePageState();
    MoviePresenter presenter = MoviePresenterImpl(view);
    presenter.init();
    return view;
  }
}

class _MyHomePageState extends State<MoviePage>   with TickerProviderStateMixin,AutomaticKeepAliveClientMixin
    implements MovieView {
  int _counter = 0;
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
  final String _videoUrl = 'http://4kbo.com/index.php/vod/show/id/';

  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
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
    _presenter.loadMovieList(_videoUrl, _index, true);
  }

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    controller.dispose();
    _refreshController.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
        title: Text('电影'),
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
            _presenter.loadMovieList(_videoUrl, _index, true);
          },
          onLoading: () {
            _index++;
            _presenter.loadMovieList(_videoUrl, _index, false);
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context)
              .push(new MaterialPageRoute(builder: (BuildContext context) {
            return HtmlParsePage1();
          }));
        },
        tooltip: 'Increment',
        child: Icon(Icons.add_alarm),
      ), // This trailing comma makes auto-formatting nicer for build methods.
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
            child: CachedNetworkImage(
              imageUrl: item.imageUrl,
              fit: BoxFit.cover,
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
  loadMovieListSuc(List<VideoListItem> list, bool isRefresh) {
    if (isRefresh) {
      data.clear();
    }
    _refreshController.refreshCompleted();
    _refreshController.loadComplete();
    data.addAll(list);
    setState(() {});
  }

  @override
  setPresenter(MoviePresenter presenter) {
    _presenter = presenter;
  }

  @override
  getVideoUrlSuc(String url) {
    Navigator.pop(context);
    Navigator.of(context)
        .push(new MaterialPageRoute(builder: (BuildContext context) {
      return VideoPlayPage(url);
    }));
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
