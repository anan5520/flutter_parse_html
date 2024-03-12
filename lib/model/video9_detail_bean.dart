/// info : {"id":269250,"title":"幻想成真","url":"https://xdow0.cyw4nadw.xyz/uploads/videos/欧美大片/20240306/67ad9280dc6f282ea51a6d83fe5522a1.mp4","url_s":"https://ts.zhenmeitiyu.xyz/uploads/m3u8/欧美大片/20240306/67ad9280dc6f282ea51a6d83fe5522a1.m3u8","is_trans":1,"scores":0,"times":"0:29:54","thumbimg":"https://3wvpWu.ekyryrhc.xyz/uploads/bmvideo/2024/03/07/20d147b087b67d71453222b2946120d9.jpg","remark":"","category":10,"tags":"43","photos":null,"type":"bmvideo","status":1,"is_rec":0,"hits":6305,"comments":0,"zan":2,"collect":2,"user_id":0,"user_name":"官方账号","user_avatar":"https://3wvpWu.ekyryrhc.xyz/uploads/others/adminheader.jpg","user_type":1,"sub_time":"2024-03-08 00:11:43","create_time":"2024-03-07 00:11:56","update_time":"2024-03-08 17:35:22","is_dy":0,"thumb_type":0,"is_vip":0,"topic":[],"city_id":0,"city_name":"","is_top":0,"user_top":"0","user_show":"1","scores_fan":0,"pass_msg":"","pass_time":0,"content":"","imglist":[],"url_s_s":"/uploads/m3u8/欧美大片/20240306/67ad9280dc6f282ea51a6d83fe5522a1.m3u8","user_vip":0,"hasZan":0,"hasCollect":0,"hasDown":0,"isFollow":0}
/// roadList : [{"id":"1","name":"普通线路1","domain":"https://ts.zhenmeitiyu.xyz","is_vip":"1"},{"id":"2","name":"普通线路2","domain":"https://Znt2SE.r3yx2evj.xyz","is_vip":"1"},{"id":"8","name":"普通线路3","domain":"https://ts.wj5kg5bq.xyz","is_vip":"1"},{"id":"3","name":"VIP线路1","domain":"https://Znt2SE.r3yx2evj.xyz","is_vip":"0"},{"id":"5","name":"VIP线路2","domain":"https://ts.zhenmeitiyu.xyz","is_vip":"0"},{"id":"7","name":"VIP线路3","domain":"https://vip.wj5kg5bq.xyz","is_vip":"0"}]

class Video9DetailBean {
  Video9DetailBean({
      Info info, 
      List<RoadList> roadList,}){
    _info = info;
    _roadList = roadList;
}

  Video9DetailBean.fromJson(dynamic json) {
    _info = json['info'] != null ? Info.fromJson(json['info']) : null;
    if (json['roadList'] != null) {
      _roadList = [];
      json['roadList'].forEach((v) {
        _roadList.add(RoadList.fromJson(v));
      });
    }
  }
  Info _info;
  List<RoadList> _roadList;
Video9DetailBean copyWith({  Info info,
  List<RoadList> roadList,
}) => Video9DetailBean(  info: info ?? _info,
  roadList: roadList ?? _roadList,
);
  Info get info => _info;
  List<RoadList> get roadList => _roadList;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (_info != null) {
      map['info'] = _info.toJson();
    }
    if (_roadList != null) {
      map['roadList'] = _roadList.map((v) => v.toJson()).toList();
    }
    return map;
  }

}

/// id : "1"
/// name : "普通线路1"
/// domain : "https://ts.zhenmeitiyu.xyz"
/// is_vip : "1"

class RoadList {
  RoadList({
      String id, 
      String name, 
      String domain, 
      String isVip,}){
    _id = id;
    _name = name;
    _domain = domain;
    _isVip = isVip;
}

  RoadList.fromJson(dynamic json) {
    _id = json['id'];
    _name = json['name'];
    _domain = json['domain'];
    _isVip = json['is_vip'];
  }
  String _id;
  String _name;
  String _domain;
  String _isVip;
RoadList copyWith({  String id,
  String name,
  String domain,
  String isVip,
}) => RoadList(  id: id ?? _id,
  name: name ?? _name,
  domain: domain ?? _domain,
  isVip: isVip ?? _isVip,
);
  String get id => _id;
  String get name => _name;
  String get domain => _domain;
  String get isVip => _isVip;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = _id;
    map['name'] = _name;
    map['domain'] = _domain;
    map['is_vip'] = _isVip;
    return map;
  }

}

