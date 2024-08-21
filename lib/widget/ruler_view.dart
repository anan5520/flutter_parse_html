import 'dart:ui';
import 'dart:ui' as ui;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class RulerView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return RulerViewState();
  }
}

class RulerViewState extends State {
  var lastX;
  var startX;
  double moveX = 0;
  @override
  Widget build(BuildContext context) {
    return new GestureDetector(
      child: CustomPaint(
        painter: RulerViewPainter(moveX: moveX),
        size: Size(900,400),
      ),
      onPanDown: _onPanDown,
      onHorizontalDragUpdate: _onPanUpDate,
      onPanEnd: _onPanEnd,
    );
  }

  void _onPanDown(DragDownDetails details) {
    startX = details.globalPosition.dx;
  }

  void _onPanUpDate(DragUpdateDetails details) {
    setState(() {
      moveX =  details.globalPosition.dx - startX - moveX;
    });
  }

  void _onPanEnd(DragEndDetails details) {
    lastX = details.velocity.pixelsPerSecond.dx;
  }
}

class RulerViewPainter extends CustomPainter {
  double selectorValue = 50.0; // 未选择时 默认的值 滑动后表示当前中间指针正在指着的值
  var maxValue = 200; // 最大数值
  var minValue = 0.0; //最小的数值
  double perValue = 1; //最小单位 刻度

  var textMarginTop = 10.0; //o
  var textSize = 15.0; //尺子刻度下方数字 textsize
  var textColor = '#333333'; //文字颜色

  var _alphaEnable = false; // 尺子 最左边 最后边是否需要透明 (透明效果更好点)

  var _textHeight; //尺子刻度下方数字  的高度

  late Paint _textPaint; // 尺子刻度下方数字( 也就是每隔10个出现的数值) paint
  late Paint _linePaint;

  double _lineSpaceWidth = 5.0;    //  尺子刻度2条线之间的距离
  var _lineWidth = 2.0;         //  尺子刻度的宽度
  var _lineMaxHeight = 20.0;   //  尺子刻度分为3中不同的高度。 mLineMaxHeight表示最长的那根(也就是 10的倍数时的高度)
  var _lineMinHeight = 10.0;    //  最短的那个高度
  var _maxOffset;               //所有刻度 共有多长
  var _offset;                // 默认状态下，mSelectorValue所在的位置  位于尺子总刻度的位置
  var _totalLine;
  double moveX = 0;
  String selectorColor;
  RulerViewPainter(
  {this.selectorValue = 50,
    this.maxValue = 200,
    this.minValue = 0,
    this.textSize = 15.0,
    this.textColor = '',
    this.moveX = 0,
    this.selectorColor = "#007AFF",
    this.textMarginTop = 10.0,
    this.perValue = 1}){
    _textPaint = new Paint();
    _textPaint.color = hexToColor(textColor);
    _linePaint = new Paint();
    _linePaint.color = hexToColor(textColor);
    _totalLine =((maxValue  - minValue ) / perValue) + 1;
    _offset = ((selectorValue - minValue) / perValue * _lineSpaceWidth) - moveX ;
  }

  @override
  void paint(Canvas canvas, Size size) {
    for(int i = 0;i < _totalLine;i++){
      double value = -(_offset - size.width / 2 - i * _lineSpaceWidth);
      if(value > 0 && value < size.width){
        double lineHeight = _lineMinHeight;
        if (i % 10 == 0) {
          lineHeight = _lineMaxHeight;
          // 新建一个段落建造器，然后将文字基本信息填入;
          ParagraphBuilder pb = ParagraphBuilder(ParagraphStyle(
            textAlign: TextAlign.center,
            fontWeight: FontWeight.w300,
            fontStyle: FontStyle.normal,
            fontSize: textSize,
          ));
          pb.pushStyle(ui.TextStyle(color: hexToColor(textColor)));

          pb.addText(i.toString());
          // 设置文本的宽度约束
          ParagraphConstraints pc = ParagraphConstraints(width: 50);
          // 这里需要先layout,将宽度约束填入，否则无法绘制
          Paragraph paragraph = pb.build()..layout(pc);
          canvas.drawParagraph(paragraph, Offset(value - 25,lineHeight + textMarginTop));
          _linePaint.color = hexToColor(selectorColor);
          _linePaint.strokeCap = StrokeCap.round;
          _linePaint.strokeWidth = _lineWidth * 1.5;
          canvas.drawLine(Offset(size.width/2, 0), Offset(size.width/2,lineHeight),_linePaint);
        } else{
          lineHeight = _lineMinHeight;
        }
        print('line>>>>>>>>>>>>>>>$value|${lineHeight + textMarginTop}');
        _linePaint.strokeWidth = _lineWidth;
        _linePaint.color = hexToColor(textColor);
        _linePaint.strokeCap = StrokeCap.square;
        canvas.drawLine(Offset(value, 0), Offset(value,lineHeight),_linePaint);
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }

  Color hexToColor(String s) {
    // 如果传入的十六进制颜色值不符合要求，返回默认值
    if (s == null || s.length != 7 || int.tryParse(s.substring(1, 7), radix: 16) == null) {
      s = '#999999';
    }

    return new Color(int.parse(s.substring(1, 7), radix: 16) + 0xFF000000);
  }
}
