class TvBeanEntity {
	String? englishName;
	String? identifier;
	List<TvBeanChannel>? channels;
	String? chineseName;
	int? id;

	TvBeanEntity({this.englishName, this.identifier, this.channels, this.chineseName, this.id});

	TvBeanEntity.fromJson(Map<String?, dynamic> json) {
		englishName = json['englishName'];
		identifier = json['identifier'];
		if (json['channels'] != null) {
			channels = [];(json['channels'] as List).forEach((v) { channels!.add(new TvBeanChannel.fromJson(v)); });
		}
		chineseName = json['chineseName'];
		id = json['id'];
	}

	Map<String?, dynamic> toJson() {
		final Map<String?, dynamic> data = new Map<String?, dynamic>();
		data['englishName'] = this.englishName;
		data['identifier'] = this.identifier;
		if (this.channels != null) {
      data['channels'] =  this.channels!.map((v) => v.toJson()).toList();
    }
		data['chineseName'] = this.chineseName;
		data['id'] = this.id;
		return data;
	}
}

class TvBeanChannel {
	String? englishName;
	String? adImg;
	List<String?>? streams;
	String? name;
	String? icon;
	int? channelNum;
	String? id;
	int? adImgHeight;
	int? adImgWidth;
	int? channelId;
	String? url;

	TvBeanChannel({this.englishName, this.adImg, this.streams, this.name, this.icon, this.channelNum, this.id, this.adImgHeight, this.adImgWidth, this.channelId, this.url});

	TvBeanChannel.fromJson(Map<String?, dynamic> json) {
		englishName = json['englishName'];
		adImg = json['adImg'];
		streams = json['streams']?.cast<String?>();
		name = json['name'];
		icon = json['icon'];
		channelNum = json['channelNum'];
		id = json['id'];
		adImgHeight = json['adImgHeight'];
		adImgWidth = json['adImgWidth'];
		channelId = json['channelId'];
		url = json['url'];
	}

	Map<String?, dynamic> toJson() {
		final Map<String?, dynamic> data = new Map<String?, dynamic>();
		data['englishName'] = this.englishName;
		data['adImg'] = this.adImg;
		data['streams'] = this.streams;
		data['name'] = this.name;
		data['icon'] = this.icon;
		data['channelNum'] = this.channelNum;
		data['id'] = this.id;
		data['adImgHeight'] = this.adImgHeight;
		data['adImgWidth'] = this.adImgWidth;
		data['channelId'] = this.channelId;
		data['url'] = this.url;
		return data;
	}
}
