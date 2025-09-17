import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/action_bottom_sheet.dart';
import './widgets/application_schedule_widget.dart';
import './widgets/field_selector_widget.dart';
import './widgets/recommendation_card.dart';
import './widgets/soil_status_card.dart';

class FertilizerRecommendations extends StatefulWidget {
  const FertilizerRecommendations({Key? key}) : super(key: key);

  @override
  State<FertilizerRecommendations> createState() =>
      _FertilizerRecommendationsState();
}

class _FertilizerRecommendationsState extends State<FertilizerRecommendations> {
  String _selectedFieldId = 'field_1';
  String _searchQuery = '';
  String _selectedFilter = 'All';
  bool _organicOnly = false;

  final TextEditingController _searchController = TextEditingController();

  // Mock data for fields
  final List<Map<String, dynamic>> _fields = [
    {
      "id": "field_1",
      "name": "North Field",
      "area": "5.2 acres",
      "color": "0xFF4CAF50",
      "crop": "Wheat"
    },
    {
      "id": "field_2",
      "name": "South Field",
      "area": "3.8 acres",
      "color": "0xFF2196F3",
      "crop": "Corn"
    },
    {
      "id": "field_3",
      "name": "East Field",
      "area": "7.1 acres",
      "color": "0xFFFF9800",
      "crop": "Soybeans"
    }
  ];

  // Mock soil data
  final Map<String, dynamic> _soilData = {
    "nitrogen": 45,
    "phosphorus": 32,
    "potassium": 68,
    "ph": 6.8,
    "organic_matter": 3.2
  };

  // Mock fertilizer recommendations
  final List<Map<String, dynamic>> _recommendations = [
    {
      "id": "rec_1",
      "name": "NPK 20-10-10",
      "type": "Granular Fertilizer",
      "priority": "High",
      "quantity": "150 kg/acre",
      "cost": "\$85.00",
      "method": "Broadcast Application",
      "coverage": "5.2 acres",
      "reasoning":
          "Your soil analysis shows nitrogen deficiency (45%) which is below optimal levels for wheat growth. This NPK blend will boost nitrogen while maintaining phosphorus and potassium balance. The 20-10-10 ratio is specifically formulated for cereal crops during vegetative growth stage.",
      "instructions":
          "Apply evenly across the field using a broadcast spreader. Water immediately after application if no rain is expected within 24 hours. Avoid application during windy conditions.",
      "organic": false,
      "category": "Primary Nutrients"
    },
    {
      "id": "rec_2",
      "name": "Organic Compost Blend",
      "type": "Organic Amendment",
      "priority": "Medium",
      "quantity": "2 tons/acre",
      "cost": "\$120.00",
      "method": "Incorporation",
      "coverage": "5.2 acres",
      "reasoning":
          "Improve soil organic matter content and provide slow-release nutrients. Your current organic matter at 3.2% can be enhanced to improve soil structure, water retention, and microbial activity for long-term soil health.",
      "instructions":
          "Spread evenly and incorporate into top 6 inches of soil using a disc harrow or rototiller. Best applied 2-3 weeks before planting or during fall preparation.",
      "organic": true,
      "category": "Soil Amendment"
    },
    {
      "id": "rec_3",
      "name": "Phosphorus Booster 0-46-0",
      "type": "Single Nutrient",
      "priority": "Medium",
      "quantity": "75 kg/acre",
      "cost": "\$45.00",
      "method": "Band Application",
      "coverage": "5.2 acres",
      "reasoning":
          "Phosphorus levels at 32% are moderately low for optimal root development and flowering. This concentrated phosphorus fertilizer will enhance root growth and improve nutrient uptake efficiency.",
      "instructions":
          "Apply in bands 2 inches to the side and 2 inches below seed placement. Use precision applicator for accurate placement. Do not apply directly with seeds.",
      "organic": false,
      "category": "Secondary Nutrients"
    },
    {
      "id": "rec_4",
      "name": "Liquid Kelp Extract",
      "type": "Organic Liquid",
      "priority": "Low",
      "quantity": "5 L/acre",
      "cost": "\$35.00",
      "method": "Foliar Spray",
      "coverage": "5.2 acres",
      "reasoning":
          "Provides micronutrients and growth hormones to enhance plant vigor and stress resistance. Kelp extract contains natural plant growth regulators that improve nutrient uptake and overall plant health.",
      "instructions":
          "Dilute 1:200 with water. Apply during early morning or late evening to avoid leaf burn. Ensure complete coverage of foliage. Reapply every 2-3 weeks during growing season.",
      "organic": true,
      "category": "Micronutrients"
    }
  ];

