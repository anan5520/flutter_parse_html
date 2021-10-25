import 'package:flutter_parse_html/model/j_d_search_list_entity.dart';

jDSearchListEntityFromJson(JDSearchListEntity data, Map<String, dynamic> json) {
	if (json['retcode'] != null) {
		data.retcode = json['retcode'].toString();
	}
	if (json['errmsg'] != null) {
		data.errmsg = json['errmsg'].toString();
	}
	if (json['data'] != null) {
		data.data = JDSearchListData().fromJson(json['data']);
	}
	return data;
}

Map<String, dynamic> jDSearchListEntityToJson(JDSearchListEntity entity) {
	final Map<String, dynamic> data = new Map<String, dynamic>();
	data['retcode'] = entity.retcode;
	data['errmsg'] = entity.errmsg;
	data['data'] = entity.data?.toJson();
	return data;
}

jDSearchListDataFromJson(JDSearchListData data, Map<String, dynamic> json) {
	if (json['searchm'] != null) {
		data.searchm = JDSearchListDataSearchm().fromJson(json['searchm']);
	}
	return data;
}

Map<String, dynamic> jDSearchListDataToJson(JDSearchListData entity) {
	final Map<String, dynamic> data = new Map<String, dynamic>();
	data['searchm'] = entity.searchm?.toJson();
	return data;
}

jDSearchListDataSearchmFromJson(JDSearchListDataSearchm data, Map<String, dynamic> json) {
	if (json['Paragraph'] != null) {
		data.paragraph = (json['Paragraph'] as List).map((v) => JDSearchListDataSearchmParagraph().fromJson(v)).toList();
	}
	return data;
}

Map<String, dynamic> jDSearchListDataSearchmToJson(JDSearchListDataSearchm entity) {
	final Map<String, dynamic> data = new Map<String, dynamic>();
	data['Paragraph'] =  entity.paragraph?.map((v) => v.toJson())?.toList();
	return data;
}

