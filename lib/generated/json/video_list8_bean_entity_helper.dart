import 'package:flutter_parse_html/model/video_list8_bean_entity.dart';

videoList8BeanEntityFromJson(VideoList8BeanEntity data, Map<String, dynamic> json) {
	if (json['ajax_url'] != null) {
		data.ajaxUrl = json['ajax_url'].toString();
	}
	if (json['home_url'] != null) {
		data.homeUrl = json['home_url'].toString();
	}
	if (json['UID'] != null) {
		data.uID = json['UID'].toString();
	}
	if (json['PID'] != null) {
		data.pID = json['PID'].toString();
	}
	if (json['TOKEN'] != null) {
		data.tOKEN = json['TOKEN'].toString();
	}
	if (json['LINE'] != null) {
		data.lINE = json['LINE'].toString();
	}
	return data;
}

Map<String, dynamic> videoList8BeanEntityToJson(VideoList8BeanEntity entity) {
	final Map<String, dynamic> data = new Map<String, dynamic>();
	data['ajax_url'] = entity.ajaxUrl;
	data['home_url'] = entity.homeUrl;
	data['UID'] = entity.uID;
	data['PID'] = entity.pID;
	data['TOKEN'] = entity.tOKEN;
	data['LINE'] = entity.lINE;
	return data;
}