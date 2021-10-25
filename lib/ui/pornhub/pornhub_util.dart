import 'dart:convert';

import 'package:flutter_parse_html/model/button_bean.dart';
import 'package:flutter_parse_html/model/movie_bean.dart';
import 'package:flutter_parse_html/model/porn_hub_video_entity.dart';
import 'package:flutter_parse_html/model/video_list_item.dart';
import 'package:flutter_parse_html/net/net_util.dart';
import 'package:gbk2utf8/gbk2utf8.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart';
class PornHubUtil {
  static final String pornHubUrl = 'https://cn.pornhub.com';

  static final String _params = "hd=1"; // 高清

  static final String _corsAnywhere = "https://cors-anywhere.herokuapp.com/";
  static final String _jsonpUrl = "https://jsonp.afeld.me/?url=";

  static final String _parseVideoUrl = "https://www.savido.net/download?url=";

  static final String _superParse = "https://superparse.com/zh";

  static final String _vlogdownloader =
      "https://www.vlogdownloader.com/download.html";

  static final String _httpDebuger =
      "http://www.httpdebugger.com/tools/ViewHttpHeaders.aspx";

  //从cors-anywhere代理 获取网页内容
  static Future<String> getHtmlFromCors(String url, {bool isMobile = true}) async{
    var header = isMobile
        ? {
            "x-requested-with": "XMLHttpRequest",
          "User-Agent":
          "Mozilla/5.0 (Linux; U; Android 2.3.6; zh-cn; GT-S5660 Build/GINGERBREAD) AppleWebKit/533.1 (KHTML, like Gecko) Version/4.0 Mobile Safari/533.1 MicroMessenger/4.5.255",
          }
        : {
            "x-requested-with": "XMLHttpRequest",
            "User-Agent":
                "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_7_0) AppleWebKit/535.11 (KHTML, like Gecko) Chrome/17.0.963.56 Safari/535.11",
          };
    return NetUtil.getHtmlDataWithHttp('$_corsAnywhere$url', header: header).then((value)async{
      if(value.contains('This demo of CORS Anywhere should only be used for development purposes')){
        var doc = parse(value);
        var accepts = doc.getElementsByTagName('input');
        String accessRequest = "";
        for (var value1 in accepts) {
          if(value1.attributes.containsValue("accessRequest")){
            accessRequest = value1.attributes['value'];
          }
        }
        if(accessRequest.isNotEmpty){
          await NetUtil.getHtmlDataWithHttp('https://cors-anywhere.herokuapp.com/corsdemo',paras: {"accessRequest":accessRequest});
          return await NetUtil.getHtmlDataWithHttp('$_corsAnywhere$url', header: header);
        }else{
          return '';
        }
      }else{
        return value;
      }
    });
  }

  //从Jsonp代理 获取网页内容
  static Future<String> getHtmlFromJsonp(String url, {bool isMobile = true,bool isGbk = false}) {
    var header = isMobile
        ? {
            "User-Agent":
                "Mozilla/5.0 (Linux; U; Android 2.3.6; zh-cn; GT-S5660 Build/GINGERBREAD) AppleWebKit/533.1 (KHTML, like Gecko) Version/4.0 Mobile Safari/533.1 MicroMessenger/4.5.255",
          }
        : {
            "User-Agent":
                "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_7_0) AppleWebKit/535.11 (KHTML, like Gecko) Chrome/17.0.963.56 Safari/535.11",
          };
    return NetUtil.getHtmlData('$_jsonpUrl$url', header: header,isGbk: isGbk);
  }

