


import 'package:flutter/material.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
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
    // TODO: implement dispose
    super.dispose();
    flutterWebviewPlugin.dispose();
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
      if(!url.contains(urlString) && url.endsWith('com/')){
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
          IconButton(
            icon: Icon(Icons.navigate_next),
            onPressed: () => launchUrl(),
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
   var document = parse.parse(html);
   var element = document.getElementsByClassName('text-center header_title size_xxxl c_red').first;
   if(element != null){
     String url = 'https://${element.text}';
     if(url.endsWith('com') && _resultUrl.isEmpty){
       _resultUrl = url;
       Navigator.pop(context,url);
     }
   }
  }
}