/// id : 269250
/// title : "幻想成真"
/// url : "https://xdow0.cyw4nadw.xyz/uploads/videos/欧美大片/20240306/67ad9280dc6f282ea51a6d83fe5522a1.mp4"
/// url_s : "https://ts.zhenmeitiyu.xyz/uploads/m3u8/欧美大片/20240306/67ad9280dc6f282ea51a6d83fe5522a1.m3u8"
/// is_trans : 1
/// scores : 0
/// times : "0:29:54"
/// thumbimg : "https://3wvpWu.ekyryrhc.xyz/uploads/bmvideo/2024/03/07/20d147b087b67d71453222b2946120d9.jpg"
/// remark : ""
/// category : 10
/// tags : "43"
/// photos : null
/// type : "bmvideo"
/// status : 1
/// is_rec : 0
/// hits : 6305
/// comments : 0
/// zan : 2
/// collect : 2
/// user_id : 0
/// user_name : "官方账号"
/// user_avatar : "https://3wvpWu.ekyryrhc.xyz/uploads/others/adminheader.jpg"
/// user_type : 1
/// sub_time : "2024-03-08 00:11:43"
/// create_time : "2024-03-07 00:11:56"
/// update_time : "2024-03-08 17:35:22"
/// is_dy : 0
/// thumb_type : 0
/// is_vip : 0
/// topic : []
/// city_id : 0
/// city_name : ""
/// is_top : 0
/// user_top : "0"
/// user_show : "1"
/// scores_fan : 0
/// pass_msg : ""
/// pass_time : 0
/// content : ""
/// imglist : []
/// url_s_s : "/uploads/m3u8/欧美大片/20240306/67ad9280dc6f282ea51a6d83fe5522a1.m3u8"
/// user_vip : 0
/// hasZan : 0
/// hasCollect : 0
/// hasDown : 0
/// isFollow : 0

class Info {
  Info({
      num id, 
      String title, 
      String url, 
      String urlS, 
      num isTrans, 
      num scores, 
      String times, 
      String thumbimg, 
      String remark, 
      num category, 
      String tags, 
      dynamic photos, 
      String type, 
      num status, 
      num isRec, 
      num hits, 
      num comments, 
      num zan, 
      num collect, 
      num userId, 
      String userName, 
      String userAvatar, 
      num userType, 
      String subTime, 
      String createTime, 
      String updateTime, 
      num isDy, 
      num thumbType, 
      num isVip, 
      List<dynamic> topic, 
      num cityId, 
      String cityName, 
      num isTop, 
      String userTop, 
      String userShow, 
      num scoresFan, 
      String passMsg, 
      num passTime, 
      String content, 
      List<dynamic> imglist, 
      String urlSS, 
      num userVip, 
      num hasZan, 
      num hasCollect, 
      num hasDown, 
      num isFollow,}){
    _id = id;
    _title = title;
    _url = url;
    _urlS = urlS;
    _isTrans = isTrans;
    _scores = scores;
    _times = times;
    _thumbimg = thumbimg;
    _remark = remark;
    _category = category;
    _tags = tags;
    _photos = photos;
    _type = type;
    _status = status;
    _isRec = isRec;
    _hits = hits;
    _comments = comments;
    _zan = zan;
    _collect = collect;
    _userId = userId;
    _userName = userName;
    _userAvatar = userAvatar;
    _userType = userType;
    _subTime = subTime;
    _createTime = createTime;
    _updateTime = updateTime;
    _isDy = isDy;
    _thumbType = thumbType;
    _isVip = isVip;
    _topic = topic;
    _cityId = cityId;
    _cityName = cityName;
    _isTop = isTop;
    _userTop = userTop;
    _userShow = userShow;
    _scoresFan = scoresFan;
    _passMsg = passMsg;
    _passTime = passTime;
    _content = content;
    _imglist = imglist;
    _urlSS = urlSS;
    _userVip = userVip;
    _hasZan = hasZan;
    _hasCollect = hasCollect;
    _hasDown = hasDown;
    _isFollow = isFollow;
}

