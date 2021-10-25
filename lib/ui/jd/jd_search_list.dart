

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_parse_html/generated/json/base/json_convert_content.dart';
import 'package:flutter_parse_html/model/j_d_search_list_entity.dart';
import 'package:flutter_parse_html/net/net_util.dart';

class JDSearchListPage extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return JDSearchState();
  }
}


class JDSearchState extends State{


  List<JDSearchListDataSearchmParagraph> _data = [];

  @override
  void initState() {
    _getData();
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _getContentWidget(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // if (childBtnValues.length > 0) {
          //   //有选项再显示
          //   _showDialog();
          // }
        },
        child: Icon(Icons.add),
      ),
    );
  }

  _getContentWidget() {
    return ListView.builder(
      itemBuilder: (context, index) {
        return new GestureDetector(
          onTap: () {

          },
          child: new ListTile(title: Row(children: [
            Expanded(child: Text('${_data[index].content.warename}',maxLines: 1,),),
            Text('${_data[index].dredisprice}元-',style: TextStyle(color: Colors.blue),maxLines: 1,),
            Text('${_data[index].pfdt.m}件${_data[index].pfdt.j}折',style: TextStyle(color: Colors.red),maxLines: 1,),
          ],)),
        );
      },
      itemCount: _data.length,
    );
  }

  void _getData() async{
    var couponBatch = '801273890';
    var page = 0;
    var pageSize = 20;
    var url = "https://wqsou.jd.com/coprsearch/cosearch?coupon_batch=$couponBatch&coupon_aggregation=yes&neverpop=yes&datatype=1&callback=jdSearchResultBkCbG&page=$page&pagesize=$pageSize&ext_attr=no&brand_col=no&price_col=no&color_col=no&size_col=no&ext_attr_sort=no&multi_suppliers=yes&rtapi=no&coupon_kind=1&coupon_shopid=0&jxcoupon=0&area_ids=1,72,2819";
    var response = await NetUtil.getHtmlData(url);
    response = response.replaceAll(new RegExp(r'jdSearchResultBkCbG\(|\)|\\x'), '');
    try {
      var pa = json.decode(response);
      JDSearchListEntity jdSearchListEntity = JDSearchListEntity().fromJson(pa);
      jdSearchListEntity.data.searchm.paragraph.forEach((element) {
        _data.add(element);
      });
    } catch (e) {
      print(e);
    }

    setState(() {

    });
  }
}