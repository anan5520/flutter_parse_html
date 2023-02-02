import 'dart:core';

import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_parse_html/book/base/util/utils_toast.dart';
import 'package:flutter_parse_html/model/movie_bean.dart';
import 'package:flutter_parse_html/ui/video_play.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path/path.dart';

import 'native_utils.dart';

class CommonUtil {
  static String toMd5(String result) {
    return md5.convert(utf8.encode(result)).toString();
  }

  static String replaceStr(String result) {
    return result.replaceAll(new RegExp(r'\n|\t|  '), '');
  }

  static void showLoading(BuildContext context) {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return SpinKitWave(
            color: Colors.blue,
          );
        });
  }

  static void toVideoPlay(String playUrl, BuildContext context,
      {String title = '',
      bool isLive = false,
      List<MovieItemBean> movieList,
      bool toWebPlay = false,bool isDownLoad = false,bool onlyWeb = false}) async {
    MovieBean movieBean = MovieBean();
    movieBean.playUrl = playUrl;
    movieBean.name = title;
    movieBean.list = movieList;
    if(isLive){
      NativeUtils.goToVideoPlay(playUrl, title,isLive);
    }else{
      showDialog(
          context: context,
          builder: (context) {
            return SimpleDialog(
              title:Text('选择播放器(打不开或资源慢的可以选择跳转浏览器)'),
              children: [
                FlatButton(
                  child: Text(title),
                  onPressed: () {

                  },
                ),
                isDownLoad ? Container():
                FlatButton(
                  child: Text("ij播放器(推荐)"),
                  onPressed: () {
                    if(Platform.isAndroid){
                      print('播放:$playUrl');
                      Navigator.pop(context);
                      NativeUtils.goToVideoPlay(playUrl, '',false);
                    }else{
                      ToastUtils.showToast("不支持ios");
                    }
                  },
                ),
                isDownLoad ? Container():
                FlatButton(
                  child: Text("内置播放器"),
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.of(context).push(
                        new MaterialPageRoute(builder: (BuildContext context) {
                          return VideoPlayPage.alongMovieBean(movieBean);
                        }));
                  },
                ),
                FlatButton(
                  child: Text("跳转uc浏览器播放下载"),
                  onPressed: () {
                    if(Platform.isAndroid){
                      print('播放:$playUrl');
                      Navigator.pop(context);
                      NativeUtils.startUcBrowser(playUrl);
                    }else{
                      ToastUtils.showToast("不支持ios");
                    }

                  },
                ),
                FlatButton(
                  child: Text("跳转qq浏览器播放下载(推荐)"),
                  onPressed: () {
                    if(Platform.isAndroid){
                      print('播放:$playUrl');
                      Navigator.pop(context);
                      NativeUtils.startQBrowser(playUrl);
                    }else{
                      ToastUtils.showToast("不支持ios");
                    }

                  },
                ),
                FlatButton(
                  child: Text("本机播放"),
                  onPressed: () {
                    if(Platform.isAndroid){
                      print('播放:$playUrl');
                      Navigator.pop(context);
                      NativeUtils.goToLocalVideoPlay(playUrl, '',false);
                    }else{
                      ToastUtils.showToast("不支持ios");
                    }
                  },
                ),
                isDownLoad ? Container():FlatButton(
                  child: Text("x5播放器"),
                  onPressed: () {
                    if(Platform.isAndroid){
                      print('播放:$playUrl');
                      Navigator.pop(context);
                      NativeUtils.toX5Play(playUrl, '');
                    }else{
                      ToastUtils.showToast("不支持ios");
                    }

                  },
                ),
                FlatButton(
                  child: Text("复制播放地址"),
                  onPressed: () {
                    Fluttertoast.showToast(
                        msg: '已复制到粘贴板', toastLength: Toast.LENGTH_SHORT);
                    Clipboard.setData(
                        new ClipboardData(text: playUrl));
                  },
                ),
              ],);
          });
    }

  }
}
