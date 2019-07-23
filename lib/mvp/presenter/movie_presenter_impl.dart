

import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_parse_html/api/api_constant.dart';
import 'package:flutter_parse_html/model/video_list_item.dart';
import 'package:flutter_parse_html/util/escapeu_unescape.dart';
import 'package:flutter_parse_html/util/log_utils.dart';
import 'package:dio/dio.dart';
import 'dart:convert' as convert;
import 'package:html/parser.dart' as parse;
import 'movie_presenter.dart';

 class MoviePresenterImpl implements MoviePresenter{

   MovieView _view;
   var _dio;


   MoviePresenterImpl(this._view){
     _view.setPresenter(this);
   }

   @override
  init() {
     _dio = new Dio();
   }

  @override
  loadMovieList(String url, int pageNum,bool isRefresh) async {
    var videoUrl = "${url}${pageNum}.html";
    try {
      var response = await _dio.get(videoUrl);
      if (response.statusCode == HttpStatus.ok) {
        var body = response.data;
        var document = parse.parse(body);
        var elements = document.getElementsByClassName("stui-vodlist__item");
        List<VideoListItem> list = [];
        for (var value in elements) {
          VideoListItem videoListItem = new VideoListItem();
          var imgElement = value
              .getElementsByClassName("stui-vodlist__thumb lazyload")
              .first;
          videoListItem.imageUrl =
          imgElement.attributes["data-original"]; //图片地址
          videoListItem.title = value
              .getElementsByClassName("stui-vodlist__title")
              .first
              .getElementsByTagName("a")
              .first
              .text; //标题
          videoListItem.targetUrl =
          '${ApiConstant.movieBaseUrl}${imgElement.attributes['href'].trim()}'; //跳转地址
          list.add(videoListItem);
        }
        _view.loadMovieListSuc(list,isRefresh);
        LogUtils.d("http", "返回${list}");
      }
    } catch (e) {
      _view.loadMovieListFail();
      print(e);
    }
  }

  @override
   void getVideoUrl(String url) async {
     var response = await _dio.get(url);
     String body = response.data;
     var document = parse.parse(body);
     var element = document.getElementsByClassName("btn btn-primary").first;
     if(element != null){
       String pageUrl = '${ApiConstant.movieBaseUrl}${element.attributes['href']}';
       var response = await _dio.get(pageUrl);
       String pageBody = response.data;
       var pageDocument = parse.parse(pageBody);
       String playData = pageDocument.getElementsByClassName('pl-l').first
           .getElementsByTagName('script').first.text;
       String data = playData.split('var player_data=')[1];
       LogUtils.d("json", "播放数据>>>${data}");
       var map = convert.json.decode(data);
       int encrypt = map['encrypt'];
       String playUrl = map['url'];
       if(playUrl.isNotEmpty){
         if(encrypt == 1){
           playUrl = EscapeUnescape.unescape(playUrl);
         }else{
           playUrl = EscapeUnescape.unescape(String.fromCharCodes(new Runes(convert.utf8.decode(convert.base64.decode(playUrl)))));
         }
         LogUtils.d("json", "播放地址>>>${playUrl}");
         _view.getVideoUrlSuc(playUrl);
       }
     }
   }

}
