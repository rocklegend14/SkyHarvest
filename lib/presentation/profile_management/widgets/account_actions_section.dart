import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sizer/sizer.dart';

import '../../../models/user_profile.dart';
import '../../../services/profile_service.dart';
import '../../../services/settings_service.dart';
import './change_password_dialog.dart';
import 'change_password_dialog.dart';

class AccountActionsSection extends StatefulWidget {
  final UserProfile? profile;
  final VoidCallback onProfileUpdated;

  const AccountActionsSection({
    super.key,
    required this.profile,
    required this.onProfileUpdated,
  });

  @override
  State<AccountActionsSection> createState() => _AccountActionsSectionState();
}

class _AccountActionsSectionState extends State<AccountActionsSection> {
  final ProfileService _profileService = ProfileService();
  final SettingsService _settingsService = SettingsService();

  bool _isExporting = false;
  bool _isClearingData = false;

  void _showChangePasswordDialog() {
    showDialog(context: context, builder: (context) => ChangePasswordDialog());
  }

  Future<void> _exportUserData() async {
    setState(() => _isExporting = true);
    try {
      final data = await _settingsService.exportUserData();

      // Convert data to JSON string
      final jsonString = json.encode(data);

      // Save to device
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/farm_data_export.json');
      await file.writeAsString(jsonString);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Data exported successfully to ${file.path}'),
          duration: Duration(seconds: 3),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error exporting data: $e')));
    } finally {
      setState(() => _isExporting = false);
    }
  }

  Future<void> _clearUserData() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Clear All Data'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('This will permanently delete:'),
                SizedBox(height: 8),
                Text('• All your fields'),
                Text('• All fertilizer recommendations'),
                Text('• All alerts and notifications'),
                Text('• Reset settings to default'),
                SizedBox(height: 16),
                Text(
                  'Your profile information will be kept. This action cannot be undone.',
                  style: TextStyle(
                    color: Colors.red[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text(
                  'Clear Data',
                  style: TextStyle(color: Colors.red[600]),
                ),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      setState(() => _isClearingData = true);
      try {
        await _settingsService.clearUserData();
        widget.onProfileUpdated();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('User data cleared successfully')),
        );
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error clearing data: $e')));
      } finally {
        setState(() => _isClearingData = false);
      }
    }
  }

  Future<void> _deleteAccount() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Delete Account'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'This will permanently delete your account and all associated data.',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                SizedBox(height: 16),
                Text(
                  'This action cannot be undone!',
                  style: TextStyle(
                    color: Colors.red[600],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text(
                  'Delete Account',
                  style: TextStyle(color: Colors.red[600]),
                ),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      try {
        await _profileService.deleteAccount();
        Navigator.of(context).pushReplacementNamed('/login-screen');
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error deleting account: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Security Section
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Security',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  SizedBox(height: 16),

                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.blue[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.lock, color: Colors.blue[600]),
                    ),
                    title: Text(
                      'Change Password',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(
                      'Update your account password',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey[600],
                      ),
                    ),
                    trailing: Icon(Icons.chevron_right),
                    onTap: _showChangePasswordDialog,
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 20),

          // Data Management Section
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Data Management',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  SizedBox(height: 16),

                  // Export Data
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.green[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.download, color: Colors.green[600]),
                    ),
                    title: Text(
                      'Export Data',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(
                      'Download your data as JSON file',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey[600],
                      ),
                    ),
                    trailing:
                        _isExporting
                            ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                            : Icon(Icons.chevron_right),
                    onTap: _isExporting ? null : _exportUserData,
                  ),

                  Divider(height: 32),

                  // Clear Data
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.orange[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.cleaning_services,
                        color: Colors.orange[600],
                      ),
                    ),
                    title: Text(
                      'Clear All Data',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(
                      'Delete fields, recommendations, and alerts',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey[600],
                      ),
                    ),
                    trailing:
                        _isClearingData
                            ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                            : Icon(
                              Icons.chevron_right,
                              color: Colors.orange[600],
                            ),
                    onTap: _isClearingData ? null : _clearUserData,
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 20),

          // Danger Zone
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red[200]!),
              ),
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.warning, color: Colors.red[600], size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Danger Zone',
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.red[600],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),

                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.red[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.delete_forever,
                          color: Colors.red[600],
                        ),
                      ),
                      title: Text(
                        'Delete Account',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.red[600],
                        ),
                      ),
                      subtitle: Text(
                        'Permanently delete your account and all data',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.red[500],
                        ),
                      ),
                      trailing: Icon(
                        Icons.chevron_right,
                        color: Colors.red[600],
                      ),
                      onTap: _deleteAccount,
                    ),
                  ],
                ),
              ),
            ),
          ),

          SizedBox(height: 40),
        ],
      ),
    );
  }
}
