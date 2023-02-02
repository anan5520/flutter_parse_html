import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_parse_html/model/button_bean.dart';
import 'package:flutter_parse_html/util/native_utils.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gallery_saver/gallery_saver.dart';

class NoticeDialog extends StatefulWidget {
  final String _title;
  final String _content;

  NoticeDialog(this._title, this._content);

  @override
  State<StatefulWidget> createState() {
    return NoticeState();
  }
}

class NoticeState extends State<NoticeDialog> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Column(
          children: <Widget>[
            Text(widget._title),
            Divider(
              height: 1,
              color: Colors.grey,
            ),
            Text(widget._content),
            Divider(
              height: 1,
              color: Colors.grey,
            ),
            Text('确定')
          ],
          crossAxisAlignment: CrossAxisAlignment.center,
        ),
      ],
    );
  }
}

class GridViewDialog extends StatelessWidget {
  final List<ButtonBean> _btns;
  final bool showToPage;
  const GridViewDialog(this._btns,{this.showToPage = true});

  @override
  Widget build(BuildContext context) {
    TextEditingController _textEditingController = new TextEditingController();
    return SizedBox(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.6,
        child: Column(
          children: [
            showToPage?Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: Container(
                      padding: EdgeInsets.only(left: 10, right: 4),
                      alignment: Alignment.centerLeft,
                      color: Color(0xffeeeeee),
                      child: TextField(
                        maxLines: 1,
                        autofocus: false,
                        controller: _textEditingController,
                        textInputAction: TextInputAction.go,
                        onSubmitted: (value) {
                          ButtonBean buttonBean = ButtonBean();
                          buttonBean.page = int.parse(value);
                          buttonBean.type = 1;
                          _textEditingController.dispose();
                          Navigator.pop(context, value);
                        },
                        style: TextStyle(color: Colors.blue,fontSize: 15),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: "输入页数",
                          hintStyle: TextStyle(color: Colors.blue),
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                  child: MaterialButton(
                    onPressed: () {
                      ButtonBean buttonBean = ButtonBean();
                      buttonBean.page = int.parse(_textEditingController.text);
                      buttonBean.type = 1;
                      _textEditingController.dispose();
                      Navigator.pop(context, buttonBean);
                    },
                    color: Colors.blue,
                    child: Text('跳转',
                        maxLines: 1,
                        style: TextStyle(
                            fontSize: 13,
                            color: Colors.white,
                            decoration: TextDecoration.none)),
                    textColor: Colors.black,
                  ),
                )
              ],
            ):Container(),
            Expanded(
              child: Padding(
                padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
                child: GridView.count(
                  childAspectRatio: 1.5,
                  crossAxisCount: _btns.length > 8 ? 3 : 2,
                  mainAxisSpacing: 5,
                  crossAxisSpacing: 5,
                  children: getItem(context),
                ),
              ),
            ),
          ],
        ));
  }

  getItem(BuildContext context) {
    List<Widget> list = [];
    for (ButtonBean value in _btns) {
      list.add(SizedBox(
        width: 10,
        height: 5,
        child: MaterialButton(
          height: 4,
          padding: EdgeInsets.all(0),
          onPressed: () {
            Navigator.pop(context, value);
          },
          color: Colors.blue,
          child: Text(value.title,
              maxLines: 1,
              style: TextStyle(
                  fontSize: 13,
                  color: Colors.white,
                  decoration: TextDecoration.none)),
          textColor: Colors.black,
        ),
      ));
    }
    return list;
  }
}

class ShowImageDialog extends StatefulWidget {
  final String url;

  const ShowImageDialog(this.url);

  @override
  State<StatefulWidget> createState() {
    return ShowImageDialogState(url);
  }
}

class ShowImageDialogState extends State {
  final String url;
  ShowImageDialogState(this.url);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        width: MediaQuery.of(context).size.width,
        child: Container(
          child: GestureDetector(
            child: url.startsWith('http')?CachedNetworkImage(imageUrl: url,):Image.file(File(url)),
            onLongPressStart: (detail) {
              _showMenu(context, detail, url);
            },
          ),
        ));
  }

  _showMenu(BuildContext context, LongPressStartDetails detail, String url) {
    final RelativeRect position = RelativeRect.fromLTRB(
        detail.globalPosition.dx, //取点击位置坐弹出x坐标
        detail.globalPosition.dy, //取text高度做弹出y坐标（这样弹出就不会遮挡文本）
        MediaQuery.of(context).size.width - detail.globalPosition.dx,
        0);
    var pop = _popMenu(url);
    showMenu(
      context: context,
      items: pop.itemBuilder(context),
      position: position, //弹出框位置
    ).then((newValue) {
      if (!mounted) return null;
      if (newValue == null) {
        if (pop.onCanceled != null) pop.onCanceled();
        return null;
      }
      if (pop.onSelected != null) pop.onSelected(newValue);
    });
  }

  PopupMenuButton _popMenu(String url) {
    return PopupMenuButton(
      itemBuilder: (context) => _getPopupMenu(context),
      onSelected: (value) {
        print('onSelected');
        _selectValueChange(value, url);
      },
      onCanceled: () {
        print('onCanceled');
        setState(() {});
      },
    );
  }

  _selectValueChange(String value, String url) {
    setState(() {
      if (value != null && value == 'save') {
        _onImageSaveButtonPressed(url);
      }
    });
  }

  _getPopupMenu(BuildContext context) {
    return <PopupMenuEntry>[
      PopupMenuItem(
        value: 'save',
        child: Text('保存到相册'),
      ),
    ];
  }

  void _onImageSaveButtonPressed(String url) async {
    print('保存图片>>>$url');
    if (Platform.isAndroid) {
      // var response = await http.get(url, headers: header);
      // File savedFile = await ImageSaver.toFile(fileData: response.bodyBytes);
      // print('保存成功>>>' + savedFile.path);
      GallerySaver.saveImage(url).then((value){
        Fluttertoast.showToast(msg: '保存成功$value');
      });

    } else {
      NativeUtils.saveImage(url, albumName: 'Media').then((bool success) {
        print('保存图片返回结果>>$success');
        Fluttertoast.showToast(msg: '保存成功');
      });
    }
}
}


class ProgressDialog extends StatefulWidget{

  double startProgress = 0;


  ProgressDialog(this.startProgress);

  @override
  State<StatefulWidget> createState() {
    return ProgressDialogState();
  }
}

class ProgressDialogState extends State<ProgressDialog> {
  double _progress = 0;

  @override
  void initState() {
    _progress = widget.startProgress;
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      child: Padding(
        padding: EdgeInsets.only(top: 20,bottom: 20),
        child: Column(
          children: [
            Text("进度${(_progress * 100).toStringAsFixed(0)} %"),
            Slider(
              min: 0,
              max: 1,
              label: "${(_progress * 100).toStringAsFixed(0)} %",
              value: _progress,
              divisions: 100,
              inactiveColor: Colors.grey,
              activeColor: Colors.blue,
              onChangeEnd: (d){
                _progress = d;
              }, onChanged: (double value) {
              _progress = value;
              setState((){});
            },
            ),
            MaterialButton(onPressed:(){
              Navigator.pop(context, _progress);
            }, child: Text("确定",style: TextStyle(color: Colors.white),),color: Colors.blue)
          ],
        ),
      ),
    );
  }
}


