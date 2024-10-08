import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_parse_html/resources/shared_preferences_keys.dart';
import 'package:flutter_parse_html/ui/gif/gif_page.dart';
import 'package:flutter_parse_html/ui/home_other_page.dart';
import 'package:flutter_parse_html/ui/live/tv_page.dart';
import 'package:flutter_parse_html/ui/parse/abj_list_page.dart';
import 'package:flutter_parse_html/ui/parse/book_list3_page.dart';
import 'package:flutter_parse_html/ui/parse/book_list_4_page.dart';
import 'package:flutter_parse_html/ui/parse/dong_man_page.dart';
import 'package:flutter_parse_html/util/shared_preferences.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:installed_apps/installed_apps.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:umeng_common_sdk/umeng_common_sdk.dart';
import 'live/live_page.dart';
import 'movie/movie_page.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_parse_html/net/net_util.dart';
import 'package:flutter_parse_html/api/api_constant.dart';
import 'package:flutter_parse_html/model/api_bean.dart';
import 'dart:io';
import 'dart:convert';
import 'package:flutter_parse_html/util/native_utils.dart';
import 'package:package_info/package_info.dart';

class HomePage extends StatefulWidget {
  static bool goToFuLi = false;
  static bool inLsj = false;

  @override
  State<StatefulWidget> createState() {
    initUrl();
    UmengCommonSdk.initCommon('5ddc8b37570df395b0000af1', '', 'lsj');
    return HomeState();
  }

  void initUrl() async {
    SpUtil sp = await SpUtil.getInstance();
    String? localStr = sp.getString(SharedPreferencesKeys.urls);
    UrlsBean? localUrl;
    if (localStr != null && localStr.isNotEmpty) {
      localUrl = UrlsBean.fromJson(json.decode(localStr));
      updateUrl(localUrl);
    }
//    var response = await http.get(ApiConstant.urlsUrl);
//    Utf8Decoder utf8decoder = new Utf8Decoder();
//    var body = utf8decoder.convert(response.bodyBytes);
    String urlJson =
    await NetUtil.getHtmlData(ApiConstant.urlsUrl, isWeb: true);
    UrlsBean urlsBean = UrlsBean.fromJson(json.decode(urlJson));
    goToFuLi = urlsBean.goToFuLi!;
    if (localUrl == null || urlsBean.version !> localUrl.version!) {
      sp.putString(SharedPreferencesKeys.urls, json.encode(urlsBean));
      updateUrl(urlsBean);
      if (urlsBean.isUpSiSeUrl != null && urlsBean.isUpSiSeUrl!) {
        sp.putString(SharedPreferencesKeys.htmlUrl1, '');
      }
    }
  }

