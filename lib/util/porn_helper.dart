import 'package:flutter_parse_html/api/api_constant.dart';
import 'package:flutter_parse_html/net/net_util.dart';
import 'dart:math';
import 'package:flutter_parse_html/model/porn_bean.dart';
import 'package:flutter_parse_html/ui/pornhub/pornhub_util.dart';
import 'package:flutter_parse_html/util/escapeu_unescape.dart';
import 'dart:convert';
import 'package:html/parser.dart' as parse;
import 'package:flutter_parse_html/util/log_utils.dart';

class PornHelper {
  static final String _tag = 'PornHelper';

  static Future<VideoResult> parseVideoPage(PornItem item) {
    var viewKey = item.viewKey;
    Map<String, dynamic> param = {'viewkey': viewKey};
    Map<String, dynamic> header = {
      'X-Forwarded-For': _getRandomIPAddress(),
      'Referer': ApiConstant.getPornHomeUrl(),
      'Cookie': ApiConstant.pornCookie
    };
    return NetUtil.getHtmlData(ApiConstant.getPornParseVideoUrl(),
            paras: param, header: header)
        .then((onValue) {
      return _parseVideoUrl(onValue, item);
    });
  }

  //解析视频评论
  static Future<List<VideoComment>> parseVideoComment(
      String videoId, int page, String viewKey) {
    Map<String, dynamic> param = {
      'VID': videoId,
      'start': page,
      'comment_per_page': 20
    };
    Map<String, dynamic> header = {
      'X-Requested-With': 'XMLHttpRequest',
      'Referer': ApiConstant.getPornHomeUrl(),
      'Cookie': ApiConstant.pornCookie
    };
    return NetUtil.getHtmlData(ApiConstant.getPornCommentUrl(),
            paras: param,
            header: header,
            isWeb: true,
            referer: _getPlayVideoReferer(viewKey))
        .then((onValue) {
      return _parseVideoComment(onValue);
    });
  }

  //解析论坛版块
  static Future<List<PornForumItem>> parsePornForum(String fid, int page) {
    Map<String, dynamic> param = {'fid': fid, 'page': page};
    return PornHubUtil.getHtmlFromHttpDeugger(
      fid == 'index'
          ? ApiConstant.getPornForumHomeUrl()
          : ApiConstant.getPornForumUrl(),
      params: param).then((onValue) {
      return fid == 'index'
          ? _parsePornIndexForum(onValue)
          : _parsePornForum(onValue, page);
    });
  }

  static Future<PornForumContent> parsePornForumContent(int tid) {
    Map<String, dynamic> param = {'tid': tid};
    return PornHubUtil.getHtmlFromHttpDeugger(ApiConstant.getPornForumContentUrl(),
            params: param)
        .then((onValue) {
      return parsePornForumContentImg(onValue);
    });
  }

  static String _getPlayVideoReferer(String viewKey) {
    return ApiConstant.pornBaseUrl + "view_video.php?viewkey=" + viewKey;
  }

  //随机ip地址
  static String _getRandomIPAddress() {
    Random random = Random();
    return '${random.nextInt(255)}.${random.nextInt(255)}.${random.nextInt(255)}.${random.nextInt(255)}';
  }

