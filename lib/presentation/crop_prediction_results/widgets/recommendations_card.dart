import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class RecommendationsCard extends StatelessWidget {
  final List<Map<String, dynamic>> recommendations;
  final VoidCallback onSetReminder;

  const RecommendationsCard({
    Key? key,
    required this.recommendations,
    required this.onSetReminder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
                iconName: 'lightbulb',
                color: AppTheme.warningLight,
                size: 6.w,
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Text(
                  'AI Recommendations',
                  style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: 3.h),
          ListView.separated(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: recommendations.length,
            separatorBuilder: (context, index) => SizedBox(height: 2.h),
            itemBuilder: (context, index) {
              final recommendation = recommendations[index];
              return _buildRecommendationItem(context, recommendation);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationItem(
      BuildContext context, Map<String, dynamic> recommendation) {
    final type = recommendation['type'] ?? 'general';
    final title = recommendation['title'] ?? 'Recommendation';
    final description =
        recommendation['description'] ?? 'No description available';
    final priority = recommendation['priority'] ?? 'medium';
    final timing = recommendation['timing'] ?? 'Anytime';

    Color priorityColor = priority == 'high'
        ? AppTheme.errorLight
        : priority == 'medium'
            ? AppTheme.warningLight
            : AppTheme.successLight;

    IconData typeIcon = _getTypeIcon(type);

    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: priorityColor.withValues(alpha: 0.05),
        border: Border.all(color: priorityColor.withValues(alpha: 0.2)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(2.w),
                decoration: BoxDecoration(
                  color: priorityColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: CustomIconWidget(
                  iconName: _getIconName(typeIcon),
                  color: priorityColor,
                  size: 5.w,
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: AppTheme.lightTheme.textTheme.titleMedium
                                ?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        _buildPriorityBadge(priority, priorityColor),
                      ],
                    ),
                    SizedBox(height: 0.5.h),
                    Text(
                      timing,
                      style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Text(
            description,
            style: AppTheme.lightTheme.textTheme.bodyMedium,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 2.h),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onSetReminder,
                  icon: CustomIconWidget(
                    iconName: 'alarm',
                    color: AppTheme.lightTheme.colorScheme.primary,
                    size: 4.w,
                  ),
                  label: Text(
                    'Set Reminder',
                    style: AppTheme.lightTheme.textTheme.labelMedium,
                    overflow: TextOverflow.ellipsis,
                  ),
                  style: OutlinedButton.styleFrom(
                    padding:
                        EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.5.h),
                  ),
                ),
              ),
              SizedBox(width: 2.w),
              IconButton(
                onPressed: () =>
                    _showRecommendationDetails(context, recommendation),
                icon: CustomIconWidget(
                  iconName: 'info',
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  size: 5.w,
                ),
                style: IconButton.styleFrom(
                  backgroundColor: AppTheme.lightTheme.colorScheme.surface,
                  side: BorderSide(
                    color: AppTheme.lightTheme.colorScheme.outline
                        .withValues(alpha: 0.2),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPriorityBadge(String priority, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        priority.toUpperCase(),
        style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  IconData _getTypeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'irrigation':
        return Icons.water_drop;
      case 'fertilizer':
        return Icons.eco;
      case 'pest':
        return Icons.bug_report;
      case 'harvest':
        return Icons.agriculture;
      case 'planting':
        return Icons.grass;
      default:
        return Icons.lightbulb;
    }
  }

  String _getIconName(IconData iconData) {
    if (iconData == Icons.water_drop) return 'water_drop';
    if (iconData == Icons.eco) return 'eco';
    if (iconData == Icons.bug_report) return 'bug_report';
    if (iconData == Icons.agriculture) return 'agriculture';
    if (iconData == Icons.grass) return 'grass';
    return 'lightbulb';
  }

  void _showRecommendationDetails(
      BuildContext context, Map<String, dynamic> recommendation) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            recommendation['title'] ?? 'Recommendation Details',
            style: AppTheme.lightTheme.textTheme.titleLarge,
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Description:',
                  style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 1.h),
                Text(
                  recommendation['description'] ?? 'No description available',
                  style: AppTheme.lightTheme.textTheme.bodyMedium,
                ),
                SizedBox(height: 2.h),
                Text(
                  'Timing:',
                  style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 1.h),
                Text(
                  recommendation['timing'] ?? 'Anytime',
                  style: AppTheme.lightTheme.textTheme.bodyMedium,
                ),
                if (recommendation['additionalInfo'] != null) ...[
                  SizedBox(height: 2.h),
                  Text(
                    'Additional Information:',
                    style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 1.h),
                  Text(
                    recommendation['additionalInfo'],
                    style: AppTheme.lightTheme.textTheme.bodyMedium,
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Close',
                style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.primary,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
