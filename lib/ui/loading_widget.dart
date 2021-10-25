



import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
class LoadingWidget extends StatefulWidget{



  @override
  State<StatefulWidget> createState() {
    return LoadingWidgetState();
  }

  LoadingWidget(Key key):super(key:key);

}


class LoadingWidgetState extends State<LoadingWidget>{

  bool _isShow = true;

  @override
  Widget build(BuildContext context) {
    Widget loading = _isShow?SpinKitWave(color:Colors.blue,):Container();
    return loading;
  }


  void setVisible(bool show){
    setState(() {
      _isShow = show;
    });
  }
}