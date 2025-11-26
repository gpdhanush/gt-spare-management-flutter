import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/machine.dart';
import '../models/unit.dart';
import '../models/spare.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('spare_management.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future<void> _createDB(Database db, int version) async {
    // Create machines table
    await db.execute('''
      CREATE TABLE machines (
        id TEXT PRIMARY KEY,
        name TEXT UNIQUE NOT NULL,
        description TEXT,
        created_at TEXT DEFAULT (datetime('now')),
        updated_at TEXT DEFAULT (datetime('now'))
      )
    ''');

    // Create subunits table
    await db.execute('''
      CREATE TABLE subunits (
        id TEXT PRIMARY KEY,
        machine_id TEXT NOT NULL,
        name TEXT NOT NULL,
        description TEXT,
        created_at TEXT DEFAULT (datetime('now')),
        updated_at TEXT DEFAULT (datetime('now')),
        FOREIGN KEY (machine_id) REFERENCES machines(id) ON DELETE CASCADE
      )
    ''');

    // Create spare_parts table
    await db.execute('''
      CREATE TABLE spare_parts (
        id TEXT PRIMARY KEY,
        subunit_id TEXT NOT NULL,
        serial_no TEXT NOT NULL,
        material_code TEXT NOT NULL,
        material_name TEXT NOT NULL,
        part_no TEXT NOT NULL,
        description TEXT DEFAULT '',
        created_at TEXT DEFAULT (datetime('now')),
        updated_at TEXT DEFAULT (datetime('now')),
        FOREIGN KEY (subunit_id) REFERENCES subunits(id) ON DELETE CASCADE
      )
    ''');

    // Create indexes
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_subunits_machine_id ON subunits(machine_id)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_spare_parts_subunit_id ON spare_parts(subunit_id)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_spare_parts_material_code ON spare_parts(material_code)',
    );

    // Insert seed data
    await _insertSeedData(db);
  }

  Future<void> _insertSeedData(Database db) async {
    // Insert machines
    final machines = [
      {
        'id': _generateId(),
        'name': 'Bosch',
        'description': 'Bosch machine system',
      },
      {
        'id': _generateId(),
        'name': 'Khosla',
        'description': 'Khosla machine system',
      },
      {
        'id': _generateId(),
        'name': 'Omorl',
        'description': 'Omorl machine system',
      },
      {
        'id': _generateId(),
        'name': 'Bundle',
        'description': 'Bundle machine system',
      },
      {
        'id': _generateId(),
        'name': 'Stamper',
        'description': 'Stamper machine system',
      },
      {
        'id': _generateId(),
        'name': 'Tapping Machine',
        'description': 'Tapping machine system',
      },
    ];

    for (var machine in machines) {
      await db.insert(
        'machines',
        machine,
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    }

    // Get machine IDs
    final machineRows = await db.query('machines');
    final machineMap = <String, String>{};
    for (var row in machineRows) {
      machineMap[row['name'] as String] = row['id'] as String;
    }

    // Standard subunits for each machine
    final subunits = [
      {'name': 'Jaw Unit', 'description': 'Jaw assembly and components'},
      {'name': 'Roller Unit', 'description': 'Roller mechanism and parts'},
      {'name': 'Infeed Unit', 'description': 'Material infeed system'},
      {'name': 'Belt', 'description': 'Belt drive components'},
      {'name': 'Bearing', 'description': 'Bearing assemblies'},
      {'name': 'Others', 'description': 'Miscellaneous parts'},
    ];

    // Insert subunits for each machine
    for (var machineName in machineMap.keys) {
      final machineId = machineMap[machineName]!;
      for (var subunit in subunits) {
        await db.insert('subunits', {
          'id': _generateId(),
          'machine_id': machineId,
          'name': subunit['name'],
          'description': subunit['description'],
        }, conflictAlgorithm: ConflictAlgorithm.ignore);
      }
    }

    // Insert sample spare parts for Bosch - Jaw Unit
    final boschJawUnitRows = await db.query(
      'subunits',
      where: 'machine_id = ? AND name = ?',
      whereArgs: [machineMap['Bosch'], 'Jaw Unit'],
    );

    if (boschJawUnitRows.isNotEmpty) {
      final jawUnitId = boschJawUnitRows.first['id'] as String;
      await db.insert('spare_parts', {
        'id': _generateId(),
        'subunit_id': jawUnitId,
        'serial_no': 'SN-001',
        'material_code': 'MC-JU-001',
        'material_name': 'Jaw Assembly Main',
        'part_no': 'PN-JU-001',
        'description': 'Main jaw assembly component with mounting hardware',
      }, conflictAlgorithm: ConflictAlgorithm.ignore);

      await db.insert('spare_parts', {
        'id': _generateId(),
        'subunit_id': jawUnitId,
        'serial_no': 'SN-002',
        'material_code': 'MC-JU-002',
        'material_name': 'Jaw Spring',
        'part_no': 'PN-JU-002',
        'description': 'High tension spring for jaw mechanism',
      }, conflictAlgorithm: ConflictAlgorithm.ignore);
    }

    // Insert sample spare parts for Bosch - Bearing
    final boschBearingRows = await db.query(
      'subunits',
      where: 'machine_id = ? AND name = ?',
      whereArgs: [machineMap['Bosch'], 'Bearing'],
    );

    if (boschBearingRows.isNotEmpty) {
      final bearingId = boschBearingRows.first['id'] as String;
      await db.insert('spare_parts', {
        'id': _generateId(),
        'subunit_id': bearingId,
        'serial_no': 'SN-003',
        'material_code': 'MC-BR-001',
        'material_name': 'Ball Bearing 6205',
        'part_no': 'PN-BR-001',
        'description': 'Deep groove ball bearing 6205 series',
      }, conflictAlgorithm: ConflictAlgorithm.ignore);
    }
  }

  String _generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString() +
        DateTime.now().microsecondsSinceEpoch.toString();
  }

  // Check if database exists and has data
  Future<bool> hasData() async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM machines');
    final count = Sqflite.firstIntValue(result) ?? 0;
    return count > 0;
  }

  // Machine CRUD operations
  Future<List<Machine>> getMachines() async {
    final db = await database;
    final maps = await db.query('machines', orderBy: 'name');
    return maps.map((map) => Machine.fromMap(map)).toList();
  }

  Future<String> insertMachine(Machine machine) async {
    final db = await database;
    final id = machine.id.isEmpty ? _generateId() : machine.id;
    await db.insert(
      'machines',
      machine.copyWith(id: id).toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return id;
  }

  Future<int> updateMachine(Machine machine) async {
    final db = await database;
    return await db.update(
      'machines',
      machine.copyWith(updatedAt: DateTime.now().toIso8601String()).toMap(),
      where: 'id = ?',
      whereArgs: [machine.id],
    );
  }

  Future<int> deleteMachine(String id) async {
    final db = await database;
    return await db.delete('machines', where: 'id = ?', whereArgs: [id]);
  }

  // Unit CRUD operations
  Future<List<Unit>> getUnitsByMachine(String machineId) async {
    final db = await database;
    final maps = await db.query(
      'subunits',
      where: 'machine_id = ?',
      whereArgs: [machineId],
      orderBy: 'name',
    );
    return maps.map((map) => Unit.fromMap(map)).toList();
  }

  Future<String> insertUnit(Unit unit) async {
    final db = await database;
    final id = unit.id.isEmpty ? _generateId() : unit.id;
    await db.insert(
      'subunits',
      unit.copyWith(id: id).toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return id;
  }

  Future<int> updateUnit(Unit unit) async {
    final db = await database;
    return await db.update(
      'subunits',
      unit.copyWith(updatedAt: DateTime.now().toIso8601String()).toMap(),
      where: 'id = ?',
      whereArgs: [unit.id],
    );
  }

  Future<int> deleteUnit(String id) async {
    final db = await database;
    return await db.delete('subunits', where: 'id = ?', whereArgs: [id]);
  }

  // Spare CRUD operations
  Future<List<Spare>> getSparesByUnit(String unitId) async {
    final db = await database;
    final maps = await db.query(
      'spare_parts',
      where: 'subunit_id = ?',
      whereArgs: [unitId],
      orderBy: 'material_name',
    );
    return maps.map((map) => Spare.fromMap(map)).toList();
  }

  Future<String> insertSpare(Spare spare) async {
    final db = await database;
    final id = spare.id.isEmpty ? _generateId() : spare.id;
    await db.insert(
      'spare_parts',
      spare.copyWith(id: id).toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return id;
  }

  Future<int> updateSpare(Spare spare) async {
    final db = await database;
    return await db.update(
      'spare_parts',
      spare.copyWith(updatedAt: DateTime.now().toIso8601String()).toMap(),
      where: 'id = ?',
      whereArgs: [spare.id],
    );
  }

  Future<int> deleteSpare(String id) async {
    final db = await database;
    return await db.delete('spare_parts', where: 'id = ?', whereArgs: [id]);
  }

  // Helper methods
  Future<Machine?> getMachineById(String id) async {
    final db = await database;
    final maps = await db.query('machines', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;
    return Machine.fromMap(maps.first);
  }

  Future<Unit?> getUnitById(String id) async {
    final db = await database;
    final maps = await db.query('subunits', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;
    return Unit.fromMap(maps.first);
  }

  Future<void> closeDatabase() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }

  Future<String> getDatabasePath() async {
    final dbPath = await getDatabasesPath();
    return join(dbPath, 'spare_management.db');
  }
}
