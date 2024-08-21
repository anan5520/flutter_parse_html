import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_parse_html/db/download_db.dart';
import 'package:flutter_parse_html/net/net_util.dart';
import 'package:flutter_parse_html/util/common_util.dart';
import 'package:path_provider/path_provider.dart';

class DownloadUtil {
  static DatabaseHelper? _dbHelper;

  static RefreshCallback? _refreshCallback;

  static DatabaseHelper get dbHelper {
    if (_dbHelper != null) {
      return _dbHelper!;
    }
    _dbHelper = DatabaseHelper();
    return _dbHelper!;
  }

  static void refreshCallback(RefreshCallback value) {
    _refreshCallback = value;
  }

  static Future downVideo(
    String url,
    title,
    int isVideo, {
    bool isM3u8 = false,
    double? videoLength,
        int maxTaskNum = 0,
    ProgressCallback? onReceiveProgress,
  }) async {
    Directory? appDocDir = Platform.isAndroid
        ? await getExternalStorageDirectory()
        : await getApplicationDocumentsDirectory();
    String md5Url = CommonUtil.toMd5(url);
    String path = "${appDocDir?.path}/$md5Url/$md5Url.mp4";
    File file = new File(path);
    if (!await file.parent.exists()) {
      await file.parent.create();
    }
    print('下载地址>>$path');
    if (url.contains('.m3u8') || isM3u8) {
      return _downM3u8(url, title, path,
          onReceiveProgress: onReceiveProgress!, videoLength: videoLength!,maxTaskNum: maxTaskNum);
    } else {
      return _downloadWithChunks(url, path, title + md5Url, isVideo,
          onReceiveProgress: onReceiveProgress!, videoLength: videoLength!);
    }
  }

  /// Downloading by spiting as file in chunks
  static Future _downloadWithChunks(
    url,
    savePath,
    title,
    int isVideo, {
    double? videoLength,
    ProgressCallback? onReceiveProgress,
  }) async {
    Download? download = await dbHelper.getItem(title);
    if (download == null) {
      print('数据库中没有>>>>');
      dbHelper.saveItem(Download.make(0, url, title, savePath, 0, 0,
          videoLength == null ? 0 : videoLength, isVideo));
    }
    const firstChunkSize = 102;
    const maxChunk = 3;

    int total = 0;
    var dio = Dio();
    var progress = <int>[];

    createCallback(no) {
      return (int received, _) {
        progress[no] = received;
        if (total != 0) {
          int count = progress.reduce((a, b) => a + b);
          int percentage = (count * 100) ~/ total;
          if (percentage % 4 == 0) {
            dbHelper.updateItemWithMap({
              'progress': (count * 100) / total,
              'status': count == total ? 1 : 0,
              'path': savePath,
            }, title);
            print('percentage>>$percentage|更新>》》》');
            if (_refreshCallback != null) _refreshCallback!(percentage);
            if (onReceiveProgress != null) onReceiveProgress(count, total);
          }
        }
      };
    }

    Future<Response> downloadChunk(url, start, end, no) async {
      progress.add(0);
      --end;
      return dio.download(
        url,
        savePath + "temp$no",
        onReceiveProgress: createCallback(no),
        options: Options(
          headers: {"range": "bytes=$start-$end"},
        ),
      );
    }

    Future mergeTempFiles(chunk) async {
      File f = File(savePath + "temp0");
      IOSink ioSink = f.openWrite(mode: FileMode.writeOnlyAppend);
      for (int i = 1; i < chunk; ++i) {
        File _f = File(savePath + "temp$i");
        await ioSink.addStream(_f.openRead());
        await _f.delete();
      }
      await ioSink.close();
      await f.rename(savePath);
      print('下载完成>>>>$savePath');
    }

    // 通过第一个分块请求检测服务器是否支持分块传输
    Response response = await downloadChunk(url, 0, firstChunkSize, 0);
    if (response.statusCode == 206) {
      //如果支持
      //解析文件总长度，进而算出剩余长度
      total = int.parse(response.headers
          .value(HttpHeaders.contentRangeHeader)
          ?.split("/")
          .last??'');
      int reserved = total -
          int.parse(response.headers.value(HttpHeaders.contentLengthHeader)??'');
      //文件的总块数(包括第一块)
      int chunk = (reserved / firstChunkSize).ceil() + 1;

      print('下载>>>total>$total>文件的总数>$chunk');
      if (chunk > 1) {
        int chunkSize = firstChunkSize;
        if (chunk > maxChunk + 1) {
          chunk = maxChunk + 1;
          chunkSize = (reserved / maxChunk).ceil();
        }
        print('下载>>>firstChunkSize>$firstChunkSize>剩余每个大小chunkSize>$chunkSize');
        print('下载>>>total>$total>文件的总数 maxChunk>$maxChunk');
        var futures = <Future>[];
        for (int i = 0; i < maxChunk; ++i) {
          int start = firstChunkSize + i * chunkSize;
          //分块下载剩余文件
          futures.add(downloadChunk(url, start, start + chunkSize, i + 1));
        }
        //等待所有分块全部下载完成
        await Future.wait(futures);
      }
      //合并文件文件
      await mergeTempFiles(chunk);
    } else if (response.statusCode == HttpStatus.internalServerError) {
      print('下载出错>>>');
    }
  }

