

class UrlsBean {
  String s4kMovie;
  String pornForum;
  String pornVideo;
  String lsjUrl;
  String liveUrl;
  String searchUrl;
  String searchNiMaUrl;
  String fanHao1;
  String fanHao2;
  String fanHao3;
  String xianFengUrl;
  String videoList1Url;
  String videoList2Url;
  String videoList3Url;
  String videoList4Url;
  String videoList5Url;
  String videoList6Url;
  String videoList7Url;
  String videoList8Url;
  String videoList9Url;
  String videoList10Url;
  String douYinUrl;
  String douYin2Url;
  String abjUrl;
  String yaSeUrl;
  String parse2Url;
  String parse3Url;
  String parse4Url;
  String parse5Url;
  String movieBaseUrl1;
  String gif1;
  String gif2;
  String xianFeng3Url;
  String xianFeng4Url;
  String xianFeng5Url;
  bool isUpSiSeUrl;
  bool goToFuLi;
  int version;

  UrlsBean(
      {this.s4kMovie,
        this.pornForum,
        this.pornVideo,
        this.lsjUrl,
        this.liveUrl,
        this.searchUrl,
        this.searchNiMaUrl,
        this.fanHao1,
        this.fanHao2,
        this.fanHao3,
        this.xianFengUrl,
        this.videoList1Url,
        this.videoList2Url,
        this.videoList3Url,
        this.videoList4Url,
        this.videoList5Url,
        this.videoList6Url,
        this.douYinUrl,
        this.douYin2Url,
        this.abjUrl,
        this.yaSeUrl,
        this.parse2Url,
        this.parse3Url,
        this.parse4Url,
        this.parse5Url,
        this.movieBaseUrl1,
        this.gif1,
        this.gif2,
        this.xianFeng3Url,
        this.xianFeng4Url,
        this.xianFeng5Url,
        this.isUpSiSeUrl,
        this.goToFuLi,
        this.version});

  UrlsBean.fromJson(Map<String, dynamic> json) {
    s4kMovie = json['4kMovie'];
    pornForum = json['pornForum'];
    pornVideo = json['pornVideo'];
    lsjUrl = json['lsjUrl'];
    liveUrl = json['liveUrl'];
    searchUrl = json['searchUrl'];
    searchNiMaUrl = json['searchNiMaUrl'];
    fanHao1 = json['fanHao1'];
    fanHao2 = json['fanHao2'];
    fanHao3 = json['fanHao3'];
    xianFengUrl = json['xianFengUrl'];
    videoList1Url = json['videoList1Url'];
    videoList2Url = json['videoList2Url'];
    videoList3Url = json['videoList3Url'];
    videoList4Url = json['videoList4Url'];
    videoList5Url = json['videoList5Url'];
    videoList6Url = json['videoList6Url'];
    videoList7Url = json['videoList7Url'];
    videoList8Url = json['videoList8Url'];
    videoList9Url = json['videoList9Url'];
    videoList10Url = json['videoList10Url'];
    xianFeng5Url = json['xianFeng5Url'];
    douYinUrl = json['douYinUrl'];
    douYin2Url = json['douYin2Url'];
    abjUrl = json['abjUrl'];
    yaSeUrl = json['yaSeUrl'];
    parse2Url = json['parse2Url'];
    parse3Url = json['parse3Url'];
    parse4Url = json['parse4Url'];
    parse5Url = json['parse5Url'];
    movieBaseUrl1 = json['movieBaseUrl1'];
    gif1 = json['gif1'];
    gif2 = json['gif2'];
    xianFeng3Url = json['xianFeng3Url'];
    xianFeng4Url = json['xianFeng4Url'];
    isUpSiSeUrl = json['isUpSiSeUrl'];
    goToFuLi = json['goToFuLi'];
    version = json['version'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['4kMovie'] = this.s4kMovie;
    data['pornForum'] = this.pornForum;
    data['pornVideo'] = this.pornVideo;
    data['lsjUrl'] = this.lsjUrl;
    data['liveUrl'] = this.liveUrl;
    data['searchUrl'] = this.searchUrl;
    data['searchNiMaUrl'] = this.searchNiMaUrl;
    data['fanHao1'] = this.fanHao1;
    data['fanHao2'] = this.fanHao2;
    data['fanHao3'] = this.fanHao3;
    data['xianFengUrl'] = this.xianFengUrl;
    data['videoList1Url'] = this.videoList1Url;
    data['videoList2Url'] = this.videoList2Url;
    data['videoList3Url'] = this.videoList3Url;
    data['videoList4Url'] = this.videoList4Url;
    data['videoList5Url'] = this.videoList5Url;
    data['videoList6Url'] = this.videoList6Url;
    data['videoList7Url'] = this.videoList7Url;
    data['videoList8Url'] = this.videoList8Url;
    data['videoList9Url'] = this.videoList9Url;
    data['videoList10Url'] = this.videoList10Url;
    data['douYinUrl'] = this.douYinUrl;
    data['douYin2Url'] = this.douYin2Url;
    data['abjUrl'] = this.abjUrl;
    data['yaSeUrl'] = this.yaSeUrl;
    data['parse2Url'] = this.parse2Url;
    data['parse3Url'] = this.parse3Url;
    data['parse4Url'] = this.parse4Url;
    data['parse5Url'] = this.parse5Url;
    data['movieBaseUrl1'] = this.movieBaseUrl1;
    data['gif1'] = this.gif1;
    data['gif2'] = this.gif2;
    data['xianFeng3Url'] = this.xianFeng3Url;
    data['xianFeng4Url'] = this.xianFeng4Url;
    data['xianFeng5Url'] = this.xianFeng5Url;
    data['isUpSiSeUrl'] = this.isUpSiSeUrl;
    data['goToFuLi'] = this.goToFuLi;
    data['version'] = this.version;
    return data;
  }
}
class UpdateBean {
  int version;
  bool isForce;
  String versionName;
  String des;
  String url;

  UpdateBean(
      {this.version, this.isForce, this.versionName, this.des, this.url});

  UpdateBean.fromJson(Map<String, dynamic> json) {
    version = json['version'];
    isForce = json['isForce'];
    versionName = json['versionName'];
    des = json['des'];
    url = json['url'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['version'] = this.version;
    data['isForce'] = this.isForce;
    data['versionName'] = this.versionName;
    data['des'] = this.des;
    data['url'] = this.url;
    return data;
  }
}

class NoticeBean {
  String content;
  int version;
  String title;
  bool isShow;
  bool canCancel;

  NoticeBean(
      {this.content, this.version, this.title, this.isShow, this.canCancel});

  NoticeBean.fromJson(Map<String, dynamic> json) {
    content = json['content'];
    version = json['version'];
    title = json['title'];
    isShow = json['isShow'];
    canCancel = json['canCancel'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['content'] = this.content;
    data['version'] = this.version;
    data['title'] = this.title;
    data['isShow'] = this.isShow;
    data['canCancel'] = this.canCancel;
    return data;
  }
}

class UpdateKey {
  String xVideosKey;
  String copyKey;

  UpdateKey({this.xVideosKey});

  UpdateKey.fromJson(Map<String, dynamic> json) {
    xVideosKey = json['xVideosKey'];
    copyKey = json['copyKey'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['xVideosKey'] = this.xVideosKey;
    data['copyKey'] = this.copyKey;
    return data;
  }
}





