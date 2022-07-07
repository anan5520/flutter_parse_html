


class MovieBean{
  String name;
  String imgUrl;
  String playUrl;
  String info;
  String des = '';
  String originUrl;
  String number;
  bool isM3u8 = false;
  List<MovieItemBean> list;


  @override
  String toString() {
    return 'MovieBean{name: $name, imgUrl: $imgUrl, playUrl: $playUrl, info: $info, des: $des, list: $list}';
  }


}

class MovieItemBean{
  String name;
  String targetUrl;

  @override
  String toString() {
    return 'MovieItemBean{name: $name, targetUrl: $targetUrl}';
  }

}

class GifItemBean{
  String name;
  String targetUrl;
  String imageUrl;
  GifType gifType;


}

enum GifType{
 gif1,gif2,gift3

}


class MaHuaMovieList {
  int code;
  String msg;
  int page;
  int pagecount;
  int limit;
  int total;
  List<Item> list;
  List<Type> type;

  MaHuaMovieList({this.code, this.msg, this.page, this.pagecount, this.limit, this.total, this.list, this.type});

  MaHuaMovieList.fromJson(Map<String, dynamic> json) {
  code = json['code'];
  msg = json['msg'];
  page = json['page'];
  pagecount = json['pagecount'];
  limit = json['limit'];
  total = json['total'];
  if (json['list'] != null) {
  list = new List<Item>();
  json['list'].forEach((v) {
    list.add(new Item.fromJson(v)); });
  }
  if (json['class'] != null) {
  type = new List<Type>();
  json['class'].forEach((v) { type.add(new Type.fromJson(v)); });
  }
  }

  Map<String, dynamic> toJson() {
  final Map<String, dynamic> data = new Map<String, dynamic>();
  data['code'] = this.code;
  data['msg'] = this.msg;
  data['page'] = this.page;
  data['pagecount'] = this.pagecount;
  data['limit'] = this.limit;
  data['total'] = this.total;
  if (this.list != null) {
  data['list'] = this.list.map((v) => v.toJson()).toList();
  }
  if (this.type != null) {
  data['class'] = this.type.map((v) => v.toJson()).toList();
  }
  return data;
  }
}

class Item {
  String vodId;
  String vodName;
  String typeId;
  String typeName;
  String vodEn;
  String vodTime;
  String vodRemarks;
  String vodPlayFrom;

  Item({this.vodId, this.vodName, this.typeId, this.typeName, this.vodEn, this.vodTime, this.vodRemarks, this.vodPlayFrom});

  Item.fromJson(Map<String, dynamic> json) {
    vodId = json['vod_id'];
    vodName = json['vod_name'];
    typeId = json['type_id'];
    typeName = json['type_name'];
    vodEn = json['vod_en'];
    vodTime = json['vod_time'];
    vodRemarks = json['vod_remarks'];
    vodPlayFrom = json['vod_play_from'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['vod_id'] = this.vodId;
    data['vod_name'] = this.vodName;
    data['type_id'] = this.typeId;
    data['type_name'] = this.typeName;
    data['vod_en'] = this.vodEn;
    data['vod_time'] = this.vodTime;
    data['vod_remarks'] = this.vodRemarks;
    data['vod_play_from'] = this.vodPlayFrom;
    return data;
  }
}

class Type {
  String typeId;
  String typeName;

  Type({this.typeId, this.typeName});

  Type.fromJson(Map<String, dynamic> json) {
    typeId = json['type_id'];
    typeName = json['type_name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['type_id'] = this.typeId;
    data['type_name'] = this.typeName;
    return data;
  }
}

class MaHuaMovieDetail {
  int code;
  String msg;
  int page;
  int pagecount;
  int limit;
  int total;
  List<DetailItem> list;

  MaHuaMovieDetail(
      {this.code,
        this.msg,
        this.page,
        this.pagecount,
        this.limit,
        this.total,
        this.list});

