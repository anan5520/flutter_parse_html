import 'package:flick_video_player/flick_video_player.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_parse_html/download/download_page.dart';
import 'package:flutter_parse_html/download/download_util.dart';
import 'package:flutter_parse_html/ui/porn/porn_page.dart';
import 'package:flutter_parse_html/util/common_util.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path/path.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_parse_html/model/porn_bean.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:flutter_parse_html/util/porn_helper.dart';
import 'dart:io';

import '../video_play.dart';

class PornVideoDetailPage extends StatefulWidget {
  final VideoResult _videoResult;

  PornVideoDetailPage(this._videoResult);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return PornVideoDetailState();
  }
}

class PornVideoDetailState extends State<PornVideoDetailPage> {
  bool _showThumb = true;
  late FlickManager _controller;
  late RefreshController _refreshController;
  List<VideoComment> _data = [];
  int _page = 1;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _controller = new FlickManager(
        videoPlayerController:
            VideoPlayerController.network(widget._videoResult.videoUrl!));
    _refreshController = RefreshController(initialRefresh: true);
    startVideo();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text('视频详情'),
        actions: <Widget>[
          ElevatedButton(
            child: Text(
              '查看所有作品',
              style: TextStyle(color: Colors.white, fontSize: 12),
            ),
            onPressed: () {
              //跳转查看作者其他作品
              Navigator.pop(context);
              Navigator.of(context)
                  .push(new MaterialPageRoute(builder: (BuildContext context) {
                return PornPage.authorId(widget._videoResult.ownerId!);
              }));
            },
          ),
          GestureDetector(
            onTap: () {
              Fluttertoast.showToast(
                  msg: '已复制到粘贴板', toastLength: Toast.LENGTH_SHORT);
              Clipboard.setData(
                  new ClipboardData(text: widget._videoResult.videoUrl!));
            },
            child: Center(
              child: Padding(
                padding: EdgeInsets.only(right: 10),
                child: Text('复制链接'),
              ),
            ),
          ),
          new IconButton(
              icon: new Icon(Icons.file_download),
              tooltip: '下载',
              onPressed: () {
                CommonUtil.toVideoPlay(widget._videoResult.videoUrl, context,
                    isDownLoad: true);
              })
        ],
      ),
      body: Column(
        children: <Widget>[
          SizedBox(
            height: 200,
            child: Stack(
              children: <Widget>[
                FlickVideoPlayer(
                  flickManager: _controller,
                  flickVideoWithControls: new FlickVideoWithControls(
                      videoFit: BoxFit.contain,
                      controls: FlickPortraitControls()),
                ),
                Offstage(
                    offstage: _showThumb,
                    child: CachedNetworkImage(
                        width: double.infinity,
                        fit: BoxFit.cover,
                        imageUrl: widget._videoResult.thumbImgUrl == null
                            ? ''
                            : widget._videoResult.thumbImgUrl!)),
              ],
            ),
          ),
          Container(
            alignment: Alignment.centerLeft,
            width: double.infinity,
            height: 100,
            color: Colors.blue,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(bottom: 5, left: 5, right: 5),
                  child: widget._videoResult.videoName!.startsWith('http')
                      ? CachedNetworkImage(
                          imageUrl: widget._videoResult.videoName!)
                      : Text(
                          '${widget._videoResult.videoName}',
                          style: TextStyle(color: Colors.white),
                        ),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 5, right: 5),
                  child: Visibility(
                    visible: widget._videoResult.ownerId!.isNotEmpty,
                    child: GestureDetector(
                      onTap: () {
                        //跳转查看作者其他作品
                        Navigator.pop(context);
                        Navigator.of(context).push(new MaterialPageRoute(
                            builder: (BuildContext context) {
                          return PornPage.authorId(widget._videoResult.ownerId!);
                        }));
                      },
                      child: Text(
                        '${widget._videoResult.userOtherInfo}',
                        style: TextStyle(color: Colors.white70, fontSize: 11),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          getCommentWidget()
        ],
      ),
    );
  }

  void _addDownload(BuildContext context, String title, String url) async {
    DownloadUtil.downVideo(url, title, 1);
    Fluttertoast.showToast(msg: '添加下载成功');
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return DownloadPage();
    }));
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _controller.dispose();
  }

  Widget getCommentWidget() {
    return Expanded(
      child: SmartRefresher(
        enablePullUp: true,
        enablePullDown: true,
        onRefresh: () {
          _page = 1;
          _data.clear();
          getData();
        },
        onLoading: () {
          _page++;
          getData();
        },
        controller: _refreshController,
        child: ListView.separated(
            itemBuilder: (context, index) {
              VideoComment videoComment = _data[index];
              String content = '';
              for (var value in videoComment.commentQuoteList!) {
                content = '$content${value}\n';
              }

              return Padding(
                padding: EdgeInsets.all(5),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(bottom: 5, top: 5),
                      child: Text(
                        '${videoComment.uName}----${videoComment.replyTime}',
                        style: TextStyle(color: Colors.blueAccent),
                      ),
                    ),
                    Text(content)
                  ],
                ),
              );
            },
            separatorBuilder: (BuildContext context, int index) {
              return new Container(height: 1.0, color: Colors.grey);
            },
            itemCount: _data.length),
      ),
    );
  }

  void getData() async {
    List<VideoComment> list = await PornHelper.parseVideoComment(
        widget._videoResult.videoId!, _page, widget._videoResult.viewKey!);
    _refreshController.refreshCompleted();
    _refreshController.loadComplete();
    _data.addAll(list);
    setState(() {});
  }

  void startVideo() async {
    _controller.flickVideoManager!.videoPlayerController!.play();
  }
}
