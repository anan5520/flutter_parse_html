
import 'package:flutter_parse_html/book/base/structure/provider/config_provider.dart';
import 'package:flutter_parse_html/ui/home_page.dart';
import 'package:flutter_parse_html/ui/parse/htm_parse_page1.dart';
import 'package:flutter_parse_html/ui/parse/image_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_parse_html/ui/splash_page.dart';
import 'package:provider/provider.dart';

import '../provider_setup.dart';
import 'main_page_view.dart';

class BookView extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
              providers: providers,
              child: Consumer<ConfigProvider>(builder:
                  (BuildContext context, ConfigProvider appInfo, Widget child) {
                return MaterialApp(
                    title: '书库',
                    theme: ThemeData(primaryColor:Colors.white,),
                    home: MainPageView());
              }));
  }


}


