import 'package:path/path.dart';
import 'dart:io';

import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseConnection {
  Future<Database> setDatabase() async {
    Directory directory = await getApplicationDocumentsDirectory();
    String path = join(directory.path, 'gatherly');
    Database database =
        await openDatabase(path, version: 1, onCreate: _createDatabase);
    return database;
  }

  Future<void> _createDatabase(Database database, int version) async {
    String sql =
        'CREATE TABLE stalls(id TEXT PRIMARY KEY, title TEXT, description TEXT,startDate TEXT, endDate TEXT, mediaUrls TEXT)';
    await database.execute(sql);
  }
}
