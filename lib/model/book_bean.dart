class BookList1Bean {
  bool? success;
  int? total;
  List<Data>? data;
  String? msg;

  BookList1Bean({this.success, this.total, this.data, this.msg});

  BookList1Bean.fromJson(Map<String?, dynamic> json) {
    success = json['success'];
    total = json['total'];
    if (json['data'] != null) {
      data = [];
      json['data'].forEach((v) {
        data?.add(new Data.fromJson(v));
      });
    }
    msg = json['msg'];
  }

  Map<String?, dynamic> toJson() {
    final Map<String?, dynamic> data = new Map<String?, dynamic>();
    data['success'] = this.success;
    data['total'] = this.total;
    if (this.data != null) {
      data['data'] = this.data?.map((v) => v.toJson()).toList();
    }
    data['msg'] = this.msg;
    return data;
  }
}

class Data {
  int? rowNum;
  int? id;
  String? title;
  String? times;
  int? num;
  int? viewcount;

  Data(
      {this.rowNum, this.id, this.title, this.times, this.num, this.viewcount});

  Data.fromJson(Map<String?, dynamic> json) {
    rowNum = json['rowNum'];
    id = json['id'];
    title = json['title'];
    times = json['times'];
    num = json['num'];
    viewcount = json['viewcount'];
  }

  Map<String?, dynamic> toJson() {
    final Map<String?, dynamic> data = new Map<String?, dynamic>();
    data['rowNum'] = this.rowNum;
    data['id'] = this.id;
    data['title'] = this.title;
    data['times'] = this.times;
    data['num'] = this.num;
    data['viewcount'] = this.viewcount;
    return data;
  }
}
