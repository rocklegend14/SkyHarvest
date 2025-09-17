import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:intl/intl.dart';

class ProfileStatisticsCard extends StatelessWidget {
  final Map<String, dynamic> statistics;

  const ProfileStatisticsCard({super.key, required this.statistics});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Farm Overview',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            SizedBox(height: 20),

            // First Row
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    'Total Fields',
                    statistics['total_fields']?.toString() ?? '0',
                    Icons.landscape,
                    Colors.green[600]!,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _buildStatItem(
                    'Farm Area',
                    '${(statistics['total_farm_area'] ?? 0.0).toStringAsFixed(1)} acres',
                    Icons.agriculture,
                    Colors.brown[600]!,
                  ),
                ),
              ],
            ),

            SizedBox(height: 12),

            // Second Row
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    'Recommendations',
                    statistics['total_recommendations']?.toString() ?? '0',
                    Icons.lightbulb,
                    Colors.orange[600]!,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _buildStatItem(
                    'Unread Alerts',
                    statistics['unread_alerts']?.toString() ?? '0',
                    Icons.notification_important,
                    statistics['unread_alerts'] != null &&
                            statistics['unread_alerts'] > 0
                        ? Colors.red[600]!
                        : Colors.grey[600]!,
                  ),
                ),
              ],
            ),

            SizedBox(height: 16),

            // Account Created
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.person_add, color: Colors.blue[600], size: 24),
                  SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Member Since',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.blue[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        statistics['account_created'] != null
                            ? DateFormat('MMM dd, yyyy').format(
                              DateTime.parse(
                                statistics['account_created'].toString(),
                              ),
                            )
                            : 'Unknown',
                        style: TextStyle(
                          fontSize: 16.sp,
                          color: Colors.blue[800],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
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
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withAlpha(26),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withAlpha(77)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12.sp,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
