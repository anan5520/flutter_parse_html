import 'dart:io';
import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_parse_html/db/history_db.dart';
import 'package:flutter_parse_html/download/download_util.dart';
import 'package:flutter_parse_html/model/movie_bean.dart';
import 'package:flutter_parse_html/ui/video_play.dart';
import 'package:flutter_parse_html/util/movie_util.dart';
import 'package:flutter_parse_html/util/native_utils.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_saver/image_saver.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class HistoryPage extends StatefulWidget {
  var db = HistoryDatabaseHelper();

  @override
  State<StatefulWidget> createState() {
    return HistoryState();
  }
}

class HistoryState extends State<HistoryPage>
    with AutomaticKeepAliveClientMixin {
  RefreshController _refreshController;
  List<History> _data = [];

  @override
  void initState() {
    super.initState();
    _refreshController = new RefreshController(initialRefresh: true);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('历史记录'),
      ),
      body: SmartRefresher(
        enablePullDown: true,
        controller: _refreshController,
        onRefresh: () {
          _getData();
        },
        child: ListView.builder(
          itemBuilder: getListItem,
          itemCount: _data.length,
        ),
      ),
    );
  }

  Widget getListItem(BuildContext context, int index) {
    History history = _data[index];
    return Dismissible(
        onDismissed: (_) async {
//          widget._data.removeAt(index);
          widget.db.deleteItem(history.title);
          Scaffold.of(context)
              .showSnackBar(new SnackBar(content: new Text("删除成功")));
        },
        movementDuration: Duration(microseconds: 100),
        key: Key(history.title),
        background: Container(
          color: Color(0xffff0000),
        ),
        child: GestureDetector(
          onLongPressStart: (detail) {
            //长按
          },
          onTap: () async {
            showLoading();
            MovieBean movieBean = await MovieUtil.getMovieBean(
                history.originUrl, history.title,
                number: history.number);
            Navigator.pop(context);
            Navigator.push(context, MaterialPageRoute(builder: (context) {
              return VideoPlayPage(movieBean, history.progress,false);
            }));
          },
          child: Column(children: <Widget>[
            Padding(
              padding: EdgeInsets.only(left: 10, top: 5, bottom: 5, right: 10),
              child: Row(
                children: <Widget>[
                 SizedBox(
                   height: 120,
                   width: 80,
                   child:  Container(
                     color: Color(0xffeeeeee),
                     child: CachedNetworkImage(
                       height: 120,
                       width: 80,
                       imageUrl: history.imageUrl,
                       errorWidget:
                           (BuildContext context, String url, Object error) {
                         return new Icon(Icons.error);
                       },
                       fit: BoxFit.fill,
                       placeholder: (context, url) {
                         return new Icon(Icons.error);
                       },
                     ),
                   ),
                 ),
                  Padding(
                    padding: EdgeInsets.only(left: 10),
                    child: Column(
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.only(bottom: 10),
                          child: Text(
                            history.title,
                            style: TextStyle(color: Colors.blue),
                          ),
                        ),
                        Text(
                            '${history.number} 观看进度: ${(history.progress * 100).toStringAsFixed(2)}%')
                      ],
                    ),
                  )
                ],
              ),
            ),
          ]),
        ));
  }

  void _getData() async {
    List<History> list = History.fromMapList(await widget.db.getTotalList());
    _data.clear();
    _data.addAll(list);
    setState(() {
      _refreshController.refreshCompleted();
    });
  }

  @override
  bool get wantKeepAlive => true;

  _showMenu(BuildContext context, LongPressStartDetails detail, String url) {
    final RelativeRect position = RelativeRect.fromLTRB(
        detail.globalPosition.dx, //取点击位置坐弹出x坐标
        detail.globalPosition.dy, //取text高度做弹出y坐标（这样弹出就不会遮挡文本）
        MediaQuery.of(context).size.width - detail.globalPosition.dx,
        0);
    var pop = _popMenu(url);
    showMenu(
      context: context,
      items: pop.itemBuilder(context),
      position: position, //弹出框位置
    ).then((newValue) {
      if (!mounted) return null;
      if (newValue == null) {
        if (pop.onCanceled != null) pop.onCanceled();
        return null;
      }
      if (pop.onSelected != null) pop.onSelected(newValue);
    });
  }

  void _onImageSaveButtonPressed(String path) async {
    print('保存视频>>>$path');

    if (Platform.isAndroid) {
      Uint8List fileData = await new File(path).readAsBytes();
      File savedFile = await ImageSaver.toFile(fileData: fileData);
      print('保存成功>>>' + savedFile.path);
      Fluttertoast.showToast(msg: '保存成功');
    } else {
      File file = File(path);
      if (!await file.exists()) {
        Fluttertoast.showToast(msg: '文件不存在');
        return;
      }
      NativeUtils.saveVideo(path, albumName: 'Media').then((bool success) {
        print('保存视频返回结果>>$success');
        Fluttertoast.showToast(msg: '保存成功');
      });
    }
  }

  PopupMenuButton _popMenu(String url) {
    return PopupMenuButton(
      itemBuilder: (context) => _getPopupMenu(context),
      onSelected: (value) {
        print('onSelected');
        _selectValueChange(value, url);
      },
      onCanceled: () {
        print('onCanceled');
        setState(() {});
      },
    );
  }

  _selectValueChange(String value, String url) {
    setState(() {
      if (value != null && value == 'save') {
        _onImageSaveButtonPressed(url);
      }
    });
  }

  _getPopupMenu(BuildContext context) {
    return <PopupMenuEntry>[
      PopupMenuItem(
        value: 'save',
        child: Text('保存到相册'),
      ),
    ];
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
