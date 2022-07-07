

import 'package:flutter_parse_html/api/api_constant.dart';
import 'package:flutter_parse_html/model/video_list_item.dart';
import 'package:flutter_parse_html/net/net_util.dart';
import 'package:html/parser.dart' as parse;
import 'package:flutter_parse_html/model/fanhao_bean.dart';
import 'package:flutter_parse_html/ui/fanhao/fanhao_parse_page.dart';
class FanHaoHelper {


  static Future<List<VideoListItem>> getFanHao1List(int page) {
    return NetUtil.getHtmlData(ApiConstant.getFanHao1(page))
        .then((onValue) {
      return _parseFanHao1List(onValue);
    });
  }

  static List<VideoListItem> _parseFanHao1List(String html) {
    List<VideoListItem> list = [];
    var doc = parse.parse(html);
    var elements = doc.getElementsByClassName('i_list list_n2');
    for (var value in elements) {
        VideoListItem item = new VideoListItem();
        var imageElement = value.getElementsByClassName('waitpic').first;
        item.imageUrl = imageElement.attributes['data-original'];
        item.targetUrl = '${ApiConstant.fanHao1}${value.getElementsByTagName('a').first.attributes['href']}';
        item.title = imageElement.attributes['alt'];
        list.add(item);
    }
    return list;
  }


  static Future<List<VideoListItem>> getFanHao2List(String type,int page) {
    return NetUtil.getHtmlData(ApiConstant.getFanHao2(type,page))
        .then((onValue) {
      return parseFanHao2List(onValue);
    });
  }

  static List<VideoListItem> parseFanHao2List(String html) {
    List<VideoListItem> list = [];
    try {
      var doc = parse.parse(html);
      var elements = doc.getElementsByClassName('anime_list').first.getElementsByTagName('img');
      for (var value in elements) {
              VideoListItem item = new VideoListItem();
              item.imageUrl = value.attributes['src'];
              item.title = value.attributes['alt'];
              list.add(item);
          }
    } catch (e) {
      print(e);
    }
    return list;
  }


  static Future<List<VideoListItem>> getFanHao3List(String type,int page) {
    return NetUtil.getHtmlData(ApiConstant.getFanHao3(type,page))
        .then((onValue) {
      return parseFanHao3List(type,onValue);
    });
  }

  static List<VideoListItem> parseFanHao3List(String type,String html) {
    String key = type == 'yo'?"uu-item":"grid-item";
    List<VideoListItem> list = [];
    var doc = parse.parse(html);
    var elements = doc.getElementsByClassName(key);
    for (var value in elements) {
        VideoListItem item = new VideoListItem();
        var imageElement = value.getElementsByTagName('img').first;
        item.imageUrl = '${ApiConstant.fanHao3}${imageElement.attributes['src']}';
        String titleKey = type == 'yo'?"meta-name":"meta-title";
        item.targetUrl = '${ApiConstant.fanHao3}${value.getElementsByTagName('a').first.attributes['href']}';
        item.title = value.getElementsByClassName(titleKey).first.text;
        list.add(item);
    }
    return list;
  }

  static FanHaoContent parseFanHaoContent(FanHaoType type,String html) {
    FanHaoContent fanHaoContent = new FanHaoContent();
    var doc = parse.parse(html);
    fanHaoContent.content = doc.getElementsByClassName('content_left').first.outerHtml;
    var pElements = doc.getElementsByTagName('p');
    List<String> items = new List();
    for (var value in pElements) {
      String p = value.text;
      if(p.contains('识别码:')){
        p = p.replaceAll('\n', '').trim();
        String item = p.split('识别码:')[1].split('发行日期')[0];
        items.add(item);
      }
    }
    fanHaoContent.items = items;
    return fanHaoContent;
  }

}