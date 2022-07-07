import 'dart:math';

import 'package:flutter_parse_html/api/api_constant.dart';
import 'package:flutter_parse_html/book/novel/entity/entity_novel_book_chapter.dart';
import 'package:flutter_parse_html/book/novel/entity/entity_novel_book_key_word_search.dart'
    as search;
import 'package:flutter_parse_html/book/novel/entity/entity_novel_book_key_word_search.dart';
import 'package:flutter_parse_html/book/novel/entity/entity_novel_book_recommend.dart';
import 'package:flutter_parse_html/book/novel/entity/entity_novel_book_recommend.dart'
    as recommend;
import 'package:flutter_parse_html/book/novel/entity/entity_novel_book_review.dart';
import 'package:flutter_parse_html/book/novel/entity/entity_novel_book_source.dart';
import 'package:flutter_parse_html/book/novel/entity/entity_novel_detail.dart';
import 'package:flutter_parse_html/book/novel/entity/entity_novel_short_comment.dart';
import 'package:flutter_parse_html/book/base/http/manager_net_request.dart';
import 'package:flutter_parse_html/net/net_util.dart';
import 'package:flutter_parse_html/ui/home_page.dart';
import 'package:flutter_parse_html/ui/pornhub/pornhub_util.dart';
import 'package:flutter_parse_html/util/common_util.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:html/parser.dart';

class NovelApi {
  static const String BASE_URL = "http://api.zhuishushenqi.com/";
  static const String READER_IMAGE_URL = 'http://statics.zhuishushenqi.com';

  static const String QUERY_AUTO_COMPLETE_QUERY_KEYWORD =
      BASE_URL + "book/auto-complete?query=";
  static const String QUERY_HOT_QUERY_KEYWORD = BASE_URL + "book/hot-word";
  static const String QUERY_BOOK_KEY_WORD = BASE_URL + "book/fuzzy-search";
  static const String QUERY_BOOK_DETAIL_INFO = BASE_URL + "book/";
  static const String QUERY_BOOK_SHORT_REVIEW = BASE_URL + "post/short-review";
  static const String QUERY_BOOK_REVIEW = BASE_URL + "post/review/by-book";
  static const String QUERY_BOOK_RECOMMEND = BASE_URL + "book/{id}/recommend";
  static const String QUERY_BOOK_CATALOG =
      BASE_URL + "atoc/{sourceid}?view=chapters";
  static const String QUERY_BOOK_SOURCE =
      BASE_URL + "btoc?book={bookId}&view=summary";
  static const String QUERY_BOOK_CHAPTER_CONTENT =
      "http://chapterup.zhuishushenqi.com/chapter/{link}";

  var client = NetRequestManager.instance;

  /// 小说搜索词
  Future<BaseResponse<List<String>>> getSearchWord(String keyWord) async {
    var response;
    BaseResponse<List<String>> result = BaseResponse();
    List<String> resultData = [];
    try {
      response =
          await client.getRequest(QUERY_AUTO_COMPLETE_QUERY_KEYWORD + keyWord);
      bool isOk = response?.data["ok"];
      if (isOk) {
        for (var data in response.data["keywords"]) {
          resultData.add(data);
        }
      }
      result.isSuccess = isOk;
      result.data = resultData;
    } catch (e) {
      print("$e");
      result.isSuccess = false;
    }
    return result;
  }

  /// 小说搜索热词
  Future<BaseResponse<List<String>>> getHotSearchWord() async {
    var response;
    BaseResponse<List<String>> result = BaseResponse();

    List<String> resultData = [];
    try {
      response = await client.getRequest(QUERY_HOT_QUERY_KEYWORD);
      for (var data in response.data["hotWords"]) {
        resultData.add(data);
      }
      result.isSuccess = true;
      result.data = resultData;
    } catch (e) {
      print("$e");
    }
    return result;
  }

