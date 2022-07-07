/// flag : "play"
/// encrypt : 0
/// trysee : 0
/// points : 0
/// link : "/vodplay/172769-1-1.html"
/// link_next : ""
/// link_pre : ""
/// url : "https://new.iskcd.com/20220406/48OvxJ23/index.m3u8"
/// url_next : ""
/// from : "wjm3u8"
/// server : "no"
/// note : ""
/// id : "172769"
/// sid : 1
/// nid : 1

class MovieDetail2 {
  MovieDetail2({
      String flag, 
      int encrypt, 
      int trysee, 
      int points, 
      String link, 
      String linkNext, 
      String linkPre, 
      String url, 
      String urlNext, 
      String from, 
      String server, 
      String note, 
      String id, 
      int sid, 
      int nid,}){
    _flag = flag;
    _encrypt = encrypt;
    _trysee = trysee;
    _points = points;
    _link = link;
    _linkNext = linkNext;
    _linkPre = linkPre;
    _url = url;
    _urlNext = urlNext;
    _from = from;
    _server = server;
    _note = note;
    _id = id;
    _sid = sid;
    _nid = nid;
}

  MovieDetail2.fromJson(dynamic json) {
    _flag = json['flag'];
    _encrypt = json['encrypt'];
    _trysee = json['trysee'];
    _points = json['points'];
    _link = json['link'];
    _linkNext = json['link_next'];
    _linkPre = json['link_pre'];
    _url = json['url'];
    _urlNext = json['url_next'];
    _from = json['from'];
    _server = json['server'];
    _note = json['note'];
    _id = json['id'];
    _sid = json['sid'];
    _nid = json['nid'];
  }
  String _flag;
  int _encrypt;
  int _trysee;
  int _points;
  String _link;
  String _linkNext;
  String _linkPre;
  String _url;
  String _urlNext;
  String _from;
  String _server;
  String _note;
  String _id;
  int _sid;
  int _nid;

  String get flag => _flag;
  int get encrypt => _encrypt;
  int get trysee => _trysee;
  int get points => _points;
  String get link => _link;
  String get linkNext => _linkNext;
  String get linkPre => _linkPre;
  String get url => _url;
  String get urlNext => _urlNext;
  String get from => _from;
  String get server => _server;
  String get note => _note;
  String get id => _id;
  int get sid => _sid;
  int get nid => _nid;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['flag'] = _flag;
    map['encrypt'] = _encrypt;
    map['trysee'] = _trysee;
    map['points'] = _points;
    map['link'] = _link;
    map['link_next'] = _linkNext;
    map['link_pre'] = _linkPre;
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