  static Future _downM3u8(String url, String title, savePath,
      {double? videoLength,int maxTaskNum = 0, ProgressCallback? onReceiveProgress}) async {

    var dio = Dio();
    int total = 0;
    var progress = <int>[];

    List<String> tsUrls = await _getM3u8PartUrls(url);

    Download? download = await dbHelper.getItem(title);
    if (download == null) {
      print('数据库中没有>>>>');
      dbHelper.saveItem(Download.make(0, url, title, savePath, 0, 0,
          videoLength == null ? 0 : videoLength, 1));
    }

    createCallback(no) {
      return (int received, all) {
        progress[no] = received;
        if (total != 0) {
          int count = progress.reduce((a, b) => a + b);
          int percentage = (count * 100) ~/ total;
          if (percentage % 4 == 0) {
//            dbHelper.updateItemWithMap({
//              'progress': (count * 100) / total,
//              'status': count == total ? 1 : 0,
//            }, title);
//            print('percentage>>$percentage|更新>》》》');`
            if (_refreshCallback != null) _refreshCallback!(percentage);
            if (onReceiveProgress != null) onReceiveProgress(count, total);
          }
        }
      };
    }
    Future mergeTempFiles(chunk) async {
      if(chunk == 0){
        File f = File(savePath + "temp0");
        await f.rename(savePath);
        File saveFile = File(savePath);
        await saveFile.parent.list().forEach((file) async{
          if(file.path != savePath.toString()){
            IOSink ioSink = saveFile.openWrite(mode: FileMode.writeOnlyAppend);
            File _f = File(file.path);
            await ioSink.addStream(_f.openRead());
            await ioSink.close();
            await _f.delete();
          }
        });

      }else{
        File f = File(savePath);
        if(await f.exists()){
          print('合并》》》》temp$chunk');
          IOSink ioSink = f.openWrite(mode: FileMode.writeOnlyAppend);
          File _f = File(savePath + "temp$chunk");
          await ioSink.addStream(_f.openRead());
          await ioSink.close();
          await _f.delete();
        }
      }
      print('合并到》》》》$chunk');
//      print('合并》》》》开始');
//      File f = File(savePath + "temp0");
//      IOSink ioSink = f.openWrite(mode: FileMode.writeOnlyAppend);
//      for (int i = 1; i < chunk; ++i) {
//        print('合并》》》》$i');
//        File _f = File(savePath + "temp$i");
//        await ioSink.addStream(_f.openRead());
//        await _f.delete();
//      }
//      await ioSink.close();
//      await f.rename(savePath);
//      print('下载完成>>>>${f.path} || savePah>>$savePath');
//      dbHelper.updateItemWithMap({
//        'progress': 100,
//        'status': 1,
//        'path': savePath,
//      }, title);
    }

    Future<Response?> downloadChunk(url, no) async {
      try {
        progress.add(0);
        print('开始下载>>$url||$no');
        return dio.download(
          url,
          savePath + "temp$no",
          onReceiveProgress: createCallback(no),
        ).then((reponse)async{
          print('下载完成》》》》$no');
          await mergeTempFiles(no);
          return reponse;
        });
      } catch (e) {
        print(e);
        print('下载失败>>>${e.toString()}');
        return null;
      }
    }


    total = tsUrls.length;
    int maxTask = total <= 80 ? 1 : maxTaskNum > 0?maxTaskNum:5;
    int temp = 0;
    Future<String> downWithMax() {
      int tem = temp;
      var futures = <Future>[];
      for (int i = 0; i < maxTask; ++i) {
        //分块下载剩余文件
        if (i + tem < tsUrls.length) {
          futures.add(downloadChunk(tsUrls[i + tem], i + tem));
          temp++;
        }
      }
      //等待所有分块全部下载完成
      return Future.wait(futures).then((list) async {
        if (onReceiveProgress != null) {
          onReceiveProgress(temp, total);
        }
        print('下载到>>>>$temp总共》》${tsUrls.length}');
        dbHelper.updateItemWithMap({
          'progress': (temp * 100) / total,
          'status': temp == total ? 1 : 0,
          'path': savePath,
        }, title);
        if (temp < tsUrls.length) {
          await downWithMax();
        } else {
          print('下载完毕>>>>$temp');
        }
        return '';
      });
    }

    await downWithMax();
//    print('合并》》》》开始');
    //合并文件文件
//    await mergeTempFiles(total);
    if (onReceiveProgress != null) {
      print('合成完毕>>>>$temp');
      onReceiveProgress(temp, total);
    }
  }

