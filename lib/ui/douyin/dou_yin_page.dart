import 'dart:convert';
import 'dart:math';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_parse_html/book/base/util/utils_time.dart';
import 'package:flutter_parse_html/model/button_bean.dart';
import 'package:flutter_parse_html/model/video_list_item.dart';
import 'dart:io';
import 'package:flutter_parse_html/net/net_util.dart';
import 'package:flutter_parse_html/api/api_constant.dart';
import 'package:flutter_parse_html/ui/pornhub/pornhub_util.dart';
import 'package:flutter_parse_html/util/common_util.dart';
import 'package:flutter_parse_html/widget/dialog_page.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:gbk2utf8/gbk2utf8.dart';
import 'package:html/parser.dart';
import 'package:video_player/video_player.dart';
import '../video_play.dart';
import 'package:http/http.dart' as http;
import 'package:cached_network_image/cached_network_image.dart';

class DouYinPage extends StatefulWidget {
  // IjkMediaController _flickManager;
  final int type;

  DouYinPage(this.type);

  // startOrStopPlay(bool start) {
  //   if (_flickManager != null) {
  //     if (start) {
  //       _flickManager.play();
  //     } else {
  //       _flickManager.pause();
  //     }
  //   }
  // }

  // dispose() async {
  //   if (_flickManager != null) {
  //     await _flickManager.dispose();
  //   }
  // }

  @override
  State<StatefulWidget> createState() {
    return DouYinState();
  }
}

