import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parse;
import 'package:flutter_parse_html/util/native_utils.dart';
import 'package:extended_image/extended_image.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'package:crypto/crypto.dart';

import '../../net/net_util.dart';
class ImagePage extends StatefulWidget {
  late List<String> imgs;
  bool addHeader = false;
  var parentContext;
  final Map arguments;

  ImagePage(this.arguments);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    imgs = arguments['list'];
    addHeader = arguments['addHeader'] == null ? false : arguments['addHeader'];
    return BookState(imgs, parentContext);
  }
}

class BookState extends State<ImagePage> {
  String content = '';
  late List<String> imgs;

  late PageController _pageController;
  late var parentContext;
  late Map<String, String> header;

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
          child: PageView.builder(
        itemCount: imgs.length,
        scrollDirection: Axis.horizontal,
        controller: _pageController,
        itemBuilder: (context, index) {
          return Padding(
            padding: EdgeInsets.only(left: 10, right: 10),
            child: GestureDetector(
              onLongPressStart: (detail) {
                _showMenu(context, detail, imgs[index]);
              },
              child: ExtendedImage.network(
                imgs[index],
                headers: header,
                cache: true,
                fit: BoxFit.contain,
                mode: ExtendedImageMode.gesture,
                initGestureConfigHandler: (state) {
                  return GestureConfig(
                      minScale: 0.8,
                      animationMinScale: 0.7,
                      maxScale: 3.0,
                      animationMaxScale: 3.5,
                      speed: 1.0,
                      initialScale: 1.0,
                      inPageView: true,
                      inertialSpeed: 100.0);
                },
              ),
            ),
          );
        },
      )),
    );
  }

  @override
  void dispose() {
    super.dispose();
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
        if (pop.onCanceled != null) pop.onCanceled!.call();
        return null;
      }
      if (pop.onSelected != null) pop.onSelected!.call(newValue);
    });
  }

  void _onImageSaveButtonPressed(String url) async {
    print('保存图片>>>$url');

    if (Platform.isAndroid) {
      // var response = await http.get(url, headers: header);
      // File savedFile = await ImageSaver.toFile(fileData: response.bodyBytes);
      // print('保存成功>>>' + savedFile.path);
      if(url.endsWith('gif')){
        Directory tempDir = await getTemporaryDirectory();
        var path = '${tempDir.path}/${md5.convert(new Utf8Encoder().convert(url))}.gif';
        await NetUtil.dio.download(url, path);
        await ImageGallerySaver.saveFile(path, isReturnPathOfIOS: true);
      }else{
        var response = await Dio().get(url,
            options: Options(responseType: ResponseType.bytes));
        final result = await ImageGallerySaver.saveImage(Uint8List.fromList(response.data));
      }
      Fluttertoast.showToast(msg: '保存成功');

    } else {
      NativeUtils.saveImage(url, albumName: 'Media',headers: header).then((bool success) {
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
