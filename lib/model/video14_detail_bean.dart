/// ret : 200
/// data : {"code":0,"msg":"","info":{"user":{"is_vip":0,"watch_times":0},"details":{"id":"5075","title":"2019年度韩国福布斯名人榜第十名+iu+运动袜","face_img":"https://storage.googleapis.com/migutv/08cc1264329bbf89e0869836fc80f3d9.png","video_url":"","hclass_id":"3","htheme_id":null,"is_payfree":"1","video_times":"00:00:55","views":"29215","create_time":"2022-03-29 19:53:46","intro":null,"imgpath":"https://hbggkj2.com/upload/base64/20220329/08cc1264329bbf89e0869836fc80f3d9.png","m3u8_url":"https://hbggkj2.com/upload/admin/20220329/08cc1264329bbf89e0869836fc80f3d9/08cc1264329bbf89e0869836fc80f3d9.m3u8","is_like":0},"recommlist":[{"id":"5076","title":"be natural+裴珠泫+白丝袜做爱","face_img":"https://storage.googleapis.com/migutv/20ffd207c2a7b4fecdd30e84141892fe.png","is_payfree":"1","video_times":"00:02:36","views":"28494","create_time":"1648554905","imgpath":"https://hbggkj2.com/upload/base64/20220329/20ffd207c2a7b4fecdd30e84141892fe.png"},{"id":"5074","title":"be natural+裴珠泫+插的很舒服","face_img":"https://storage.googleapis.com/migutv/f6d1c643975d2518cb0fcb97670a8f1a.png","is_payfree":"1","video_times":"00:00:54","views":"28552","create_time":"1648554781","imgpath":"https://hbggkj2.com/upload/base64/20220329/f6d1c643975d2518cb0fcb97670a8f1a.png"},{"id":"5073","title":"2019年度歌手奖（10月音源部份）+iu+口交","face_img":"https://storage.googleapis.com/migutv/0961648618628b0aa011a10ab896e868.png","is_payfree":"1","video_times":"00:00:57","views":"28614","create_time":"1648554740","imgpath":"https://hbggkj2.com/upload/base64/20220329/0961648618628b0aa011a10ab896e868.png"},{"id":"5072","title":"《制作人》女主角+iu+自慰享受","face_img":"https://storage.googleapis.com/migutv/9a5be0a7647e1e095118e149dfa58370.png","is_payfree":"1","video_times":"00:01:29","views":"28440","create_time":"1648554701","imgpath":"https://hbggkj2.com/upload/base64/20220329/9a5be0a7647e1e095118e149dfa58370.png"},{"id":"5071","title":"《游戏公司女职员们》女主角+裴珠泫+学生装自慰","face_img":"https://storage.googleapis.com/migutv/ffc7d6b2a24b0c2ee71ea6679b5f810e.png","is_payfree":"1","video_times":"00:01:13","views":"27759","create_time":"1648554650","imgpath":"https://hbggkj2.com/upload/base64/20220329/ffc7d6b2a24b0c2ee71ea6679b5f810e.png"},{"id":"5070","title":"《在光化门》mv主角+裴珠泫+跟阳具玩","face_img":"https://storage.googleapis.com/migutv/2e10f2a4bd3e59352d5d6bc4f385b4ac.png","is_payfree":"1","video_times":"00:00:52","views":"28119","create_time":"1648554592","imgpath":"https://hbggkj2.com/upload/base64/20220329/2e10f2a4bd3e59352d5d6bc4f385b4ac.png"},{"id":"5069","title":"《在光化门》mv主角+裴珠泫+各种自慰棒","face_img":"https://storage.googleapis.com/migutv/2ca4e6cc7a5392b4c29896dd51f661a6.png","is_payfree":"1","video_times":"00:00:53","views":"27982","create_time":"1648554548","imgpath":"https://hbggkj2.com/upload/base64/20220329/2ca4e6cc7a5392b4c29896dd51f661a6.png"},{"id":"5068","title":"《在光化门》mv主角+裴珠泫+插入很享受","face_img":"https://storage.googleapis.com/migutv/6e891a6517241378b9710c84856e884e.png","is_payfree":"1","video_times":"00:00:54","views":"28330","create_time":"1648554514","imgpath":"https://hbggkj2.com/upload/base64/20220329/6e891a6517241378b9710c84856e884e.png"},{"id":"5067","title":" be natural+裴珠泫+非常大的几把","face_img":"https://storage.googleapis.com/migutv/82f299dd9e6cdab5b81c34076c022d22.png","is_payfree":"1","video_times":"00:00:48","views":"28412","create_time":"1648554471","imgpath":"https://hbggkj2.com/upload/base64/20220329/82f299dd9e6cdab5b81c34076c022d22.png"},{"id":"5046","title":"《在光化门》mv主角+裴珠泫+豹纹诱惑","face_img":"https://storage.googleapis.com/migutv/17c2f516f3e1245513a41d2b1081d89f.png","is_payfree":"1","video_times":"00:00:42","views":"72466","create_time":"1648467639","imgpath":"https://hbggkj2.com/upload/base64/20220328/17c2f516f3e1245513a41d2b1081d89f.png"}]}}
/// msg : ""

