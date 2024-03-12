class Video9ListItem {
  Video9ListItem({
      this.id, 
      this.title, 
      this.thumbimg, 
      this.hits, 
      this.times, 
      this.scores, 
      this.isVip, 
      this.remark, 
      this.type, 
      this.userVip,});

  Video9ListItem.fromJson(dynamic json) {
    id = json['id'];
    title = json['title'];
    thumbimg = json['thumbimg'];
    hits = json['hits'];
    times = json['times'];
    scores = json['scores'];
    isVip = json['is_vip'];
    remark = json['remark'];
    type = json['type'];
    userVip = json['user_vip'];
  }
  String id;
  String title;
  String thumbimg;
  String hits;
  String times;
  String scores;
  String isVip;
  String remark;
  String type;
  int userVip;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['title'] = title;
    map['thumbimg'] = thumbimg;
    map['hits'] = hits;
    map['times'] = times;
    map['scores'] = scores;
    map['is_vip'] = isVip;
    map['remark'] = remark;
    map['type'] = type;
    map['user_vip'] = userVip;
    return map;
  }

}