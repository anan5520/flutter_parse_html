import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_parse_html/api/api_constant.dart';
import 'package:flutter_parse_html/model/video_list_item.dart';
import 'package:flutter_parse_html/ui/movie/movie_page.dart';
import 'package:flutter_parse_html/util/escapeu_unescape.dart';
import 'package:flutter_parse_html/util/log_utils.dart';
import 'package:dio/dio.dart';
import 'dart:convert' as convert;
import 'package:html/parser.dart' as parse;
import 'movie_presenter.dart';
import 'package:flutter_parse_html/model/movie_bean.dart';
import 'package:flutter_parse_html/model/button_bean.dart';
class MoviePresenterImpl implements MoviePresenter {
  MovieView _view;
  var _dio;

  MoviePresenterImpl(this._view) {
    _view.setPresenter(this);
  }

  @override
  init() {
    _dio = new Dio();
  }

  @override
  loadMovieList(String url, int pageNum,MovieType type, bool isRefresh) async {
    var videoUrl = "${url}page/${pageNum}.html";
    List<ButtonBean> btns = [];
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
          videoListItem.des = value.getElementsByClassName('pic-text text-right').first.text;
          list.add(videoListItem);
        }
        int index = type == MovieType.comic?1:0;
        var btnElements = document.getElementsByClassName('stui-screen__list type-slide clearfix')[index].getElementsByTagName('li');
        for (var value1 in btnElements) {
          var elements = value1.getElementsByTagName('a');
          if(elements != null && elements.length > 0){
            var element = elements[0];
            String title = element.text;
            String href = element.attributes['href'];
            if(href != null && href.isNotEmpty){
              ButtonBean bean = ButtonBean();
              bean.title = title;
              bean.value = href;
              btns.add(bean);
            }
          }
        }
        _view.loadMovieListSuc(list,btns, isRefresh);
        LogUtils.d("http", "返回${list}");
      }
    } catch (e) {
      _view.loadMovieListFail();
      print(e);
    }
  }

  @override
  void getVideoUrl(String url) async {
    MovieBean movieBean = MovieBean();
    var response = await _dio.get(url);
    String body = response.data;
    var document = parse.parse(body);
    var element = document.getElementsByClassName("btn btn-primary").first;
    var infoElement =
        document.getElementsByClassName("stui-content__detail fl-l").first;
    movieBean.name = infoElement.getElementsByClassName('title').first.text;
    movieBean.info = '${movieBean.name}';
    for (var value in infoElement.getElementsByClassName('data')) {
      movieBean.info = '${movieBean.info}\n${value.text}';
    }
    movieBean.des =
        '剧情介绍\n${document.getElementsByClassName('stui-content__desc col-pd clearfix').first.text}';
    movieBean.imgUrl = document
        .getElementsByClassName('img-responsive lazyload')
        .first
        .attributes['data-original'];
    if (element != null) {
      String pageUrl =
          '${ApiConstant.movieBaseUrl}${element.attributes['href']}';
      var response = await _dio.get(pageUrl);
      String pageBody = response.data;
      var pageDocument = parse.parse(pageBody);
      String playData = pageDocument
          .getElementsByClassName('pl-l')
          .first
          .getElementsByTagName('script')
          .first
          .text;
      String data = playData.split('var player_data=')[1];
      LogUtils.d("json", "播放数据>>>${data}");
      var map = convert.json.decode(data);
      int encrypt = map['encrypt'];
      String playUrl = map['url'];
      if (playUrl.isNotEmpty) {
        if (encrypt == 1) {
          playUrl = EscapeUnescape.unescape(playUrl);
        } else {
          playUrl = EscapeUnescape.unescape(String.fromCharCodes(
              new Runes(convert.utf8.decode(convert.base64.decode(playUrl)))));
        }
        var itemElements = pageDocument
            .getElementsByClassName('stui-content__playlist clearfix')
            .first
            .getElementsByTagName('li');
        List<MovieItemBean> list = List();
        for (var value in itemElements) {
          MovieItemBean movieItemBean = MovieItemBean();
          movieItemBean.name = value.getElementsByTagName('a').first.text;
          movieItemBean.targetUrl = ApiConstant.movieBaseUrl +
              value.getElementsByTagName('a').first.attributes['href'];
          list.add(movieItemBean);
        }
        movieBean.list = list;
        movieBean.playUrl = playUrl;
        LogUtils.d("json", "播放地址>>>${playUrl}");
        _view.getVideoUrlSuc(movieBean);
      }
    }
  }
}
