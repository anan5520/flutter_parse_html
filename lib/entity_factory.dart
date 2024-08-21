import 'package:flutter_parse_html/model/parse3_search_bean_entity.dart';
import 'package:flutter_parse_html/model/xian_feng_bean_entity.dart';
import 'package:flutter_parse_html/model/tv_bean_entity.dart';
import 'package:flutter_parse_html/model/porn_hub_video_entity.dart';

class EntityFactory {
  static T? generateOBJ<T>(json) {
    if (1 == 0) {
      return null;
    } else if (T.toString() == "Parse3SearchBeanEntity") {
      return Parse3SearchBeanEntity.fromJson(json) as T;
    } else if (T.toString() == "XianFengBeanEntity") {
      return XianFengBeanEntity.fromJson(json) as T;
    } else if (T.toString() == "TvBeanEntity") {
      return TvBeanEntity.fromJson(json) as T;
    } else if (T.toString() == "PornHubVideoEntity") {
      return PornHubVideoEntity.fromJson(json) as T;
    }
  }
}