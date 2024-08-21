/// id : 322290
/// title : "6rKdWTLCHN7Iv4mvbNj5RjVfwqlQ/ABwmP/ot2QKqkhzuZRPZI1sbxKzQHOZpK16"
/// thumb : "sise/sise/jingpin/fengmiantu/xiaoxuan_23072301.jpg"
/// tags : "9hdBjUj8ytU8OyYYi3DbZQ=="
/// channel : "juqing"
/// insert_time : 1692013145

class SiseSearchEntity {
  SiseSearchEntity({
      num? id, 
      String? title, 
      String? thumb, 
      String? tags, 
      String? channel, 
      num? insertTime,}){
    _id = id;
    _title = title;
    _thumb = thumb;
    _tags = tags;
    _channel = channel;
    _insertTime = insertTime;
}

  SiseSearchEntity.fromJson(dynamic json) {
    _id = json['id'];
    _title = json['title'];
    _thumb = json['thumb'];
    _tags = json['tags'];
    _channel = json['channel'];
    _insertTime = json['insert_time'];
  }
  num? _id;
  String? _title;
  String? _thumb;
  String? _tags;
  String? _channel;
  num? _insertTime;
SiseSearchEntity copyWith({  num? id,
  String? title,
  String? thumb,
  String? tags,
  String? channel,
  num? insertTime,
}) => SiseSearchEntity(  id: id ?? _id,
  title: title ?? _title,
  thumb: thumb ?? _thumb,
  tags: tags ?? _tags,
  channel: channel ?? _channel,
  insertTime: insertTime ?? _insertTime,
);
  num? get id => _id;
  String? get title => _title;
  String? get thumb => _thumb;
  String? get tags => _tags;
  String? get channel => _channel;
  num? get insertTime => _insertTime;

  Map<String?, dynamic> toJson() {
    final map = <String?, dynamic>{};
    map['id'] = _id;
    map['title'] = _title;
    map['thumb'] = _thumb;
    map['tags'] = _tags;
    map['channel'] = _channel;
    map['insert_time'] = _insertTime;
    return map;
  }

}