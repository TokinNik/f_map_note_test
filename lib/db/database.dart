import 'dart:io';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class MarkersDB {
  MarkersDB._();

  static final MarkersDB db = MarkersDB._();

  static Database _database;

  Future<Database> get database async {
    if (_database != null)
      return _database;

    // if _database is null we instantiate it
    _database = await initDB();
    return _database;
  }

  initDB() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();

    String path = join(documentsDirectory.path, "markers.db");

    return await openDatabase(path, version: 2, onOpen: (db) {},
        onCreate: (Database db, int version) async {
          await db.execute(
              "CREATE TABLE markers ("
                  "id TEXT PRIMARY KEY,"
                  "name TEXT,"
                  "description TEXT,"
                  "target_lat REAL,"
                  "target_lng REAL,"
                  "time TEXT"
                  ")"
          );
        }
    );
  }

  Future<MarkerData> insertMarker(MarkerData marker) async {
    final Database db = await database;

    await db.insert(
      'markers',
      marker.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<MarkerData>> getAllMarkers() async {
    final Database db = await database;

    final List<Map<String, dynamic>> maps = await db.query('markers');

    return List.generate(maps.length, (i) {
      return MarkerData(
          id: maps[i]['id'],
          name: maps[i]['name'],
          description: maps[i]['description'],
          target: LatLng(maps[i]['target_lat'], maps[i]['target_lng']),
          time: maps[i]['time']
      );
    });
  }

  Future<void> deleteMarker(String id) async {
    final db = await database;
    await db.delete(
      'markers',
      where: "id = ?",
      whereArgs: [id],
    );
  }

  Future<void> deleteAll() async {
    final db = await database;
    db.rawDelete("Delete from markers");
  }
}

class MarkerData {
  final String id;
  final String name;
  final String description;
  final LatLng target;
  final String time;

  MarkerData({this.id, this.name, this.description, this.target, this.time});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'target_lat': target.latitude,
      'target_lng': target.longitude,
      'time': time,
    };
  }
}