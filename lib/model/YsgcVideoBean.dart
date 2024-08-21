/// flag : "play"
/// encrypt : 3
/// trysee : 0
/// points : 0
/// link : "/vodplay/114273-1-1.html"
/// link_next : ""
/// link_pre : ""
/// vod_data : {"vod_name":"幻术先生","vod_actor":"钱小豪,杜奕衡","vod_director":"胡海铭","vod_class":"网络电影,喜剧"}
/// vod_title : "%E5%B9%BB%E6%9C%AF%E5%85%88%E7%94%9F"
/// vod_pic_thumb : "https://pic2.iqiyipic.com/image/20230131/0a/0a/v_171105291_m_601_m4_480_270.jpg"
/// vod_title_name : "HD%E5%9B%BD%E8%AF%AD"
/// url : "GVPT90foo00ooo00oAwo000ooeDhbj8o000o7HpSzoo00oEt7biwr2MAeKnIwrvVB5xlNely0lZmUfoTTXT4rqIF4LbxGeEIBFJbzQfXo000oAO0O0OO0O0O"
/// url_next : "JxtDG0fQLPxo000o2PrrQwUwNQO0O0OO0O0O"
/// from : "ffm3u8"
/// server : "no"
/// note : ""
/// id : "114273"
/// sid : 3
/// nid : 1

class YsgcVideoBean {
  YsgcVideoBean({
      String? flag, 
      num? encrypt, 
      num? trysee, 
      num? points, 
      String? link, 
      String? linkNext, 
      String? linkPre, 
      VodData? vodData,
      String? vodTitle, 
      String? vodPicThumb, 
      String? vodTitleName, 
      String? url, 
      String? urlNext, 
      String? from, 
      String? server, 
      String? note, 
      String? id, 
      num? sid, 
      num? nid,}){
    _flag = flag;
    _encrypt = encrypt;
    _trysee = trysee;
    _points = points;
    _link = link;
    _linkNext = linkNext;
    _linkPre = linkPre;
    _vodData = vodData;
    _vodTitle = vodTitle;
    _vodPicThumb = vodPicThumb;
    _vodTitleName = vodTitleName;
    _url = url;
    _urlNext = urlNext;
    _from = from;
    _server = server;
    _note = note;
    _id = id;
    _sid = sid;
    _nid = nid;
}

  YsgcVideoBean.fromJson(dynamic json) {
    _flag = json['flag'];
    _encrypt = json['encrypt'];
    _trysee = json['trysee'];
    _points = json['points'];
    _link = json['link'];
    _linkNext = json['link_next'];
    _linkPre = json['link_pre'];
    _vodData = json['vod_data'] != null ? VodData.fromJson(json['vod_data']) : null;
    _vodTitle = json['vod_title'];
    _vodPicThumb = json['vod_pic_thumb'];
    _vodTitleName = json['vod_title_name'];
    _url = json['url'];
    _urlNext = json['url_next'];
    _from = json['from'];
    _server = json['server'];
    _note = json['note'];
    _id = json['id'];
    _sid = json['sid'];
    _nid = json['nid'];
  }
  String? _flag;
  num? _encrypt;
  num? _trysee;
  num? _points;
  String? _link;
  String? _linkNext;
  String? _linkPre;
  VodData? _vodData;
  String? _vodTitle;
  String? _vodPicThumb;
  String? _vodTitleName;
  String? _url;
  String? _urlNext;
  String? _from;
  String? _server;
  String? _note;
  String? _id;
  num? _sid;
  num? _nid;
YsgcVideoBean copyWith({  String? flag,
  num? encrypt,
  num? trysee,
  num? points,
  String? link,
  String? linkNext,
  String? linkPre,
  VodData? vodData,
  String? vodTitle,
  String? vodPicThumb,
  String? vodTitleName,
  String? url,
  String? urlNext,
  String? from,
  String? server,
  String? note,
  String? id,
  num? sid,
  num? nid,
}) => YsgcVideoBean(  flag: flag ?? _flag,
  encrypt: encrypt ?? _encrypt,
  trysee: trysee ?? _trysee,
  points: points ?? _points,
  link: link ?? _link,
  linkNext: linkNext ?? _linkNext,
  linkPre: linkPre ?? _linkPre,
  vodData: vodData ?? _vodData,
  vodTitle: vodTitle ?? _vodTitle,
  vodPicThumb: vodPicThumb ?? _vodPicThumb,
  vodTitleName: vodTitleName ?? _vodTitleName,
  url: url ?? _url,
  urlNext: urlNext ?? _urlNext,
  from: from ?? _from,
  server: server ?? _server,
  note: note ?? _note,
  id: id ?? _id,
  sid: sid ?? _sid,
  nid: nid ?? _nid,
);
  String? get flag => _flag;
  num? get encrypt => _encrypt;
  num? get trysee => _trysee;
  num? get points => _points;
  String? get link => _link;
  String? get linkNext => _linkNext;
  String? get linkPre => _linkPre;
  VodData? get vodData => _vodData;
  String? get vodTitle => _vodTitle;
  String? get vodPicThumb => _vodPicThumb;
  String? get vodTitleName => _vodTitleName;
  String? get url => _url;
  String? get urlNext => _urlNext;
  String? get from => _from;
  String? get server => _server;
  String? get note => _note;
  String? get id => _id;
  num? get sid => _sid;
  num? get nid => _nid;

