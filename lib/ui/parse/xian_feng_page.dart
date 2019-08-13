import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_parse_html/model/video_list_item.dart';
import 'package:flutter_parse_html/ui/movie/movie_detail_page.dart';
import 'package:flutter_parse_html/util/native_utils.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:flutter_parse_html/model/button_bean.dart';
import 'package:flutter_parse_html/net/net_util.dart';
import 'package:flutter_parse_html/api/api_constant.dart';
import 'package:html/parser.dart' as parse;
import 'package:flutter_parse_html/widget/dialog_page.dart';
import 'package:flutter_parse_html/model/movie_bean.dart';
class XianFengPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return XianFengState();
  }
}

class XianFengState extends State<XianFengPage> {

  List<VideoListItem> _data = [];
  List<ButtonBean> _btns ;
  RefreshController _refreshController;
  int _page = 1;
  String _currentKey = '/';
  @override
  void initState() {
    _refreshController = new RefreshController(initialRefresh: true);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('先锋'),
      ),
      body: SmartRefresher(
        onRefresh:(){
          _page = 1;
          _data.clear();
          _getData();
        },
        onLoading:(){
          _page ++ ;
          _getData();
        },
        enablePullUp: true,
        enablePullDown: true,
        controller: _refreshController,
        child: ListView.separated(separatorBuilder: (context,index){
          return Divider(color: Colors.grey,);
        },itemCount:_data.length,itemBuilder: (context, index) {
          return GestureDetector(onTap: (){
            goToDetail(_data[index]);
          },
          child: Padding(padding: EdgeInsets.all(5),
            child: Text(_data[index].title),),);
        }),
      ),
      floatingActionButton: FloatingActionButton(onPressed: (){
        if(_btns.length > 0){//有选项再显示
          _showDialog();
//        NativeUtils.toXfPlay('xfplay://dna=DwjbAwfdmwLWDZiWAZfdBdiZAZx2m0m4AGeXmeDXEdjbAZmYAZxZmt|dx=450062105|mz=JUY-794_CH_SD_onekeybatch.mp4|zx=nhE0pdOVl3P5AY5xqzD5Ac5wo206BGa4mc94MzXPozS|zx=nhE0pdOVl3Ewpc5xqzD4AF5wo206BGa4mc94MzXPozS');
        }
      },child: Icon(Icons.add),),
    );
  }
  //获取数据
  void _getData() async{
    String response = await NetUtil.getHtmlData(ApiConstant.xianFengUrl + _currentKey + 'index-$_page.html');
    var doc = parse.parse(response);
    var btnElements = doc.getElementsByClassName('hypoMain clear');
    try {
      if(_btns == null){
            _btns = [];
            for (var value in btnElements) {
              var eles = value.getElementsByTagName('li');
              for (var value1 in eles) {
                ButtonBean buttonBean = ButtonBean();
                var ems = value1.getElementsByTagName('em');
                if(ems.length > 0){
                   var em = ems[0];
                  buttonBean.title = em.text;
                  buttonBean.value = em.getElementsByTagName('a').first.attributes['href'];
                  _btns.add(buttonBean);
                }
              }
            }
          }
      var tbodys = doc.getElementsByTagName('tbody').first.getElementsByTagName('tbody');
      if(tbodys.length > 2){
        var tbody =  tbodys[1];
        if(tbody != null){
          var trs = tbody.getElementsByTagName('tr');
          for (var value in trs) {
            String title = value.text.replaceAll('\t', '').replaceAll('\n', '\t');
            if(!title.contains('上一页')){
              VideoListItem item = VideoListItem();
              item.targetUrl = ApiConstant.xianFengUrl + value.getElementsByTagName('a').first.attributes['href'];
              item.title = title ;
              _data.add(item);
            }

          }
        }
      }
    } catch (e) {
      print(e);
    }

    setState(() {
      _refreshController.refreshCompleted();
      _refreshController.loadComplete();
    });

  }

  void _showDialog() async{
   ButtonBean buttonBean = await showDialog(context: context,builder:(context){
      return new AlertDialog(content: GridViewDialog(_btns),);
    } );
   if(buttonBean != null){
     _currentKey = buttonBean.value;
    _refreshController.requestRefresh();
   }
  }

  void goToDetail(VideoListItem data) async{
    showLoading();
    String response = await NetUtil.getHtmlData(data.targetUrl);
    var doc  = parse.parse(response);
    MovieBean movieBean = MovieBean();
    var tbodys = doc.getElementsByTagName('tbody');
    if(tbodys.length >2){
      var tbody = tbodys[1];
      movieBean.name = tbodys[0].text.replaceAll('\n', '').replaceAll('\t', '');
      movieBean.imgUrl = tbody.getElementsByTagName('img').first.attributes['src'];
      movieBean.info = tbody.getElementsByTagName('div').first.text;
      movieBean.des = tbody.getElementsByClassName('intro').first.text;
    }
    var inputs = doc.getElementsByTagName('input');
    for (var value in inputs) {
      String name = value.attributes['name'];
      if(name != null && name == 'copy_sel'){
        MovieItemBean movieItemBean = MovieItemBean();
        movieItemBean.targetUrl = value.attributes['value'];
        movieItemBean.name = '先锋影音';
        movieBean.list =[movieItemBean];
      }
    }

    Navigator.pop(context);
    Navigator.of(context)
        .push(new MaterialPageRoute(builder: (BuildContext context) {
      return MovieDetailPage(2,movieBean);
    }));
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
}
