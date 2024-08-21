import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite/sqlite_api.dart';

class Download {
  Download();

  Download.make(
      this.status, this.url, this.title, this.path, this.progress, this.size, this.length, this.isVideo);

  int? status;

  String? url;
  String? title;
  String? path;
  double? progress;
  double? size;
  double? length = 0;
  int? isVideo;

  Map<String, dynamic> toMap() {
    var map = new Map<String, dynamic>();
    map['status'] = status;
    map['url'] = url;
    map['title'] = title;
    map['path'] = path;
    map['progress'] = progress;
    map['size'] = size;
    map['length'] = length;
    map['isVideo'] = isVideo;
    return map;
  }

  static Download fromMap(Map<String, dynamic> map) {
    Download download = new Download();
    try {
      download.url = map['url'];
      download.status = map['status'];
      download.title = map['title'];
      download.path = map['path'];
      download.progress = map['progress'];
      download.size = map['size'];
      download.length = map['length'];
      download.isVideo = map['isVideo'];
    } catch (e) {
      print(e);
    }
    return download;
  }

  static List<Download> fromMapList(List mapList) {
    List<Download> list = [];
    for (int i = 0; i < mapList.length; i++) {
      list.add(fromMap(mapList[i]));
    }
    return list;
  }

  @override
  String toString() {
    return 'Download{ status: $status, url: $url, title: $title, path: $path, progress: $progress, size: $size}';
  }
}

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper.internal();

  factory DatabaseHelper() => _instance;
  final String tableName = "download";

//  final String columnId = "id";
  final String columnUrl = "url";
  final String columnStatus = "status";
  final String columnTitle = "title";
  final String columnProgress = "progress";
  final String columnSize = "size";
  final String columnPath = "path";
  final String columnLength = "length";
  final String columnIsVideo = "isVideo";
  static Database? _db;

  Future<Database> get db async {
    if (_db != null) {
      return _db!;
    }
    _db = await initDb();
    return _db!;
  }

  DatabaseHelper.internal();

  initDb() async {
    try {
      var databasesPath = await getDatabasesPath();
      String path = join(databasesPath, 'parse.db');
      var ourDb = await openDatabase(path, version: 1, onCreate: _onCreate);
      _onCreate(ourDb, 1);
      return ourDb;
    } catch (e) {
      print(e);
    }
  }

  //创建数据库表
  void _onCreate(Database db, int version) async {
    try {
      String eq =
              "create table $tableName($columnTitle text primary key ,$columnUrl text not null ,$columnStatus integer not null ,$columnProgress DOUBLE not null ,$columnSize DOUBLE not null ,$columnPath text not null ,$columnLength DOUBLE not null ,$columnIsVideo integer not null )";
      await db.execute(eq);
    } catch (e) {
      print(e);
    }
    print("Table is created");
  }

//插入
  Future<int> saveItem(Download download) async {
    var dbClient = await db;
    int res = await dbClient.insert("$tableName", download.toMap());
    print(res.toString());
    return res;
  }

  //查询
  Future<List> getTotalList() async {
    var dbClient = await db;
    var result = await dbClient.rawQuery("SELECT * FROM $tableName ");
    return result.toList();
  }

  //查询
  Future<List> getListWithDowning() async {
    var dbClient = await db;
    var result = await dbClient.rawQuery("SELECT * FROM $tableName WHERE $columnStatus != 1");
    return result.toList();
  }

  //查询
  Future<List> getListWithFinish() async {
    var dbClient = await db;
    var result = await dbClient.rawQuery("SELECT * FROM $tableName WHERE $columnStatus == 1");
    return result.toList();
  }

  //查询总数
  Future<int?> getCount() async {
    var dbClient = await db;
    return Sqflite.firstIntValue(
        await dbClient.rawQuery("SELECT COUNT(*) FROM $tableName"));
  }

//按照title查询
  Future<Download?> getItem(String title) async {
    var dbClient = await db;
//    var result = await dbClient
//        .rawQuery("SELECT * FROM $tableName WHERE $columnUrl = '$url'");
    var result = await dbClient
        .query(tableName,where:"$columnTitle = ?",whereArgs: [title]);
    if (result.length == 0) return null;
    return Download.fromMap(result.first);
  }

  //清空数据
  Future<int> clear() async {
    var dbClient = await db;
    return await dbClient.delete(tableName);
  }

  //根据id删除
  Future<int> deleteItem(String title) async {
    var dbClient = await db;
    return await dbClient
        .delete(tableName, where: "$columnTitle = ?", whereArgs: [title]);
  }

  //修改
  Future<int> updateItem(Download download) async {
    var dbClient = await db;
    return await dbClient.update("$tableName", download.toMap(),
        where: "$columnUrl = ?", whereArgs: [download.url]);
  }

  //修改
  Future<int> updateItemWithMap(Map<String, dynamic> values, String title) async {
    var dbClient = await db;
    return await dbClient.update("$tableName", values,
        where: "$columnTitle = ?", whereArgs: [title]);
  }

  //关闭
  Future close() async {
    var dbClient = await db;
    return dbClient.close();
  }
}
