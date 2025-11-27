import 'package:flutter/material.dart';
import 'package:spare_management/app_configs/app_routes.dart';
import 'package:spare_management/app_themes/app_colors.dart';
import 'package:spare_management/app_themes/custom_theme.dart';
import 'package:spare_management/app_utils/app_bar_widget.dart';
import 'package:spare_management/app_utils/global_list_tile.dart';
import 'package:spare_management/models/machine.dart';
import 'package:spare_management/models/unit.dart';
import 'package:spare_management/models/spare.dart';
import 'package:spare_management/services/database_helper.dart';
import 'package:spare_management/services/data_service.dart';

class GlobalSearchPage extends StatefulWidget {
  const GlobalSearchPage({super.key});

  @override
  State<GlobalSearchPage> createState() => _GlobalSearchPageState();
}

class _GlobalSearchPageState extends State<GlobalSearchPage> {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  final DataService _dataService = DataService();
  final TextEditingController _searchController = TextEditingController();

  List<Machine> _machines = [];
  List<Unit> _units = [];
  List<Spare> _spares = [];

  List<Machine> _filteredMachines = [];
  List<Unit> _filteredUnits = [];
  List<Spare> _filteredSpares = [];

  Map<String, Machine> _machineMap = {};
  Map<String, Unit> _unitMap = {};

  bool _isLoading = true;
  bool _hasSearched = false;

  @override
  void initState() {
    super.initState();
    _loadData();
    _searchController.addListener(_performSearch);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final machines = await _dataService.getMachines();
      final units = await _dbHelper.getAllUnits();
      final spares = await _dbHelper.getAllSpares();

      final machineMap = <String, Machine>{};
      for (var machine in machines) {
        machineMap[machine.id] = machine;
      }

      final unitMap = <String, Unit>{};
      for (var unit in units) {
        unitMap[unit.id] = unit;
      }

      setState(() {
        _machines = machines;
        _units = units;
        _spares = spares;
        _machineMap = machineMap;
        _unitMap = unitMap;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      debugPrint("Error loading data: $e");
    }
  }

  void _performSearch() {
    final query = _searchController.text.toLowerCase().trim();

    if (query.isEmpty) {
      setState(() {
        _filteredMachines = [];
        _filteredUnits = [];
        _filteredSpares = [];
        _hasSearched = false;
      });
      return;
    }

    setState(() {
      _hasSearched = true;

      // Filter machines
      _filteredMachines = _machines.where((machine) {
        return machine.name.toLowerCase().contains(query) ||
            (machine.description != null &&
                machine.description!.toLowerCase().contains(query));
      }).toList();

      // Filter units
      _filteredUnits = _units.where((unit) {
        final machine = _machineMap[unit.machineId];
        final machineName = machine?.name ?? '';
        return unit.name.toLowerCase().contains(query) ||
            (unit.description != null &&
                unit.description!.toLowerCase().contains(query)) ||
            machineName.toLowerCase().contains(query);
      }).toList();

      // Filter spares
      _filteredSpares = _spares.where((spare) {
        final unit = _unitMap[spare.subunitId];
        final machine = unit != null ? _machineMap[unit.machineId] : null;
        final machineName = machine?.name ?? '';
        final unitName = unit?.name ?? '';

        return spare.materialName.toLowerCase().contains(query) ||
            spare.serialNo.toLowerCase().contains(query) ||
            spare.materialCode.toLowerCase().contains(query) ||
            spare.partNo.toLowerCase().contains(query) ||
            (spare.description != null &&
                spare.description!.toLowerCase().contains(query)) ||
            machineName.toLowerCase().contains(query) ||
            unitName.toLowerCase().contains(query);
      }).toList();
    });
  }

  void _navigateToMachine(Machine machine) {
    Navigator.pushNamed(
      context,
      AppRoute.units,
      arguments: {'machine': machine},
    );
  }

  void _navigateToUnit(Unit unit) {
    final machine = _machineMap[unit.machineId];
    if (machine != null) {
      Navigator.pushNamed(
        context,
        AppRoute.spares,
        arguments: {'unit': unit, 'machine': machine},
      );
    }
  }

  void _navigateToSpareDetails(Spare spare) {
    final unit = _unitMap[spare.subunitId];
    if (unit != null) {
      final machine = _machineMap[unit.machineId];
      if (machine != null) {
        Navigator.pushNamed(
          context,
          AppRoute.spareDetails,
          arguments: {'spare': spare, 'unit': unit, 'machine': machine},
        );
      }
    }
  }

  String _getSpareContext(Spare spare) {
    final unit = _unitMap[spare.subunitId];
    if (unit != null) {
      final machine = _machineMap[unit.machineId];
      if (machine != null) {
        return '${machine.name} > ${unit.name}';
      }
      return unit.name;
    }
    return 'Unknown';
  }

  String _getUnitContext(Unit unit) {
    final machine = _machineMap[unit.machineId];
    return machine?.name ?? 'Unknown Machine';
  }

  @override
  Widget build(BuildContext context) {
    final totalResults =
        _filteredMachines.length +
        _filteredUnits.length +
        _filteredSpares.length;

    return Scaffold(
      appBar: AppBarWidget(
        title: 'Global Search',
        action: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Container
          Container(
            padding: const EdgeInsets.all(16),
            color: AppColors.gray,
            child: TextField(
              controller: _searchController,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Search machines, units, or spare parts...',
                hintStyle: TextStyle(color: AppColors.fontgrey),
                prefixIcon: const Icon(Icons.search, color: AppColors.primary),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(
                          Icons.clear,
                          color: AppColors.fontgrey,
                        ),
                        onPressed: () {
                          _searchController.clear();
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.grayDark),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.grayDark),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: AppColors.primary,
                    width: 2,
                  ),
                ),
              ),
            ),
          ),