  //从HttpDeugger代理 获取网页内容
  static Future<String> getHtmlFromHttpDeugger(String url,
      {bool isMobile = true,
      Map<String, dynamic> params,
      Map<String, String> header,
      String referer,bool isGbk,
      bool isXvideos = false}) {
    print('请求url:$url');
    var paras = isMobile
        ? {
            "UrlBox": url,
            "AgentList": "Custom...",
            "AgentBox":
                "Mozilla/5.0 (Linux; U; Android 2.3.6; zh-cn; GT-S5660 Build/GINGERBREAD) AppleWebKit/533.1 (KHTML, like Gecko) Version/4.0 Mobile Safari/533.1 MicroMessenger/4.5.255",
            "VersionsList": "HTTP/1.1",
            "MethodList": "GET",
          }
        : {
            "UrlBox": url,
            "AgentList": "Google Chrome",
            "VersionsList": "HTTP/1.1",
            "MethodList": "GET",
          };

    if (params == null) {
      params = new Map<String, dynamic>();
    }
    if (params.length > 0) {
      url = '$url?';
    }
    params.forEach((key, value) {
      url = '$url$key=$value&';
    });
    if (url.endsWith('&')) {
      url = url.substring(0, url.length - 1);
    }
    String headerStr = '';
    header?.forEach((key, value) {
      headerStr = '$key:$value,';
    });
    return NetUtil.getHtmlDataPost(_httpDebuger, paras: paras, header: {
      "Host": "www.httpdebugger.com",
      "Origin": "http://www.httpdebugger.com",
      "Pragma": "no-cache",
      "RefererBox": referer,
      "HeadersBox": headerStr,
      "Referer": "http://www.httpdebugger.com/tools/ViewHttpHeaders.aspx",
      "Upgrade-Insecure-Requests": "1",
    },isGbk: isGbk).then((response) async {
      if ("error" != response) {
        Document doc = parse(response);
        var videoEle = doc.getElementById('ResultData');
        String resultText = videoEle == null ? response : videoEle.text;
        return resultText;
      } else {
        if (isXvideos) {
          response = await getHtmlFromCors(url);
        } else {
          response = await getHtmlFromJsonp(url, isMobile: isMobile);
        }
        return response;
      }
    });
  }

  static Future<List<ButtonBean>> getCategories() async {
    return await getHtmlFromCors('$pornHubUrl/categories').then((response) {
      List<ButtonBean> result = [];
      Document document = parse(response);
      var elements = document.querySelectorAll('ul#categoriesListSection > li');
      for (var value in elements) {
        String href =
            '${value.querySelector('div.category-wrapper > a').attributes['href']}';
        if (href.contains("?")) {
          // 只获取高清视频
          href += "&" + _params;
        } else {
          href += "?" + _params;
        }
        String title = value
            .querySelector('div.category-wrapper > h5 > a')
            .attributes['data-mxptext'];
        ButtonBean buttonBean = new ButtonBean();
        buttonBean.title = title;
        buttonBean.value = href;
        result.add(buttonBean);
      }
      return result;
    });
  }

  static Future<List<VideoListItem>> search(String key, {int page = 1}) {
    return getHtmlFromHttpDeugger(
            '$pornHubUrl/video/search?search=$key&page=$page')
        .then((response) {
      List<VideoListItem> viewUrls = new List<VideoListItem>();
      Document doc = parse(response);
      try {
        var videoResult = doc.getElementById('videoListSearchResults');
        var lis = videoResult.getElementsByTagName('li');
        for (var value in lis) {
          VideoListItem videoListItem = new VideoListItem();
          videoListItem.targetUrl =
              '$pornHubUrl${value.getElementsByTagName('a').first.attributes['href']}';
          videoListItem.imageUrl =
              value.getElementsByTagName('img').first.attributes['src'];
          if (!videoListItem.imageUrl.startsWith('http')) {
            videoListItem.imageUrl = value
                .getElementsByTagName('img')
                .first
                .attributes['data-thumb_url'];
          }
          videoListItem.title =
              '${value.getElementsByClassName('title').first.text.replaceAll(new RegExp('\n| '), '')}';
          viewUrls.add(videoListItem);
        }
      } catch (e) {
        print(e);
      }
      return viewUrls;
    });
  }

  static Future<List<VideoListItem>> getViewUrlsFromCors(String url,
      {bool isMobile = false}) {
    return getHtmlFromCors(url, isMobile: isMobile).then((response) {
      return _parseHtml(response);
    });
  }

  static Future<List<VideoListItem>> getViewUrlsFromHttpDebugger(String url,
      {bool isMobile = false}) {
    return getHtmlFromHttpDeugger(url, isMobile: false).then((response) {
      return _parseHtml(response);
    });
  }

