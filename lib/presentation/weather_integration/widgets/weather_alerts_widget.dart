import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../../../widgets/custom_icon_widget.dart';

class WeatherAlertsWidget extends StatelessWidget {
  final List<Map<String, dynamic>> alerts;

  const WeatherAlertsWidget({super.key, required this.alerts});

  @override
  Widget build(BuildContext context) {
    if (alerts.isEmpty) {
      return SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        child: Container(
          width: double.infinity,
          height: MediaQuery.of(context).size.height * 0.6,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.check_circle, size: 80, color: Colors.green[400]),
              SizedBox(height: 20),
              Text(
                'No weather alerts',
                style: TextStyle(
                  fontSize: 18.sp,
                  color: Colors.green[600],
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Weather conditions are favorable',
                style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: alerts.length,
      itemBuilder: (context, index) {
        final alert = alerts[index];
        return _buildAlertCard(alert);
      },
    );
  }

  Widget _buildAlertCard(Map<String, dynamic> alert) {
    final priority = alert['priority'] ?? 'medium';
    final alertType = alert['type'] ?? 'general';

    return Card(
      margin: EdgeInsets.only(bottom: 12),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _getPriorityColor(priority), width: 2),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Alert Header
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _getPriorityColor(priority).withAlpha(26),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getAlertIcon(alertType),
                    color: _getPriorityColor(priority),
                    size: 24,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        alert['title'] ?? 'Weather Alert',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                      SizedBox(height: 4),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _getPriorityColor(priority),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _getPriorityLabel(priority),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            SizedBox(height: 16),

            // Alert Description
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                alert['description'] ?? 'No description available',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.grey[700],
                  height: 1.4,
                ),
              ),
            ),

            SizedBox(height: 16),

            // Recommendations (if available)
            if (alert['recommendations'] != null) ...[
              Text(
                'Recommendations:',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
              SizedBox(height: 8),
              ...List<Widget>.from(
                (alert['recommendations'] as List<String>).map(
                  (rec) => Padding(
                    padding: EdgeInsets.only(bottom: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '• ',
                          style: TextStyle(color: _getPriorityColor(priority)),
                        ),
                        Expanded(
                          child: Text(
                            rec,
                            style: TextStyle(
                              fontSize: 13.sp,
                              color: Colors.grey[700],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],

            // Action Buttons
            if (priority == 'critical' || priority == 'high') ...[
              SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        // Handle acknowledge action
                      },
                      icon: Icon(Icons.check, size: 16),
                      label: Text('Acknowledge'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: _getPriorityColor(priority),
                        side: BorderSide(color: _getPriorityColor(priority)),
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // Handle view details action
                      },
                      icon: Icon(Icons.info_outline, size: 16),
                      label: Text('Details'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _getPriorityColor(priority),
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'critical':
        return Colors.red[600]!;
      case 'high':
        return Colors.orange[600]!;
      case 'medium':
        return Colors.yellow[700]!;
      case 'low':
        return Colors.blue[600]!;
      default:
        return Colors.grey[600]!;
    }
  }

  String _getPriorityLabel(String priority) {
    switch (priority) {
      case 'critical':
        return 'CRITICAL';
      case 'high':
        return 'HIGH';
      case 'medium':
        return 'MEDIUM';
      case 'low':
        return 'LOW';
      default:
        return 'UNKNOWN';
    }
  }

  IconData _getAlertIcon(String alertType) {
    switch (alertType) {
      case 'heavy_rain':
        return Icons.umbrella;
      case 'high_wind':
        return Icons.air;
      case 'frost':
        return Icons.ac_unit;
      case 'storm':
        return Icons.thunderstorm;
      case 'hail':
        return Icons.grain;
      default:
        return Icons.warning;
    }
  }
}
