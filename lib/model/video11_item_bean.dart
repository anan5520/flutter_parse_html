/// code : 200
/// rescont : {"current_page":1,"data":[{"id":22465,"title":"【动漫】於是我就被叔叔給办了~ACNDP-001012","coverpath":"http://image.ytbohao.com/storage/hh/videocover/2021/12/06/16387636029999.jpeg","authername":"动漫人物","auther_no":"ACNDP-001012"},{"id":22464,"title":"【动漫】千鹤酱的开发日记~1~GLOD-00197","coverpath":"http://image.ytbohao.com/storage/hh/videocover/2021/12/06/163876352210000.jpeg","authername":"动漫人物","auther_no":"GLOD-00197"},{"id":22463,"title":"【动漫】家属～母与姐妹的娇声~3~ACPDP-01081","coverpath":"http://image.ytbohao.com/storage/hh/videocover/2021/12/06/16387634449999.jpeg","authername":"动漫人物","auther_no":"ACPDP-01081"},{"id":22462,"title":"【动漫】性爱上瘾费洛蒙中毒~2~2DM-350","coverpath":"http://image.ytbohao.com/storage/hh/videocover/2021/12/04/163858196810000.jpeg","authername":"动漫人物","auther_no":"2DM-350"},{"id":22251,"title":"【动漫】勇者大戰魔物娘~2~2DM-322","coverpath":"http://image.ytbohao.com/storage/hh/videocover/2021/11/25/16378045109999.jpeg","authername":"动漫人物","auther_no":"2DM-322"},{"id":22250,"title":"【动漫】勇者大戰魔物娘~1~2DM-321","coverpath":"http://image.ytbohao.com/storage/hh/videocover/2021/11/25/163780445010000.jpeg","authername":"动漫人物","auther_no":"2DM-321"},{"id":22249,"title":"【动漫】性爱上瘾费洛蒙中毒~1~2DM-349","coverpath":"http://image.ytbohao.com/storage/hh/videocover/2021/11/25/16378033009999.jpeg","authername":"动漫人物","auther_no":"2DM-349"},{"id":22125,"title":"【动漫】我的弥生小姐~02~2DM-324","coverpath":"http://image.ytbohao.com/storage/hh/videocover/2021/11/19/16372794369999.jpeg","authername":"动漫人物","auther_no":"2DM-324"},{"id":22124,"title":"【动漫】我的弥生小姐~01~2DM-323","coverpath":"http://image.ytbohao.com/storage/hh/videocover/2021/11/19/16372793639999.jpeg","authername":"动漫人物","auther_no":"2DM-323"},{"id":22123,"title":"【动漫】湿透的JO避雨强奸~02~2DM-313","coverpath":"http://image.ytbohao.com/storage/hh/videocover/2021/11/19/16372793019999.jpeg","authername":"动漫人物","auther_no":"2DM-313"},{"id":21917,"title":"【动漫】湿透的JO避雨强奸~01~2DM-312","coverpath":"http://image.ytbohao.com/storage/hh/videocover/2021/11/10/16365359829999.jpeg","authername":"动漫人物","auther_no":"2DM-312"},{"id":21898,"title":"【动漫】续公主和女骑士W下流露出~前篇~WBR-0109","coverpath":"http://image.ytbohao.com/storage/hh/videocover/2021/11/09/163643621510000.jpeg","authername":"动漫人物","auther_no":"WBR-0109"},{"id":21897,"title":"【动漫】小玉理香里酱PROJECT.3~决战！极致服务VS天堂服务~2DM-068","coverpath":"http://image.ytbohao.com/storage/hh/videocover/2021/11/09/163643601510000.jpeg","authername":"动漫人物","auther_no":"2DM-068"},{"id":21822,"title":"【动漫】小玉理香里酱PROJECT.1~诞生！爱与奉献的少女~2DM-066","coverpath":"http://image.ytbohao.com/storage/hh/videocover/2021/11/05/16360896949999.jpeg","authername":"动漫人物","auther_no":"2DM-066"},{"id":21821,"title":"【动漫】天使们的私人课程~核心MIX大超市哦~Support.3~2DM-331","coverpath":"http://image.ytbohao.com/storage/hh/videocover/2021/11/05/163608961810000.jpeg","authername":"动漫人物","auther_no":"2DM-331"}],"first_page_url":"http://fsfapermanentcosmeticartistry.com/api/videosort/14?page=1","from":1,"last_page":95,"last_page_url":"http://fsfapermanentcosmeticartistry.com/api/videosort/14?page=95","next_page_url":"http://fsfapermanentcosmeticartistry.com/api/videosort/14?page=2","path":"http://fsfapermanentcosmeticartistry.com/api/videosort/14","per_page":15,"prev_page_url":null,"to":15,"total":1425}
/// msg : ""