jDSearchListDataSearchmParagraphFromJson(JDSearchListDataSearchmParagraph data, Map<String, dynamic> json) {
	if (json['Content'] != null) {
		data.content = JDSearchListDataSearchmParagraphContent().fromJson(json['Content']);
	}
	if (json['toShopLink'] != null) {
		data.toShopLink = json['toShopLink'].toString();
	}
	if (json['toItemLink'] != null) {
		data.toItemLink = json['toItemLink'].toString();
	}
	if (json['catid'] != null) {
		data.catid = json['catid'].toString();
	}
	if (json['cid1'] != null) {
		data.cid1 = json['cid1'].toString();
	}
	if (json['cid2'] != null) {
		data.cid2 = json['cid2'].toString();
	}
	if (json['dredisprice'] != null) {
		data.dredisprice = json['dredisprice'].toString();
	}
	if (json['eredisprice'] != null) {
		data.eredisprice = json['eredisprice'].toString();
	}
	if (json['good'] != null) {
		data.good = json['good'].toString();
	}
	if (json['hotscore'] != null) {
		data.hotscore = json['hotscore'].toString();
	}
	if (json['hprice'] != null) {
		data.hprice = json['hprice'].toString();
	}
	if (json['ico'] != null) {
		data.ico = json['ico'].toString();
	}
	if (json['productext'] != null) {
		data.productext = json['productext'].toString();
	}
	if (json['productext2'] != null) {
		data.productext2 = json['productext2'].toString();
	}
	if (json['shop_id'] != null) {
		data.shopId = json['shop_id'].toString();
	}
	if (json['vender_id'] != null) {
		data.venderId = json['vender_id'].toString();
	}
	if (json['wareid'] != null) {
		data.wareid = json['wareid'].toString();
	}
	if (json['discountIcon'] != null) {
		data.discountIcon = json['discountIcon'].toString();
	}
	if (json['promotion_id'] != null) {
		data.promotionId = json['promotion_id'].toString();
	}
	if (json['promotion_type'] != null) {
		data.promotionType = json['promotion_type'].toString();
	}
	if (json['couponIcon'] != null) {
		data.couponIcon = json['couponIcon'].toString();
	}
	if (json['coupon'] != null) {
		data.coupon = JDSearchListDataSearchmParagraphCoupon().fromJson(json['coupon']);
	}
	if (json['pf'] != null) {
		data.pf = (json['pf'] as List).map((v) => v.toString()).toList().cast<String>();
	}
	if (json['pfdt'] != null) {
		data.pfdt = JDSearchListDataSearchmParagraphPfdt().fromJson(json['pfdt']);
	}
	if (json['fqy'] != null) {
		data.fqy = json['fqy'].toString();
	}
	if (json['feature_log'] != null) {
		data.featureLog = json['feature_log'].toString();
	}
	if (json['lowestbuy'] != null) {
		data.lowestbuy = json['lowestbuy'].toString();
	}
	if (json['wareWeight'] != null) {
		data.wareWeight = json['wareWeight'].toString();
	}
	if (json['property_flag'] != null) {
		data.propertyFlag = json['property_flag'].toString();
	}
	if (json['flags'] != null) {
		data.flags = json['flags'].toString();
	}
	if (json['sendService'] != null) {
		data.sendService = json['sendService'].toString();
	}
	if (json['isActualServ'] != null) {
		data.isActualServ = json['isActualServ'].toString();
	}
	if (json['sku_mark'] != null) {
		data.skuMark = json['sku_mark'].toString();
	}
	if (json['venderType'] != null) {
		data.venderType = json['venderType'].toString();
	}
	if (json['bjssy'] != null) {
		data.bjssy = json['bjssy'].toString();
	}
	if (json['oldWareInfo'] != null) {
		data.oldWareInfo = JDSearchListDataSearchmParagraphOldWareInfo().fromJson(json['oldWareInfo']);
	}
	if (json['pinGou'] != null) {
		data.pinGou = JDSearchListDataSearchmParagraphPinGou().fromJson(json['pinGou']);
	}
	if (json['priceReal'] != null) {
		data.priceReal = JDSearchListDataSearchmParagraphPriceReal().fromJson(json['priceReal']);
	}
	if (json['is_video'] != null) {
		data.isVideo = json['is_video'].toString();
	}
	if (json['isSeptax'] != null) {
		data.isSeptax = json['isSeptax'].toString();
	}
	if (json['userPsnProductNew'] != null) {
		data.userPsnProductNew = json['userPsnProductNew'].toString();
	}
	if (json['freeMark'] != null) {
		data.freeMark = json['freeMark'].toString();
	}
	if (json['showlog_new'] != null) {
		data.showlogNew = json['showlog_new'].toString();
	}
	if (json['brand_id'] != null) {
		data.brandId = json['brand_id'].toString();
	}
	if (json['sxzz'] != null) {
		data.sxzz = json['sxzz'].toString();
	}
	if (json['wareInStock'] != null) {
		data.wareInStock = json['wareInStock'].toString();
	}
	if (json['jzfp'] != null) {
		data.jzfp = json['jzfp'].toString();
	}
	if (json['award'] != null) {
		data.award = json['award'].toString();
	}
	if (json['isOverSea'] != null) {
		data.isOverSea = json['isOverSea'].toString();
	}
	if (json['isbjp'] != null) {
		data.isbjp = json['isbjp'].toString();
	}
	if (json['isPgShop'] != null) {
		data.isPgShop = json['isPgShop'].toString();
	}
	if (json['fanxianPeople'] != null) {
		data.fanxianPeople = json['fanxianPeople'].toString();
	}
	if (json['fanxianFuzzyPeople'] != null) {
		data.fanxianFuzzyPeople = json['fanxianFuzzyPeople'].toString();
	}
	if (json['fanxianPrice'] != null) {
		data.fanxianPrice = json['fanxianPrice'].toString();
	}
	if (json['fanxianType'] != null) {
		data.fanxianType = json['fanxianType'].toString();
	}
	if (json['fanxianCash'] != null) {
		data.fanxianCash = json['fanxianCash'].toString();
	}
	if (json['fanxianLabel'] != null) {
		data.fanxianLabel = json['fanxianLabel'].toString();
	}
	return data;
}

