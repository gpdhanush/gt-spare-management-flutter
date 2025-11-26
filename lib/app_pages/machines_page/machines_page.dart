import 'package:flutter/material.dart';
import 'package:spare_management/app_themes/app_colors.dart';
import 'package:spare_management/app_themes/custom_theme.dart';
import 'package:spare_management/app_utils/app_bar_widget.dart';
import 'package:spare_management/models/machine.dart';
import 'package:spare_management/services/data_service.dart';
import 'package:spare_management/services/google_drive_service.dart';
import 'package:spare_management/services/auth_service.dart';
import 'package:spare_management/app_configs/app_routes.dart';

class MachinesPage extends StatefulWidget {
  const MachinesPage({super.key});

  @override
  State<MachinesPage> createState() => _MachinesPageState();
}

class _MachinesPageState extends State<MachinesPage> {
  final DataService _dataService = DataService();
  final TextEditingController _searchController = TextEditingController();
  List<Machine> _machines = [];
  List<Machine> _filteredMachines = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMachines();
    _searchController.addListener(_filterMachines);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterMachines() {
    final query = _searchController.text.toLowerCase().trim();
    if (query.isEmpty) {
      setState(() {
        _filteredMachines = _machines;
      });
    } else {
      setState(() {
        _filteredMachines = _machines.where((machine) {
          return machine.name.toLowerCase().contains(query) ||
              (machine.description != null &&
                  machine.description!.toLowerCase().contains(query));
        }).toList();
      });
    }
  }

