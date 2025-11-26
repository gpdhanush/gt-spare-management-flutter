import '../models/machine.dart';
import '../models/unit.dart';
import '../models/spare.dart';
import 'database_helper.dart';

class DataService {
  static final DataService _instance = DataService._internal();
  factory DataService() => _instance;
  DataService._internal();

  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  // Initialize database - check if data exists, if not create and seed
  Future<void> initialize() async {
    final hasData = await _dbHelper.hasData();
    if (!hasData) {
      // Database will be created and seeded on first access
      await _dbHelper.database;
    }
  }

  // Machine methods
  Future<List<Machine>> getMachines() async {
    return await _dbHelper.getMachines();
  }

  Future<String> addMachine(Machine machine) async {
    return await _dbHelper.insertMachine(machine);
  }

  Future<int> updateMachine(Machine machine) async {
    return await _dbHelper.updateMachine(machine);
  }

  Future<int> deleteMachine(String id) async {
    return await _dbHelper.deleteMachine(id);
  }

  // Unit methods
  Future<List<Unit>> getUnitsByMachine(String machineId) async {
    return await _dbHelper.getUnitsByMachine(machineId);
  }

  Future<String> addUnit(Unit unit) async {
    return await _dbHelper.insertUnit(unit);
  }

  Future<int> updateUnit(Unit unit) async {
    return await _dbHelper.updateUnit(unit);
  }

  Future<int> deleteUnit(String id) async {
    return await _dbHelper.deleteUnit(id);
  }

  // Spare methods
  Future<List<Spare>> getSparesByUnit(String unitId) async {
    return await _dbHelper.getSparesByUnit(unitId);
  }

  Future<String> addSpare(Spare spare) async {
    return await _dbHelper.insertSpare(spare);
  }

  Future<int> updateSpare(Spare spare) async {
    return await _dbHelper.updateSpare(spare);
  }

  Future<int> deleteSpare(String id) async {
    return await _dbHelper.deleteSpare(id);
  }

  // Helper methods
  Future<Machine?> getMachineById(String id) async {
    return await _dbHelper.getMachineById(id);
  }

  Future<Unit?> getUnitById(String id) async {
    return await _dbHelper.getUnitById(id);
  }
}
