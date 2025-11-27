import 'package:flutter/material.dart';
import 'package:spare_management/app_configs/app_routes.dart';
import 'package:spare_management/app_themes/app_colors.dart';
import 'package:spare_management/app_themes/custom_theme.dart';
import 'package:spare_management/app_utils/app_bar_widget.dart';
import 'package:spare_management/app_utils/global_list_tile.dart';
import 'package:spare_management/models/machine.dart';
import 'package:spare_management/models/unit.dart';
import 'package:spare_management/services/database_helper.dart';
import 'package:spare_management/services/data_service.dart';

class AllUnitsPage extends StatefulWidget {
  const AllUnitsPage({super.key});

  @override
  State<AllUnitsPage> createState() => _AllUnitsPageState();
}

class _AllUnitsPageState extends State<AllUnitsPage> {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  final DataService _dataService = DataService();
  final TextEditingController _searchController = TextEditingController();
  List<Unit> _units = [];
  List<Unit> _filteredUnits = [];
  Map<String, Machine> _machineMap = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUnits();
    _searchController.addListener(_filterUnits);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterUnits() {
    final query = _searchController.text.toLowerCase().trim();
    if (query.isEmpty) {
      setState(() {
        _filteredUnits = _units;
      });
    } else {
      setState(() {
        _filteredUnits = _units.where((unit) {
          final machine = _machineMap[unit.machineId];
          final machineName = machine?.name ?? '';
          return unit.name.toLowerCase().contains(query) ||
              (unit.description != null &&
                  unit.description!.toLowerCase().contains(query)) ||
              machineName.toLowerCase().contains(query);
        }).toList();
      });
    }
  }

  Future<void> _loadUnits() async {
    setState(() => _isLoading = true);
    try {
      final units = await _dbHelper.getAllUnits();
      final machines = await _dataService.getMachines();

      final machineMap = <String, Machine>{};
      for (var machine in machines) {
        machineMap[machine.id] = machine;
      }

      setState(() {
        _units = units;
        _filteredUnits = units;
        _machineMap = machineMap;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      debugPrint("Error loading units: $e");
    }
  }

  void _navigateToSpares(Unit unit) {
    final machine = _machineMap[unit.machineId];
    if (machine != null) {
      Navigator.pushNamed(
        context,
        AppRoute.spares,
        arguments: {'unit': unit, 'machine': machine},
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(
        title: 'All Units',
        action: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadUnits,
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
              decoration: InputDecoration(
                hintText: 'Search units by name, description, or machine...',
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

          // Units List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredUnits.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.inventory_2_outlined,
                          size: 64,
                          color: AppColors.fontgrey,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _searchController.text.isEmpty
                              ? 'No units found'
                              : 'No units match your search',
                          style: AppTextStyles.bodyText.copyWith(
                            color: AppColors.fontgrey,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _loadUnits,
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _filteredUnits.length,
                      itemBuilder: (context, index) {
                        final unit = _filteredUnits[index];
                        final machine = _machineMap[unit.machineId];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: GlobalListTile(
                            title: unit.name,
                            subtitle: machine != null
                                ? '${machine.name}${unit.description != null ? " • ${unit.description}" : ""}'
                                : unit.description ?? 'No machine assigned',
                            leadingIcon: Icons.build_circle,
                            trailing: const Icon(
                              Icons.arrow_forward_ios,
                              size: 16,
                              color: AppColors.primary,
                            ),
                            onTap: () => _navigateToSpares(unit),
                          ),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