  Map<String?, dynamic> toJson() {
    final map = <String?, dynamic>{};
    map['flag'] = _flag;
    map['encrypt'] = _encrypt;
    map['trysee'] = _trysee;
    map['points'] = _points;
    map['link'] = _link;
    map['link_next'] = _linkNext;
    map['link_pre'] = _linkPre;
    if (_vodData != null) {
      map['vod_data'] = _vodData!.toJson();
    }
    map['vod_title'] = _vodTitle;
    map['vod_pic_thumb'] = _vodPicThumb;
    map['vod_title_name'] = _vodTitleName;
    map['url'] = _url;
    map['url_next'] = _urlNext;
    map['from'] = _from;
    map['server'] = _server;
    map['note'] = _note;
    map['id'] = _id;
    map['sid'] = _sid;
    map['nid'] = _nid;
    return map;
  }

}

/// vod_name : "幻术先生"
/// vod_actor : "钱小豪,杜奕衡"
/// vod_director : "胡海铭"
/// vod_class : "网络电影,喜剧"

class VodData {
  VodData({
      String? vodName, 
      String? vodActor, 
      String? vodDirector, 
      String? vodClass,}){
    _vodName = vodName;
    _vodActor = vodActor;
    _vodDirector = vodDirector;
    _vodClass = vodClass;
}

  VodData.fromJson(dynamic json) {
    _vodName = json['vod_name'];
    _vodActor = json['vod_actor'];
    _vodDirector = json['vod_director'];
    _vodClass = json['vod_class'];
  }
  String? _vodName;
  String? _vodActor;
  String? _vodDirector;
  String? _vodClass;
VodData copyWith({  String? vodName,
  String? vodActor,
  String? vodDirector,
  String? vodClass,
}) => VodData(  vodName: vodName ?? _vodName,
  vodActor: vodActor ?? _vodActor,
  vodDirector: vodDirector ?? _vodDirector,
  vodClass: vodClass ?? _vodClass,
);
  String? get vodName => _vodName;
  String? get vodActor => _vodActor;
  String? get vodDirector => _vodDirector;
  String? get vodClass => _vodClass;

  Map<String?, dynamic> toJson() {
    final map = <String?, dynamic>{};
    map['vod_name'] = _vodName;
    map['vod_actor'] = _vodActor;
    map['vod_director'] = _vodDirector;
    map['vod_class'] = _vodClass;
    return map;
  }

}