  //更新地址
  void updateUrl(UrlsBean urls) {
    ApiConstant.movieBaseUrl = urls.s4kMovie!;
    ApiConstant.pornForumBaseUrl = urls.pornForum!;
    ApiConstant.pornBaseUrl = urls.pornVideo!;
    ApiConstant.siSeUrl = urls.lsjUrl!;
    ApiConstant.liveUrl = urls.liveUrl!;
    ApiConstant.searchUrl = urls.searchUrl!;
    ApiConstant.fanHao1 = urls.fanHao1!;
    ApiConstant.fanHao2 = urls.fanHao2!;
    ApiConstant.fanHao3 = urls.fanHao3!;
    ApiConstant.xianFengUrl = urls.xianFengUrl!;
    ApiConstant.videoList1Url = urls.videoList1Url!;
    ApiConstant.videoList4Url = urls.videoList4Url != null
        ? urls.videoList4Url!
        : ApiConstant.videoList4Url;
    ApiConstant.videoList5Url = urls.videoList5Url != null
        ? urls.videoList5Url!
        : ApiConstant.videoList5Url;
    ApiConstant.videoList6Url = urls.videoList6Url != null
        ? urls.videoList6Url!
        : ApiConstant.videoList6Url;
    ApiConstant.videoList7Url = urls.videoList7Url != null
        ? urls.videoList7Url!
        : ApiConstant.videoList7Url;
    ApiConstant.videoList8Url = urls.videoList8Url != null
        ? urls.videoList8Url!
        : ApiConstant.videoList8Url;
    ApiConstant.videoList9Url = urls.videoList9Url != null
        ? urls.videoList9Url!
        : ApiConstant.videoList9Url;
    ApiConstant.videoList10Url = urls.videoList10Url != null
        ? urls.videoList10Url!
        : ApiConstant.videoList10Url;
    ApiConstant.videoList18Url = urls.videoList18Url != null
        ? urls.videoList18Url!
        : ApiConstant.videoList18Url;
    ApiConstant.yaSeUrl =
        urls.yaSeUrl != null ? urls.yaSeUrl! : ApiConstant.yaSeUrl;
    ApiConstant.videoList3Url =
        (urls.videoList3Url != null && urls.videoList3Url != "")
            ? urls.videoList3Url!
            : ApiConstant.videoList3Url;
    ApiConstant.parse2Url =
        urls.parse2Url != null ? urls.parse2Url! : ApiConstant.parse2Url;
    ApiConstant.parse3Url =
        urls.parse3Url != null ? urls.parse3Url! : ApiConstant.parse3Url;
    ApiConstant.parse4Url =
        urls.parse4Url != null ? urls.parse4Url! : ApiConstant.parse4Url;
    ApiConstant.parse5Url =
        urls.parse5Url != null ? urls.parse5Url! : ApiConstant.parse5Url;
    ApiConstant.movieBaseUrl1 = urls.movieBaseUrl1 != null
        ? urls.movieBaseUrl1!
        : ApiConstant.movieBaseUrl1;
    ApiConstant.gif1 = urls.gif1 != null ? urls.gif1! : ApiConstant.gif1;
    ApiConstant.gif2 = urls.gif2 != null ? urls.gif2! : ApiConstant.gif2;
    ApiConstant.xianFeng3Url = urls.xianFeng3Url != null
        ? urls.xianFeng3Url!
        : ApiConstant.xianFeng3Url;
    ApiConstant.xianFeng4Url = urls.xianFeng4Url != null
        ? urls.xianFeng4Url!
        : ApiConstant.xianFeng4Url;
    ApiConstant.xianFeng5Url = urls.xianFeng5Url != null
        ? urls.xianFeng5Url!
        : ApiConstant.xianFeng5Url;
    ApiConstant.douYinUrl =
        urls.douYinUrl != null ? urls.douYinUrl! : ApiConstant.douYinUrl;
    ApiConstant.douYin2Url =
        urls.douYin2Url != null ? urls.douYin2Url! : ApiConstant.douYin2Url;
    ApiConstant.abjUrl = urls.abjUrl != null ? urls.abjUrl! : ApiConstant.abjUrl;
  }
}

class HomeState extends State<HomePage> with WidgetsBindingObserver {
  List _tabData = [
    {'text': '电影', 'icon': Icon(Icons.movie)},
    {'text': '图片', 'icon': Icon(Icons.photo_camera_outlined)},
    // {'text': '电视直播', 'icon': Icon(Icons.tv)},
    {'text': '动漫', 'icon': Icon(Icons.ondemand_video)},
    {'text': '电视剧', 'icon': Icon(Icons.live_tv)},
    {'text': '综艺', 'icon': Icon(Icons.play_circle_filled)},
  ];
  List<BottomNavigationBarItem> _bottomItems = [];
  int _currentIndex = 0;
  late PageController _controller;

