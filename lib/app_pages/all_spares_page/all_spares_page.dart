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

class AllSparesPage extends StatefulWidget {
  const AllSparesPage({super.key});

  @override
  State<AllSparesPage> createState() => _AllSparesPageState();
}

class _AllSparesPageState extends State<AllSparesPage> {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  final DataService _dataService = DataService();
  final TextEditingController _searchController = TextEditingController();
  List<Spare> _spares = [];
  List<Spare> _filteredSpares = [];
  Map<String, Unit> _unitMap = {};
  Map<String, Machine> _machineMap = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSpares();
    _searchController.addListener(_filterSpares);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterSpares() {
    final query = _searchController.text.toLowerCase().trim();
    if (query.isEmpty) {
      setState(() {
        _filteredSpares = _spares;
      });
    } else {
      setState(() {
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
  }

  Future<void> _loadSpares() async {
    setState(() => _isLoading = true);
    try {
      final spares = await _dbHelper.getAllSpares();
      final units = await _dbHelper.getAllUnits();
      final machines = await _dataService.getMachines();

      final unitMap = <String, Unit>{};
      for (var unit in units) {
        unitMap[unit.id] = unit;
      }

      final machineMap = <String, Machine>{};
      for (var machine in machines) {
        machineMap[machine.id] = machine;
      }

      setState(() {
        _spares = spares;
        _filteredSpares = spares;
        _unitMap = unitMap;
        _machineMap = machineMap;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      debugPrint("Error loading spares: $e");
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(
        title: 'All Spare Parts',
        action: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadSpares,
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
                hintText:
                    'Search spares by name, code, part no, machine, or unit...',
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

          // Spares List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredSpares.isEmpty
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
                              ? 'No spare parts found'
                              : 'No spare parts match your search',
                          style: AppTextStyles.bodyText.copyWith(
                            color: AppColors.fontgrey,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _loadSpares,
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _filteredSpares.length,
                      itemBuilder: (context, index) {
                        final spare = _filteredSpares[index];
                        final contextStr = _getSpareContext(spare);
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: GlobalListTile(
                            title: spare.materialName,
                            subtitle:
                                '$contextStr\nPart No: ${spare.partNo} • Code: ${spare.materialCode}',
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
                                          : AppColors.primary.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      'Qty: ${spare.quantity}',
                                      style: AppTextStyles.bodyText.copyWith(
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
