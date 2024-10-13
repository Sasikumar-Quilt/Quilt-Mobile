import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DataBaseHelper {
  static final _databaseName = "Events.db";
  static final _databaseVersion = 1;

  static final table = 'event_requests';

  static final columnId = '_id';
  static final columnJsonRequest = 'jsonRequest';
  static final moodId = 'moodId';

  // Private constructor for singleton pattern
  DataBaseHelper._privateConstructor();
  static final DataBaseHelper instance = DataBaseHelper._privateConstructor();

  static Database? _database;

  // Singleton access to the database
  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDatabase();
    return _database!;
  }

  // Initialize the database
  _initDatabase() async {
    String path = join(await getDatabasesPath(), _databaseName);
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
    );
  }

  // SQL code to create the table
  Future _onCreate(Database db, int version) async {
    await db.execute('''
  CREATE TABLE $table (
    $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
    $moodId TEXT NOT NULL UNIQUE,
    $columnJsonRequest TEXT NOT NULL
  )
''');
  }

  // Method to store API request
  Future<int> storeApiRequest(String jsonRequest,String mId) async {
    Database db = await instance.database;
    try {
      return await db.insert(
        table,
        {columnJsonRequest: jsonRequest,moodId:mId},
        conflictAlgorithm: ConflictAlgorithm.replace, // Avoid duplicate requests
      );
    } catch (e) {
      print("Request already exists");
      return -1; // Indicate that the request already exists
    }
  }

  // Method to retrieve all stored API requests
  Future<List<ApiRequestModel>> getStoredRequests() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(table);

    // Convert List<Map<String, dynamic>> into List<ApiRequestModel>
    return List.generate(maps.length, (i) {
      return ApiRequestModel(
        id: maps[i][columnId],  moodId: maps[i][moodId],
        jsonRequest: maps[i][columnJsonRequest],
      );
    });
  }
  Future<List<ApiRequestModel>> getStoredRequestsByMoodId(String mId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      table,
      where: '$moodId = ?',  // Filter by moodId
      whereArgs: [mId],         // Use moodId as an argument
    );
    return List.generate(maps.length, (i) {
      return ApiRequestModel(
        id: maps[i][columnId],  moodId: maps[i][moodId],
        jsonRequest: maps[i][columnJsonRequest],
      );
    });
  }
  Future<ApiRequestModel?> getLastStoredRequestByMoodId(String mId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      table,
      where: '$moodId = ?',  // Filter by moodId
      whereArgs: [mId],      // Use moodId as an argument
      orderBy: '$columnId DESC', // Sort by id in descending order to get the latest record
      limit: 1,              // Limit the result to only one record
    );

    if (maps.isNotEmpty) {
      return ApiRequestModel(
        id: maps[0][columnId],
        moodId: maps[0][moodId],
        jsonRequest: maps[0][columnJsonRequest],
      );
    } else {
      return null; // Return null if no record matches
    }
  }
  // Method to delete a request by its ID
  Future<void> deleteApiRequest(String id) async {
    Database db = await instance.database;
    await db.delete(table, where: '$moodId = ?', whereArgs: [id]);
    print("Request with ID $id deleted");
  }

  // Method to delete all requests (optional)
  Future<void> deleteAllRequests() async {
    Database db = await instance.database;
    await db.delete(table);
    print("All requests deleted");
  }
}
class ApiRequestModel {
  int id;
  String jsonRequest;
  String moodId;

  ApiRequestModel({required this.id, required this.jsonRequest,required this.moodId});

  // Convert model to map for database
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      "moodId":moodId,
      'jsonRequest': jsonRequest,
    };
  }
}