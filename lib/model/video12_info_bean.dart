/// status : 200
/// result : {"id":22448,"title":"国产AV-迷情弹奏性爱淫荡交织","artist":"5000","code":null,"url":"https://cdn.hqt1849.com/videos/202112/hls/2a7da6cf-c3e9-4752-a7e6-77b410b0d106/index.m3u8?id=22448&sign=fe0eebbd5cc98bb1bef2fa2bacd9675b&t=1639034100","desc":"国产AV-迷情弹奏性爱淫荡交织","image":"https://image.hannlin.com/storage/videos/202112/covers/2479d9ff-1ab5-4b4d-a062-88d22d3f034d_n.jpg","sort":58,"tag":"剧情,素人,美乳,诱惑,口交,淫乱,骑乘,后入,美臀","views":18141,"zans":1,"downloads":0,"comments":0,"barrage":1000,"vip_only":0,"is_recommend":0,"operator":"sys","created_at":"2021-12-08 11:41:50","updated_at":"2021-12-09 15:06:33","status":1,"sync_status":0,"ts_time":0,"short_video_path":"","uuid":"2a7da6cf-c3e9-4752-a7e6-77b410b0d106","is_like":false,"coverbase64":{"url":"https://cdn.hqt1849.com/videos/202112/covers/2479d9ff-1ab5-4b4d-a062-88d22d3f034d_n","type":"image/jpeg"}}
/// message : "success"

class Video12InfoBean {
  Video12InfoBean({
      int status, 
      Result result, 
      String message,}){
    _status = status;
    _result = result;
    _message = message;
}

  Video12InfoBean.fromJson(dynamic json) {
    _status = json['status'];
    _result = json['result'] != null ? Result.fromJson(json['result']) : null;
    _message = json['message'];
  }
  int _status;
  Result _result;
  String _message;

  int get status => _status;
  Result get result => _result;
  String get message => _message;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['status'] = _status;
    if (_result != null) {
      map['result'] = _result.toJson();
    }
    map['message'] = _message;
    return map;
  }

}

/// id : 22448
/// title : "国产AV-迷情弹奏性爱淫荡交织"
/// artist : "5000"
/// code : null
/// url : "https://cdn.hqt1849.com/videos/202112/hls/2a7da6cf-c3e9-4752-a7e6-77b410b0d106/index.m3u8?id=22448&sign=fe0eebbd5cc98bb1bef2fa2bacd9675b&t=1639034100"
/// desc : "国产AV-迷情弹奏性爱淫荡交织"
/// image : "https://image.hannlin.com/storage/videos/202112/covers/2479d9ff-1ab5-4b4d-a062-88d22d3f034d_n.jpg"
/// sort : 58
/// tag : "剧情,素人,美乳,诱惑,口交,淫乱,骑乘,后入,美臀"
/// views : 18141
/// zans : 1
/// downloads : 0
/// comments : 0
/// barrage : 1000
/// vip_only : 0
/// is_recommend : 0
/// operator : "sys"
/// created_at : "2021-12-08 11:41:50"
/// updated_at : "2021-12-09 15:06:33"
/// status : 1
/// sync_status : 0
/// ts_time : 0
/// short_video_path : ""
/// uuid : "2a7da6cf-c3e9-4752-a7e6-77b410b0d106"
/// is_like : false
/// coverbase64 : {"url":"https://cdn.hqt1849.com/videos/202112/covers/2479d9ff-1ab5-4b4d-a062-88d22d3f034d_n","type":"image/jpeg"}

class Result {
  Result({
      int id, 
      String title, 
      String artist, 
      dynamic code, 
      String url, 
      String desc, 
      String image, 
      int sort, 
      String tag, 
      int views, 
      int zans, 
      int downloads, 
      int comments, 
      int barrage, 
      int vipOnly, 
      int isRecommend, 
      String operator, 
      String createdAt, 
      String updatedAt, 
      int status, 
      int syncStatus, 
      int tsTime, 
      String shortVideoPath, 
      String uuid, 
      bool isLike, 
      Coverbase64 coverbase64,}){
    _id = id;
    _title = title;
    _artist = artist;
    _code = code;
    _url = url;
    _desc = desc;
    _image = image;
    _sort = sort;
    _tag = tag;
    _views = views;
    _zans = zans;
    _downloads = downloads;
    _comments = comments;
    _barrage = barrage;
    _vipOnly = vipOnly;
    _isRecommend = isRecommend;
    _operator = operator;
    _createdAt = createdAt;
    _updatedAt = updatedAt;
    _status = status;
    _syncStatus = syncStatus;
    _tsTime = tsTime;
    _shortVideoPath = shortVideoPath;
    _uuid = uuid;
    _isLike = isLike;
    _coverbase64 = coverbase64;
}

