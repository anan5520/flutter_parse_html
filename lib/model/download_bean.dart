

class DownloadItem{
  double? progress;
  int? size;
  DownloadStatus? status;
  String? title;
  String? path;

}

  enum DownloadStatus{
  downing,complete
  }