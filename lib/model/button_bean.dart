

class ButtonBean{
  int type = 0; // 1 跳转页面
  String title;
  String value;
  int page = 1;



  @override
  String toString() {
    return 'ButtonBean{title: $title, value: $value}';
  }


}