  Result.fromJson(dynamic json) {
    _id = json['id'];
    _title = json['title'];
    _artist = json['artist'];
    _code = json['code'];
    _url = json['url'];
    _desc = json['desc'];
    _image = json['image'];
    _sort = json['sort'];
    _tag = json['tag'];
    _views = json['views'];
    _zans = json['zans'];
    _downloads = json['downloads'];
    _comments = json['comments'];
    _barrage = json['barrage'];
    _vipOnly = json['vip_only'];
    _isRecommend = json['is_recommend'];
    _operator = json['operator'];
    _createdAt = json['created_at'];
    _updatedAt = json['updated_at'];
    _status = json['status'];
    _syncStatus = json['sync_status'];
    _tsTime = json['ts_time'];
    _shortVideoPath = json['short_video_path'];
    _uuid = json['uuid'];
    _isLike = json['is_like'];
    _coverbase64 = json['coverbase64'] != null ? Coverbase64.fromJson(json['coverbase64']) : null;
  }
  int _id;
  String _title;
  String _artist;
  dynamic _code;
  String _url;
  String _desc;
  String _image;
  int _sort;
  String _tag;
  int _views;
  int _zans;
  int _downloads;
  int _comments;
  int _barrage;
  int _vipOnly;
  int _isRecommend;
  String _operator;
  String _createdAt;
  String _updatedAt;
  int _status;
  int _syncStatus;
  int _tsTime;
  String _shortVideoPath;
  String _uuid;
  bool _isLike;
  Coverbase64 _coverbase64;

  int get id => _id;
  String get title => _title;
  String get artist => _artist;
  dynamic get code => _code;
  String get url => _url;
  String get desc => _desc;
  String get image => _image;
  int get sort => _sort;
  String get tag => _tag;
  int get views => _views;
  int get zans => _zans;
  int get downloads => _downloads;
  int get comments => _comments;
  int get barrage => _barrage;
  int get vipOnly => _vipOnly;
  int get isRecommend => _isRecommend;
  String get operator => _operator;
  String get createdAt => _createdAt;
  String get updatedAt => _updatedAt;
  int get status => _status;
  int get syncStatus => _syncStatus;
  int get tsTime => _tsTime;
  String get shortVideoPath => _shortVideoPath;
  String get uuid => _uuid;
  bool get isLike => _isLike;
  Coverbase64 get coverbase64 => _coverbase64;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = _id;
    map['title'] = _title;
    map['artist'] = _artist;
    map['code'] = _code;
    map['url'] = _url;
    map['desc'] = _desc;
    map['image'] = _image;
    map['sort'] = _sort;
    map['tag'] = _tag;
    map['views'] = _views;
    map['zans'] = _zans;
    map['downloads'] = _downloads;
    map['comments'] = _comments;
    map['barrage'] = _barrage;
    map['vip_only'] = _vipOnly;
    map['is_recommend'] = _isRecommend;
    map['operator'] = _operator;
    map['created_at'] = _createdAt;
    map['updated_at'] = _updatedAt;
    map['status'] = _status;
    map['sync_status'] = _syncStatus;
    map['ts_time'] = _tsTime;
    map['short_video_path'] = _shortVideoPath;
    map['uuid'] = _uuid;
    map['is_like'] = _isLike;
    if (_coverbase64 != null) {
      map['coverbase64'] = _coverbase64.toJson();
    }
    return map;
  }

}

/// url : "https://cdn.hqt1849.com/videos/202112/covers/2479d9ff-1ab5-4b4d-a062-88d22d3f034d_n"
/// type : "image/jpeg"

class Coverbase64 {
  Coverbase64({
      String url, 
      String type,}){
    _url = url;
    _type = type;
}

  Coverbase64.fromJson(dynamic json) {
    _url = json['url'];
    _type = json['type'];
  }
  String _url;
  String _type;

  String get url => _url;
  String get type => _type;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['url'] = _url;
    map['type'] = _type;
    return map;
  }

}