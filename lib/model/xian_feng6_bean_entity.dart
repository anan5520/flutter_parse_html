import 'package:flutter/services.dart';

class XianFeng6BeanEntity {
	List<String> vod;
	List<Data> data;

	XianFeng6BeanEntity({this.vod, this.data});

	XianFeng6BeanEntity.fromJson(Map<String, dynamic> json) {
		vod = json['Vod'].cast<String>();
		if (json['Data'] != null) {
			data = new List<Data>();
			json['Data'].forEach((v) { data.add(new Data.fromJson(v)); });
		}
	}

	Map<String, dynamic> toJson() {
		final Map<String, dynamic> data = new Map<String, dynamic>();
		data['Vod'] = this.vod;
		if (this.data != null) {
			data['Data'] = this.data.map((v) => v.toJson()).toList();
		}
		return data;
	}
}

class Data {
	String servername;
	String playname;
	List<List<String>> playurls;

	Data({this.servername, this.playname, this.playurls});

	Data.fromJson(Map<String, dynamic> json) {
		servername = json['servername'];
		playname = json['playname'];
		if (json['playurls'] != null) {
			playurls = new List<List<String>>();
			json['playurls'].forEach((v) {
				var list = new List<String>();
				v.forEach((s){
					list.add(s);
				});
				playurls.add(list);});
		}
	}

	Map<String, dynamic> toJson() {
		final Map<String, dynamic> data = new Map<String, dynamic>();
		data['servername'] = this.servername;
		data['playname'] = this.playname;
		if (this.playurls != null) {
		}
		return data;
	}
}