class Video11ItemBean {
  Video11ItemBean({
      int? code, 
      Rescont? rescont,
      String? msg,}){
    _code = code;
    _rescont = rescont;
    _msg = msg;
}

  Video11ItemBean.fromJson(dynamic json) {
    _code = json['code'];
    _rescont = json['rescont'] != null ? Rescont.fromJson(json['rescont']) : null;
    _msg = json['msg'];
  }
  int? _code;
  Rescont? _rescont;
  String? _msg;

  int? get code => _code;
  Rescont? get rescont => _rescont;
  String? get msg => _msg;

  Map<String?, dynamic> toJson() {
    final map = <String?, dynamic>{};
    map['code'] = _code;
    if (_rescont != null) {
      map['rescont'] = _rescont!.toJson();
    }
    map['msg'] = _msg;
    return map;
  }

}

/// current_page : 1
/// data : [{"id":22465,"title":"【动漫】於是我就被叔叔給办了~ACNDP-001012","coverpath":"http://image.ytbohao.com/storage/hh/videocover/2021/12/06/16387636029999.jpeg","authername":"动漫人物","auther_no":"ACNDP-001012"},{"id":22464,"title":"【动漫】千鹤酱的开发日记~1~GLOD-00197","coverpath":"http://image.ytbohao.com/storage/hh/videocover/2021/12/06/163876352210000.jpeg","authername":"动漫人物","auther_no":"GLOD-00197"},{"id":22463,"title":"【动漫】家属～母与姐妹的娇声~3~ACPDP-01081","coverpath":"http://image.ytbohao.com/storage/hh/videocover/2021/12/06/16387634449999.jpeg","authername":"动漫人物","auther_no":"ACPDP-01081"},{"id":22462,"title":"【动漫】性爱上瘾费洛蒙中毒~2~2DM-350","coverpath":"http://image.ytbohao.com/storage/hh/videocover/2021/12/04/163858196810000.jpeg","authername":"动漫人物","auther_no":"2DM-350"},{"id":22251,"title":"【动漫】勇者大戰魔物娘~2~2DM-322","coverpath":"http://image.ytbohao.com/storage/hh/videocover/2021/11/25/16378045109999.jpeg","authername":"动漫人物","auther_no":"2DM-322"},{"id":22250,"title":"【动漫】勇者大戰魔物娘~1~2DM-321","coverpath":"http://image.ytbohao.com/storage/hh/videocover/2021/11/25/163780445010000.jpeg","authername":"动漫人物","auther_no":"2DM-321"},{"id":22249,"title":"【动漫】性爱上瘾费洛蒙中毒~1~2DM-349","coverpath":"http://image.ytbohao.com/storage/hh/videocover/2021/11/25/16378033009999.jpeg","authername":"动漫人物","auther_no":"2DM-349"},{"id":22125,"title":"【动漫】我的弥生小姐~02~2DM-324","coverpath":"http://image.ytbohao.com/storage/hh/videocover/2021/11/19/16372794369999.jpeg","authername":"动漫人物","auther_no":"2DM-324"},{"id":22124,"title":"【动漫】我的弥生小姐~01~2DM-323","coverpath":"http://image.ytbohao.com/storage/hh/videocover/2021/11/19/16372793639999.jpeg","authername":"动漫人物","auther_no":"2DM-323"},{"id":22123,"title":"【动漫】湿透的JO避雨强奸~02~2DM-313","coverpath":"http://image.ytbohao.com/storage/hh/videocover/2021/11/19/16372793019999.jpeg","authername":"动漫人物","auther_no":"2DM-313"},{"id":21917,"title":"【动漫】湿透的JO避雨强奸~01~2DM-312","coverpath":"http://image.ytbohao.com/storage/hh/videocover/2021/11/10/16365359829999.jpeg","authername":"动漫人物","auther_no":"2DM-312"},{"id":21898,"title":"【动漫】续公主和女骑士W下流露出~前篇~WBR-0109","coverpath":"http://image.ytbohao.com/storage/hh/videocover/2021/11/09/163643621510000.jpeg","authername":"动漫人物","auther_no":"WBR-0109"},{"id":21897,"title":"【动漫】小玉理香里酱PROJECT.3~决战！极致服务VS天堂服务~2DM-068","coverpath":"http://image.ytbohao.com/storage/hh/videocover/2021/11/09/163643601510000.jpeg","authername":"动漫人物","auther_no":"2DM-068"},{"id":21822,"title":"【动漫】小玉理香里酱PROJECT.1~诞生！爱与奉献的少女~2DM-066","coverpath":"http://image.ytbohao.com/storage/hh/videocover/2021/11/05/16360896949999.jpeg","authername":"动漫人物","auther_no":"2DM-066"},{"id":21821,"title":"【动漫】天使们的私人课程~核心MIX大超市哦~Support.3~2DM-331","coverpath":"http://image.ytbohao.com/storage/hh/videocover/2021/11/05/163608961810000.jpeg","authername":"动漫人物","auther_no":"2DM-331"}]
/// first_page_url : "http://fsfapermanentcosmeticartistry.com/api/videosort/14?page=1"
/// from : 1
/// last_page : 95
/// last_page_url : "http://fsfapermanentcosmeticartistry.com/api/videosort/14?page=95"
/// next_page_url : "http://fsfapermanentcosmeticartistry.com/api/videosort/14?page=2"
/// path : "http://fsfapermanentcosmeticartistry.com/api/videosort/14"
/// per_page : 15
/// prev_page_url : null
/// to : 15
/// total : 1425

