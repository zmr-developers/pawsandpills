import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static Database? _db;

  static Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  static Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'pawsandpills.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await _createTables(db);
        await _seedData(db);
      },
    );
  }

  static Future<void> _createTables(Database db) async {
    await db.execute('''
      CREATE TABLE profiles (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        type TEXT NOT NULL,
        subtype TEXT NOT NULL,
        age INTEGER,
        photo_path TEXT,
        vet_contact TEXT,
        notes TEXT,
        created_at TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE medications (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        profile_id INTEGER NOT NULL,
        name TEXT NOT NULL,
        dose TEXT,
        unit TEXT,
        frequency TEXT,
        times TEXT,
        start_date TEXT,
        end_date TEXT,
        stock_count INTEGER DEFAULT 0,
        photo_path TEXT,
        notes TEXT,
        created_at TEXT NOT NULL,
        FOREIGN KEY (profile_id) REFERENCES profiles(id)
      )
    ''');
    await db.execute('''
      CREATE TABLE dose_history (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        medication_id INTEGER NOT NULL,
        profile_id INTEGER NOT NULL,
        scheduled_time TEXT NOT NULL,
        status TEXT NOT NULL,
        taken_at TEXT,
        FOREIGN KEY (medication_id) REFERENCES medications(id)
      )
    ''');
    await db.execute('''
      CREATE TABLE shopping_list (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        medication_name TEXT NOT NULL,
        profile_name TEXT NOT NULL,
        quantity INTEGER DEFAULT 1,
        bought INTEGER DEFAULT 0,
        created_at TEXT NOT NULL
      )
    ''');
  }

  static Future<void> _seedData(Database db) async {
    try {
      final now = DateTime.now().toIso8601String();
      await db.insert('profiles', {'name': 'John (Adult)', 'type': 'human', 'subtype': 'adult', 'age': 35, 'created_at': now});
      await db.insert('profiles', {'name': 'Grandma Rose', 'type': 'human', 'subtype': 'elderly', 'age': 72, 'created_at': now});
      await db.insert('profiles', {'name': 'Buddy (Dog)', 'type': 'pet', 'subtype': 'dog', 'created_at': now});
      await db.insert('medications', {'profile_id': 1, 'name': 'Metformin', 'dose': '500', 'unit': 'mg', 'frequency': 'twice_daily', 'times': '08:00,20:00', 'stock_count': 60, 'created_at': now});
      await db.insert('medications', {'profile_id': 2, 'name': 'Aspirin', 'dose': '81', 'unit': 'mg', 'frequency': 'once_daily', 'times': '09:00', 'stock_count': 30, 'created_at': now});
      await db.insert('medications', {'profile_id': 3, 'name': 'Heartgard', 'dose': '1', 'unit': 'tablet', 'frequency': 'monthly', 'times': '08:00', 'stock_count': 6, 'created_at': now});
    } catch (e) {
      print('Seed error: $e');
    }
  }
}
