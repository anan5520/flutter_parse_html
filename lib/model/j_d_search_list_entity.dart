import 'package:flutter_parse_html/generated/json/base/json_convert_content.dart';
import 'package:flutter_parse_html/generated/json/base/json_field.dart';

class JDSearchListEntity with JsonConvert<JDSearchListEntity> {
	String retcode;
	String errmsg;
	JDSearchListData data;
}

class JDSearchListData with JsonConvert<JDSearchListData> {
	JDSearchListDataSearchm searchm;
}

class JDSearchListDataSearchm with JsonConvert<JDSearchListDataSearchm> {
	@JSONField(name: "Paragraph")
	List<JDSearchListDataSearchmParagraph> paragraph;
}

class JDSearchListDataSearchmParagraph with JsonConvert<JDSearchListDataSearchmParagraph> {
	@JSONField(name: "Content")
	JDSearchListDataSearchmParagraphContent content;
	String toShopLink;
	String toItemLink;
	String catid;
	String cid1;
	String cid2;
	String dredisprice;
	String eredisprice;
	String good;
	String hotscore;
	String hprice;
	String ico;
	String productext;
	String productext2;
	@JSONField(name: "shop_id")
	String shopId;
	@JSONField(name: "vender_id")
	String venderId;
	String wareid;
	String discountIcon;
	@JSONField(name: "promotion_id")
	String promotionId;
	@JSONField(name: "promotion_type")
	String promotionType;
	String couponIcon;
	JDSearchListDataSearchmParagraphCoupon coupon;
	List<String> pf;
	JDSearchListDataSearchmParagraphPfdt pfdt;
	String fqy;
	@JSONField(name: "feature_log")
	String featureLog;
	String lowestbuy;
	String wareWeight;
	@JSONField(name: "property_flag")
	String propertyFlag;
	String flags;
	String sendService;
	String isActualServ;
	@JSONField(name: "sku_mark")
	String skuMark;
	String venderType;
	String bjssy;
	JDSearchListDataSearchmParagraphOldWareInfo oldWareInfo;
	JDSearchListDataSearchmParagraphPinGou pinGou;
	JDSearchListDataSearchmParagraphPriceReal priceReal;
	@JSONField(name: "is_video")
	String isVideo;
	String isSeptax;
	String userPsnProductNew;
	String freeMark;
	@JSONField(name: "showlog_new")
	String showlogNew;
	@JSONField(name: "brand_id")
	String brandId;
	String sxzz;
	String wareInStock;
	String jzfp;
	String award;
	String isOverSea;
	String isbjp;
	String isPgShop;
	String fanxianPeople;
	String fanxianFuzzyPeople;
	String fanxianPrice;
	String fanxianType;
	String fanxianCash;
	String fanxianLabel;
}

class JDSearchListDataSearchmParagraphContent with JsonConvert<JDSearchListDataSearchmParagraphContent> {
	String author;
	String imageurl;
	@JSONField(name: "long_image_url")
	String longImageUrl;
	@JSONField(name: "shop_name")
	String shopName;
	String warename;
	@JSONField(name: "CustomAttrList")
	String customAttrList;
	String shortWarename;
	String gaiyawarename;
	String extname;
}

class JDSearchListDataSearchmParagraphCoupon with JsonConvert<JDSearchListDataSearchmParagraphCoupon> {
	String m;
	String j;
	String t;
	String b;
	JDSearchListDataSearchmParagraphCouponD d;
}

class JDSearchListDataSearchmParagraphCouponD with JsonConvert<JDSearchListDataSearchmParagraphCouponD> {
	String high;
	List<dynamic> info;
}

class JDSearchListDataSearchmParagraphPfdt with JsonConvert<JDSearchListDataSearchmParagraphPfdt> {
	String t;
	String m;
	String j;
}

class JDSearchListDataSearchmParagraphOldWareInfo with JsonConvert<JDSearchListDataSearchmParagraphOldWareInfo> {
	@JSONField(name: "old_min_price")
	String oldMinPrice;
}

class JDSearchListDataSearchmParagraphPinGou with JsonConvert<JDSearchListDataSearchmParagraphPinGou> {
	String bp;
	String count;
}

class JDSearchListDataSearchmParagraphPriceReal with JsonConvert<JDSearchListDataSearchmParagraphPriceReal> {
	String up;
	String p;
	String tkp;
	String sp;
	String tpp;
	String l;
	String cbf;
	String nup;
	String sdp;
	String sfp;
	String app;
}
