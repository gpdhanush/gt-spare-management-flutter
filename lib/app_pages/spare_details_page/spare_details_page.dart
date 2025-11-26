import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:spare_management/app_themes/app_colors.dart';
import 'package:spare_management/app_themes/custom_theme.dart';
import 'package:spare_management/app_utils/app_bar_widget.dart';
import 'package:spare_management/models/machine.dart';
import 'package:spare_management/models/unit.dart';
import 'package:spare_management/models/spare.dart';

class SpareDetailsPage extends StatelessWidget {
  final Spare spare;
  final Unit unit;
  final Machine machine;

  const SpareDetailsPage({
    super.key,
    required this.spare,
    required this.unit,
    required this.machine,
  });

  String _formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return 'N/A';
    try {
      // Try parsing ISO format first
      final date = DateTime.parse(dateString);
      return DateFormat('MM/dd/yyyy').format(date);
    } catch (e) {
      // If parsing fails, try SQLite datetime format
      try {
        final date = DateFormat('yyyy-MM-dd HH:mm:ss').parse(dateString);
        return DateFormat('MM/dd/yyyy').format(date);
      } catch (e2) {
        return dateString;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBarWidget(
        title: 'Spare Details',
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Main Title Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.black.withOpacity(0.08),
                    blurRadius: 15,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    spare.materialName,
                    style: AppTextStyles.bodyText.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 28,
                      color: AppColors.black,
                      height: 1.2,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Identification Section
            _buildSection(
              title: 'IDENTIFICATION',
              child: Column(
                children: [
                  _buildInfoRow('Serial Number', spare.serialNo),
                  const SizedBox(height: 16),
                  _buildInfoRow('Material Code', spare.materialCode),
                  const SizedBox(height: 16),
                  _buildInfoRow('Part Number', spare.partNo),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Description Section
            if (spare.description != null && spare.description!.isNotEmpty)
              _buildSection(
                title: 'DESCRIPTION',
                child: Text(
                  spare.description!,
                  style: AppTextStyles.bodyText.copyWith(
                    fontSize: 16,
                    color: AppColors.black,
                    height: 1.5,
                  ),
                ),
              ),
            if (spare.description != null && spare.description!.isNotEmpty)
              const SizedBox(height: 20),

            // Record Information Section
            _buildSection(
              title: 'RECORD INFORMATION',
              child: _buildInfoRow('Created', _formatDate(spare.createdAt)),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.bodyText.copyWith(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.fontgrey,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: AppTextStyles.bodyText.copyWith(
              fontSize: 14,
              color: AppColors.fontgrey,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: AppTextStyles.bodyText.copyWith(
              fontSize: 16,
              color: AppColors.black,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
