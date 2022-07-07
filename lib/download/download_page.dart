import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_parse_html/db/download_db.dart';
import 'package:flutter_parse_html/download/download_util.dart';
import 'package:flutter_parse_html/model/movie_bean.dart';
import 'package:flutter_parse_html/ui/video_play.dart';
import 'package:flutter_parse_html/util/native_utils.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_saver/image_saver.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class DownloadPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return DownloadPageState();
  }
}

class DownloadPageState extends State<DownloadPage>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  TabController _tabController;
  PageController _pageController;
  var db = DatabaseHelper();
  var isPageCanChanged = true;
  List<String> _titleName = ["下载中", "已完成"];

  @override
  void initState() {
    _tabController = new TabController(length: _titleName.length, vsync: this);
    _pageController = new PageController();
    createTable();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('下载中心'),
      ),
      body: Column(
        children: <Widget>[
          Container(
            color: Colors.blue,
            height: 38,
            width: double.infinity,
            child: TabBar(
              controller: _tabController,
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
    return DownloadItemPage(index, db);
  }

  void createTable() async {
//    await downloadDb.createTable();
  }

  @override
  bool get wantKeepAlive => true;
}

class DownloadItemPage extends StatefulWidget {
  final int _type;

  DatabaseHelper db;

  DownloadItemPage(this._type, this.db);

  @override
  State<StatefulWidget> createState() {
    return DownloadItemState();
  }
}

class DownloadItemState extends State<DownloadItemPage>
    with AutomaticKeepAliveClientMixin {
  RefreshController _refreshController;
  List<Download> _data = [];
  bool hasInit = false;
  @override
  void initState() {
    _refreshController = new RefreshController(initialRefresh: true);
    DownloadUtil.refreshCallback((per) {
      _getData();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
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
    Download download = _data[index];
    return Dismissible(
      onDismissed: (_) async{
        File file = new File(download.path);
        bool exists = await file.parent.exists();
        if(exists){
          try {
            await file.parent.list().forEach((file) async{
              if(await file.exists()){
                await file.delete();
              }
            });
            await file.parent.delete();
          } catch (e) {
            print(e);
          }
        }
        _data.removeAt(index);
        DownloadUtil.dbHelper.deleteItem(download.title);
        Scaffold.of(context).showSnackBar(
            new SnackBar(content: new Text("删除成功")));
      },
      movementDuration: Duration(microseconds: 100),
      key: Key(download.title),
      background: Container(
        color: Color(0xffff0000),
      ),
      child: GestureDetector(
        onLongPressStart: (detail) {
          if (download.status == 1 && download.isVideo == 1 && Platform.isIOS) {
            _showMenu(context, detail, download.path);
          }
        },
        onTap: () {
          if (download.isVideo == 1) {
            Navigator.push(context, MaterialPageRoute(builder: (context) {
              MovieBean movieBean = MovieBean();
              movieBean.playUrl = download.path;
              movieBean.name = download.title;
              return VideoPlayPage(movieBean,0,false);
            }));
          }
        },
        child: Column(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(left: 10, top: 5, bottom: 5, right: 10),
              child:  Row(
                children: <Widget>[
                  Expanded(
                    child: Padding(padding: EdgeInsets.only(left: 10),child: Text(download.title),),
                  ),
                  Column(children: <Widget>[   Padding(padding: EdgeInsets.only(top: 10),
                  child: download.status == 1?Text('已完成'):GestureDetector(
                    child: Icon(download.status == 0?Icons.pause:Icons.play_arrow),
                    onTap: (){
                      if(download.status == 2){
                        Fluttertoast.showToast(msg: '继续下载');
                        DownloadUtil.continueDown(download.url, download.path, download.title, download.isVideo);
                      }
                    },
                  ),),
                    Text('${(download.progress).toStringAsFixed(2)}%',)
                  ],)

                ],
              ),
            ),
            Slider(
              label: '${download.progress}',
              max: 100,
              min: 0,
              divisions: 1000,
              activeColor: Colors.blue,
              inactiveColor: Colors.grey,
              value: download.progress,
              onChanged: (double) {},
            )
          ],
        ),
      ),
    );
  }

  void _getData() async {
    try {
      List<Download> list = Download.fromMapList(widget._type == 0?await widget.db.getListWithDowning():await widget.db.getListWithFinish());
      _data.clear();
      if( !hasInit){
        list.forEach((downLoad){
          downLoad.status = downLoad.status == 0?2:downLoad.status;
          _data.add(downLoad);
        });
      }

    } catch (e) {
      print(e);
    }
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
      if(! await file.exists()){
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
}
