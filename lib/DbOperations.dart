
import 'dart:async';

import 'package:demo_flutter_app/Note.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

class DbOperations{

  static final _databaseName = "DemoFlutter.db";
  static final _databaseVersion = 1;

  static final table = 'note_table';

  static final String columnTitle = 'title';
  static final String columnId = 'id';
  static final String columnDescription = 'description';
  static final String columnTimestamp = 'timestamp';

  static Database _database;

  static final DbOperations _dbOperations = DbOperations._init();
  DbOperations._init(){
    print("_init...DbOperations._init() called");
    _initDb();
  }

  factory DbOperations(){
    print("DbOperations...factory called");
    return _dbOperations;
  }

  Future<Database> _initDb() async{
    if(_database != null){
      print("_initDb...db is not null");
      return _database;
    }
    print("_initDb...db is null");
    String databasesPath = await getDatabasesPath();
    String path = join(databasesPath, _databaseName);
    _database = await openDatabase(path, version: _databaseVersion, onCreate: _onCreate);
    return _database;
  }

  void _onCreate(Database db, int version) async{
    print("_onCreate...db created");
    await db.execute('CREATE TABLE $table($columnId INTEGER PRIMARY KEY, $columnTitle TEXT, $columnDescription TEXT, $columnTimestamp TEXT)');
  }

  Future<int> saveNote(Note note) async {
    var result = await _database.insert(table, note.toMap());
    return result;
  }

  Future<int> updateNote(Note note, String id) async {
    var result = await _database.update(table, note.toMap(), where: "id = ?", whereArgs: [id]);
    return result;
  }

  Future<int> deleteNote(String id) async {
    var result = await _database.delete(table, where: "id = ?", whereArgs: [id]);
    return result;
  }

  Future<int> queryRowCount() async {
    return Sqflite.firstIntValue(await _database.rawQuery('SELECT COUNT(*) FROM $table'));
  }

  Future<List<Map<String, dynamic>>> getAllRows() async{
    return await _database.query(table);
  }

  void closeDb() {
    _database.close();
  }

}