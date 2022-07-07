import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_parse_html/model/girl_bean.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_parse_html/util/girl_helper.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class GirlPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return GirlState();
  }
}

class GirlState extends State<GirlPage> with SingleTickerProviderStateMixin {
  List<String> _titleValue = [
    "",
    "hot",
    "best",
    "xinggan",
    "japan",
    "taiwan",
    "mm"
  ];
  List<String> _titleName = ["主页", "最热", "推荐", "性感妹子", "日本妹子", "台湾妹子", "清纯妹子"];

  TabController _tabController;
  PageController _pageController;
  var isPageCanChanged = true;

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
        title: Text('美图'),
      ),
      body: Column(
        children: <Widget>[
          Container(
            color: Colors.blue,
            height: 38,
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
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
    return GirlItemPage(_titleValue[index]);
  }
}

class GirlItemPage extends StatefulWidget {
  final String _tag;

  GirlItemPage(this._tag);

  @override
  State<StatefulWidget> createState() {
    return GirlItemState();
  }
}

class GirlItemState extends State<GirlItemPage>
    with AutomaticKeepAliveClientMixin {
  List<GirlBean> _data = [];
  RefreshController _refreshController;
  int _page = 1;

  @override
  void initState() {
    _refreshController = new RefreshController(initialRefresh: true);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return SmartRefresher(
      header: MaterialClassicHeader(),
      footer: ClassicFooter(),
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
      enablePullUp: true,
      child: GridView.builder(
        itemCount: _data.length,
          gridDelegate:
              SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2
              ,crossAxisSpacing: 5,
                  childAspectRatio: 0.6,
              mainAxisSpacing: 5),
          itemBuilder: getDisplayItem),
    );
  }

  @override
  bool get wantKeepAlive => true;

  Widget getDisplayItem(BuildContext context, int index) {
    GirlBean girlBean = _data[index];
    return GestureDetector(
      onTap: () async{
        showLoading();
        List<String> imgs =  await GirlHelper.getGirlDetail('${girlBean.id}');
        Navigator.pop(context);
        Navigator.pushNamed(context, "/ImagePage", arguments: {"list": imgs,'addHeader':true});
      },
      child: Column(
        children: <Widget>[
          Expanded(
            child: CachedNetworkImage(
              height: girlBean.height,
              width: girlBean.width,
              httpHeaders: {
                'Accept-Language': 'zh-CN,zh;q=0.9,zh-TW;q=0.8',
//                'Host': 'i.meizitu.net',
                'Sec-Fetch-Mode': 'no-cors',
                'User-Agent':
                'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/63.0.3239.132 Safari/537.36',
                'Referer': 'http://www.mzitu.com/'
              },
              imageUrl: girlBean.thumbUrl,
              fit: BoxFit.fitWidth,
            ),
          ),
          Text(girlBean.name),
        ],
      ),
    );
  }

  void getData() async {
    List<GirlBean> list = await GirlHelper.getGirlList(widget._tag, _page);
    _data.addAll(list);
    print(_data.toString());
    setState(() {
      _refreshController.refreshCompleted();
      _refreshController.loadComplete();
    });
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
}
