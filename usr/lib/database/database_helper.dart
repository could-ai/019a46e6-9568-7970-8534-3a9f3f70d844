import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import '../models/resident.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Future<Database> get database async {
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
    Database db = await database;
    return await db.insert('residentes', resident.toMap());
  }

  Future<List<Resident>> getResidents() async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query('residentes');
    return List.generate(maps.length, (i) => Resident.fromMap(maps[i]));
  }

  Future<int> updateResident(Resident resident) async {
    Database db = await database;
    return await db.update(
      'residentes',
      resident.toMap(),
      where: 'id = ?',
      whereArgs: [resident.id],
    );
  }

  Future<int> deleteResident(int id) async {
    Database db = await database;
    return await db.delete(
      'residentes',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Map<String, dynamic>>> getStatistics() async {
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
