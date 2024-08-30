/*
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static DatabaseHelper? _databaseHelper;
  static Database? _database;

  String stepCountTable = 'step_count';
  String colId = 'id';
  String colCount = 'count';
  String colDate = 'date';

  DatabaseHelper._createInstance();

  factory DatabaseHelper() {
    if (_databaseHelper == null) {
      _databaseHelper = DatabaseHelper._createInstance();
    }
    return _databaseHelper!;
  }

  Future<Database> get database async {
    if (_database == null) {
      _database = await initializeDatabase();
    }
    return _database!;
  }

  Future<Database> initializeDatabase() async {
    String path = join(await getDatabasesPath(), 'step_count.db');
    var stepCountDatabase =
    await openDatabase(path, version: 1, onCreate: _createDb);
    return stepCountDatabase;
  }

  void _createDb(Database db, int newVersion) async {
    await db.execute(
        'CREATE TABLE $stepCountTable($colId INTEGER PRIMARY KEY AUTOINCREMENT, $colCount INTEGER, $colDate TEXT)');
  }

  Future<int> insertStepCount(StepCounts stepCount) async {
    Database db = await this.database;
    var result = await db.insert(stepCountTable, stepCount.toMap());
    return result;
  }
  Future<List<StepCounts>> getStepCountByDate(String date) async {
    Database db = await this.database;
    List<Map<String, dynamic>> result = await db.query(
      stepCountTable,
      where: '$colDate = ?',
      whereArgs: [date],
      orderBy: '$colDate DESC',
    );

    List<StepCounts> stepCountList = [];
    if(result.length>0) {
      stepCountList.add(StepCounts.fromMapObject(result[0]));
    }
    return stepCountList;
  }

  Future<List<Map<String, dynamic>>> getStepCountMapList() async {
    Database db = await this.database;
    var result = await db.query(stepCountTable, orderBy: '$colDate DESC');
    return result;
  }

  Future<List<StepCounts>> getStepCountList() async {
    var stepCountMapList = await getStepCountMapList();
    List<StepCounts> stepCountList = [];
    for (int i = 0; i < stepCountMapList.length; i++) {
      stepCountList.add(StepCounts.fromMapObject(stepCountMapList[i]));
    }
    return stepCountList;
  }

  Future<int> updateStepCount(StepCounts stepCount) async {
    var db = await this.database;
    var result = await db.update(stepCountTable, stepCount.toMap(),
        where: '$colId = ?', whereArgs: [stepCount.id]);
    return result;
  }

  Future<int> deleteStepCount(int id) async {
    var db = await this.database;
    int result =
    await db.rawDelete('DELETE FROM $stepCountTable WHERE $colId = $id');
    return result;
  }

  Future<int> getCount() async {
    Database db = await this.database;
    List<Map<String, dynamic>> x =
    await db.rawQuery('SELECT COUNT (*) from $stepCountTable');
    int? result = Sqflite.firstIntValue(x);
    return result!;
  }
}
class StepCounts {
  int id;
  int count;
  String date;

  StepCounts({required this.id, required this.count, required this.date});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'count': count,
      'date': date,
    };
  }

  StepCounts.fromMapObject(Map<String, dynamic> map) :
        id = map['id'],
        count = map['count'],
        date = map['date'];
}
*/
