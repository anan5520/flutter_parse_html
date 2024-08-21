import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite/sqlite_api.dart';

class History {
  History();

  History.make(
      this.type, this.originUrl, this.title, this.videoUrl, this.progress, this.imageUrl, this.length, this.number);

  int? type;

  String? originUrl;
  String? title;
  String? videoUrl;
  String? imageUrl;
  String? number;
  double? progress;
  double? length = 0;

  Map<String, dynamic> toMap() {
    var map = new Map<String, dynamic>();
    map['type'] = type;
    map['originUrl'] = originUrl;
    map['title'] = title;
    map['videoUrl'] = videoUrl;
    map['progress'] = progress;
    map['length'] = length;
    map['number'] = number;
    map['imageUrl'] = imageUrl;
    return map;
  }

  static History fromMap(Map<String, dynamic> map) {
    History download = new History();
    try {
      download.originUrl = map['originUrl'];
      download.type = map['type'];
      download.title = map['title'];
      download.videoUrl = map['videoUrl'];
      download.progress = map['progress'];
      download.imageUrl = map['imageUrl'];
      download.number = map['number'];
      download.length = map['length'];
    } catch (e) {
      print(e);
    }
    return download;
  }

  static List<History> fromMapList(List mapList) {
    List<History> list = [];
    for (int i = 0; i < mapList.length; i++) {
      list.add(fromMap(mapList[i]));
    }
    return list;
  }


  @override
  String toString() {
    return 'Download{ status: $type, url: $originUrl, title: $title, path: $videoUrl, progress: $progress, size: $number}';
  }
}

class HistoryDatabaseHelper {
  static final HistoryDatabaseHelper _instance = HistoryDatabaseHelper.internal();

  factory HistoryDatabaseHelper() => _instance;
  final String tableName = "history";

//  final String columnId = "id";
  static final String columnOriginUrl = "originUrl";
  static final String columnType = "type";
  static final String columnTitle = "title";
  static final String columnProgress = "progress";
  static final String columnVideoUrl = "videoUrl";
  static final String columnNumber = "number";
  static final String columnLength = "length";
  static final String columnIsImageUrl = "imageUrl";
  static Database? _db;

  Future<Database> get db async {
    if (_db != null) {
      return _db!;
    }
    _db = await initDb();
    return _db!;
  }

  HistoryDatabaseHelper.internal();

  initDb() async {
    var databasesPath = await getDatabasesPath();
    String path = join(databasesPath, 'parse.db');
    var ourDb = await openDatabase(path, version: 2, onCreate: _onCreate);
    return ourDb;
  }

  //创建数据库表
  void _onCreate(Database db, int version) async {
    String eq =
        "create table $tableName($columnTitle text primary key ,$columnOriginUrl text not null ,$columnType integer not null ,$columnProgress DOUBLE not null ,$columnVideoUrl DOUBLE not null ,$columnNumber text not null ,$columnLength DOUBLE not null ,$columnIsImageUrl integer not null )";
    await db.execute(eq);
    print("Table is created");
  }

//插入
  Future<int> saveItem(History download) async {
    var dbClient = await db;
    int res = await dbClient.insert("$tableName", download.toMap());
    print(res.toString());
    return res;
  }

  //查询
  Future<List> getTotalList() async {
    var dbClient = await db;
    try {
      var result = await dbClient.rawQuery("SELECT * FROM $tableName ");
      return result.toList();
    } catch (e) {
      print(e);
    }
    return [];
  }

  //查询总数
  Future<int?> getCount() async {
    var dbClient = await db;
    return Sqflite.firstIntValue(
        await dbClient.rawQuery("SELECT COUNT(*) FROM $tableName"));
  }

//按照title查询
  Future<History?> getItem(String title) async {
    var dbClient = await db;
//    var result = await dbClient
//        .rawQuery("SELECT * FROM $tableName WHERE $columnUrl = '$url'");
    var result = await dbClient
        .query(tableName,where:"$columnTitle = ?",whereArgs: [title]);
    if (result.length == 0) return null;
    return History.fromMap(result.first);
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
  Future<int> updateItem(History download) async {
    var dbClient = await db;
    return await dbClient.update("$tableName", download.toMap(),
        where: "$columnOriginUrl = ?", whereArgs: [download.originUrl]);
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
