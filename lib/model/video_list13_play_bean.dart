/// retcode : 0
/// errmsg : "游客权限范围内免费播放"
/// data : {"xxx_api_auth":"6263396536316266613737313563363235623365333533663064393665363062","isfavorite":0,"iszan":0,"encurl":0,"httpurl":"https://v9.meitull.com/20211205/20210829/index.m3u8","httpurls":[{"hdtype":"默认","httpurl":"https://v9.meitull.com/20211205/20210829/index.m3u8"}]}

class VideoList13PlayBean {
  VideoList13PlayBean({
      int retcode, 
      String errmsg, 
      Data data,}){
    _retcode = retcode;
    _errmsg = errmsg;
    _data = data;
}

  VideoList13PlayBean.fromJson(dynamic json) {
    _retcode = json['retcode'];
    _errmsg = json['errmsg'];
    _data = json['data'] != null ? Data.fromJson(json['data']) : null;
  }
  int _retcode;
  String _errmsg;
  Data _data;

  int get retcode => _retcode;
  String get errmsg => _errmsg;
  Data get data => _data;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['retcode'] = _retcode;
    map['errmsg'] = _errmsg;
    if (_data != null) {
      map['data'] = _data.toJson();
    }
    return map;
  }

}

/// xxx_api_auth : "6263396536316266613737313563363235623365333533663064393665363062"
/// isfavorite : 0
/// iszan : 0
/// encurl : 0
/// httpurl : "https://v9.meitull.com/20211205/20210829/index.m3u8"
/// httpurls : [{"hdtype":"默认","httpurl":"https://v9.meitull.com/20211205/20210829/index.m3u8"}]

class Data {
  Data({
      String xxxApiAuth, 
      int isfavorite, 
      int iszan, 
      int encurl, 
      String httpurl, 
      List<Httpurls> httpurls,}){
    _xxxApiAuth = xxxApiAuth;
    _isfavorite = isfavorite;
    _iszan = iszan;
    _encurl = encurl;
    _httpurl = httpurl;
    _httpurls = httpurls;
}

  Data.fromJson(dynamic json) {
    _xxxApiAuth = json['xxx_api_auth'];
    _isfavorite = json['isfavorite'];
    _iszan = json['iszan'];
    _encurl = json['encurl'];
    _httpurl = json['httpurl'];
    if (json['httpurls'] != null) {
      _httpurls = [];
      json['httpurls'].forEach((v) {
        _httpurls.add(Httpurls.fromJson(v));
      });
    }
  }
  String _xxxApiAuth;
  int _isfavorite;
  int _iszan;
  int _encurl;
  String _httpurl;
  List<Httpurls> _httpurls;

  String get xxxApiAuth => _xxxApiAuth;
  int get isfavorite => _isfavorite;
  int get iszan => _iszan;
  int get encurl => _encurl;
  String get httpurl => _httpurl;
  List<Httpurls> get httpurls => _httpurls;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['xxx_api_auth'] = _xxxApiAuth;
    map['isfavorite'] = _isfavorite;
    map['iszan'] = _iszan;
    map['encurl'] = _encurl;
    map['httpurl'] = _httpurl;
    if (_httpurls != null) {
      map['httpurls'] = _httpurls.map((v) => v.toJson()).toList();
    }
    return map;
  }

}

/// hdtype : "默认"
/// httpurl : "https://v9.meitull.com/20211205/20210829/index.m3u8"

class Httpurls {
  Httpurls({
      String hdtype, 
      String httpurl,}){
    _hdtype = hdtype;
    _httpurl = httpurl;
}

  Httpurls.fromJson(dynamic json) {
    _hdtype = json['hdtype'];
    _httpurl = json['httpurl'];
  }
  String _hdtype;
  String _httpurl;

  String get hdtype => _hdtype;
  String get httpurl => _httpurl;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['hdtype'] = _hdtype;
    map['httpurl'] = _httpurl;
    return map;
  }

}