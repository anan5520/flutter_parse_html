import 'dart:convert';

import 'package:flutter_parse_html/api/api_constant.dart';
import 'package:flutter_parse_html/model/porn_bean.dart';
import 'package:flutter_parse_html/model/video_list_item.dart';
import 'package:flutter_parse_html/net/net_util.dart';
import 'package:flutter_parse_html/ui/pornhub/pornhub_util.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart' as parse;

class YaSeHelper {
  static Future<List<VideoListItem>> getVideoContent(String url) {
    return NetUtil.getHtmlData(ApiConstant.yaSeUrl + url).then((onValue) {
      return parseVideo(parse.parse(onValue));
    });
  }

  //解析视频
  static List<VideoListItem> parseVideo(Document html) {
    List<VideoListItem> list = [];
    var elements = html.getElementsByTagName('colVideoList');
    try {
      for (var value in elements) {
        VideoListItem videoListItem = VideoListItem();
        videoListItem.targetUrl =
            value.getElementsByTagName('a').first.attributes['href'];
        videoListItem.title = value.text;
        String url = '';
        var imgEle = value.getElementsByTagName('img');
        if (imgEle != null && imgEle.length != 0) {
          url = value.getElementsByTagName('img').first.attributes['data-original']!;
        }
        if (url == null || url == '') {
          url = value
              .getElementsByClassName('video-thumb')
              .first
              .getElementsByTagName('div')
              .first
              .attributes['data-original']!;
        }
        videoListItem.imageUrl = url;
        list.add(videoListItem);
      }
    } catch (e) {
      print(e);
    }
    return list;
  }

  //解析小说
  static List<VideoListItem> parseBook(Document html) {
    List<VideoListItem> list = [];
    var elements = html.getElementsByClassName('novel-item');
    for (var value in elements) {
      VideoListItem videoListItem = VideoListItem();
      var h2 = value.getElementsByTagName('a').first;
      videoListItem.targetUrl = ApiConstant.yaSeUrl + h2.attributes['href']!;
      videoListItem.title = h2.attributes['title'];
      videoListItem.des = value.getElementsByClassName('novel-desc').first.text;
      list.add(videoListItem);
    }
    return list;
  }

  //解析自拍
  static List<VideoListItem> parseSelf(Document html) {
    List<VideoListItem> list = [];
    var rootElement = html.getElementsByClassName('pic-ul');
    if (rootElement == null || rootElement.length == 0)
      rootElement = html.getElementsByClassName('pic-list');
    if (rootElement == null || rootElement.length == 0)
      rootElement = html.getElementsByClassName('user-pic-list');
    var elements = rootElement.first.getElementsByTagName('li');
    for (var value in elements) {
      try {
        VideoListItem videoListItem = VideoListItem();
        var h2 = value
            .getElementsByClassName('pic_img')
            .first
            .getElementsByTagName('a')
            .first;
        videoListItem.targetUrl = ApiConstant.yaSeUrl + h2.attributes['href']!;
        videoListItem.title = h2.attributes['title'];
        var userEle = value.getElementsByClassName('meta-cat get-userinfo');
        var vid;
        try {
          if (userEle == null || userEle.length == 0) {
            userEle = value.getElementsByClassName('meta-cat');
            vid = userEle.first
                .getElementsByTagName('a')
                .first
                .attributes['href'];
          } else {
            vid = userEle.first.attributes['data-href'];
          }
        } catch (e) {
          print(e);
        }
        videoListItem.vid = vid;
        String imageUrl =
            value.getElementsByTagName('img').first.attributes['data-src']!;
        if (imageUrl == null)
          imageUrl = value
              .getElementsByTagName('img')
              .first
              .attributes['data-original']!;
        videoListItem.imageUrl = imageUrl;
        videoListItem.des = value
            .getElementsByClassName('meta')
            .first
            .text
            .trim()
            .replaceAll('\n', '')
            .replaceAll('\t', '');
        list.add(videoListItem);
      } catch (e) {
        print(e);
      }
    }
    print(list.toString());
    return list;
  }

  //解析自拍详情
  static Future<PornForumContent> parseSelfContent(String url) {
    return NetUtil.getHtmlData(url, isWeb: false).then((onValue) {
      Document doc = parse.parse(onValue);
      PornForumContent pornForumContent = PornForumContent();
      try {
        var rootEles = doc.getElementsByClassName('article-content');
        Element ele;
        if (rootEles == null || rootEles.length == 0) {
          ele = doc.getElementsByClassName('pic-view').first;
        } else {
          ele = rootEles.first;
        }
        List<String> imgList = [];
        var eles = ele.getElementsByTagName('img');
        for (var value in eles) {
          String url = value.attributes['data-src']!;
          if (url == null) url = value.attributes['data-original']!;
          if (url == null) url = value.attributes['src']!;
          value.attributes['src'] = url;
          if (url != null && url != "") imgList.add(url);
        }
        pornForumContent.imageList = imgList;
        pornForumContent.content = ele.outerHtml;
      } catch (e) {
        print(e);
      }
      print(pornForumContent.content);
      return pornForumContent;
    });
  }

