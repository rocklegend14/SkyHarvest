import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../models/fertilizer_recommendation.dart';
import '../../../services/fertilizer_service.dart';
import '../../../services/profile_service.dart';

class AddRecommendationBottomSheet extends StatefulWidget {
  final VoidCallback onRecommendationAdded;

  const AddRecommendationBottomSheet({
    super.key,
    required this.onRecommendationAdded,
  });

  @override
  State<AddRecommendationBottomSheet> createState() =>
      _AddRecommendationBottomSheetState();
}

class _AddRecommendationBottomSheetState
    extends State<AddRecommendationBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _fertilizerService = FertilizerService();
  final _profileService = ProfileService();

  List<Map<String, dynamic>> _fields = [];
  bool _isLoading = false;
  bool _isSubmitting = false;

  // Form fields
  String? _selectedFieldId;
  String _fertilizerType = 'nitrogen';
  double _amount = 0.0;
  DateTime _applicationDate = DateTime.now();
  String _applicationMethod = '';
  double _costEstimate = 0.0;
  String _notes = '';

  final List<Map<String, String>> _fertilizerTypes = [
    {'value': 'nitrogen', 'label': 'Nitrogen'},
    {'value': 'phosphorus', 'label': 'Phosphorus'},
    {'value': 'potassium', 'label': 'Potassium'},
    {'value': 'organic', 'label': 'Organic'},
    {'value': 'compound', 'label': 'Compound'},
  ];

  @override
  void initState() {
    super.initState();
    _loadFields();
  }

  Future<void> _loadFields() async {
    setState(() => _isLoading = true);
    try {
      final fields = await _profileService.getUserFields();
      setState(() => _fields = fields);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error loading fields: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _submitRecommendation() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      await _fertilizerService.createRecommendation({
        'field_id': _selectedFieldId,
        'fertilizer_type': _fertilizerType,
        'recommended_amount': _amount,
        'application_date': _applicationDate.toIso8601String().split('T')[0],
        'application_method':
            _applicationMethod.isEmpty ? null : _applicationMethod,
        'cost_estimate': _costEstimate == 0.0 ? null : _costEstimate,
        'notes': _notes.isEmpty ? null : _notes,
        'status': 'pending',
      });

      widget.onRecommendationAdded();
      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Recommendation created successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error creating recommendation: $e')),
      );
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _applicationDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365)),
    );
    if (date != null) {
      setState(() => _applicationDate = date);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Add Fertilizer Recommendation',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: Icon(Icons.close),
                ),
              ],
            ),
          ),

          // Form
          Expanded(
            child:
                _isLoading
                    ? Center(child: CircularProgressIndicator())
                    : SingleChildScrollView(
                      padding: EdgeInsets.all(20),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Field Selection
                            Text(
                              'Select Field',
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[700],
                              ),
                            ),
                            SizedBox(height: 8),
                            DropdownButtonFormField<String>(
                              value: _selectedFieldId,
                              decoration: InputDecoration(
                                hintText: 'Choose a field',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 16,
                                ),
                              ),
                              items:
                                  _fields.map((field) {
                                    return DropdownMenuItem<String>(
                                      value: field['id'],
                                      child: Text(
                                        '${field['name']} (${field['area_acres']} acres)',
                                      ),
                                    );
                                  }).toList(),
                              onChanged: (value) {
                                setState(() => _selectedFieldId = value);
                              },
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please select a field';
                                }
                                return null;
                              },
                            ),

                            SizedBox(height: 20),

                            // Fertilizer Type
                            Text(
                              'Fertilizer Type',
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[700],
                              ),
                            ),
                            SizedBox(height: 8),
                            DropdownButtonFormField<String>(
                              value: _fertilizerType,
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
                                  _fertilizerTypes.map((type) {
                                    return DropdownMenuItem<String>(
                                      value: type['value'],
                                      child: Text(type['label']!),
                                    );
                                  }).toList(),
                              onChanged: (value) {
                                setState(() => _fertilizerType = value!);
                              },
                            ),

                            SizedBox(height: 20),

                            // Amount
                            Text(
                              'Amount (kg/acre)',
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[700],
                              ),
                            ),
                            SizedBox(height: 8),
                            TextFormField(
                              keyboardType: TextInputType.numberWithOptions(
                                decimal: true,
                              ),
                              decoration: InputDecoration(
                                hintText: 'Enter amount',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 16,
                                ),
                              ),
                              onChanged: (value) {
                                _amount = double.tryParse(value) ?? 0.0;
                              },
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter amount';
                                }
                                final amount = double.tryParse(value);
                                if (amount == null || amount <= 0) {
                                  return 'Please enter valid amount';
                                }
                                return null;
                              },
                            ),

                            SizedBox(height: 20),

                            // Application Date
                            Text(
                              'Application Date',
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[700],
                              ),
                            ),
                            SizedBox(height: 8),
                            InkWell(
                              onTap: _selectDate,
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
                                      '${_applicationDate.day}/${_applicationDate.month}/${_applicationDate.year}',
                                      style: TextStyle(fontSize: 14.sp),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            SizedBox(height: 20),

                            // Application Method (Optional)
                            Text(
                              'Application Method (Optional)',
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[700],
                              ),
                            ),
                            SizedBox(height: 8),
                            TextFormField(
                              decoration: InputDecoration(
                                hintText: 'e.g., Side-dress, Broadcast',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 16,
                                ),
                              ),
                              onChanged: (value) => _applicationMethod = value,
                            ),

                            SizedBox(height: 20),

                            // Cost Estimate (Optional)
                            Text(
                              'Cost Estimate (Optional)',
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[700],
                              ),
                            ),
                            SizedBox(height: 8),
                            TextFormField(
                              keyboardType: TextInputType.numberWithOptions(
                                decimal: true,
                              ),
                              decoration: InputDecoration(
                                hintText: 'Enter estimated cost',
                                prefixText: '\$',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 16,
                                ),
                              ),
                              onChanged: (value) {
                                _costEstimate = double.tryParse(value) ?? 0.0;
                              },
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
                              onChanged: (value) => _notes = value,
                            ),

                            SizedBox(height: 30),

                            // Submit Button
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed:
                                    _isSubmitting
                                        ? null
                                        : _submitRecommendation,
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
                                          'Create Recommendation',
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
    );
  }
}
