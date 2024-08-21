
import 'dart:ui';

import 'package:flutter_parse_html/ui/home_page.dart';
import 'package:flutter_parse_html/ui/parse/htm_parse_page1.dart';
import 'package:flutter_parse_html/ui/parse/image_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_parse_html/ui/parse/show_staggered_image_page.dart';
import 'package:flutter_parse_html/ui/splash_page.dart';
import 'package:flutter_parse_html/util/theme.dart';
void main() => runApp(MyApp());
const Set<PointerDeviceKind> _kTouchLikeDeviceTypes = <PointerDeviceKind>{
  PointerDeviceKind.touch,
  PointerDeviceKind.mouse,
  PointerDeviceKind.stylus,
  PointerDeviceKind.invertedStylus,
  PointerDeviceKind.unknown
};
class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      scrollBehavior: const MaterialScrollBehavior().copyWith(
          scrollbars: true,
          dragDevices: _kTouchLikeDeviceTypes
      ),
      title: '老司机',
      theme: LTheme.dartTheme,
      onGenerateRoute: (setting){
        if(setting.name == '/ImagePage'){
          return MaterialPageRoute(builder: (context) => ImagePage(setting.arguments as Map));
        }
        if(setting.name == '/ShowStaggeredImagePage'){
          return MaterialPageRoute(builder: (context) => ShowStaggeredImagePage(setting.arguments as Map));
        }
        return null;
      },
      routes: <String,WidgetBuilder>{
        "/HtmlParse1":(BuildContext context)=>new HtmlParsePage1(),
        "/HomePage":(BuildContext context)=>new HomePage(),
      },
      home: SplashPage(),
    );
  }


}


