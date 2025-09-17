import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../models/fertilizer_recommendation.dart';
import '../../../services/profile_service.dart';

class AddFieldDialog extends StatefulWidget {
  final VoidCallback onFieldAdded;

  const AddFieldDialog({super.key, required this.onFieldAdded});

  @override
  State<AddFieldDialog> createState() => _AddFieldDialogState();
}

class _AddFieldDialogState extends State<AddFieldDialog> {
  final _formKey = GlobalKey<FormState>();
  final ProfileService _profileService = ProfileService();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _areaController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  String _selectedSoilType = 'loam';
  String _selectedCropType = 'corn';
  DateTime? _plantingDate;
  DateTime? _harvestDate;

  bool _isSubmitting = false;

  final List<Map<String, String>> _soilTypes = [
    {'value': 'clay', 'label': 'Clay'},
    {'value': 'loam', 'label': 'Loam'},
    {'value': 'sand', 'label': 'Sand'},
    {'value': 'silt', 'label': 'Silt'},
    {'value': 'rocky', 'label': 'Rocky'},
  ];

  final List<Map<String, String>> _cropTypes = [
    {'value': 'wheat', 'label': 'Wheat'},
    {'value': 'corn', 'label': 'Corn'},
    {'value': 'rice', 'label': 'Rice'},
    {'value': 'soybeans', 'label': 'Soybeans'},
    {'value': 'cotton', 'label': 'Cotton'},
    {'value': 'vegetables', 'label': 'Vegetables'},
    {'value': 'fruits', 'label': 'Fruits'},
    {'value': 'other', 'label': 'Other'},
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _areaController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectPlantingDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _plantingDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(Duration(days: 365)),
      lastDate: DateTime.now().add(Duration(days: 365)),
    );
    if (date != null) {
      setState(() => _plantingDate = date);
    }
  }

  Future<void> _selectHarvestDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate:
          _harvestDate ??
          (_plantingDate?.add(Duration(days: 120)) ??
              DateTime.now().add(Duration(days: 120))),
      firstDate: _plantingDate ?? DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 730)),
    );
    if (date != null) {
      setState(() => _harvestDate = date);
    }
  }

  Future<void> _createField() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final fieldData = {
        'name': _nameController.text.trim(),
        'area_acres': double.parse(_areaController.text.trim()),
        'soil_type': _selectedSoilType,
        'crop_type': _selectedCropType,
        'planting_date': _plantingDate?.toIso8601String().split('T')[0],
        'expected_harvest_date': _harvestDate?.toIso8601String().split('T')[0],
        'notes':
            _notesController.text.trim().isEmpty
                ? null
                : _notesController.text.trim(),
      };

      await _profileService.createField(fieldData);
      widget.onFieldAdded();
      Navigator.of(context).pop();

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Field created successfully')));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error creating field: $e')));
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: EdgeInsets.all(16),
      child: Container(
        width: double.infinity,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.green[700],
                borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Add New Field',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(Icons.close, color: Colors.white),
                  ),
                ],
              ),
            ),

            // Form
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Field Name
                      Text(
                        'Field Name',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[700],
                        ),
                      ),
                      SizedBox(height: 8),
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          hintText: 'Enter field name',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 16,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter field name';
                          }
                          return null;
                        },
                      ),

                      SizedBox(height: 20),

                      // Area
                      Text(
                        'Area (acres)',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[700],
                        ),
                      ),
                      SizedBox(height: 8),
                      TextFormField(
                        controller: _areaController,
                        keyboardType: TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Enter area in acres',
                          suffixText: 'acres',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 16,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter area';
                          }
                          final area = double.tryParse(value.trim());
                          if (area == null || area <= 0) {
                            return 'Please enter valid area';
                          }
                          return null;
                        },
                      ),

                      SizedBox(height: 20),

                      // Soil Type
                      Text(
                        'Soil Type',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[700],
                        ),
                      ),
                      SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: _selectedSoilType,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 16,
                          ),
                        ),
                        items:
                            _soilTypes.map((type) {
                              return DropdownMenuItem<String>(
                                value: type['value'],
                                child: Text(type['label']!),
                              );
                            }).toList(),
                        onChanged: (value) {
                          setState(() => _selectedSoilType = value!);
                        },
                      ),

                      SizedBox(height: 20),

                      // Crop Type
                      Text(
                        'Crop Type',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[700],
                        ),
                      ),
                      SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: _selectedCropType,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 16,
                          ),
                        ),
                        items:
                            _cropTypes.map((type) {
                              return DropdownMenuItem<String>(
                                value: type['value'],
                                child: Text(type['label']!),
                              );
                            }).toList(),
                        onChanged: (value) {
                          setState(() => _selectedCropType = value!);
                        },
                      ),

                      SizedBox(height: 20),

                      // Planting Date (Optional)
                      Text(
                        'Planting Date (Optional)',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[700],
                        ),
                      ),
                      SizedBox(height: 8),
                      InkWell(
                        onTap: _selectPlantingDate,
                        child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 16,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey[400]!),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.calendar_today,
                                size: 20,
                                color: Colors.grey[600],
                              ),
                              SizedBox(width: 8),
                              Text(
                                _plantingDate != null
                                    ? '${_plantingDate!.day}/${_plantingDate!.month}/${_plantingDate!.year}'
                                    : 'Select planting date',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color:
                                      _plantingDate != null
                                          ? Colors.grey[800]
                                          : Colors.grey[500],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      SizedBox(height: 20),

                      // Expected Harvest Date (Optional)
                      Text(
                        'Expected Harvest Date (Optional)',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[700],
                        ),
                      ),
                      SizedBox(height: 8),
                      InkWell(
                        onTap: _selectHarvestDate,
                        child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 16,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey[400]!),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.calendar_today,
                                size: 20,
                                color: Colors.grey[600],
                              ),
                              SizedBox(width: 8),
                              Text(
                                _harvestDate != null
                                    ? '${_harvestDate!.day}/${_harvestDate!.month}/${_harvestDate!.year}'
                                    : 'Select harvest date',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color:
                                      _harvestDate != null
                                          ? Colors.grey[800]
                                          : Colors.grey[500],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      SizedBox(height: 20),

                      // Notes (Optional)
                      Text(
                        'Notes (Optional)',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[700],
                        ),
                      ),
                      SizedBox(height: 8),
                      TextFormField(
                        controller: _notesController,
                        maxLines: 3,
                        decoration: InputDecoration(
                          hintText: 'Add any additional notes',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 16,
                          ),
                        ),
                      ),

                      SizedBox(height: 30),

                      // Submit Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isSubmitting ? null : _createField,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green[600],
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child:
                              _isSubmitting
                                  ? SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                  : Text(
                                    'Create Field',
                                    style: TextStyle(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