  //解析视频地址
  static VideoResult _parseVideoUrl(String html, PornItem item) {
    var viewKey = item.viewKey;
    VideoResult videoResult = new VideoResult();
    if (html.contains('你每天只可观看10个视频')) {
      print('超出观看上限了');
      videoResult.id = VideoResult.OUT_OF_WATCH_TIMES;
      return videoResult;
    }
    var reg ;
    if(html.contains("strencode2")){
      reg = RegExp(r'document.write\(strencode2\("|"\)\);');
    }else {
      reg = RegExp(r'document.write\(strencode\("|"\)\);');
    }
    var strings = html.split(reg);

    if (strings.length > 1) {
      String s = strings[1];
      if(html.contains("strencode2")){
        s = EscapeUnescape.unescape(s);
      }else{
        var urlArray = s.split('","');
        s = urlArray[0];
        var s1 = urlArray[1];
        var s2 = urlArray[2];
        if(s2.substring(s2.length - 1) == "2"){
          var t = s;
          s = s1;
          s1 = t;
        }
        s = String.fromCharCodes(base64Decode(s));
        var len = s1.length;
        var code = "";
        for(var i = 0; i< s.length;i++ ){
          var k = i % len;
          code += String.fromCharCode(s.codeUnitAt(i) ^ s1.codeUnitAt(k));
        }
        s = String.fromCharCodes(base64Decode(code));
      }
      var document = parse.parse(s);
      String videoUrl =
          document.querySelectorAll('source').first.attributes['src'];
      videoResult.videoUrl = videoUrl;
      try {
        var tempVideoUrl = videoUrl.substring(0, videoUrl.indexOf(".m3u8"));
        int startIndex = tempVideoUrl.lastIndexOf("/");
        videoResult.videoId = tempVideoUrl.substring(++startIndex);
      } catch (e) {
        print(e);
      }
      //解析作者
      var doc = parse.parse(html);
      try {
        String ownerUrl =
                  doc.querySelectorAll('a[href*=UID]').first.attributes['href'];
        String ownerId =
                  ownerUrl.substring(ownerUrl.indexOf('=') + 1, ownerUrl.length);
        videoResult.ownerId = ownerId;
      } catch (e) {
        print(e);
      }

      var element =
          doc.getElementById('addToFavLink').querySelectorAll('a').first;
      var addToFavLink = element.attributes;

//      var args = addToFavLink['onclick'].split(',');
//      var userId = args[1].trim();
//      LogUtils.d(_tag, "userId》》》》$userId");

      //原始纯数字作者id，用于收藏接口
//      String authorId = args[3].replaceAll(');', '').trim();
//      LogUtils.d(_tag, 'authorId=====$authorId');
//      videoResult.authorId = authorId;

      try {
        String ownerName = doc.querySelector('a[href*=UID]').text;
        videoResult.ownerName = ownerName;
      } catch (e) {
        print(e);
      }
      var infos = doc.getElementsByClassName('videodetails-yakov');
      infos.forEach((value) {
        if (value.text.contains('添加时间')) {
          try {
            String allInfo = value.text;
            allInfo = allInfo.replaceAll('\s', '');
            allInfo = allInfo.replaceAll('\t', '');
            allInfo = allInfo.replaceAll('\n', '');
            String addDate = allInfo.substring(
                allInfo.indexOf('添加时间'), allInfo.indexOf('作者'));
            videoResult.addDate = addDate;
            String otherInfo =
                allInfo.substring(allInfo.indexOf('注册'), allInfo.indexOf('简介'));
            videoResult.userOtherInfo = otherInfo;
          } catch (e) {
            print(e);
          }
        }
      });
      var imageEles = doc.getElementById("player_one_html5_api");
      if (imageEles != null &&
          imageEles.attributes != null &&
          imageEles.attributes.containsKey('poster')) {
        String thumbImg = doc.getElementById('vid').attributes['poster'];
        videoResult.thumbImgUrl = thumbImg;
      }

      videoResult.videoName = item.title;
      videoResult.viewKey = viewKey;
    } else {
      try {
        var doc = parse.parse(html);
        var eles = doc.getElementsByTagName('source');
        String videoUrl = '';
        if (eles.length > 0) {
          videoUrl = eles.first.attributes['src'];
        } else {
          var videos = html.split(new RegExp(r'<source src="|" type='));
          videos.forEach((element) {
            if (element.startsWith('http')) {
              videoUrl = element;
            }
          });
        }

        videoResult.videoUrl = videoUrl;
        videoResult.thumbImgUrl =
            doc.getElementsByTagName('video').first.attributes['poster'];
        videoResult.viewKey = viewKey;
        videoResult.videoName = item.title;
        try {
          var tempVideoUrl = videoUrl.substring(0, videoUrl.indexOf(".mp4"));
          int startIndex = tempVideoUrl.lastIndexOf("/");
          videoResult.videoId = tempVideoUrl.substring(++startIndex);
        } catch (e) {
          print(e);
        }
        String content = doc.getElementById('videodetails-content').text;
        var times = content.split(new RegExp(r'添加时间:|作者:'));
        if (times.length > 1) {
          videoResult.addDate = times[1];
        }
        var userNames = content.split(new RegExp(r'作者:|注册:'));
        if (userNames.length > 1) {
          videoResult.ownerName = userNames[1];
        }

        var userInfo = content.split('注册:');
        if (userInfo.length > 1) {
          videoResult.userOtherInfo = userInfo[1];
        }
      } catch (e) {
        print(e);
      }
    }

    return videoResult;
  }

