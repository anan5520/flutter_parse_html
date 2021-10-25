import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:file/src/interface/file.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_parse_html/book/api/api_novel.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class NovelBookCacheModel extends BaseCacheManager{
  static const key = "libCacheNovelData";

  static NovelBookCacheModel _instance;

  factory NovelBookCacheModel() {
    if (_instance == null) {
      _instance = new NovelBookCacheModel._();
    }
    return _instance;
  }

  NovelBookCacheModel._() : super();

  Future<String> getFilePath() async {
    var directory = await getTemporaryDirectory();
    return p.join(directory.path, key);
  }

  Future<File> _getNovelPersistentCacheFile(String url, {Map<String, String> headers}) async {
    FileInfo cacheFile = await getFileFromCache(url);
    if (cacheFile != null&&cacheFile.file!=null) {
      return cacheFile.file;
    }else {
      removeFile(url);
      try {
        var download = await getSingleFile(url, headers: headers);
        return download;
      } catch (e) {
        return null;
      }
    }
  }

  Future<String> getCacheChapterContent(String chapterLink) async{
    File targetFile = await _getNovelPersistentCacheFile(chapterLink);

    if (targetFile == null) {
      return null;
    } else {
      Uint8List bytes = await targetFile.readAsBytes();
      return utf8.decode(bytes, allowMalformed: true);
    }
  }

  @override
  Future<void> dispose() {
    // TODO: implement dispose
    throw UnimplementedError();
  }

  @override
  Future<FileInfo> downloadFile(String url, {String key, Map<String, String> authHeaders, bool force = false}) {
    // TODO: implement downloadFile
    throw UnimplementedError();
  }

  @override
  Future<void> emptyCache() {
    // TODO: implement emptyCache
    throw UnimplementedError();
  }

  @override
  Stream<FileInfo> getFile(String url, {String key, Map<String, String> headers}) {
    // TODO: implement getFile
    throw UnimplementedError();
  }

  @override
  Future<FileInfo> getFileFromCache(String key, {bool ignoreMemCache = false}) {
    // TODO: implement getFileFromCache
    throw UnimplementedError();
  }

  @override
  Future<FileInfo> getFileFromMemory(String key) {
    // TODO: implement getFileFromMemory
    throw UnimplementedError();
  }

  @override
  Stream<FileResponse> getFileStream(String url, {String key, Map<String, String> headers, bool withProgress}) {
    // TODO: implement getFileStream
    throw UnimplementedError();
  }

  @override
  Future<File> getSingleFile(String url, {String key, Map<String, String> headers}) {
    // TODO: implement getSingleFile
    throw UnimplementedError();
  }

  @override
  Future<File> putFile(String url, Uint8List fileBytes, {String key, String eTag, Duration maxAge = const Duration(days: 30), String fileExtension = 'file'}) {
    // TODO: implement putFile
    throw UnimplementedError();
  }

  @override
  Future<File> putFileStream(String url, Stream<List<int>> source, {String key, String eTag, Duration maxAge = const Duration(days: 30), String fileExtension = 'file'}) {
    // TODO: implement putFileStream
    throw UnimplementedError();
  }

  @override
  Future<void> removeFile(String key) {
    // TODO: implement removeFile
    throw UnimplementedError();
  }

}