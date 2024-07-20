import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:gatherly/models/database_service/database_service.dart';
import 'package:gatherly/models/database_service/stalldetails_constants/stall_details_constant.dart';
import 'package:gatherly/models/model_serialize/stall_details.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

// ignore: depend_on_referenced_packages
import 'package:path/path.dart' as path;

class SqfliteRepositor {
  late DatabaseConnection _databaseConnection;
  static Database? _database;
  SqfliteRepositor() {
    _databaseConnection = DatabaseConnection();
  }
  Future<Database?> get database async {
    if (_database != null) {
      return _database;
    } else {
      _database = await _databaseConnection.setDatabase();
      return _database;
    }
  }

  // Insert data
  Future<int> insertData(String table, Map<String, Object?> data,
      {bool isInitLoad = false}) async {
    Database? connection = await database;
    String combinedPath = '';
    if (isInitLoad) {
      List<String> assestPaths = data['mediaUrls'].toString().split(',');
      for (String assestPath in assestPaths) {
        String base64Code = await assetImageToBase64(assestPath);
        Uint8List imageBytes = base64Decode(base64Code);
        Directory directory = await getApplicationDocumentsDirectory();
        File file = File(path.join(
            directory.path,
            path.basename(
                '${(data['title'] as String)} ${assestPaths.indexOf(assestPath)}')));
        if (!assestPaths.contains(file.path)) {
          final result = file.writeAsBytes(imageBytes);

          file.path;
          if (assestPaths.indexOf(assestPath) == 0) {
            combinedPath += file.path;
          } else {
            combinedPath += ',${file.path}';
          }
        }
      }
    }
    Map<String, dynamic> modifiedData = {
      'title': data['title'],
      'description': data['description'],
      'startDate': data['startDate'],
      'endDate': data['endDate'],
      'mediaUrls': combinedPath, // Replace with your actual combined URLs
    };
    List<Map<String, Object?>> queryResult = await connection!
        .query(table, where: 'title=?', whereArgs: [modifiedData['title']]);
    if (queryResult.isEmpty) {
      return await connection.insert(table, modifiedData);
    }
    List<String> updateUrls = (modifiedData['mediaUrls'] as String).split(',');
    List<String> alreadyExistMediaUrls =
        (queryResult[0]['mediaUrls'] as String).split(',');
    String updatedCombinedString = queryResult[0]['mediaUrls'] as String;
    for (String url in updateUrls) {
      if (!alreadyExistMediaUrls.contains(url)) {
        if (alreadyExistMediaUrls.isEmpty) {
          updatedCombinedString = modifiedData['mediaUrls'];
        } else {
          updatedCombinedString += ',$url';
        }
      }
    }
    Map<String, dynamic> modifiedDataToUpdate = {
      'title': data['title'],
      'description': data['description'],
      'startDate': data['startDate'],
      'endDate': data['endDate'],
      'mediaUrls':
          updatedCombinedString, // Replace with your actual combined URLs
    };
    return await updatdata(table, modifiedDataToUpdate);
  }

  //Read Data
  Future<List<Map<String, Object?>>> readData(String table) async {
    Database? connection = await database;
    List<Map<String, Object?>> readAllDataResult =
        await connection!.query(table);
    List<Map<String, Object?>> jsonData = [];
    for (var element in readAllDataResult) {
      List<String> newvalue = element['mediaUrls'].toString().split(',');
      Map<String, dynamic> modifiedData = {
        'title': element['title'],
        'description': element['description'],
        'startDate': element['startDate'],
        'endDate': element['endDate'],
        'mediaUrls': newvalue, // Replace with your actual combined URLs
      };
      jsonData.add(modifiedData);
    }
    return jsonData;
  }

  // ReadData by id
  Future<List<Map<String, Object?>>> readDataById(
      String table, String title) async {
    Database? connection = await database;
    List<Map<String, Object?>> readDataByIdResult =
        await connection!.query(table, where: 'title=?', whereArgs: [title]);
    List<Map<String, Object?>> jsonData = [];
    for (var element in readDataByIdResult) {
      List<String> newvalue = element['mediaUrls'].toString().split(',');
      Map<String, dynamic> modifiedData = {
        'title': element['title'],
        'description': element['description'],
        'startDate': element['startDate'],
        'endDate': element['endDate'],
        'mediaUrls': newvalue, // Replace with your actual combined URLs
      };
      jsonData.add(modifiedData);
    }
    return jsonData;
  }

  //Update data by id
  Future<int> updatdata(table, data) async {
    Database? connection = await database;
    return await connection!
        .update(table, data, where: 'title=?', whereArgs: [data['title']]);
  }
  //Delete user

  Future<int> deleteUser(table, userId) async {
    Database? connection = await database;
    return await connection!.rawDelete('delete from $table where id=$userId');
  }

  Future<void> initLoadDatabase() async {
    for (Map<String, dynamic> stall in stallDetailsConstant) {
      await insertData(
        'stalls',
        stall,
        isInitLoad: true,
      );
    }
  }

  Future<String> assetImageToBase64(String assetPath) async {
    final ByteData byteData = await rootBundle.load(assetPath);
    final List<int> imageBytes = byteData.buffer.asUint8List();
    return base64Encode(imageBytes);
  }

  Future<String> imageToBase64(File imageFile) async {
    List<int> imageBytes = await imageFile.readAsBytes();
    return base64Encode(imageBytes);
  }

  Future<int> updateUploadedFile(
      table, StallDetails data, String filePath) async {
    Database? connection = await database;
    List<Map<String, Object?>> readDataByTitleResult = await connection!
        .query(table, where: 'title=?', whereArgs: [data.title]);
    String combinedMediaUrls = '';

    if ((readDataByTitleResult[0]['mediaUrls'] as String).isEmpty) {
      combinedMediaUrls = filePath;
    } else {
      String alreadyExistingMediaUrls =
          readDataByTitleResult[0]['mediaUrls'] as String;
      combinedMediaUrls = '$alreadyExistingMediaUrls,$filePath';
    }
    List<Map<String, Object?>> jsonData = [];
    for (var element in readDataByTitleResult) {
      Map<String, dynamic> modifiedData = {
        'title': element['title'],
        'description': element['description'],
        'startDate': element['startDate'],
        'endDate': element['endDate'],
        'mediaUrls':
            combinedMediaUrls, // Replace with your actual combined URLs
      };
      jsonData.add(modifiedData);
    }
    return await connection
        .update(table, jsonData[0], where: 'title=?', whereArgs: [data.title]);
  }
}
