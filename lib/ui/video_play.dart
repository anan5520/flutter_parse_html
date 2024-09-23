import 'dart:async';
import 'dart:io';

import 'package:flick_video_player/flick_video_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_parse_html/api/api_constant.dart';
import 'package:flutter_parse_html/db/history_db.dart';
import 'package:flutter_parse_html/download/download_page.dart';
import 'package:flutter_parse_html/download/download_util.dart';
import 'package:flutter_parse_html/model/button_bean.dart';
import 'package:flutter_parse_html/model/movie_bean.dart';
import 'package:flutter_parse_html/util/common_util.dart';
import 'package:flutter_parse_html/util/movie_util.dart';
import 'package:flutter_parse_html/util/native_utils.dart';
import 'package:flutter_parse_html/widget/dialog_page.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path/path.dart';
import 'package:video_player/video_player.dart';
import 'package:keep_screen_on/keep_screen_on.dart';

class VideoPlayPage extends StatefulWidget {
  MovieBean _movieBean;
  double _progress;
  bool isYaSe = false;

  VideoPlayPage(this._movieBean, this._progress, this.isYaSe);

  VideoPlayPage.alongMovieBean(MovieBean _movieBean)
      : this(_movieBean, 0, false);

  VideoPlayPage.isYaseMovieBean(MovieBean _movieBean, bool isYaSe)
      : this(_movieBean, 0, isYaSe);

  @override
  State<StatefulWidget> createState() {
    KeepScreenOn.turnOn();
    print('播放地址>>>${_movieBean.playUrl}');
    return _VideoAppState(_movieBean.playUrl!);
  }
}

class _VideoAppState extends State<VideoPlayPage> {
  late FlickManager flickManager;
  late String playUrl;
  List<ButtonBean> _btns = [];

  _VideoAppState(this.playUrl);

  late Timer _timer;

  bool isFilePlay = false;

  int fileTemp = 0;

  late Widget state;

  bool visible = false;

  @override
  void initState() {
    if (widget._movieBean.list != null) {
      for (var value in widget._movieBean.list!) {
        ButtonBean buttonBean = new ButtonBean();
        buttonBean.value = value.targetUrl;
        buttonBean.title = value.name;
        _btns.add(buttonBean);
      }
    }
    if (playUrl.startsWith('http')) {
      flickManager = FlickManager(
          videoPlayerController: VideoPlayerController.network(playUrl));
    } else {
      File file = new File(playUrl);
      flickManager =
          FlickManager(videoPlayerController: VideoPlayerController.file(file));
    }

    startPlay();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Scaffold(
        appBar: AppBar(
          title: Text((widget._movieBean.name!.isNotEmpty
                  ? widget._movieBean.name
                  : '播放') !+
              '${widget._movieBean.number != null ? widget._movieBean.number : ""}'),
          actions: <Widget>[
            GestureDetector(
              onTap: () {
                Fluttertoast.showToast(
                    msg: '已复制到粘贴板', toastLength: Toast.LENGTH_SHORT);
                Clipboard.setData(new ClipboardData(text: playUrl));
              },
              child: Center(
                child: Padding(
                  padding: EdgeInsets.only(right: 10),
                  child: Text('复制链接'),
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                if (_btns != null && _btns.length > 0) {
                  _showDialog();
                }
              },
              child: Center(
                child: Text('选集'),
              ),
            ),
            new IconButton(
                icon: new Icon(Icons.file_download),
                tooltip: '下载',
                onPressed: () {
                  NativeUtils.startQBrowser(playUrl);
                  // _addDownload(
                  //     context,
                  //     widget._movieBean.name +
                  //         '${widget._movieBean.number != null ? widget._movieBean.number : ""}');
                })
          ],
        ),
        body: Center(
            child: FlickVideoPlayer(
          systemUIOverlay: [SystemUiOverlay.top],
          wakelockEnabledFullscreen: false,
          flickManager: flickManager,
          flickVideoWithControls: FlickVideoWithControls(
            videoFit: BoxFit.fitWidth,
            controls: FlickPortraitControls(),
          ),
          flickVideoWithControlsFullscreen: FlickVideoWithControls(
            controls: FlickLandscapeControls(),
          ),
        )),
      ),
    );
  }

