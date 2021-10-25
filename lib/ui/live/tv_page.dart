import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_parse_html/api/api_constant.dart';
import 'package:flutter_parse_html/model/tv_bean_entity.dart';
import 'package:flutter_parse_html/net/net_util.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:video_player/video_player.dart';

class TvPage extends StatefulWidget {
  // IjkMediaController player ;
  @override
  State<StatefulWidget> createState() {
    return TvState();
  }


  // startOrStopPlay(bool start) {
  //   if (player != null) {
  //     if (start) {
  //       player.play();
  //     } else {
  //       player.stop();
  //     }
  //   }
  // }
}

class TvState extends State<TvPage>
    with AutomaticKeepAliveClientMixin, TickerProviderStateMixin {
  TabController _tabController;
  PageController _pageController;
  var isPageCanChanged = true;
  List<String> _titleName = [];
  List<TvBeanEntity> _data = [];

  @override
  void initState() {
    super.initState();
    // widget.player = IjkMediaController();
    // _tabController = TabController(initialIndex :0,length: _data.length, vsync: this);
    _pageController = PageController();
    _getData();
  }

  @override
  Widget build(BuildContext context) {

    super.build(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('电视直播'),
      ),
      body: Column(
        children: <Widget>[
          SizedBox(
            height: 200,
            child: Container(),
          ),
          Expanded(
            child: Column(
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
                    tabs: _data.map((item) {
                      return Tab(
                        text: item.chineseName,
                      );
                    }).toList(),
                  ),
                ),
                Expanded(
                  child: PageView.builder(
                    itemCount: _data.length,
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
          )
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;

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
    TvBeanEntity _tvBean = _data[index];
    List<TvBeanChannel> _list = _tvBean.channels;
    return GridView.builder(
      padding: EdgeInsets.all(10),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          childAspectRatio: 2.0,),
        itemCount: _list.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: (){
              String url = '';
              TvBeanChannel _tvBean = _list[index];
              if(_tvBean.url.contains('.m3u8')){
                url = _tvBean.url;
              }else{
                _tvBean.streams.forEach((f){
                  if(f.contains('.m3u8')){
                    url = f;
                  }
                });
              }
              if(url.isNotEmpty){
                // startVideo(url);
              }else{
                Fluttertoast.showToast(msg: '当前链接不可用');
              }

            },
            child:  Container(
              color: Colors.blue,
              child: Center(
                child: Text('${_list[index].name}',style: TextStyle(color: Colors.white),),
              ),
            ),
          );
        });
  }

  void _getData() async{
    String response = await NetUtil.getHtmlData(ApiConstant.tvUrl,isWeb: false);
    List<TvBeanEntity> _list = [];
    try {
      List<dynamic> jsonMap = json.decode(response);
      jsonMap.forEach((v) {
            _data.add(TvBeanEntity.fromJson(v));
          });
      setState(() {
        _tabController = TabController(length: _data.length, vsync: this);

      });
    } catch (e) {
      print(e);
    }
  }


  // void startVideo(String url)async {
  //   await widget.player.reset();
  //   await widget.player.setNetworkDataSource(url,autoPlay: true);
  // }
  //
  // @override
  // void dispose() async{
  //   // TODO: implement dispose
  //   await widget.player.dispose();
  //   super.dispose();
  //
  // }
}
