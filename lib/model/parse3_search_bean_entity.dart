class Parse3SearchBeanEntity {
	int code;
	Parse3SearchBeanData data;

	Parse3SearchBeanEntity({this.code, this.data});

	Parse3SearchBeanEntity.fromJson(Map<String, dynamic> json) {
		code = json['code'];
		data = json['data'] != null ? new Parse3SearchBeanData.fromJson(json['data']) : null;
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

class Parse3SearchBeanData {
	int pages;
	List<Parse3SearchBeanDataItem> items;

	Parse3SearchBeanData({this.pages, this.items});

	Parse3SearchBeanData.fromJson(Map<String, dynamic> json) {
		pages = json['pages'];
		if (json['items'] != null) {
			items = new List<Parse3SearchBeanDataItem>();(json['items'] as List).forEach((v) { items.add(new Parse3SearchBeanDataItem.fromJson(v)); });
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

class Parse3SearchBeanDataItem {
	String picurl;
	List<Null> actors;
	String urlpath;
	List<Null> topics;
	String name;
	String createdAt;
	int id;
	List<Parse3SearchBeanDataItemsTag> tags;

	Parse3SearchBeanDataItem({this.picurl, this.actors, this.urlpath, this.topics, this.name, this.createdAt, this.id, this.tags});

	Parse3SearchBeanDataItem.fromJson(Map<String, dynamic> json) {
		picurl = json['picurl'];
		if (json['actors'] != null) {
			actors = new List<Null>();
		}
		urlpath = json['urlpath'];
		if (json['topics'] != null) {
			topics = new List<Null>();
		}
		name = json['name'];
		createdAt = json['created_at'];
		id = json['id'];
		if (json['tags'] != null) {
			tags = new List<Parse3SearchBeanDataItemsTag>();(json['tags'] as List).forEach((v) { tags.add(new Parse3SearchBeanDataItemsTag.fromJson(v)); });
		}
	}

	Map<String, dynamic> toJson() {
		final Map<String, dynamic> data = new Map<String, dynamic>();
		data['picurl'] = this.picurl;
		if (this.actors != null) {
      data['actors'] =  [];
    }
		data['urlpath'] = this.urlpath;
		if (this.topics != null) {
      data['topics'] =  [];
    }
		data['name'] = this.name;
		data['created_at'] = this.createdAt;
		data['id'] = this.id;
		if (this.tags != null) {
      data['tags'] =  this.tags.map((v) => v.toJson()).toList();
    }
		return data;
	}
}

class Parse3SearchBeanDataItemsTag {
	String urlpath;
	String name;

	Parse3SearchBeanDataItemsTag({this.urlpath, this.name});

	Parse3SearchBeanDataItemsTag.fromJson(Map<String, dynamic> json) {
		urlpath = json['urlpath'];
		name = json['name'];
	}

	Map<String, dynamic> toJson() {
		final Map<String, dynamic> data = new Map<String, dynamic>();
		data['urlpath'] = this.urlpath;
		data['name'] = this.name;
		return data;
	}
}
