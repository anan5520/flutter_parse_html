import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_parse_html/api/api_constant.dart';
import 'package:flutter_parse_html/model/video_list_item.dart';
import 'package:flutter_parse_html/net/net_util.dart';
import 'package:flutter_parse_html/ui/movie/movie_page.dart';
import 'package:flutter_parse_html/util/common_util.dart';
import 'package:flutter_parse_html/util/escapeu_unescape.dart';
import 'package:flutter_parse_html/util/files.dart';
import 'package:flutter_parse_html/util/log_utils.dart';
import 'package:dio/dio.dart';
import 'package:flutter_parse_html/util/movie_util.dart';
import 'package:html/dom.dart' as html;
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
  loadMovieList(String url, int pageNum, MovieType type, bool isRefresh,
      int baseType,{isType = false}) async {
    if (baseType == 1) {
      _load4kMovie(url, pageNum, type, isRefresh);
    } else {
      _loadOkMovie(url, pageNum, type, isRefresh,isType);
    }
  }

  @override
  void getVideoUrl(String url, int type) async {
    if (type == 1) {
      _view.getVideoUrlSuc(await MovieUtil.getVideoInfo(url));
    } else {
      _view.getVideoUrlSuc(await MovieUtil.getOkVideoInfo(url));
    }
  }

  void _load4kMovie(
      String url, int pageNum, MovieType type, bool isRefresh) async {
    if (url.endsWith('.html')) {
      url = url.replaceAll('.html', '');
    }
    var videoUrl = '';
    if(url.contains('---')){
      if(pageNum > 1){
        url = url.replaceAll('-----', '');
      }
      videoUrl = pageNum == 1?"$url.html":"$url-$pageNum---.html";
    }else{
      videoUrl = "$url-$pageNum.html";
    }
    List<ButtonBean> btns = [];
    var body = await NetUtil.getHtmlData(videoUrl);
    print('返回结果=$body');
    try {
      var document = parse.parse(body);
      var videoRootEles = document
          .getElementsByClassName("myui-vodlist clearfix");
      var elements = [];
      videoRootEles.forEach((element) {
        if(element.getElementsByClassName('col-lg-7 col-md-6 col-sm-4 col-xs-3').isNotEmpty){
          elements =element.getElementsByClassName("col-lg-7 col-md-6 col-sm-4 col-xs-3");
        }
        if(element.getElementsByClassName('col-md-6 col-sm-4 col-xs-3').isNotEmpty){
          elements =element.getElementsByClassName("col-md-6 col-sm-4 col-xs-3");
        }
      });
      List<VideoListItem> list = [];
      List<VideoListItem> bannerList = [];
      var bannerEle = document
          .getElementsByClassName("myui-panel active clearfix")
          .first
          .getElementsByClassName("myui-vodlist__box");
      initBanner(bannerList,bannerEle);
      for (var value in elements) {
        VideoListItem videoListItem = new VideoListItem();
        var imgElement =
            value.getElementsByClassName("myui-vodlist__thumb").first;
        videoListItem.imageUrl = imgElement.attributes["data-original"]; //图片地址
        videoListItem.imageUrl = videoListItem.imageUrl.startsWith("http")?videoListItem.imageUrl:
            '${ApiConstant.movieBaseUrl}${videoListItem.imageUrl}';
        // var imgs = videoListItem.imageUrl.split(new RegExp(r'\)|\('));
        // videoListItem.imageUrl = imgs[1];
        videoListItem.title = CommonUtil.replaceStr(value
            .getElementsByClassName("title text-overflow")
            .first
            .getElementsByTagName("a")
            .first
            .text); //标题
        videoListItem.targetUrl =
            '${ApiConstant.movieBaseUrl}${imgElement.attributes['href'].trim()}'; //跳转地址
        videoListItem.des = CommonUtil.replaceStr(value
            .getElementsByClassName('text text-overflow text-muted hidden-xs')
            .first
            .text);
        list.add(videoListItem);
      }
      int index = type == MovieType.comic ? 1 : 0;
      var btnElements = document
          .getElementsByClassName('myui-screen__list nav-slide clearfix')[index]
          .getElementsByTagName('li');
      for (var value1 in btnElements) {
        var elements = value1.getElementsByTagName('a');
        if (elements != null && elements.length > 0) {
          var element = elements[0];
          String title = element.text;
          String href = element.attributes['href'];
          if (href != null && href.isNotEmpty) {
            ButtonBean bean = ButtonBean();
            bean.title = title;
            bean.value = href;
            btns.add(bean);
          }
        }
      }
      _view.loadMovieListSuc(list, btns, isRefresh,bannerList: bannerList);
      LogUtils.d("http", "返回${list}");
    } catch (e) {
      _view.loadMovieListFail();
      print(e);
    }
  }

  void _loadOkMovie(
      String url, int pageNum, MovieType type, bool isRefresh,bool isType) async {
    var videoUrl = "${url}${isType ?"-----${pageNum}---.html":'${pageNum}.html'}";
    print('加载$videoUrl');
    try {
      var response = await _dio.get(videoUrl);
      if (response.statusCode == HttpStatus.ok) {
        var body = response.data;
        var document = parse.parse(body);
        List<ButtonBean> btns = [];
        List<VideoListItem> list = [];
        var btnsEle = document.getElementsByClassName('panel-body query-box').first.getElementsByClassName('clearfix');
        for (var value in btnsEle) {
          if(value.text.contains('按类型')){
            value.getElementsByTagName('span').forEach((element) {
              var aEle = element.getElementsByTagName('a').first;
              ButtonBean buttonBean = new ButtonBean();
              buttonBean.value = aEle.attributes['href'];
              buttonBean.title = aEle.text;
              btns.add(buttonBean);
            });

          }

        }
        var items = document
            .getElementsByClassName('cards video-list')
            .first
            .getElementsByClassName('col-md-2 col-xs-4');
        for (var value1 in items) {
          var aEle = value1.getElementsByTagName('a');
          if (aEle.length > 0) {
            var target = aEle.first.attributes['href'];
            var imgEle = aEle.first.getElementsByTagName('img')?.first;
            if (target != null && imgEle != null) {
              VideoListItem listItem = new VideoListItem();
              listItem.targetUrl =
                  ApiConstant.movieBaseUrl1 + target;
              listItem.title = imgEle.attributes['alt'];
              listItem.imageUrl = imgEle.attributes['data-original'];
              var v5 = value1.getElementsByClassName('card-content text-ellipsis text-muted');
              if (v5.length > 0) {
                listItem.des = "${v5.first.text}";
              } else {
                listItem.des = "";
              }
              list.add(listItem);
            }
          }
        }
        _view.loadMovieListSuc(list, btns, isRefresh);
        LogUtils.d("http", "返回${list}");
      }
    } catch (e) {
      _view.loadMovieListFail();
      print(e);
    }
  }

  void _loadMaHuaMovie(
      String url, int pageNum, MovieType type, bool isRefresh) async {
    var videoUrl = '$url&pg=$pageNum';
    try {
      var response = await _dio.get(videoUrl);
      if (response.statusCode == HttpStatus.ok) {
        var body = response.data;
        MaHuaMovieList maHuaMovieList =
            MaHuaMovieList.fromJson(convert.json.decode(body));
        List<ButtonBean> btns = [];
        List<VideoListItem> list = [];
        var noHas = ['电影', '连续剧', '综艺', '动漫', '倫理', '短视频'];
        maHuaMovieList.type
            .where((element) => !noHas.contains(element.typeName))
            .forEach((value) {
          ButtonBean buttonBean = new ButtonBean();
          buttonBean.value = value.typeId;
          buttonBean.title = value.typeName;
          btns.add(buttonBean);
        });
        for (var value1 in maHuaMovieList.list) {
          VideoListItem listItem = new VideoListItem();
          listItem.targetUrl =
              '${ApiConstant.movieBaseUrl2}?ac=detail&ids=${value1.vodId}';
          listItem.des = value1.vodTime;
          listItem.title = value1.vodName;
          list.add(listItem);
        }
        _view.loadMovieListSuc(list, btns, isRefresh);
        LogUtils.d("http", "返回${list}");
      }
    } catch (e) {
      _view.loadMovieListFail();
      print(e);
    }
  }
}

void initBanner(List<VideoListItem> bannerList, List<html.Element> bannerEle) {
  for (var value in bannerEle) {
    VideoListItem videoListItem = new VideoListItem();
    var imgEle = value.getElementsByTagName('a').first;
    videoListItem.imageUrl = imgEle.attributes["data-original"]; //图片地址
    videoListItem.title = imgEle.attributes['title'];
    videoListItem.targetUrl = '${ApiConstant.movieBaseUrl}${imgEle.attributes['href']}';
    bannerList.add(videoListItem);
  }
}
