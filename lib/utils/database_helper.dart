import 'dart:io';

import 'package:pad_keeper/models/note_model.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static DatabaseHelper _databaseHelper; //singleton reference
  static Database _database;

  String noteTable = "note_table";
  String colId = "id";
  String colTitle = "title";
  String colDescription = "description";
  String colPriority = "priority";
  String colDate = "date";

  DatabaseHelper._createInstance(); //named constructor to create instance

  factory DatabaseHelper() {
    if (_databaseHelper == null) {
      _databaseHelper = DatabaseHelper._createInstance();
    }
    return _databaseHelper;
  }

  Future<Database> get database async {
    if (_database == null) {
      _database = await initializeDatabase();
    }
    return _database;
  }

  Future<Database> initializeDatabase() async {
    //get directory path for android and ios to store DB
    Directory directory = await getApplicationDocumentsDirectory();
    String path = directory.path + 'note.db';

    //open/create the database and create
    var noteDatabase =
        await openDatabase(path, version: 1, onCreate: _createDb);
    return noteDatabase;
  }

  //create table
  void _createDb(Database db, int newVersion) async {
    await db.execute(
        "CREATE TABLE $noteTable($colId INTEGER PRIMARY KEY AUTOINCREMENT, $colTitle TEXT, "
        "$colDescription TEXT, $colPriority INTEGER, $colDate TEXT)");
  }

  //Fetch data
  Future<List<Map<String, dynamic>>> getNoteMapList() async {
    Database db = await this.database;
    // var result = await db.rawQuery("SELECT * FROM $noteTable order by $colPriority ASC");
    var result = await db.query(noteTable, orderBy: "$colPriority ASC");
    return result;
  }

  //insert data
  Future<int> insertNote(Note note) async {
    print("note called from helper: "+note.noteToMap().toString());
    Database db = await this.database;
    var result = await db.insert(noteTable, note.noteToMap());
    return result;
  }

  //update data
  Future<int> updateNote(Note note) async {
    Database db = await this.database;
    var result = await db.update(noteTable, note.noteToMap(),
        where: '$colId = ?', whereArgs: [note.id]);
    return result;
  }

//delete data
  Future<int> deleteNote(int id) async {
    Database db = await this.database;
    int result =
        await db.rawDelete("DELETE FROM $noteTable WHERE $colId = $id");
    return result;
  }

  //get total count of column object from database
  Future<int> getCount() async {
    Database db = await this.database;
    List<Map<String, dynamic>> x =
        await db.rawQuery("SELECT COUNT (*) FROM $noteTable");
    int result = Sqflite.firstIntValue(x); //get count value from list
    return result;
  }

  Future<List<Note>> getNoteList() async {
    var noteMapList = await getNoteMapList();
    int count = noteMapList.length;
    List<Note> noteList = List<Note>();
    for (int i = 0; i < count; i++) {
      noteList.add(Note.mapToNote(noteMapList[i]));
    }
    return noteList;
  }
}
