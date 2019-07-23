


import 'package:flutter_parse_html/model/video_list_item.dart';

import '../mvp.dart';

abstract class MoviePresenter implements IPresenter{
  loadMovieList(String url,int pageNum,bool isRefresh);

  getVideoUrl(String targetUrl);
}

abstract class MovieView implements IView<MoviePresenter>{

  loadMovieListSuc(List<VideoListItem> list,bool isRefresh);

  getVideoUrlSuc(String url);

  loadMovieListFail();

}