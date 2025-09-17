import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class SoilAnalysisCard extends StatelessWidget {
  final Map<String, dynamic> soilData;

  const SoilAnalysisCard({
    Key? key,
    required this.soilData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final phLevel = soilData['phLevel'] ?? 7.0;
    final nitrogen = soilData['nitrogen'] ?? 0.0;
    final phosphorus = soilData['phosphorus'] ?? 0.0;
    final potassium = soilData['potassium'] ?? 0.0;
    final moisture = soilData['moisture'] ?? 0.0;
    final healthStatus = soilData['healthStatus'] ?? 'Good';

    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color:
                AppTheme.lightTheme.colorScheme.shadow.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomIconWidget(
                iconName: 'terrain',
                color: AppTheme.soilHealthGood,
                size: 6.w,
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Text(
                  'Soil Analysis',
                  style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: 3.h),
          _buildHealthStatusCard(healthStatus),
          SizedBox(height: 3.h),
          _buildSoilMetrics(phLevel, moisture),
          SizedBox(height: 3.h),
          _buildNutrientChart(nitrogen, phosphorus, potassium),
        ],
      ),
    );
  }

  Widget _buildHealthStatusCard(String healthStatus) {
    Color statusColor = healthStatus == 'Excellent'
        ? AppTheme.soilHealthGood
        : healthStatus == 'Good'
            ? AppTheme.soilHealthGood
            : healthStatus == 'Moderate'
                ? AppTheme.soilHealthModerate
                : AppTheme.soilHealthPoor;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: statusColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          CustomIconWidget(
            iconName: healthStatus == 'Excellent' || healthStatus == 'Good'
                ? 'check_circle'
                : healthStatus == 'Moderate'
                    ? 'warning'
                    : 'error',
            color: statusColor,
            size: 6.w,
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Soil Health Status',
                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 0.5.h),
                Text(
                  healthStatus,
                  style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSoilMetrics(double phLevel, double moisture) {
    Color phColor = phLevel >= 6.0 && phLevel <= 7.5
        ? AppTheme.soilHealthGood
        : AppTheme.soilHealthModerate;

    Color moistureColor = moisture >= 40 && moisture <= 60
        ? AppTheme.moistureOptimal
        : moisture < 40
            ? AppTheme.moistureLow
            : AppTheme.moistureHigh;

    return Row(
      children: [
        Expanded(
          child: _buildMetricCard(
            'pH Level',
            phLevel.toStringAsFixed(1),
            CustomIconWidget(
              iconName: 'science',
              color: phColor,
              size: 5.w,
            ),
            phColor,
          ),
        ),
        SizedBox(width: 3.w),
        Expanded(
          child: _buildMetricCard(
            'Moisture',
            '${moisture.toInt()}%',
            CustomIconWidget(
              iconName: 'water_drop',
              color: moistureColor,
              size: 5.w,
            ),
            moistureColor,
          ),
        ),
      ],
    );
  }

  Widget _buildMetricCard(
      String label, String value, Widget icon, Color color) {
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        border: Border.all(color: color.withValues(alpha: 0.2)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          icon,
          SizedBox(height: 1.h),
          Text(
            label,
            style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 0.5.h),
          Text(
            value,
            style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: color,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildNutrientChart(
      double nitrogen, double phosphorus, double potassium) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Nutrient Levels (ppm)',
          style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 2.h),
        Container(
          width: double.infinity,
          height: 25.h,
          child: BarChart(
            BarChartData(
              gridData: FlGridData(show: false),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 12.w,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        '${value.toInt()}',
                        style: AppTheme.lightTheme.textTheme.bodySmall,
                      );
                    },
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 4.h,
                    getTitlesWidget: (value, meta) {
                      switch (value.toInt()) {
                        case 0:
                          return Text(
                            'N',
                            style: AppTheme.lightTheme.textTheme.bodyMedium
                                ?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          );
                        case 1:
                          return Text(
                            'P',
                            style: AppTheme.lightTheme.textTheme.bodyMedium
                                ?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          );
                        case 2:
                          return Text(
                            'K',
                            style: AppTheme.lightTheme.textTheme.bodyMedium
                                ?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          );
                        default:
                          return Text('');
                      }
                    },
                  ),
                ),
                topTitles:
                    AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles:
                    AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              borderData: FlBorderData(show: false),
              barGroups: [
                BarChartGroupData(
                  x: 0,
                  barRods: [
                    BarChartRodData(
                      toY: nitrogen,
                      color: AppTheme.lightTheme.colorScheme.primary,
                      width: 8.w,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ],
                ),
                BarChartGroupData(
                  x: 1,
                  barRods: [
                    BarChartRodData(
                      toY: phosphorus,
                      color: AppTheme.lightTheme.colorScheme.secondary,
                      width: 8.w,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ],
                ),
                BarChartGroupData(
                  x: 2,
                  barRods: [
                    BarChartRodData(
                      toY: potassium,
                      color: AppTheme.accentLight,
                      width: 8.w,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 2.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildNutrientLegend(
                'Nitrogen', AppTheme.lightTheme.colorScheme.primary),
            _buildNutrientLegend(
                'Phosphorus', AppTheme.lightTheme.colorScheme.secondary),
            _buildNutrientLegend('Potassium', AppTheme.accentLight),
          ],
        ),
      ],
    );
  }

  Widget _buildNutrientLegend(String nutrient, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 3.w,
          height: 3.w,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(1.5.w),
          ),
        ),
        SizedBox(width: 1.w),
        Text(
          nutrient,
          style: AppTheme.lightTheme.textTheme.bodySmall,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