  Info.fromJson(dynamic json) {
    _id = json['id'];
    _title = json['title'];
    _url = json['url'];
    _urlS = json['url_s'];
    _isTrans = json['is_trans'];
    _scores = json['scores'];
    _times = json['times'];
    _thumbimg = json['thumbimg'];
    _remark = json['remark'];
    _category = json['category'];
    _tags = json['tags'];
    _photos = json['photos'];
    _type = json['type'];
    _status = json['status'];
    _isRec = json['is_rec'];
    _hits = json['hits'];
    _comments = json['comments'];
    _zan = json['zan'];
    _collect = json['collect'];
    _userId = json['user_id'];
    _userName = json['user_name'];
    _userAvatar = json['user_avatar'];
    _userType = json['user_type'];
    _subTime = json['sub_time'];
    _createTime = json['create_time'];
    _updateTime = json['update_time'];
    _isDy = json['is_dy'];
    _thumbType = json['thumb_type'];
    _isVip = json['is_vip'];
    if (json['topic'] != null) {
      _topic = [];
      json['topic'].forEach((v) {
        _topic.add(v);
      });
    }
    _cityId = json['city_id'];
    _cityName = json['city_name'];
    _isTop = json['is_top'];
    _userTop = json['user_top'];
    _userShow = json['user_show'];
    _scoresFan = json['scores_fan'];
    _passMsg = json['pass_msg'];
    _passTime = json['pass_time'];
    _content = json['content'];
    if (json['imglist'] != null) {
      _imglist = [];
      json['imglist'].forEach((v) {
        _imglist.add(v);
      });
    }
    _urlSS = json['url_s_s'];
    _userVip = json['user_vip'];
    _hasZan = json['hasZan'];
    _hasCollect = json['hasCollect'];
    _hasDown = json['hasDown'];
    _isFollow = json['isFollow'];
  }
  num _id;
  String _title;
  String _url;
  String _urlS;
  num _isTrans;
  num _scores;
  String _times;
  String _thumbimg;
  String _remark;
  num _category;
  String _tags;
  dynamic _photos;
  String _type;
  num _status;
  num _isRec;
  num _hits;
  num _comments;
  num _zan;
  num _collect;
  num _userId;
  String _userName;
  String _userAvatar;
  num _userType;
  String _subTime;
  String _createTime;
  String _updateTime;
  num _isDy;
  num _thumbType;
  num _isVip;
  List<dynamic> _topic;
  num _cityId;
  String _cityName;
  num _isTop;
  String _userTop;
  String _userShow;
  num _scoresFan;
  String _passMsg;
  num _passTime;
  String _content;
  List<dynamic> _imglist;
  String _urlSS;
  num _userVip;
  num _hasZan;
  num _hasCollect;
  num _hasDown;
  num _isFollow;
Info copyWith({  num id,
  String title,
  String url,
  String urlS,
  num isTrans,
  num scores,
  String times,
  String thumbimg,
  String remark,
  num category,
  String tags,
  dynamic photos,
  String type,
  num status,
  num isRec,
  num hits,
  num comments,
  num zan,
  num collect,
  num userId,
  String userName,
  String userAvatar,
  num userType,
  String subTime,
  String createTime,
  String updateTime,
  num isDy,
  num thumbType,
  num isVip,
  List<dynamic> topic,
  num cityId,
  String cityName,
  num isTop,
  String userTop,
  String userShow,
  num scoresFan,
  String passMsg,
  num passTime,
  String content,
  List<dynamic> imglist,
  String urlSS,
  num userVip,
  num hasZan,
  num hasCollect,
  num hasDown,
  num isFollow,
}) => Info(  id: id ?? _id,
  title: title ?? _title,
  url: url ?? _url,
  urlS: urlS ?? _urlS,
  isTrans: isTrans ?? _isTrans,
  scores: scores ?? _scores,
  times: times ?? _times,
  thumbimg: thumbimg ?? _thumbimg,
  remark: remark ?? _remark,
  category: category ?? _category,
  tags: tags ?? _tags,
  photos: photos ?? _photos,
  type: type ?? _type,
  status: status ?? _status,
  isRec: isRec ?? _isRec,
  hits: hits ?? _hits,
  comments: comments ?? _comments,
  zan: zan ?? _zan,
  collect: collect ?? _collect,
  userId: userId ?? _userId,
  userName: userName ?? _userName,
  userAvatar: userAvatar ?? _userAvatar,
  userType: userType ?? _userType,
  subTime: subTime ?? _subTime,
  createTime: createTime ?? _createTime,
  updateTime: updateTime ?? _updateTime,
  isDy: isDy ?? _isDy,
  thumbType: thumbType ?? _thumbType,
  isVip: isVip ?? _isVip,
  topic: topic ?? _topic,
  cityId: cityId ?? _cityId,
  cityName: cityName ?? _cityName,
  isTop: isTop ?? _isTop,
  userTop: userTop ?? _userTop,
  userShow: userShow ?? _userShow,
  scoresFan: scoresFan ?? _scoresFan,
  passMsg: passMsg ?? _passMsg,
  passTime: passTime ?? _passTime,
  content: content ?? _content,
  imglist: imglist ?? _imglist,
  urlSS: urlSS ?? _urlSS,
  userVip: userVip ?? _userVip,
  hasZan: hasZan ?? _hasZan,
  hasCollect: hasCollect ?? _hasCollect,
  hasDown: hasDown ?? _hasDown,
  isFollow: isFollow ?? _isFollow,
);
  num get id => _id;
  String get title => _title;
  String get url => _url;
  String get urlS => _urlS;
  num get isTrans => _isTrans;
  num get scores => _scores;
  String get times => _times;
  String get thumbimg => _thumbimg;
  String get remark => _remark;
  num get category => _category;
  String get tags => _tags;
  dynamic get photos => _photos;
  String get type => _type;
  num get status => _status;
  num get isRec => _isRec;
  num get hits => _hits;
  num get comments => _comments;
  num get zan => _zan;
  num get collect => _collect;
  num get userId => _userId;
  String get userName => _userName;
  String get userAvatar => _userAvatar;
  num get userType => _userType;
  String get subTime => _subTime;
  String get createTime => _createTime;
  String get updateTime => _updateTime;
  num get isDy => _isDy;
  num get thumbType => _thumbType;
  num get isVip => _isVip;
  List<dynamic> get topic => _topic;
  num get cityId => _cityId;
  String get cityName => _cityName;
  num get isTop => _isTop;
  String get userTop => _userTop;
  String get userShow => _userShow;
  num get scoresFan => _scoresFan;
  String get passMsg => _passMsg;
  num get passTime => _passTime;
  String get content => _content;
  List<dynamic> get imglist => _imglist;
  String get urlSS => _urlSS;
  num get userVip => _userVip;
  num get hasZan => _hasZan;
  num get hasCollect => _hasCollect;
  num get hasDown => _hasDown;
  num get isFollow => _isFollow;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = _id;
    map['title'] = _title;
    map['url'] = _url;
    map['url_s'] = _urlS;
    map['is_trans'] = _isTrans;
    map['scores'] = _scores;
    map['times'] = _times;
    map['thumbimg'] = _thumbimg;
    map['remark'] = _remark;
    map['category'] = _category;
    map['tags'] = _tags;
    map['photos'] = _photos;
    map['type'] = _type;
    map['status'] = _status;
    map['is_rec'] = _isRec;
    map['hits'] = _hits;
    map['comments'] = _comments;
    map['zan'] = _zan;
    map['collect'] = _collect;
    map['user_id'] = _userId;
    map['user_name'] = _userName;
    map['user_avatar'] = _userAvatar;
    map['user_type'] = _userType;
    map['sub_time'] = _subTime;
    map['create_time'] = _createTime;
    map['update_time'] = _updateTime;
    map['is_dy'] = _isDy;
    map['thumb_type'] = _thumbType;
    map['is_vip'] = _isVip;
    if (_topic != null) {
      map['topic'] = _topic.map((v) => v.toJson()).toList();
    }
    map['city_id'] = _cityId;
    map['city_name'] = _cityName;
    map['is_top'] = _isTop;
    map['user_top'] = _userTop;
    map['user_show'] = _userShow;
    map['scores_fan'] = _scoresFan;
    map['pass_msg'] = _passMsg;
    map['pass_time'] = _passTime;
    map['content'] = _content;
    if (_imglist != null) {
      map['imglist'] = _imglist.map((v) => v.toJson()).toList();
    }
    map['url_s_s'] = _urlSS;
    map['user_vip'] = _userVip;
    map['hasZan'] = _hasZan;
    map['hasCollect'] = _hasCollect;
    map['hasDown'] = _hasDown;
    map['isFollow'] = _isFollow;
    return map;
  }

}