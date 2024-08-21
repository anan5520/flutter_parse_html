/// code : 200
/// rescont : [{"id":10,"name":"国产精品","icopath":"http://image.ytbohao.com/storage/xkd/sysico/3c15b7f9d33c0c9a9c98ad3c4d8b09da.png","order":1},{"id":9,"name":"绝色佳人","icopath":"http://image.ytbohao.com/storage/xkd/sysico/a6649bf7cb96d98097014784d03ca709.png","order":2},{"id":53,"name":"网红主播","icopath":"http://image.ytbohao.com/storage/hh/sysico/2021/03/12/161552571310000.png","order":3},{"id":51,"name":"国产AV","icopath":"http://image.ytbohao.com/storage/xkd/sysico/2020/08/27/15985097849999.png","order":4},{"id":14,"name":"H动漫","icopath":"http://image.ytbohao.com/storage/xkd/sysico/746d66b33fedff7f3f422a1b2e99cd38.png","order":6},{"id":46,"name":"师生不伦","icopath":"http://image.ytbohao.com/storage/xkd/sysico/2020/08/18/159772019410000.png","order":7},{"id":44,"name":"痴汉轮奸","icopath":"http://image.ytbohao.com/storage/xkd/sysico/2020/08/17/15976657839999.png","order":8},{"id":37,"name":"制服丝袜","icopath":"http://image.ytbohao.com/storage/xkd/sysico/2020/08/17/15976553199999.png","order":9},{"id":41,"name":"高清无码","icopath":"http://image.ytbohao.com/storage/xkd/sysico/2020/08/17/15976601469999.png","order":10},{"id":25,"name":"三级电影","icopath":"http://image.ytbohao.com/storage/xkd/sysico/076ee88c4030f6513d6687cc954989a0.png","order":11},{"id":16,"name":"欧美激情","icopath":"http://image.ytbohao.com/storage/xkd/sysico/1e9b12880d670a5768a7e3493184d617.png","order":12},{"id":38,"name":"风俗按摩","icopath":"http://image.ytbohao.com/storage/xkd/sysico/2020/08/17/15976558869999.png","order":13},{"id":40,"name":"美乳巨乳","icopath":"http://image.ytbohao.com/storage/xkd/sysico/2020/08/17/15976599479999.png","order":14},{"id":47,"name":"绝顶痉挛","icopath":"http://image.ytbohao.com/storage/xkd/sysico/2020/08/20/159789943110000.png","order":15},{"id":54,"name":"AV解说","icopath":"http://image.ytbohao.com/storage/hh/sysico/2021/03/12/16155257279999.png","order":15},{"id":42,"name":"少女萝莉","icopath":"http://image.ytbohao.com/storage/xkd/sysico/2020/08/17/159766040010000.png","order":16},{"id":35,"name":"人妻熟女","icopath":"http://image.ytbohao.com/storage/xkd/sysico/2020/08/24/159824740910000.png","order":17},{"id":36,"name":"淫欲痴女","icopath":"http://image.ytbohao.com/storage/xkd/sysico/2020/08/17/159765511810000.png","order":17},{"id":39,"name":"AV剧情","icopath":"http://image.ytbohao.com/storage/xkd/sysico/2020/08/17/159765598710000.png","order":18},{"id":55,"name":"恐怖系列","icopath":"http://image.ytbohao.com/storage/hh/sysico/2021/03/12/161552573910000.png","order":18},{"id":43,"name":"家庭乱伦","icopath":"http://image.ytbohao.com/storage/xkd/sysico/2020/08/17/15976628499999.png","order":20},{"id":50,"name":"女同性爱","icopath":"http://image.ytbohao.com/storage/xkd/sysico/2020/08/24/15982586249999.png","order":20}]
/// msg : ""

class Video11Bean {
  Video11Bean({
      int? code,
      List<Rescont>? rescont,
      String? msg,}){
    _code = code;
    _rescont = rescont;
    _msg = msg;
}

  Video11Bean.fromJson(dynamic json) {
    _code = json['code'];
    if (json['rescont'] != null) {
      _rescont = [];
      json['rescont'].forEach((v) {
        _rescont!.add(Rescont.fromJson(v));
      });
    }
    _msg = json['msg'];
  }
  int? _code;
  List<Rescont>? _rescont;
  String? _msg;

  int? get code => _code;
  List<Rescont>? get rescont => _rescont;
  String? get msg => _msg;

  Map<String?, dynamic> toJson() {
    final map = <String?, dynamic>{};
    map['code'] = _code;
    if (_rescont != null) {
      map['rescont'] = _rescont!.map((v) => v.toJson()).toList();
    }
    map['msg'] = _msg;
    return map;
  }

}

/// id : 10
/// name : "国产精品"
/// icopath : "http://image.ytbohao.com/storage/xkd/sysico/3c15b7f9d33c0c9a9c98ad3c4d8b09da.png"
/// order : 1

class Rescont {
  Rescont({
      int? id,
      String? name,
      String? icopath,
      int? order,}){
    _id = id;
    _name = name;
    _icopath = icopath;
    _order = order;
}

  Rescont.fromJson(dynamic json) {
    _id = json['id'];
    _name = json['name'];
    _icopath = json['icopath'];
    _order = json['order'];
  }
  int? _id;
  String? _name;
  String? _icopath;
  int? _order;

  int? get id => _id;
  String? get name => _name;
  String? get icopath => _icopath;
  int? get order => _order;

  Map<String?, dynamic> toJson() {
    final map = <String?, dynamic>{};
    map['id'] = _id;
    map['name'] = _name;
    map['icopath'] = _icopath;
    map['order'] = _order;
    return map;
  }

}