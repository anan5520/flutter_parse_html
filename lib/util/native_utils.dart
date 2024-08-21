import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'files.dart';

class NativeUtils {
  static const String methodSaveImage = 'saveImage';
  static const String methodSaveVideo = 'saveVideo';

  static const perform = const MethodChannel("android_go_to_act");
  static const umeng = const MethodChannel("umeng_channel");
  static const initX5 = const MethodChannel("initX5");
  static const goToBrowser = const MethodChannel("GO_TO_BROWSER");
  static const goToUcBrowser = const MethodChannel("GO_TO_UC_BROWSER");
  static const goToDownload = const MethodChannel("GO_TO_DOWNLOAD");
  static const goToPlay = const MethodChannel("GO_TO_PLAY");
  static const localGoToPlay = const MethodChannel("LOCAL_GO_TO_PLAY");
  static const goDouYin = const MethodChannel("GO_TO_DOU_YIN");
  static const _channel_gallery = const MethodChannel("arvin_gallery_saver");
  static const counterPlugin = const EventChannel('native/plugin');
  static const _strChangeEncode = const MethodChannel('STRING_ENCODE');

  static const String pleaseProvidePath = 'Please provide valid file path.';
  static const String fileIsNotVideo = 'File on path is not a video.';
  static const String fileIsNotImage = 'File on path is not an image.';
  static StreamSubscription? _subscription;

  static void onResume() {
    umeng.invokeMethod('onResume', {'event': " "});
  }

  static void onPause() {
    umeng.invokeMethod('onPause', {'event': " "});
  }

  static void onEvent(String event) {
    umeng.invokeMethod('event', {'event': event});
  }

  static void initX5Web() {
    initX5.invokeMethod('event', {'event': ''});
  }

  static void toAct(String magnet) {
    perform.invokeMethod('act', {'magnet': magnet});
  }

  static Future<bool?> toX5Browser(String url, String title) {
    return perform.invokeMethod('toX5Browser', {'url': url, 'title': title});
  }

  static void toX5Play(String url, String title) {
    perform.invokeMethod('toX5Play', {'url': url, 'title': title});
  }

  static void startQBrowser(String url) {
    goToBrowser.invokeMethod('GO_TO_BROWSER', {'url': url});
  }

  static void startUcBrowser(String url) {
    goToUcBrowser.invokeMethod('GO_TO_UC_BROWSER', {'url': url});
  }

  static void startDownload(String url) {
    goToDownload.invokeMethod('GO_TO_DOWNLOAD', {'url': url});
  }

  static void goToVideoPlay(String url, String title, bool isLive) {
    goToPlay.invokeMethod(
        'GO_TO_PLAY', {'url': url, 'title': title, 'isLive': isLive});
  }

  static void goToLocalVideoPlay(String url, String title, bool isLive) {
    localGoToPlay.invokeMethod(
        'LOCAL_GO_TO_PLAY', {'url': url, 'title': title, 'isLive': isLive});
  }

  static void goToDouYin(String type) {
    goDouYin.invokeMethod('GO_TO_DOU_YIN', {'type': type});
  }

  static void toBrowser(String url) {
    perform.invokeMethod('toBrowser', {'url': url});
  }

  static void toXfPlay(String url) {
    perform.invokeMethod('xfplay', {'url': url});
  }

  static Future<String> strChangeEncode(
      String str, String oldChar, String newChar){
   return _strChangeEncode.invokeMethod('STRING_ENCODE', {
      'str': str,
      'oldChar': oldChar,
      'newChar': newChar
    }).then((value) => value.toString());
  }

  ///saves video from provided temp path and optional album name in gallery
  static Future<bool> saveVideo(String path, {String albumName = ""}) async {
    File? tempFile;
    if (path == null || path.isEmpty) {
      throw ArgumentError(pleaseProvidePath);
    }
    if (!isVideo(path)) {
      throw ArgumentError(fileIsNotVideo);
    }
    if (!isLocalFilePath(path)) {
      tempFile = await _downloadFile(path);
      path = tempFile.path;
    }
    bool result = await _channel_gallery.invokeMethod(
      methodSaveVideo,
      <String, dynamic>{'path': path, 'albumName': albumName},
    );
    if (tempFile != null) {
      tempFile.delete();
    }
    return result;
  }

  ///saves image from provided temp path and optional album name in gallery
  static Future<bool> saveImage(String path,
      {String albumName = '', Map<String, String> headers = const {}}) async {
    File? tempFile;
    if (path == null || path.isEmpty) {
      throw ArgumentError(pleaseProvidePath);
    }
    if (!isImage(path)) {
      throw ArgumentError(fileIsNotImage);
    }
    if (!isLocalFilePath(path)) {
      tempFile = await _downloadFile(path, headers: headers);
      path = tempFile.path;
    }

    bool result = await _channel_gallery.invokeMethod(
      methodSaveImage,
      <String, dynamic>{'path': path, 'albumName': albumName},
    );
    if (tempFile != null) {
      tempFile.delete();
    }

    return result;
  }

  static void startFromNativeLis(void onData(dynamic event)?,
      {Function? onError}) {
    //开启监听
    if (_subscription == null) {
      _subscription = counterPlugin
          .receiveBroadcastStream()
          .listen(onData, onError: onError);
    }
  }

  static void cancelFromNativeLis() {
    if (_subscription != null) {
      _subscription?.cancel();
    }
  }

  static Future<File> _downloadFile(String url,
      {Map<String, String> headers = const {}}) async {
    print(url);
    var response = await http.get(Uri(path: url), headers: headers);
    var bytes = response.bodyBytes;
    String dir = (await getTemporaryDirectory()).path;
    File file = new File('$dir/${basename(url)}');
    await file.writeAsBytes(bytes);
    print('File size:${await file.length()}');
    print(file.path);
    return file;
  }
}
