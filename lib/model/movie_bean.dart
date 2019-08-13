

class MovieBean{
  String name;
  String imgUrl;
  String playUrl;
  String info;
  String des;
  List<MovieItemBean> list;

  @override
  String toString() {
    return 'MovieBean{name: $name, imgUrl: $imgUrl, playUrl: $playUrl, info: $info, des: $des, list: $list}';
  }


}

class MovieItemBean{
  String name;
  String targetUrl;

  @override
  String toString() {
    return 'MovieItemBean{name: $name, targetUrl: $targetUrl}';
  }

}