  static Future<MovieBean> getVideoUrl(String url) {
    return getHtmlFromHttpDeugger(url, isMobile: true).then((response) {
      MovieBean movieBean = new MovieBean();
      try {
        String resultText = response;
        Document document = parse(resultText);
        var container = document.getElementById('mobileContainer');
        var videoShow = document.getElementById('videoShow');
        var js = container.getElementsByTagName('script').first.text;
        var urlJsons = js.split(new RegExp(r'("};|= {")'));
        String urlJson = '{"${urlJsons[1]}"}';
        PornHubVideoEntity pornHubVideoEntity =
            PornHubVideoEntity.fromJson(json.decode(urlJson));
        List<MovieItemBean> list = [];
        movieBean.playUrl = videoShow.attributes['data-default'];
        pornHubVideoEntity.mediaDefinitions.forEach((value) {
          if (value.videoUrl != '') {
            if (movieBean.playUrl == null || movieBean.playUrl == '') {
              movieBean.playUrl = value.videoUrl;
              movieBean.name = value.format;
            }
            MovieItemBean movieItemBean = MovieItemBean();
            movieItemBean.targetUrl = value.videoUrl;
            movieItemBean.name = value.format;
            list.add(movieItemBean);
          }
        });
        movieBean.name = pornHubVideoEntity.videoTitle;
        movieBean.imgUrl = pornHubVideoEntity.imageUrl;
        movieBean.list = list;
        print(pornHubVideoEntity);
      } catch (e) {
        print(e);
      }
      return movieBean;
    });
  }

  static Future<MovieBean> getVideoUrlFromParseVideo(String url) {
    return getHtmlFromHttpDeugger('$_parseVideoUrl$url').then((response) {
      MovieBean playUrl = new MovieBean();
      try {
        Document doc = parse(response);
        var videoEle = doc.getElementById('ResultData');
        String resultText = videoEle == null ? response : videoEle.text;
        Document document = parse(resultText);
        var aEles = document
            .getElementsByClassName('table-responsive')
            .first
            .getElementsByTagName('tr');
        List<MovieItemBean> list = [];
        for (var value in aEles) {
          try {
            MovieItemBean videoListItem = new MovieItemBean();
            videoListItem.name =
                value.text.replaceAll(new RegExp('\n|\t| '), '');
            videoListItem.targetUrl =
                value.getElementsByTagName('a').first.attributes['href'];
            if (playUrl.playUrl == null || playUrl.playUrl.isEmpty) {
              playUrl.playUrl = videoListItem.targetUrl;
              playUrl.name = videoListItem.name;
            }
            list.add(videoListItem);
          } catch (e) {
            print(e);
          }
        }
        playUrl.list = list;
      } catch (e) {
        print(e);
      }
      return playUrl;
    });
  }

  static Future<MovieBean> getVideoUrlFromSuperparse(String url) {
    return NetUtil.getHtmlDataPost(_superParse, paras: {
      'url': url
    }, header: {
      'Content-Type': 'application/x-www-form-urlencoded',
      'Accept-Encoding': 'gzip, deflate, br',
      'Connection': 'keep-alive',
      'Referer': 'https://superparse.com/pornhub/zh',
      'origin': 'https://superparse.com',
      'user-agent':
          'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_14_4) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/77.0.3865.75 Safari/537.36',
      'sec-fetch-mode': 'navigate',
      'cookie':
          '_ga=GA1.2.2013403863.1588930674; _gid=GA1.2.291201928.1588930674; Hm_lvt_cdce8cda34e84469b1c8015204129522=1588930697,1588931953,1588931992; _gat_gtag_UA_125709902_1=1; Hm_lpvt_cdce8cda34e84469b1c8015204129522=1588932649',
    }).then((response) {
      MovieBean playUrl = new MovieBean();
      try {
        Document document = parse(response);
        var aEles = document.getElementsByClassName('caption');
        List<MovieItemBean> list = [];
        for (var value in aEles) {
          try {
            MovieItemBean videoListItem = new MovieItemBean();
            videoListItem.name = value.getElementsByTagName('p').first.text;
            videoListItem.targetUrl =
                value.getElementsByTagName('a').first.attributes['href'];
            if (playUrl.playUrl == null || playUrl.playUrl.isEmpty) {
              playUrl.playUrl = videoListItem.targetUrl;
              playUrl.name = videoListItem.name;
            }
            list.add(videoListItem);
          } catch (e) {
            print(e);
          }
        }
        playUrl.list = list;
      } catch (e) {
        print(e);
      }
      return playUrl;
    });
  }

