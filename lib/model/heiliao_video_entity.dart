/// live : false
/// autoplay : false
/// theme : "#FADFA3"
/// loop : false
/// screenshot : false
/// hotkey : true
/// preload : "none"
/// lang : "zh-cn"
/// logo : null
/// volume : 0.7
/// mutex : true
/// video : {"url":"https://long.lgtcpnb.cn/watch9/04c029f74be32b1fbde11b60fe5e8315/04c029f74be32b1fbde11b60fe5e8315.m3u8","pic":"","type":"auto","thumbnails":null}

class HeiliaoVideoEntity {
  HeiliaoVideoEntity({
      bool live, 
      bool autoplay, 
      String theme, 
      bool loop, 
      bool screenshot, 
      bool hotkey, 
      String preload, 
      String lang, 
      dynamic logo, 
      num volume, 
      bool mutex, 
      Video video,}){
    _live = live;
    _autoplay = autoplay;
    _theme = theme;
    _loop = loop;
    _screenshot = screenshot;
    _hotkey = hotkey;
    _preload = preload;
    _lang = lang;
    _logo = logo;
    _volume = volume;
    _mutex = mutex;
    _video = video;
}

  HeiliaoVideoEntity.fromJson(dynamic json) {
    _live = json['live'];
    _autoplay = json['autoplay'];
    _theme = json['theme'];
    _loop = json['loop'];
    _screenshot = json['screenshot'];
    _hotkey = json['hotkey'];
    _preload = json['preload'];
    _lang = json['lang'];
    _logo = json['logo'];
    _volume = json['volume'];
    _mutex = json['mutex'];
    _video = json['video'] != null ? Video.fromJson(json['video']) : null;
  }
  bool _live;
  bool _autoplay;
  String _theme;
  bool _loop;
  bool _screenshot;
  bool _hotkey;
  String _preload;
  String _lang;
  dynamic _logo;
  num _volume;
  bool _mutex;
  Video _video;
HeiliaoVideoEntity copyWith({  bool live,
  bool autoplay,
  String theme,
  bool loop,
  bool screenshot,
  bool hotkey,
  String preload,
  String lang,
  dynamic logo,
  num volume,
  bool mutex,
  Video video,
}) => HeiliaoVideoEntity(  live: live ?? _live,
  autoplay: autoplay ?? _autoplay,
  theme: theme ?? _theme,
  loop: loop ?? _loop,
  screenshot: screenshot ?? _screenshot,
  hotkey: hotkey ?? _hotkey,
  preload: preload ?? _preload,
  lang: lang ?? _lang,
  logo: logo ?? _logo,
  volume: volume ?? _volume,
  mutex: mutex ?? _mutex,
  video: video ?? _video,
);
  bool get live => _live;
  bool get autoplay => _autoplay;
  String get theme => _theme;
  bool get loop => _loop;
  bool get screenshot => _screenshot;
  bool get hotkey => _hotkey;
  String get preload => _preload;
  String get lang => _lang;
  dynamic get logo => _logo;
  num get volume => _volume;
  bool get mutex => _mutex;
  Video get video => _video;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['live'] = _live;
    map['autoplay'] = _autoplay;
    map['theme'] = _theme;
    map['loop'] = _loop;
    map['screenshot'] = _screenshot;
    map['hotkey'] = _hotkey;
    map['preload'] = _preload;
    map['lang'] = _lang;
    map['logo'] = _logo;
    map['volume'] = _volume;
    map['mutex'] = _mutex;
    if (_video != null) {
      map['video'] = _video.toJson();
    }
    return map;
  }

}

/// url : "https://long.lgtcpnb.cn/watch9/04c029f74be32b1fbde11b60fe5e8315/04c029f74be32b1fbde11b60fe5e8315.m3u8"
/// pic : ""
/// type : "auto"
/// thumbnails : null

class Video {
  Video({
      String url, 
      String pic, 
      String type, 
      dynamic thumbnails,}){
    _url = url;
    _pic = pic;
    _type = type;
    _thumbnails = thumbnails;
}

  Video.fromJson(dynamic json) {
    _url = json['url'];
    _pic = json['pic'];
    _type = json['type'];
    _thumbnails = json['thumbnails'];
  }
  String _url;
  String _pic;
  String _type;
  dynamic _thumbnails;
Video copyWith({  String url,
  String pic,
  String type,
  dynamic thumbnails,
}) => Video(  url: url ?? _url,
  pic: pic ?? _pic,
  type: type ?? _type,
  thumbnails: thumbnails ?? _thumbnails,
);
  String get url => _url;
  String get pic => _pic;
  String get type => _type;
  dynamic get thumbnails => _thumbnails;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['url'] = _url;
    map['pic'] = _pic;
    map['type'] = _type;
    map['thumbnails'] = _thumbnails;
    return map;
  }

}