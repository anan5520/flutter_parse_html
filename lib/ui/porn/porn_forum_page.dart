import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_parse_html/model/porn_bean.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:flutter_parse_html/util/porn_helper.dart';
import 'porn_forum_content_page.dart';
class PornForumPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return PornForumState();
  }
}

class PornForumState extends State<PornForumPage>
    with SingleTickerProviderStateMixin {
  final List<String> _titles = [
    '自拍达人原创申请',
    '我爱我妻',
    'x趣分享',
    '两x健康',
  ];
  final List<String> _values = [
    '19',
    '21',
    '33',
    '34',
  ];

  late TabController _tabController;
  late PageController _pageController;
  var isPageCanChanged = true;

  @override
  void initState() {
    super.initState();
    _tabController = new TabController(length: _titles.length, vsync: this);
    _pageController = new PageController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('论坛'),
      ),
      body: Column(
        children: <Widget>[
          Container(
            color: Colors.white,
            height: 38,
            child: TabBar(
              unselectedLabelStyle:TextStyle(color: Colors.grey),
              labelStyle: TextStyle(color: Colors.black),
              controller: _tabController,
              isScrollable: true,
              onTap: (index) {
                onPageChange(index, p: _pageController);
              },
              tabs: _titles.map((item) {
                return Tab(
                  text: item,
                );
              }).toList(),
            ),
          ),
          Expanded(
            child: PageView.builder(
              itemCount: _titles.length,
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

  void onPageChange(int index, {PageController? p, TabController? t}) async {
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
    return ForumDisplayPage(_values[index]);
  }
}

class ForumDisplayPage extends StatefulWidget {
  final String _display;

  ForumDisplayPage(this._display);

  @override
  State<StatefulWidget> createState() {
    return ForumDisplayState();
  }
}

class ForumDisplayState extends State<ForumDisplayPage>
    with AutomaticKeepAliveClientMixin {
  List<PornForumItem> _data = [];
  late RefreshController _refreshController;
  int _page = 1;

  @override
  void initState() {
    super.initState();
    _refreshController = new RefreshController(initialRefresh: true);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return SmartRefresher(
      controller: _refreshController,
      onRefresh: () {
        _page = 1;
        _data.clear();
        getData();
      },
      onLoading: () {
        _page++;
        getData();
      },
      enablePullDown: true,
      enablePullUp: widget._display != 'index',
      child: ListView.separated(
        itemBuilder: getDisplayItem,
        itemCount: _data.length,
        separatorBuilder: (BuildContext context, int index) {
          return new Container(height: 1.0, color: Colors.grey);
        },
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;

  Widget getDisplayItem(BuildContext context, int index) {
    PornForumItem item = _data[index];
    return GestureDetector(onTap: (){
      Navigator.push(context, MaterialPageRoute(builder: (context){
        return PornForumContentPage(item.tid!,0,'');
      }));
    },child: Padding(
      padding: EdgeInsets.only(left: 5, right: 5, top: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(top: 5, bottom: 5),
            child: Text(
              '${item.title}   ${item.agreeCount == null || item.agreeCount!.isEmpty ? '' : item.agreeCount}(${item.replyCount}/${item.viewCount})',
              style: TextStyle(color: Colors.blue),
            ),
          ),
          Text(
            '${item.author}---${item.authorPublishTime}',
            style: TextStyle(color: Colors.grey, fontSize: 11),
          ),
          Padding(
            padding: EdgeInsets.only(top: 5, bottom: 5),
            child: Text(
              '${item.lastPostAuthor}---${item.lastPostTime}',
              style: TextStyle(color: Colors.grey, fontSize: 11),
            ),
          ),
        ],
      ),
    ),);
  }

  void getData() async {
    List<PornForumItem> list =
        await PornHelper.parsePornForum(widget._display, _page);
    _data.addAll(list);
    setState(() {
      _refreshController.refreshCompleted();
      _refreshController.loadComplete();
    });
  }
}
