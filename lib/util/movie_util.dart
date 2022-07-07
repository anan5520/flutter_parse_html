import 'package:flutter_parse_html/api/api_constant.dart';
import 'package:flutter_parse_html/model/movie_bean.dart';
import 'package:flutter_parse_html/net/net_util.dart';
import 'package:flutter_parse_html/util/escapeu_unescape.dart';
import 'package:flutter_parse_html/util/log_utils.dart';
import 'package:path/path.dart';
import 'package:html/parser.dart' as parse;
import 'dart:convert' as convert;

class MovieUtil {
  static Future<MovieBean> getVideoInfo(String url, {String number}) {
    return NetUtil.getHtmlData(url).then((response) async {
      MovieBean movieBean = MovieBean();
      String body = response;
      var document = parse.parse(body);
      try {
        var element = document.getElementsByClassName("myui-content__list sort-list clearfix").first;
        var infoElement =
                  document.getElementsByClassName("myui-content__detail").first;
        movieBean.name = infoElement.getElementsByClassName('title text-fff').first.text;
        movieBean.info = '${movieBean.name}';
        for (var value in infoElement.getElementsByClassName('data')) {
                movieBean.info = '${movieBean.info}\n${value.text}';
              }
        movieBean.des =
                  '剧情介绍\n${document.getElementsByClassName('desc text-collapse hidden-xs').first.text}';
        movieBean.imgUrl = document
                  .getElementsByClassName('myui-content__thumb')
                  .first.getElementsByTagName('img').first
                  .attributes['data-original'];
        if (element != null) {
                String id = '';
                var eleIds = document.getElementsByClassName('nav nav-tabs active').first.getElementsByTagName('li');
                eleIds.forEach((element) {
                  if(element.text.contains('m3u8')){
                    id = element.getElementsByTagName('a').first.attributes['href'].replaceAll('#', '');
                  }
                });
                if(id.isEmpty && eleIds.length > 0){
                  id = eleIds[0].getElementsByTagName('a').first.attributes['href'].replaceAll('#', '');
                }
                var itemElements = document.getElementById(id)
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
                if (list.length > 0) movieBean.number = list[0].name;
                return movieBean;
              }
      } catch (e) {
        print(e);
      }
      return movieBean;
    });
  }

  static Future<MovieBean> getOkVideoInfo(String url) {
    return NetUtil.getHtmlData(url).then((response) async {
      MovieBean movieBean = MovieBean();
      String body = response;
      var document = parse.parse(body);
      var imgEle = document.getElementsByClassName('img-thumbnail').first;
      movieBean.imgUrl = imgEle.attributes['src'];
      movieBean.name = imgEle.attributes['alt'];
      movieBean.info = document.getElementsByClassName('col-md-9 col-xs-7').first.text;
      movieBean.des = document.getElementsByClassName('detail').first.text;
      var playEle = document.getElementsByClassName('play-list');
      List<MovieItemBean> list = [];
      for (var value in playEle) {
          var inputs = value.getElementsByTagName('li');
          if(inputs.length > 0){
            for (var li in inputs) {
              var input = li.getElementsByTagName('a').first;
              var value = input.attributes['href'];
              MovieItemBean movieItemBean = new MovieItemBean();
              movieItemBean.name = input.text;
              movieItemBean.targetUrl = "${ApiConstant.movieBaseUrl1}$value";
              list.add(movieItemBean);
            }
          }
      }
      movieBean.originUrl = url;
      movieBean.list = list;
      return movieBean;
    });
  }

  static Future<MovieBean> getMaHuaVideoInfo(String url) {
    return NetUtil.getHtmlData(url).then((response) async {
      MaHuaMovieDetail maHuaMovieDetail = MaHuaMovieDetail.fromJson(convert.json.decode(response));
      MovieBean movieBean = MovieBean();
      maHuaMovieDetail.list.forEach((element) {
        movieBean.imgUrl = element.vodPic;
        movieBean.name = element.vodName;
        movieBean.info = '${element.vodTime}\n${element.vodActor}\n${element.vodArea}';
        movieBean.des = element.vodContent;
        var urls = element.vodPlayUrl.split("#");
        List<MovieItemBean> list = [];
        urls.forEach((element) {
          MovieItemBean movieItemBean = new MovieItemBean();
          var urls = element.split("\$");
          movieItemBean.name = urls[0];
          movieItemBean.targetUrl = urls[1];
          list.add(movieItemBean);
        });
        movieBean..list = list;
      });
      return movieBean;
    });
  }

  static Future<String> getVideoUrl(String pageUrl, {String number}) {
    return NetUtil.getHtmlData(pageUrl).then((pageBody) async {
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

        if (number != null && number != "") {
          print('需要播放$number');
          String resultUrl;
          for (var value in list) {
            if (number == value.targetUrl) {
              resultUrl = '${ApiConstant.movieBaseUrl}${value.targetUrl}';
            }
          }
          if (resultUrl != null) {
            String response = await NetUtil.getHtmlData(resultUrl);
            var pageDocument = parse.parse(response);
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
                    new Runes(
                        convert.utf8.decode(convert.base64.decode(playUrl)))));
              }
            }
          }
        }
        return playUrl;
      }
      return "";
    });
  }

  static Future<MovieBean> getMovieBean(String pageUrl,String name, {String number}) {
    return NetUtil.getHtmlData(pageUrl).then((pageBody) async {
      MovieBean movieBean = MovieBean();
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

        if (number != null && number != "") {
          print('需要播放$number');
          String resultUrl;
          for (var value in list) {
            if (number == value.name) {
              resultUrl = value.targetUrl;
            }
          }
          if (resultUrl != null) {
            String response = await NetUtil.getHtmlData(resultUrl);
            var pageDocument = parse.parse(response);
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
            playUrl = map['url'];
            if (playUrl.isNotEmpty) {
              if (encrypt == 1) {
                playUrl = EscapeUnescape.unescape(playUrl);
              } else {
                playUrl = EscapeUnescape.unescape(String.fromCharCodes(
                    new Runes(
                        convert.utf8.decode(convert.base64.decode(playUrl)))));
              }
            }
          }
        }
        movieBean.playUrl = playUrl;
        movieBean.name = name;
        movieBean.list = list;
        movieBean.number = number;
        return movieBean;
      }
      return movieBean;
    });
  }
}
