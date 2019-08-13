import 'package:flutter/widgets.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_parse_html/model/porn_bean.dart';
import 'package:flutter_ijkplayer/flutter_ijkplayer.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:flutter_parse_html/util/porn_helper.dart';
import 'dart:io';
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
  IjkMediaController _controller;
  RefreshController _refreshController;
  List<VideoComment> _data = [];
  int _page = 1;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _controller = IjkMediaController();
    _refreshController = RefreshController(initialRefresh: true);
    startVideo();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text('视频详情'),
      ),
      body: Column(
        children: <Widget>[
          SizedBox(
            height: 200,
            child: Stack(
              children: <Widget>[
                IjkPlayer(
                  mediaController: _controller,
                  statusWidgetBuilder: (context, controller, status) {
                    if (status == IjkStatus.prepared ) {
//                      _showThumb = true;
                      _controller.play();
                    }else if(status == IjkStatus.error){
//                      _showThumb = false;
                    }else if(status == IjkStatus.playing){
//                      _showThumb = true;
                    }
                  },
                ),
                Offstage(
                    offstage: _showThumb,
                    child: CachedNetworkImage(
                        width: double.infinity,
                        fit: BoxFit.cover,
                        imageUrl: widget._videoResult.thumbImgUrl)),
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
                  padding: EdgeInsets.only(bottom: 5,left: 5,right: 5),
                  child: Text(
                    '${widget._videoResult.videoName}',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                Padding(padding: EdgeInsets.only(left: 5,right: 5),
                child: Text(
                  '${widget._videoResult.userOtherInfo}',
                  style: TextStyle(color: Colors.white70,fontSize: 11),
                ),),
              ],
            ),
          ),
          getCommentWidget()
        ],
      ),
    );
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
              for (var value in videoComment.commentQuoteList) {
                content = '$content${value}\n';
              }

              return Padding(
                padding: EdgeInsets.all(5),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(bottom: 5,top: 5),
                      child: Text(
                          '${videoComment.uName}----${videoComment.replyTime}',style: TextStyle(color: Colors.blueAccent),),
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
        widget._videoResult.videoId, _page, widget._videoResult.viewKey);
    _refreshController.refreshCompleted();
    _refreshController.loadComplete();
    _data.addAll(list);
    setState(() {

    });
  }

  void startVideo()async {
   await _controller.setNetworkDataSource(widget._videoResult.videoUrl,
        autoPlay: Platform.isAndroid);
  }
}