class Video14DetailBean {
  Video14DetailBean({
      int ret, 
      Data data, 
      String msg,}){
    _ret = ret;
    _data = data;
    _msg = msg;
}

  Video14DetailBean.fromJson(dynamic json) {
    _ret = json['ret'];
    _data = json['data'] != null ? Data.fromJson(json['data']) : null;
    _msg = json['msg'];
  }
  int _ret;
  Data _data;
  String _msg;

  int get ret => _ret;
  Data get data => _data;
  String get msg => _msg;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['ret'] = _ret;
    if (_data != null) {
      map['data'] = _data.toJson();
    }
    map['msg'] = _msg;
    return map;
  }

}

/// code : 0
/// msg : ""
/// info : {"user":{"is_vip":0,"watch_times":0},"details":{"id":"5075","title":"2019年度韩国福布斯名人榜第十名+iu+运动袜","face_img":"https://storage.googleapis.com/migutv/08cc1264329bbf89e0869836fc80f3d9.png","video_url":"","hclass_id":"3","htheme_id":null,"is_payfree":"1","video_times":"00:00:55","views":"29215","create_time":"2022-03-29 19:53:46","intro":null,"imgpath":"https://hbggkj2.com/upload/base64/20220329/08cc1264329bbf89e0869836fc80f3d9.png","m3u8_url":"https://hbggkj2.com/upload/admin/20220329/08cc1264329bbf89e0869836fc80f3d9/08cc1264329bbf89e0869836fc80f3d9.m3u8","is_like":0},"recommlist":[{"id":"5076","title":"be natural+裴珠泫+白丝袜做爱","face_img":"https://storage.googleapis.com/migutv/20ffd207c2a7b4fecdd30e84141892fe.png","is_payfree":"1","video_times":"00:02:36","views":"28494","create_time":"1648554905","imgpath":"https://hbggkj2.com/upload/base64/20220329/20ffd207c2a7b4fecdd30e84141892fe.png"},{"id":"5074","title":"be natural+裴珠泫+插的很舒服","face_img":"https://storage.googleapis.com/migutv/f6d1c643975d2518cb0fcb97670a8f1a.png","is_payfree":"1","video_times":"00:00:54","views":"28552","create_time":"1648554781","imgpath":"https://hbggkj2.com/upload/base64/20220329/f6d1c643975d2518cb0fcb97670a8f1a.png"},{"id":"5073","title":"2019年度歌手奖（10月音源部份）+iu+口交","face_img":"https://storage.googleapis.com/migutv/0961648618628b0aa011a10ab896e868.png","is_payfree":"1","video_times":"00:00:57","views":"28614","create_time":"1648554740","imgpath":"https://hbggkj2.com/upload/base64/20220329/0961648618628b0aa011a10ab896e868.png"},{"id":"5072","title":"《制作人》女主角+iu+自慰享受","face_img":"https://storage.googleapis.com/migutv/9a5be0a7647e1e095118e149dfa58370.png","is_payfree":"1","video_times":"00:01:29","views":"28440","create_time":"1648554701","imgpath":"https://hbggkj2.com/upload/base64/20220329/9a5be0a7647e1e095118e149dfa58370.png"},{"id":"5071","title":"《游戏公司女职员们》女主角+裴珠泫+学生装自慰","face_img":"https://storage.googleapis.com/migutv/ffc7d6b2a24b0c2ee71ea6679b5f810e.png","is_payfree":"1","video_times":"00:01:13","views":"27759","create_time":"1648554650","imgpath":"https://hbggkj2.com/upload/base64/20220329/ffc7d6b2a24b0c2ee71ea6679b5f810e.png"},{"id":"5070","title":"《在光化门》mv主角+裴珠泫+跟阳具玩","face_img":"https://storage.googleapis.com/migutv/2e10f2a4bd3e59352d5d6bc4f385b4ac.png","is_payfree":"1","video_times":"00:00:52","views":"28119","create_time":"1648554592","imgpath":"https://hbggkj2.com/upload/base64/20220329/2e10f2a4bd3e59352d5d6bc4f385b4ac.png"},{"id":"5069","title":"《在光化门》mv主角+裴珠泫+各种自慰棒","face_img":"https://storage.googleapis.com/migutv/2ca4e6cc7a5392b4c29896dd51f661a6.png","is_payfree":"1","video_times":"00:00:53","views":"27982","create_time":"1648554548","imgpath":"https://hbggkj2.com/upload/base64/20220329/2ca4e6cc7a5392b4c29896dd51f661a6.png"},{"id":"5068","title":"《在光化门》mv主角+裴珠泫+插入很享受","face_img":"https://storage.googleapis.com/migutv/6e891a6517241378b9710c84856e884e.png","is_payfree":"1","video_times":"00:00:54","views":"28330","create_time":"1648554514","imgpath":"https://hbggkj2.com/upload/base64/20220329/6e891a6517241378b9710c84856e884e.png"},{"id":"5067","title":" be natural+裴珠泫+非常大的几把","face_img":"https://storage.googleapis.com/migutv/82f299dd9e6cdab5b81c34076c022d22.png","is_payfree":"1","video_times":"00:00:48","views":"28412","create_time":"1648554471","imgpath":"https://hbggkj2.com/upload/base64/20220329/82f299dd9e6cdab5b81c34076c022d22.png"},{"id":"5046","title":"《在光化门》mv主角+裴珠泫+豹纹诱惑","face_img":"https://storage.googleapis.com/migutv/17c2f516f3e1245513a41d2b1081d89f.png","is_payfree":"1","video_times":"00:00:42","views":"72466","create_time":"1648467639","imgpath":"https://hbggkj2.com/upload/base64/20220328/17c2f516f3e1245513a41d2b1081d89f.png"}]}

