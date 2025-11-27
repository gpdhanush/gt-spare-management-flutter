import 'package:flutter/material.dart';
import 'package:spare_management/app_configs/app_routes.dart';
import 'package:spare_management/app_themes/app_colors.dart';
import 'package:spare_management/app_themes/custom_theme.dart';
import 'package:spare_management/app_utils/app_bar_widget.dart';
import 'package:spare_management/models/spare.dart';
import 'package:spare_management/services/database_helper.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  int _machineCount = 0;
  int _unitCount = 0;
  int _spareCount = 0;
  List<Spare> _lowStockSpares = [];
  List<Spare> _recentSpares = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() => _isLoading = true);
    try {
      final machineCount = await _dbHelper.getMachineCount();
      final unitCount = await _dbHelper.getUnitCount();
      final spareCount = await _dbHelper.getSpareCount();
      final lowStockSpares = await _dbHelper.getLowStockSpares(threshold: 10);
      final recentSpares = await _dbHelper.getRecentSpares(limit: 5);

      setState(() {
        _machineCount = machineCount;
        _unitCount = unitCount;
        _spareCount = spareCount;
        _lowStockSpares = lowStockSpares;
        _recentSpares = recentSpares;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      debugPrint("Error loading dashboard data: $e");
    }
  }

  Future<void> _handleLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Logout',
          style: AppTextStyles.bodyText.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: AppColors.black,
          ),
        ),
        content: const Text(
          'Are you sure you want to logout?',
          style: AppTextStyles.bodyText,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: AppTextStyles.bodyText.copyWith(color: AppColors.fontgrey),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      try {
        if (mounted) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            AppRoute.login,
            (route) => false,
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Logout failed: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(
        title: 'Dashboard',
        action: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDashboardData,
            tooltip: 'Refresh',
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _handleLogout,
            tooltip: 'Logout',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadDashboardData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Statistics Cards
                    _buildStatisticsSection(),
                    const SizedBox(height: 24),

                    // Quick Access Section
                    _buildQuickAccessSection(),
                    const SizedBox(height: 24),

                    // Low Stock Alerts
                    if (_lowStockSpares.isNotEmpty) ...[
                      _buildLowStockSection(),
                      const SizedBox(height: 24),
                    ],

                    // Recent Activity
                    if (_recentSpares.isNotEmpty) ...[
                      _buildRecentActivitySection(),
                    ],
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildStatisticsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Overview',
          style: AppTextStyles.headline2.copyWith(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                title: 'Machines',
                count: _machineCount,
                icon: Icons.precision_manufacturing,
                color: AppColors.primary,
                onTap: () {
                  Navigator.pushNamed(context, AppRoute.machines);
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                title: 'Units',
                count: _unitCount,
                icon: Icons.build_circle,
                color: AppColors.primaryOption4,
                onTap: () {
                  Navigator.pushNamed(context, AppRoute.allUnits);
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildStatCard(
          title: 'Spare Parts',
          count: _spareCount,
          icon: Icons.inventory_2,
          color: AppColors.primaryOption3,
          onTap: () {
            Navigator.pushNamed(context, AppRoute.allSpares);
          },
          fullWidth: true,
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required int count,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    bool fullWidth = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: fullWidth ? double.infinity : null,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3), width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 28),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: color.withOpacity(0.6),
                  size: 16,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              count.toString(),
              style: AppTextStyles.headline1.copyWith(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: AppTextStyles.bodyText.copyWith(
                fontSize: 14,
                color: AppColors.fontgrey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAccessSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Access',
          style: AppTextStyles.headline2.copyWith(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.5,
          children: [
            _buildQuickAccessCard(
              title: 'Machines',
              icon: Icons.precision_manufacturing,
              color: AppColors.primary,
              route: AppRoute.machines,
            ),
            _buildQuickAccessCard(
              title: 'All Units',
              icon: Icons.build_circle,
              color: AppColors.primaryOption4,
              route: AppRoute.allUnits,
            ),
            _buildQuickAccessCard(
              title: 'All Spares',
              icon: Icons.inventory_2,
              color: AppColors.primaryOption3,
              route: AppRoute.allSpares,
            ),
            _buildQuickAccessCard(
              title: 'Search',
              icon: Icons.search,
              color: AppColors.primaryOption5,
              route: AppRoute.globalSearch,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickAccessCard({
    required String title,
    required IconData icon,
    required Color color,
    required String route,
  }) {
    return InkWell(
      onTap: () {
        Navigator.pushNamed(context, route);
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [color, color.withOpacity(0.7)],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 32),
            const SizedBox(height: 8),
            Text(
              title,
              style: AppTextStyles.bodyText.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLowStockSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Low Stock Alerts',
              style: AppTextStyles.headline2.copyWith(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${_lowStockSpares.length}',
                style: AppTextStyles.bodyText.copyWith(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.red.withOpacity(0.2), width: 1),
          ),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.all(12),
            itemCount: _lowStockSpares.length > 5 ? 5 : _lowStockSpares.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final spare = _lowStockSpares[index];
              return _buildLowStockItem(spare);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildLowStockItem(Spare spare) {
    return FutureBuilder(
      future: _getSpareContext(spare),
      builder: (context, snapshot) {
        return ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 4,
          ),
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.warning_amber_rounded,
              color: Colors.red,
              size: 20,
            ),
          ),
          title: Text(
            spare.materialName,
            style: AppTextStyles.bodyText.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (snapshot.hasData && snapshot.data != null)
                Text(
                  snapshot.data!,
                  style: AppTextStyles.bodyText.copyWith(
                    fontSize: 12,
                    color: AppColors.fontgrey,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              const SizedBox(height: 2),
              Text(
                'Part No: ${spare.partNo}',
                style: AppTextStyles.bodyText.copyWith(
                  fontSize: 11,
                  color: AppColors.fontgrey,
                ),
              ),
            ],
          ),
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'Qty: ${spare.quantity ?? 0}',
              style: AppTextStyles.bodyText.copyWith(
                color: Colors.red,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
          onTap: () => _navigateToSpareDetails(spare),
        );
      },
    );
  }

  Future<String?> _getSpareContext(Spare spare) async {
    try {
      final unit = await _dbHelper.getUnitById(spare.subunitId);
      if (unit != null) {
        final machine = await _dbHelper.getMachineById(unit.machineId);
        if (machine != null) {
          return '${machine.name} > ${unit.name}';
        }
        return unit.name;
      }
    } catch (e) {
      debugPrint("Error getting spare context: $e");
    }
    return null;
  }

  Widget _buildRecentActivitySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Activity',
          style: AppTextStyles.headline2.copyWith(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: AppColors.gray,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.grayDark, width: 1),
          ),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.all(12),
            itemCount: _recentSpares.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final spare = _recentSpares[index];
              return _buildRecentActivityItem(spare);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRecentActivityItem(Spare spare) {
    return FutureBuilder(
      future: _getSpareContext(spare),
      builder: (context, snapshot) {
        return ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 4,
          ),
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.inventory_2, color: AppColors.primary, size: 20),
          ),
          title: Text(
            spare.materialName,
            style: AppTextStyles.bodyText.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (snapshot.hasData && snapshot.data != null)
                Text(
                  snapshot.data!,
                  style: AppTextStyles.bodyText.copyWith(
                    fontSize: 12,
                    color: AppColors.fontgrey,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              const SizedBox(height: 2),
              Text(
                'Code: ${spare.materialCode}',
                style: AppTextStyles.bodyText.copyWith(
                  fontSize: 11,
                  color: AppColors.fontgrey,
                ),
              ),
            ],
          ),
          trailing: spare.quantity != null
              ? Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Qty: ${spare.quantity}',
                    style: AppTextStyles.bodyText.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                )
              : null,
          onTap: () => _navigateToSpareDetails(spare),
        );
      },
    );
  }

  Future<void> _navigateToSpareDetails(Spare spare) async {
    try {
      final unit = await _dbHelper.getUnitById(spare.subunitId);
      if (unit != null) {
        final machine = await _dbHelper.getMachineById(unit.machineId);
        if (machine != null) {
          Navigator.pushNamed(
            context,
            AppRoute.spareDetails,
            arguments: {'spare': spare, 'unit': unit, 'machine': machine},
          );
        }
      }
    } catch (e) {
      debugPrint("Error navigating to spare details: $e");
    }
  }
}
