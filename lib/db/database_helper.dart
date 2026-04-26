import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static Database? _db;
  static int _interstitialCount = 0;

  static int get interstitialCount => _interstitialCount;
  static void incrementInterstitial() => _interstitialCount++;
  static bool shouldShowInterstitial() => _interstitialCount % 3 == 0;

  static Future<Database> get database async {
    _db ??= await _initDb();
    return _db!;
  }

  static Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'pawsandpills.db');
    return openDatabase(
      path,
      version: 2,
      onCreate: (db, version) async {
        await _createTables(db);
        await _seedData(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        await db.execute('DROP TABLE IF EXISTS profiles');
        await db.execute('DROP TABLE IF EXISTS medications');
        await db.execute('DROP TABLE IF EXISTS dose_history');
        await db.execute('DROP TABLE IF EXISTS shopping_list');
        await db.execute('DROP TABLE IF EXISTS conflicts');
        await db.execute('DROP TABLE IF EXISTS toxic_pets');
        await db.execute('DROP TABLE IF EXISTS species');
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
        age_years INTEGER DEFAULT 0,
        age_months INTEGER DEFAULT 0,
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
        active INTEGER DEFAULT 1,
        created_at TEXT NOT NULL,
        FOREIGN KEY (profile_id) REFERENCES profiles(id) ON DELETE CASCADE
      )
    ''');
    await db.execute('''
      CREATE TABLE dose_history (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        medication_id INTEGER NOT NULL,
        profile_id INTEGER NOT NULL,
        medication_name TEXT NOT NULL,
        profile_name TEXT NOT NULL,
        scheduled_time TEXT NOT NULL,
        status TEXT NOT NULL,
        taken_at TEXT,
        FOREIGN KEY (medication_id) REFERENCES medications(id) ON DELETE CASCADE
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
    await db.execute('''
      CREATE TABLE conflicts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        med1 TEXT NOT NULL,
        med2 TEXT NOT NULL,
        severity TEXT NOT NULL,
        description_en TEXT,
        description_ar TEXT,
        description_fr TEXT,
        description_es TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE toxic_pets (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        medication TEXT NOT NULL,
        toxic_to TEXT NOT NULL,
        severity TEXT NOT NULL,
        description_en TEXT,
        description_ar TEXT,
        description_fr TEXT,
        description_es TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE species (
        id TEXT PRIMARY KEY,
        name_en TEXT NOT NULL,
        name_ar TEXT,
        name_fr TEXT,
        name_es TEXT,
        emoji TEXT,
        type TEXT NOT NULL
      )
    ''');
    // Indexes for performance
    await db.execute('CREATE INDEX idx_medications_profile ON medications(profile_id)');
    await db.execute('CREATE INDEX idx_dose_history_profile ON dose_history(profile_id)');
    await db.execute('CREATE INDEX idx_dose_history_medication ON dose_history(medication_id)');
    await db.execute('CREATE INDEX idx_dose_history_time ON dose_history(scheduled_time)');
  }

  static Future<void> _seedData(Database db) async {
    try {
      final speciesJson = await rootBundle.loadString('assets/species.json');
      final List speciesList = jsonDecode(speciesJson);
      for (final s in speciesList) {
        await db.insert('species', {
          'id': s['id'],
          'name_en': s['name_en'],
          'name_ar': s['name_ar'] ?? '',
          'name_fr': s['name_fr'] ?? '',
          'name_es': s['name_es'] ?? '',
          'emoji': s['emoji'] ?? '',
          'type': s['type'] ?? 'pet',
        }, conflictAlgorithm: ConflictAlgorithm.replace);
      }
      debugPrint('Species seeded: ${speciesList.length}');

      final conflictsJson = await rootBundle.loadString('assets/conflicts.json');
      final List conflictsList = jsonDecode(conflictsJson);
      for (final c in conflictsList) {
        await db.insert('conflicts', {
          'med1': c['med1'],
          'med2': c['med2'],
          'severity': c['severity'],
          'description_en': c['description_en'] ?? '',
          'description_ar': c['description_ar'] ?? '',
          'description_fr': c['description_fr'] ?? '',
          'description_es': c['description_es'] ?? '',
        }, conflictAlgorithm: ConflictAlgorithm.replace);
      }
      debugPrint('Conflicts seeded: ${conflictsList.length}');

      final toxicJson = await rootBundle.loadString('assets/toxic_pets.json');
      final List toxicList = jsonDecode(toxicJson);
      for (final t in toxicList) {
        final toxicTo = t['toxic_to'] is List
            ? (t['toxic_to'] as List).join(',')
            : t['toxic_to'].toString();
        await db.insert('toxic_pets', {
          'medication': t['medication'],
          'toxic_to': toxicTo,
          'severity': t['severity'],
          'description_en': t['description_en'] ?? '',
          'description_ar': t['description_ar'] ?? '',
          'description_fr': t['description_fr'] ?? '',
          'description_es': t['description_es'] ?? '',
        }, conflictAlgorithm: ConflictAlgorithm.replace);
      }
      debugPrint('Toxic pets seeded: ${toxicList.length}');

      final now = DateTime.now().toIso8601String();
      await db.insert('profiles', {'name': 'John', 'type': 'human', 'subtype': 'adult', 'age_years': 35, 'age_months': 0, 'created_at': now});
      await db.insert('profiles', {'name': 'Grandma Rose', 'type': 'human', 'subtype': 'senior', 'age_years': 72, 'age_months': 0, 'created_at': now});
      await db.insert('profiles', {'name': 'Buddy', 'type': 'pet', 'subtype': 'dog', 'age_years': 2, 'age_months': 3, 'created_at': now});

      await db.insert('medications', {'profile_id': 1, 'name': 'Metformin', 'dose': '500', 'unit': 'mg', 'frequency': 'twice_daily', 'times': '08:00,20:00', 'stock_count': 60, 'active': 1, 'created_at': now});
      await db.insert('medications', {'profile_id': 2, 'name': 'Aspirin', 'dose': '81', 'unit': 'mg', 'frequency': 'once_daily', 'times': '09:00', 'stock_count': 30, 'active': 1, 'created_at': now});
      await db.insert('medications', {'profile_id': 3, 'name': 'Heartgard', 'dose': '1', 'unit': 'tablet', 'frequency': 'monthly', 'times': '08:00', 'stock_count': 6, 'active': 1, 'created_at': now});

      debugPrint('Sample data seeded successfully');
    } catch (e, stack) {
      debugPrint('Seed error: $e');
      debugPrint('Stack: $stack');
    }
  }

  // ─── PROFILES ───────────────────────────────────────────────

  static Future<List<Map<String, dynamic>>> getProfiles() async {
    final db = await database;
    return db.query('profiles', orderBy: 'created_at ASC');
  }

  static Future<int> addProfile(Map<String, dynamic> profile) async {
    final db = await database;
    profile['created_at'] = DateTime.now().toIso8601String();
    return db.insert('profiles', profile);
  }

  static Future<void> updateProfile(int id, Map<String, dynamic> data) async {
    final db = await database;
    await db.update('profiles', data, where: 'id = ?', whereArgs: [id]);
  }

  static Future<void> deleteProfile(int id) async {
    final db = await database;
    await db.delete('dose_history', where: 'profile_id = ?', whereArgs: [id]);
    await db.delete('medications', where: 'profile_id = ?', whereArgs: [id]);
    await db.delete('profiles', where: 'id = ?', whereArgs: [id]);
  }

  // ─── MEDICATIONS ────────────────────────────────────────────

  static Future<List<Map<String, dynamic>>> getMedications(int profileId) async {
    final db = await database;
    return db.query('medications', where: 'profile_id = ? AND active = 1', whereArgs: [profileId], orderBy: 'created_at ASC');
  }

  static Future<List<Map<String, dynamic>>> getAllMedications() async {
    final db = await database;
    return db.query('medications', where: 'active = 1', orderBy: 'created_at ASC');
  }

  static Future<int> addMedication(Map<String, dynamic> med) async {
    final db = await database;
    med['created_at'] = DateTime.now().toIso8601String();
    med['active'] = 1;
    return db.insert('medications', med);
  }

  static Future<void> updateMedication(int id, Map<String, dynamic> data) async {
    final db = await database;
    await db.update('medications', data, where: 'id = ?', whereArgs: [id]);
  }

  static Future<void> deleteMedication(int id) async {
    final db = await database;
    await db.update('medications', {'active': 0}, where: 'id = ?', whereArgs: [id]);
  }

  // ─── DOSE HISTORY ───────────────────────────────────────────

  static Future<void> markDose(int medicationId, int profileId,
      String medicationName, String profileName,
      String scheduledTime, String status) async {
    final db = await database;
    final existing = await db.query('dose_history',
        where: 'medication_id = ? AND scheduled_time = ?',
        whereArgs: [medicationId, scheduledTime]);
    if (existing.isNotEmpty) {
      await db.update('dose_history',
          {'status': status, 'taken_at': status == 'taken' ? DateTime.now().toIso8601String() : null},
          where: 'medication_id = ? AND scheduled_time = ?',
          whereArgs: [medicationId, scheduledTime]);
    } else {
      await db.insert('dose_history', {
        'medication_id': medicationId,
        'profile_id': profileId,
        'medication_name': medicationName,
        'profile_name': profileName,
        'scheduled_time': scheduledTime,
        'status': status,
        'taken_at': status == 'taken' ? DateTime.now().toIso8601String() : null,
      });
    }
  }

  static Future<List<Map<String, dynamic>>> getDoseHistory({int? profileId, String? date}) async {
    final db = await database;
    String where = '1=1';
    List<dynamic> whereArgs = [];
    if (profileId != null) {
      where += ' AND profile_id = ?';
      whereArgs.add(profileId);
    }
    if (date != null) {
      where += ' AND DATE(scheduled_time) = ?';
      whereArgs.add(date);
    }
    return db.query('dose_history',
        where: where,
        whereArgs: whereArgs.isEmpty ? null : whereArgs,
        orderBy: 'scheduled_time DESC',
        limit: 200);
  }

  // ─── SHOPPING LIST ──────────────────────────────────────────

  static Future<List<Map<String, dynamic>>> getShoppingList() async {
    final db = await database;
    return db.query('shopping_list', orderBy: 'bought ASC, created_at DESC');
  }

  static Future<void> addToShopping(String medName, String profileName) async {
    final db = await database;
    final existing = await db.query('shopping_list',
        where: 'medication_name = ? AND bought = 0', whereArgs: [medName]);
    if (existing.isEmpty) {
      await db.insert('shopping_list', {
        'medication_name': medName,
        'profile_name': profileName,
        'quantity': 1,
        'bought': 0,
        'created_at': DateTime.now().toIso8601String(),
      });
    }
  }

  static Future<void> toggleShoppingBought(int id, int current) async {
    final db = await database;
    await db.update('shopping_list', {'bought': current == 0 ? 1 : 0},
        where: 'id = ?', whereArgs: [id]);
  }

  static Future<void> deleteShoppingItem(int id) async {
    final db = await database;
    await db.delete('shopping_list', where: 'id = ?', whereArgs: [id]);
  }

  // ─── CONFLICTS ──────────────────────────────────────────────

  static Future<List<Map<String, dynamic>>> checkConflicts(String medName, int profileId) async {
    final db = await database;
    final existing = await getMedications(profileId);
    final existingNames = existing.map((m) => m['name'].toString().toLowerCase()).toList();
    final name = medName.toLowerCase();
    final results = <Map<String, dynamic>>[];
    for (final existingName in existingNames) {
      final conflicts = await db.rawQuery('''
        SELECT * FROM conflicts 
        WHERE (LOWER(med1) LIKE ? AND LOWER(med2) LIKE ?)
           OR (LOWER(med1) LIKE ? AND LOWER(med2) LIKE ?)
      ''', ['%$name%', '%$existingName%', '%$existingName%', '%$name%']);
      results.addAll(conflicts);
    }
    return results;
  }

  // ─── TOXIC CHECK ────────────────────────────────────────────

  static Future<List<Map<String, dynamic>>> checkToxicForPet(String medName, String species) async {
    final db = await database;
    return db.rawQuery('''
      SELECT * FROM toxic_pets 
      WHERE LOWER(medication) LIKE ? AND toxic_to LIKE ?
    ''', ['%${medName.toLowerCase()}%', '%$species%']);
  }

  // ─── SPECIES ────────────────────────────────────────────────

  static Future<List<Map<String, dynamic>>> getSpecies({String? type}) async {
    final db = await database;
    if (type != null) {
      return db.query('species', where: 'type = ?', whereArgs: [type]);
    }
    return db.query('species');
  }

  // ─── TODAY'S DOSES ──────────────────────────────────────────

  static Future<List<Map<String, dynamic>>> getDosesForDate(String date) async {
    final db = await database;
    final profiles = await getProfiles();
    final List<Map<String, dynamic>> result = [];

    for (final profile in profiles) {
      final meds = await getMedications(profile['id'] as int);
      for (final med in meds) {
        final times = (med['times'] as String? ?? '08:00').split(',');
        for (final time in times) {
          final scheduledTime = '$date ${time.trim()}';
          final history = await db.query('dose_history',
              where: 'medication_id = ? AND scheduled_time = ?',
              whereArgs: [med['id'], scheduledTime]);
          final status = history.isEmpty ? 'pending' : history.first['status'] as String;
          result.add({
            ...med,
            'profile_name': profile['name'],
            'profile_subtype': profile['subtype'],
            'scheduled_time': scheduledTime,
            'display_time': time.trim(),
            'dose_status': status,
          });
        }
      }
    }
    result.sort((a, b) => a['display_time'].compareTo(b['display_time']));
    return result;
  }

  // ─── LOW STOCK ──────────────────────────────────────────────

  static Future<List<Map<String, dynamic>>> getLowStockMedications({int threshold = 7}) async {
    final db = await database;
    return db.rawQuery('''
      SELECT m.*, p.name as profile_name
      FROM medications m
      JOIN profiles p ON m.profile_id = p.id
      WHERE m.active = 1 AND m.stock_count <= ?
      ORDER BY m.stock_count ASC
    ''', [threshold]);
  }

  // ─── AGE DISPLAY ────────────────────────────────────────────

  static String formatAge(Map<String, dynamic> profile, String lang) {
    final years = profile['age_years'] as int? ?? 0;
    final months = profile['age_months'] as int? ?? 0;
    final subtype = profile['subtype'] as String? ?? '';
    final showMonths = ['child', 'dog', 'cat', 'rabbit', 'bird', 'hamster', 'fish', 'reptile', 'horse'].contains(subtype);

    final Map<String, Map<String, String>> labels = {
      'years': {'en': 'y', 'ar': 'س', 'fr': 'a', 'es': 'a'},
      'months': {'en': 'm', 'ar': 'ش', 'fr': 'm', 'es': 'm'},
    };

    final y = labels['years']![lang] ?? 'y';
    final m = labels['months']![lang] ?? 'm';

    if (years == 0 && months == 0) return '';
    if (!showMonths) return '$years$y';
    if (years == 0) return '$months$m';
    if (months == 0) return '$years$y';
    return '$years$y $months$m';
  }
}
