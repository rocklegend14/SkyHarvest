import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../../../models/user_profile.dart';
import 'package:intl/intl.dart';

class ProfileInfoSection extends StatelessWidget {
  final UserProfile profile;

  const ProfileInfoSection({super.key, required this.profile});

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
              'Personal Information',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            SizedBox(height: 20),

            // Contact Information
            _buildInfoRow(
              'Email',
              profile.email,
              Icons.email,
              Colors.blue[600]!,
            ),

            if (profile.phone != null)
              _buildInfoRow(
                'Phone',
                profile.phone!,
                Icons.phone,
                Colors.green[600]!,
              ),

            SizedBox(height: 16),
            Divider(),
            SizedBox(height: 16),

            // Farm Information
            Text(
              'Farm Information',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            SizedBox(height: 12),

            if (profile.farmName != null)
              _buildInfoRow(
                'Farm Name',
                profile.farmName!,
                Icons.agriculture,
                Colors.brown[600]!,
              ),

            if (profile.farmLocation != null)
              _buildInfoRow(
                'Location',
                profile.farmLocation!,
                Icons.location_on,
                Colors.red[600]!,
              ),

            if (profile.totalAreaAcres != null)
              _buildInfoRow(
                'Total Area',
                '${profile.totalAreaAcres!.toStringAsFixed(1)} acres',
                Icons.landscape,
                Colors.green[700]!,
              ),

            _buildInfoRow(
              'Role',
              profile.roleDisplay,
              Icons.person,
              Colors.purple[600]!,
            ),

            SizedBox(height: 16),
            Divider(),
            SizedBox(height: 16),

            // Account Information
            Text(
              'Account Information',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            SizedBox(height: 12),

            _buildInfoRow(
              'Member Since',
              DateFormat('MMM dd, yyyy').format(profile.createdAt),
              Icons.calendar_today,
              Colors.indigo[600]!,
            ),

            _buildInfoRow(
              'Last Updated',
              DateFormat('MMM dd, yyyy HH:mm').format(profile.updatedAt),
              Icons.update,
              Colors.orange[600]!,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon, Color color) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withAlpha(26),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.grey[800],
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
