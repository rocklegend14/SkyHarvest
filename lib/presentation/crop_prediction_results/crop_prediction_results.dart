import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/prediction_overview_card.dart';
import './widgets/recommendations_card.dart';
import './widgets/soil_analysis_card.dart';
import './widgets/weather_impact_card.dart';

class CropPredictionResults extends StatefulWidget {
  const CropPredictionResults({Key? key}) : super(key: key);

  @override
  State<CropPredictionResults> createState() => _CropPredictionResultsState();
}

class _CropPredictionResultsState extends State<CropPredictionResults>
    with TickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;

  // Mock prediction data
  final Map<String, dynamic> _predictionData = {
    "fieldName": "North Field - Sector A",
    "predictionDate": "December 13, 2025",
    "yieldEstimate": 8.5,
    "harvestDate": "March 15, 2026",
    "confidence": 0.87,
    "cropType": "Winter Wheat",
  };

  final Map<String, dynamic> _weatherData = {
    "temperature": [22.5, 24.1, 21.8, 23.6, 25.2, 22.9, 24.7],
    "rainfall": [12.5, 8.2, 15.7, 6.3, 18.9, 11.4, 9.8],
    "humidity": 68.5,
    "impact": "Positive",
  };

  final Map<String, dynamic> _soilData = {
    "phLevel": 6.8,
    "nitrogen": 45.2,
    "phosphorus": 32.8,
    "potassium": 28.6,
    "moisture": 52.3,
    "healthStatus": "Good",
  };

  final List<Map<String, dynamic>> _recommendations = [
    {
      "type": "irrigation",
      "title": "Optimize Irrigation Schedule",
      "description":
          "Based on current soil moisture levels and weather forecast, adjust irrigation to every 3 days for the next two weeks to maintain optimal growth conditions.",
      "priority": "high",
      "timing": "Next 2 weeks",
      "additionalInfo":
          "Current soil moisture is at 52%, which is ideal. Monitor daily and adjust based on rainfall predictions.",
    },
    {
      "type": "fertilizer",
      "title": "Nitrogen Application Needed",
      "description":
          "Soil analysis shows nitrogen levels are slightly below optimal. Apply 25kg/hectare of nitrogen-rich fertilizer to boost crop development.",
      "priority": "medium",
      "timing": "Within 1 week",
      "additionalInfo":
          "Best applied during early morning or late evening to minimize nutrient loss through evaporation.",
    },
    {
      "type": "pest",
      "title": "Monitor for Aphid Activity",
      "description":
          "Weather conditions are favorable for aphid development. Conduct weekly field inspections and consider preventive measures if population exceeds threshold.",
      "priority": "low",
      "timing": "Weekly monitoring",
      "additionalInfo":
          "Look for curled leaves and sticky honeydew residue. Natural predators like ladybugs can help control populations.",
    },
    {
      "type": "harvest",
      "title": "Prepare Harvest Equipment",
      "description":
          "Based on growth predictions, harvest is expected in approximately 12 weeks. Begin equipment maintenance and scheduling to ensure readiness.",
      "priority": "low",
      "timing": "8-10 weeks before harvest",
      "additionalInfo":
          "Consider weather patterns and market prices when finalizing harvest dates.",
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: _buildAppBar(),
      body: _isLoading ? _buildLoadingState() : _buildMainContent(),
      bottomNavigationBar: _buildBottomActionBar(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppTheme.lightTheme.colorScheme.surface,
      elevation: 2,
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: CustomIconWidget(
          iconName: 'arrow_back',
          color: AppTheme.lightTheme.colorScheme.onSurface,
          size: 6.w,
        ),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _predictionData['fieldName'] ?? 'Field Results',
            style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            _predictionData['predictionDate'] ?? 'Today',
            style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
      actions: [
        IconButton(
          onPressed: _shareResults,
          icon: CustomIconWidget(
            iconName: 'share',
            color: AppTheme.lightTheme.colorScheme.onSurface,
            size: 6.w,
          ),
        ),
        SizedBox(width: 2.w),
      ],
    );
  }

  Widget _buildMainContent() {
    return RefreshIndicator(
      onRefresh: _refreshPredictionData,
      color: AppTheme.lightTheme.colorScheme.primary,
      child: Column(
        children: [
          _buildHeroSection(),
          _buildTabBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildOverviewTab(),
                _buildWeatherTab(),
                _buildSoilTab(),
                _buildRecommendationsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroSection() {
    final yieldEstimate = _predictionData['yieldEstimate'] ?? 0.0;
    final harvestDate = _predictionData['harvestDate'] ?? 'Not available';

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.lightTheme.colorScheme.primary,
            AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.8),
          ],
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildHeroMetric(
                  'Expected Yield',
                  '${yieldEstimate.toStringAsFixed(1)} t/ha',
                  CustomIconWidget(
                    iconName: 'trending_up',
                    color: Colors.white,
                    size: 8.w,
                  ),
                ),
                Container(
                  width: 1,
                  height: 8.h,
                  color: Colors.white.withValues(alpha: 0.3),
                ),
                _buildHeroMetric(
                  'Harvest Date',
                  harvestDate,
                  CustomIconWidget(
                    iconName: 'calendar_today',
                    color: Colors.white,
                    size: 8.w,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroMetric(String label, String value, Widget icon) {
    return Column(
      children: [
        icon,
        SizedBox(height: 1.h),
        Text(
          label,
          style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
            color: Colors.white.withValues(alpha: 0.9),
          ),
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
        ),
        SizedBox(height: 0.5.h),
        Text(
          value,
          style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: AppTheme.lightTheme.colorScheme.surface,
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        tabAlignment: TabAlignment.start,
        labelColor: AppTheme.lightTheme.colorScheme.primary,
        unselectedLabelColor: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
        indicatorColor: AppTheme.lightTheme.colorScheme.primary,
        indicatorWeight: 3,
        labelStyle: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: AppTheme.lightTheme.textTheme.labelLarge,
        tabs: [
          Tab(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomIconWidget(
                  iconName: 'dashboard',
                  color: _tabController.index == 0
                      ? AppTheme.lightTheme.colorScheme.primary
                      : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  size: 4.w,
                ),
                SizedBox(width: 1.w),
                Text('Overview'),
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomIconWidget(
                  iconName: 'wb_sunny',
                  color: _tabController.index == 1
                      ? AppTheme.lightTheme.colorScheme.primary
                      : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  size: 4.w,
                ),
                SizedBox(width: 1.w),
                Text('Weather'),
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomIconWidget(
                  iconName: 'terrain',
                  color: _tabController.index == 2
                      ? AppTheme.lightTheme.colorScheme.primary
                      : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  size: 4.w,
                ),
                SizedBox(width: 1.w),
                Text('Soil'),
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomIconWidget(
                  iconName: 'lightbulb',
                  color: _tabController.index == 3
                      ? AppTheme.lightTheme.colorScheme.primary
                      : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  size: 4.w,
                ),
                SizedBox(width: 1.w),
                Text('Tips'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(vertical: 2.h),
      child: Column(
        children: [
          PredictionOverviewCard(predictionData: _predictionData),
          _buildConfidenceExplanation(),
        ],
      ),
    );
  }

  Widget _buildWeatherTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(vertical: 2.h),
      child: WeatherImpactCard(weatherData: _weatherData),
    );
  }

  Widget _buildSoilTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(vertical: 2.h),
      child: SoilAnalysisCard(soilData: _soilData),
    );
  }

  Widget _buildRecommendationsTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(vertical: 2.h),
      child: RecommendationsCard(
        recommendations: _recommendations,
        onSetReminder: _setReminder,
      ),
    );
  }

  Widget _buildConfidenceExplanation() {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.tertiary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color:
              AppTheme.lightTheme.colorScheme.tertiary.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomIconWidget(
                iconName: 'info',
                color: AppTheme.lightTheme.colorScheme.tertiary,
                size: 5.w,
              ),
              SizedBox(width: 2.w),
              Text(
                'About AI Predictions',
                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.lightTheme.colorScheme.tertiary,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Text(
            'Our AI model analyzes weather patterns, soil conditions, historical data, and crop characteristics to provide yield predictions. Higher confidence scores indicate more reliable predictions based on data quality and environmental stability.',
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: AppTheme.lightTheme.colorScheme.primary,
          ),
          SizedBox(height: 2.h),
          Text(
            'Updating prediction data...',
            style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActionBar() {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color:
                AppTheme.lightTheme.colorScheme.shadow.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _saveToHistory,
                icon: CustomIconWidget(
                  iconName: 'bookmark',
                  color: AppTheme.lightTheme.colorScheme.primary,
                  size: 5.w,
                ),
                label: Text(
                  'Save to History',
                  style: AppTheme.lightTheme.textTheme.labelLarge,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _scheduleActions,
                icon: CustomIconWidget(
                  iconName: 'schedule',
                  color: Colors.white,
                  size: 5.w,
                ),
                label: Text(
                  'Schedule Actions',
                  style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                    color: Colors.white,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _refreshPredictionData() async {
    setState(() {
      _isLoading = true;
    });

    // Simulate API call
    await Future.delayed(Duration(seconds: 2));

    setState(() {
      _isLoading = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Prediction data updated successfully'),
        backgroundColor: AppTheme.successLight,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _shareResults() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(4.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 12.w,
                height: 0.5.h,
                decoration: BoxDecoration(
                  color: AppTheme.lightTheme.colorScheme.outline,
                  borderRadius: BorderRadius.circular(0.25.h),
                ),
              ),
              SizedBox(height: 3.h),
              Text(
                'Share Prediction Results',
                style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 3.h),
              ListTile(
                leading: CustomIconWidget(
                  iconName: 'message',
                  color: AppTheme.lightTheme.colorScheme.primary,
                  size: 6.w,
                ),
                title: Text('Send via Message'),
                onTap: () {
                  Navigator.pop(context);
                  _showShareSuccess('Message');
                },
              ),
              ListTile(
                leading: CustomIconWidget(
                  iconName: 'email',
                  color: AppTheme.lightTheme.colorScheme.primary,
                  size: 6.w,
                ),
                title: Text('Send via Email'),
                onTap: () {
                  Navigator.pop(context);
                  _showShareSuccess('Email');
                },
              ),
              ListTile(
                leading: CustomIconWidget(
                  iconName: 'download',
                  color: AppTheme.lightTheme.colorScheme.primary,
                  size: 6.w,
                ),
                title: Text('Export as PDF'),
                onTap: () {
                  Navigator.pop(context);
                  _showShareSuccess('PDF Export');
                },
              ),
              SizedBox(height: 2.h),
            ],
          ),
        );
      },
    );
  }

  void _showShareSuccess(String method) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Results shared via $method'),
        backgroundColor: AppTheme.successLight,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _setReminder() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Set Reminder',
            style: AppTheme.lightTheme.textTheme.titleLarge,
          ),
          content: Text(
            'Would you like to set a reminder for this recommendation?',
            style: AppTheme.lightTheme.textTheme.bodyMedium,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Reminder set successfully'),
                    backgroundColor: AppTheme.successLight,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              child: Text(
                'Set Reminder',
                style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                  color: Colors.white,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _saveToHistory() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Prediction saved to history'),
        backgroundColor: AppTheme.successLight,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _scheduleActions() {
    Navigator.pushNamed(context, '/irrigation-alerts');
  }
}