  MaHuaMovieDetail.fromJson(Map<String, dynamic> json) {
    code = json['code'];
    msg = json['msg'];
    page = json['page'];
    pagecount = json['pagecount'];
    limit = json['limit'];
    total = json['total'];
    if (json['list'] != null) {
      list = new List<DetailItem>();
      json['list'].forEach((v) {
        list.add(new DetailItem.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['code'] = this.code;
    data['msg'] = this.msg;
    data['page'] = this.page;
    data['pagecount'] = this.pagecount;
    data['limit'] = this.limit;
    data['total'] = this.total;
    if (this.list != null) {
      data['list'] = this.list.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class DetailItem {
  String vodTime;
  String vodId;
  String vodName;
  String vodEnname;
  String vodSubname;
  String vodLetter;
  String vodColor;
  String vodTag;
  String typeId;
  String typeName;
  String vodPic;
  String vodLang;
  String vodArea;
  String vodYear;
  String vodRemark;
  String vodActor;
  String vodDirector;
  String vodSerial;
  String vodLock;
  String vodLevel;
  String vodHits;
  String vodHitsDay;
  String vodHitsWeek;
  String vodHitsMonth;
  String vodDuration;
  String vodUp;
  String vodDown;
  String vodScore;
  String vodScoreAll;
  String vodScoreNum;
  String vodPointsPlay;
  String vodPointsDown;
  String vodContent;
  String vodPlayFrom;
  String vodPlayNote;
  String vodPlayServer;
  String vodPlayUrl;
  String vodDownFrom;
  String vodDownNote;
  String vodDownServer;
  String vodDownUrl;

  DetailItem(
      {this.vodTime,
        this.vodId,
        this.vodName,
        this.vodEnname,
        this.vodSubname,
        this.vodLetter,
        this.vodColor,
        this.vodTag,
        this.typeId,
        this.typeName,
        this.vodPic,
        this.vodLang,
        this.vodArea,
        this.vodYear,
        this.vodRemark,
        this.vodActor,
        this.vodDirector,
        this.vodSerial,
        this.vodLock,
        this.vodLevel,
        this.vodHits,
        this.vodHitsDay,
        this.vodHitsWeek,
        this.vodHitsMonth,
        this.vodDuration,
        this.vodUp,
        this.vodDown,
        this.vodScore,
        this.vodScoreAll,
        this.vodScoreNum,
        this.vodPointsPlay,
        this.vodPointsDown,
        this.vodContent,
        this.vodPlayFrom,
        this.vodPlayNote,
        this.vodPlayServer,
        this.vodPlayUrl,
        this.vodDownFrom,
        this.vodDownNote,
        this.vodDownServer,
        this.vodDownUrl});

  DetailItem.fromJson(Map<String, dynamic> json) {
    vodTime = json['vod_time'];
    vodId = json['vod_id'];
    vodName = json['vod_name'];
    vodEnname = json['vod_enname'];
    vodSubname = json['vod_subname'];
    vodLetter = json['vod_letter'];
    vodColor = json['vod_color'];
    vodTag = json['vod_tag'];
    typeId = json['type_id'];
    typeName = json['type_name'];
    vodPic = json['vod_pic'];
    vodLang = json['vod_lang'];
    vodArea = json['vod_area'];
    vodYear = json['vod_year'];
    vodRemark = json['vod_remark'];
    vodActor = json['vod_actor'];
    vodDirector = json['vod_director'];
    vodSerial = json['vod_serial'];
    vodLock = json['vod_lock'];
    vodLevel = json['vod_level'];
    vodHits = json['vod_hits'];
    vodHitsDay = json['vod_hits_day'];
    vodHitsWeek = json['vod_hits_week'];
    vodHitsMonth = json['vod_hits_month'];
    vodDuration = json['vod_duration'];
    vodUp = json['vod_up'];
    vodDown = json['vod_down'];
    vodScore = json['vod_score'];
    vodScoreAll = json['vod_score_all'];
    vodScoreNum = json['vod_score_num'];
    vodPointsPlay = json['vod_points_play'];
    vodPointsDown = json['vod_points_down'];
    vodContent = json['vod_content'];
    vodPlayFrom = json['vod_play_from'];
    vodPlayNote = json['vod_play_note'];
    vodPlayServer = json['vod_play_server'];
    vodPlayUrl = json['vod_play_url'];
    vodDownFrom = json['vod_down_from'];
    vodDownNote = json['vod_down_note'];
    vodDownServer = json['vod_down_server'];
    vodDownUrl = json['vod_down_url'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['vod_time'] = this.vodTime;
    data['vod_id'] = this.vodId;
    data['vod_name'] = this.vodName;
    data['vod_enname'] = this.vodEnname;
    data['vod_subname'] = this.vodSubname;
    data['vod_letter'] = this.vodLetter;
    data['vod_color'] = this.vodColor;
    data['vod_tag'] = this.vodTag;
    data['type_id'] = this.typeId;
    data['type_name'] = this.typeName;
    data['vod_pic'] = this.vodPic;
    data['vod_lang'] = this.vodLang;
    data['vod_area'] = this.vodArea;
    data['vod_year'] = this.vodYear;
    data['vod_remark'] = this.vodRemark;
    data['vod_actor'] = this.vodActor;
    data['vod_director'] = this.vodDirector;
    data['vod_serial'] = this.vodSerial;
    data['vod_lock'] = this.vodLock;
    data['vod_level'] = this.vodLevel;
    data['vod_hits'] = this.vodHits;
    data['vod_hits_day'] = this.vodHitsDay;
    data['vod_hits_week'] = this.vodHitsWeek;
    data['vod_hits_month'] = this.vodHitsMonth;
    data['vod_duration'] = this.vodDuration;
    data['vod_up'] = this.vodUp;
    data['vod_down'] = this.vodDown;
    data['vod_score'] = this.vodScore;
    data['vod_score_all'] = this.vodScoreAll;
    data['vod_score_num'] = this.vodScoreNum;
    data['vod_points_play'] = this.vodPointsPlay;
    data['vod_points_down'] = this.vodPointsDown;
    data['vod_content'] = this.vodContent;
    data['vod_play_from'] = this.vodPlayFrom;
    data['vod_play_note'] = this.vodPlayNote;
    data['vod_play_server'] = this.vodPlayServer;
    data['vod_play_url'] = this.vodPlayUrl;
    data['vod_down_from'] = this.vodDownFrom;
    data['vod_down_note'] = this.vodDownNote;
    data['vod_down_server'] = this.vodDownServer;
    data['vod_down_url'] = this.vodDownUrl;
    return data;
  }
}

