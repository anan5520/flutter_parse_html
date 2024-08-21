class LiveDetail {
  List<Zhubo>? zhubo;

  LiveDetail({this.zhubo});

  LiveDetail.fromJson(Map<String, dynamic> json) {
    if (json['zhubo'] != null) {
      zhubo = [];
      json['zhubo'].forEach((v) {
        zhubo!.add(new Zhubo.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.zhubo != null) {
      data['zhubo'] = this.zhubo!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Zhubo {
  String? address;
  String? img;
  String? title;

  Zhubo({this.address, this.img, this.title});

  Zhubo.fromJson(Map<String, dynamic> json) {
    address = json['address'];
    img = json['img'];
    title = json['title'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['address'] = this.address;
    data['img'] = this.img;
    data['title'] = this.title;
    return data;
  }
}