class DouYinState extends State<DouYinPage>
    with AutomaticKeepAliveClientMixin, WidgetsBindingObserver {
  PageController _pageController;
  List<VideoListItem> _data = [];
  Widget _ijkPlayer;
  bool showLoading = true;
  bool isFirstPlay = true;
  int _currentIndex = 0;

  @override //生命周期
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.resumed:
//        if(widget._ijkMediaController != null){
//          widget._ijkMediaController.play();
//        }
        break;
      case AppLifecycleState.inactive:
        break;
      case AppLifecycleState.paused:
        // if (widget._flickManager != null) {
        //   widget._flickManager.pause();
        // }
        break;
    }
  }

  @override
  void initState() {
    _pageController = new PageController(initialPage: 3);

    getData(true);
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    // if (widget._flickManager == null) {
    //   widget._flickManager = IjkMediaController();
    //   _ijkPlayer = IjkPlayer(
    //     mediaController: widget._flickManager,
    //     controllerWidgetBuilder: (controller) {
    //       return DefaultIJKControllerWidget(
    //         verticalGesture: false,
    //         showFullScreenButton: false,
    //         volumeType: VolumeType.media,
    //         controller: controller,
    //         fullscreenControllerWidgetBuilder: (ctl) =>
    //             DefaultIJKControllerWidget(
    //           controller: controller,
    //           currentFullScreenState: true,
    //         ),
    //       ); // 自定义
    //     },
    //     statusWidgetBuilder: (context, controller, state) {
    //       if(state == IjkStatus.prepared || state ==  IjkStatus.complete){
    //         Future.delayed(Duration(milliseconds: 1000),(){
    //           controller.play();
    //         });
    //
    //       }
    //       switch (state) {
    //         case IjkStatus.noDatasource:
    //           // TODO: Handle this case.
    //           break;
    //         case IjkStatus.preparing:
    //           return SpinKitWave(
    //             color: Colors.blue,
    //           );
    //           break;
    //         case IjkStatus.setDatasourceFail:
    //           playNext();
    //           break;
    //         case IjkStatus.prepared:
    //           controller.play();
    //           break;
    //         case IjkStatus.pause:
    //           // TODO: Handle this case.
    //           break;
    //         case IjkStatus.error:
    //           playNext();
    //           break;
    //         case IjkStatus.playing:
    //           // TODO: Handle this case.
    //           break;
    //         case IjkStatus.complete:
    //           // TODO: Handle this case.
    //           break;
    //         case IjkStatus.disposed:
    //           // TODO: Handle this case.
    //           break;
    //       }
    //       return Container();
    //     },
    //   );
    // }
    return Scaffold(
      body: Stack(
        alignment: AlignmentDirectional.bottomEnd,
        children: <Widget>[
          _ijkPlayer,
          Offstage(
            offstage: !showLoading,
            child:   SpinKitWave(
              color: Colors.blue,
            ),
          ),
          Positioned(
            bottom: 50,
            right: 100,
            child: Text((_data.length == 0 || _data[_currentIndex].title == null)?'':_data[_currentIndex].title,
            style: TextStyle(color: Colors.white,fontSize: 17),),
          ),
          Positioned(
            bottom: 60,
            child: Column(children: [
              Padding(padding: EdgeInsets.only(top: 10),
              child: MaterialButton(
                height: 40,
                shape: CircleBorder(),
                padding: EdgeInsets.all(0),
                color: Colors.white,
                child: SizedBox(
                  height: 50,
                  child: Column(children: [
                    Icon(
                      Icons.skip_previous,
                      color: Colors.blue,
                      size: 30,
                    ),
                    Text('上一个',style: TextStyle(color: Colors.blue,fontSize: 10),)
                  ],),
                ),
                onPressed: () {
                  playPrevious();
                },
              ),),

              Padding(padding: EdgeInsets.only(top: 10),
              child: MaterialButton(
                height: 40,
                shape: CircleBorder(),
                padding: EdgeInsets.all(0),
                color: Colors.white,
                child: SizedBox(
                  height: 50,
                  child: Column(children: [
                    Icon(
                      Icons.skip_next,
                      color: Colors.blue,
                      size: 30,
                    ),
                    Text('下一个',style: TextStyle(color: Colors.blue,fontSize: 10),)
                  ],),
                ),
                onPressed: () {
                  playNext();
                },
              ),),

              Padding(padding: EdgeInsets.only(top: 10),
              child: MaterialButton(
                height: 40,
                shape: CircleBorder(),
                padding: EdgeInsets.all(0),
                color: Colors.white,
                child: SizedBox(
                  height: 50,
                  child: Column(children: [
                    Icon(
                      Icons.arrow_circle_down,
                      color: Colors.blue,
                      size: 30,
                    ),
                    Text('浏览器下载',style: TextStyle(color: Colors.blue,fontSize: 8),)
                  ],),
                ),
                onPressed: () {
                  CommonUtil.toVideoPlay(_data[_currentIndex].targetUrl,context,isDownLoad: true);
                },
              ),),

            ],),
          )
        ],
      ),
    );
  }

  void onPageChanged(int index) async {
    VideoListItem listItem = _data[index];
    int i = index - 1;
    int a = index + 1;
    if (i >= 0) {
      _data[i].show = true;
    }
    if (a < _data.length) {
      _data[a].show = true;
    }
    _data[index].show = false;
    playVideo(listItem.targetUrl);
    if (index == _data.length - 1) {
      getData(false);
    }
    setState(() {});
  }

  Widget getItem(BuildContext context, int index) {
    VideoListItem item = _data[index];
    return Container(
      child: Stack(
        children: <Widget>[
          _ijkPlayer,
          Positioned(
            bottom: 50,
            child: Padding(
              padding: EdgeInsets.all(10),
              child: Text('${item.title == null ? "" : item.title}',
                  style: TextStyle(
                      backgroundColor: Colors.transparent,
                      color: Colors.white,
                      fontSize: 15)),
            ),
          ),
          Offstage(
            offstage: !item.show,
            child: SizedBox.expand(
              child: new Image.asset(
                "images/video_bg.png",
                fit: BoxFit.cover,
              ),
            ),
          ),
        ],
      ),
    );
  }

  //获取数据每次获取6条
  getData(bool isFirst) async {
    setState(() {
      showLoading = true;
    });
    for (int i = 0; i < 3; i++) {
//          var response = await http.get(ApiConstant.douYinUrl);
//          var body = gbk.decode(response.bodyBytes);
//    Utf8Decoder utf8decoder = new Utf8Decoder();
//    var body = utf8decoder.convert(response.bodyBytes);
      if (widget.type == 0) {
        var indexs = ['1', '2', '4', '5', '7', '8'];
        var response = await NetUtil.getHtmlData(
            ApiConstant.douYinUrl + '${indexs[Random().nextInt(5)]}.php',
            isWeb: false);
        addItem(response);
      } else {
        String url = '${ApiConstant.douYin2Url}${Random().nextInt(4658)}.json';
        var response = await NetUtil.getHtmlData(url);
        response = response.replaceAll('Response Content', '').trim();
        Map<String, dynamic> jsonMap = json.decode(response);
        VideoListItem videoListItem = new VideoListItem();
        videoListItem.targetUrl = jsonMap['url'];
        videoListItem.title = jsonMap['name'];
        if (videoListItem.targetUrl != null) {
          _data.add(videoListItem);
        }
      }
    }
    showLoading = false;
    setState(() {
      if (_data.length > 0) {
        playNext();
      }
    });
//    String url =  _data[0].targetUrl;
//    await _ijkMediaController.setNetworkDataSource(url,autoPlay: true);
  }

