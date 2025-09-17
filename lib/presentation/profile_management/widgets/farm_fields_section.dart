import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../models/fertilizer_recommendation.dart';
import '../../../services/profile_service.dart';
import '../../../widgets/custom_icon_widget.dart';
import './add_field_dialog.dart';
import './field_card_widget.dart';
import 'add_field_dialog.dart';
import 'field_card_widget.dart';

class FarmFieldsSection extends StatefulWidget {
  final List<Map<String, dynamic>> fields;
  final VoidCallback onFieldsChanged;

  const FarmFieldsSection({
    super.key,
    required this.fields,
    required this.onFieldsChanged,
  });

  @override
  State<FarmFieldsSection> createState() => _FarmFieldsSectionState();
}

class _FarmFieldsSectionState extends State<FarmFieldsSection> {
  final ProfileService _profileService = ProfileService();

  void _showAddFieldDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AddFieldDialog(onFieldAdded: widget.onFieldsChanged),
    );
  }

  Future<void> _deleteField(String fieldId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Delete Field'),
            content: Text(
              'Are you sure you want to delete this field? This action cannot be undone.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text('Delete', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      try {
        await _profileService.deleteField(fieldId);
        widget.onFieldsChanged();
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Field deleted successfully')));
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error deleting field: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          // Header with Add Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Farm Fields (${widget.fields.length})',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              ElevatedButton.icon(
                onPressed: _showAddFieldDialog,
                icon: Icon(Icons.add, color: Colors.white),
                label: Text('Add Field', style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[600],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 20),

          // Fields List
          if (widget.fields.isEmpty)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CustomIconWidget(
                      iconPath: 'assets/images/sad_face.svg',
                      height: 80,
                      width: 80,
                    ),
                    SizedBox(height: 20),
                    Text(
                      'No fields added yet',
                      style: TextStyle(
                        fontSize: 18.sp,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Add your first field to get started',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.grey[500],
                      ),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: _showAddFieldDialog,
                      icon: Icon(Icons.add, color: Colors.white),
                      label: Text(
                        'Add Your First Field',
                        style: TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[600],
                        padding: EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                itemCount: widget.fields.length,
                itemBuilder: (context, index) {
                  final field = widget.fields[index];
                  return FieldCardWidget(
                    field: field,
                    onDelete: () => _deleteField(field['id']),
                    onFieldUpdated: widget.onFieldsChanged,
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
