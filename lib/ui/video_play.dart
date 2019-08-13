

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_ijkplayer/flutter_ijkplayer.dart';
class VideoPlayPage extends StatelessWidget{

  String url;

  VideoPlayPage(this.url);

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return VideoPage(url);
  }

}

class VideoPage extends StatefulWidget{
  String url;


  VideoPage(this.url);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    print('播放地址>>>$url');
    return _VideoAppState(url);
  }
}


class _VideoAppState extends State<VideoPage>{
  IjkMediaController _controller;
  String playUrl;



  _VideoAppState(this.playUrl);

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _controller = new IjkMediaController();
    startPlay();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      body: Scaffold(
        appBar: AppBar(title: Text('播放'),),
        body: Center(
            child: IjkPlayer(mediaController: _controller,
              controllerWidgetBuilder: (_){return DefaultIJKControllerWidget(
                controller: _controller,);},
              statusWidgetBuilder: (context,controller,status){
                switch(status){
                  case IjkStatus.prepared:
                    _controller.play();
                    break;
                  case IjkStatus.noDatasource:
                  // TODO: Handle this case.
                    break;
                  case IjkStatus.preparing:
                  // TODO: Handle this case.
                    break;
                  case IjkStatus.setDatasourceFail:
                  // TODO: Handle this case.
                    break;
                  case IjkStatus.pause:
                  // TODO: Handle this case.
                    break;
                  case IjkStatus.error:
                  // TODO: Handle this case.
                    break;
                  case IjkStatus.playing:
                  // TODO: Handle this case.
                    break;
                  case IjkStatus.complete:
                  // TODO: Handle this case.
                    break;
                  case IjkStatus.disposed:
                  // TODO: Handle this case.
                    break;
                }
              },)
        ),
      ),
    );
  }
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void startPlay() async{
    await _controller.setNetworkDataSource(playUrl,autoPlay: Platform.isAndroid);
  }

}