  static Future<MovieBean> getVideoUrlFromVlogdownloader(String url) {
    return NetUtil.httpHtmlCookies(
        'https://www.vlogdownloader.com', _vlogdownloader,
        data: {
          'url': url,
          'hash': ''
        },
        header: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Accept-Encoding': 'gzip, deflate, br',
          'Connection': 'keep-alive',
          'sec-fetch-mode': 'navigate',
          'sec-fetch-user': '?1',
          'origin': 'null',
          'upgrade-insecure-requests': '1',
          'Accept':
              'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3',
          'sec-fetch-site': 'same-origin',
          'user-agent':
              'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_14_4) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/77.0.3865.75 Safari/537.36',
        }).then((response) {
      MovieBean playUrl = new MovieBean();
      try {
        Document document = parse(response);
        var aEles = document.getElementsByClassName('caption');
        List<MovieItemBean> list = [];
        for (var value in aEles) {
          try {
            MovieItemBean videoListItem = new MovieItemBean();
            videoListItem.name = value.getElementsByTagName('p').first.text;
            videoListItem.targetUrl =
                value.getElementsByTagName('a').first.attributes['href'];
            if (playUrl.playUrl == null || playUrl.playUrl.isEmpty) {
              playUrl.playUrl = videoListItem.targetUrl;
              playUrl.name = videoListItem.name;
            }
            list.add(videoListItem);
          } catch (e) {
            print(e);
          }
        }
        playUrl.list = list;
      } catch (e) {
        print(e);
      }
      return playUrl;
    });
  }

  static List<VideoListItem> _parseHtml(String response) {
    List<VideoListItem> viewUrls = new List<VideoListItem>();
    Document doc = parse(response);
    var lis = doc.querySelectorAll('ul#videoCategory > li.js-pop');
    if (lis.length > 0) {
      for (var value in lis) {
        VideoListItem videoListItem = new VideoListItem();
        String viewkey = value.attributes[value.attributes.containsKey('_vkey')
            ? '_vkey'
            : 'data-video-vkey'];
        videoListItem.targetUrl = '$pornHubUrl/view_video.php?viewkey=$viewkey';
        videoListItem.imageUrl =
            value.getElementsByTagName('img').first.attributes['src'];
        if (!videoListItem.imageUrl.startsWith('http')) {
          videoListItem.imageUrl = value
              .getElementsByTagName('img')
              .first
              .attributes['data-thumb_url'];
        }
        videoListItem.title = value
            .getElementsByClassName('title')
            .first
            .text
            .replaceAll(new RegExp('\n|\t| '), '');
        viewUrls.add(videoListItem);
      }
    } else {
      //frontListingWrapper

      var result = doc.getElementsByClassName('frontListingWrapper');
      if (result == null || result.length == 0) {
        result = doc.getElementsByClassName('videos search-video-thumbs');
      }
      var videoResult = result.first;
      var lis = videoResult.getElementsByTagName('li');
      for (var value in lis) {
        String viewKey = value.attributes['_vkey'];
        if (viewKey != null && viewKey.isNotEmpty) {
          VideoListItem videoListItem = new VideoListItem();
          videoListItem.targetUrl =
              '$pornHubUrl/view_video.php?viewkey=${value.attributes['_vkey']}';
          videoListItem.imageUrl =
              value.getElementsByTagName('img').first.attributes['src'];
          videoListItem.title =
              '${value.getElementsByClassName('title').first.text.replaceAll(new RegExp('\n| '), '')} '
              '${value.getElementsByClassName('videoDetailsBlock').first.text.replaceAll(new RegExp('\n| '), '')}';
          viewUrls.add(videoListItem);
        }
      }
    }
    return viewUrls;
  }
}
