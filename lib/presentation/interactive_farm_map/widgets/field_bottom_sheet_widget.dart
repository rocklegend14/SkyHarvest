import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class FieldBottomSheetWidget extends StatelessWidget {
  final Map<String, dynamic>? selectedField;
  final VoidCallback onGetPrediction;
  final VoidCallback onScheduleIrrigation;
  final VoidCallback onViewHistory;
  final VoidCallback onClose;

  const FieldBottomSheetWidget({
    Key? key,
    required this.selectedField,
    required this.onGetPrediction,
    required this.onScheduleIrrigation,
    required this.onViewHistory,
    required this.onClose,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (selectedField == null) return SizedBox.shrink();

    return DraggableScrollableSheet(
      initialChildSize: 0.3,
      minChildSize: 0.2,
      maxChildSize: 0.6,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: AppTheme.lightTheme.colorScheme.surface,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: Offset(0, -2),
              ),
            ],
          ),
          child: Column(
            children: [
              // Drag handle
              Container(
                margin: EdgeInsets.only(top: 1.h),
                width: 10.w,
                height: 0.5.h,
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Header with close button
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Field Details',
                      style: AppTheme.lightTheme.textTheme.titleLarge,
                    ),
                    IconButton(
                      onPressed: onClose,
                      icon: CustomIconWidget(
                        iconName: 'close',
                        color: AppTheme.lightTheme.colorScheme.onSurface,
                        size: 24,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: EdgeInsets.symmetric(horizontal: 4.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Field information
                      _buildInfoRow(
                          'Crop Type', selectedField!['cropType'] as String),
                      SizedBox(height: 1.h),
                      _buildInfoRow('Planting Date',
                          selectedField!['plantingDate'] as String),
                      SizedBox(height: 1.h),
                      _buildInfoRow(
                          'Field Size', '${selectedField!['size']} hectares'),
                      SizedBox(height: 1.h),
                      // Health status with color indicator
                      Row(
                        children: [
                          Text(
                            'Health Status:',
                            style: AppTheme.lightTheme.textTheme.bodyMedium
                                ?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(width: 2.w),
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 3.w, vertical: 0.5.h),
                            decoration: BoxDecoration(
                              color: _getHealthStatusColor(
                                  selectedField!['healthStatus'] as String),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              selectedField!['healthStatus'] as String,
                              style: AppTheme.lightTheme.textTheme.bodySmall
                                  ?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 3.h),
                      // Action buttons
                      _buildActionButton(
                        'Get Prediction',
                        'analytics',
                        AppTheme.lightTheme.primaryColor,
                        onGetPrediction,
                      ),
                      SizedBox(height: 1.h),
                      _buildActionButton(
                        'Schedule Irrigation',
                        'water_drop',
                        AppTheme.accentLight,
                        onScheduleIrrigation,
                      ),
                      SizedBox(height: 1.h),
                      _buildActionButton(
                        'View History',
                        'history',
                        AppTheme.lightTheme.colorScheme.secondary,
                        onViewHistory,
                      ),
                      SizedBox(height: 2.h),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 30.w,
          child: Text(
            '$label:',
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: AppTheme.lightTheme.textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(
      String title, String iconName, Color color, VoidCallback onTap) {
    return Container(
      width: double.infinity,
      height: 6.h,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomIconWidget(
              iconName: iconName,
              color: Colors.white,
              size: 20,
            ),
            SizedBox(width: 2.w),
            Text(
              title,
              style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getHealthStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'excellent':
        return AppTheme.successLight;
      case 'good':
        return AppTheme.lightTheme.primaryColor;
      case 'moderate':
        return AppTheme.warningLight;
      case 'poor':
        return AppTheme.lightTheme.colorScheme.error;
      default:
        return Colors.grey;
    }
  }
}
