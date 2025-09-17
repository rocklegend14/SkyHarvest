import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class SoilStatusCard extends StatelessWidget {
  final Map<String, dynamic> soilData;

  const SoilStatusCard({
    Key? key,
    required this.soilData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CustomIconWidget(
                  iconName: 'eco',
                  color: AppTheme.lightTheme.primaryColor,
                  size: 24,
                ),
                SizedBox(width: 2.w),
                Text(
                  'Current Soil Status',
                  style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            SizedBox(height: 2.h),
            _buildNutrientLevel(
              'Nitrogen (N)',
              (soilData['nitrogen'] as num).toDouble(),
              _getNutrientColor((soilData['nitrogen'] as num).toDouble()),
            ),
            SizedBox(height: 1.5.h),
            _buildNutrientLevel(
              'Phosphorus (P)',
              (soilData['phosphorus'] as num).toDouble(),
              _getNutrientColor((soilData['phosphorus'] as num).toDouble()),
            ),
            SizedBox(height: 1.5.h),
            _buildNutrientLevel(
              'Potassium (K)',
              (soilData['potassium'] as num).toDouble(),
              _getNutrientColor((soilData['potassium'] as num).toDouble()),
            ),
            SizedBox(height: 2.h),
            Container(
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: _getOverallHealthColor().withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  CustomIconWidget(
                    iconName: 'info',
                    color: _getOverallHealthColor(),
                    size: 20,
                  ),
                  SizedBox(width: 2.w),
                  Expanded(
                    child: Text(
                      _getOverallHealthText(),
                      style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                        color: _getOverallHealthColor(),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNutrientLevel(String nutrient, double level, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              nutrient,
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '${level.toStringAsFixed(1)}%',
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        SizedBox(height: 0.5.h),
        LinearProgressIndicator(
          value: level / 100,
          backgroundColor: AppTheme.neutralLight.withValues(alpha: 0.3),
          valueColor: AlwaysStoppedAnimation<Color>(color),
          minHeight: 6,
        ),
      ],
    );
  }

  Color _getNutrientColor(double level) {
    if (level < 30) return AppTheme.errorLight;
    if (level < 60) return AppTheme.warningLight;
    return AppTheme.successLight;
  }

  Color _getOverallHealthColor() {
    final nitrogen = (soilData['nitrogen'] as num).toDouble();
    final phosphorus = (soilData['phosphorus'] as num).toDouble();
    final potassium = (soilData['potassium'] as num).toDouble();
    final average = (nitrogen + phosphorus + potassium) / 3;

    if (average < 40) return AppTheme.errorLight;
    if (average < 70) return AppTheme.warningLight;
    return AppTheme.successLight;
  }

  String _getOverallHealthText() {
    final nitrogen = (soilData['nitrogen'] as num).toDouble();
    final phosphorus = (soilData['phosphorus'] as num).toDouble();
    final potassium = (soilData['potassium'] as num).toDouble();
    final average = (nitrogen + phosphorus + potassium) / 3;

    if (average < 40) {
      return 'Soil requires immediate nutrient supplementation for optimal crop growth.';
    } else if (average < 70) {
      return 'Soil health is moderate. Consider targeted fertilizer applications.';
    } else {
      return 'Excellent soil health! Maintain current nutrient levels with balanced fertilization.';
    }
  }
}
