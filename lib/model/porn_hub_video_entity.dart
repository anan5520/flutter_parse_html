class PornHubVideoEntity {
	String mp4Seek;
	String videoDuration;
	String vcServerUrl;
	PornHubVideoNextvideo nextVideo;
	String quality720p;
	String relatedUrl;
	String isp;
	int startLagThreshold;
	String pauserollUrl;
	String language;
	String mostviewedUrl;
	int disableSharebar;
	List<int> hotspots;
	String actionTags;
	String topratedUrl;
	String geo;
	String videoUnavailableCountry;
	PornHubVideoPrerollglobalconfig prerollGlobalConfig;
	String autoreplay;
	String isHD;
	String appId;
	bool hidePostPauseRoll;
	String options;
	String linkUrl;
	String tubesCmsPrerollConfigType;
	String experimentId;
	String quality480p;
	bool enableBitmovinDebug;
	String embedCode;
	String errorReports;
	String htmlPauseRoll;
	String quality240p;
	List<PornHubVideoMediadefinition> mediaDefinitions;
	String htmlPostRoll;
	int outBufferLagThreshold;
	int maxInitialBufferLength;
	String videoUnavailable;
	String imageUrl;
	String postrollUrl;
	String cdn;
	String autoplay;
	String videoTitle;
	String isVertical;
	String service;
	String cdnProvider;
	List<int> defaultQuality;
	PornHubVideoThumbs thumbs;

	PornHubVideoEntity({this.mp4Seek, this.videoDuration, this.vcServerUrl, this.nextVideo, this.quality720p, this.relatedUrl, this.isp, this.startLagThreshold, this.pauserollUrl, this.language, this.mostviewedUrl, this.disableSharebar, this.hotspots, this.actionTags, this.topratedUrl, this.geo, this.videoUnavailableCountry, this.prerollGlobalConfig, this.autoreplay, this.isHD, this.appId, this.hidePostPauseRoll, this.options, this.linkUrl, this.tubesCmsPrerollConfigType, this.experimentId, this.quality480p, this.enableBitmovinDebug, this.embedCode, this.errorReports, this.htmlPauseRoll, this.quality240p, this.mediaDefinitions, this.htmlPostRoll, this.outBufferLagThreshold, this.maxInitialBufferLength, this.videoUnavailable, this.imageUrl, this.postrollUrl, this.cdn, this.autoplay, this.videoTitle, this.isVertical, this.service, this.cdnProvider, this.defaultQuality, this.thumbs});

	PornHubVideoEntity.fromJson(Map<String, dynamic> json) {
		mp4Seek = json['mp4_seek'];
		videoDuration = json['video_duration'];
		vcServerUrl = json['vcServerUrl'];
		nextVideo = json['nextVideo'] != null ? new PornHubVideoNextvideo.fromJson(json['nextVideo']) : null;
		quality720p = json['quality_720p'];
		relatedUrl = json['related_url'];
		isp = json['isp'];
		startLagThreshold = json['startLagThreshold'];
		pauserollUrl = json['pauseroll_url'];
		language = json['language'];
		mostviewedUrl = json['mostviewed_url'];
		disableSharebar = json['disable_sharebar'];
		hotspots = json['hotspots']?.cast<int>();
		actionTags = json['actionTags'];
		topratedUrl = json['toprated_url'];
		geo = json['geo'];
		videoUnavailableCountry = json['video_unavailable_country'];
		prerollGlobalConfig = json['prerollGlobalConfig'] != null ? new PornHubVideoPrerollglobalconfig.fromJson(json['prerollGlobalConfig']) : null;
		autoreplay = json['autoreplay'];
		isHD = json['isHD'];
		appId = json['appId'];
		hidePostPauseRoll = json['hidePostPauseRoll'];
		options = json['options'];
		linkUrl = json['link_url'];
		tubesCmsPrerollConfigType = json['tubesCmsPrerollConfigType'];
		experimentId = json['experimentId'];
		quality480p = json['quality_480p'];
		enableBitmovinDebug = json['enableBitmovinDebug'];
		embedCode = json['embedCode'];
		errorReports = json['errorReports'];
		htmlPauseRoll = json['htmlPauseRoll'];
		quality240p = json['quality_240p'];
		if (json['mediaDefinitions'] != null) {
			mediaDefinitions = new List<PornHubVideoMediadefinition>();(json['mediaDefinitions'] as List).forEach((v) { mediaDefinitions.add(new PornHubVideoMediadefinition.fromJson(v)); });
		}
		htmlPostRoll = json['htmlPostRoll'];
		outBufferLagThreshold = json['outBufferLagThreshold'];
		maxInitialBufferLength = json['maxInitialBufferLength'];
		videoUnavailable = json['video_unavailable'];
		imageUrl = json['image_url'];
		postrollUrl = json['postroll_url'];
		cdn = json['cdn'];
		autoplay = json['autoplay'];
		videoTitle = json['video_title'];
		isVertical = json['isVertical'];
		service = json['service'];
		cdnProvider = json['cdnProvider'];
		defaultQuality = json['defaultQuality']?.cast<int>();
		thumbs = json['thumbs'] != null ? new PornHubVideoThumbs.fromJson(json['thumbs']) : null;
	}

	Map<String, dynamic> toJson() {
		final Map<String, dynamic> data = new Map<String, dynamic>();
		data['mp4_seek'] = this.mp4Seek;
		data['video_duration'] = this.videoDuration;
		data['vcServerUrl'] = this.vcServerUrl;
		if (this.nextVideo != null) {
      data['nextVideo'] = this.nextVideo.toJson();
    }
		data['quality_720p'] = this.quality720p;
		data['related_url'] = this.relatedUrl;
		data['isp'] = this.isp;
		data['startLagThreshold'] = this.startLagThreshold;
		data['pauseroll_url'] = this.pauserollUrl;
		data['language'] = this.language;
		data['mostviewed_url'] = this.mostviewedUrl;
		data['disable_sharebar'] = this.disableSharebar;
		data['hotspots'] = this.hotspots;
		data['actionTags'] = this.actionTags;
		data['toprated_url'] = this.topratedUrl;
		data['geo'] = this.geo;
		data['video_unavailable_country'] = this.videoUnavailableCountry;
		if (this.prerollGlobalConfig != null) {
      data['prerollGlobalConfig'] = this.prerollGlobalConfig.toJson();
    }
		data['autoreplay'] = this.autoreplay;
		data['isHD'] = this.isHD;
		data['appId'] = this.appId;
		data['hidePostPauseRoll'] = this.hidePostPauseRoll;
		data['options'] = this.options;
		data['link_url'] = this.linkUrl;
		data['tubesCmsPrerollConfigType'] = this.tubesCmsPrerollConfigType;
		data['experimentId'] = this.experimentId;
		data['quality_480p'] = this.quality480p;
		data['enableBitmovinDebug'] = this.enableBitmovinDebug;
		data['embedCode'] = this.embedCode;
		data['errorReports'] = this.errorReports;
		data['htmlPauseRoll'] = this.htmlPauseRoll;
		data['quality_240p'] = this.quality240p;
		if (this.mediaDefinitions != null) {
      data['mediaDefinitions'] =  this.mediaDefinitions.map((v) => v.toJson()).toList();
    }
		data['htmlPostRoll'] = this.htmlPostRoll;
		data['outBufferLagThreshold'] = this.outBufferLagThreshold;
		data['maxInitialBufferLength'] = this.maxInitialBufferLength;
		data['video_unavailable'] = this.videoUnavailable;
		data['image_url'] = this.imageUrl;
		data['postroll_url'] = this.postrollUrl;
		data['cdn'] = this.cdn;
		data['autoplay'] = this.autoplay;
		data['video_title'] = this.videoTitle;
		data['isVertical'] = this.isVertical;
		data['service'] = this.service;
		data['cdnProvider'] = this.cdnProvider;
		data['defaultQuality'] = this.defaultQuality;
		if (this.thumbs != null) {
      data['thumbs'] = this.thumbs.toJson();
    }
		return data;
	}
}