  static Future<String> downAndMerge(url, List<String> tsUrls, savePath, title,
      ProgressCallback onReceiveProgress,
      {int start = 0}) async {
    print('从$start开始');
    var dio = Dio();
    int total = 0;
    var progress = <int>[];
    createCallback(no) {
      return (int received, _) {
        progress[no] = received;
        if (total != 0) {
          int count = progress.reduce((a, b) => a + b);
          int percentage = (count * 100) ~/ total;
          if (percentage % 4 == 0) {
//            dbHelper.updateItemWithMap({
//              'progress': (count * 100) / total,
//              'status': count == total ? 1 : 0,
//            }, title);
//            print('percentage>>$percentage|更新>》》》');
            if (_refreshCallback != null) _refreshCallback!(percentage);
            if (onReceiveProgress != null) onReceiveProgress(count, total);
          }
        }
      };
    }

    Future<Response?> downloadChunk(url, no) async {
      try {
        progress.add(0);
        print('开始下载>>$url||$no');
        return dio.download(
          url,
          savePath + "temp$no",
          onReceiveProgress: createCallback(no),
        );
      } catch (e) {
        print(e);
        print('下载失败>>>${e.toString()}');
        return null;
      }
    }

    Future<int> mergeTempFiles(chunk) async {
      print('合并》》》》开始');
      File f = File(savePath + "temp0");
      IOSink ioSink = f.openWrite(mode: FileMode.writeOnlyAppend);
      for (int i = 1; i < chunk; ++i) {
        print('合并》》》》$i');
        File _f = File(savePath + "temp$i");
        await ioSink.addStream(_f.openRead());
        await _f.delete();
      }
      await ioSink.close();
      await f.rename(savePath);
      print('下载完成>>>>${f.path} || savePah>>$savePath');
      return dbHelper.updateItemWithMap({
        'progress': 100,
        'status': 1,
        'path': savePath,
      }, title);
    }

    total = tsUrls.length;
    int maxTask = total <= 80 ? 2 : 5;
    int temp = start;
    Future<String> downWithMax() {
      int tem = temp;
      var futures = <Future>[];
      for (int i = 0; i < maxTask; ++i) {
        //分块下载剩余文件
        if (i + tem < tsUrls.length) {
          futures.add(downloadChunk(tsUrls[i + tem], i + tem));
          temp++;
        }
      }
      //等待所有分块全部下载完成
      return Future.wait(futures).then((list) async {
        int realTemp = start + temp;
        if (onReceiveProgress != null) {
          onReceiveProgress(realTemp, total);
        }
        print('下载到>>>>$realTemp总共》》${tsUrls.length}');
        dbHelper.updateItemWithMap({
          'progress': (realTemp * 100) / total,
          'status': realTemp == total ? 1 : 0,
          'path': savePath,
        }, title);
        if (realTemp < tsUrls.length) {
          await downWithMax();
        } else {
          print('下载完毕>>>>$realTemp');
        }
        return '';
      });
    }

    await downWithMax();
    print('合并》》》》开始');
    //合并文件文件
    return mergeTempFiles(total).then((int) {
      if (onReceiveProgress != null) {
        print('合成完毕>>>>${temp + start}');
        onReceiveProgress(temp + start, total);
      }
      return "";
    });
  }

  static Future<List<String>> _getM3u8PartUrls(String url) {
    List<String> tsUrls = [];
    int index = url.lastIndexOf('/') + 1;
    var baseM3u8Url = url.substring(0, index);
    var baseUrls = url.split('//');
    var baseUrl = baseUrls[0] +
        '//' +
        baseUrls[1].substring(0, baseUrls[1].indexOf('/') + 1);
    //获取片段地址
    Future<String> getUrl(String url) async {
      return NetUtil.getHtmlData(url, isWeb: true).then((response) async {
        var urls = response.split('\n');
        for (int i = 0; i < urls.length; i++) {
          var s = urls[i];
          if (s.contains(".m3u8")) {
            String tempStr = baseUrls[1].split('/')[1];
            if(s.contains(tempStr)){
              baseM3u8Url = baseUrl;
            }
            if(baseM3u8Url.endsWith('/') && s.startsWith('/')){
              baseM3u8Url = baseM3u8Url.substring(0,baseM3u8Url.length - 1);
            }
            await getUrl('$baseM3u8Url$s');
          } else if (s.contains('.jpg') || s.contains('.ts')) {
            if (s.contains('.ts')) {
              if(s.startsWith('http')){
                baseUrl = '';
              }else if(!s.contains(baseUrls[1].split('/')[1])){
                baseUrl = '${url.substring(0, url.lastIndexOf('/'))}/';
              }
            }
            s = s.replaceAll('\r', '');
            if(baseUrl.endsWith('/') && s.startsWith('/')){
              baseUrl = baseUrl.substring(0,baseUrl.length - 1);
            }
            tsUrls.add('$baseUrl$s');
          }
        }
        return '';
      });
    }

    return getUrl(url).then((url) {
      return tsUrls;
    });
  }

  static Future continueDown (
    url,
    savePath,
    title,
    int isVideo, {
    double? videoLength,
    ProgressCallback? onReceiveProgress,
  }) async {
    List<String> tsUrls = await _getM3u8PartUrls(url);
    File file = new File(savePath);
    int start = await file.parent.list().length;
    await downAndMerge(url, tsUrls, savePath, title, onReceiveProgress!,start: start);
  }
}

typedef RefreshCallback = void Function(int per);
