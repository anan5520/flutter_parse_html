

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
  bool isUpSiSeUrl;
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
        this.isUpSiSeUrl,
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
    isUpSiSeUrl = json['isUpSiSeUrl'];
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
    data['isUpSiSeUrl'] = this.isUpSiSeUrl;
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