  @override
  void dispose() async{
//    _controller.getVideoInfo().then((videoInfo) {
//      var db = HistoryDatabaseHelper();
//      db.getItem(widget._movieBean.name).then((history) {
//        if (history != null) {
//          double progress = videoInfo.currentPosition / videoInfo.duration;
//          db.updateItemWithMap({
//            HistoryDatabaseHelper.columnProgress: progress,
//            HistoryDatabaseHelper.columnLength: videoInfo.duration,
//            HistoryDatabaseHelper.columnNumber: widget._movieBean.number,
//          }, history.title);
//        } else {
//          History item = History();
//          item.type = 1;
//          item.progress = videoInfo.progress;
//          item.originUrl = widget._movieBean.originUrl;
//          item.imageUrl = widget._movieBean.imgUrl;
//          item.title = widget._movieBean.name;
//          item.videoUrl = widget._movieBean.playUrl;
//          item.number = widget._movieBean.number;
//          item.length = videoInfo.duration;
//          try {
//            db.saveItem(item);
//          } catch (e) {
//            print(e);
//          }
//        }
//      });
//    });
    await flickManager.flickVideoManager!.videoPlayerController!.pause();
    flickManager.dispose();
    KeepScreenOn.turnOff();
    super.dispose();
    if (_timer != null) {
      _timer.cancel();
    }
  }

  void startPlay() async {
    await flickManager.flickVideoManager!.videoPlayerController!.play();
  }

  void _addDownload(BuildContext context, String title) async {
    String url = widget._movieBean.playUrl!;
    if (url.startsWith('http')) {
      DownloadUtil.downVideo(widget._movieBean.playUrl!, title, 1,
          maxTaskNum: widget.isYaSe ? 3 : 6,
          isM3u8: widget._movieBean.isM3u8 == null
              ? false
              : widget._movieBean.isM3u8);
      Fluttertoast.showToast(msg: '添加下载成功');
      Navigator.pop(context);
      Navigator.push(context, MaterialPageRoute(builder: (context) {
        return DownloadPage();
      }));
    }
  }

  void _showDialog() async {
    ButtonBean buttonBean = await showDialog(
        context: this.context,
        builder: (context) {
          return new AlertDialog(
            content: GridViewDialog(_btns,showToPage: false,),
          );
        });
    if (buttonBean != null) {
      widget._progress = 0;
      if (buttonBean.value!.contains('.m3u8') ||
          buttonBean.value!.contains('.mp4')) {
        playUrl = buttonBean.value!;
        flickManager = FlickManager(
            videoPlayerController: VideoPlayerController.network(playUrl));
        startPlay();
        return;
      }
      playUrl = await MovieUtil.getVideoUrl(buttonBean.value!);
      startPlay();
    }
  }

  void seekToProgress() {
    if (widget._progress != 0) {
      _timer = new Timer(const Duration(milliseconds: 5000), () {
        setState(() {
//          _controller.seekToProgress(widget._progress);
        });
      });
    }
  }
}

// class VideoPlayPage2 extends StatefulWidget {
//   MovieBean _movieBean;
//   double _progress;
//   bool isYaSe = false;
//
//   VideoPlayPage2(this._movieBean, this._progress, this.isYaSe);
//
//   VideoPlayPage2.alongMovieBean(MovieBean _movieBean)
//       : this(_movieBean, 0, false);
//
//   VideoPlayPage2.isYaseMovieBean(MovieBean _movieBean, bool isYaSe)
//       : this(_movieBean, 0, isYaSe);
//
//   @override
//   State<StatefulWidget> createState() {
//     Screen.keepOn(true);
//     // _movieBean.playUrl = Uri.encodeComponent(_movieBean.playUrl);
//     String url = '';
//     var strings = _movieBean.playUrl.split('/');
//     strings.forEach((element) {
//       if (!element.contains('http') && element != '') {
//         url = url + '/' + Uri.encodeComponent(element);
//       }
//     });
//     _movieBean.playUrl = '${strings[0]}/$url';
//     print('播放地址>>>${_movieBean.playUrl}');
//     getScreen();
//     return _VideoAppState2(_movieBean.playUrl);
//   }
//
//   void getScreen() async {
//     // Check if the screen is kept on:
//     bool isKeptOn = await Screen.isKeptOn;
//     print('isKeptOn>>>$isKeptOn');
//   }
// }