Map<String, dynamic> jDSearchListDataSearchmParagraphToJson(JDSearchListDataSearchmParagraph entity) {
	final Map<String, dynamic> data = new Map<String, dynamic>();
	data['Content'] = entity.content?.toJson();
	data['toShopLink'] = entity.toShopLink;
	data['toItemLink'] = entity.toItemLink;
	data['catid'] = entity.catid;
	data['cid1'] = entity.cid1;
	data['cid2'] = entity.cid2;
	data['dredisprice'] = entity.dredisprice;
	data['eredisprice'] = entity.eredisprice;
	data['good'] = entity.good;
	data['hotscore'] = entity.hotscore;
	data['hprice'] = entity.hprice;
	data['ico'] = entity.ico;
	data['productext'] = entity.productext;
	data['productext2'] = entity.productext2;
	data['shop_id'] = entity.shopId;
	data['vender_id'] = entity.venderId;
	data['wareid'] = entity.wareid;
	data['discountIcon'] = entity.discountIcon;
	data['promotion_id'] = entity.promotionId;
	data['promotion_type'] = entity.promotionType;
	data['couponIcon'] = entity.couponIcon;
	data['coupon'] = entity.coupon?.toJson();
	data['pf'] = entity.pf;
	data['pfdt'] = entity.pfdt?.toJson();
	data['fqy'] = entity.fqy;
	data['feature_log'] = entity.featureLog;
	data['lowestbuy'] = entity.lowestbuy;
	data['wareWeight'] = entity.wareWeight;
	data['property_flag'] = entity.propertyFlag;
	data['flags'] = entity.flags;
	data['sendService'] = entity.sendService;
	data['isActualServ'] = entity.isActualServ;
	data['sku_mark'] = entity.skuMark;
	data['venderType'] = entity.venderType;
	data['bjssy'] = entity.bjssy;
	data['oldWareInfo'] = entity.oldWareInfo?.toJson();
	data['pinGou'] = entity.pinGou?.toJson();
	data['priceReal'] = entity.priceReal?.toJson();
	data['is_video'] = entity.isVideo;
	data['isSeptax'] = entity.isSeptax;
	data['userPsnProductNew'] = entity.userPsnProductNew;
	data['freeMark'] = entity.freeMark;
	data['showlog_new'] = entity.showlogNew;
	data['brand_id'] = entity.brandId;
	data['sxzz'] = entity.sxzz;
	data['wareInStock'] = entity.wareInStock;
	data['jzfp'] = entity.jzfp;
	data['award'] = entity.award;
	data['isOverSea'] = entity.isOverSea;
	data['isbjp'] = entity.isbjp;
	data['isPgShop'] = entity.isPgShop;
	data['fanxianPeople'] = entity.fanxianPeople;
	data['fanxianFuzzyPeople'] = entity.fanxianFuzzyPeople;
	data['fanxianPrice'] = entity.fanxianPrice;
	data['fanxianType'] = entity.fanxianType;
	data['fanxianCash'] = entity.fanxianCash;
	data['fanxianLabel'] = entity.fanxianLabel;
	return data;
}

jDSearchListDataSearchmParagraphContentFromJson(JDSearchListDataSearchmParagraphContent data, Map<String, dynamic> json) {
	if (json['author'] != null) {
		data.author = json['author'].toString();
	}
	if (json['imageurl'] != null) {
		data.imageurl = json['imageurl'].toString();
	}
	if (json['long_image_url'] != null) {
		data.longImageUrl = json['long_image_url'].toString();
	}
	if (json['shop_name'] != null) {
		data.shopName = json['shop_name'].toString();
	}
	if (json['warename'] != null) {
		data.warename = json['warename'].toString();
	}
	if (json['CustomAttrList'] != null) {
		data.customAttrList = json['CustomAttrList'].toString();
	}
	if (json['shortWarename'] != null) {
		data.shortWarename = json['shortWarename'].toString();
	}
	if (json['gaiyawarename'] != null) {
		data.gaiyawarename = json['gaiyawarename'].toString();
	}
	if (json['extname'] != null) {
		data.extname = json['extname'].toString();
	}
	return data;
}

Map<String, dynamic> jDSearchListDataSearchmParagraphContentToJson(JDSearchListDataSearchmParagraphContent entity) {
	final Map<String, dynamic> data = new Map<String, dynamic>();
	data['author'] = entity.author;
	data['imageurl'] = entity.imageurl;
	data['long_image_url'] = entity.longImageUrl;
	data['shop_name'] = entity.shopName;
	data['warename'] = entity.warename;
	data['CustomAttrList'] = entity.customAttrList;
	data['shortWarename'] = entity.shortWarename;
	data['gaiyawarename'] = entity.gaiyawarename;
	data['extname'] = entity.extname;
	return data;
}

jDSearchListDataSearchmParagraphCouponFromJson(JDSearchListDataSearchmParagraphCoupon data, Map<String, dynamic> json) {
	if (json['m'] != null) {
		data.m = json['m'].toString();
	}
	if (json['j'] != null) {
		data.j = json['j'].toString();
	}
	if (json['t'] != null) {
		data.t = json['t'].toString();
	}
	if (json['b'] != null) {
		data.b = json['b'].toString();
	}
	if (json['d'] != null) {
		data.d = JDSearchListDataSearchmParagraphCouponD().fromJson(json['d']);
	}
	return data;
}