class Data {
  Data({
      int code, 
      String msg, 
      Info info,}){
    _code = code;
    _msg = msg;
    _info = info;
}

  Data.fromJson(dynamic json) {
    _code = json['code'];
    _msg = json['msg'];
    _info = json['info'] != null ? Info.fromJson(json['info']) : null;
  }
  int _code;
  String _msg;
  Info _info;

  int get code => _code;
  String get msg => _msg;
  Info get info => _info;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['code'] = _code;
    map['msg'] = _msg;
    if (_info != null) {
      map['info'] = _info.toJson();
    }
    return map;
  }

}

/// user : {"is_vip":0,"watch_times":0}
/// details : {"id":"5075","title":"2019年度韩国福布斯名人榜第十名+iu+运动袜","face_img":"https://storage.googleapis.com/migutv/08cc1264329bbf89e0869836fc80f3d9.png","video_url":"","hclass_id":"3","htheme_id":null,"is_payfree":"1","video_times":"00:00:55","views":"29215","create_time":"2022-03-29 19:53:46","intro":null,"imgpath":"https://hbggkj2.com/upload/base64/20220329/08cc1264329bbf89e0869836fc80f3d9.png","m3u8_url":"https://hbggkj2.com/upload/admin/20220329/08cc1264329bbf89e0869836fc80f3d9/08cc1264329bbf89e0869836fc80f3d9.m3u8","is_like":0}
/// recommlist : [{"id":"5076","title":"be natural+裴珠泫+白丝袜做爱","face_img":"https://storage.googleapis.com/migutv/20ffd207c2a7b4fecdd30e84141892fe.png","is_payfree":"1","video_times":"00:02:36","views":"28494","create_time":"1648554905","imgpath":"https://hbggkj2.com/upload/base64/20220329/20ffd207c2a7b4fecdd30e84141892fe.png"},{"id":"5074","title":"be natural+裴珠泫+插的很舒服","face_img":"https://storage.googleapis.com/migutv/f6d1c643975d2518cb0fcb97670a8f1a.png","is_payfree":"1","video_times":"00:00:54","views":"28552","create_time":"1648554781","imgpath":"https://hbggkj2.com/upload/base64/20220329/f6d1c643975d2518cb0fcb97670a8f1a.png"},{"id":"5073","title":"2019年度歌手奖（10月音源部份）+iu+口交","face_img":"https://storage.googleapis.com/migutv/0961648618628b0aa011a10ab896e868.png","is_payfree":"1","video_times":"00:00:57","views":"28614","create_time":"1648554740","imgpath":"https://hbggkj2.com/upload/base64/20220329/0961648618628b0aa011a10ab896e868.png"},{"id":"5072","title":"《制作人》女主角+iu+自慰享受","face_img":"https://storage.googleapis.com/migutv/9a5be0a7647e1e095118e149dfa58370.png","is_payfree":"1","video_times":"00:01:29","views":"28440","create_time":"1648554701","imgpath":"https://hbggkj2.com/upload/base64/20220329/9a5be0a7647e1e095118e149dfa58370.png"},{"id":"5071","title":"《游戏公司女职员们》女主角+裴珠泫+学生装自慰","face_img":"https://storage.googleapis.com/migutv/ffc7d6b2a24b0c2ee71ea6679b5f810e.png","is_payfree":"1","video_times":"00:01:13","views":"27759","create_time":"1648554650","imgpath":"https://hbggkj2.com/upload/base64/20220329/ffc7d6b2a24b0c2ee71ea6679b5f810e.png"},{"id":"5070","title":"《在光化门》mv主角+裴珠泫+跟阳具玩","face_img":"https://storage.googleapis.com/migutv/2e10f2a4bd3e59352d5d6bc4f385b4ac.png","is_payfree":"1","video_times":"00:00:52","views":"28119","create_time":"1648554592","imgpath":"https://hbggkj2.com/upload/base64/20220329/2e10f2a4bd3e59352d5d6bc4f385b4ac.png"},{"id":"5069","title":"《在光化门》mv主角+裴珠泫+各种自慰棒","face_img":"https://storage.googleapis.com/migutv/2ca4e6cc7a5392b4c29896dd51f661a6.png","is_payfree":"1","video_times":"00:00:53","views":"27982","create_time":"1648554548","imgpath":"https://hbggkj2.com/upload/base64/20220329/2ca4e6cc7a5392b4c29896dd51f661a6.png"},{"id":"5068","title":"《在光化门》mv主角+裴珠泫+插入很享受","face_img":"https://storage.googleapis.com/migutv/6e891a6517241378b9710c84856e884e.png","is_payfree":"1","video_times":"00:00:54","views":"28330","create_time":"1648554514","imgpath":"https://hbggkj2.com/upload/base64/20220329/6e891a6517241378b9710c84856e884e.png"},{"id":"5067","title":" be natural+裴珠泫+非常大的几把","face_img":"https://storage.googleapis.com/migutv/82f299dd9e6cdab5b81c34076c022d22.png","is_payfree":"1","video_times":"00:00:48","views":"28412","create_time":"1648554471","imgpath":"https://hbggkj2.com/upload/base64/20220329/82f299dd9e6cdab5b81c34076c022d22.png"},{"id":"5046","title":"《在光化门》mv主角+裴珠泫+豹纹诱惑","face_img":"https://storage.googleapis.com/migutv/17c2f516f3e1245513a41d2b1081d89f.png","is_payfree":"1","video_times":"00:00:42","views":"72466","create_time":"1648467639","imgpath":"https://hbggkj2.com/upload/base64/20220328/17c2f516f3e1245513a41d2b1081d89f.png"}]

