


import 'package:flutter_parse_html/model/button_bean.dart';
import 'package:flutter_parse_html/model/video_list_item.dart';
import 'package:flutter_parse_html/ui/movie/movie_page.dart';

import '../mvp.dart';
import 'package:flutter_parse_html/model/movie_bean.dart';
abstract class MoviePresenter implements IPresenter{
  loadMovieList(String url,int pageNum,MovieType type,bool isRefresh,int baseType);

  getVideoUrl(String targetUrl,int type);
}

abstract class MovieView implements IView<MoviePresenter>{

  loadMovieListSuc(List<VideoListItem> list,List<ButtonBean> btns,bool isRefresh,{List<VideoListItem> bannerList});

  getVideoUrlSuc(MovieBean movieBean);

  loadMovieListFail();

}