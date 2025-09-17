import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class StatisticsCardWidget extends StatelessWidget {
  final Map<String, dynamic> statistics;

  const StatisticsCardWidget({super.key, required this.statistics});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Fertilizer Overview',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    'Total',
                    statistics['total_recommendations']?.toString() ?? '0',
                    Icons.list_alt,
                    Colors.blue[600]!,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    'Pending',
                    statistics['pending_applications']?.toString() ?? '0',
                    Icons.schedule,
                    Colors.orange[600]!,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    'Applied',
                    statistics['applied_recommendations']?.toString() ?? '0',
                    Icons.check_circle,
                    Colors.green[600]!,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    'Total Cost',
                    '\$${(statistics['total_cost'] ?? 0.0).toStringAsFixed(2)}',
                    Icons.monetization_on,
                    Colors.purple[600]!,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withAlpha(26),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}