  /// 小说关键词搜索
  Future<BaseResponse<NovelKeyWordSearch>> searchTargetKeyWord(String keyWord,
      {int start: 1, int limit: 20}) async {
    var response;
    BaseResponse<NovelKeyWordSearch> result = BaseResponse();
    if (HomePage.inLsj) {
      try {
        response = await NetUtil.getHtmlData(
            "${ApiConstant.bookUrl2}/modules/article/search.php?searchkey=${Uri.encodeFull(keyWord)}&searchtype=all&page=$start");
        result.isSuccess = true;
        List<search.Books> books = [];
        var doc = parse(response);
        try {
          var tdElements = doc.getElementById('jieqi_page_contents').getElementsByTagName('tr');
          if(tdElements != null && tdElements.length <= 0){
            var divElements = doc.getElementsByClassName('c_row');
            divElements.forEach((value) {
              var aEles = value.getElementsByTagName('a');
              var aEle = aEles.first;
              search.Books item = search.Books.empty();
              String href = aEle.attributes['href'];
              item.cover = value.getElementsByTagName('img').first.attributes['src'];
              item.title = CommonUtil.replaceStr(
                  value.getElementsByClassName('c_subject').first.text);
              item.author = CommonUtil.replaceStr(
                  value.getElementsByClassName('c_tag').first.text);
              item.shortIntro = CommonUtil.replaceStr(
                  value.getElementsByClassName('c_description').first.text);
              item.id = href;
              books.add(item);
            });
          }else{
            for (var value in tdElements) {
              var aEles = value.getElementsByTagName('a');
              var aEle = aEles.first;
              search.Books item = search.Books.empty();
              String href = aEle.attributes['href'];
              item.cover = '';
              item.title = CommonUtil.replaceStr(
                  value.getElementsByTagName('td').first.text);
              item.author = CommonUtil.replaceStr(
                  value.getElementsByTagName('td')[2].text);
              item.shortIntro = CommonUtil.replaceStr(
                  value.text);
              item.id = href;
              books.add(item);
            }
          }
        } catch (e) {
          print(e);
        }
        NovelKeyWordSearch novelKeyWordSearch =
            NovelKeyWordSearch(books, books.length, true);
        result.data = novelKeyWordSearch;
      } catch (e) {
        print("$e");
      }
    } else {
      try {
        response = await NetUtil.getHtmlDataPost(
            "${ApiConstant.bookUrl3}/search.php",
            paras: {'searchkey': keyWord});
        result.isSuccess = true;
        List<search.Books> books = [];
        var searchList =
            parse(response).getElementsByClassName('slide-item list1');
        var liEles = searchList.first.getElementsByTagName('div');
        liEles.forEach((element) {
          String id =
              element.getElementsByTagName('a').first.attributes['href'];
          String author = CommonUtil.replaceStr(element
              .getElementsByTagName('a')
              .first
              .getElementsByClassName('author')
              .first
              .text);
          String title = CommonUtil.replaceStr(
              element.getElementsByClassName('title').first.text);
          String cover = '';
          String shortIntro = CommonUtil.replaceStr(
              element.getElementsByClassName('author')[1].text);
          search.Books book = new search.Books(
              id,
              false,
              title,
              'aliases',
              'cat',
              author,
              'site',
              cover,
              shortIntro,
              shortIntro,
              0,
              0,
              false,
              0,
              0,
              'contentType',
              'superscript',
              0,
              null);
          books.add(book);
        });
        NovelKeyWordSearch novelKeyWordSearch =
            NovelKeyWordSearch(books, books.length, true);
        result.data = novelKeyWordSearch;
      } catch (e) {
        print("$e");
      }
    }
//    {
//      try {
//        response = await NetUtil.getHtmlData(Uri.encodeFull("${ApiConstant.bookUrl1}/search.html?keyword=${keyWord}"));
//        result.isSuccess = true;
//        List<search.Books> books = [];
//        var searchList = parse(response).getElementsByClassName('rankdatacont search');
//        var liEles = searchList.first.getElementsByClassName('secd-rank-list');
//        liEles.forEach((element) {
//          String targetUrl = element.getElementsByTagName('a').first.attributes['href'];
//          var ids = targetUrl.split(new RegExp(r'\/|.html'));
//          String id = ids[ids.length - 2];
//          String author = element.getElementsByTagName('dd').first.getElementsByTagName('a')[1].text;
//          String title = element.getElementsByTagName('dd').first.getElementsByTagName('a').first.text.replaceAll(new RegExp(r'\n|\t'), '');
//          String cover = element.getElementsByTagName('img').first.attributes['data-original'];
//          String shortIntro = element.getElementsByClassName('big-book-info').first.text.replaceAll(new RegExp(r'\n|\t'), '');
//          search.Books book = new search.Books(id, false, title, 'aliases', 'cat', author, 'site', cover, shortIntro,
//              'lastChapter', 0, 0, false, 0,0, 'contentType', 'superscript', 0, null);
//          books.add(book);
//        });
//        NovelKeyWordSearch novelKeyWordSearch = NovelKeyWordSearch(books,books.length,true);
//        result.data = novelKeyWordSearch;
//      } catch (e) {
//        print("$e");
//      }
//    }

    return result;
  }