  Future<void> _loadMachines() async {
    setState(() => _isLoading = true);
    try {
      final machines = await _dataService.getMachines();
      setState(() {
        _machines = machines;
        _filteredMachines = machines;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      debugPrint("Error loading machines: $e");
    }
  }

  void _showAddEditMachineDialog({Machine? machine}) {
    final nameController = TextEditingController(text: machine?.name ?? '');
    final descriptionController = TextEditingController(
      text: machine?.description ?? '',
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          machine == null ? 'Add Machine' : 'Edit Machine',
          style: AppTextStyles.bodyText.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: AppColors.black,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Name *',
                  labelStyle: TextStyle(color: AppColors.fontgrey),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.primary, width: 2),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.grayDark),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(
                  labelText: 'Description',
                  labelStyle: TextStyle(color: AppColors.fontgrey),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.primary, width: 2),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.grayDark),
                  ),
                ),
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: AppColors.fontgrey)),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.isNotEmpty) {
                if (machine == null) {
                  final newMachine = Machine(
                    id: '',
                    name: nameController.text.trim(),
                    description: descriptionController.text.trim().isEmpty
                        ? null
                        : descriptionController.text.trim(),
                  );
                  await _dataService.addMachine(newMachine);
                } else {
                  final updatedMachine = machine.copyWith(
                    name: nameController.text.trim(),
                    description: descriptionController.text.trim().isEmpty
                        ? null
                        : descriptionController.text.trim(),
                  );
                  await _dataService.updateMachine(updatedMachine);
                }
                if (context.mounted) {
                  Navigator.pop(context);
                  _loadMachines();
                  _filterMachines();
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(Machine machine) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Delete Machine',
          style: AppTextStyles.bodyText.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: AppColors.black,
          ),
        ),
        content: Text(
          'Are you sure you want to delete ${machine.name}?',
          style: AppTextStyles.bodyText.copyWith(color: AppColors.fontgrey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: AppColors.fontgrey)),
          ),
          ElevatedButton(
            onPressed: () async {
              await _dataService.deleteMachine(machine.id);
              if (context.mounted) {
                Navigator.pop(context);
                _loadMachines();
                _filterMachines();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _handleExportDatabase() async {
    final success = await GoogleDriveService.instance.exportDatabase();
    if (success && mounted) {
      _loadMachines(); // Refresh data
    }
  }

  Future<void> _handleImportDatabase() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Import Database',
          style: AppTextStyles.bodyText.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: AppColors.black,
          ),
        ),
        content: Text(
          'This will replace your current database with the one from Google Drive. Are you sure?',
          style: AppTextStyles.bodyText.copyWith(color: AppColors.fontgrey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: AppColors.fontgrey)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await GoogleDriveService.instance
                  .importDatabase();
              if (success && mounted) {
                _loadMachines(); // Refresh data
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text('Import', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _handleSignOut() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Sign Out',
          style: AppTextStyles.bodyText.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: AppColors.black,
          ),
        ),
        content: Text(
          'Are you sure you want to sign out?',
          style: AppTextStyles.bodyText.copyWith(color: AppColors.fontgrey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: AppColors.fontgrey)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await AuthService.instance.signOut();
              if (mounted) {
                Navigator.pushReplacementNamed(context, AppRoute.login);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text(
              'Sign Out',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBarWidget(
        title: 'Machines',
        action: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onSelected: (value) {
              if (value == 'export') {
                _handleExportDatabase();
              } else if (value == 'import') {
                _handleImportDatabase();
              } else if (value == 'signout') {
                _handleSignOut();
              }
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem<String>(
                value: 'export',
                child: Row(
                  children: [
                    Icon(Icons.upload, color: AppColors.primary),
                    SizedBox(width: 8),
                    Text('Export to Google Drive'),
                  ],
                ),
              ),
              const PopupMenuItem<String>(
                value: 'import',
                child: Row(
                  children: [
                    Icon(Icons.download, color: AppColors.primary),
                    SizedBox(width: 8),
                    Text('Import from Google Drive'),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem<String>(
                value: 'signout',
                child: Row(
                  children: [
                    Icon(Icons.logout, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Sign Out', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: CircleAvatar(
              backgroundColor: Colors.white,
              radius: 18,
              child: Text(
                'GT',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            color: AppColors.white,
            child: ValueListenableBuilder<TextEditingValue>(
              valueListenable: _searchController,
              builder: (context, value, child) {
                return TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search by name or description...',
                    hintStyle: TextStyle(
                      color: AppColors.fontgrey.withOpacity(0.6),
                    ),
                    prefixIcon: Icon(Icons.search, color: AppColors.primary),
                    suffixIcon: value.text.isNotEmpty
                        ? IconButton(
                            icon: Icon(Icons.clear, color: AppColors.fontgrey),
                            onPressed: () {
                              _searchController.clear();
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: AppColors.gray,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: AppColors.grayDark,
                        width: 1,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: AppColors.primary,
                        width: 2,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),
                );
              },
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredMachines.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.computer_outlined,
                          size: 80,
                          color: AppColors.fontgrey.withOpacity(0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _searchController.text.isNotEmpty
                              ? 'No machines found matching your search'
                              : 'No machines found',
                          style: AppTextStyles.bodyText.copyWith(
                            color: AppColors.fontgrey,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _searchController.text.isNotEmpty
                              ? 'Try a different search term'
                              : 'Tap the + button to add a new machine',
                          style: AppTextStyles.bodyText.copyWith(
                            color: AppColors.fontgrey,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: _filteredMachines.length,
                    itemBuilder: (context, index) {
                      final machine = _filteredMachines[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.black.withOpacity(0.08),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Material(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(16),
                          child: InkWell(
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                AppRoute.units,
                                arguments: {'machine': machine},
                              ).then((_) => _loadMachines());
                            },
                            borderRadius: BorderRadius.circular(16),
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          machine.name,
                                          style: AppTextStyles.bodyText
                                              .copyWith(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 20,
                                                color: AppColors.black,
                                              ),
                                        ),
                                        if (machine.description != null &&
                                            machine
                                                .description!
                                                .isNotEmpty) ...[
                                          const SizedBox(height: 8),
                                          Text(
                                            machine.description!,
                                            style: AppTextStyles.bodyText
                                                .copyWith(
                                                  color: AppColors.fontgrey,
                                                  fontSize: 14,
                                                ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                  Column(
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                          color: AppColors.primary.withOpacity(
                                            0.1,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: IconButton(
                                          icon: Icon(
                                            Icons.edit,
                                            color: AppColors.primary,
                                            size: 20,
                                          ),
                                          onPressed: () =>
                                              _showAddEditMachineDialog(
                                                machine: machine,
                                              ),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Container(
                                        decoration: BoxDecoration(
                                          color: Colors.red.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: IconButton(
                                          icon: const Icon(
                                            Icons.delete,
                                            color: Colors.red,
                                            size: 20,
                                          ),
                                          onPressed: () =>
                                              _showDeleteConfirmation(machine),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.4),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: () => _showAddEditMachineDialog(),
          backgroundColor: AppColors.primary,
          elevation: 0,
          child: const Icon(Icons.add, color: Colors.white, size: 28),
        ),
      ),
    );
  }
}