  static List<VideoComment> _parseVideoComment(String html) {
    List<VideoComment> list = [];
    var doc = parse.parse(html);
    var elements = doc.querySelectorAll("table.comment-divider");
    for (var element in elements) {
      VideoComment videoComment = VideoComment();

      String ownnerUrl =
          element.querySelectorAll('a[href*=UID]').first.attributes['href'];
      String uid =
          ownnerUrl.substring(ownnerUrl.indexOf('=') + 1, ownnerUrl.length);
      videoComment.uid = uid;

      String uName = element.querySelectorAll('a[href*=UID]').first.text;
      videoComment.uName = uName;

      String replyTime =
          element.querySelectorAll('span.comment-info').first.text;
      videoComment.replyTime =
          replyTime.replaceAll('(', '').replaceAll(')', '');

      String tmpreplyId =
          element.querySelectorAll('div.comment-body').first.attributes['id'];
      String replyId = tmpreplyId.substring(
          tmpreplyId.lastIndexOf('_') + 1, tmpreplyId.length);
      videoComment.replyId = replyId;

      String comment = element
          .querySelectorAll('div.comment-body')
          .first
          .text
          .replaceAll('举报', '')
          .replaceAll('Show', '');
      List<String> tmpQuoteList = [comment];
      var quotes = element
          .querySelectorAll('div.comment-body')
          .first
          .querySelectorAll('div.comment_quote');
      for (var value in quotes) {
        tmpQuoteList.add(value.text);
      }
      List<String> quoteList = [];
      for (int i = 0; i < tmpQuoteList.length; i++) {
        String quote;
        if (i + 1 >= tmpQuoteList.length) {
          quote = tmpQuoteList[i];
          quoteList.insert(0, quote.trim());
          break;
        }
        quote = tmpQuoteList[i].replaceAll(tmpQuoteList[i + 1], '');
        quoteList.insert(0, quote.trim());
      }

      videoComment.commentQuoteList = quoteList;

      String info = element.querySelectorAll('td').first.text;
      String titleInfo = info.substring(0, info.indexOf('('));
      videoComment.titleInfo = titleInfo.replaceAll(uName, '');
      list.add(videoComment);
    }
    return list;
  }