  /// 小说详情
  Future<BaseResponse<NovelDetailInfo>> getNovelDetailInfo(
      String bookId) async {
    BaseResponse<NovelDetailInfo> result = BaseResponse()..isSuccess = false;
    var img = [
      'https://api.uomg.com/api/rand.img1',
      'https://api.uomg.com/api/rand.img2',
      'https://api.uomg.com/api/rand.img3',
      'https://api.uomg.com/api/rand.img1',
      'https://api.uomg.com/api/rand.img2',
      'https://api.uomg.com/api/rand.img3'
    ];
    if (HomePage.inLsj) {
      try {
        var response =
            await PornHubUtil.getHtmlFromHttpDeugger('${bookId.replaceAll('articleinfo', 'reader').replaceAll('?id', '?aid')}');
        var doc = parse(response);
        var infoEle =
            doc.getElementsByClassName('mainbody').first;
        String title = CommonUtil.replaceStr(
            infoEle.getElementsByClassName('atitle').first.text);
        String author = CommonUtil.replaceStr(
            infoEle.getElementsByClassName('ainfo').first.text);
        String cover = img[Random().nextInt(img.length)];
        String wordCount = '未知';
        String longIntro = '';
        String lastChapter = '最近更新';
        List<String> tags = [];
        NovelDetailInfo novelDetailInfo = new NovelDetailInfo(
            bookId, title, author, cover, 0, wordCount, tags, longIntro);
        Rating rating = new Rating(0, 0, '', false);
        novelDetailInfo.rating = rating;
        novelDetailInfo.latelyFollower = 0;
        novelDetailInfo.retentionRatio = "0";
        result.isSuccess = true;
        novelDetailInfo.lastChapter = lastChapter;
        result.data = novelDetailInfo;
        List<recommend.Books> recommendBook = [];
        result.data.novelBookRecommend =
            NovelBookRecommend(recommendBook, false);
      } catch (e) {
        print("$e");
      }
    } else {
      try {
        var response =
            await NetUtil.getHtmlData('${ApiConstant.bookUrl3}$bookId');
        var doc = parse(response);
        var infoEle = doc.getElementsByClassName('synopsisArea_detail').first;
        String title = doc.getElementsByClassName('title').first.text;
        String author = infoEle
            .getElementsByClassName('author')
            .first
            .text
            .replaceAll('作者：', '');
        String cover =
            infoEle.getElementsByTagName('img').first.attributes['src'];
        String wordCount = '';
        String longIntro = doc
            .getElementsByClassName('review')
            .first
            .text
            .replaceAll(new RegExp(r'\n|\t'), '');
        String lastChapter = doc
            .getElementsByClassName('str-over-dot')
            .first
            .text
            .replaceAll(new RegExp(r'\n|\t'), '');
        List<String> tags = [];
        var tag = CommonUtil.replaceStr(
            infoEle.getElementsByClassName('sort').first.text);
        tags.add(tag.replaceAll('类别：', ''));
        NovelDetailInfo novelDetailInfo = new NovelDetailInfo(
            bookId, title, author, cover, 0, wordCount, tags, longIntro);
        Rating rating = new Rating(0, 0, '', false);
        novelDetailInfo.rating = rating;
        novelDetailInfo.latelyFollower = 0;
        novelDetailInfo.retentionRatio = "0";
        result.isSuccess = true;
        novelDetailInfo.lastChapter = lastChapter;
        result.data = novelDetailInfo;
        List<recommend.Books> recommendBook = [];
        result.data.novelBookRecommend =
            NovelBookRecommend(recommendBook, false);
      } catch (e) {
        print("$e");
      }
    }
//    {
//      try {
//        var response = await NetUtil.getHtmlData('${ApiConstant.bookUrl1}/novel/$bookId.html');
//        var doc = parse(response);
//        var infoEle = doc.getElementsByClassName('fl detailgame').first;
//        String title = infoEle.getElementsByClassName('name fl').first.text;
//        String author = infoEle.getElementsByClassName('author fl').first.text;
//        String cover = infoEle.getElementsByTagName('img').first.attributes['src'];
//        String wordCount = infoEle.getElementsByClassName('hits').first.getElementsByTagName('span').first.text;
//        String longIntro = infoEle.getElementsByClassName('brief_text').first.text.replaceAll(new RegExp(r'\n|\t'), '');
//        String lastChapter = doc.getElementsByClassName('chaptername fl').first.text.replaceAll(new RegExp(r'\n|\t'), '');
//        List<String> tags = [];
//        var tag = infoEle.getElementsByClassName('tags clearfixer').first.getElementsByTagName('span');
//        tag.forEach((element) {
//          tags.add(element.text);
//        });
//        NovelDetailInfo novelDetailInfo = new NovelDetailInfo(bookId, title, author,cover,0,wordCount,tags,longIntro);
//        Rating rating = new Rating(0, 0, '', false);
//        novelDetailInfo.rating = rating;
//        novelDetailInfo.latelyFollower = 0;
//        novelDetailInfo.retentionRatio = "0";
//        result.isSuccess = true;
//        novelDetailInfo.lastChapter = lastChapter;
//        result.data = novelDetailInfo;
//        var recommendEle = doc.getElementsByClassName('rec-content ').first.getElementsByTagName('li');
//        List<recommend.Books> recommendBook = [];
//        recommendEle.forEach((element) {
//          String targetUrl = element.getElementsByTagName('a').first.attributes['href'];
//          var ids = targetUrl.split(new RegExp(r'\/|.html'));
//          String id = ids[ids.length - 2];
//          String cover = element.getElementsByTagName('img').first.attributes['data-original'];
//          String title = element.getElementsByClassName('rec-con-title').first.text.replaceAll(new RegExp(r'\n|\t'), '');
//          String author = element.getElementsByClassName('rec-author').first.text.replaceAll('作者 : ', '');
//          String shortIntro = element.getElementsByClassName('rec-text').first.text.replaceAll(new RegExp(r'\n|\t'), '');
//          recommend.Books books = new recommend.Books(id, title, author, 'site', cover, shortIntro, 'lastChapter', 0,
//              0, 'majorCate', 'minorCate', false, false, 'contentType', false, 0);
//          recommendBook.add(books);
//        });
//        result.data.novelBookRecommend = NovelBookRecommend(recommendBook,false);
//      } catch (e) {
//        print("$e");
//      }
//    }
    return result;
  }

