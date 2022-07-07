class XianFengBeanEntity {
	int code;
	XianFengBeanData data;

	XianFengBeanEntity({this.code, this.data});

	XianFengBeanEntity.fromJson(Map<String, dynamic> json) {
		code = json['code'];
		data = json['data'] != null ? new XianFengBeanData.fromJson(json['data']) : null;
	}

	Map<String, dynamic> toJson() {
		final Map<String, dynamic> data = new Map<String, dynamic>();
		data['code'] = this.code;
		if (this.data != null) {
      data['data'] = this.data.toJson();
    }
		return data;
	}
}

class XianFengBeanData {
	int pages;
	List<XianFengBeanDataItem> items;

	XianFengBeanData({this.pages, this.items});

	XianFengBeanData.fromJson(Map<String, dynamic> json) {
		pages = json['pages'];
		if (json['items'] != null) {
			items = new List<XianFengBeanDataItem>();(json['items'] as List).forEach((v) { items.add(new XianFengBeanDataItem.fromJson(v)); });
		}
	}

	Map<String, dynamic> toJson() {
		final Map<String, dynamic> data = new Map<String, dynamic>();
		data['pages'] = this.pages;
		if (this.items != null) {
      data['items'] =  this.items.map((v) => v.toJson()).toList();
    }
		return data;
	}
}

class XianFengBeanDataItem {
	String node;
	String urlpath;
	String name;
	String createdAt;
	List<XianFengBeanDataItemsArea> areas;
	int id;

	XianFengBeanDataItem({this.node, this.urlpath, this.name, this.createdAt, this.areas, this.id});

	XianFengBeanDataItem.fromJson(Map<String, dynamic> json) {
		node = json['node'];
		urlpath = json['urlpath'];
		name = json['name'];
		createdAt = json['created_at'];
		if (json['areas'] != null) {
			areas = new List<XianFengBeanDataItemsArea>();(json['areas'] as List).forEach((v) { areas.add(new XianFengBeanDataItemsArea.fromJson(v)); });
		}
		id = json['id'];
	}

	Map<String, dynamic> toJson() {
		final Map<String, dynamic> data = new Map<String, dynamic>();
		data['node'] = this.node;
		data['urlpath'] = this.urlpath;
		data['name'] = this.name;
		data['created_at'] = this.createdAt;
		if (this.areas != null) {
      data['areas'] =  this.areas.map((v) => v.toJson()).toList();
    }
		data['id'] = this.id;
		return data;
	}
}

class XianFengBeanDataItemsArea {
	String name;

	XianFengBeanDataItemsArea({this.name});

	XianFengBeanDataItemsArea.fromJson(Map<String, dynamic> json) {
		name = json['name'];
	}

	Map<String, dynamic> toJson() {
		final Map<String, dynamic> data = new Map<String, dynamic>();
		data['name'] = this.name;
		return data;
	}
}
