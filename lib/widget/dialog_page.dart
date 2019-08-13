import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_parse_html/model/button_bean.dart';

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
  List<ButtonBean> _btns;

  GridViewDialog(this._btns);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.9,
      height: MediaQuery.of(context).size.height * 0.6,
      child: GridView.count(
        childAspectRatio: 1.5,
        crossAxisCount: 4,
        mainAxisSpacing: 5,
        crossAxisSpacing: 5,
        children: getItem(context),
      ),
    );
  }

  getItem(BuildContext context) {
    List<Widget> list = [];
    for (ButtonBean value in _btns) {
      list.add(SizedBox(width: 10,height: 5,child: MaterialButton(
        height: 4,
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
      ),));
    }
    return list;
  }
}
