import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_parse_html/model/video_list_item.dart';
import 'package:flutter_parse_html/ui/movie/movie_detail_page.dart';
import 'package:flutter_parse_html/ui/pornhub/pornhub_util.dart';
import 'package:flutter_parse_html/util/common_util.dart';
import 'package:flutter_parse_html/util/native_utils.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:flutter_parse_html/model/button_bean.dart';
import 'package:flutter_parse_html/net/net_util.dart';
import 'package:flutter_parse_html/api/api_constant.dart';
import 'package:html/parser.dart' as parse;
import 'package:flutter_parse_html/widget/dialog_page.dart';
import 'package:flutter_parse_html/model/movie_bean.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart' show rootBundle;
import '../../model/api_bean.dart';
import '../../model/video4_top_menu_entity.dart';
import '../../model/video_list4_video_list_entity.dart';
import '../../resources/shared_preferences_keys.dart';
import '../../util/crypto_util.dart';
import '../../util/shared_preferences.dart';
import 'book_page.dart';
import 'package:html/dom.dart' as dom;
class VideoList4Page extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return VideoList4State();
  }
}

class VideoList4State extends State<VideoList4Page>
    with AutomaticKeepAliveClientMixin {
  List<VideoListItem> _data = [];
  late List<ButtonBean> _btns = [];

  late RefreshController _refreshController;
  int _page = 1,buttonType = 0;
  String _currentKey = '40';
  bool _isSearch = false;
  int _type = 0;
  late TextEditingController _editingController;
  StreamController<VideoListItem> imgeStream = StreamController.broadcast();
  @override
  void initState() {
    _refreshController = new RefreshController(initialRefresh: true);
    _editingController = new TextEditingController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      body: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.all(10),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: Container(
                padding: EdgeInsets.only(left: 10, right: 4),
                alignment: Alignment.centerLeft,
                color: Colors.white,
                child: TextField(
                  maxLines: 1,
                  autofocus: false,
                  controller: _editingController,
                  textInputAction: TextInputAction.go,
                  onSubmitted: (value) {
                    _page = 0;
                    _currentKey = value;
                    _isSearch = true;
                    _refreshController.requestRefresh();
                  },
                  style: TextStyle(color: Colors.blue),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: "搜索",
                    hintStyle: TextStyle(color: Colors.blue),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: SmartRefresher(
              onRefresh: () {
                _page = buttonType == 1?_page:1;
                _data.clear();
                _getData();
              },
              onLoading: () {
                _page++;
                _getData();
              },
              enablePullUp: true,
              enablePullDown: true,
              controller: _refreshController,
              child: GridView.builder(
                padding: EdgeInsets.all(10),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 0.6,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10),
                itemBuilder: (BuildContext context, int index) {
                  return getItem(index);
                },
                itemCount: _data.length,
              ),
            ),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_btns.length > 0) {
            //有选项再显示
            _showDialog();
          }
        },
        child: Icon(Icons.add),
      ),
    );
  }

  void goToPlay(VideoListItem data) async {
    if (data.targetUrl?.startsWith('http')??false) {
      CommonUtil.toVideoPlay(data.targetUrl, context,title:data.title!);
    }
  }

  void _getImageBase64(VideoListItem item, int index) async {
    if(_type != 0 || _isSearch){
      return;
    }
    Directory tempDir = await getTemporaryDirectory();
    var path =
        '${tempDir.path}/${md5.convert(
        new Utf8Encoder().convert(item.imageUrl!))}';
    if (await File(path).exists()) {
      item.index = index;
      imgeStream.sink.add(item..base64Img = path);
    } else {
      NetUtil.getHtmlData(item.imageUrl).then((value) {
        value = value.replaceAll('data:image/jpg;base64,', '');
        new File(path).writeAsBytes(base64Decode(value)).then((value) {
          item.index = index;
          item.base64Img = path;
          imgeStream.sink.add(item);
        });
      });
    }
  }

  getItem(int index) {
    VideoListItem item = _data[index];
    _getImageBase64(item, index);
    return ClipRRect(
      borderRadius: BorderRadius.circular(5),
      child: GestureDetector(
        onTap: () {
          if(_isSearch){
            toSearchDetail(item);
          }else{
            if(_type == 0){
              goToPlay(item);
            }else if(_type == 1){
              getImg(item.targetUrl!);
            }else{
              Navigator.of(context)
                  .push(new MaterialPageRoute(builder: (BuildContext context) {
                return BookHomePage(_data[index].targetUrl, 9);
              }));
            }
          }
        },
        child: Container(
          color: Colors.white,
          child: new Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Expanded(
                child: ConstrainedBox(
                  child: StreamBuilder(stream:imgeStream.stream,builder: (_,_snap){
                    return item.imageUrl!.endsWith("jpg")?
                    CachedNetworkImage(
                      placeholder: (context, url) => new Icon(Icons.image),
                      errorWidget: (context, url, error) => new Icon(Icons.error),
                      imageUrl: item.imageUrl!,
                      fit: BoxFit.cover,
                    ): (item.index !> -1 && item.imageUrl!.isNotEmpty)
                        ? Image.file(
                      File(item.base64Img!),
                      gaplessPlayback: true,
                      fit: BoxFit.cover,
                    )
                        : _getDefaultImg(item);
                  },),
                  constraints: new BoxConstraints.expand(),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 4, bottom: 4, left: 3, right: 3),
                child: Text(
                  '${item.title}',
                  style: TextStyle(fontSize: 12),
                  maxLines: 1,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  String fromUnicode(String unicodeStr) {
    return unicodeStr
        .replaceAllMapped(RegExp(r'\\u([0-9a-fA-F]{4})'),
            (Match m) => String.fromCharCode(int.parse(m.group(1)!, radix: 16)));
  }

  //获取数据
  void _getData() async {
    String url = _isSearch
        ? '${ApiConstant.videoList4Url}/searchs/?page=${_page}&keyboard=${Uri.encodeComponent(_currentKey)}&classid=0'
        : "${ApiConstant.videoList4Url}${_currentKey.isNotEmpty?'/category/${_currentKey}${'-${_page}'}.json':''}";

    String response =  await NetUtil.getHtmlData(url);
    _refreshController.refreshCompleted();
    _refreshController.loadComplete();
    var jsonMap = json.decode(response);
    String cipher = jsonMap['data'];
    final plain = fromUnicode(decryptFromJs(cipher));
    final menuPlain = "p7sX2GqRPDXC79b4cfd5fsJes4jzJjDabE_D_qBSkB5UCeyRlUYvcEKXDAhkecXGNiBzcQTN6QXvIX1rinvwNOg22mn8ZPz1fYQoO6oUXro60sHbpExL27iMT0fQ3iASlvMpIaMCplgWS0myEoXPEm6-r3u2cbS517uJeatWJY3V2-Ap0wXqr05IQZ-Lr3ofjtOHFY7aJ2S9DhV9n6E7MpOz_YGtrZoPxsvkBN7y08ihBjZI7PUNu8PFPK3ZcDcHviCtDMgLK8omhC_P_Uw_HleWIJLwPj83cnvHN60-phLxBSyA1fDk0EGzuQH_c467zdAX88KpqPvlySap3xe7YxrJQaLxGmYwXjD4sHeeEuFZGTrYm8g7J55umYJahR7_Km5EYXn402A5F266AX1qr0TGVnHk25OSon5r1uYK0Jasx-o3EfGjmJFLJ5MF2j3laIfgiRj8sz1M-pDsnq4U4EruzbyqsCuRM_kPJZjK5Mf21eSKFm1bvU37jY32UBZy9wuXILXtV6sffpawAmicXd6lvtxiJRfFLI9YSfAT4B-DFw5lxpgB3Kj04ZST6f3Kq17ej4xQH4JCZxLJMtyTcjHLPiaEux-f8UOsig6vYIPhx01AYnl_UntpXXIQVD2nGJkYAGNRWD----TdE4dFjpFYqMHjyOxIt0aDJZrtVQmdJCOXtxL3ha9wE9B_AMXFexYX3XeXg-5vgXZ-yloKqPhn4ofb8d30IJC49BeSkvmnuak7y_owEBKIM6bE-ODZYFvLWmeyK7TPd__gLVKEOx9aCa9qxr0ghOKpe-0qyvTX6h5ydXM--6fHYlR18A0s0DCH3TzpzDw0RpXteP7zg0lPGcoVMpn00QliPLeRtW6bGuvVnodFfCzRs103HB7dGf0fDR1nJ43jvSWGiOuEa7-3-hvkdFWBLpMxHmysOQbuwLT1SlQ8YGmoAMM3CX4HNmtUI_ooiGEqNKRvcHHfPLaJuW0lbJ_bcOWMNKfoaAFQ4zQgPBkQQt2nxm0bbw-hYPkpkZcHblzNGghXhrpGe-_qs5mLhAa5qFQB3bHhUIspz_0NlOeFnpAkMZHG6g3JnmNsa4o_xkoXAE2I2J962_Dzw4XT2IGh0Yjv51-xJfsrgdbkZjVZ6EBx1qbqmpj1MzdXTF16XsbxWNIvgBLSCcPQUApJ1Qda5YQj2o3b5IcGFBBp_xkN0FpY3z7Gm9yM-rcgC_dph_ShUKutpEXOfEjQ07RORolNSC8ztAxq3MzPrgvSA7xim6tMWx0S3vZTU1-_Q_aosDIMQRezft1BwMHngxnnpRhXFohdi6U-tNY5AOJ6LKJnH6c8a4cQ27XjoLKTIAY8HxnVvKF7Cc9ZLHu9YxA475SeFmsphCVQ5EpMAxz1Kw_D05VvlVEGtg-CnJrY6Or-zeKGwpyJEjTfzRUwvE_OwiQ8oCwHOLZaoRhGg1_h-ld6baJ5tgQRXLG3hh-cMfKcNTDywG3pCODl05oy_FcRtCA1OZm-Vzd5P2scAHF4_ll-74w1X1jwos_yDR64uAG5cC0dVTiL8iW9LvR08PYCsdaWNiTKQ4wiKYLA8MNWgJGs-_-ZUDSFz2NAoEUoISTn5N18P45BtI7_KE4uxyXCwZozHbfOigXEed8KYJUlPEX0D81Rlh9u-nvNOL8o2SIXjE333SDH51Mku6J_nFzzU4eDgV2pLvRfOYmWT4fi40Np4BB5TmUZLSn_dCOw411izQYrAMzjiQDTI1Ocqm3EL4mkauHDLOQe6vEjMPcKjdm5tRQKMT7eIimtrx-zQVxPBs9ReXNtMcaLW4MQy4s0RGqts7ptaqk3uWZls8-T82F2sGZ9ZMPSqrcqfhpN3KmX-T7nhmyAF4mGq9nNK0gHPI_gx8fNChFl0vQKAwUNZClVc5UGH6f8IA28d6JBeFs0EKYQZCo6YhdWfaqUZBI07Txf-wy_bB3L5iqDa1hFbqskzEXmoEdc46B4_rbYrCykL6QRl_d4ProIeQ3RuqsP-lBqh8cQnlia20gG9Fpi_78f6yhuKZtBdFHP8jQ74YIl5DSamMuc2dm4FkkPCUMyVwC5PXj1u9FgLH7akCpRSi_Q6VrujRXI_3Bycld81YkqKBonAGLQt85GmFcEL1hKywHVW2KtKwdFPABPk1eKnMRKV7siBU8zIGtb4sBCK_GANOgQeGzhpc6_SNURA-Ohjhpne7EWiAbwQmk6fmiaC0IMGjygVOeCJtEun1E3u2Jlj8OkpYTeus-RSF_-u9CFZsPAIrYmFa9fakvhptRcGUO0rXNGyDCFKc5M-nnmUBRwZJrh-ny9lHy95oUQK40aq-ArnRzHs4AH4Rlt2ZAPpu3c8EpyBiGKCVI-ZpoupeJ8QjJtoZKBttsHS-Z25L2-dcDx06yzU3DH6imfTuRAMHyJd4XT14RxbHoUuOgYIgjYHroWxhWDZS8CXi9jk6B2czeG0Kd0MNp_eIJEOdHBgPhr45JT36Uv1_fP9dSTkYdTKoZON44XQKf4szbOxOJ3rlUcMQ2CugDLBUFS8GSq051OO5p4N49Y4M3gDB7YxBEPs6kupDTUkoMOkPmM09d0vjgbmOLQTAhc2YKMLrt-rlRE4loomL47judSbezqCxra1kISOp6Mg6-DJXJIANxOw_slDEiLxJaj7srcpsOJOGu5iep0ZZJWTRAm1f8y-17mt-oKmpAVBBg5ENDuPsNAvnLliKJ4qQIk_l7mNl9z6WOKacOyev-pxXgKMcwXbgvYvIsLVvl0jw0BBitD8fFWGbHOZA3rACPb2HsLaeJp0RRWdF_RWuHirgfSOI3Ss6MS8jNSRueyiAR6cpW2evE_6qR3hefHF4sAJnVMFVFoH41BVd6bfATz-ypf2U1d8VH2qdkKbnGy-OY_8VomR1WxYKxXp1cVkEJBi0nN3B-gIZCnK0od8RPzxejAuOpABDH-_OKShf0rfttvBkPQTQzLk0WRXdpZafRhBStn7jmEv4fAj5BEHwHCxewgx4wwrQ0WT_z35CSXL98a7cG1Z1md3KHKRSMspYCT-5gGsdhovwIa0SS9uZboOS-TNzeOPWGuBD1cB37CrxOJezQRKvkG02EGsCS_ZqojhReo9ES3dpm15Wk-fr8QU8RdTg_Uobk4AXtI0Tguk7mHn4zFFQ91yGgNCHq7gFpFIgoiCUmZ72Y4VyqX641g3ktytQQ8oSRL7Ove_qeHA9VAUOkHrp4cpyszhFhOiS0LZ30i6a1OL1TZ2EjJ-xOVjGs0L3HGnh_-yKz2XZoH-SPQ_OU-6Ov4a2LhKPvkuaAhZgCB_gRzuZl6uHb9GHZFwtz5Ph8ITYKFA6beDwz4c1T_HaQ0IDAsGoDf158qCej2drRoeHIeuGyXtJoeoj8R2KnI9qE09ll6K9UIEyHj67Ofk9szBsjhJ_hFfXadeh-oYaDdRuc4alJmMyipP4x36GYZnJShuvfEtehwHyI5aQc1tiHaofhsGTlIPvvEJWa-RyQkDATpccBShKO-ZCCI3tjwWr944EBsI3eQxg9GeHxXqUKvWYl-i46GF2YG9zusX9mQVrQSuYiAdSe50721P3tLYLVISCoIvh2GgaTtVlpT2MNqqHWQFkDSdvixm1cJBEhwidNoB2FQiaMn8Sr0TxSEQvQgzkrneq7ebH-_D8R64sL_675l3ludMSdinKRvK-OEUCEm_hcomXz3g4RYnjQcqcy1Q_4ypX6oZuTVgMqp6o5WYWdI3TYW6mxw9R0dDuvz3STBJqSb4sei2dRJQcOyQg2ZNi2wioX0VRDmLkL9nfG7WWLehZjLjAkv2IgGvms5h0u9KGwqhfJDHUA1CraPSdu_0ERplwB9etaRop5kRpanWZoO2q9E2YPS15qqSxU-_rLcrf6Fl6bIwyKsu5xRlX7oKioQzg_3b8PyDQWrSqF-VlK4gKsSABe5Aj8_7-BFZQdwwz8geI0x6SV51nKTzCMuBG5Dw9GH4tyzniXISINSqqDABVw1cTjEyWMwndUQo5tRoz5pd4QGPb3MDQL_MFfcyOj3Cwwdppld9S7dJEWebJMQH-FYQSROAMcuG_PKNBcq3yDS2DKfbuih0g-4D1L6_2ip6aTwrlxf9MghZEWmy5RLj8oI4AsrIlbRdnxjH6qz9nDTLaS6g8nw5M5PabWF2dCXR4hl5AnEig54HaPdSrw_LPQEIk5fMQeuxu66VHsR9lMk5cyltJNahJNACAPf-eCxt3IUg7vEiuZ4nygzzfSJ0F7gqCIrbyGsXZcwGEU53vPo1HHGzYV9NSacm9YZRnOIK048lsZugHVpyXYRRqfs7yMAlUoKqrR7xrTCpl5jMxvhl8IJxKnmV-CgJWA93V548pBRVXGvn3rKJOKi2QpZfOHHtY_1ezLuLuK0UJCGggWxXL3LHyUIeLcRR7H5Mz-Ip04uZxmNVQMk0s8p-6WOmHwd0DQ4ZqqKzxvcxyypbTuwItigUntraefcz9ouQUECihzqz-iakk78xhjNHERpm1XhIjkGoGngSHa_tbPQ9jhsP_fMdNnx8RUd6juSP6Z3jzfGRKoLFKbCYUuhbZA8-moJTns5cKjV_YP_8WEr16yoUECFnzbOvMoT8pw-z4LY1wQyl7_QPF2XkUTCHLVVn0OSWQLNLin4atDfLMKYSOeE9d0nE2mRC7Z3Galt-4pJMTREbzabHBgWjqVYedYeZduRE9cHYEGtvrHFxayhxPBSIuF7cbpBwcR46pmcJOl6S9srAf_SqSHc9OJ1VOEakFigKTufR8-ZAdtzBBLSflNvG9oIKfvujxFsj-jbHKl4e3jXtECk6q6P1--v1GnLk9eVmQ9XHBCiknQG3i5nOeTGQy4QgWRe0diqD2CqoU7FLoDd5WJensDhQvGtKJ4bOmkyiwlmZftyQ7LQkLk7cVTLthkmbXrf3nUKnIfvn1I2l0SQvs347XjHlQrOtdT-5uKl50f6p62MJL9G2dNW0xy6e7bNFsZCwHOGEvvDUV7PQ8BJ36JPj1hGkT639OGq1hslyxuGeesGdM-_koTLUHQe6g6hF6zRjdfGUBwMSbT3FMncSeqXUyFtuwZDfWIM3POxlCybXFx2Xq8HE4IBgnONjBSJ2yKmlgIJA9FKVIsxmeKqgIENJQOOOzgbrXFf4ZPOdIv7x909jWuCoVLV2OfVCbDBSNPYpRqVCppxBiPPLS3YRZ6zw-U9hyk6cDvzQslBLHthcPFlLVtEj_Cd8NQ4-6IsR_7xIYCiIiFYe7iZNNSDA3Ai_VAAlk47GhlE_Dzm0upLYAW9fxEzV9jOgyADR6iuyBNnworIyoRyJ6aFROfSpsfKPPE3YeR0o97ZYNOsVuggpVDsf1Pj73ABUb_b-XnVbPtEHDxYAIE8US4PkTFJWMmntIvhwBnQeGEi-InIhT7WwkaH_Q3v8vtjNTmqVIUZb-z-WCwTBEO2qAFR0egxPKqtKvs7qFDDCWgynSl_jShblAjvSRjnCzHcipgdeYVl36QGvREkEAqyGGCEbLaDqyLb1y5fBZuZVhKcSSIxX3L7WvmkH_8irQ3vsEAGxiDDJ3VOdxJFdUvJOfF0l-O_R8BCXkW3EcGOD7RPp8BeVBiwWd0KvhQIvaodTYWwxYInOYGH1AAAGGFZSqWkzVg5gVIvkIDpClLeVu4ka9cMXiSm1NFLNjO9hWuzH0Bw8WK_u0F-iNx0cdSft6_ydE7z6va8y3zUYXjpTXpXQ0XDurJjn8vhePfhWHc_cXVi9MduKfF0Z1gxfiWc-1WZGjDiZfhuS2gcptjcAcGM9kuNwld_HbR5nQv6OpkOmoiBTuZZe3ECl7pKhSkZq4F_H9NPNmN-ZbwUTvzDym1rctLcEGpT9xUPvhTHCfurbwNuDdwy7crxmb-bl5y8MMCpgiS9Jn7X04GujPjqjGoPDkDdbF9XrrP-5hAoz_igKPsBLBE_rxVhDNfermNXdsw7yHDjuq08N67lUY9pCtGMmdoc5zMSb9FMylDH7apRbGQWQNEOe3CT4UjCHmgzolm054i3voutmfwcbhOQoxOVbIubXK_U4GLHOPqgAY-Kzyi6Wd2XqZ1NrVIlHiD6oxvTHX30k7Tia8K7lUAPH8iQdY2XECCSpcHEHqMuVWMvjIGR1j8XYOkNtS5fFyqcdyeFzYeu2-YKZjgvcKSQBpB_l52QeMRVCgJy2pltspV-2UitPCwMcr1yVimlb9CZ_ODJVlvghv0d0sFBifR-558MxF6cd0D9zcz0dE6RoRPOB09jqwhX9shMhsBm56F__GL6Uhf2ROFgAmEJ_FqDPanGJbr1vcEHOQP1DepgwmRpzDslP8B5AIuzyZzjntYpHsPSnbuhHBTIBfJ_tPCgc1xrqzzRfSI-9R71DB25AP2lAdE_YBhcaDu3hFf727S95Sydk8JnQAeO3t7xrWsYMDROn_Tr1DFB3diciKQeTaOp3SURRO-uObfNtSgoZlRYUWX4rMPs4G8xCPTLrLtg545tthg_Q9coU3o4UCPtr8Mu3bQfizya4zAgvAorA3J8lyX0D93bP0b-_G3Q6A_uQmMv9ryHI85dBEDHKkiltQjV7gQYQYnKdj1DoLq50FwygURBS1qRvqupUl4_MdmNFvlITjfWXOMJMMu1xA-T8oE7HU6eE-yN4yvuilXZMMQA3e6Hqv1wc5FaeaQJYzIwAoX3tfgUt0xR5xa4evNMTHGrbDCCCuEqL31jqI_9VtwmwdrGA-zhTdCtl_GpE9gcNiKAqXLkKf-f8j6kOsBYV9tNwkyNWeeKngLE2aZP25uCRPFPLlJ2ISjZjLVJsUbk_yDVUVvAMiEsICsb9BHsBCPUOEXPNY1Nuh1_nDVlBAAH9fKr7yKhyh6zhTvtGUpwYIAc7bZ6CstjebzWRQkozt96XbNlcaecqTH84km0BiVGS2MU1xjWpDNOuG9VqcLu5CnI6WSB2j0mXvByAdt7xV79dHZZiR07czBVlTWMJF3drleCL_ZQJ5BUEKfiYltGEPHe3nAciZo8I9i6FCann0cfMZ3tncFFXCb9lKWaM2f5GzQDxeCdXXxsp0SfYakN4ne4y7PlEwcfPU_p2OXJiTWqS9tUHkTjp4p0vSffAgPB04IYXLOyQd6uXOkaQyaSuV45La0QiFH3YNF5nK6p2ACy_RvTv5qHuqMBj-iISWkMdt59McEvsWi5j_0FeE1RVif3l760K2_iy-b5vaQJKfZhhPj4iMcq5YoXxod56GUJ6TLIPro2SdWHJOEv_G7P8-K7bW6NHd8TdV9t-JD9g-y-Z_WV6-MUN7J8Z108HdV3ZuXf9hJX_d1MIimTtYZSdrU1LcgdE0x8ssY6dLb3sBV2I7oj8UEEJ4l_d-U1a6AcHGB4tu6Wy3_Tk5j2VXtwt1bg2_xoU67rcWCI4I-CTRNBVvqwflW7bUQDgzBFBmqeyFr39kUiHCZCsuJz5BNPR5_L__GVdvSbAuxZLY99bRP40PcWUy7Ox7DUjDq0bgM3NaZHVtjErmEXtUEltoEQb6EFuQrXosVWs__3v-ye72hZ0MSQIs-l_Y0Fg5bILsXdF3hPRNfIRxekjIxPQCCnw0Wt0hynn41qqgw38r8e6JKVlV8X3QhHogOvhjTJOsJdXZjmqF70gzUYDkzn0CGU-kDVDS_gozE75_S2FLtjEIPsvRyrAQhmQSbmIppMRoQWdqoKHsJo5mWTIROqCoBhR247yBdx8uL6UqOm0Gu2EzYDK6z7I3I-Lysj4wvEGzbIVc2R-UTFC1d7ETtslR376U_vmMgmUA9uwriIaCsPrn_PugHc4G7KW_E4UBExe9pqjjO_jRP4iXyO-ErCf6bbfhsPXuHRkMI6oLLQDdMf0hajwzgLkQo-avdqXWfd8I75tA-IKaP0C2Cj8wUFOodwIkLJlEYkozc5hcsXQYo0lQ1KOvuxrW8L5CX5-9Bl6fMZ9puro4nKkloAB6LFUnE8-kgzHzMGcFjpKP8G98hau8HzY-Y5xSFHDzgLBejg71WCy673kCyTh6AqyZ8VtpB264NigmzYmNrXTiR7lt0u7jnpTet3lmheM_am34_z_VmgfPpjJMy398c5GSDnWovtAUL-bGfLv2XIQtqJTWy97fsmD2th4OExgnHr76f7c-WNz_coxeYeBM2-Qv1FhcpSKuskNiSyuYND-m6-mj-BzOqdjOFIKZrko5vN8_77-kk7dyFRYMoEFE4sdEruZA4Qf9zTHLyaduzn5O0N2C2p7ME7H2YNLcNtFSuU3uWZDZT6Hp2AzU32hKu_Fc_9fhKDXjGR40AmSXOF-q22WlM-oFxHuq5La2n9gEFVCBpN9LxX96To2riSadjkS7okHAitmaAoUANo3jQS1XuXA0aQ5IBtcT4iouJpwuCIU5oKZxHH1j7qti_vU1JKWpRShERIkPaEOthLOQ2vXP657W1U1UlK-ZomZ-a8ogzk_9CoqVw9sNi6oSqtvnz5SbI_49O-H1S5Tcwt1GJJOncUfjIvLrq1Bs0XR33WlkxCLl0MmUIHXZy47hGJJd4_I9ZlrhlunST_NVtMTd7PlTldIVCJ8HGI3mALcWZGyLuCTgU7baJ-maXj6THNys-xuW7uHpDxUQern112KZ_I3ejKsdAOH5aRE-Fx92yXLvo4TB4oaSV8TLU-E-qWStVUER5nVrSrpyEzLLQ7v4TglMD1fzzKMDgyvcrg1qbAktOZ2CYBIkEW86Uaw6XdGZVRiQ9rfPkiVytvLt1J3iimmg1EzOZha9t4yxahoAXWNVNgkhvqhlGejWuSmD3Rh7C_TbFw_JFbGqLSem_K8K-ibLSdhBz2s22X5Addee6csUwKnBIznOnMAIkr4VzyqvV_FiUkX_HARgAU2Q6JmC1hyyvYN_C4sP_HhoqDQ5PIUcikQTzV7qckPnElQe1VnAvjrsTz_yccpmZnTnthcB_m5KByrWOxqum6hVIhBest71TNzBd_hi91b2NzH2CF-4J2A3yaKpPBqRqRHFLM0GdJMNTnngKnRK2FujkC-1ZXBzVvHpW32CiTt9wXv8iRY50Xf1M24qe3i3Mhg7Jrsc2Pdlt58WhgCIea4PhU67uzWzRQobV3oKtT4Iqm7TxZvrCqbaWJjo-YjwGh2-OzIe9QaCKUqENuKPQbj1sYlJwf33sSiRCBWXtHKwmc_rga4dJ3OrnT8OWkiGTGw6hX7ESJgt4JZqBxmzUhQn4voP6GJEJ4cLa-Dz6sh8jDLUqG8Say0YkdVg59sn5pPF1DePCWhZ_zesNHu1wSLGc90102sFOIj6XOANWBwoOGY6q11GSVOCEFi7CXKVEyRKw9hS9p8XIqY9NPcoxAFVnMpOKG7GQp5jgsbmyOQeCqt_0Kn6sxaV33RA4-AIOJ1p7viYgRB0tCIitANPqkw-aWpKG4aUwNEYDVAvb8aDGg0JOoCIaDZNNrXrEP6bZSTjCUajTln3O2a0HxWBJi5fnHU8pzekfUWHmlmmgJNX8kDVWz96Q1RTdv9Na0OXgS-AAbE4Dys9PQ_KNgGKYangfI5HmLg4fr77mnIzPwypAt-Z_tQYHXYCR_qZxHIEhyqnlzEv2SzL94TXcK09IplhZbg1_iP0BW_JhGiqVJmrZl2NNkTu0fNsZ0n3kgbCHeolZf1CoZh6G_bCUHE7rkwuHSYgMguqoZt0BhLNDh751JqtZYRF71dckXmYlRTCcDYaOWiaHRHM1fjiJz4l_klxqNt5__E0renP9X8ZG8ldGNEfQ0X2tFWG-wuLo-dFHcjTNELT_Ua4qejiTNVjffNwPhfuKz9ooWtWqHyXjDRdH-PhZ1LMELgAvQT_2uY5L6FS3_r7scsuQJc9h1SJdQFqNjM-8NBGtT9N7GZbr3gPBNi7ewjricMBGLglXOA7OgXQrgq6YnACgsCg5xxF33Ldqv2QS9jnzGU5tffO6Om9qkycwqg6IzjYTbeR1yjXB-h7QSubk43C-LgRNw6H1rGl-deNKzLtGCMq71tZLo-LPyATHYYG-_Cn0f6oqXuPY-njrOw8A4BqE-F0-qe-vGxrBxFn7apymNvaqGfoY9zqr9_xALJZMTkI31a1uDG4MEhw4437ufUZzJz21ExIbEMlHihoBKB8QSY_OpyvTn0ZpqkrgZIi3vvdw_ZxokiKiad_a_cgUz3S0SvDCujcBoIrisA5br798oFN3y-bB0G_nCGOQQJpKTzvN2rGxVphDHYtKdvEBQKgVnn2F-q-S_0GfXoiewomtJV-NmbRI1ddLtUczwnhxW5dNHMQLjuVO2qnDx7H2cADX0HXjnGtaLgoLRjxBmVOsuc5JZbDeUPH4h8IJ7zaUdr8R6DShSHg2G8nyym9RvhLWj4EBn-jHFxnNRhk9_7Mf-Ixm6SAC87Nflt4AqPa7any5idgWU5BlPH8cr9c6RznJ3XD5UFVTxiH1k2UvL2-ZQxR2MPZJ7J9ilNxoyWg-_shSw_4phpICusHMMWHtD8V3-7-GExGsv5gfFI4ww983_O_btVZID7iR56AlOPc7uMzjTmAKKiG4Q5bE4XA1T5pebEIEwfxce0EqxjZJNLSiMLB8wFeIku9m6ksmz2JCrYf1PlsHRcng9OZVPxr-OCPQFDndI4edtlZUP7eMjxYKEJblPpICkQoJ6cwSNWI0UVXXQ7f3EutIAHCtekAn4-AeQwndutkxuH1Ohuwnr3_VtwqIHjoxTFvR21uzC0W3P28V16flvFBLZy7OXUaYehRZDCt5_M5YS3u58jhnxqNEMmu9UcJYta_CCja9Vas51WI1BP4O5XeVzsph-oFHy8E1bTRLxHcKjCNON-a5p1HNtxbjVuwvkic8ID9GihQ3grMzeBsev6kBHajbnCNQ5DLqtbbMl9HRF2vsaCD8dcZZd-rx6JxO9U7RZiVAdXi6Wp5IkGToxYOW5iPO44Go31FizAPuOiA6yhDa6dVHihBgxJegpL-M4NpF0XcarfWtOblHrSgAXwG-bErgh2u87t6LOjbVhZaR58vWSIBKpsdPYL_9hvn1oCMi4UKjeebBfIvFjTbpKEEGP-NlBDvJGNdNgUsugi_mmJg1fVaXLYct2R4-U_uk68jHjJWVAZeRScDLSaLuUO-kJMu183rQAUmqwLfpnalYMLUBFsxdlygex1DiqpMzpIRlTRw3ND1ImBK4HVoRFOqwKL9C0bpI3oI_mxeW6qyP6DHEahKrFJypRqi2AUUyWkxTTK5j0Or1-cZfKouMoBf_qIDQGXXGmAIHCHCQ44qhDsbGAyXrI7-0CQpJXxPsnyQ0hjJ2Su88Zdcm294nwbua0y_6PuEqPVLFdsiuNjSEPZ8u90994fmpDuK5wjrpesO-xKUFpP0yw-qnZMm7c68MP_eG5WkKD-MIpJgrUzaSybRaGugB91vh7x3Daz4UFYAcsZvZX8O_Ej58uEzCjU5SiEni0b3zdNNsKfOJlBZv-z4Mk4YVwiD7r9eRkDeEY4A4spqfe1H4Tcn8PCKwGFzgNYmBu9871-w0jH7AEoTMBdQ8IyQ7W1SrSnhl1tihxYAY2HX94XOKJtY2URX5e5oXvIuonPLgEgKDgsoACsIMmtrR3UrA1xZYwerFBm6cMQtR3uf402VDzRLDNgrYeEFN_W1PKwvx6h9iq3gpXlYA1vExB-XDZlta2XNtkLTMzwba8QryrZJY12ffm3b-0y9BQvIh5NApLgu0qo2gpBoGwaY2UUh12YZ0pqkQ74_NWjzXPuMrtDbEF2qZFEY3UUh03LCYPR55bBxg93a11L5JS_MIJZoLvom0GYkYSu-FUg5bcmmTPo32-9bGOAB2H6_TFH6ataMyKc-buJDkJYtgFGY3T_tYCZBds_oPyElcPPVIyN-q2jhuXjndnjRqjYMDJ1MX7baswT4CNTf2poQbCuTreNEDY2DGo9C8yro7G34wPjG37u3Vtj1IayhEhYBarBjtgubmn18r4RA9XuQs_aeGUC56w77q_5JmtpxEMu8FueGUwkRhOxe3PnmfGRXH2kS5iIDIY_jCuTGj9PhsuiOPh4OFnwoN4JZY2sroR2_R6rfykN74UEpJrHDnLArdS7ue-DXoc98be6OpBFWD2gA6nZlC307Ok281DDHbC3dqfOX7qI5K_6vndADLu6OCn78DXBMrujbZDcxCQes5lGdOMQ2nyBHGx9t3eoMMm_mgEZvMm4b_OXzMqsHGXpigl_ZSs8DsrHs4F1WyywckTF2443-RHJJxMSReqRZTX5dzcJv14GrymTFOMfa8iuuuY2DaQRYfJc6p5HUkkgoOUglrJqBa8KMEkz-Zt7yIGg_eUF792KzYjkllcOlCn-1pegzcmvOEA3C4Sc4PzOfcc1lJra-Z5PCm9ZKYxY3m2ZM4s16rovPqk_Xh8j6J8Cn9uc3fnL7_zGOI9terORDNrCtHFxYx2ZUfgIJi8k8AuLnHhK6V72taRZFjAko7qWVnh0sSf1OSqFnteX0a8DAVjHTtsyF5kfQ6V0vj1irMl2Hnv6t6kNSBoXuMlZIQPJ2K4jUH7qgaBNysf70JLodzLB8nNibYrqdwFA-SYmoR9QJGA68O_YVUiFLm9GtgoQ0lgZ5nYaK5re3gSYQCdgwWFRRjGQ7y2Eczis4odquV_hg6IERYp76xtF0O_dY63osTNAeI268z6ALXrqJj7HswToFOkbRHkScpF_VMGHcIK6qiJc2yFBkTxqrZszRmHERwuleAoP4sRb7bmDS87Eu8JPmtSWimO7UfvaehSDZ4f80u_824jm7PgQaS_gcINy7o9y-ERiGQyknvbBQE8E5D9MvnQA0SJxc5fSIVRL0gqmSWVmbdEz5cVB7CISMGudfiriF5Gj9y8NaveDqjLWyoT3bqGWHx7p-B0MXUltRWPz8kZOI-Dm2Ytbbqq5EMO50R-5zOIwVyVqicEjW6G5E1sN2d5oxAN409Mp8XJfMr1qba78NuE6hGGr1jJsOJDmkUKAy2s0ltGryVUBvoIXg4iypZ95WXupjXa84Q614q56-0oYH9155GRPjxUC25StathRbt7qohZ-x8uxL2gspfKmyJKH_8QozkMRIAt7OrxgMji1-BpIOzXEP8RMBrxejeLlxrSDw7AXnGpMJ-lTpsliPhlOYWwOC4ZLIz3sMLmwHxs3d8XEMAaEmTbQA8IBEgoBsi3uiW29HVwWfaqGOPBm7u8IyXNo37RLKHQMfv99AWXEi2lOgvI58oE_WXU_FBEtl2cJYbMFkZJGslTUk9swV3Skl_M9M8xeG4V0HFxXOaAlaKqG6oo_Of5VebRY5Nu6zGGYGpWvxXRYbOdQ7kVWzcurvXiyrGew5HQF5ZtjhBgdZoipax5kCT-CK7r_3BJlzPKzXlXMnuAyVIrV9YpQX7uyN5QLPG-pVVHwwwhmL6cxqoqO8kx7-e86vUSRJMFIDaXDrFTmYnOoOXaH9KUq8znGe8MBK4t_1_hf32sDU8c1ZEqtRctpmCeBv1_Sc1DovILMoLuBeicnpXyjjfnXQOXwprL8Y7xI9CQWlcL2yMu1g7_fdxLeuklxQdCcCq9o3ykmk8waKgPDclh9PuJ-R1E7-YGJ0ymDGEqhtRWgyIIwXd_C6kxK2eFOD22oZPlBdHua82V5Fj2pbdgrS8xylViNyHWtDOawBoGcOeyZbeZaiVEVJ-Qy_SJR3cCVpIGpRBGMzUBmgEkjrkHDK9emlsxTJXgBCM4RtIEjksh4IxrhOxEy9goGiSAewg1M7nilWGNk6gaoxOfHJW_RzMxYCLunY-rWxp7gpxlvckXdcfqEsCNgNLcyE_3sjKT3QXn6FkOHKi5lD2RuNtc1O81oLtW244fum84oq_yKe51h_k8vkrBAZZbEPuT_84XQP99g0hJguaaE0xwGhHxf-wMpUW5jJCynd2Dll2uCxBuQ16nq10U1uhX_-tAQJ-J-P6fDAO9ohL6NZnVH6NC9z_mHhwJCHZJAPqRUUc0nJjE6sMuEo6MZ9gNLUKyFJwxHi4Z6E6Yn47e-bwM3pPrFCuRz_SeTgCu6tg7RU0iCYpQvjfMmdm2ImwBQLgPwzLKLNJaTqwiUS3RxTGJpr4FbOFnQnix9727KqLLhHIf3BT9DZpZ4W4s8yyp1q4gY2eJukzpL_h1n9zpfsNSVY7JSx3MLJHBcUdzXbZ16AQUdN5JrsZuIjx_41r7It5s4ttFx6aPFBnTE7-Bgk_hW4XorLz5JxSUFJn8Sy2GnFPagVu66Rvu5eJ5j7oaR79otPIJytNf7fxwyngjcM9irF95zPIF527npoZmIp-f9XYAS39huwdXDfSmy7klYR7k70SGTWcaa8SiN70rLpm7cPgRpT2EbWqX7KzQmglhRazOlj2aFc-6qBYJfF4-GuLJ_W_hFMGhNl1y1VnJTmoWVcm8ENxP1ZXVi0RlvSJhEeRBi0NPqF4GHV2gSjQkSmwBEUxVSOvR7YXx2lcj1-XqVSTtzTTm8cyahTmLUIb487pRNfBgdBSsy-Eg6LHg-TJNpS_UYdma3kTucaoN9KuIiftEu1v88DNnjoNT2new5Fo9NLP4AeklQQmRdZpgjtdTJje3czIPuTAlz-LPkHYzssfPdgv8C-AhmNMpe8_9p1IvswF_qn-xib_r75J2qHOFEHCFIGen5NI1Muc_jTq397N9UNp3mwN4umIivf88XPZb2y50mecChQPBA7oALNQ_sfu81t94eu8cCg9t6ZX-2Ngyg3m59V__L01cWQltCvhD5vint9i-P5FJUZ6FJ5srTEVr5yGs7tdTPvx2wdSghibrLrDrv8o9nQMh_K-QOm3xiIGzqUgqrGyrwT88EqDNN1a5TonnQ8UQZu48OC6L9G6m-GrWvIznWxXxbryQTLpu3dIVUM9u2Qj27eQrFhEjUv5BAs_ZJ3xXrwnXyqIBDH0jfMfYb28uUMYMiH3d23ywoQaFiRfQW3sdx8Uya5BZV25UT2LPsQy3ZavMDawLUb1Q4qNlW0a0v7UQaxbK5BsxnzmBJknFC988NQehYZwix95kF9Jq2rls3sC07S3_T5Q7lfAhvkTplRWmaLNzpfCXq3obVparfXLCn339ddgdBkgqoZkbqNwsnK-Z4qGKyUq4wuN8unKVNeTQoF-ZbNtzVK2Fc1lKmUiBF-20cHoOOJV7WthLKZ-2SIwmtrIAI6ZUWUYsO7QSkDvy8BziZkc5igf3F0hS-yMCn8zdpBadha1xY-CHXw0674og58Z2Neh4d-sbr_9kjEttkc2X1cR_P3ZFcq84XZ7PQ1uFUMAHRZhDEu_v-YaVZp5nAVnAJqRdGZzkKwFBpcaN-V9Z2_z9CLatVTb-0riYCS-LHJ4IA4hEMwroR50G25-N83uDjC22gXwt3NjQYh4horz4O3TAJ1cx4x_NPTXDUcHpyCCQ8Oix_C_5fs388H5YIOH3gxbcYWm9SKhwxNRIQ6ValSRKivzPRCU4b849S2QKKB3tMWOaWwWZvihmUkKG1CgGfymGCbd_jERiLVCk3D_L3GoC3JBzYcWPw8cmrMTInrU13cJk7ORTH4ORFq-BszGSJylvI5WYr8AATpadyy_dVTIfx9aQKtCzrHyYSebolnq1CJ4mlX846sR7tWWiVsqVoZHnztxYH90E8kr23yFdz0C38DFJNX7J3_hfiKhj7_92DXhQz_wwvmHWJRHyIxh5EztqsXUQqn6QWFo7iVhDYj4A6QljVE-JkRZPVYOryJ5D7TkrdLsmKQkICbaJlbyJ2SwGKkFHNel4sSvLVZ5W-99XPtu2hABXPLR4umqcuZ1N0UncuxDN6UJZagaZl5JbUeu0EJLcbtKySYzotAd8jVu_Ziu8RDDkV9umoJ5T0mC5_3rFqomPK6nEKR-Dwj10chRucY9mWzhLiP8BN2WS9JiQb8Sf4Mr3a0tErV6hMP6R4N4FrT-z4fobWeQ6zaOCvA9GxRHJQzQw55xqkpoMxKt9GrIATztPV8p4mx9Mu_7NZGJGrnum-JOuuC-yE14dwbLhzNUr8N5w22WhxMsA9glRNZg5M_QfmjKAcKleK8skUnYB7DJQgOR6uVj3hwGu-fuWkXqfOaZsUsR7HJZbANXcJleQK1pQsIZuT2cxJidtnOX6yRoVQj9xN6YTdnOHemJhyzFgtZmqI9k8A4Ilzkop4hNPSKcVCru_-HCeMLDSnDDfUhk97iTtiUj9sOdb5OehKkrSL38l_nUs__xBZuBnc-fzBI8QHBvmAhY3RJ0MgbUgb3DMKaeJzM22v3-ZPoMMZwiprs3_LEtUF6jNO6-yqcdBzBETY3rPDhnSk0Pt_xYusBDg0PLI_eRcBM5etT0XtlUYvdyVulHdtpeELY8jKGk4ekeSkcMPeAypyIAxYrgqA4HuCq79wBfznx7vu3APEsZ3DEvorLJboDxuVpKHOljIr52xy_GffE1SFtImF5AfR2GQ80KQmqrFOU2lTyq1g7msKakP0fO2RrWruobjxnUHB1fEHPQPf4_emmNvJp8kTC0wvEXsuDV61pMlKG_cLBtgj3YvGm76yWmiw7IaSHr8vZKv6qsTWN3mH33qrBe9IlIkQk_OZ-o0b8y_O6Sl-MlH9ZUfJfR-AjScQzdcO3ceNm2wcyiWxlHgtapgXHZC8gzWdklnp5LcUemYZTblKrN0cyp2szqwELswG7fTaQPBTtAbTIz5iu4RwIur6nzhJAF452GkUnLy3KpdICYFM_Bh7YdiDI3YTQBaFA9WQbXbog8wI2omOxMoG8LJKNFkD2o162ljJgQrjdMamTBrf0eM4u6zh-7mNSMbcbQyZhhLmyclIjw0AKaZX6C4-FxbuwnoFzmqrOXK7DsSUgRQ5DSlDCPmrqklAjOOKkRck-j7-nicr6rIhk8N3cGveTPUK_LAAMbfeEtgg5clCXW-3-RCAGuL_nBssiK6HECXR0BHiOqEPkBj4Y8ZAz4JNbBOb3gBHX87ZJqkdF4PWHNAEmA6cW1yYl4RU9qS3yO5JX5TITvASw16eRJG7i29IzaCRtje6G-dgX43BGZHnpCs7G5-4ZmSa8pEebUDwISBBeN3B04VmON5KME5BfRe6xDhJMiUQ-4kpHRSuQAj_70eXXOKKvJkdKwnKL3siD7CcT5jSF-j0xdCAG18FZVSGaqByk5stsGR-l7CUIh6b1Oak36P16Q3Be_RLL4mcvhi1l7qMbThfHqmi0B7z5g499vBTRe6GwCoibhn3r8z80F4bV42odHH4aM7ZZkzhkdvP3hNHONXWxgxkT_SuC5F4T3S4-gpgodxWJxCwDir7-6wwVdQZYA8N_p7i33-cczRitTm95FKlS9xLBZUNGvxQbdqPBkvf9zabSA4iZ2wdHlZb1lgLW006f7lBZVts6dQAm1c6Pkav4aZBK8hX9v380ftUiHQ8A8G84p5qKh9XeHsar1d8qfXADLuoS242pUYJbVUKs4WtxYSzz_jwLCVNNaMwg9t_lD-63UXViS8_IxV1zFU4LvOf2hSoMUeagIR9vFzv5JasM-Ck_34dNvhbVwueaBFciv6yx1SL2IxnkxWRCwFxZFEEd6Tp5NJn1x_quSYpYv1kehFcZx4aAkpLuYhGCUNjGTCd7YbW0GW1xI9sc2163MLcwjSc5C4PpA3K-0R3fyeRWvoPzXMOwjqJQfhc88RmqShuSUJnXpwOPnDWr0-RMNdpW6lADVocWCy14N1-WoNzRGE1UALFokO7kJddG3Bf7aGrUuDt_sXW9tfagxyVhBVywUf1rf2lfqkmdHfia-QhMCwYq5KCbjstDBLyH9vCJyFSYz7WeP2VRjEyYcdwSl9HLyWhgfPWIPOyehI1ZpD_6PxFv_uOUoOvLyWT8yvsDsMJ-q6O8AHjAQfX1f6p1KGXKzBr4AuecL14MqFg5UFigFirkV4S8T0Rdzu7MOQgVmTE5fYHF4prscyueTFeTx5gJJkNvlcc5yRB_X3m31OwHkR1jjddj2h0nxli8y6VjxjA2gOtycm576QAnKIzYArs8nrcrM3IkBZXbrzKmO3ql-wzzr2dIsmu_b_PB3al3KHwwIz96dBySPKJ0XvKYneDdSE0sNrCLCRO0DVEe1xW-WCDU3yEjcbxJy2ngCjh-IfO-RFyc1GYSDiWQ81ckE7WYd21mkoiid_-gz-DbbcJH0GUaD0JLqJaVg5tpVsl0skmnlTDGi5nCfQV-GB7BtQzCDWB_Sqtmqi3gyDI5hrao-AcVfVnKvCPPfSQ8L39cEOccQy_RDfl6NqcAOttsEzHezI2Llr62GUdL_gWnIaP9c_wdKploOgHd2NC2IkdzAf3JbE06f5AUE2vdPj4ZvJjyjDbdpsrjHN5RUPSqyy5JigBqFyK57ljW9VrQ_AHUFudEOnqQ8HkbBSYJthZ_9D5b8aBZAVVkIcn1_i-zIXr32xjSO466-DNjjhPzY6vjovL51soqQP8M8AJxgEA9ivszAJnvScckwGxFA5-m-XbJZlvPd7I9yVhJ6J9SbtYWL5JQtAjjbXKveP_XTTwQxX9J9FE5LCDkPnp_1K2hjpskRIEfBEUxbTcSvoMw83V5lIKXO6-zXPkmRhUc0xWvrLLxgheUqtSjMbG6gIHLzwd7njNTesWTHxgknwHsVasDz8v_2HxgJYNTt2bcyiSATjEfYvEitQ06D2TLJHmvGztxJq1tAqBP-F2oDqdShk86OgQ3kCwcFhd-El1Ko29o1jmBpIp8aiHIPEBKYgSzcTSfMYYh9m9MHDQFOK3jx0_M7yv1C7s-bX4THFZpz4nvy4L2Y3O1Hpj21aJx5IQRHS5FIL-3KHMSq1jleZNb0fA7yctlO2Krn9EZuRuLv8kfgj4FRlK5yCf1ep4I4VF6O_7j3mn31-DCdnIvbU1sEoEo35eLF9MSVYliXP_qHPTbU1Ah8D91Qv645Dkw99GVzO2R8oD1ETXzG-xcJNbykatEu0526elt0wMypV7s-WsGNR7Zx4chXB_LNFSeriHw_hjtd86ty08o46l39rZgr_7Gjfj_RPfKrb2OQUzPd0oiF_0Sl68LF5QVwMLCxTRJDSYQfaP-STQH8SXu1TaEUE6FjeBOMNbpm8jn5CB6qg-8PqH6CDuceOA4eBT-1e1_SlWTXTumfDzI7nlkVHT3-KeGs19XhbFHPWa168dQDar6kba2DApE8g6jrAf-zwOv7Aprgaz6K7WJk-K2_X9zk1AkUgjXl1X8DFJqPOoU9eTLVks3i3RceYkD0gLOx1-2aA4znbd7x68RussehkV1syl10-SAaWxQB1jhxk69f5xUvUfNf19at869h3CZ_u9Mzp9yfI44-aLgUp0hTGAJmHlRyhCQdUxg9c016NUQnO7TFzgtq56PXmgDASXNYTRREfiVxOkk8e74uuu7oLq_ELN7bom5NiU71Ax631z-lquz782Wrg7ld6M_MiYCretko_CeP5QIdwbC11Mx2aLLLlWksPwc5NHmz720xuEO5O8V3EQq8C0OB0I7As07ssGttScjpwl77f3YUwnQhGvU9mFwZU83yFtyfXsolscM-pY4XAtn_ddPVM9fMJB1ADyl358c3tnYSyiPLX3neqkvs1V_92FDHplcFo27NxPQPR_gTI0SiEWhaNKGBIg_sI2M-ME0nwp5pRO-nkDwzgRmTADIcNm6yGgHNsdJidn0rBWC-EdLjBxDMSZxarugn4IOoBHPIvRbPJGIaR3fugalzFJQRXX3ZUIsk_P2rRp0_2tQ6mG2uxWMi7PYQvFSGhpztBUlvVOh1iNI2QonxbMcIF1fsq9iCf1h3vLTGSpdZT7LBdK5niw1Tzvas50bLVKBQIrGkPUpbT-hPQtuXipf_wi-QdlB-2-H3euIDATxfwwmLJegIfDUEDODMZKRGr5183JT6_mCupnxtmahMtwmsRMECTB7I4vl9Btuy1XrwJkt3GvlUXEI90bOg6oG1qgqtFhv3Na8HBc6L91XDRruPxH0LGl5pn3kSKYAwcjdSjVAg5mIchVM5spIdGqgFGR4PHMmogYNzofIha6QBMSZdGSkApU4ABJGyH3e1eu_7-7nT-rJ6lsPiRmBeLY_sSEOMylQNVywsI7s9uW69yvQYIPBrMhOMrfECeoFJGjLUTtf2Mm3FJe_hGRUE-EaNY5xVjj5-npwbO_GrKhJpceiF47yH7aTdMmU7HwnvrgdVkTgRSqtEUZEqeT4YWFXBhJB4fduuvoBvvBy8p2rk7sWKSVR1KBtNmERDjZBDHkwFWdl0teTQ1DPWB_2x1AZCx-Znu7AogLkxwjhZp6_SJ42G8Xbh-Dm8e-3z7umMsR823IGHUB9hInL1kbNfCb_aqnnamm7BZoOe9z54dEFOp5j1L_UTrLW8dTSpdEHRrQ4pQJUAsSx2pgL13fKTslK9uVAKVT3QM6lKC1JXpWR9Q6qwXmhNbbXhAa216kW0H97pG6wrW_4cfnpWeCbNWcNO-jEu5TH4GciHqXt7KhZMH4yOaF_DN_0OPAGiG5JXl4JFE8vwo_5LUi-jYVbYEz4ypM72ghIVj_0MH8xSVCxwBwZMTfJI5_QXN7kbI9ei-Cdz51pK4NaET9cDr-pepOTUuMndZPXQ41Q43QHor_f1XFgaormFTsw_YjCS-OM6f5roZl5xLcF5A3iXJUaiiBj2U_lQjmgJ_AAKGA5YwLAWDHoCR6PDGQulWt7K9kTlpd5w_Zj_HLE2zpOgy_N1pbcAvdf-PQDFGvv_JIONPz9OQR7v6s9bg02olXExDXDoeOFdP9iNFvUi7wCmTduP7U1hYdEDZ4Q8lMeWBaqEdSLZCggsHAeCxzGRQXcIbzgNaubgs_pkCBhjR9N80lJA3jWGWfRZrhVtLG9C14RuM1udRlPrB3rP24LaM6HdOhk0n5IAaXOSAgEhbE62hUHKdb4vY8_cZ7wK0SD7KE_ShZi4RtoFah_yxtOgM8ahqzDXzbakI_KeEEVL5y4DrVp4XGYCq2PbkxfUSizbHJXnxhyywEaIZuekWymD9_fICVbuTn9kXWEKVLxMZdWS9EF1N_rtHLJaIEOkqc2pe2RbjgLODv4kIlv6HL79R2CFYRGM0pKuxK6V7r8Lnv89-RbTFlMhZZb2XKvlD7plyr6wlFSex-y1mKmva1JUVLqJETMuv-wnxcZHhZvzMG9f9nYAXj598qoPcbYnHAJwNBYXlLh0_gog3ej-_DqfLqzVTMEOj1EoJzASovSbb8d_vYqwVZ3wYqT4_j1Rxjqpz-0O7BwORkv10JK7LTE08QMNldzSLN-JQoRC09_ELY3MK4lKSEGKsE8wEgYoGaAHB1pkdfjEGj6x3bwo4BrFvfDxX3P-jQk_xTA7T5gONKS1oT-KUB4EXj9oa1MO6NFrVhlG83Ok08G-AmzqnGQPYCow0o2N_LwDPgo2UgUuwgui5bvAHMQkc46FQcPmukNl1y2SfalK4Rz4JyfV4QUY4IrbMLgZu8cXBC1hXVWqxG4hOYgZoC2zGleMrcI25pJR4GEWgx2hgDMn80qgxc0OTSC5PTp65X8q8t6o4j04V6MI3--lf7CDc4W9qmd4aN8lcwIND7gCFvk9cuJOVdbpqbfymOS-uTruCzjGloTmVof5iJFN9ytj-Mk5v9iJ3G-kxOeybkSViTi9qczaE9Do--IwAdR7UkHnOZXkluHGd21LRJpef-7QI-dlbXd0C6WJk8xVt1DaWava2vlkzxCZ1_XtJmw-gWulSt6TsrUNbiCph7dXs2cnOIr6jVDOjMVzRPXNz3fOfnMs94Zh6-x3ZUL6FDgLA1EQw2gr8ixf-RGx7ZGmOFFZhKoORJfuRuTdOnPgkPBTcy6EMiYW89ToHtRPVId4znFXXfEdZFo9T_-23kh6hAP8nSgHhN384mYudn42km5P7IvZKCspK5ujyFgMX5b2VkhuWO0ofvkjuYPEhcxiE5OKCl4nc7slY_Dvb2lve33hZLHCvR8pxr_c-Kuo5QfAxXCKI49y_rF4r-OpDbdhS3Pp1y40zvjIYQcx5GBWvKGt0wbwW0CXNETjUL5CvDeN2J3HcEBQ_B_EHOCCJ61DcZPmUTpVffXbsM6x5qS0ZAFTOuXyzI3ETnKItBwugCPRagdMctAYjUxMeFFpq3V6O-0cy0O8AUUmpWwrUNOPQSrtZ5a7UrnoBPYCJ_BygT0v2DVEy1JQ_BUN7SBjmOZdhAm_a8fVugrxGJqI5eZWy_Pz_ErV61jyGBRSU-C6DTKg6dRjd0milICxE2F07Z8DQfqqn_yfijcpCi40FynsJeGgXsYohLH9wpTbLox0VtVeuAe-jvcsBRkk4CGfU3wUt08NF0U9hoBJwLTIBaVMzaEHztgcQes4R1YYMLSZGrzXUGphDxnrfTwxTmf94W_pLEoHQEcNoeVk4q093hi45OA3djzglntvgbytDBc1H6HUcMSLFmomJbcvIWRYGCqpXAfGNTOoSx_aoV4rioAFMIxRGKX75s8Yt6Ym-AU-juxMjV-onSGoiVugZywj1E-4kFdBlY9B7c0JS6CATQ3XNKDAslrQinaCs7xLSIRKLnBNkAVHRt_QXNjpMPzBiUaG9haMLCOjvI3_ItHBVRPDT-zTOWfzeqTpDhoGmPEj51NE7ASXNLJ6rn6nIKHOSCNy8nG_yUfCvfmqKc1tshOI9RWfmthXN749JrMwzLnto0Ca8IFbTaoC3LOP2kas7D26sqbl_EcNMnCigapgCA1PtDoV2f3SV1vBg-rzO9Jft7biCYCCgr4r8WrqpBzLiZ_N37pY-L-7Rp5hEOpea2AJHAj7E2WxFCyC8wcNP6b2GPKQAbvB6dXmrZZ6dsq_gHSAcM6_zkO1Eaw-A2AChMXYIeXvE6X5THyjCyivrDfBa4XLX9y2dXCPIXVDh38Pe4mPUv9Em7LfuX9tDisO-9ao_9Dm0fkXCga4ywff5l_0Q20TVfv22T3PTZPr-aJEFM8HbaJv_uqyA5jGK5E-nHfDLdX7QBwnscpWBHs5dKeZkBu5T6NzSWXWwO4CkTCm2fiNnE3n5kGkuCWnsX7ss6yc5cdQ7Fpr7egu50S6mRaC6T6XH0oSyFzneROvQCaLeFqyp1qMFX9i_cKRHcI39bq-UzI0W7L49rHAEAw_W6hNUVJek9zSPqYIs6EsHL_sTy4ySIyPf7uKo55YQU-cvEEh2YCSiJwm-CUGtoOVSA7biSlFiSOuwEk8_b0WR7fm3v1hIj3NvOw2oejIoXNGbBrS63huM-Gg2cQLHga-90iXo8RgIkIRVIw1hb2RmsmkPMuuOReYX1PZyDEsTcHOx01dYISK35g8CroGE_o5GwBrA9-JzbkI3ehQlBgtoIjOmzjGyt0QRtdqaZnISFs6aWoarvFRry-N5X9-CNjuoaN8MZqFUAnVVZ40EwDCm7aCNzZD8B88gOizc_E015xYG1fCDNGdyazp6U2p21kv7Xx3hgT2dVlx9syqWOsfGKNnWmzPr9rNAguhk6lcdU7KTaCJYtYns5iZXsi6IFNBgi8wcYZPdPp_paJ70CQK6qAkDXCk2rfnkYl3wEFPX3aXhrUGdHxL2oNKbRVDn-OSO62SD-0OdqUgJeZqVPKonWC6teuS-S3Ak4U3lM8UN-EWKzVJC2L6t1_SBHx_OTghk4hMhvpLG4hhDERD4HWsgx38cyJan9aNy7Wx33scptBaXtNWnOACdHWr22Mp-XA-QDjBhcbxUNMLm66b3y_sN7tYVCiC1AQGiiwGikLiXHya7L9B1cNQVUWz2TLYlbltt2xo_C5dbqGRouZsmAuUyrx2SvOYtRgCYOoE8aY01m1bNh1CsZMoI18yjBRCdfB_8_o2-PYAX1r99uXtzl7n7aFEkJyWH-q5S4VygZprEg_D1ndTtiIkjTheTr3bzdA6_CzqChgdVeS_WD_TtPO5ar-0IohhGGYkI2l79uV8eU48s7MuLUKd0WxwE9b6DmNIAq4OLcys_YYocV6JXKYvfJFp1gjDi8qu882EnTG4pDD4vEnMZZ__FA8lZCI4EDsSnAG3jUc1-yXVS0669SnCI-VHvIhNfnSO_SY5-gZ08tdo163jSZOJ48jqBb9Z_UrBvpOeZlpV64JuFmlhCKX7kl1cs6xInWZT4eZfk8TrkiBQ2FEwFc-4aqQJDRtquDJS1efr_ocsUefp-VkpN6dJ3gcJC8eOdbpKolV5nQu2Mmr4OinleFod06-HXEBiN20MhSHCK0w_eI0Mjst7W5IbUXYioJ8nN5dXyCZz_gqTv329ZvEN4iOVlrz9lENH7b2fSgVRWJnEGOEWohq5VUNJK26EiaKCKKQOrVOKjpiNd2C8sljsOPbQ7FAxT5UvPtHF1sVopVgn8FD-H9WgiEqgO8O4-wcRpyeE7R5oA88KWJbNgmOYqexTIGYlHQI0Fizt-EfNzpnKXkpK7NqI9ukYUBO81ZSGZn6dQQGncVFtPWH4nc2mCblanO0jhpKtrr1qqx93TKqpEVMsjcKJl4b2ZXYL03mlodGPPE-UtU37i7D2oJ5jb-tve73QLsO1l4M5sTCbtE2ncg7y2JmC633eULTlszB6GnWT4IvJXbPYJLjswXk3MBhAB0-0T91fALA7kPmhs_P31Gk9-Dvfyj8I6lJzymEGnEHaqWy31bVQUTp3NhvYBk4RAXoQFIKuSLaNY8qphO_lsA3YZOWqJ_C4YXVsWhoyK_XzhNJ86LtfmU69l6h9wDmYAnaVTjMX2EuOTKpI_FEf1uIq7zCWcHxa6xmNNIX3sBp-6Dv_3ADlZSan_KFNR-jx8rWAbQNnlccnocWMKymv9AHDYJ4EHG2x2YYZrtxa6TKMGyir44APV4cyHHFM2FyjK4gwuCV19DqDVudgv8rtNCV5YD3q57_eOXFFT6lLqy1F0FGryqjM3Nqpq1P6o3-VI3qL5TlI_9YopyzKpdiGy05Tcs2fawUHDLmyhoAxsv4z3wT3wvRMB4BNcNQ80UN0EsGtXXPmG0MTBlf4ZO_Q-TECDezHsxo_OjxoXTtsNGLCBjo8cKuwGXid37JQpv9RrVYFoxNBJlSpDO38lxJHu2i58VXvl-hHiRIftpIP3TP076BQz7ETqJuR2hs3vMyszNkSIbGU3v-91rQ_eb-LHVpJLnxy4vmZr3u7mHZjISEjGly2hwhLtu-IhfzuQp-AnvB-80ogrTdybvdW1mBw77ZgVA_-MiFG6dTDU9zK3VPW1NJHZf52gP42HmKtEQcWjH0ys3N0FPPd2e0lPbkJLF33fUCIJ10UgukZRowPlw6ew_fWvrFvZgiHKRXVuEM2xvF-20ay79uXlzff1E0HoF_8Sn-WkQOPLVZqK05ZEkniFXAaOk9RY9ciPfGGp2mfzRq6MTih2eHTbctdEVi8GIv_qJKccs-lkewSHoT0c3CxxI4XwBrJA-pythEt6AuWYIuceZJaVjOA8IqaGHhzY_WHvKQIo8qr28lf9JTSCFv_9B5KZmwjNlYjHCSPaF2v2C5DjKd5a9U1_PCwPByANLf4d0GOSW4j70xrRptrkzJFpd5tbnCljhAyfqhHWD4iCW2GPkOh7UWjtW9QJAASpGrUQLwDE5e7TjMhwXzyo6GsvtWUEqJ5IaTjX2rxlTPoFFEwTXs94FPuwOKIl7Bijb-25t6aAo1qxQUyxkS_I460rbTwxBuXbjPhIFdxpnAcj3RFSL6b19jq9gg8NF2IXRt0XC-U5hGYUx3_GVkkN_jsKvdG_j6xu3OzDq1HMN3NlX2XnX62X5sqeZLWCcbmtt2DL4SFNUvdZCwgG-5d_oUpYxtOPE9BodCGrcdHw1k_85MWOq0lrLcC8woBkM-z9HGE_qKDB3fhozAvbFlqNRAlsdxx9XOxhiVkiSPYahNEXR6S_5WMrNxkAfh1k-s7GRNaYSeopBRZ58i396LsK4AnGa8m8_6CJ284NqpI1Y-77sUqsKN4KnWqvYVP9OkRSA2f5Vk7I-dv9fVBWkcm7ILGdw-NTn0sT_x_look-JBZSIsVWMwFhq7UXfWHDhedWVUpptiYcJfjJGH5O6Iyq-h4C0Zka8Hh7t5bz056mRGMMru01Nfn8XkFkvidez97rVtdAgERCiUZrHcq6FAhrkLXjFXcKITMYtLGvfG2PBURBsUiE7rWJ8KVd4gTsMsuSSjvEpNJrQaAC7fEAEVMFn54-eviw2JPB7uVanLYMd7oOTvavLKkrr9y3RpVgHshPQsqomco-AFphCfQAo6mZWyllDp7Pd62HGfl7rQNBPZ_VtntudY5-WSn4glS8m-DDKnEbBv9s4-kFdnPuXEWylkPW74JAUDvt7FC1vltqC0o1igcBFiaNW60vLs8URS_8hm-sBnm7tu6iyAr5sumnX8T8BHNPd3hoMYa3Oyw4B5oCq_sOLiuklpbL7zbL8l-FCdwEdITWV9FEa17VWq4vhVS5bc4xv2CbT-gC_-XW4YRGgIWI2IshUh0KK0KKNPHF6vnTKutxXKfP8jP_BQ_gdYoQSqCEeAhPzud_lazmQ6zR1ICmzzlcPeXLmZLCZX8yJi4o3aj6l7rWeUxEHKOR-qHQNYxmWT5tySnsurcfj0yPDdsSHaPPUs7GH5mS6rCdnAxrXSzWlcmY0ywsmWvF5rP1o9GrDUVrssu_1_KJsyWQCgLa_V-cA_-r8Ve0_gM9R1CRT1CXxL-ehH0q0gdEilLnetEpTwTdAIT1sRN3y_HXeySWUfQ5t6K7JFYFy6qcXK7x9Qf8gZYPjDtY4WMt3PpJJT72jL84irbOZSyrcAL5fTMMapPbVnRMFmRgIsvfBKTzTWOmnUwHMKb7WSitbaPTUVDz6chZLVMRRzkCDYF7KI9NRuNtANgba_Ln_of9ZxVGd_wgjCZhT6w4e6ltG_j-wgI0DBdZzRV1O9vJOOk_ggkIEOosSfLfdd8FvVvHCji_iRn9qcj3zc0Pu6WgBQ9EPC4PDMJP1HeKNSXjvViTe2QoRH5NMaDfhB0wP1jbq4joGpPDZ-iTpuRyimhJpDY29XYVis05NXkfij6jmc7WRDAXC_1st0DXGmPaqyXLwlGo9UCjcIii88IZo_zqoUhvoDcfSHFDL2DmqFf_xTU1ZO48fM59m954AZ15OS64wvt40Gr63P0LoTq1GXLDEDZ3m3GLo_oF2qpsUiRdQM4NCPj8iF-Kby9yXTwRexunLAaNspZNFpDEAJMeLTwWnhNNa53VtTlLpyWGhhnMmdPUJxI51yaydu2jHyI84V0zCqaLE3F1FtD-PWrKYbI-MDKcVlSv1hK5y6GiKOsxRRsoA3roprInjiXzokECNK1ai_VxGrRm6eIEpfD4sopvkoXS-IvMwqyyGKiESfa_X_ctsiXg99svWCuWeJTt3_Erzd24nJ7c_oKUHHAi-IrGd151D1bUubgFykX10X_hi8gZiPlKKa8oiFUsBdYKTj6qjyQRSUq11G8MJHoUjdM7ZFMqWs9nlesw3EgMmyCeRI5oG9tBlLXkhhGhMsyrug-QfXwoH0Fttrmta2wNSWF9MAgtVZ65SzEko4Bx-XvWIDX4WrRhhgBCR6SfYK37BbKiC758Iqk06KO5-dTO3J6wgFRDRm3X-rTcvOs2k1gC6wZ_AdjRI8xMO2Ib5T8wfHCorzqPao4_MIFrMLSsnBnjODBNmeHYGJtkvrQUDVZYaiGhvvnG0gc6meZSoKTg6PLQqGguN1ZR32MGUDaUATTBWEfZ3t_KM1vjI7A9oZ4-Dm1E3YYOh-qYHTLFv2FDSXlRkHXm3sZ4pE5WGX6TCfJpCTq8DlMTpYkygjAkSBR8DtWeOr66SirJ-g3SDU9CiJ_TyhB0Iw3jjpVNoz-X9DGHcSHaxGZZTKXxZnizRCzUzhAHZnMBAV5qSbFADHq0vItsHkYlw5ERL7QH6gSqlqkokbIdAnWQI0QArxkV3mFf-we07cQySP0CH8n9FPmwzOi7QHWVr_Ky3iNFzNzxO0La6q6Y0I2Fwza8RAUlqMSIUW954kNVhXvrO90nftt_6X9TBzQMuUGlKEIFx6_HG3bEs0wgJtNjqJWh0ZdmQ0afaNos470xKNIe_CfNagmWWAsoTkKiDLtfDX-rMPyUADQ6cW9ZMPjjWkby3LGuJkM7D7yjf-RQsxCDzAYe_Kjo4jyUpu03azg20HXQ48Gz9kOFqRKPbuRVw8LiKTfZB13tIgiDJzNn2h9H4T-KDGtjnqGrC8WF6UqH8I6zUo-J4b0Bp-NAZfK84R1xcqpj81v5XfSVKEoT2kvrPQwUO-dcst27dtNYcosW0i62Cz25uDaEv6hl2UavttxLqyksviFUgq8YP1D_it1TLgexMjxprjmgxBr4WLMc29ya9T2X3A567UPweRw8NRpROLvdnkFfBtQiWSBhp7Ut8EyKIwhVPI0tK5LpoJC5WE9FOGt69z4WaSAVAB30DFjgqV-9r_0aGJvCtmFaWIdKob_1EjYv8EUtTMIrPk7o7--1I4EqWtvKp6stFmk1lbpnqWulizx-dda4gRP1ufHnaHmysnjuaFNVJzMbMtcBR8P0PfGZLx0MIuZZQIFHf_rbhZ0Xj-0_BX5ktQOQBPdaReB6KPTZP3rps07z4dxtaqlyD0nR8f3ZykpwgeFVQOOLKfuyEQOZXOnaUYOsRWgHErR46-dl0OinAhFsecO8eWf7TzlFzM4F1TfsVAxnHwaOF3Zjmv1v8N5nrgNfBS4Uw-FYuPwLjdxyriM1VANQMT-qJauh6KcbZV-VHcYg4MwQcSenvap84A";
    final menu = fromUnicode(decryptFromJs(menuPlain));
    List<Video4TopMenuEntity> menuList = (json.decode(menu) as List).map((value) {
      // 使用当前元素value解析，而非再次解析整个menu
      return Video4TopMenuEntity.fromJson(value as Map<String, dynamic>);
    }).toList();
    print("解密后内容: $plain");
    VideoList4VideoListEntity videoList4VideoListEntity = VideoList4VideoListEntity.fromJson(json.decode(plain));
    var doc = parse.parse(response);
    try {
      if(_isSearch){
        var rootEles = doc
            .getElementsByClassName('row-book clearfix');
        if(rootEles.isEmpty){
          resetUrl(url);
          return;
        }
        var tdElements =
        rootEles.first
            .getElementsByTagName('dl');
        for (var value in tdElements) {
          try {
            var h2Ele = value.getElementsByTagName("h2");
            if(h2Ele.isEmpty){
              continue;
            }
            var aEles = value.getElementsByTagName("a");
            if (aEles.length > 0) {
              var aEle = aEles.first;
              VideoListItem item = VideoListItem();
              String href = aEle.attributes['href']!;
              var imgs = value.getElementsByTagName('img');
              var tag = value.getElementsByClassName('url').first.text;
              var imgTags = ["自拍偷拍","美腿丝袜","欧美色图","卡通图片"];
              for (var value in imgTags) {
                if(tag!.contains(value)){
                  item.isImage = true;
                }
              }
              if(tag.contains("小说")){
                item.isBook = true;
              }else if(item.isImage != true){
                item.isVideo = true;
              }
              if(imgs.isNotEmpty){
                var imgEle = imgs.first;
                item.imageUrl = imgEle.attributes['data-original'];
              }else{
                item.imageUrl = "";
              }
              item.title = aEle.text;
              item.targetUrl = href;
              _data.add(item);
            }
          } catch (e) {
            print(e);
          }
        }
      }else{
        videoList4VideoListEntity.data?.forEach((value){
          VideoListItem videoListItem = new VideoListItem();
          videoListItem.title = value.title;
          videoListItem.imageUrl = value.titlepic;
          videoListItem.targetUrl = 'https://m3u8.46cdn.com${value.m3u8}';
          _data.add(videoListItem);
        });
      }

      if (_btns.isEmpty) {
        _btns.clear();
        menuList?.forEach((value){
          value.items?.forEach((item){
            ButtonBean bean = new ButtonBean();
            bean.title = item.classname;
            bean.value = item.classid.toString();
            _btns.add(bean);
          });

        });
      }
    } catch (e) {
      print(e);
    }

    setState(() {

    });
  }
  void getImg(String targetUrl) async {
    showLoading();
    var response = await NetUtil.getHtmlData(targetUrl);
    var document = parse.parse(response);
    var elments = document
        .getElementsByClassName("pic")
        .first
        .getElementsByTagName("img");
    List<String> imgs = [];
    for (var value in elments) {
      imgs.add(value.attributes['src']!);
    }
    Navigator.pop(context);
    Navigator.pushNamed(context, "/ShowStaggeredImagePage", arguments: {"list": imgs});
  }
  void _showDialog() async {
    ButtonBean buttonBean = await showDialog(
        context: context,
        builder: (context) {
          return new AlertDialog(
            content: GridViewDialog(_btns),
          );
        });
    if (buttonBean != null) {
      if(buttonBean.type == 1){
        _page = buttonBean.page;
        buttonType = 1;
      }else{
        _isSearch = false;
        buttonType = 0;
        _currentKey = buttonBean.value!;
      }
      _type = 0;
      var imgs = ["自拍偷拍","美腿丝袜","欧美色图","卡通图片"];
      for (var value in imgs) {
        if(buttonBean.title!.contains(value)){
          _type = 1;
        }
      }
      if(buttonBean.title!.contains('小说')){
        _type = 2;
      }

      _refreshController.requestRefresh();
    }
  }

  void goToDetail(VideoListItem data) async {
    showLoading();
    String response = await NetUtil.getHtmlData(data.targetUrl);
    var doc = parse.parse(response);
    var urls = response.split(new RegExp(r'"url":"https|.m3u8",'));
    String url = urls[0];
    // MovieBean movieBean = MovieBean();
    // try {
    //   var tbody = doc.getElementsByClassName('ibox').first;
    //   movieBean.imgUrl = tbody
    //       .getElementsByTagName('img')
    //       .first
    //       .attributes['src'];
    //   movieBean.info = tbody.getElementsByClassName('vodInfo').first.text;
    //   movieBean.name = data.title;
    //   movieBean.des = '';
    //   movieBean.originUrl = data.targetUrl;
    //   var vodplayinfo = doc.getElementsByClassName('vodplayinfo');
    //   vodplayinfo.forEach((element) {
    //     if(element.text.contains('.m3u8')){
    //       var playEles = element.getElementsByTagName('input');
    //       for (var value in playEles) {
    //         var title = value.attributes['value'];
    //         if(title.contains('.m3u8')){
    //           MovieItemBean itemBean = MovieItemBean();
    //           itemBean.name = '播放';
    //           itemBean.targetUrl = title;
    //           movieBean.list = [itemBean];
    //         }
    //       }
    //     }
    //   });
    //
    // } catch (e) {
    //   print(e);
    // }

    Navigator.pop(context);
    CommonUtil.toVideoPlay(url, context,title: data.title!);
    // Navigator.of(context)
    //     .push(new MaterialPageRoute(builder: (BuildContext context) {
    //   return MovieDetailPage(1, movieBean);
    // }));
  }

  void showLoading() {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return SpinKitWave(
            color: Colors.blue,
          );
        });
  }

  @override
  bool get wantKeepAlive => true;

  // **解混淆函数**：跳过每两个字符中的一个
  String deobfuscate(String text) {
    StringBuffer deobfuscated = StringBuffer();
    for (int i = 0; i < text.length; i += 2) {
      deobfuscated.write(text[i]);
    }
    return deobfuscated.toString();
  }

  void resetUrl(String original) async{
    // 1️⃣ 获取当前 URL
    var url = Uri.parse(original);

    // 2️⃣ 提取协议、主机、路径
    var result = "${url.scheme}://${url.host}${url.path}";

    // 3️⃣ 构造 Base64 编码的 URL 参数
    String encodeBase64(String input) {
      return base64Encode(utf8.encode(input));
    }

    var u = encodeBase64(result);
    var p = encodeBase64("${url.path}${url.query}");

    // 4️⃣ 构造重定向 URL
    var redirectUrl = "${ApiConstant.videoList4Url}/Index/Inform.html?u=$u&p=$p";

    print("重定向 URL: $redirectUrl");
    var requestUrl = "";
    http.Request req = http.Request("Get", Uri.parse(redirectUrl))..followRedirects = false;
    http.Client baseClient = http.Client();
    http.StreamedResponse redirectResponse = await baseClient.send(req);
    final responseBody = await redirectResponse.stream.bytesToString();
    if(redirectResponse.statusCode == 302){
      Uri redirectUri = Uri.parse(redirectResponse.headers['location']!);
      requestUrl = redirectUri.origin;
      _resetBaseUrl(requestUrl);
      return;
    }
    // 5️⃣ 执行跳转
    // window.location.href = redirectUrl;
  }

  void _resetBaseUrl(String url,{bool useFanhao = true})  async{
    SpUtil sp = await SpUtil.getInstance();
    String localStr = sp.getString(SharedPreferencesKeys.urls);
    UrlsBean? localUrl;
    if (localStr != null && localStr.isNotEmpty) {
      localUrl = UrlsBean.fromJson(json.decode(localStr));
    }
    http.Request req = http.Request("Get", Uri.parse(url))..followRedirects = false;
    http.Client baseClient = http.Client();
    http.StreamedResponse redirectResponse = await baseClient.send(req);
    if(redirectResponse.statusCode == 302){
      Uri redirectUri = Uri.parse(redirectResponse.headers['location']!);
      url = redirectUri.origin;
      _resetBaseUrl(url,useFanhao: false);
      return;
    }
    if(url.isNotEmpty){
      ApiConstant.videoList4Url = url.replaceAll('/index/home.html', '');
      UrlsBean localUrl;
      if (localStr != null && localStr.isNotEmpty) {
        localUrl = UrlsBean.fromJson(json.decode(localStr));
        localUrl.videoList4Url = ApiConstant.videoList4Url;
        sp.putString(SharedPreferencesKeys.urls, json.encode(localUrl));
      }
      _refreshController.requestRefresh();
    }
  }

  @override
  void dispose() {
    imgeStream.close();
    super.dispose();
  }

  void toSearchDetail(VideoListItem item) {
    if(item.isVideo == true){
      goToPlay(item);
    }else if(item.isImage == true){
      getImg(item.targetUrl!);
    }else{
      Navigator.of(context)
          .push(new MaterialPageRoute(builder: (BuildContext context) {
        return BookHomePage(item.targetUrl, 9);
      }));
    }
  }

  _getDefaultImg(VideoListItem item) {
    if(item.isVideo == true){
      return Icon(Icons.play_circle,color: Colors.blue,size: 50,);
    }

    if(item.isImage == true){
      return Icon(Icons.image,color: Colors.blue,size: 50,);
    }
    if(item.isBook == true){
      return Icon(Icons.menu_book_outlined,color: Colors.blue,size: 50,);
    }

    return Image.asset('images/video_bg.png');
  }

}
