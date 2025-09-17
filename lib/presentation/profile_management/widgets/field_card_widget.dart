import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';

import '../../../models/fertilizer_recommendation.dart';

class FieldCardWidget extends StatelessWidget {
  final Map<String, dynamic> field;
  final VoidCallback onDelete;
  final VoidCallback onFieldUpdated;

  const FieldCardWidget({
    super.key,
    required this.field,
    required this.onDelete,
    required this.onFieldUpdated,
  });

  String _formatDate(String? dateString) {
    if (dateString == null) return 'Not set';
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('MMM dd, yyyy').format(date);
    } catch (e) {
      return 'Invalid date';
    }
  }

  String _getCropTypeDisplay(String cropType) {
    switch (cropType) {
      case 'wheat':
        return 'Wheat';
      case 'corn':
        return 'Corn';
      case 'rice':
        return 'Rice';
      case 'soybeans':
        return 'Soybeans';
      case 'cotton':
        return 'Cotton';
      case 'vegetables':
        return 'Vegetables';
      case 'fruits':
        return 'Fruits';
      case 'other':
        return 'Other';
      default:
        return cropType;
    }
  }

  String _getSoilTypeDisplay(String soilType) {
    switch (soilType) {
      case 'clay':
        return 'Clay';
      case 'loam':
        return 'Loam';
      case 'sand':
        return 'Sand';
      case 'silt':
        return 'Silt';
      case 'rocky':
        return 'Rocky';
      default:
        return soilType;
    }
  }

  IconData _getCropIcon(String cropType) {
    switch (cropType) {
      case 'wheat':
        return Icons.grass;
      case 'corn':
        return Icons.agriculture;
      case 'rice':
        return Icons.grass;
      case 'soybeans':
        return Icons.eco;
      case 'cotton':
        return Icons.local_florist;
      case 'vegetables':
        return Icons.park;
      case 'fruits':
        return Icons.apple;
      default:
        return Icons.landscape;
    }
  }

  Color _getCropColor(String cropType) {
    switch (cropType) {
      case 'wheat':
        return Colors.amber[700]!;
      case 'corn':
        return Colors.yellow[700]!;
      case 'rice':
        return Colors.green[700]!;
      case 'soybeans':
        return Colors.green[600]!;
      case 'cotton':
        return Colors.grey[700]!;
      case 'vegetables':
        return Colors.lightGreen[700]!;
      case 'fruits':
        return Colors.red[600]!;
      default:
        return Colors.brown[600]!;
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
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: _getCropColor(field['crop_type']).withAlpha(26),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    _getCropIcon(field['crop_type']),
                    color: _getCropColor(field['crop_type']),
                    size: 24,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        field['name'],
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        _getCropTypeDisplay(field['crop_type']),
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: _getCropColor(field['crop_type']),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'delete') {
                      onDelete();
                    }
                  },
                  itemBuilder:
                      (context) => [
                        PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(
                                Icons.delete,
                                size: 20,
                                color: Colors.red[600],
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Delete',
                                style: TextStyle(color: Colors.red[600]),
                              ),
                            ],
                          ),
                        ),
                      ],
                ),
              ],
            ),

            SizedBox(height: 16),

            // Field Details
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildDetailItem(
                          'Area',
                          '${field['area_acres']} acres',
                          Icons.square_foot,
                          Colors.blue[600]!,
                        ),
                      ),
                      Expanded(
                        child: _buildDetailItem(
                          'Soil Type',
                          _getSoilTypeDisplay(field['soil_type']),
                          Icons.terrain,
                          Colors.brown[600]!,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildDetailItem(
                          'Planting Date',
                          _formatDate(field['planting_date']),
                          Icons.calendar_today,
                          Colors.green[600]!,
                        ),
                      ),
                      Expanded(
                        child: _buildDetailItem(
                          'Harvest Date',
                          _formatDate(field['expected_harvest_date']),
                          Icons.calendar_month,
                          Colors.orange[600]!,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Notes (if available)
            if (field['notes'] != null &&
                field['notes'].toString().isNotEmpty) ...[
              SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.note, size: 16, color: Colors.blue[700]),
                        SizedBox(width: 6),
                        Text(
                          'Notes',
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.blue[700],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 6),
                    Text(
                      field['notes'],
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: Colors.blue[800],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: color),
            SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 11.sp,
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            fontSize: 14.sp,
            color: Colors.grey[800],
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