class Info {
  Info({
      User user, 
      Details details, 
      List<Recommlist> recommlist,}){
    _user = user;
    _details = details;
    _recommlist = recommlist;
}

  Info.fromJson(dynamic json) {
    _user = json['user'] != null ? User.fromJson(json['user']) : null;
    _details = json['details'] != null ? Details.fromJson(json['details']) : null;
    if (json['recommlist'] != null) {
      _recommlist = [];
      json['recommlist'].forEach((v) {
        _recommlist.add(Recommlist.fromJson(v));
      });
    }
  }
  User _user;
  Details _details;
  List<Recommlist> _recommlist;

  User get user => _user;
  Details get details => _details;
  List<Recommlist> get recommlist => _recommlist;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (_user != null) {
      map['user'] = _user.toJson();
    }
    if (_details != null) {
      map['details'] = _details.toJson();
    }
    if (_recommlist != null) {
      map['recommlist'] = _recommlist.map((v) => v.toJson()).toList();
    }
    return map;
  }

}

/// id : "5076"
/// title : "be natural+裴珠泫+白丝袜做爱"
/// face_img : "https://storage.googleapis.com/migutv/20ffd207c2a7b4fecdd30e84141892fe.png"
/// is_payfree : "1"
/// video_times : "00:02:36"
/// views : "28494"
/// create_time : "1648554905"
/// imgpath : "https://hbggkj2.com/upload/base64/20220329/20ffd207c2a7b4fecdd30e84141892fe.png"

