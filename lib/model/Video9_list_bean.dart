import 'package:flutter_parse_html/model/video9_list_item.dart';

class Video9ListBean {
  Video9ListBean({
      this.list, 
      this.hasMore, 
      this.size, 
      this.page, 
      this.total,});

  Video9ListBean.fromJson(dynamic json) {
    if (json['list'] != null) {
      list = [];
      json['list'].forEach((v) {
        list!.add(Video9ListItem.fromJson(v));
      });
    }
    hasMore = json['hasMore'];
    size = json['size'];
    page = json['page'];
    total = json['total'];
  }
  List<Video9ListItem>? list;
  bool? hasMore;
  int? size;
  int? page;
  int? total;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (list != null) {
      map['list'] = list!.map((v) => v.toJson()).toList();
    }
    map['hasMore'] = hasMore;
    map['size'] = size;
    map['page'] = page;
    map['total'] = total;
    return map;
  }

}