import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../../../models/fertilizer_recommendation.dart';
import 'package:intl/intl.dart';

class RecommendationCardWidget extends StatelessWidget {
  final FertilizerRecommendation recommendation;
  final Function(String id, String newStatus) onStatusChanged;
  final Function(String id) onDelete;

  const RecommendationCardWidget({
    super.key,
    required this.recommendation,
    required this.onStatusChanged,
    required this.onDelete,
  });

  Color _getStatusColor() {
    switch (recommendation.status) {
      case 'pending':
        return Colors.orange[600]!;
      case 'applied':
        return Colors.green[600]!;
      case 'cancelled':
        return Colors.red[600]!;
      default:
        return Colors.grey[600]!;
    }
  }

  IconData _getStatusIcon() {
    switch (recommendation.status) {
      case 'pending':
        return Icons.schedule;
      case 'applied':
        return Icons.check_circle;
      case 'cancelled':
        return Icons.cancel;
      default:
        return Icons.help;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        recommendation.field?.name ?? 'Unknown Field',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        recommendation.fertilizerTypeDisplay,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.green[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getStatusColor().withAlpha(26),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: _getStatusColor()),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _getStatusIcon(),
                        size: 16,
                        color: _getStatusColor(),
                      ),
                      SizedBox(width: 4),
                      Text(
                        recommendation.statusDisplay,
                        style: TextStyle(
                          color: _getStatusColor(),
                          fontWeight: FontWeight.w500,
                          fontSize: 12.sp,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            SizedBox(height: 16),

            // Details Grid
            Row(
              children: [
                Expanded(
                  child: _buildDetailItem(
                    'Amount',
                    '${recommendation.recommendedAmount} kg/acre',
                    Icons.agriculture,
                  ),
                ),
                Expanded(
                  child: _buildDetailItem(
                    'Cost',
                    recommendation.costEstimate != null
                        ? '\$${recommendation.costEstimate!.toStringAsFixed(2)}'
                        : 'N/A',
                    Icons.monetization_on,
                  ),
                ),
              ],
            ),

            SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _buildDetailItem(
                    'Application Date',
                    DateFormat(
                      'MMM dd, yyyy',
                    ).format(recommendation.applicationDate),
                    Icons.calendar_today,
                  ),
                ),
                Expanded(
                  child: _buildDetailItem(
                    'Method',
                    recommendation.applicationMethod ?? 'Not specified',
                    Icons.build,
                  ),
                ),
              ],
            ),

            if (recommendation.notes != null &&
                recommendation.notes!.isNotEmpty) ...[
              SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Notes',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      recommendation.notes!,
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ),
            ],

            SizedBox(height: 16),

            // Action Buttons
            Row(
              children: [
                if (recommendation.status == 'pending') ...[
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed:
                          () => onStatusChanged(recommendation.id, 'applied'),
                      icon: Icon(
                        Icons.check,
                        size: 16,
                        color: Colors.green[600],
                      ),
                      label: Text(
                        'Mark Applied',
                        style: TextStyle(color: Colors.green[600]),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.green[600]!),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed:
                          () => onStatusChanged(recommendation.id, 'cancelled'),
                      icon: Icon(Icons.close, size: 16, color: Colors.red[600]),
                      label: Text(
                        'Cancel',
                        style: TextStyle(color: Colors.red[600]),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.red[600]!),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ] else ...[
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => onDelete(recommendation.id),
                      icon: Icon(
                        Icons.delete,
                        size: 16,
                        color: Colors.red[600],
                      ),
                      label: Text(
                        'Delete',
                        style: TextStyle(color: Colors.red[600]),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.red[600]!),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(String label, String value, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: Colors.grey[600]),
            SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11.sp,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 13.sp,
            color: Colors.grey[800],
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
