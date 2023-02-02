import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_parse_html/net/net_util.dart';
import 'package:flutter_parse_html/util/aes_util.dart';
import 'package:flutter_parse_html/widget/dialog_page.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parse;
import 'package:flutter_parse_html/util/native_utils.dart';
import 'package:extended_image/extended_image.dart';
import 'package:image_saver/image_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'package:crypto/crypto.dart';

// ignore: must_be_immutable
class ShowStaggeredImagePage extends StatefulWidget {
  List<String> imgs;
  bool addHeader = false;
  var parentContext;
  final Map arguments;
  int type = 0;

  ShowStaggeredImagePage(this.arguments);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    imgs = arguments['list'];
    type = arguments['type'] == null ? 0 : arguments['type'];
    addHeader = arguments['addHeader'] == null ? false : arguments['addHeader'];
    return BookState(imgs, parentContext);
  }
}

class BookState extends State<ShowStaggeredImagePage> {
  String content = '';
  List<String> imgs;

  PageController _pageController;
  var parentContext;
  Map<String, String> header;
  StreamController<List<String>> imgeStream = StreamController.broadcast();

  BookState(this.imgs, this.parentContext);

  @override
  void initState() {
    super.initState();
    header = widget.addHeader
        ? {
            'Accept-Language': 'zh-CN,zh;q=0.9,zh-TW;q=0.8',
//            'Host': 'i.meizitu.net',
            'User-Agent':
                'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/63.0.3239.132 Safari/537.36',
            'Referer': 'http://www.mzitu.com/'
          }
        : {};
    _pageController = new PageController();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.type == 1) {
      for (int i = 0; i < widget.imgs.length; i++) {
        _getImage(i);
      }
    }
    return Scaffold(
      appBar: AppBar(
        title: Text('图片'),
        leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            }),
      ),
      body: Center(
          child: new StaggeredGridView.countBuilder(
        primary: true,
        crossAxisCount: 4,
        mainAxisSpacing: 4.0,
        crossAxisSpacing: 4.0,
        itemCount: imgs.length,
        itemBuilder: (BuildContext context, int index) => new Container(
            color: Colors.grey,
            child: GestureDetector(
              onTap: () {
                _showDialog(imgs[index]);
              },
              child: new Center(
                child: StreamBuilder(
                  stream: imgeStream.stream,
                  builder: (context, snap) {
                    return widget.type == 1
                        ? (imgs[index].startsWith('http')
                            ? Image.asset('images/video_bg.png')
                            : Image.file(
                                File(imgs[index]),
                                gaplessPlayback: true,
                                fit: BoxFit.cover,
                              ))
                        : new CachedNetworkImage(
                            httpHeaders: header,
                            imageUrl: imgs[index],
                          );
                  },
                ),
              ),
            )),
        staggeredTileBuilder: (int index) => new StaggeredTile.fit(2),
      )),
    );
  }

  @override
  void dispose() {
    super.dispose();
    imgeStream.close();
    _pageController.dispose();
  }

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

  void _showDialog(var url) async {
    showDialog(
        context: context,
        builder: (context) {
          return new AlertDialog(
            content: ShowImageDialog(url),
          );
        });
  }

  void _onImageSaveButtonPressed(String url) async {
    print('保存图片>>>$url');

    if (Platform.isAndroid) {
      // var response = await http.get(url, headers: header);
      // File savedFile = await ImageSaver.toFile(fileData: response.bodyBytes);
      // print('保存成功>>>' + savedFile.path);
      GallerySaver.saveImage(url).then((value) {
        Fluttertoast.showToast(msg: '保存成功$value');
      });
    } else {
      NativeUtils.saveImage(url, albumName: 'Media', headers: header)
          .then((bool success) {
        print('保存图片返回结果>>$success');
        Fluttertoast.showToast(msg: '保存成功');
      });
    }
//    var response = await Dio().get(
//        url,
//        options: Options(responseType: ResponseType.bytes,headers: header));
//    final result =
//        await ImageGallerySaver.saveImage(Uint8List.fromList(response.data));
//    print('保存成功>>>' +result);
//    var response = await http.get(url,headers: header);
//    File savedFile = await ImageSaver.toFile(fileData: response.bodyBytes);
//    print('保存成功>>>' + savedFile.path);
//    if (!mounted) {
//      return;
//    }
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

  _getImage(int index) async {
    String url = widget.imgs[index];
    Directory tempDir = await getTemporaryDirectory();
    var path = '${tempDir.path}/${md5.convert(new Utf8Encoder().convert(url))}';
    Widget image = await NetUtil.dio.download(url, path).then((value) async {
      var file = File(path);
      return await file.readAsBytes().then((value) {
        String old = base64Encode(value);
        String base64 = EncryptUtil().aesDecode(old);
        file.writeAsBytes(base64Decode(base64)).then((value){
          widget.imgs[index] = path;
          imgeStream.sink.add(widget.imgs);
        });

        return;
      });
    });
    return image;
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
