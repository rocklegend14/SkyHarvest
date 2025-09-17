import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class WeatherImpactCard extends StatelessWidget {
  final Map<String, dynamic> weatherData;

  const WeatherImpactCard({
    Key? key,
    required this.weatherData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final temperature =
        (weatherData['temperature'] as List? ?? []).cast<double>();
    final rainfall = (weatherData['rainfall'] as List? ?? []).cast<double>();
    final humidity = weatherData['humidity'] ?? 0.0;
    final weatherImpact = weatherData['impact'] ?? 'Neutral';

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
                iconName: 'wb_sunny',
                color: AppTheme.warningLight,
                size: 6.w,
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Text(
                  'Weather Impact Analysis',
                  style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: 3.h),
          _buildWeatherMetrics(humidity, weatherImpact),
          SizedBox(height: 3.h),
          if (temperature.isNotEmpty) _buildTemperatureChart(temperature),
          SizedBox(height: 2.h),
          if (rainfall.isNotEmpty) _buildRainfallChart(rainfall),
        ],
      ),
    );
  }

  Widget _buildWeatherMetrics(double humidity, String impact) {
    Color impactColor = impact == 'Positive'
        ? AppTheme.successLight
        : impact == 'Negative'
            ? AppTheme.errorLight
            : AppTheme.warningLight;

    return Row(
      children: [
        Expanded(
          child: _buildMetricCard(
            'Humidity',
            '${humidity.toInt()}%',
            CustomIconWidget(
              iconName: 'water_drop',
              color: AppTheme.accentLight,
              size: 5.w,
            ),
          ),
        ),
        SizedBox(width: 3.w),
        Expanded(
          child: _buildMetricCard(
            'Impact',
            impact,
            CustomIconWidget(
              iconName: impact == 'Positive'
                  ? 'trending_up'
                  : impact == 'Negative'
                      ? 'trending_down'
                      : 'trending_flat',
              color: impactColor,
              size: 5.w,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMetricCard(String label, String value, Widget icon) {
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.2),
        ),
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
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildTemperatureChart(List<double> temperature) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Temperature Trend (°C)',
          style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 2.h),
        Container(
          width: double.infinity,
          height: 25.h,
          child: LineChart(
            LineChartData(
              gridData: FlGridData(show: false),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 10.w,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        '${value.toInt()}°',
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
                      return Text(
                        'Day ${value.toInt() + 1}',
                        style: AppTheme.lightTheme.textTheme.bodySmall,
                      );
                    },
                  ),
                ),
                topTitles:
                    AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles:
                    AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              borderData: FlBorderData(show: false),
              lineBarsData: [
                LineChartBarData(
                  spots: temperature
                      .asMap()
                      .entries
                      .map((entry) => FlSpot(entry.key.toDouble(), entry.value))
                      .toList(),
                  isCurved: true,
                  color: AppTheme.warningLight,
                  barWidth: 3,
                  dotData: FlDotData(show: false),
                  belowBarData: BarAreaData(
                    show: true,
                    color: AppTheme.warningLight.withValues(alpha: 0.1),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRainfallChart(List<double> rainfall) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Rainfall Forecast (mm)',
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
                    reservedSize: 10.w,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        '${value.toInt()}mm',
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
                      return Text(
                        'Day ${value.toInt() + 1}',
                        style: AppTheme.lightTheme.textTheme.bodySmall,
                      );
                    },
                  ),
                ),
                topTitles:
                    AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles:
                    AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              borderData: FlBorderData(show: false),
              barGroups: rainfall
                  .asMap()
                  .entries
                  .map((entry) => BarChartGroupData(
                        x: entry.key,
                        barRods: [
                          BarChartRodData(
                            toY: entry.value,
                            color: AppTheme.accentLight,
                            width: 4.w,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ],
                      ))
                  .toList(),
            ),
          ),
        ),
      ],
    );
  }
}
