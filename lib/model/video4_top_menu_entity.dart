/// classid : 1
/// classname : "国产"
/// classpath : "video"
/// classurl : ""
/// classimg : ""
/// bname : "国产"
/// tbname : "movie"
/// dtlisttempid : 9
/// listtempid : 9
/// islast : 0
/// sonclass : "|4|5|6|7|8|9|38|39|59|60|64|119|139|141|142|157|"
/// items : [{"classid":4,"classname":"自拍视频","classpath":"video/zipai","classurl":"","classimg":"","bname":"自拍视频","tbname":"movie","dtlisttempid":9,"listtempid":9,"islast":1,"sonclass":""},{"classid":5,"classname":"淫妻作乐","classpath":"video/fuqi","classurl":"","classimg":"","bname":"淫妻作乐","tbname":"movie","dtlisttempid":9,"listtempid":9,"islast":1,"sonclass":""},{"classid":142,"classname":"热门探花","classpath":"video/th","classurl":"","classimg":"","bname":"热门探花","tbname":"movie","dtlisttempid":17,"listtempid":17,"islast":1,"sonclass":""},{"classid":64,"classname":"国产传媒","classpath":"video/html64","classurl":"","classimg":"","bname":"国产传媒","tbname":"movie","dtlisttempid":9,"listtempid":9,"islast":1,"sonclass":""},{"classid":6,"classname":"开放青年","classpath":"video/kaifang","classurl":"","classimg":"","bname":"开放青年","tbname":"movie","dtlisttempid":9,"listtempid":9,"islast":1,"sonclass":""},{"classid":119,"classname":"JVID专区","classpath":"video/jvid","classurl":"","classimg":"","bname":"JVID专区","tbname":"movie","dtlisttempid":9,"listtempid":9,"islast":1,"sonclass":""},{"classid":139,"classname":"SWAG专区","classpath":"video/swg","classurl":"","classimg":"","bname":"sawg专区","tbname":"movie","dtlisttempid":9,"listtempid":9,"islast":1,"sonclass":""},{"classid":60,"classname":"直播录屏","classpath":"video/zbth","classurl":"","classimg":"","bname":"直播录屏","tbname":"movie","dtlisttempid":9,"listtempid":9,"islast":1,"sonclass":""}]

class Video4TopMenuEntity {
  Video4TopMenuEntity({
      String? classid,
      String? classname, 
      String? classpath, 
      String? classurl, 
      String? classimg, 
      String? bname, 
      String? tbname, 
      int? dtlisttempid, 
      int? listtempid, 
      int? islast, 
      String? sonclass, 
      List<Items>? items,}){
    _classid = classid;
    _classname = classname;
    _classpath = classpath;
    _classurl = classurl;
    _classimg = classimg;
    _bname = bname;
    _tbname = tbname;
    _dtlisttempid = dtlisttempid;
    _listtempid = listtempid;
    _islast = islast;
    _sonclass = sonclass;
    _items = items;
}

  Video4TopMenuEntity.fromJson(dynamic json) {
    _classid = json['classid']?.toString()??'';
    _classname = json['classname'];
    _classpath = json['classpath'];
    _classurl = json['classurl'];
    _classimg = json['classimg'];
    _bname = json['bname'];
    _tbname = json['tbname'];
    _dtlisttempid = json['dtlisttempid'];
    _listtempid = json['listtempid'];
    _islast = json['islast'];
    _sonclass = json['sonclass'];
    if (json['items'] != null) {
      _items = [];
      json['items'].forEach((v) {
        _items?.add(Items.fromJson(v));
      });
    }
  }
  String? _classid;
  String? _classname;
  String? _classpath;
  String? _classurl;
  String? _classimg;
  String? _bname;
  String? _tbname;
  int? _dtlisttempid;
  int? _listtempid;
  int? _islast;
  String? _sonclass;
  List<Items>? _items;
Video4TopMenuEntity copyWith({  String? classid,
  String? classname,
  String? classpath,
  String? classurl,
  String? classimg,
  String? bname,
  String? tbname,
  int? dtlisttempid,
  int? listtempid,
  int? islast,
  String? sonclass,
  List<Items>? items,
}) => Video4TopMenuEntity(  classid: classid ?? _classid,
  classname: classname ?? _classname,
  classpath: classpath ?? _classpath,
  classurl: classurl ?? _classurl,
  classimg: classimg ?? _classimg,
  bname: bname ?? _bname,
  tbname: tbname ?? _tbname,
  dtlisttempid: dtlisttempid ?? _dtlisttempid,
  listtempid: listtempid ?? _listtempid,
  islast: islast ?? _islast,
  sonclass: sonclass ?? _sonclass,
  items: items ?? _items,
);
  String? get classid => _classid;
  String? get classname => _classname;
  String? get classpath => _classpath;
  String? get classurl => _classurl;
  String? get classimg => _classimg;
  String? get bname => _bname;
  String? get tbname => _tbname;
  int? get dtlisttempid => _dtlisttempid;
  int? get listtempid => _listtempid;
  int? get islast => _islast;
  String? get sonclass => _sonclass;
  List<Items>? get items => _items;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['classid'] = _classid;
    map['classname'] = _classname;
    map['classpath'] = _classpath;
    map['classurl'] = _classurl;
    map['classimg'] = _classimg;
    map['bname'] = _bname;
    map['tbname'] = _tbname;
    map['dtlisttempid'] = _dtlisttempid;
    map['listtempid'] = _listtempid;
    map['islast'] = _islast;
    map['sonclass'] = _sonclass;
    if (_items != null) {
      map['items'] = _items?.map((v) => v.toJson()).toList();
    }
    return map;
  }

}