// class _VideoAppState2 extends State<VideoPlayPage2> {
//   IjkMediaController player ;
//   String playUrl;
//   List<ButtonBean> _btns = [];
//
//   _VideoAppState2(this.playUrl);
//
//   Timer _timer;
//
//   bool isFilePlay = false;
//
//   int fileTemp = 0;
//
//   Widget state;
//
//   bool visible = false;
//
//   @override
//   void initState() {
//     player = IjkMediaController();
//     if (widget._movieBean.list != null) {
//       for (var value in widget._movieBean.list) {
//         ButtonBean buttonBean = new ButtonBean();
//         buttonBean.value = value.targetUrl;
//         buttonBean.title = value.name;
//         _btns.add(buttonBean);
//       }
//     }
//     startPlay();
//     super.initState();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Scaffold(
//         appBar: AppBar(
//           title: Text((widget._movieBean.name.isNotEmpty
//                   ? widget._movieBean.name
//                   : '播放') +
//               '${widget._movieBean.number != null ? widget._movieBean.number : ""}'),
//           actions: <Widget>[
//             GestureDetector(
//               onTap: () {
//                 Fluttertoast.showToast(
//                     msg: '已复制到粘贴板', toastLength: Toast.LENGTH_SHORT);
//                 Clipboard.setData(new ClipboardData(text: playUrl));
//               },
//               child: Center(
//                 child: Padding(
//                   padding: EdgeInsets.only(right: 10),
//                   child: Text('复制链接'),
//                 ),
//               ),
//             ),
//             GestureDetector(
//               onTap: () {
//                 if (_btns != null && _btns.length > 0) {
//                   _showDialog();
//                 }
//               },
//               child: Center(
//                 child: Text('选集'),
//               ),
//             ),
//             new IconButton(
//                 icon: new Icon(Icons.file_download),
//                 tooltip: '下载',
//                 onPressed: () {
//                   _addDownload(
//                       context,
//                       widget._movieBean.name +
//                           '${widget._movieBean.number != null ? widget._movieBean.number : ""}');
//                 })
//           ],
//         ),
//         body: Container(
//             color: Colors.black,
//             child: IjkPlayer(
//               mediaController: player,
//             )),
//       ),
//     );
//   }
//
//   @override
//   void dispose() async {
// //    _controller.getVideoInfo().then((videoInfo) {
// //      var db = HistoryDatabaseHelper();
// //      db.getItem(widget._movieBean.name).then((history) {
// //        if (history != null) {
// //          double progress = videoInfo.currentPosition / videoInfo.duration;
// //          db.updateItemWithMap({
// //            HistoryDatabaseHelper.columnProgress: progress,
// //            HistoryDatabaseHelper.columnLength: videoInfo.duration,
// //            HistoryDatabaseHelper.columnNumber: widget._movieBean.number,
// //          }, history.title);
// //        } else {
// //          History item = History();
// //          item.type = 1;
// //          item.progress = videoInfo.progress;
// //          item.originUrl = widget._movieBean.originUrl;
// //          item.imageUrl = widget._movieBean.imgUrl;
// //          item.title = widget._movieBean.name;
// //          item.videoUrl = widget._movieBean.playUrl;
// //          item.number = widget._movieBean.number;
// //          item.length = videoInfo.duration;
// //          try {
// //            db.saveItem(item);
// //          } catch (e) {
// //            print(e);
// //          }
// //        }
// //      });
// //    });
//     if (_timer != null) {
//       _timer.cancel();
//     }
//     player.dispose();
//     Screen.keepOn(false);
//     super.dispose();
//   }
//
//   void startPlay() async {
//     await player.setNetworkDataSource(playUrl,autoPlay: true);
//     player.play();
//     print('播放>>>$playUrl');
//     // mediaController.seekTo(0);
//   }
//
//   void _addDownload(BuildContext context, String title) async {
//     String url = widget._movieBean.playUrl;
//     if (url.startsWith('http')) {
//       DownloadUtil.downVideo(widget._movieBean.playUrl, title, 1,
//           maxTaskNum: widget.isYaSe ? 3 : 6,
//           isM3u8: widget._movieBean.isM3u8 == null
//               ? false
//               : widget._movieBean.isM3u8);
//       Fluttertoast.showToast(msg: '添加下载成功');
//       Navigator.pop(context);
//       Navigator.push(context, MaterialPageRoute(builder: (context) {
//         return DownloadPage();
//       }));
//     }
//   }
//
//   void _showDialog() async {
//     ButtonBean buttonBean = await showDialog(
//         context: this.context,
//         builder: (context) {
//           return new AlertDialog(
//             content: GridViewDialog(_btns,showToPage:false,),
//           );
//         });
//     if (buttonBean != null) {
//       widget._progress = 0;
//       if (buttonBean.value.contains('.m3u8') ||
//           buttonBean.value.contains('.mp4')) {
//         playUrl = buttonBean.value;
//         startPlay();
//         return;
//       }
//       playUrl = await MovieUtil.getVideoUrl(buttonBean.value);
//       startPlay();
//     }
//   }
//
//   void seekToProgress() {
//     if (widget._progress != 0) {
//       _timer = new Timer(const Duration(milliseconds: 5000), () {
//         setState(() {
// //          _controller.seekToProgress(widget._progress);
//         });
//       });
//     }
//   }
// }
