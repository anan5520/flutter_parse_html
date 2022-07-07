import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_parse_html/api/api_constant.dart';
import 'package:flutter_parse_html/model/movie_bean.dart';
import 'package:flutter_parse_html/model/video_list_item.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_parse_html/net/net_util.dart';
import 'package:flutter_parse_html/ui/movie/movie_detail_page.dart';
import 'package:flutter_parse_html/ui/video_play.dart';
import 'package:flutter_parse_html/util/log_utils.dart';
import 'package:flutter_parse_html/util/movie_util.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:dio/dio.dart';
import 'dart:convert' as convert;
import 'package:html/parser.dart' as parse;
import 'package:flutter_parse_html/util/escapeu_unescape.dart';

//电影搜索页面
class SearchBar extends SearchDelegate<String> {
  int type = 1;


  SearchBar(this.type); // 点击清楚的方法
  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        // 点击把文本空的内容清空
        onPressed: () {
          query = "";
        },
      )
    ];
  }

  // 点击箭头返回
  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: AnimatedIcon(
        // 使用动画效果返回
        icon: AnimatedIcons.menu_arrow, progress: transitionAnimation,
      ),
      // 点击的时候关闭页面（上下文）
      onPressed: () {
        close(context, null);
      },
    );
  }

  // 点击搜索出现结果
  @override
  Widget buildResults(BuildContext context) {
    return SearchResultPage(query, type);
  }

  // 搜索下拉框提示的方法
  @override
  Widget buildSuggestions(BuildContext context) {
    return new Center();
  }
}

class SearchResultPage extends StatefulWidget {
  final String _query;
  int type = 1;


  SearchResultPage(this._query, this.type);

  @override
  State<StatefulWidget> createState() {
    return SearchState(_query);
  }
}

class SearchState extends State<SearchResultPage>
    with AutomaticKeepAliveClientMixin {
  final String _query;

  SearchState(this._query);

  List<VideoListItem> _data = new List();

  Dio _dio;

  @override
  void initState() {
    super.initState();
    _dio = new Dio();
    getData(_query);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    Widget content;
    if (_data.length > 0) {
      content = ListView.separated(
        separatorBuilder: (context, index) {
          return Divider(
            color: Colors.grey,
          );
        },
        itemBuilder: getItem,
        itemCount: _data.length,
      );
    } else {
      content = SpinKitWave(
        color: Colors.blue,
        size: 50,
      );
    }

    return content;
  }

  Widget getItem(BuildContext context, int index) {
    VideoListItem videoListItem = _data[index];
    Widget content = videoListItem.imageUrl == null
        ? new Container()
        : CachedNetworkImage(
      imageUrl: videoListItem.imageUrl,
      fit: BoxFit.cover,
      height: 80,
      width: 60,
    );
    return new Padding(
      padding: EdgeInsets.all(10),
      child: GestureDetector(
        onTap: () {
          showLoading();
          getVideoUrl(videoListItem.targetUrl);
        },
        child: new Row(
          children: <Widget>[
            content,
            new Padding(
              padding: EdgeInsets.only(left: 10),
              child: Text(videoListItem.title),
            )
          ],
        ),
      ),
    );
  }

  void getData(String query) async {
    var videoUrl = widget.type == 1 ? '${ApiConstant.movieBaseUrl}'
        '/search.php?page=1&searchword=${Uri.encodeComponent(_query)}' : "${ApiConstant
        .movieSearchUrl1}${Uri.encodeComponent(_query)}----------1---.html";
    try {
      Map<String, String> param = {'submit': '', 'wd': query};
      var body = widget.type == 1?await NetUtil.getHtmlData(videoUrl)
          : await NetUtil.getHtmlData(videoUrl);
      var document = parse.parse(body);
      List<VideoListItem> list = [];
      if (widget.type == 1) {
        var elements = document.getElementById('searchList').getElementsByTagName("li");
        for (var value in elements) {
          VideoListItem videoListItem = new VideoListItem();
          var imgElement = value
              .getElementsByClassName('myui-vodlist__thumb img-lg-150 img-xs-100 lazyload').first;
          videoListItem.imageUrl =
          imgElement.attributes["data-original"]; //图片地址
          videoListItem.title = value
              .getElementsByClassName("title")
              .first
              .text; //标题
          videoListItem.targetUrl =
          '${ApiConstant.movieBaseUrl}${imgElement.attributes['href']
              .trim()}'; //跳转地址
          list.add(videoListItem);
        }
      } else {

        var items = document
            .getElementsByClassName('cards video-list')
            .first
            .getElementsByClassName('col-md-2 col-xs-4');
        for (var value1 in items) {
          var aEle = value1.getElementsByTagName('a');
          if (aEle.length > 0) {
            var target = aEle.first.attributes['href'];
            var imgEle = value1.getElementsByTagName('img').first;
            if (target != null) {
              VideoListItem listItem = new VideoListItem();
              listItem.targetUrl =
                  ApiConstant.movieBaseUrl1 + target;
              listItem.title = imgEle.attributes['alt'];
              listItem.imageUrl = 'https${imgEle.attributes['data-original'].split('https').last}';
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
        // MaHuaMovieList maHuaMovieList = MaHuaMovieList.fromJson(convert.json.decode(body));
        // for (var value1 in maHuaMovieList.list) {
        //   VideoListItem listItem = new VideoListItem();
        //   listItem.targetUrl = '${ApiConstant.movieBaseUrl2}?ac=detail&ids=${value1.vodId}';
        //   listItem.title = value1.vodName;
        //   listItem.des = value1.vodTime;
        //   list.add(listItem);
        // }
      }
      LogUtils.d("http", "返回${list}");
      _data.addAll(list);
      setState(() {});
    } catch (e) {
      print(e);
    }
  }

  void getVideoUrl(String url) async {
    MovieBean movieBean = MovieBean();
    if(widget.type == 1){
      var response = await _dio.get(url);
      String body = response.data;
      var document = parse.parse(body);
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
        String id = 'playlist2';
        var eleIds = document.getElementsByClassName('nav nav-tabs active').first.getElementsByTagName('li');
        eleIds.forEach((element) {
          if(element.text.contains('m3u8')){
            id = element.getElementsByTagName('a').first.attributes['href'].replaceAll('#', '');
          }
        });
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
      }
    }else{
      movieBean = await MovieUtil.getOkVideoInfo(url);
    }
    Navigator.pop(context);
    Navigator.of(context)
        .push(new MaterialPageRoute(builder: (BuildContext context) {
      return MovieDetailPage(widget.type == 2?9:1, movieBean);
    }));
  }


  void showLoading() {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return SpinKitWave(
            color: Colors.blue,
          );
        });
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;

}