  static List<PornForumItem> _parsePornIndexForum(String html) {
    List<PornForumItem> list = [];
    var doc = parse.parse(html);
    var tds = doc
        .getElementsByClassName('mainbox forumlist')
        .first
        .getElementsByTagName('div');
    for (var td in tds) {
      var elements = td.querySelectorAll('a');
//       if(td.querySelectorAll('a').first.attributes['title'].contains('最新精华')){
//
//       }
      for (var element in elements) {
        if(td.outerHtml.contains('title')){
          PornForumItem pornForumItem = new PornForumItem();
          String allInfo = element.attributes['title'].replaceAll('\n', '');
          int titeleIndex = allInfo.indexOf('主题标题:');
          int authorIndex = allInfo.indexOf('主题作者:');
          int authorPublishTimeIndex = allInfo.indexOf('发表时间:');
          int viewCountIndex = allInfo.indexOf('浏览次数:');
          int replyCountIndex = allInfo.indexOf('回复次数:');
          int lastPostTimeIndex = allInfo.indexOf('最后回复:');
          int lastPostAuthorIndex = allInfo.indexOf('最后发表:');

          String title = allInfo.substring(titeleIndex + 5, authorIndex);
          String author =
          allInfo.substring(authorIndex + 5, authorPublishTimeIndex);
          String authorPublishTime =
          allInfo.substring(authorPublishTimeIndex + 5, viewCountIndex);
          String viewCount = allInfo
              .substring(viewCountIndex + 5, replyCountIndex)
              .replaceAll('次', '')
              .trim();
          String replyCount = allInfo
              .substring(replyCountIndex + 5, lastPostTimeIndex)
              .replaceAll('次', '')
              .trim();
          String lastPostTime =
          allInfo.substring(lastPostTimeIndex + 5, lastPostAuthorIndex);
          String lastPostAuthor =
          allInfo.substring(lastPostAuthorIndex + 5, allInfo.length);

          pornForumItem.lastPostTime = lastPostTime;
          pornForumItem.lastPostAuthor = lastPostAuthor;
          pornForumItem.title = title;
          pornForumItem.author = author;
          pornForumItem.viewCount = int.parse(viewCount);
          pornForumItem.replyCount = int.parse(replyCount);
          pornForumItem.authorPublishTime = authorPublishTime;

          String contentUrl = element.attributes['href'];
          int startIndex = contentUrl.indexOf('tid=');
          String tidStr = contentUrl.substring(startIndex + 4, contentUrl.length);
          if (tidStr.isNotEmpty) {
            pornForumItem.tid = int.parse(tidStr);
          }
          list.add(pornForumItem);
        }
      }
    }
    return list;
  }

  static List<PornForumItem> _parsePornForum(String html, int page) {
    List<PornForumItem> list = [];
    try {
      var doc = parse.parse(html);
      var table = doc.getElementsByClassName('datatable').first;
      var tbBodys = table.querySelectorAll('tbody');
      bool contentStart = false;
      for (var tbody in tbBodys) {
            PornForumItem item = PornForumItem();
            var th = tbody.querySelectorAll('th').first;
            if (!contentStart && page == 1) {
              if (th.text.contains('版块主题')) {
                contentStart = true;
              }
              continue;
            }

            if (th != null) {
              String title = th.querySelectorAll('a').first.text;
              item.title = title.replaceAll('\n', '');
              String contentUrl = th.querySelectorAll('a').first.attributes['href'];
              int startIndex = contentUrl.indexOf('tid=');
              int endIndex = contentUrl.indexOf('&');
              String tidStr = contentUrl.substring(startIndex + 4, endIndex);
              if (tidStr != null && tidStr.isNotEmpty) {
                item.tid = int.parse(tidStr);
              }
              var imageElements = th.querySelectorAll('img');
              List<String> stringList;
              for (var value in imageElements) {
                if (stringList == null) {
                  stringList = [];
                }
                stringList.add(value.attributes['src']);
              }
              item.imageList = stringList;

              var agreeElements = th.querySelectorAll('font');
              if (agreeElements != null && agreeElements.length >= 1) {
                String agreeCount = th.querySelectorAll('font').last.text;
                item.agreeCount = agreeCount;
              }
              var tds = tbody.querySelectorAll('td');
              for (var td in tds) {
                try {
                  String className = td.className;
                  switch (className) {
                    case "folder":
                      String folder =
                          td.querySelectorAll("img").first.attributes["src"];
                      item.folder = folder;
                      break;
                    case "icon":
                      var iconElement = td.querySelectorAll("img").first;
                      if (iconElement != null) {
                        String icon = iconElement.attributes["src"];
                        item.icon = icon;
                      }
                      break;
                    case "author":
                      String author = td.querySelectorAll("a").first.text;
                      String authorPublishTime = td.querySelectorAll("em").first.text;
                      item.author = author;
                      item.authorPublishTime = authorPublishTime;
                      break;
                    case "nums":
                      String replyCount = td.querySelectorAll("strong").first.text;
                      String viewCount = td.querySelectorAll("em").first.text;
                      if (replyCount.isNotEmpty) {
                        item.replyCount = int.parse(replyCount);
                      }
                      if (viewCount.isNotEmpty) {
                        item.viewCount = int.parse(viewCount);
                      }
                      break;
                    case "lastpost":
                      String lastPostAuthor = td.querySelectorAll("a").first.text;
                      String lastPostTime = td.querySelectorAll("em").first.text;
                      item.lastPostAuthor = lastPostAuthor;
                      item.lastPostTime = lastPostTime;
                      break;
                    default:
                  }
                } catch (e) {
                  print(e);
                }
              }
              list.add(item);
            }
          }
    } catch (e) {
      print(e);
    }
    return list;
  }