  //解析自拍详情
  static Future<PornForumContent> parseAVContent(String url) {
    return PornHubUtil.getHtmlFromHttpDeugger(url).then((onValue) {
      Document doc = parse.parse(onValue);
      PornForumContent pornForumContent = PornForumContent();
      try {
        var rootEles = doc.getElementsByClassName('content article');
        Element ele;
        if (rootEles == null || rootEles.length == 0) {
          ele = doc.getElementsByClassName('content album').first;
        } else {
          ele = rootEles.first;
        }
        List<String> imgList = [];
        var eles = ele.getElementsByTagName('img');
        for (var value in eles) {
          String url = value.attributes['data-src']!;
          if (url == null) url = value.attributes['data-original']!;
          if (url == null) url = value.attributes['src']!;
          value.attributes['src'] = url;
          if (url != null && url != "") imgList.add(url);
        }
        pornForumContent.imageList = imgList;
        pornForumContent.content = ele.outerHtml;
      } catch (e) {
        print(e);
      }
      print(pornForumContent.content);
      return pornForumContent;
    });
  }

  //解析自拍详情
  static Future<List<VideoComment>> parseAbjContent(String url,int page) {
    var requestUrl = '$url${url.contains('?')?'&':'?'}page=$page';
    return NetUtil.getHtmlData(requestUrl, isWeb: false,isGbk: false).then((onValue) async {
      List<VideoComment> videoComments = [];
      Document doc = parse.parse(onValue);
      PornForumContent pornForumContent = PornForumContent();
      try {
        var postEle = doc.getElementById('postlist');
        var eleList = postEle!.getElementsByClassName('plhin');
        if(page == 1){
          var rootEles = doc.getElementsByClassName('pct');
          Element ele;
          if (rootEles == null || rootEles.length == 0) {
            ele = doc.getElementsByClassName('t_fsz').first;
          } else {
            ele = rootEles.first;
          }
          List<String> imgList = [];
          var eles = ele.getElementsByTagName('ignore_js_op');
          for (var value in eles) {
            var imgEle = value.getElementsByTagName('img').first;
            String? url = imgEle.attributes['data-src'];
            if (url == null) url = imgEle.attributes['data-original'];
            if (url == null) url = imgEle.attributes['zoomfile'];
            if(url != null){
              imgEle.attributes['src'] =
              '${ApiConstant.abjUrl}${!url.startsWith('/') ? '/' : ''}$url';
              if (url != null && url != "") imgList.add(imgEle.attributes['src']!);
            }
          }
          if (imgList.length == 0) {
            try {
              if (url.endsWith('-1-1.html')) {
                url =
                '${ApiConstant.abjUrl}/forum.php?mod=viewthread&tid=${url.replaceAll('-1-1.html', '').replaceAll('${ApiConstant.abjUrl}/thread-', '')}&from=album';
              }else{
                url = '$url&from=album';
              }
              var body =
              await NetUtil.getHtmlData(url, isGbk: true,isWeb: false);
              var tag = 'g';
              var imgStrings = body
                  .split(new RegExp(r"imglist\['url'] = \['|g']"))[1];
              var imgs = '$imgStrings$tag'.split(',');
              for (var value in imgs) {
                value = value.replaceAll("'", '');
                imgList.add('${ApiConstant.abjUrl}/$value');
              }
            } catch (e) {
              print(e);
            }
          }
          pornForumContent.imageList = imgList;
          pornForumContent.content = ele.outerHtml == null ? '' : ele.outerHtml;
          VideoComment videoComment = VideoComment();
          videoComment.pornForumContent = pornForumContent;
          videoComments.add(videoComment);
        }
        for(var i = page == 1?1:0; i < eleList.length;i ++){
          var ele  = eleList[i];
          var authEle = ele.getElementsByClassName('pls').first;
          var contentEle = ele.getElementsByClassName('plc').first;
          VideoComment videoComment = VideoComment();
          videoComment.uName = authEle.getElementsByClassName('authi').first.text;
          videoComment.replyTime = contentEle.getElementsByClassName('authi').first.text;
          videoComment.content = contentEle.getElementsByClassName('pct').first.text;
          videoComments.add(videoComment);
        }
      } catch (e) {
        print(e);
        pornForumContent.content = '';
      }
      return videoComments;
    });
  }
}
