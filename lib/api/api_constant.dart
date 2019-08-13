class ApiConstant {
  static final String noticeUrl =
      'https://raw.githubusercontent.com/anan5520/flutter_parse_html/1.0/api/notice.json';
  static final String updateUrl =
      'https://raw.githubusercontent.com/anan5520/flutter_parse_html/1.0/api/update.json';
  static final String urlsUrl =
      'https://raw.githubusercontent.com/anan5520/flutter_parse_html/1.0/api/urls.json';

  static String movieBaseUrl = 'http://4kbo.com';
  static String movieSearchUrl = '$movieBaseUrl/index.php/vod/search.html';
  static String liveUrl = 'http://api.hclyz.com:81/mf/json.txt';

  static String girlBaseUrl = 'http://www.mzitu.com/';

  static String fanHao1 = 'http://www.fanhaow.com/';
  static String fanHao2 = 'http://www.acg3.cc/whole/';
  static String fanHao3 = 'https://www.66hoho.com/';

  static String pornBaseUrl = 'http://625.itpromco.com/';
  static String pornForumBaseUrl = 'https://f.wonderfulday30.live/';

  static String searchUrl = 'https://zhima998.com/infolist.php?q=';
  static String searchNiMaUrl = 'http://www.nms000.com/l/';

  static String siSeUrl = 'https://www.2019be.com';

  static String xianFengUrl = 'http://www.uuzy6.com';

  static String videoList1Url = 'http://www.suduzy.com:777';

  static String getPornHomeUrl() {
    return '${pornBaseUrl}index.php';
  }

  static String getPornVideoUrl() {
    return '${pornBaseUrl}video.php';
  }

  static String getPornParseVideoUrl() {
    return '${pornBaseUrl}view_video.php';
  }

  static String getPornCommentUrl() {
    return '${pornBaseUrl}show_comments2.php';
  }

  static String getPornForumHomeUrl() {
    return '${pornForumBaseUrl}index.php';
  }

  static String getPornForumUrl() {
    return '${pornForumBaseUrl}forumdisplay.php';
  }

  static String getPornForumContentUrl() {
    return '${pornForumBaseUrl}viewthread.php';
  }

  static String getGirlListUrl(String tag, int page) {
    return page == 1 ? '$girlBaseUrl$tag' : '$girlBaseUrl$tag/page/$page';
  }

  static String getGirlDetailUrl(String id) {
    return '$girlBaseUrl$id';
  }

  static String getFanHao1(int page) {
    return '${fanHao1}page/$page';
  }

  static String getFanHao2(String type, int page) {
    return '$fanHao2$type~~~~~~~0~addtime~$page.html';
  }

  static String getFanHao3(String type, int page) {
    return page == 1
        ? '$fanHao3$type/index.html'
        : '$fanHao3$type/index_$page.html';
  }

  static String getNiMaUrl(String key, int page) {
    return '$searchNiMaUrl$key-hot-desc-$page';
  }
}