class PornHubVideoNextvideo {
	String duration;
	String thumb;
	String isHD;
	String nextUrl;
	String video;
	String title;
	bool isJoinPageEntry;
	String vkey;
	dynamic channelTitle;

	PornHubVideoNextvideo({this.duration, this.thumb, this.isHD, this.nextUrl, this.video, this.title, this.isJoinPageEntry, this.vkey, this.channelTitle});

	PornHubVideoNextvideo.fromJson(Map<String, dynamic> json) {
		duration = json['duration'];
		thumb = json['thumb'];
		isHD = json['isHD'];
		nextUrl = json['nextUrl'];
		video = json['video'];
		title = json['title'];
		isJoinPageEntry = json['isJoinPageEntry'];
		vkey = json['vkey'];
		channelTitle = json['channelTitle'];
	}

	Map<String, dynamic> toJson() {
		final Map<String, dynamic> data = new Map<String, dynamic>();
		data['duration'] = this.duration;
		data['thumb'] = this.thumb;
		data['isHD'] = this.isHD;
		data['nextUrl'] = this.nextUrl;
		data['video'] = this.video;
		data['title'] = this.title;
		data['isJoinPageEntry'] = this.isJoinPageEntry;
		data['vkey'] = this.vkey;
		data['channelTitle'] = this.channelTitle;
		return data;
	}
}

