import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class PredictionOverviewCard extends StatelessWidget {
  final Map<String, dynamic> predictionData;

  const PredictionOverviewCard({
    Key? key,
    required this.predictionData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final yieldEstimate = predictionData['yieldEstimate'] ?? 0.0;
    final harvestDate = predictionData['harvestDate'] ?? 'Not available';
    final confidence = predictionData['confidence'] ?? 0.0;
    final cropType = predictionData['cropType'] ?? 'Unknown';

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
                iconName: 'agriculture',
                color: AppTheme.lightTheme.primaryColor,
                size: 6.w,
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Text(
                  'Prediction Overview',
                  style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: 3.h),
          _buildMetricRow(
            'Crop Type',
            cropType,
            CustomIconWidget(
              iconName: 'eco',
              color: AppTheme.lightTheme.colorScheme.primary,
              size: 5.w,
            ),
          ),
          SizedBox(height: 2.h),
          _buildMetricRow(
            'Expected Yield',
            '${yieldEstimate.toStringAsFixed(1)} tons/hectare',
            CustomIconWidget(
              iconName: 'trending_up',
              color: AppTheme.successLight,
              size: 5.w,
            ),
          ),
          SizedBox(height: 2.h),
          _buildMetricRow(
            'Harvest Date',
            harvestDate,
            CustomIconWidget(
              iconName: 'calendar_today',
              color: AppTheme.lightTheme.colorScheme.secondary,
              size: 5.w,
            ),
          ),
          SizedBox(height: 2.h),
          _buildConfidenceIndicator(confidence),
        ],
      ),
    );
  }

  Widget _buildMetricRow(String label, String value, Widget icon) {
    return Row(
      children: [
        icon,
        SizedBox(width: 3.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildConfidenceIndicator(double confidence) {
    Color confidenceColor = confidence >= 0.8
        ? AppTheme.successLight
        : confidence >= 0.6
            ? AppTheme.warningLight
            : AppTheme.errorLight;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CustomIconWidget(
              iconName: 'verified',
              color: confidenceColor,
              size: 5.w,
            ),
            SizedBox(width: 3.w),
            Text(
              'Prediction Confidence',
              style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        SizedBox(height: 1.h),
        Container(
          width: double.infinity,
          height: 1.h,
          decoration: BoxDecoration(
            color:
                AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(0.5.h),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: confidence,
            child: Container(
              decoration: BoxDecoration(
                color: confidenceColor,
                borderRadius: BorderRadius.circular(0.5.h),
              ),
            ),
          ),
        ),
        SizedBox(height: 0.5.h),
        Text(
          '${(confidence * 100).toInt()}% confidence',
          style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
            color: confidenceColor,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