//   //获取数据每次获取6条
//   getData(bool isFirst) async {
//     if (widget.type == 0) {
//       var indexs = ['1','2','4','5','7'];
//       var response =
//       await NetUtil.getHtmlData(ApiConstant.douYinUrl + '/movies?page=${Random().nextInt(368)}', isWeb: true);
//       var doc = parse(response);
//       var list = [];
//       var items = doc.getElementsByClassName('card nopadding');
//       items.forEach((element) {
//         var a = element.getElementsByTagName('a').first.attributes['href'];
//         a = a.replaceAll('movie', 'share');
//         list.add('${ApiConstant.douYinUrl}$a');
//       });
//       var res =  await NetUtil.getHtmlData(list[Random().nextInt(list.length - 1)], isWeb: true);
//       var urls = res.split(new RegExp('token = \"|var m3u8 = '));
//       var token = urls[1].substring(0,urls[1].length - 3);
//       var m3u8 = '${urls[2].substring(1).split("m3u8'")[0]}m3u8';
//       VideoListItem listItem = new VideoListItem();
//       listItem.targetUrl = '${ApiConstant.douYinUrl}$m3u8?token=$token';
//       _data.add(listItem);
//     } else {
//       for (int i = 0; i < 6; i++) {
// //          var response = await http.get(ApiConstant.douYinUrl);
// //          var body = gbk.decode(response.bodyBytes);
// //    Utf8Decoder utf8decoder = new Utf8Decoder();
// //    var body = utf8decoder.convert(response.bodyBytes);
//
//         String url = '${ApiConstant.douYin2Url}${Random().nextInt(4658)}.json';
//         var response = await PornHubUtil.getHtmlFromHttpDeugger(url);
//         response = response.replaceAll('Response Content', '').trim();
//         Map<String, dynamic> jsonMap = json.decode(response);
//         VideoListItem videoListItem = new VideoListItem();
//         videoListItem.targetUrl = jsonMap['url'];
//         videoListItem.title = jsonMap['name'];
//         if(videoListItem.targetUrl != null){
//           _data.add(videoListItem);
//         }
//       }
//     }
//
//     setState(() {
//       showLoading = false;
//       if (_data.length > 0 && isFirst) {
//         _pageController.jumpTo(0);
//         onPageChanged(0);
//       }
//     });
// //    String url =  _data[0].targetUrl;
// //    await _ijkMediaController.setNetworkDataSource(url,autoPlay: true);
//   }


  addItem(String response) {
    VideoListItem listItem = new VideoListItem();
    var doc = parse(response);
    if (widget.type == 0) {
      if (response.contains('.mp4') && !response.endsWith('mp4')) {
        var strings = response.split('.mp4');
        listItem.targetUrl = '${strings[0]}.mp4';
      } else if (!response.startsWith('http')) {
        listItem.targetUrl = 'https:$response';
      } else {
        listItem.targetUrl = response;
      }
    } else {
      listItem.targetUrl =
          doc.getElementsByTagName('video').first.attributes['src'];
    }
//    listItem.targetUrl = ApiConstant.douYinUrl;
//    var strings = response.split(new RegExp(r'(<source src="|" type="video/ogg")'));
//    print('抖音视频》》$strings');
//    for (var value in strings) {
//      if (value.startsWith('https')) {
//        listItem.targetUrl =
//            value.trim().replaceAll("\n", '').replaceAll('\t', '');
//        break;
//      }
//    }
    _data.add(listItem);
  }

  void playVideo(String targetUrl) async {
    // if (targetUrl == null) return;
    // await widget._flickManager.setNetworkDataSource(targetUrl, autoPlay: true);
    // if (isFirstPlay) {
    //   isFirstPlay = false;
    // }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _pageController.dispose();
    // widget._flickManager.dispose();
    super.dispose();
  }

  void showLoadingDialog() {
    showDialog(
        context: context,
        barrierDismissible: true,
        builder: (context) {
          return SpinKitWave(
            color: Colors.blue,
          );
        });
  }

  @override
  bool get wantKeepAlive => true;

  void playNext() {
    if (_currentIndex >= _data.length - 1) {
      getData(false);
    } else {
      if(showLoading){
        showLoading = false;
      }
      _currentIndex++;
      var url = _data[_currentIndex].targetUrl;
      playVideo(url);
    }
  }

  void playPrevious() {
    if ( _currentIndex > 0) {
      _currentIndex--;
      var url = _data[_currentIndex].targetUrl;
      playVideo(url);
    }
  }
}