class Rescont {
  Rescont({
      int? currentPage, 
      List<Data>? data,
      String? firstPageUrl, 
      int? from, 
      int? lastPage, 
      String? lastPageUrl, 
      String? nextPageUrl, 
      String? path, 
      int? perPage, 
      dynamic prevPageUrl, 
      int? to, 
      int? total,}){
    _currentPage = currentPage;
    _data = data;
    _firstPageUrl = firstPageUrl;
    _from = from;
    _lastPage = lastPage;
    _lastPageUrl = lastPageUrl;
    _nextPageUrl = nextPageUrl;
    _path = path;
    _perPage = perPage;
    _prevPageUrl = prevPageUrl;
    _to = to;
    _total = total;
}

  Rescont.fromJson(dynamic json) {
    _currentPage = json['current_page'];
    if (json['data'] != null) {
      _data = [];
      json['data'].forEach((v) {
        _data!.add(Data.fromJson(v));
      });
    }
    _firstPageUrl = json['first_page_url'];
    _from = json['from'];
    _lastPage = json['last_page'];
    _lastPageUrl = json['last_page_url'];
    _nextPageUrl = json['next_page_url'];
    _path = json['path'];
    _perPage = json['per_page'];
    _prevPageUrl = json['prev_page_url'];
    _to = json['to'];
    _total = json['total'];
  }
  int? _currentPage;
  List<Data>? _data;
  String? _firstPageUrl;
  int? _from;
  int? _lastPage;
  String? _lastPageUrl;
  String? _nextPageUrl;
  String? _path;
  int? _perPage;
  dynamic _prevPageUrl;
  int? _to;
  int? _total;