  static PornForumContent parsePornForumContentImg(String html) {
    String baseUrl = ApiConstant.pornForumBaseUrl;
    var doc = parse.parse(html);
    var linkTag = doc.querySelectorAll('link').first;
    String address = '';
    if (linkTag != null) {
      String href = linkTag.attributes['href'];
      address = href.substring(0, href.indexOf('archiver'));
    }
//    if(address.isNotEmpty && address != ApiConstant.pornBaseUrl){
//
//    }
    var content = doc.getElementsByClassName('t_msgfontfix').first;
    if (content == null) {
      List<String> stringList = [];
      PornForumContent forumContent = new PornForumContent();
      forumContent.imageList = stringList;
      forumContent.content = "暂不支持解析该网页类型或者帖子已被封禁了";
      return forumContent;
    }

    var attachPopups = doc.getElementsByClassName('imgtitle');
//    if(attachPopups != null){
//      for (var value in attachPopups) {
//        value.innerHtml('');
//      }
//    }
    var ps = content.querySelectorAll('p');
    for (var value in ps) {
      value.attributes['style'] = '';
    }

    var fonts = content.querySelectorAll('font');
    for (var font in fonts) {
      font.attributes['style'] = "font-size: 16px";
      font.attributes['size'] = "3";
    }
    List<String> StringList = [];
    try {
      var imagesElements = content.querySelectorAll('img');
      for (var element in imagesElements) {
        String imgUrl = element.attributes['src'];
        bool canUserSrcValue = imgUrl != null &&
            imgUrl.isNotEmpty &&
            imgUrl.endsWith('.jpg') &&
            !imgUrl.startsWith('http');
        if (canUserSrcValue) {
          imgUrl = baseUrl + imgUrl;
          element.attributes['src'] = imgUrl;
          StringList.add(imgUrl);
        } else {
          String fileValue = element.attributes['file'];
          if (fileValue != null && fileValue.isNotEmpty) {
            if (!fileValue.startsWith('http')) {
              imgUrl = baseUrl + element.attributes['file'];
            } else {
              imgUrl = fileValue;
            }

            element.attributes['src'] = imgUrl;
            StringList.add(imgUrl);
          }
        }

        element.attributes['width'] = '400';
        element.attributes['style'] = 'margin-top: 1em;';
        element.attributes['alt'] = '[图片无法加载...]';
        element.attributes['onclick'] = 'HostApp.toast(\"" + imgUrl + "\")';
      }
    } catch (e) {
      print(e);
    }

    PornForumContent forumContent = new PornForumContent();
    String contentStr = content.outerHtml
        .replaceAll("<dd", "<dt")
        .replaceAll("\\</dd>", "\\</dt>");
//    String contentStr = doc.getElementsByClassName('postmessage firstpost').first.text;
    forumContent.content =
        doc.getElementsByClassName('postcontent').first.outerHtml;
    forumContent.imageList = StringList;
    return forumContent;
  }
}
