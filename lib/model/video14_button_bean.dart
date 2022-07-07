/// ret : 200
/// data : {"code":0,"msg":"","info":[{"id":-2,"name":"最新"},{"id":"11","name":"主播"},{"id":"1","name":"亚洲"},{"id":"13","name":"欧美"},{"id":"3","name":"自拍"},{"id":"12","name":"日本"}]}
/// msg : ""

class Video14ButtonBean {
  Video14ButtonBean({
      int ret, 
      Data data, 
      String msg,}){
    _ret = ret;
    _data = data;
    _msg = msg;
}

  Video14ButtonBean.fromJson(dynamic json) {
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
/// info : [{"id":-2,"name":"最新"},{"id":"11","name":"主播"},{"id":"1","name":"亚洲"},{"id":"13","name":"欧美"},{"id":"3","name":"自拍"},{"id":"12","name":"日本"}]

class Data {
  Data({
      int code, 
      String msg, 
      List<Info> info,}){
    _code = code;
    _msg = msg;
    _info = info;
}

  Data.fromJson(dynamic json) {
    _code = json['code'];
    _msg = json['msg'];
    if (json['info'] != null) {
      _info = [];
      json['info'].forEach((v) {
        _info.add(Info.fromJson(v));
      });
    }
  }
  int _code;
  String _msg;
  List<Info> _info;

  int get code => _code;
  String get msg => _msg;
  List<Info> get info => _info;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['code'] = _code;
    map['msg'] = _msg;
    if (_info != null) {
      map['info'] = _info.map((v) => v.toJson()).toList();
    }
    return map;
  }

}

/// id : -2
/// name : "最新"

class Info {
  Info({
    String id,
      String name,}){
    _id = id;
    _name = name;
}

  Info.fromJson(dynamic json) {
    _id = json['id'];
    _name = json['name'];
  }
  String _id;
  String _name;

  String get id => _id;
  String get name => _name;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = _id;
    map['name'] = _name;
    return map;
  }

}