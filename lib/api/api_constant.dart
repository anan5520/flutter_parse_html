


import 'dart:math';

class ApiConstant {
  static final String pornCookie = '__utmc=136596022; CLIPSHARE=bd1033668b83ccabecab406267125854; _ga=GA1.1.989883256.1700751922; __utma=136596022.1398892819.1700751774.1700751774.1701260002.2; __utmb=136596022.0.10.1701260002; __utmz=136596022.1701260002.2.2.utmcsr=91dizhi8.com|utmccn=(referral)|utmcmd=referral|utmcct=/; _ga_K5S02BRGF0=GS1.1.1701260050.2.1.1701260968.0.0.0';

  static final String noticeUrl =
      'https://gitee.com/arvin11/json/raw/master/notice.json';
  static final String updateUrl =
      'https://gitee.com/arvin11/json/raw/master/update1.json';
  static final String urlsUrl =
      'https://gitee.com/arvin11/json/raw/master/upurls2.json';
  static final String upDateKeyUrl =
      'https://gitee.com/arvin11/json/raw/master/updateKey.json';

  static String xianFengDownUrl = 'http://phone.xfplay.com/';
  static String movieBaseUrl = 'https://www.ysgc3.cc';
  static String movieBaseUrl2 = 'https://www.mhapi123.com/inc/api_mac10.php';
  static String movieSearchUrl = '$movieBaseUrl/index.php/vod/search.html';
  static String movieBaseUrl1 = 'https://www.iikk.org';
  static String movieSearchUrl1 = '$movieBaseUrl1/vodsearch/';
  static String movieSearchUrl2 = '$movieBaseUrl2?ac=list&wd=';
  static String liveUrl = 'http://api.hclyz.com:81/mf/json.txt';

  static String girlBaseUrl = 'http://www.mzitu.com/';

  static String fanHao1 = 'http://www.fanhaow.com/';
  static String fanHao2 = 'http://www.acg3.cc/whole/';
  static String fanHao3 = 'http://haoren.sxylmzs.xyz:8080/?u=aHR0cDovL3d3dy4zMzQ0eXIuY29t&p=Lw==';

  static String pornBaseUrl = 'https://810.workarea7.live/';
  static String pornForumBaseUrl = 'http://f.wonderfulday25.live/';

  static String searchUrl = 'https://zhima998.com/infolist.php?q=';
  static String searchNiMaUrl = 'http://www.nms000.com/l/';

  static String siSeUrl = 'https://www.yei6.com';

  static String parse2Url = 'http://www.y4a9.com';//yaokan.tv  www.yaokan.com

  static String parse3Url = 'http://www.6b56.com';

  static String parse4Url = 'http://avzz12.com';
  static String parse5Url = 'https://kk77.me';

  static String xianFengUrl = 'http://www.pilizy1.com';

  static String videoList1Url = '://www.suduzy1.com:777http';

  static String videoList2Url = 'https://www.xvideos.com';

  static String videoList3Url = 'https://banyinjia1.com';

  static String videoList4Url = 'http://upup--011310.ccddnn11.cyafun.com:8899';

  static String videoList5Url = 'http://www.y9xy9x.com';

  static String videoList6Url = 'https://mnysm8.com';

  static String videoList7Url = 'https://mgaa99.com';

  static String videoList8Url = 'https://www.u9t3n.com';//https://www.a7w4c.com/

  static String videoList9Url = 'https://g52gf12633.5g4k6htc.xyz';//bbixx245@gmail.com

  static String videoList10Url = 'http://www.0008hd.com';//http://www.fabu28.com/

  static String videoList13Url = 'http://jd21j0i93ygrh9gamyn7.pipiapps.com';

  static String videoList18Url = 'https://eufdu.vwyag.com';

  static String videoList17Url = 'https://www.chafanfan1.xyz';//https://wanku520.com/

  static String xianFeng2Url = 'https://sexdaye.net';

  static String xianFeng3Url = 'http://www.avscj006.com';

  static String xianFeng4Url = 'http://www.sevovo3.com';

  static String xianFeng5Url = 'http://www.ai668.xyz';

  static String xianFeng6Url = 'http://www.wuppp.com';


  static String dongManDaoUrl = 'http://www.88dmw.com';

  static String bookUrl1 = 'http://book.wweebb.cn';
  static String bookUrl2 = 'https://tti23.cyou';
  static String bookUrl3 = 'http://m.tycqxs.com';


  static String liFanUrl1 = 'https://www.acgrw.net';
  static String liFanUrl2 = 'https://www.ycylf.net';

  static String bookList3 = 'https://yazhouse8.com/';


  static String douYinUrl = 'https://mm.diskgirl.com/get/get';//'http://sv.ismicool.cn/dyvideo.php'
  static String douYin2Url = 'https://xn--pru35wv4hgss92q.xyz/json/';

  static String bookList1Url = 'http://wenzi.tjshihui.com/api/bookdata.ashx';
  static String bookList2Url = ApiConstant.yaSeUrl+"/novel/";
  static String bookList4Url = "https://yueliang.cyou";
  static String tvUrl = 'http://cdn.dianshihome.com/tvlive/apk/channel/3rd.json';

  static String gif1 = 'http://www.wowant.com';
  static String gif2 = 'http://www.gifcc.com';

  static String yaSeUrl = 'https://www.yase162.com';//www.yasehub.com  www.yase775.com www.yase2020.com

  static String xVideosKey = '女神';
  static String abjUrl = 'http://www.aibj.me';


  static String getRandomImg() {
    var urlIndex = ['1', '2', '3', '2', '1'];
    return 'https://api.uomg.com/api/rand.img${urlIndex[Random().nextInt(urlIndex.length)]}';
  }

  static String getYaSeSelf() {
    return '$yaSeUrl/pic';
  }

  static String getYaSeBookUrl() {
    return '$yaSeUrl/novel';
  }

  static String getYaSeVideoUrl() {
    return '$yaSeUrl/cid/1';
  }


  static String getPornHomeUrl() {
    return '${pornBaseUrl}index.php';
  }

  static String getPornVideoUrl() {
    return '${pornBaseUrl}v.php';
  }

  static String getAuthorVideosUrl(var uid) {
    return '${pornBaseUrl}uvideos.php?UID=$uid';
  }

  static String getPornParseVideoUrl() {
    return '${pornBaseUrl}view_video.php';
  }

  static String getPornCommentUrl() {
    return '${pornBaseUrl}show_comments2.php';
  }

  static String getPornForumHomeUrl() {
    return '${pornForumBaseUrl}index.php';
  }

  static String getPornForumUrl() {
    return '${pornForumBaseUrl}forumdisplay.php';
  }

  static String getPornForumContentUrl() {
    return '${pornForumBaseUrl}viewthread.php';
  }

  static String getGirlListUrl(String tag, int page) {
    return page == 1 ? '$girlBaseUrl$tag' : '$girlBaseUrl$tag/page/$page';
  }

  static String getGirlDetailUrl(String id) {
    return '$girlBaseUrl$id';
  }

  static String getFanHao1(int page) {
    return '${fanHao1}page/$page';
  }

  static String getFanHao2(String type, int page) {
    return '$fanHao2$type~~~~~~~0~addtime~$page.html';
  }

  static String getFanHao3(String type, int page) {
    return page == 1
        ? '$fanHao3$type/index.html'
        : '$fanHao3$type/index_$page.html';
  }

  static String getNiMaUrl(String key, int page) {
    return '$searchNiMaUrl$key-hot-desc-$page';
  }
}
