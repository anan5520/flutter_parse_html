


import 'package:flutter/material.dart';
import 'package:flutter_parse_html/model/movie_bean.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:html/parser.dart' as parse;

class WebViewPage extends StatefulWidget {
 final String _url;

  WebViewPage(this._url);

  @override
  _WebViewPageState createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage> {
  TextEditingController controller = TextEditingController();
  FlutterWebviewPlugin flutterWebviewPlugin = FlutterWebviewPlugin();
  var urlString = '';
  String _resultUrl = '';
  launchUrl() {
    setState(() {
      urlString = controller.text;
      flutterWebviewPlugin.reloadUrl(urlString);
    });
  }

  @override
  void dispose() {
    flutterWebviewPlugin.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    urlString = widget._url;
    flutterWebviewPlugin.onStateChanged.listen((WebViewStateChanged wvs) {
      print(wvs.type);
      if(wvs.type == WebViewState.finishLoad){
        getHtml();
      }
    });
    //url变化监听
    flutterWebviewPlugin.onUrlChanged.listen((url){
      print('url>>>$url');
      if(url.contains('.mp4')){
        Navigator.pop(context,url);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return WebviewScaffold(
      appBar: AppBar(
        title: TextField(
          autofocus: false,
          controller: controller,
          textInputAction: TextInputAction.go,
          onSubmitted: (url) => launchUrl(),
          style: TextStyle(color: Colors.white),
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: "Enter Url Here",
            hintStyle: TextStyle(color: Colors.white),
          ),
        ),
        actions: <Widget>[

          RaisedButton(
            child: Text('点击解析视频'),
            textColor: Colors.blue,
            color: Colors.white,
            onPressed: () => getHtml(),
          )
        ],
      ),
      url: urlString,
      withZoom: false,
      withJavascript: true,
      
    );
  }

  void getHtml() async{
   String html = await flutterWebviewPlugin.evalJavascript("document.getElementsByTagName('html')[0].innerHTML");
   if(html.startsWith('"')){
     html = html.substring(1,html.length - 1);
   }
   html = html.replaceAll('\\u003C', '<');
   html = html.replaceAll('\\', '');
   var document = parse.parse(html);
   var element = document.getElementsByTagName('tbody');
   if(element != null && element.length > 0){
     var bodyEle = element.first;
     String url = '';
     List<MovieItemBean> list = [];
     var trEles = bodyEle.getElementsByTagName('tr');
      for (var value in trEles) {
          var aEles = value.getElementsByTagName('a');
          for (var value1 in aEles) {
            url = value1.attributes['href'];
            if(url.startsWith('http')){
              MovieItemBean movieItemBean = new MovieItemBean();
              movieItemBean.targetUrl = url;
              var td = value.getElementsByTagName('td');
              movieItemBean.name = td.length > 2?td[1].text:'';
              list.add(movieItemBean);
            }
          }

      }
     Navigator.pop(context,list);
   }else{
     Fluttertoast.showToast(msg: '请先点击"GO to download"按钮');
   }
  }
}