          // Results Summary
          if (_hasSearched && totalResults > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: AppColors.primary.withOpacity(0.1),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: AppColors.primary, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    'Found $totalResults result${totalResults > 1 ? 's' : ''}',
                    style: AppTextStyles.bodyText.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),

          // Results List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : !_hasSearched
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search, size: 64, color: AppColors.fontgrey),
                        const SizedBox(height: 16),
                        Text(
                          'Start typing to search...',
                          style: AppTextStyles.bodyText.copyWith(
                            color: AppColors.fontgrey,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  )
                : totalResults == 0
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 64,
                          color: AppColors.fontgrey,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No results found',
                          style: AppTextStyles.bodyText.copyWith(
                            color: AppColors.fontgrey,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _loadData,
                    child: ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        // Machines Section
                        if (_filteredMachines.isNotEmpty) ...[
                          _buildSectionHeader(
                            'Machines',
                            _filteredMachines.length,
                          ),
                          const SizedBox(height: 8),
                          ..._filteredMachines.map(
                            (machine) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: GlobalListTile(
                                title: machine.name,
                                subtitle:
                                    machine.description ?? 'No description',
                                leadingIcon: Icons.precision_manufacturing,
                                trailing: const Icon(
                                  Icons.arrow_forward_ios,
                                  size: 16,
                                  color: AppColors.primary,
                                ),
                                onTap: () => _navigateToMachine(machine),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],

                        // Units Section
                        if (_filteredUnits.isNotEmpty) ...[
                          _buildSectionHeader('Units', _filteredUnits.length),
                          const SizedBox(height: 8),
                          ..._filteredUnits.map(
                            (unit) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: GlobalListTile(
                                title: unit.name,
                                subtitle:
                                    '${_getUnitContext(unit)}${unit.description != null ? " • ${unit.description}" : ""}',
                                leadingIcon: Icons.build_circle,
                                trailing: const Icon(
                                  Icons.arrow_forward_ios,
                                  size: 16,
                                  color: AppColors.primary,
                                ),
                                onTap: () => _navigateToUnit(unit),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],

                        // Spares Section
                        if (_filteredSpares.isNotEmpty) ...[
                          _buildSectionHeader(
                            'Spare Parts',
                            _filteredSpares.length,
                          ),
                          const SizedBox(height: 8),
                          ..._filteredSpares.map(
                            (spare) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: GlobalListTile(
                                title: spare.materialName,
                                subtitle:
                                    '${_getSpareContext(spare)}\nPart No: ${spare.partNo} • Code: ${spare.materialCode}',
                                leadingIcon: Icons.inventory_2,
                                trailing: spare.quantity != null
                                    ? Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: spare.quantity! <= 10
                                              ? Colors.red.withOpacity(0.1)
                                              : AppColors.primary.withOpacity(
                                                  0.1,
                                                ),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: Text(
                                          'Qty: ${spare.quantity}',
                                          style: AppTextStyles.bodyText
                                              .copyWith(
                                                color: spare.quantity! <= 10
                                                    ? Colors.red
                                                    : AppColors.primary,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 12,
                                              ),
                                        ),
                                      )
                                    : const Icon(
                                        Icons.arrow_forward_ios,
                                        size: 16,
                                        color: AppColors.primary,
                                      ),
                                onTap: () => _navigateToSpareDetails(spare),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, int count) {
    return Row(
      children: [
        Text(
          title,
          style: AppTextStyles.headline2.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '$count',
            style: AppTextStyles.bodyText.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }
}