Map<String, dynamic> jDSearchListDataSearchmParagraphCouponToJson(JDSearchListDataSearchmParagraphCoupon entity) {
	final Map<String, dynamic> data = new Map<String, dynamic>();
	data['m'] = entity.m;
	data['j'] = entity.j;
	data['t'] = entity.t;
	data['b'] = entity.b;
	data['d'] = entity.d?.toJson();
	return data;
}

jDSearchListDataSearchmParagraphCouponDFromJson(JDSearchListDataSearchmParagraphCouponD data, Map<String, dynamic> json) {
	if (json['high'] != null) {
		data.high = json['high'].toString();
	}
	if (json['info'] != null) {
		data.info = (json['info'] as List).map((v) => v).toList().cast<dynamic>();
	}
	return data;
}

Map<String, dynamic> jDSearchListDataSearchmParagraphCouponDToJson(JDSearchListDataSearchmParagraphCouponD entity) {
	final Map<String, dynamic> data = new Map<String, dynamic>();
	data['high'] = entity.high;
	data['info'] = entity.info;
	return data;
}

jDSearchListDataSearchmParagraphPfdtFromJson(JDSearchListDataSearchmParagraphPfdt data, Map<String, dynamic> json) {
	if (json['t'] != null) {
		data.t = json['t'].toString();
	}
	if (json['m'] != null) {
		data.m = json['m'].toString();
	}
	if (json['j'] != null) {
		data.j = json['j'].toString();
	}
	return data;
}

Map<String, dynamic> jDSearchListDataSearchmParagraphPfdtToJson(JDSearchListDataSearchmParagraphPfdt entity) {
	final Map<String, dynamic> data = new Map<String, dynamic>();
	data['t'] = entity.t;
	data['m'] = entity.m;
	data['j'] = entity.j;
	return data;
}

jDSearchListDataSearchmParagraphOldWareInfoFromJson(JDSearchListDataSearchmParagraphOldWareInfo data, Map<String, dynamic> json) {
	if (json['old_min_price'] != null) {
		data.oldMinPrice = json['old_min_price'].toString();
	}
	return data;
}

Map<String, dynamic> jDSearchListDataSearchmParagraphOldWareInfoToJson(JDSearchListDataSearchmParagraphOldWareInfo entity) {
	final Map<String, dynamic> data = new Map<String, dynamic>();
	data['old_min_price'] = entity.oldMinPrice;
	return data;
}

jDSearchListDataSearchmParagraphPinGouFromJson(JDSearchListDataSearchmParagraphPinGou data, Map<String, dynamic> json) {
	if (json['bp'] != null) {
		data.bp = json['bp'].toString();
	}
	if (json['count'] != null) {
		data.count = json['count'].toString();
	}
	return data;
}

Map<String, dynamic> jDSearchListDataSearchmParagraphPinGouToJson(JDSearchListDataSearchmParagraphPinGou entity) {
	final Map<String, dynamic> data = new Map<String, dynamic>();
	data['bp'] = entity.bp;
	data['count'] = entity.count;
	return data;
}

jDSearchListDataSearchmParagraphPriceRealFromJson(JDSearchListDataSearchmParagraphPriceReal data, Map<String, dynamic> json) {
	if (json['up'] != null) {
		data.up = json['up'].toString();
	}
	if (json['p'] != null) {
		data.p = json['p'].toString();
	}
	if (json['tkp'] != null) {
		data.tkp = json['tkp'].toString();
	}
	if (json['sp'] != null) {
		data.sp = json['sp'].toString();
	}
	if (json['tpp'] != null) {
		data.tpp = json['tpp'].toString();
	}
	if (json['l'] != null) {
		data.l = json['l'].toString();
	}
	if (json['cbf'] != null) {
		data.cbf = json['cbf'].toString();
	}
	if (json['nup'] != null) {
		data.nup = json['nup'].toString();
	}
	if (json['sdp'] != null) {
		data.sdp = json['sdp'].toString();
	}
	if (json['sfp'] != null) {
		data.sfp = json['sfp'].toString();
	}
	if (json['app'] != null) {
		data.app = json['app'].toString();
	}
	return data;
}

Map<String, dynamic> jDSearchListDataSearchmParagraphPriceRealToJson(JDSearchListDataSearchmParagraphPriceReal entity) {
	final Map<String, dynamic> data = new Map<String, dynamic>();
	data['up'] = entity.up;
	data['p'] = entity.p;
	data['tkp'] = entity.tkp;
	data['sp'] = entity.sp;
	data['tpp'] = entity.tpp;
	data['l'] = entity.l;
	data['cbf'] = entity.cbf;
	data['nup'] = entity.nup;
	data['sdp'] = entity.sdp;
	data['sfp'] = entity.sfp;
	data['app'] = entity.app;
	return data;
}