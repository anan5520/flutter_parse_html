import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class BannerView extends StatefulWidget {
  final List<Widget> chidren;

  final Duration switchDuration;

  BannerView(
      {this.chidren = const <Widget>[],
        this.switchDuration = const Duration(seconds: 3)});

  _BannerViewState createState() => _BannerViewState();
}

class _BannerViewState extends State<BannerView>
    with SingleTickerProviderStateMixin {
  TabController _tabController;
  PageController _pageController;
  int _curPageIndex;
  static const Duration animateDuration = const Duration(milliseconds: 500);
  Timer _timer;
  List<Widget> children = []; // 内部加两个页面  +B(A,B)+A

  @override
  void dispose() {
    _pageController.dispose();
    _tabController.dispose();
    _timer.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _curPageIndex = 0;
    _tabController = TabController(length: widget.chidren.length, vsync: this);

    children.addAll(widget.chidren);

    /// 定时器完成自动翻页
    if (widget.chidren.length > 1) {
      children.insert(0, widget.chidren.last);
      children.add(widget.chidren.first);

      ///如果大于一页，则会在前后都加一页， 初始页要是 1
      _curPageIndex = 1;
      _timer = Timer.periodic(widget.switchDuration, _nextBanner);
    }

    ///初始页面 指定
    _pageController = PageController(initialPage: _curPageIndex,viewportFraction: 0.5);
  }

  void _nextBanner(Timer timer) {
    _curPageIndex++;
    _curPageIndex = _curPageIndex == children.length ? 0 : _curPageIndex;
    _pageController.animateToPage(_curPageIndex,
        duration: animateDuration, curve: Curves.linear);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Listener(
          onPointerDown: (_) {
            _timer?.cancel();
          },
          onPointerUp: (_) {
            if (widget.chidren.length > 1) {
              _timer = Timer.periodic(widget.switchDuration, _nextBanner);
            }
            print("重启");
          },
          child: NotificationListener(

            // ignore: missing_return
            onNotification: (notification){
//              print(notification.runtimeType);
              if(notification is ScrollUpdateNotification){
                //是一个完整页面的偏移
                if(notification.metrics.atEdge) {
                  if (_curPageIndex == children.length - 1) {
                    ///如果是最后一页 ，让pageview jump到第1页
                    _pageController.jumpToPage(1);
                  } else if (_curPageIndex == 0) {
                    ///第1页回滑， 滑到第0页。第0页的内容是倒数第二页，是所有真实页面的最后一页的内容
                    ///指示器 到 tab的最后一个
                    _pageController.jumpToPage(children.length-2);
                  }
                }

              }
            },
            child: PageView.builder(
              itemCount: children.length,
              itemBuilder: (context, index) {
                return InkWell(
                  child: children[index],
                  onTap: () {
                    print("$index");
                  },
                );
              },
              controller: _pageController,

              ///要到新页面的时候 把新页面的index给我们
              onPageChanged: (index) {
                // 需要更新下下标
                _curPageIndex = index;
                if (index == children.length - 1) {
                  ///如果是最后一页 ，让pageview jump到第1页
//                _pageController.jumpToPage(1);
                  _tabController.animateTo(0);
                } else if (index == 0) {
                  ///第1页回滑， 滑到第0页。第0页的内容是倒数第二页，是所有真实页面的最后一页的内容
                  ///指示器 到 tab的最后一个
//                _pageController.jumpToPage(children.length-2);
                  _tabController.animateTo(_tabController.length - 1);
                } else {
                  _tabController.animateTo(index - 1);
                }
              },
            ),
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: TabPageSelector(
            indicatorSize: 8,
            controller: _tabController,
            color: Colors.white,
            selectedColor: Colors.grey,
          ),
        )
      ],
    );
  }
}