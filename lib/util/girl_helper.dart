

import 'package:flutter_parse_html/api/api_constant.dart';
import 'package:flutter_parse_html/model/girl_bean.dart';
import 'package:flutter_parse_html/net/net_util.dart';
import 'package:html/parser.dart' as parse;
class GirlHelper{

  static Future<List<GirlBean>> getGirlList(String tag,int page) {
    return NetUtil.getHtmlData(ApiConstant.getGirlListUrl(tag, page),
    referer: ApiConstant.girlBaseUrl)
        .then((onValue) {
      return _parseGirlList(onValue);
    });
  }
  static Future<List<String>> getGirlDetail(String id) {
    return NetUtil.getHtmlData(ApiConstant.getGirlDetailUrl(id),
    referer: ApiConstant.girlBaseUrl)
        .then((onValue) {
      return _parseGirlDetail(onValue);
    });
  }

  static List<GirlBean> _parseGirlList(String onValue) {
    List<GirlBean> list = [];
    var doc = parse.parse(onValue);
    var ulPins = doc.getElementById('pins');
    var lis = ulPins.querySelectorAll('li');
    for (var value in lis) {
      var contentElement = value.querySelectorAll('a').first;
      if(contentElement == null){
        continue;
      }
      GirlBean girlBean = new GirlBean();
      String contentUrl = contentElement.attributes['href'];
      int index = contentUrl.lastIndexOf('/');
      if(index >= 0 && index + 1 < contentUrl.length){
        String idStr = contentUrl.substring(index + 1,contentUrl.length);
        if(idStr.isNotEmpty){
          girlBean.id = int.parse(idStr);
        }
        var imageElement = value.querySelectorAll('img').first;
        String name = imageElement.attributes['alt'];
        girlBean.name = name;
        String thumbUrl = imageElement.attributes['data-original'];
        double height = double.parse(imageElement.attributes['height']);
        double width = double.parse(imageElement.attributes['width']);
        girlBean.height = height;
        girlBean.width = width;
        girlBean.thumbUrl = thumbUrl;
        String date = value.getElementsByClassName('time').first.text;
        girlBean.date = date;
        list.add(girlBean);
      }
    }

    return list;
  }

  static List<String>_parseGirlDetail(String onValue) {
    List<String> list = [];
    var doc = parse.parse(onValue);
    var pageElement = doc.getElementsByClassName('pagenavi').first;
    var aElements = pageElement.querySelectorAll('a');
    int totalPage = 1;
    if(aElements != null && aElements.length > 3){
      String pageStr = aElements[aElements.length - 2].text;
      if(pageStr.isNotEmpty){
        totalPage = int.parse(pageStr);
      }
    }

    String imageUrl = doc.getElementsByClassName('main-image').first.querySelectorAll('img').first.attributes['src'];
    if(totalPage == 1){
      list.add(imageUrl);
    }

    for (int i = 1; i < totalPage + 1; i++) {
      String tmp;
      if(i < 10){
        tmp = imageUrl.replaceAll('01.', '0$i.');
      }else{
        tmp = imageUrl.replaceAll('01.', '$i.');
      }
      list.add(tmp);
    }
    return list;

  }


}