class Recommlist {
  Recommlist({
      String id, 
      String title, 
      String faceImg, 
      String isPayfree, 
      String videoTimes, 
      String views, 
      String createTime, 
      String imgpath,}){
    _id = id;
    _title = title;
    _faceImg = faceImg;
    _isPayfree = isPayfree;
    _videoTimes = videoTimes;
    _views = views;
    _createTime = createTime;
    _imgpath = imgpath;
}

  Recommlist.fromJson(dynamic json) {
    _id = json['id'];
    _title = json['title'];
    _faceImg = json['face_img'];
    _isPayfree = json['is_payfree'];
    _videoTimes = json['video_times'];
    _views = json['views'];
    _createTime = json['create_time'];
    _imgpath = json['imgpath'];
  }
  String _id;
  String _title;
  String _faceImg;
  String _isPayfree;
  String _videoTimes;
  String _views;
  String _createTime;
  String _imgpath;

  String get id => _id;
  String get title => _title;
  String get faceImg => _faceImg;
  String get isPayfree => _isPayfree;
  String get videoTimes => _videoTimes;
  String get views => _views;
  String get createTime => _createTime;
  String get imgpath => _imgpath;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = _id;
    map['title'] = _title;
    map['face_img'] = _faceImg;
    map['is_payfree'] = _isPayfree;
    map['video_times'] = _videoTimes;
    map['views'] = _views;
    map['create_time'] = _createTime;
    map['imgpath'] = _imgpath;
    return map;
  }

}

