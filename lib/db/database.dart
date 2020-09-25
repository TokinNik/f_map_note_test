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

    String path = join(documentsDirectory.path, "marker.db");

    return await openDatabase(path, version: 4, onOpen: (db) {},
        onCreate: (Database db, int version) async {
          await db.execute(
              "CREATE TABLE marker ("
                  "id INTEGER PRIMARY KEY AUTOINCREMENT,"
                  "name TEXT,"
                  "description TEXT,"
                  "has_marker INTEGER,"
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
      'marker',
      marker.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<MarkerData>> getAllMarkers() async {
    final Database db = await database;

    final List<Map<String, dynamic>> maps = await db.query('marker');

    return List.generate(maps.length, (i) {
      return MarkerData(
          id: maps[i]['id'],
          name: maps[i]['name'],
          description: maps[i]['description'],
          hasMarker: maps[i]['has_marker'] == 1,
          target: maps[i]['has_marker'] == 1 ? LatLng(maps[i]['target_lat'], maps[i]['target_lng']) : null,
          time: maps[i]['time']
      );
    });
  }

  Future<void> deleteMarker(int id) async {
    final db = await database;
    await db.delete(
      'marker',
      where: "id = ?",
      whereArgs: [id],
    );
  }

  Future<void> deleteAll() async {
    final db = await database;
    db.rawDelete("Delete from marker");
  }
}

class MarkerData {
  final int id;
  final String name;
  final String description;
  final bool hasMarker;
  final LatLng target;
  final String time;

  MarkerData({this.id, this.name, this.description, this.hasMarker = false, this.target, this.time});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'has_marker': hasMarker ? 1 : 0,
      'target_lat': hasMarker ? target.latitude : 0,
      'target_lng': hasMarker ? target.longitude : 0,
      'time': time,
    };
  }
}