class PornItem {
  String viewKey;
  String title;
  String imgUrl;
  String duration;
  String info;

  PornItem(this.viewKey, this.title, this.imgUrl, this.duration, this.info);
}

class VideoResult {
  static final int OUT_OF_WATCH_TIMES = -1;
  int id;
  String videoUrl;

  String videoId;

  String ownerId = '';

  String authorId;

  String thumbImgUrl;
  String videoName;
  String ownerName;
  String addDate;
  String viewKey;
  String userOtherInfo;

  @override
  String toString() {
    return 'VideoResult{id: $id, videoUrl: $videoUrl, videoId: $videoId, ownerId: $ownerId, authorId: $authorId, thumbImgUrl: $thumbImgUrl, videoName: $videoName, ownerName: $ownerName, addDate: $addDate, viewKey: $viewKey, userOtherInfo: $userOtherInfo}';
  }
}

class VideoComment {
  String uid;
  String uName;
  String replyTime;
  String replyId;
  String titleInfo;
  String content;
  PornForumContent pornForumContent;
  List<String> commentQuoteList;

  @override
  String toString() {
    return 'VideoComment{uid: $uid, uName: $uName, replyTime: $replyTime, replyId: $replyId, titleInfo: $titleInfo, commentQuoteList: $commentQuoteList}';
  }
}

class PornForumItem {
  static final int serialVersionUID = 1;

  String folder;
  String icon;

  int tid;
  String title;
  List<String> imageList;
  String agreeCount;

  String author;
  String authorPublishTime;
  int replyCount;
  int viewCount;
  String lastPostAuthor;
  String lastPostTime;

  @override
  String toString() {
    return 'PornForumItem{folder: $folder, icon: $icon, tid: $tid, title: $title, imageList: $imageList, agreeCount: $agreeCount, author: $author, authorPublishTime: $authorPublishTime, replyCount: $replyCount, viewCount: $viewCount, lastPostAuthor: $lastPostAuthor, lastPostTime: $lastPostTime}';
  }
}

class PornForumContent {
  String content;
  String videoUrl = '';
  List<String> imageList;
  List<CiLiUrl> ciLiList;

  @override
  String toString() {
    return 'PornForumContent{content: $content, imageList: $imageList}';
  }
}

class CiLiUrl{
  String title;
  String url;
}
