import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_parse_html/model/video_list_item.dart';
import 'package:flutter_parse_html/ui/movie/movie_detail_page.dart';
import 'package:flutter_parse_html/ui/xianfeng/xian_feng_page.dart';
import 'package:flutter_parse_html/ui/xianfeng/xian_feng_page3.dart';
import 'package:flutter_parse_html/ui/xianfeng/xian_feng_page5.dart';
import 'package:flutter_parse_html/ui/xianfeng/xian_feng_page6.dart';
import 'package:flutter_parse_html/util/native_utils.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:flutter_parse_html/model/button_bean.dart';
import 'package:flutter_parse_html/net/net_util.dart';
import 'package:flutter_parse_html/api/api_constant.dart';
import 'package:html/parser.dart' as parse;
import 'package:flutter_parse_html/widget/dialog_page.dart';
import 'package:flutter_parse_html/model/movie_bean.dart';

class XianFeng2Page extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return XianFeng2tate();
  }
}

class XianFeng2tate extends State<XianFeng2Page>
    with SingleTickerProviderStateMixin {
  TabController _tabController;
  PageController _pageController;
  var isPageCanChanged = true;
  List<String> _titleValue = [
    "index_1_1_",
    "index_2_1_",
    "index_3_1_",
    "index_4_1_",
    "index_4_1_",
    "index_4_1_",
    "index_4_1_",
  ];
  List<String> _titleName = ['视频1','视频2','视频3','视频4'];

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
        title: Text('先锋2'),
      ),
      body: Column(
        children: <Widget>[
          Container(
            color: Colors.blue,
            height: 38,
            width: double.infinity,
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
    if(index == 0)
      return XianFeng6Page();
    if(index == 1)
      return XianFengPage(0);
    if(index == 2)
      return XianFengPage(1);
    if(index == 3)
      return XianFeng3Page();
  }
}

class XianFeng2ItemPage extends StatefulWidget {
  final String _type;

  XianFeng2ItemPage(this._type);

  @override
  State<StatefulWidget> createState() {
    return new XianFeng2ItemState();
  }
}

class XianFeng2ItemState extends State<XianFeng2ItemPage>
    with AutomaticKeepAliveClientMixin {
  List<VideoListItem> _data = [];
  List<ButtonBean> _btns;

  RefreshController _refreshController;
  int _page = 1,buttonType = 0;
  String _currentKey = '/sexsj/';

  @override
  void initState() {
    _refreshController = new RefreshController(initialRefresh: true);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      body: SmartRefresher(
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
        header: WaterDropMaterialHeader(),
        controller: _refreshController,
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 5,
              mainAxisSpacing: 5,
              childAspectRatio: 0.6),
          itemBuilder: getItem,
          itemCount: _data.length,
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
    String response = await NetUtil.getHtmlData(
        ApiConstant.xianFeng2Url + _currentKey + '${widget._type}$_page.html');
    var doc = parse.parse(response);
    var btnElements = doc
        .getElementsByClassName('g_subnav_movie fl')
        .first
        .getElementsByTagName('dd');
    try {
      if (_btns == null) {
        _btns = [];
        for (var value in btnElements) {
          var ele = value.getElementsByTagName('a').first;
          ButtonBean buttonBean = ButtonBean();
          buttonBean.title = ele.text;
          buttonBean.value = ele.attributes['href'];
          _btns.add(buttonBean);
        }
      }
      var tbodys = doc
          .getElementsByClassName('list clearfix ')
          .first
          .getElementsByTagName('li');
      for (var value1 in tbodys) {
        VideoListItem item = VideoListItem();
        var ele = value1.getElementsByClassName('img_wrap').first;
        item.title = ele.attributes['title'];
        item.targetUrl = ApiConstant.xianFeng2Url + ele.attributes['href'];
        var imgEle = ele.getElementsByTagName('img').first;
        String imgKey = imgEle.attributes.containsKey('data-original')?"imgEle.attributes.containsKey('data-original')":"src";
        item.imageUrl = ApiConstant.xianFeng2Url + imgEle.attributes[imgKey];
        _data.add(item);
      }
    } catch (e) {
      print(e);
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
        buttonType = 0;
        _currentKey = buttonBean.value;
      }
      _refreshController.requestRefresh();
    }
  }

  void goToDetail(VideoListItem data) async {
    showLoading();
    String response = await NetUtil.getHtmlData(data.targetUrl);
    Navigator.pop(context);
    var doc = parse.parse(response);
    MovieBean movieBean = MovieBean();
    movieBean.info = doc.getElementsByClassName('detail fl').first.text;
    movieBean.imgUrl = data.imageUrl;
    var listEles = doc
        .getElementsByClassName('mlist')
        .first
        .getElementsByTagName('a');
    List<MovieItemBean> list = [];
    for (var value in listEles) {
      MovieItemBean movieItemBean = MovieItemBean();
      movieItemBean.targetUrl = ApiConstant.xianFeng2Url +  value.attributes['href'];
      movieItemBean.name = value.text;
      list.add(movieItemBean);
    }
    movieBean.name = data.title;
    movieBean.list = list;
    Navigator.of(context)
        .push(new MaterialPageRoute(builder: (BuildContext context) {
      return MovieDetailPage(4, movieBean);
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

  Widget getItem(BuildContext context, int index) {
    return new GestureDetector(
      onTap: () {
        goToDetail(_data[index]);
      },
      child: new Column(
        children: <Widget>[
          Expanded(
            child: CachedNetworkImage(
              placeholder: (context, url) => new Icon(Icons.image),
              errorWidget: (context, url, error) => new Icon(Icons.error),
              imageUrl: _data[index].imageUrl,
              fit: BoxFit.cover,
            ),
          ),
          Text(
            _data[index].title,
            maxLines: 1,
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  @override
  bool get wantKeepAlive => true;
}