  // Mock application schedule
  final List<Map<String, dynamic>> _scheduleData = [
    {
      "id": "schedule_1",
      "fertilizer": "NPK 20-10-10",
      "date": "March 15, 2025",
      "quantity": "150 kg/acre",
      "completed": false,
      "weather_suitable": true
    },
    {
      "id": "schedule_2",
      "fertilizer": "Phosphorus Booster 0-46-0",
      "date": "March 22, 2025",
      "quantity": "75 kg/acre",
      "completed": false,
      "weather_suitable": true
    },
    {
      "id": "schedule_3",
      "fertilizer": "Organic Compost Blend",
      "date": "April 5, 2025",
      "quantity": "2 tons/acre",
      "completed": false,
      "weather_suitable": false
    },
    {
      "id": "schedule_4",
      "fertilizer": "Liquid Kelp Extract",
      "date": "April 20, 2025",
      "quantity": "5 L/acre",
      "completed": false,
      "weather_suitable": true
    }
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          FieldSelectorWidget(
            fields: _fields,
            selectedFieldId: _selectedFieldId,
            onFieldChanged: (fieldId) {
              setState(() {
                _selectedFieldId = fieldId;
              });
            },
          ),
          _buildSearchAndFilter(),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SoilStatusCard(soilData: _soilData),
                  _buildSectionHeader('Recommended Applications'),
                  ..._getFilteredRecommendations().map((recommendation) {
                    return RecommendationCard(
                      recommendation: recommendation,
                      onTap: () => _showActionBottomSheet(recommendation),
                    );
                  }).toList(),
                  ApplicationScheduleWidget(scheduleData: _scheduleData),
                  SizedBox(height: 2.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppTheme.lightTheme.colorScheme.surface,
      elevation: 1,
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: CustomIconWidget(
          iconName: 'arrow_back',
          color: AppTheme.lightTheme.colorScheme.onSurface,
          size: 24,
        ),
      ),
      title: Text(
        'Fertilizer Recommendations',
        style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      actions: [
        IconButton(
          onPressed: () => _showFilterDialog(),
          icon: CustomIconWidget(
            iconName: 'tune',
            color: AppTheme.lightTheme.colorScheme.onSurface,
            size: 24,
          ),
        ),
        IconButton(
          onPressed: () => Navigator.pushNamed(context, '/farmer-dashboard'),
          icon: CustomIconWidget(
            iconName: 'dashboard',
            color: AppTheme.lightTheme.colorScheme.onSurface,
            size: 24,
          ),
        ),
      ],
    );
  }

  Widget _buildSearchAndFilter() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search fertilizers...',
                prefixIcon: Padding(
                  padding: EdgeInsets.all(3.w),
                  child: CustomIconWidget(
                    iconName: 'search',
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    size: 20,
                  ),
                ),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        onPressed: () {
                          setState(() {
                            _searchQuery = '';
                            _searchController.clear();
                          });
                        },
                        icon: CustomIconWidget(
                          iconName: 'clear',
                          color:
                              AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                          size: 20,
                        ),
                      )
                    : null,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: AppTheme.neutralLight.withValues(alpha: 0.3),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: AppTheme.neutralLight.withValues(alpha: 0.3),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: AppTheme.lightTheme.primaryColor,
                    width: 2,
                  ),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          SizedBox(width: 2.w),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.w),
            decoration: BoxDecoration(
              color: _organicOnly
                  ? AppTheme.successLight.withValues(alpha: 0.1)
                  : AppTheme.neutralLight.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: _organicOnly
                    ? AppTheme.successLight.withValues(alpha: 0.3)
                    : AppTheme.neutralLight.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomIconWidget(
                  iconName: 'eco',
                  color: _organicOnly
                      ? AppTheme.successLight
                      : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  size: 16,
                ),
                SizedBox(width: 1.w),
                Text(
                  'Organic',
                  style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                    color: _organicOnly
                        ? AppTheme.successLight
                        : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      child: Text(
        title,
        style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _getFilteredRecommendations() {
    List<Map<String, dynamic>> filtered = _recommendations;

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((rec) {
        final name = (rec['name'] as String).toLowerCase();
        final type = (rec['type'] as String).toLowerCase();
        final category = (rec['category'] as String).toLowerCase();
        final query = _searchQuery.toLowerCase();

        return name.contains(query) ||
            type.contains(query) ||
            category.contains(query);
      }).toList();
    }

    // Apply organic filter
    if (_organicOnly) {
      filtered = filtered.where((rec) => rec['organic'] as bool).toList();
    }

    // Apply category filter
    if (_selectedFilter != 'All') {
      filtered =
          filtered.where((rec) => rec['category'] == _selectedFilter).toList();
    }

    return filtered;
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(
                'Filter Options',
                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Category',
                    style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 1.h),
                  Wrap(
                    spacing: 2.w,
                    children: [
                      'All',
                      'Primary Nutrients',
                      'Secondary Nutrients',
                      'Soil Amendment',
                      'Micronutrients'
                    ].map((category) {
                      final isSelected = _selectedFilter == category;
                      return FilterChip(
                        label: Text(category),
                        selected: isSelected,
                        onSelected: (selected) {
                          setDialogState(() {
                            _selectedFilter = selected ? category : 'All';
                          });
                        },
                      );
                    }).toList(),
                  ),
                  SizedBox(height: 2.h),
                  CheckboxListTile(
                    title: Text('Organic Only'),
                    value: _organicOnly,
                    onChanged: (value) {
                      setDialogState(() {
                        _organicOnly = value ?? false;
                      });
                    },
                    contentPadding: EdgeInsets.zero,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    setDialogState(() {
                      _selectedFilter = 'All';
                      _organicOnly = false;
                    });
                  },
                  child: Text('Clear'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      // Apply filters
                    });
                    Navigator.of(context).pop();
                  },
                  child: Text('Apply'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showActionBottomSheet(Map<String, dynamic> recommendation) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ActionBottomSheet(
        selectedRecommendation: recommendation,
      ),
    );
  }
}
