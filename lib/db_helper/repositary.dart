import 'package:flutter/cupertino.dart';
import 'package:sqflite/sqflite.dart';
import 'package:thegallery/db_helper/database_connection.dart';

class Repository {
  late DatabaseConnection _databaseConnection;
  Repository() {
    _databaseConnection = DatabaseConnection();
  }
  static Database? _database;
  Future<Database?> get database async {
    if (_database != null) {
      return _database;
    } else {
      _database = await _databaseConnection.setDatabase();
      return _database;
    }
  }

  /// insert user
  insertData(table, data) async {
    var connection = await database;
    return await connection?.insert(table, data);
  }

  ///read all record
  readData(table) async {
    var connection = await database;
    return await connection?.query("$table", orderBy: "date");
  }

  /// read a single record by id
  readDataById(table, itemId) async {
    var connection = await database;
    return await connection?.query(table, where: 'id=?', whereArgs: [itemId]);
  }

  /// upDate user
  updateData(table, data) async {
    var connection = await database;
    return await connection
        ?.update(table, data, where: 'id=?', whereArgs: [data['id']]);
  }

  /// Delete user
  deleteDataById(table, itemId) async {
    var connection = await database;
    return await connection?.rawDelete('delete from $table where id=$itemId');
  }
}
