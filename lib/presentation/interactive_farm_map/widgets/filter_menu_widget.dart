import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class FilterMenuWidget extends StatelessWidget {
  final List<String> selectedCropTypes;
  final List<String> selectedHealthStatuses;
  final List<String> selectedIrrigationZones;
  final Function(List<String>) onCropTypesChanged;
  final Function(List<String>) onHealthStatusesChanged;
  final Function(List<String>) onIrrigationZonesChanged;
  final VoidCallback onApplyFilters;
  final VoidCallback onClearFilters;

  const FilterMenuWidget({
    Key? key,
    required this.selectedCropTypes,
    required this.selectedHealthStatuses,
    required this.selectedIrrigationZones,
    required this.onCropTypesChanged,
    required this.onHealthStatusesChanged,
    required this.onIrrigationZonesChanged,
    required this.onApplyFilters,
    required this.onClearFilters,
  }) : super(key: key);

  static const List<String> cropTypes = [
    'Wheat',
    'Corn',
    'Rice',
    'Soybeans',
    'Cotton',
    'Tomatoes'
  ];
  static const List<String> healthStatuses = [
    'Excellent',
    'Good',
    'Moderate',
    'Poor'
  ];
  static const List<String> irrigationZones = [
    'Zone A',
    'Zone B',
    'Zone C',
    'Zone D'
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80.w,
      constraints: BoxConstraints(maxHeight: 70.h),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Container(
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Filter Fields',
                  style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                    color: AppTheme.lightTheme.primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                TextButton(
                  onPressed: onClearFilters,
                  child: Text(
                    'Clear All',
                    style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.error,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Flexible(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(4.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Crop Types Section
                  _buildFilterSection(
                    'Crop Types',
                    cropTypes,
                    selectedCropTypes,
                    onCropTypesChanged,
                  ),
                  SizedBox(height: 3.h),
                  // Health Status Section
                  _buildFilterSection(
                    'Health Status',
                    healthStatuses,
                    selectedHealthStatuses,
                    onHealthStatusesChanged,
                  ),
                  SizedBox(height: 3.h),
                  // Irrigation Zones Section
                  _buildFilterSection(
                    'Irrigation Zones',
                    irrigationZones,
                    selectedIrrigationZones,
                    onIrrigationZonesChanged,
                  ),
                ],
              ),
            ),
          ),
          // Apply button
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(4.w),
            child: ElevatedButton(
              onPressed: onApplyFilters,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.lightTheme.primaryColor,
                padding: EdgeInsets.symmetric(vertical: 2.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Apply Filters',
                style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection(
    String title,
    List<String> options,
    List<String> selectedOptions,
    Function(List<String>) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 1.h),
        Wrap(
          spacing: 2.w,
          runSpacing: 1.h,
          children: options.map((option) {
            final isSelected = selectedOptions.contains(option);
            return FilterChip(
              label: Text(
                option,
                style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                  color: isSelected
                      ? Colors.white
                      : AppTheme.lightTheme.colorScheme.onSurface,
                ),
              ),
              selected: isSelected,
              onSelected: (selected) {
                final newSelection = List<String>.from(selectedOptions);
                if (selected) {
                  newSelection.add(option);
                } else {
                  newSelection.remove(option);
                }
                onChanged(newSelection);
              },
              selectedColor: AppTheme.lightTheme.primaryColor,
              backgroundColor: AppTheme.lightTheme.colorScheme.surface,
              side: BorderSide(
                color: isSelected
                    ? AppTheme.lightTheme.primaryColor
                    : Colors.grey.withValues(alpha: 0.3),
              ),
              showCheckmark: false,
            );
          }).toList(),
        ),
      ],
    );
  }
}