  late TvPage tvPage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    NativeUtils.onResume();
    _initTables();
    initNotice();
    if (!kIsWeb && Platform.isAndroid) {
      initUpdate();
    }
    tvPage = new TvPage();
    _controller = new PageController();
    checkAndGetPermission();
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context);
    return Scaffold(
      body: PageView(
        children: <Widget>[
//          HomeOtherPage(),
//          MultiProvider(
//              providers: providers,
//              child: Consumer<ConfigProvider>(builder:
//                  (BuildContext context, ConfigProvider appInfo, Widget child) {
//                return MaterialApp(
//                    title: '书库',
//                    theme: ThemeData(primaryColor:Colors.white,),
////              home: NovelBookIntroView("592fe687c60e3c4926b040ca"));
//                    home: MainPageView());
//              })),
//           new VideoList6Page(''),
//           PornPage.type(1),
//           VideoList3Page(),
//           VideoList10Page(),
//           VideoLiFan2Page(),
//         PornForumPage(),
//         VideoList13Page(),
//         BookList4Page(''),
//           GifListLsjPage(),
//         PornHomePage(),
//           VideoList9Page(),
          new MoviePage(MovieType.movie),
          new GifPage(),
          // tvPage,
//          new DownloadPage(),
//          new PornHomePage(),
          DongManPage(),
          new MoviePage(MovieType.tv),

//          new DownloadPage(),

          new MoviePage(MovieType.variety),
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
      if (tvPage != null) {
        // tvPage.startOrStopPlay(index == 1);
      }
      _currentIndex = index;
    });
  }

  void _itemOnPress(int index) {
    _controller.animateToPage(index,
        duration: new Duration(milliseconds: 500), curve: Curves.ease);
  }

  void _initTables() {
    for (var value in _tabData) {
      _bottomItems.add(BottomNavigationBarItem(
          icon: value['icon'], label: '${value['text']}'));
    }
  }

  void initNotice() async {
    String jsonStr = await NetUtil.getHtmlData(ApiConstant.noticeUrl);
    NoticeBean noticeBean = NoticeBean.fromJson(json.decode(jsonStr));
    if (noticeBean.isShow!) {
      showDialog(
          context: context,
          barrierDismissible: noticeBean.canCancel!,
          builder: (context) {
            return AlertDialog(
              title: Text(noticeBean.title!),
              content: Text(noticeBean.content!),
              contentPadding: EdgeInsets.all(10),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    if (!noticeBean.canCancel!) {
                      Navigator.pop(context);
                    }
                  },
                  child: Text(
                    "确定",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            );
          });
    }
  }

  void initUpdateKey() async {
    String jsonStr = await NetUtil.getHtmlData(ApiConstant.upDateKeyUrl);
    SpUtil sp = await SpUtil.getInstance();
    UpdateKey updateKey = UpdateKey.fromJson(json.decode(jsonStr));
    ApiConstant.xVideosKey = updateKey.xVideosKey!;
    bool isShowDialog = true;
    if(updateKey.onlyShowOne ?? false){
      isShowDialog = sp.getBool(updateKey.spKey!) ?? true;
    }else{
      int now = DateTime.now().millisecondsSinceEpoch;
      int spTime =sp.getInt("showActivityDialog") ?? 0;
      int time = now - spTime;
      isShowDialog = time > 18 * 60 * 60 * 1000;
    }
    if(isShowDialog){
      if(updateKey.isJd ?? true){
        isShowDialog = await InstalledApps.getAppInfo('com.jingdong.app.mall').then((value) => value.versionName?.isNotEmpty ?? false);
      } else{
        isShowDialog = await InstalledApps.getAppInfo('com.taobao.taobao').then((value) => value.versionName?.isNotEmpty ?? false);
      }
    }
    if(updateKey.copyKey!.isNotEmpty && isShowDialog){
      sp.putBool(updateKey.spKey!, false);
      sp.putInt('showActivityDialog', (DateTime.now().millisecondsSinceEpoch));
      _showActivityDialog(updateKey);
    }
  }

  void initUpdate() async {
    String jsonStr = await NetUtil.getHtmlData(ApiConstant.updateUrl);
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    UpdateBean updateBean = UpdateBean.fromJson(json.decode(jsonStr));
    int version = int.parse(packageInfo.buildNumber);
    if (updateBean.version !> version) {
      showDialog(
          context: context,
          barrierDismissible: updateBean.isForce!,
          builder: (context) {
            return AlertDialog(
              title: Text('提示'),
              content: Text(updateBean.des!),
              contentPadding: EdgeInsets.all(10),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    NativeUtils.toBrowser(updateBean.url!);
                  },
                  child: Text(
                    "更新",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            );
          });
    }else{
      initUpdateKey();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.resumed:
        NativeUtils.onResume();
        break;
      case AppLifecycleState.inactive:
        break;
      case AppLifecycleState.paused:
        NativeUtils.onPause();
        break;
      case AppLifecycleState.detached:

        break;
      case AppLifecycleState.hidden:
    }
  }

  void checkAndGetPermission() async {
    NativeUtils.initX5Web();
  }

  void _showActivityDialog(UpdateKey updateKey) {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            title: Text('-提示-'),
            content: Text('点击支持下吧'),
            contentPadding: EdgeInsets.all(10),
            actions: <Widget>[
              TextButton(
                onPressed: () async{
                  Clipboard.setData(new ClipboardData(text: updateKey.copyKey!));
                  if(updateKey.isJd!){
                    await InstalledApps.startApp('com.jingdong.app.mall');
                  }else{
                    await InstalledApps.startApp('com.taobao.taobao');
                  }
                  Navigator.pop(context);
                },
                child: Text(
                  "好的",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          );
        });
  }
}