  /// 小说短评列表
  Future<BaseResponse<NovelShortComment>> getNovelShortReview(String id,
      {String sort: 'updated', int start: 0, int limit: 2}) async {
    BaseResponse<NovelShortComment> result = BaseResponse()..isSuccess = false;
    try {
      var response = await client.getRequest(QUERY_BOOK_SHORT_REVIEW,
          queryParameters: {
            "book": id,
            "sort": sort,
            "start": start,
            "limit": limit
          });
      result.isSuccess = true;
      result.data = NovelShortComment.fromJson(response.data);
    } catch (e) {
      print("$e");
    }
    return result;
  }

  /// 小说书评列表
  Future<BaseResponse<NovelBookReview>> getNovelBookReview(String id,
      {String sort: 'updated', int start: 0, int limit: 2}) async {
    BaseResponse<NovelBookReview> result = BaseResponse()..isSuccess = false;
    try {
      var response = await client.getRequest(QUERY_BOOK_REVIEW,
          queryParameters: {
            "book": id,
            "sort": sort,
            "start": start,
            "limit": limit
          });
      result.isSuccess = true;
      result.data = NovelBookReview.fromJson(response.data);
    } catch (e) {
      print("$e");
    }
    return result;
  }

  /// 小说推荐书籍列表
  Future<BaseResponse<NovelBookRecommend>> getNovelBookRecommend(
      String id) async {
    BaseResponse<NovelBookRecommend> result = BaseResponse()..isSuccess = false;
    try {
      var response =
          await client.getRequest(QUERY_BOOK_RECOMMEND.replaceAll("{id}", id));
      result.isSuccess = true;
      result.data = NovelBookRecommend.fromJson(response.data);
    } catch (e) {
      print("$e");
    }
    return result;
  }