/// id : "5075"
/// title : "2019年度韩国福布斯名人榜第十名+iu+运动袜"
/// face_img : "https://storage.googleapis.com/migutv/08cc1264329bbf89e0869836fc80f3d9.png"
/// video_url : ""
/// hclass_id : "3"
/// htheme_id : null
/// is_payfree : "1"
/// video_times : "00:00:55"
/// views : "29215"
/// create_time : "2022-03-29 19:53:46"
/// intro : null
/// imgpath : "https://hbggkj2.com/upload/base64/20220329/08cc1264329bbf89e0869836fc80f3d9.png"
/// m3u8_url : "https://hbggkj2.com/upload/admin/20220329/08cc1264329bbf89e0869836fc80f3d9/08cc1264329bbf89e0869836fc80f3d9.m3u8"
/// is_like : 0

class Details {
  Details({
      String id, 
      String title, 
      String faceImg, 
      String videoUrl, 
      String hclassId, 
      dynamic hthemeId, 
      String isPayfree, 
      String videoTimes, 
      String views, 
      String createTime, 
      dynamic intro, 
      String imgpath, 
      String m3u8Url, 
      int isLike,}){
    _id = id;
    _title = title;
    _faceImg = faceImg;
    _videoUrl = videoUrl;
    _hclassId = hclassId;
    _hthemeId = hthemeId;
    _isPayfree = isPayfree;
    _videoTimes = videoTimes;
    _views = views;
    _createTime = createTime;
    _intro = intro;
    _imgpath = imgpath;
    _m3u8Url = m3u8Url;
    _isLike = isLike;
}

  Details.fromJson(dynamic json) {
    _id = json['id'];
    _title = json['title'];
    _faceImg = json['face_img'];
    _videoUrl = json['video_url'];
    _hclassId = json['hclass_id'];
    _hthemeId = json['htheme_id'];
    _isPayfree = json['is_payfree'];
    _videoTimes = json['video_times'];
    _views = json['views'];
    _createTime = json['create_time'];
    _intro = json['intro'];
    _imgpath = json['imgpath'];
    _m3u8Url = json['m3u8_url'];
    _isLike = json['is_like'];
  }
  String _id;
  String _title;
  String _faceImg;
  String _videoUrl;
  String _hclassId;
  dynamic _hthemeId;
  String _isPayfree;
  String _videoTimes;
  String _views;
  String _createTime;
  dynamic _intro;
  String _imgpath;
  String _m3u8Url;
  int _isLike;

  String get id => _id;
  String get title => _title;
  String get faceImg => _faceImg;
  String get videoUrl => _videoUrl;
  String get hclassId => _hclassId;
  dynamic get hthemeId => _hthemeId;
  String get isPayfree => _isPayfree;
  String get videoTimes => _videoTimes;
  String get views => _views;
  String get createTime => _createTime;
  dynamic get intro => _intro;
  String get imgpath => _imgpath;
  String get m3u8Url => _m3u8Url;
  int get isLike => _isLike;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = _id;
    map['title'] = _title;
    map['face_img'] = _faceImg;
    map['video_url'] = _videoUrl;
    map['hclass_id'] = _hclassId;
    map['htheme_id'] = _hthemeId;
    map['is_payfree'] = _isPayfree;
    map['video_times'] = _videoTimes;
    map['views'] = _views;
    map['create_time'] = _createTime;
    map['intro'] = _intro;
    map['imgpath'] = _imgpath;
    map['m3u8_url'] = _m3u8Url;
    map['is_like'] = _isLike;
    return map;
  }

}

/// is_vip : 0
/// watch_times : 0

class User {
  User({
      int isVip, 
      int watchTimes,}){
    _isVip = isVip;
    _watchTimes = watchTimes;
}

  User.fromJson(dynamic json) {
    _isVip = json['is_vip'];
    _watchTimes = json['watch_times'];
  }
  int _isVip;
  int _watchTimes;

  int get isVip => _isVip;
  int get watchTimes => _watchTimes;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['is_vip'] = _isVip;
    map['watch_times'] = _watchTimes;
    return map;
  }

}