import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import 'package:flutter/foundation.dart' show kIsWeb;
import '../models/resident.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  // Almacenamiento en memoria para Web (ya que SQLite no funciona en el navegador)
  final List<Resident> _webResidents = [];
  int _webIdCounter = 1;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (kIsWeb) {
      throw UnsupportedError('SQLite no está soportado en web. Se usa el almacenamiento en memoria.');
    }
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    String path = p.join(dbPath, 'residentes.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE residentes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        calle TEXT NOT NULL,
        nombres TEXT NOT NULL,
        apellidos TEXT NOT NULL,
        fechaNacimiento TEXT NOT NULL,
        cedula TEXT NOT NULL,
        edad INTEGER,
        telefono TEXT,
        direccion TEXT,
        vota INTEGER DEFAULT 0,
        centroVotacion TEXT,
        alimentacion INTEGER DEFAULT 0,
        pension INTEGER DEFAULT 0,
        maternidad INTEGER DEFAULT 0,
        escolaridad INTEGER DEFAULT 0,
        bnt INTEGER DEFAULT 0,
        hogaresPatria INTEGER DEFAULT 0
      )
    ''');
  }

  Future<int> insertResident(Resident resident) async {
    if (kIsWeb) {
      resident.id = _webIdCounter++;
      _webResidents.add(resident);
      return resident.id!;
    }
    Database db = await database;
    return await db.insert('residentes', resident.toMap());
  }

  Future<List<Resident>> getResidents() async {
    if (kIsWeb) {
      return List.from(_webResidents);
    }
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query('residentes');
    return List.generate(maps.length, (i) => Resident.fromMap(maps[i]));
  }

  Future<int> updateResident(Resident resident) async {
    if (kIsWeb) {
      int index = _webResidents.indexWhere((r) => r.id == resident.id);
      if (index != -1) {
        _webResidents[index] = resident;
        return 1;
      }
      return 0;
    }
    Database db = await database;
    return await db.update(
      'residentes',
      resident.toMap(),
      where: 'id = ?',
      whereArgs: [resident.id],
    );
  }

  Future<int> deleteResident(int id) async {
    if (kIsWeb) {
      _webResidents.removeWhere((r) => r.id == id);
      return 1;
    }
    Database db = await database;
    return await db.delete(
      'residentes',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Map<String, dynamic>>> getStatistics() async {
    if (kIsWeb) {
      // Agregación manual para Web
      Map<String, int> counts = {};
      
      for (var r in _webResidents) {
        int edad = r.edad ?? r.calcularEdad();
        String key = '$edad|${r.calle}';
        counts[key] = (counts[key] ?? 0) + 1;
      }

      List<Map<String, dynamic>> result = [];
      for (var key in counts.keys) {
        var parts = key.split('|');
        int edad = int.parse(parts[0]);
        String calle = parts[1];
        result.add({
          'edad': edad,
          'calle': calle,
          'count': counts[key],
        });
      }
      
      // Ordenar por edad ascendente
      result.sort((a, b) => (a['edad'] as int).compareTo(b['edad'] as int));
      return result;
    }

    Database db = await database;
    return await db.rawQuery('''
      SELECT
        edad,
        calle,
        COUNT(*) as count
      FROM residentes
      GROUP BY edad, calle
      ORDER BY edad ASC
    ''');
  }
}
