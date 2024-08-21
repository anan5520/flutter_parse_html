import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/io.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:dio/dio.dart';
import 'package:flutter_gbk2utf8/flutter_gbk2utf8.dart';
import 'package:path/path.dart';
import 'package:http/http.dart' as http;

class NetUtil {
  static final debug = false;
  static BuildContext? context = null;

  /// 服务器路径
  static final host = 'http://xxxxxxxx';
  static final baseUrl = host + '/api/';

  ///  基础信息配置
  static final Dio _dio = new Dio(new BaseOptions(
      method: "get",
      connectTimeout: Duration(seconds: 20),
      receiveTimeout: Duration(seconds: 20),
      followRedirects: true));


  static Dio get dio => _dio;

  /// 代理设置，方便抓包来进行接口调节

  static void setProxy() {
    //Fiddler抓包设置代理
    (_dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
        (client) {
      client.findProxy = (url) {
        return "PROXY 192.168.0.108:8888";
      };
      //抓Https包设置
      client.badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
    };
  }

  static String? token;

  static final LogicError unknowError = LogicError(-1, "未知异常");

  static Future<String> getHtmlDataWithHttp<T>(String uri,
          {Map<String, dynamic>? paras,
          Map<String, dynamic>? header,
          String? referer,
          bool? isWeb,
          bool? isGbk,
          bool saveCookie = false}) =>
      _httpHtmlDataWithHttp("get", uri, referer,
          data: paras,
          header: header,
          isWeb: isWeb,
          isGbk: isGbk,
          saveCookie: saveCookie);

  static Future<String> getHtmlData<T>(String? uri,
          {Map<String, dynamic>? paras,
          Map<String, dynamic>? header,
          String? referer,
          bool? isWeb,
          bool? isGbk,
          bool saveCookie = false}) =>
      _httpHtmlData("get", uri??'', referer,
          data: paras,
          header: header,
          isWeb: isWeb,
          isGbk: isGbk,
          saveCookie: saveCookie);

  static Future<String> getHtmlDataPost<T>(String uri,
          {Map<String, dynamic>? paras,
          Map<String, dynamic>? header,
          String? referer,
          bool? isGbk,
          bool? isWeb}) =>
      _httpHtmlDataPost("post", uri, referer,
          data: paras, header: header, isWeb: isWeb, isGbk: isGbk);

  static Future<Map<String, dynamic>> getJson<T>(
          String uri, Map<String, dynamic> paras) =>
      _httpJson("get", uri, data: paras).then(logicalErrorTransform);

  static Future<Map<String, dynamic>> getForm<T>(
          String uri, Map<String, dynamic> paras) =>
      _httpJson("get", uri, data: paras, dataIsJson: false)
          .then(logicalErrorTransform);

  /// 表单方式的post
  static Future<Map<String, dynamic>> postForm<T>(
          String uri, Map<String, dynamic> paras) =>
      _httpJson("post", uri, data: paras, dataIsJson: false)
          .then(logicalErrorTransform);

  /// requestBody (json格式参数) 方式的 post
  static Future<Map<String, dynamic>> postJson(
          String uri, Map<String, dynamic> body) =>
      _httpJson("post", uri, data: body).then(logicalErrorTransform);

  static Future<Map<String, dynamic>> deleteJson<T>(
          String uri, Map<String, dynamic> body) =>
      _httpJson("delete", uri, data: body).then(logicalErrorTransform);

  /// requestBody (json格式参数) 方式的 put
  static Future<Map<String, dynamic>> putJson<T>(
          String uri, Map<String, dynamic> body) =>
      _httpJson("put", uri, data: body).then(logicalErrorTransform);

  /// 表单方式的 put
  static Future<Map<String, dynamic>> putForm<T>(
          String uri, Map<String, dynamic> body) =>
      _httpJson("put", uri, data: body, dataIsJson: false)
          .then(logicalErrorTransform);

//  /// 文件上传  返回json数据为字符串
//  static Future<T> putFile<T>(String uri, String filePath) {
//    var name =
//    filePath.substring(filePath.lastIndexOf("/") + 1, filePath.length);
//    var suffix = name.substring(name.lastIndexOf(".") + 1, name.length);
//    FormData formData = new FormData.from({
//      "multipartFile": new UploadFileInfo(new File(filePath), name,
//          contentType: ContentType.parse("image/$suffix"))
//    });
//
//    var enToken = token == null ? "" : Uri.encodeFull(token);
//    return _dio
//        .put<Map<String, dynamic>>("$uri?token=$enToken", data: formData)
//        .then(logicalErrorTransform);
//  }

  static Future<Response<Map<String, dynamic>>> _httpJson(
      String method, String uri,
      {Map<String, dynamic>? data, bool dataIsJson = true}) {
    var enToken = token == null ? "" : Uri.encodeFull(token!);

    /// 如果为 get方法，则进行参数拼接
    if (method == "get") {
      dataIsJson = false;
      if (data == null) {
        data = new Map<String, dynamic>();
      }
      data["token"] = token;
    }

    if (debug) {
      print('<net url>------$uri');
      print('<net params>------$data');
    }

    /// 根据当前 请求的类型来设置 如果是请求体形式则使用json格式
    /// 否则则是表单形式的（拼接在url上）
    Options op;
    if (dataIsJson) {
      op = new Options(contentType: "application/x-www-form-urlencoded");
    } else {
      op = new Options(contentType: "application/x-www-form-urlencoded");
    }

    op.method = method;

    /// 统一带上token
    return _dio.request<Map<String, dynamic>>(
        method == "get" ? uri : "$uri?token=$enToken",
        data: data,
        options: op);
  }

  //获取网页内容
  static Future<String> _httpHtmlData(String method, String uri, String? referer,
      {Map<String, dynamic>? data,
      Map<String, dynamic>? header,
      bool dataIsJson = true,
      bool? isWeb = true,
      bool? isGbk = false,
      bool saveCookie = false,
      Function(String error)? error}) {
//    setProxy();
    if (saveCookie) {
      var cookieJar = CookieJar();
      _dio.interceptors.add(CookieManager(cookieJar));
    }

    /// 如果为 get方法，则进行参数拼接
    if (method == "get") {
      dataIsJson = false;
      if (data == null) {
        data = new Map<String, dynamic>();
      }
      if (data.length > 0) {
        uri = '$uri${!uri.contains("?") ? "?" : "&"}';
      }
      data.forEach((key, value) {
        uri = '$uri$key=$value&';
      });
      if (uri.endsWith('&')) {
        uri = uri.substring(0, uri.length - 1);
      }
    }

    if (debug) {
      print('<net url>------$uri');
      print('<net params>------$data');
    }

    /// 根据当前 请求的类型来设置 如果是请求体形式则使用json格式
    /// 否则则是表单形式的（拼接在url上）
    Options op;
    op = new Options(contentType: "application/x-www-form-urlencoded");
    if (isGbk != null && isGbk) {
      op.responseDecoder = (List<int> responseBytes, RequestOptions options,
          ResponseBody responseBody) {
        var body = gbk.decode(responseBytes);
        // var body = utf8decoder.convert(responseBytes);
        return body;
      };
    }
    Map<String, dynamic> headerMap = isWeb == null || isWeb
        ? {
            "User-Agent":
                "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/68.0.3440.84 Safari/537.36",
            "Accept-Language": "zh-CN,zh;q=0.8,zh-TW;q=0.7,zh-HK;q=0.5",
            "Connection": "keep-alive",
            // "Cache-Control": "max-age=0",
            "Connection": "keep-alive",
            "Referer": referer == null || referer.isEmpty ? uri : referer,
          }
        : {
            "User-Agent":
                "Mozilla/5.0 (Linux; U; Android 2.3.6; zh-cn; GT-S5660 Build/GINGERBREAD) AppleWebKit/533.1 (KHTML, like Gecko) Version/4.0 Mobile Safari/533.1 MicroMessenger/4.5.255",
            "Accept-Language": "zh-CN,zh;q=0.8,zh-TW;q=0.7,zh-HK;q=0.5",
            "Proxy-Connection": "keep-alive",
            "Cache-Control": "max-age=0",
          };
    if (header != null) {
      headerMap.addAll(header);
    }
    op.method = method;
    op.headers = headerMap;
    print('请求url>>$uri');
    return _dio.get<String>(uri, options: op).then((value) {
      print('返回结果:${value.data}');
      return Future.value(value.data??'');
    }).catchError((e){
      return Future.value('error');
    });
  }

  //获取网页内容
  static Future<String> _httpHtmlDataWithHttp(
      String method, String uri, String? referer,
      {Map<String, dynamic>? data,
      Map<String, dynamic>? header,
      bool dataIsJson = true,
      bool? isWeb = true,
      bool? isGbk = false,
      bool saveCookie = false,
      Function(String error)? error}) {
//    setProxy();
    /// 如果为 get方法，则进行参数拼接
    if (method == "get") {
      dataIsJson = false;
      if (data == null) {
        data = new Map<String, dynamic>();
      }
      if (data.length > 0) {
        uri = '$uri?';
      }
      data.forEach((key, value) {
        uri = '$uri$key=$value&';
      });
      if (uri.endsWith('&')) {
        uri = uri.substring(0, uri.length - 1);
      }
    }

    if (debug) {
      print('<net url>------$uri');
      print('<net params>------$data');
    }

    /// 根据当前 请求的类型来设置 如果是请求体形式则使用json格式
    /// 否则则是表单形式的（拼接在url上）
    Options op;
    op = new Options(contentType: "application/x-www-form-urlencoded");
    if (isGbk != null && isGbk) {
      op.responseDecoder = (List<int> responseBytes, RequestOptions options,
          ResponseBody responseBody) {
        var body = gbk.decode(responseBytes);
        // var body = utf8decoder.convert(responseBytes);
        return body;
      };
    }
    Map<String, String> headerMap = isWeb == null || isWeb
        ? {
            "User-Agent":
                "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/68.0.3440.84 Safari/537.36",
            "Accept-Language": "zh-CN,zh;q=0.8,zh-TW;q=0.7,zh-HK;q=0.5",
            "Proxy-Connection": "keep-alive",
            "Cache-Control": "max-age=0",
            "Referer": referer == null || referer.isEmpty ? uri : referer,
          }
        : {
            "User-Agent":
                "Mozilla/5.0 (Linux; U; Android 2.3.6; zh-cn; GT-S5660 Build/GINGERBREAD) AppleWebKit/533.1 (KHTML, like Gecko) Version/4.0 Mobile Safari/533.1 MicroMessenger/4.5.255",
            "Accept-Language": "zh-CN,zh;q=0.8,zh-TW;q=0.7,zh-HK;q=0.5",
            "Proxy-Connection": "keep-alive",
            "Cache-Control": "max-age=0",
          };
    if (header != null) {
      headerMap.addAll(header.map((key,value){
        return MapEntry(key,value);
      }));
    }
    op.method = method;
    op.headers = headerMap;
    print('请求url>>$uri');

    return http.get(Uri(path: uri), headers: headerMap).then((value) {
      Utf8Decoder utf8decoder = new Utf8Decoder();
      return utf8decoder.convert(value.bodyBytes);
    }).catchError((onError) {
      return "error";
    });
  }

  //获取网页内容
  static Future<Response<String>> httpHtmlCookies(String cookieUrl, String uri,
      {Map<String, dynamic>? data,
      Map<String, dynamic>? header,
      bool dataIsJson = true,
      bool isWeb = true}) async {
//    setProxy();
    if (debug) {
      print('<net url>------$uri');
      print('<net params>------$data');
    }

    /// 根据当前 请求的类型来设置 如果是请求体形式则使用json格式
    /// 否则则是表单形式的（拼接在url上）
    Options op;
    op = new Options(contentType: "application/x-www-form-urlencoded");
    Map<String, dynamic> headerMap = isWeb == null || isWeb
        ? {
            "User-Agent":
                "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/68.0.3440.84 Safari/537.36",
            "Cache-Control": "max-age=0",
          }
        : {};
    if (header != null) {
      headerMap.addAll(header);
    }
    op.method = 'get';
    op.headers = headerMap;
    var cookieJar = CookieJar();
//    _dio.interceptors.add(CookieManager(cookieJar));
    var cookies = cookieJar.loadForRequest(Uri.parse(cookieUrl));
    cookieJar.loadForRequest(Uri.parse(uri));
    await _dio.get<String>(cookieUrl, options: op);

    /// 根据当前 请求的类型来设置 如果是请求体形式则使用json格式
    /// 否则则是表单形式的（拼接在url上）
    Options postOp;
    postOp = new Options(contentType: "application/x-www-form-urlencoded");
    postOp.method = 'post';
    postOp.headers = headerMap;
    print('请求url>>$uri | ${cookies.toString()}');
    return _dio.request<String>(uri, data: data, options: postOp);
  }

  //获取网页内容
  static Future<String> _httpHtmlDataPost(
      String method, String uri, String? referer,
      {Map<String, dynamic>? data,
      Map<String, dynamic>? header,
      bool? dataIsJson = true,
      bool? isWeb = true,
      bool? isGbk = false}) {
    /// 如果为 get方法，则进行参数拼接
    if (method == "get") {
      dataIsJson = false;
      if (data == null) {
        data = new Map<String, dynamic>();
      }
      if (data.length > 0) {
        uri = '$uri?';
      }
      data.forEach((key, value) {
        uri = '$uri$key=$value&';
      });
      if (uri.endsWith('&')) {
        uri = uri.substring(0, uri.length - 1);
      }
    }

    if (debug) {
      print('<net url>------$uri');
      print('<net params>------$data');
    }

    /// 根据当前 请求的类型来设置 如果是请求体形式则使用json格式
    /// 否则则是表单形式的（拼接在url上）
    Options op;

    op = new Options(contentType: "application/x-www-form-urlencoded");
    // op.responseDecoder = (
    //     List<int> responseBytes, RequestOptions options, ResponseBody responseBody){
    //   var body = gbk.decode(responseBytes);
    //   // var body = utf8decoder.convert(responseBytes);
    //   return body;
    // };
    if (isGbk != null && isGbk) {
      op.responseDecoder = (List<int> responseBytes, RequestOptions options,
          ResponseBody responseBody) {
        var body = gbk.decode(responseBytes);
        // var body = utf8decoder.convert(responseBytes);
        return body;
      };
    }
    op.method = method;
    op.headers = header ??= {
      'Content-Type': 'application/x-www-form-urlencoded',
      'Accept-Encoding': 'gzip, deflate, br',
      'Connection': 'keep-alive',
      'user-agent':
          'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_14_4) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/77.0.3865.75 Safari/537.36',
      'sec-fetch-mode': 'navigate',
    };
    print('请求url>>$uri');
    return _dio.request<String>(uri, data: data, options: op).then((value) {
      print('返回结果:${value.data}');
      return Future.value(value.data);
    });
  }

  /// 对请求返回的数据进行统一的处理
  /// 如果成功则将我们需要的数据返回出去，否则进异常处理方法，返回异常信息
  static Future<String> htmlErrorTransform<T>(Response<String> resp) {
    return Future.value(resp.data);
  }

  /// 对请求返回的数据进行统一的处理
  /// 如果成功则将我们需要的数据返回出去，否则进异常处理方法，返回异常信息
  static Future<T> logicalErrorTransform<T>(
      Response<Map<String, dynamic>> resp) {
    if (resp.data != null) {
      if (resp.data?["code"] == 0) {
        T realData = resp.data?["data"];
        return Future.value(realData);
      }
    }

    if (debug) {
      print('resp--------$resp');
      print('resp.data--------${resp.data}');
    }

    LogicError error;
    if (resp.data != null && resp.data?["code"] != 0) {
      if (resp.data?['data'] != null) {
        /// 失败时  错误提示在 data中时
        /// 收到token过期时  直接进入登录页面
        Map<String, dynamic> realData = resp.data?["data"];
        error = new LogicError(resp.data?["code"], realData['codeMessage']);
      } else {
        /// 失败时  错误提示在 message中时
        error = new LogicError(resp.data?["code"], resp.data?["message"]);
      }
    } else {
      error = unknowError;
    }
    return Future.error(error);
  }

  ///获取授权token
  static getToken() async {
//    String token = await LocalStorage.get(LocalStorage.TOKEN_KEY);
    return token;
  }
}

/// 统一异常类
class LogicError {
  int? errorCode;
  String? msg;

  LogicError(errorCode, msg) {
    this.errorCode = errorCode;
    this.msg = msg;
  }
}