/// classid : 4
/// classname : "自拍视频"
/// classpath : "video/zipai"
/// classurl : ""
/// classimg : ""
/// bname : "自拍视频"
/// tbname : "movie"
/// dtlisttempid : 9
/// listtempid : 9
/// islast : 1
/// sonclass : ""

class Items {
  Items({
      int? classid, 
      String? classname, 
      String? classpath, 
      String? classurl, 
      String? classimg, 
      String? bname, 
      String? tbname, 
      int? dtlisttempid, 
      int? listtempid, 
      int? islast, 
      String? sonclass,}){
    _classid = classid;
    _classname = classname;
    _classpath = classpath;
    _classurl = classurl;
    _classimg = classimg;
    _bname = bname;
    _tbname = tbname;
    _dtlisttempid = dtlisttempid;
    _listtempid = listtempid;
    _islast = islast;
    _sonclass = sonclass;
}

  Items.fromJson(dynamic json) {
    _classid = json['classid'];
    _classname = json['classname'];
    _classpath = json['classpath'];
    _classurl = json['classurl'];
    _classimg = json['classimg'];
    _bname = json['bname'];
    _tbname = json['tbname'];
    _dtlisttempid = json['dtlisttempid'];
    _listtempid = json['listtempid'];
    _islast = json['islast'];
    _sonclass = json['sonclass'];
  }
  int? _classid;
  String? _classname;
  String? _classpath;
  String? _classurl;
  String? _classimg;
  String? _bname;
  String? _tbname;
  int? _dtlisttempid;
  int? _listtempid;
  int? _islast;
  String? _sonclass;
Items copyWith({  int? classid,
  String? classname,
  String? classpath,
  String? classurl,
  String? classimg,
  String? bname,
  String? tbname,
  int? dtlisttempid,
  int? listtempid,
  int? islast,
  String? sonclass,
}) => Items(  classid: classid ?? _classid,
  classname: classname ?? _classname,
  classpath: classpath ?? _classpath,
  classurl: classurl ?? _classurl,
  classimg: classimg ?? _classimg,
  bname: bname ?? _bname,
  tbname: tbname ?? _tbname,
  dtlisttempid: dtlisttempid ?? _dtlisttempid,
  listtempid: listtempid ?? _listtempid,
  islast: islast ?? _islast,
  sonclass: sonclass ?? _sonclass,
);
  int? get classid => _classid;
  String? get classname => _classname;
  String? get classpath => _classpath;
  String? get classurl => _classurl;
  String? get classimg => _classimg;
  String? get bname => _bname;
  String? get tbname => _tbname;
  int? get dtlisttempid => _dtlisttempid;
  int? get listtempid => _listtempid;
  int? get islast => _islast;
  String? get sonclass => _sonclass;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['classid'] = _classid;
    map['classname'] = _classname;
    map['classpath'] = _classpath;
    map['classurl'] = _classurl;
    map['classimg'] = _classimg;
    map['bname'] = _bname;
    map['tbname'] = _tbname;
    map['dtlisttempid'] = _dtlisttempid;
    map['listtempid'] = _listtempid;
    map['islast'] = _islast;
    map['sonclass'] = _sonclass;
    return map;
  }

}