  int? get currentPage => _currentPage;
  List<Data>? get data => _data;
  String? get firstPageUrl => _firstPageUrl;
  int? get from => _from;
  int? get lastPage => _lastPage;
  String? get lastPageUrl => _lastPageUrl;
  String? get nextPageUrl => _nextPageUrl;
  String? get path => _path;
  int? get perPage => _perPage;
  dynamic get prevPageUrl => _prevPageUrl;
  int? get to => _to;
  int? get total => _total;

  Map<String?, dynamic> toJson() {
    final map = <String?, dynamic>{};
    map['current_page'] = _currentPage;
    if (_data != null) {
      map['data'] = _data!.map((v) => v.toJson()).toList();
    }
    map['first_page_url'] = _firstPageUrl;
    map['from'] = _from;
    map['last_page'] = _lastPage;
    map['last_page_url'] = _lastPageUrl;
    map['next_page_url'] = _nextPageUrl;
    map['path'] = _path;
    map['per_page'] = _perPage;
    map['prev_page_url'] = _prevPageUrl;
    map['to'] = _to;
    map['total'] = _total;
    return map;
  }

}

/// id : 22465
/// title : "【动漫】於是我就被叔叔給办了~ACNDP-001012"
/// coverpath : "http://image.ytbohao.com/storage/hh/videocover/2021/12/06/16387636029999.jpeg"
/// authername : "动漫人物"
/// auther_no : "ACNDP-001012"

class Data {
  Data({
      int? id, 
      String? title, 
      String? coverpath, 
      String? authername, 
      String? autherNo,}){
    _id = id;
    _title = title;
    _coverpath = coverpath;
    _authername = authername;
    _autherNo = autherNo;
}

  Data.fromJson(dynamic json) {
    _id = json['id'];
    _title = json['title'];
    _coverpath = json['coverpath'];
    _authername = json['authername'];
    _autherNo = json['auther_no'];
  }
  int? _id;
  String? _title;
  String? _coverpath;
  String? _authername;
  String? _autherNo;

  int? get id => _id;
  String? get title => _title;
  String? get coverpath => _coverpath;
  String? get authername => _authername;
  String? get autherNo => _autherNo;

  Map<String?, dynamic> toJson() {
    final map = <String?, dynamic>{};
    map['id'] = _id;
    map['title'] = _title;
    map['coverpath'] = _coverpath;
    map['authername'] = _authername;
    map['auther_no'] = _autherNo;
    return map;
  }

}

class Video11PlayBean {
  int? code;
  Rescont1? rescont;
  String? msg;

  Video11PlayBean({this.code, this.rescont, this.msg});

  Video11PlayBean.fromJson(Map<String?, dynamic> json) {
    code = json['code'];
    rescont =
    json['rescont'] != null ? new Rescont1.fromJson(json['rescont']) : null;
    msg = json['msg'];
  }

  Map<String?, dynamic> toJson() {
    final Map<String?, dynamic> data = new Map<String?, dynamic>();
    data['code'] = this.code;
    if (this.rescont != null) {
      data['rescont'] = this.rescont!.toJson();
    }
    data['msg'] = this.msg;
    return data;
  }
}

class Rescont1 {
  String? videopath;

  Rescont1({this.videopath});

  Rescont1.fromJson(Map<String?, dynamic> json) {
    videopath = json['videopath'];
  }

  Map<String?, dynamic> toJson() {
    final Map<String?, dynamic> data = new Map<String?, dynamic>();
    data['videopath'] = this.videopath;
    return data;
  }
}