  /// 小说追书神器源
  Future<BaseResponse<List<NovelBookSource>>> getNovelSource(
      String novelId) async {
    BaseResponse<List<NovelBookSource>> result = BaseResponse()
      ..isSuccess = false;
    try {
      var response = await client
          .getRequest(QUERY_BOOK_SOURCE.replaceAll("{bookId}", novelId));
      result.isSuccess = true;
      result.data = getNovelBookSourceList(response.data);
    } catch (e) {
      print("$e");
    }
    return result;
  }

  /// 小说章节内容
  Future<BaseResponse<NovelBookChapter>> getNovelCatalog(
      String sourceId) async {
    BaseResponse<NovelBookChapter> result = BaseResponse()..isSuccess = false;
    if (HomePage.inLsj) {
      try {
        String url =
            '${sourceId.replaceAll('articleinfo', 'reader').replaceAll('?id', '?aid')}';
        var response = await PornHubUtil.getHtmlFromHttpDeugger(url);
        var doc = parse(response);
        var cateList = doc.getElementsByClassName('index').first.getElementsByTagName('dd');
        List<Chapters> list = [];
        int index = 1;
        cateList.forEach((element) {
          var aEle = element.getElementsByTagName('a').first;
          String title = CommonUtil.replaceStr(aEle.text);
          String time = '';
          String targetUrl = aEle.attributes['href'];
          Chapters chapters = new Chapters(sourceId, title, targetUrl, '', time,
              'chapterCover', 10, 0, index, 0, false, false);
          list.add(chapters);
          index++;
        });
        NovelBookChapter novelBookChapter = new NovelBookChapter(
            sourceId, 'name', 'source', sourceId, url, list, '1', 'host');
        result.isSuccess = true;
        result.data = novelBookChapter;
      } catch (e) {
        print("$e");
      }
    } else {
      try {
        String url = '${ApiConstant.bookUrl3}${sourceId}all.html';
        var response = await NetUtil.getHtmlData(url);
        var doc = parse(response);
        var cateList =
            doc.getElementById('chapterlist').getElementsByTagName('p');
        List<Chapters> list = [];
        int index = 1;
        cateList.forEach((element) {
          var aEle = element.getElementsByTagName('a').first;
          String targetUrl = aEle.attributes['href'];
          if (!targetUrl.contains('bottom')) {
            String title = aEle.text;
            String time = '';
            String id = targetUrl.replaceAll('.html', '');
            targetUrl = ApiConstant.bookUrl3 + targetUrl;
            Chapters chapters = new Chapters(sourceId, title, targetUrl, id,
                time, 'chapterCover', 10, 0, index, 0, false, false);
            list.add(chapters);
            index++;
          }
        });
        NovelBookChapter novelBookChapter = new NovelBookChapter(
            sourceId, 'name', 'source', sourceId, url, list, '1', 'host');
        result.isSuccess = true;
        result.data = novelBookChapter;
      } catch (e) {
        print("$e");
      }
    }

//      {
//      try {
//        String url = '${ApiConstant.bookUrl1}/novel/$sourceId.html#catalog';
//        var response = await NetUtil.getHtmlData(url);
//        var doc = parse(response);
//        var cateList = doc.getElementsByClassName('cate-list').first.getElementsByTagName('li');
//        List<Chapters> list = [];
//        int index = 1;
//        cateList.forEach((element) {
//          var aEle = element.getElementsByTagName('a');
//          aEle.forEach((element) {
//            String title = element.getElementsByClassName('chapter_name').first.text;
//            String time = element.getElementsByClassName('chapter_date').first.text;
//            String targetUrl = element.attributes['href'];
//            var ids = targetUrl.split(new RegExp(r'\/|.html'));
//            String id = ids[ids.length - 2];
//            Chapters chapters = new Chapters(sourceId, title, targetUrl, id, time, 'chapterCover', 10, 0, index, 0,
//                false, false);
//            list.add(chapters);
//            index++;
//          });
//        });
//        NovelBookChapter novelBookChapter = new NovelBookChapter(sourceId, 'name', 'source', sourceId, url, list, '1', 'host');
//        result.isSuccess = true;
//        result.data = novelBookChapter;
//      } catch (e) {
//        print("$e");
//      }
//    }

    return result;
  }
}

class BaseResponse<T> {
  bool isSuccess;
  T data;
}
