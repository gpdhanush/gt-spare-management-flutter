import 'package:flutter/material.dart';
import 'package:spare_management/app_themes/app_colors.dart';
import 'package:spare_management/app_themes/custom_theme.dart';
import 'package:spare_management/app_utils/app_bar_widget.dart';
import 'package:spare_management/models/machine.dart';
import 'package:spare_management/models/unit.dart';
import 'package:spare_management/models/spare.dart';
import 'package:spare_management/services/data_service.dart';
import 'package:spare_management/app_configs/app_routes.dart';

class SparesPage extends StatefulWidget {
  final Unit unit;
  final Machine machine;

  const SparesPage({super.key, required this.unit, required this.machine});

  @override
  State<SparesPage> createState() => _SparesPageState();
}

class _SparesPageState extends State<SparesPage> {
  final DataService _dataService = DataService();
  final TextEditingController _searchController = TextEditingController();
  List<Spare> _spares = [];
  List<Spare> _filteredSpares = [];
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
          return spare.materialName.toLowerCase().contains(query) ||
              spare.serialNo.toLowerCase().contains(query) ||
              spare.materialCode.toLowerCase().contains(query) ||
              spare.partNo.toLowerCase().contains(query) ||
              (spare.description != null &&
                  spare.description!.toLowerCase().contains(query));
        }).toList();
      });
    }
  }

  Future<void> _loadSpares() async {
    setState(() => _isLoading = true);
    try {
      final spares = await _dataService.getSparesByUnit(widget.unit.id);
      setState(() {
        _spares = spares;
        _filteredSpares = spares;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      debugPrint("Error loading spares: $e");
    }
  }

  void _showAddEditSpareDialog({Spare? spare}) {
    final serialNoController = TextEditingController(
      text: spare?.serialNo ?? '',
    );
    final materialCodeController = TextEditingController(
      text: spare?.materialCode ?? '',
    );
    final materialNameController = TextEditingController(
      text: spare?.materialName ?? '',
    );
    final partNoController = TextEditingController(text: spare?.partNo ?? '');
    final descriptionController = TextEditingController(
      text: spare?.description ?? '',
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          spare == null ? 'Add Spare Part' : 'Edit Spare Part',
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
                controller: serialNoController,
                decoration: InputDecoration(
                  labelText: 'Serial Number *',
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
                controller: materialCodeController,
                decoration: InputDecoration(
                  labelText: 'Material Code *',
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
                controller: materialNameController,
                decoration: InputDecoration(
                  labelText: 'Material Name *',
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
                controller: partNoController,
                decoration: InputDecoration(
                  labelText: 'Part Number *',
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
              if (serialNoController.text.isNotEmpty &&
                  materialCodeController.text.isNotEmpty &&
                  materialNameController.text.isNotEmpty &&
                  partNoController.text.isNotEmpty) {
                if (spare == null) {
                  final newSpare = Spare(
                    id: '',
                    subunitId: widget.unit.id,
                    serialNo: serialNoController.text.trim(),
                    materialCode: materialCodeController.text.trim(),
                    materialName: materialNameController.text.trim(),
                    partNo: partNoController.text.trim(),
                    description: descriptionController.text.trim().isEmpty
                        ? null
                        : descriptionController.text.trim(),
                  );
                  await _dataService.addSpare(newSpare);
                } else {
                  final updatedSpare = spare.copyWith(
                    serialNo: serialNoController.text.trim(),
                    materialCode: materialCodeController.text.trim(),
                    materialName: materialNameController.text.trim(),
                    partNo: partNoController.text.trim(),
                    description: descriptionController.text.trim().isEmpty
                        ? null
                        : descriptionController.text.trim(),
                  );
                  await _dataService.updateSpare(updatedSpare);
                }
                if (context.mounted) {
                  Navigator.pop(context);
                  _loadSpares();
                  _filterSpares();
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

  void _showDeleteConfirmation(Spare spare) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Delete Spare Part',
          style: AppTextStyles.bodyText.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: AppColors.black,
          ),
        ),
        content: Text(
          'Are you sure you want to delete ${spare.materialName}?',
          style: AppTextStyles.bodyText.copyWith(color: AppColors.fontgrey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: AppColors.fontgrey)),
          ),
          ElevatedButton(
            onPressed: () async {
              await _dataService.deleteSpare(spare.id);
              if (context.mounted) {
                Navigator.pop(context);
                _loadSpares();
                _filterSpares();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBarWidget(
        title: widget.unit.name,
        action: [
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
          // Breadcrumb
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.primary.withOpacity(0.15),
                  AppColors.primary.withOpacity(0.08),
                ],
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.layers, color: AppColors.primary, size: 20),
                ),
                const SizedBox(width: 12),
                Text(
                  '${widget.unit.name} / Spares',
                  style: AppTextStyles.bodyText.copyWith(
                    color: AppColors.primary,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
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
                    hintText: 'Search by name, serial, code, part number...',
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
                : _filteredSpares.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.inventory_2_outlined,
                          size: 80,
                          color: AppColors.fontgrey.withOpacity(0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _searchController.text.isNotEmpty
                              ? 'No spares found matching your search'
                              : 'No spares found',
                          style: AppTextStyles.bodyText.copyWith(
                            color: AppColors.fontgrey,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _searchController.text.isNotEmpty
                              ? 'Try a different search term'
                              : 'Tap the + button to add a new spare part',
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
                    itemCount: _filteredSpares.length,
                    itemBuilder: (context, index) {
                      final spare = _filteredSpares[index];
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
                                AppRoute.spareDetails,
                                arguments: {
                                  'spare': spare,
                                  'unit': widget.unit,
                                  'machine': widget.machine,
                                },
                              );
                            },
                            borderRadius: BorderRadius.circular(16),
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          spare.materialName,
                                          style: AppTextStyles.bodyText
                                              .copyWith(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 20,
                                                color: AppColors.black,
                                              ),
                                        ),
                                        const SizedBox(height: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: AppColors.primary
                                                .withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(
                                              6,
                                            ),
                                          ),
                                          child: Text(
                                            'SN: ${spare.serialNo}',
                                            style: AppTextStyles.bodyText
                                                .copyWith(
                                                  color: AppColors.primary,
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 10,
                                                      vertical: 6,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: AppColors.gray,
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                child: Text(
                                                  'Code: ${spare.materialCode}',
                                                  style: AppTextStyles.bodyText
                                                      .copyWith(
                                                        color:
                                                            AppColors.fontgrey,
                                                        fontSize: 13,
                                                      ),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 10,
                                                      vertical: 6,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: AppColors.gray,
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                child: Text(
                                                  'Part: ${spare.partNo}',
                                                  style: AppTextStyles.bodyText
                                                      .copyWith(
                                                        color:
                                                            AppColors.fontgrey,
                                                        fontSize: 13,
                                                      ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        if (spare.description != null &&
                                            spare.description!.isNotEmpty) ...[
                                          const SizedBox(height: 8),
                                          Text(
                                            spare.description!,
                                            style: AppTextStyles.bodyText
                                                .copyWith(
                                                  color: AppColors.fontgrey,
                                                  fontSize: 14,
                                                  fontStyle: FontStyle.italic,
                                                ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.red.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: IconButton(
                                      icon: const Icon(
                                        Icons.delete,
                                        color: Colors.red,
                                        size: 20,
                                      ),
                                      onPressed: () =>
                                          _showDeleteConfirmation(spare),
                                    ),
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
          onPressed: () => _showAddEditSpareDialog(),
          backgroundColor: AppColors.primary,
          elevation: 0,
          child: const Icon(Icons.add, color: Colors.white, size: 28),
        ),
      ),
    );
  }
}
