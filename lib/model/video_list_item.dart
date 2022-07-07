

class VideoListItem {
  String title;
  String imageUrl;
  String targetUrl;
  String vid;
  String des;
  String author;
  bool show = true;

  VideoListItem();

  @override
  String toString() {
    return 'VideoListItem{title: $title, imageUrl: $imageUrl, targetUrl: $targetUrl, vid: $vid, des: $des, show: $show}';
  }


}