class PornHubVideoPrerollglobalconfig {
	int skipDelay;
	List<int> delay;
	String userAcceptLanguage;
	int forgetUserAfter;
	bool vastSkipDelay;
	bool skippable;
	String vast;
	int onNth;

	PornHubVideoPrerollglobalconfig({this.skipDelay, this.delay, this.userAcceptLanguage, this.forgetUserAfter, this.vastSkipDelay, this.skippable, this.vast, this.onNth});

	PornHubVideoPrerollglobalconfig.fromJson(Map<String, dynamic> json) {
		skipDelay = json['skipDelay'];
		delay = json['delay']?.cast<int>();
		userAcceptLanguage = json['user_accept_language'];
		forgetUserAfter = json['forgetUserAfter'];
		vastSkipDelay = json['vastSkipDelay'];
		skippable = json['skippable'];
		vast = json['vast'];
		onNth = json['onNth'];
	}

	Map<String, dynamic> toJson() {
		final Map<String, dynamic> data = new Map<String, dynamic>();
		data['skipDelay'] = this.skipDelay;
		data['delay'] = this.delay;
		data['user_accept_language'] = this.userAcceptLanguage;
		data['forgetUserAfter'] = this.forgetUserAfter;
		data['vastSkipDelay'] = this.vastSkipDelay;
		data['skippable'] = this.skippable;
		data['vast'] = this.vast;
		data['onNth'] = this.onNth;
		return data;
	}
}

class PornHubVideoMediadefinition {
	String videoUrl;
	String format;
	bool defaultQuality;
	String quality;

	PornHubVideoMediadefinition({this.videoUrl, this.format, this.defaultQuality, this.quality});

	PornHubVideoMediadefinition.fromJson(Map<String, dynamic> json) {
		videoUrl = json['videoUrl'];
		format = json['format'];
		defaultQuality = json['defaultQuality'];
		quality = json['quality'] is String?json['quality']:'';
	}

	Map<String, dynamic> toJson() {
		final Map<String, dynamic> data = new Map<String, dynamic>();
		data['videoUrl'] = this.videoUrl;
		data['format'] = this.format;
		data['defaultQuality'] = this.defaultQuality;
		data['quality'] = this.quality;
		return data;
	}
}

class PornHubVideoThumbs {
	String thumbHeight;
	String cdnType;
	int samplingFrequency;
	String urlPattern;
	String thumbWidth;
	String type;

	PornHubVideoThumbs({this.thumbHeight, this.cdnType, this.samplingFrequency, this.urlPattern, this.thumbWidth, this.type});

	PornHubVideoThumbs.fromJson(Map<String, dynamic> json) {
		thumbHeight = json['thumbHeight'];
		cdnType = json['cdnType'];
		samplingFrequency = json['samplingFrequency'];
		urlPattern = json['urlPattern'];
		thumbWidth = json['thumbWidth'];
		type = json['type'];
	}

	Map<String, dynamic> toJson() {
		final Map<String, dynamic> data = new Map<String, dynamic>();
		data['thumbHeight'] = this.thumbHeight;
		data['cdnType'] = this.cdnType;
		data['samplingFrequency'] = this.samplingFrequency;
		data['urlPattern'] = this.urlPattern;
		data['thumbWidth'] = this.thumbWidth;
		data['type'] = this.type;
		return data;
	}
}
