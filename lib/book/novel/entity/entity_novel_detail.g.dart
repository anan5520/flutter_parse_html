// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'entity_novel_detail.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NovelDetailInfo _$NovelDetailInfoFromJson(Map<String, dynamic> json) {
  return NovelDetailInfo(
    json['_id'] as String,
    json['title'] as String,
    json['author'] as String,
    json['cover'] as String,
    json['totalFollower'] as int,
    json['wordCount'] as String,
    json['tags'] as List,
    json['longIntro'] as String,
  );
}

Map<String, dynamic> _$NovelDetailInfoToJson(NovelDetailInfo instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'title': instance.title,
      'author': instance.author,
      'majorCate': instance.majorCate,
      'cover': instance.cover,
      'longIntro': instance.longIntro,
      'starRatingCount': instance.starRatingCount,
      'starRatings': instance.starRatings,
      'isMakeMoneyLimit': instance.isMakeMoneyLimit,
      'contentLevel': instance.contentLevel,
      'isFineBook': instance.isFineBook,
      'safelevel': instance.safelevel,
      'allowFree': instance.allowFree,
      'originalAuthor': instance.originalAuthor,
      'anchors': instance.anchors,
      'authorDesc': instance.authorDesc,
      'rating': instance.rating,
      'hasCopyright': instance.hasCopyright,
      'buytype': instance.buytype,
      'sizetype': instance.sizetype,
      'superscript': instance.superscript,
      'currency': instance.currency,
      'contentType': instance.contentType,
      '_le': instance.le,
      'allowMonthly': instance.allowMonthly,
      'allowVoucher': instance.allowVoucher,
      'allowBeanVoucher': instance.allowBeanVoucher,
      'hasCp': instance.hasCp,
      'banned': instance.banned,
      'postCount': instance.postCount,
      'totalFollower': instance.totalFollower,
      'latelyFollower': instance.latelyFollower,
      'followerCount': instance.followerCount,
      'wordCount': instance.wordCount,
      'serializeWordCount': instance.serializeWordCount,
      'retentionRatio': instance.retentionRatio,
      'updated': instance.updated,
      'isSerial': instance.isSerial,
      'chaptersCount': instance.chaptersCount,
      'lastChapter': instance.lastChapter,
      'gender': instance.gender,
      'tags': instance.tags,
      'advertRead': instance.advertRead,
      'donate': instance.donate,
      'copyright': instance.copyright,
      '_gg': instance.gg,
      'isForbidForFreeApp': instance.isForbidForFreeApp,
      'isAllowNetSearch': instance.isAllowNetSearch,
      'limit': instance.limit,
      'copyrightInfo': instance.copyrightInfo,
      'copyrightDesc': instance.copyrightDesc,
    };

StarRatings _$StarRatingsFromJson(Map<String, dynamic> json) {
  return StarRatings(
    json['count'] as int,
    json['star'] as int,
  );
}

Map<String, dynamic> _$StarRatingsToJson(StarRatings instance) =>
    <String, dynamic>{
      'count': instance.count,
      'star': instance.star,
    };

Rating _$RatingFromJson(Map<String, dynamic> json) {
  return Rating(
    (json['score'] as num)?.toDouble(),
    json['count'] as int,
    json['tip'] as String,
    json['isEffect'] as bool,
  );
}

Map<String, dynamic> _$RatingToJson(Rating instance) => <String, dynamic>{
      'score': instance.score,
      'count': instance.count,
      'tip': instance.tip,
      'isEffect': instance.isEffect,
    };
