class YaSeVideoEntity {
	int code;
	YaSeVideoData data;

	YaSeVideoEntity({this.code, this.data});

	YaSeVideoEntity.fromJson(Map<String, dynamic> json) {
		code = json['code'];
		data = json['data'] != null ? new YaSeVideoData.fromJson(json['data']) : null;
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

class YaSeVideoData {
	int total;
	int page;
	List<YaSeVideoDataList> xList;

	YaSeVideoData({this.total, this.page, this.xList});

	YaSeVideoData.fromJson(Map<String, dynamic> json) {
		total = json['total'];
		page = json['page'];
		if (json['list'] != null) {
			xList = new List<YaSeVideoDataList>();(json['list'] as List).forEach((v) { xList.add(new YaSeVideoDataList.fromJson(v)); });
		}
	}

	Map<String, dynamic> toJson() {
		final Map<String, dynamic> data = new Map<String, dynamic>();
		data['total'] = this.total;
		data['page'] = this.page;
		if (this.xList != null) {
      data['list'] =  this.xList.map((v) => v.toJson()).toList();
    }
		return data;
	}
}

class YaSeVideoDataList {
	String customPic;
	int fansnum;
	String dateline;
	String viewnumStr;
	String pic;
	String mozaiquethumb;
	String title;
	List<String> tagsName;
	int uid;
	int viewnum;
	dynamic nvyou;
	String videoHls;
	int istop;
	int id;
	int commentnum;
	int level;
	int collectnum;
	String avatar;
	List<String> users;
	int likenum;
	int isav;
	String timelong;
	String name;
	int sortnum;
	int hd;
	int cid;

	YaSeVideoDataList({this.customPic, this.fansnum, this.dateline, this.viewnumStr, this.pic, this.mozaiquethumb, this.title, this.tagsName, this.uid, this.viewnum, this.nvyou, this.videoHls, this.istop, this.id, this.commentnum, this.level, this.collectnum, this.avatar, this.users, this.likenum, this.isav, this.timelong, this.name, this.sortnum, this.hd, this.cid});

	YaSeVideoDataList.fromJson(Map<String, dynamic> json) {
		customPic = json['custom_pic'];
		fansnum = json['fansnum'];
		dateline = json['dateline'];
		viewnumStr = json['viewnum_str'];
		pic = json['pic'];
		mozaiquethumb = json['mozaiquethumb'];
		title = json['title'];
		tagsName = json['tags_name']?.cast<String>();
		uid = json['uid'];
		viewnum = json['viewnum'];
		nvyou = json['nvyou'];
		videoHls = json['video_hls'];
		istop = json['istop'];
		id = json['id'];
		commentnum = json['commentnum'];
		level = json['level'];
		collectnum = json['collectnum'];
		avatar = json['avatar'];
		users = json['users']?.cast<String>();
		likenum = json['likenum'];
		isav = json['isav'];
		timelong = json['timelong'];
		name = json['name'];
		sortnum = json['sortnum'];
		hd = json['hd'];
		cid = json['cid'];
	}

	Map<String, dynamic> toJson() {
		final Map<String, dynamic> data = new Map<String, dynamic>();
		data['custom_pic'] = this.customPic;
		data['fansnum'] = this.fansnum;
		data['dateline'] = this.dateline;
		data['viewnum_str'] = this.viewnumStr;
		data['pic'] = this.pic;
		data['mozaiquethumb'] = this.mozaiquethumb;
		data['title'] = this.title;
		data['tags_name'] = this.tagsName;
		data['uid'] = this.uid;
		data['viewnum'] = this.viewnum;
		data['nvyou'] = this.nvyou;
		data['video_hls'] = this.videoHls;
		data['istop'] = this.istop;
		data['id'] = this.id;
		data['commentnum'] = this.commentnum;
		data['level'] = this.level;
		data['collectnum'] = this.collectnum;
		data['avatar'] = this.avatar;
		data['users'] = this.users;
		data['likenum'] = this.likenum;
		data['isav'] = this.isav;
		data['timelong'] = this.timelong;
		data['name'] = this.name;
		data['sortnum'] = this.sortnum;
		data['hd'] = this.hd;
		data['cid'] = this.cid;
		return data;
	}
}
