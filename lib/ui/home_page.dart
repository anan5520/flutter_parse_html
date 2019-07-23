import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'live/live_page.dart';
import 'movie/movie_page.dart';

class HomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return HomeState();
  }
}

class HomeState extends State<HomePage>{
  List _tabData = [
    {'text': '电影', 'icon': Icon(Icons.movie)},
    {'text': '直播', 'icon': Icon(Icons.live_tv)}
  ];
  List<BottomNavigationBarItem> _bottomItems = [];
  int _currentIndex = 0;
  PageController _controller;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _initTables();
    _controller = new PageController();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      body: PageView(
        children: <Widget>[
          new MoviePage(),
          new LivePage(),
        ],
        controller: _controller,
        onPageChanged: _onPageChanged,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: _bottomItems,
        onTap: _itemOnPress,
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        fixedColor: Colors.blue,
      ),
    );
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _itemOnPress(int index) {
    _controller.animateToPage(index,
        duration: new Duration(seconds: 2), curve: new ElasticOutCurve(0.8));
  }


  void _initTables() {
    for (var value in _tabData) {
      _bottomItems.add(BottomNavigationBarItem(
          icon: value['icon'], title: Text('${value['text']}')));
    }
  }
}
