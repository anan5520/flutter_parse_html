import 'package:flutter/material.dart' hide NestedScrollView;
import 'package:flutter_parse_html/book/base/structure/base_view.dart';
import 'package:flutter_parse_html/book/base/structure/base_view_model.dart';
import 'package:flutter_parse_html/book/base/util/utils_toast.dart';
import 'package:flutter_parse_html/book/novel/view/novel_about.dart';
import 'package:flutter_parse_html/book/novel/view/novel_book_find.dart';
import 'package:flutter_parse_html/book/novel/view/novel_book_shelf.dart';
import 'package:flutter_parse_html/book/router/manager_router.dart';

class MainPageView extends BaseStatefulView {
  @override
  BaseStatefulViewState<BaseStatefulView<BaseViewModel>, BaseViewModel>
      buildState() {
    return MainPageViewState();
  }
}

class MainPageViewState
    extends BaseStatefulViewState<MainPageView, BaseViewModel>
    with SingleTickerProviderStateMixin {
  DateTime _lastClickTime;

  TabController primaryTC;

  @override
  void initData() {
    primaryTC = TabController(length: 2, vsync: this);

  }

  @override
  Widget buildView(BuildContext context, BaseViewModel viewModel) {

    return Scaffold(
      appBar: AppBar(
        title: Text("小说"),
        bottom: TabBar(
          tabs: <Widget>[
            Tab(
              text: "书库",
            ),
            Tab(
              text: "发现",
            )
          ],
          controller: primaryTC,
        ),
        actions: <Widget>[
          Padding(
            child: IconButton(icon:Icon(Icons.search),onPressed: (){
              APPRouter.instance.route(APPRouterRequestOption(
                  APPRouter.ROUTER_NAME_NOVEL_SEARCH, context));
            },),
            padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
          ),
          Padding(
            child: Icon(Icons.menu),
            padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
          )
        ],
      ),
      backgroundColor: Colors.grey[100],
      body: WillPopScope(
          child: Container(
            child: TabBarView(
              children: [
                NovelBookShelfView(),
                NovelBookFindView(),
              ],
              controller: primaryTC,
            ),
          ),
          onWillPop: () async {
            if (_lastClickTime == null ||
                DateTime.now().difference(_lastClickTime) >
                    Duration(seconds: 1)) {
              //两次点击间隔超过1秒则重新计时
              _lastClickTime = DateTime.now();
              ToastUtils.showToast("再次点击退出应用");
              return false;
            }
            return true;
          }),
    );
  }

  @override
  void loadData(BuildContext context, BaseViewModel viewModel) {}

  @override
  BaseViewModel buildViewModel(BuildContext context) {
    return null;
  }
}
