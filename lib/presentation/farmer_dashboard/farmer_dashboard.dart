import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/alert_item.dart';
import './widgets/empty_state_widget.dart';
import './widgets/farm_summary_card.dart';
import './widgets/quick_action_button.dart';
import './widgets/weather_widget.dart';

class FarmerDashboard extends StatefulWidget {
  const FarmerDashboard({Key? key}) : super(key: key);

  @override
  State<FarmerDashboard> createState() => _FarmerDashboardState();
}

class _FarmerDashboardState extends State<FarmerDashboard>
    with TickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;
  bool _hasFields = true; // Set to false to show empty state
  DateTime _lastUpdated = DateTime.now();

  // Mock data
  final Map<String, dynamic> _weatherData = {
    "location": "Green Valley Farm",
    "temperature": 24,
    "condition": "Sunny",
    "humidity": 65,
    "windSpeed": 12,
  };

  final List<Map<String, dynamic>> _farmSummaryData = [
    {
      "title": "Active Fields",
      "value": "8",
      "subtitle": "2 ready for harvest",
      "icon": "agriculture",
    },
    {
      "title": "Irrigation Alerts",
      "value": "3",
      "subtitle": "Field A, B, C need water",
      "icon": "water_drop",
    },
    {
      "title": "Fertilizer Due",
      "value": "2",
      "subtitle": "Next: Tomorrow",
      "icon": "eco",
    },
    {
      "title": "Crop Health",
      "value": "92%",
      "subtitle": "Excellent condition",
      "icon": "local_florist",
    },
  ];

  final List<Map<String, dynamic>> _quickActions = [
    {"title": "Get Prediction", "icon": "analytics"},
    {"title": "View Maps", "icon": "map"},
    {"title": "Check Weather", "icon": "wb_sunny"},
    {"title": "Add Field", "icon": "add_location"},
  ];

  final List<Map<String, dynamic>> _recentAlerts = [
    {
      "id": 1,
      "type": "irrigation",
      "priority": "high",
      "title": "Irrigation Required",
      "message": "Field A moisture level is below optimal threshold",
      "timestamp": DateTime.now().subtract(Duration(minutes: 30)),
    },
    {
      "id": 2,
      "type": "fertilizer",
      "priority": "medium",
      "title": "Fertilizer Schedule",
      "message": "Apply nitrogen fertilizer to Field B tomorrow morning",
      "timestamp": DateTime.now().subtract(Duration(hours: 2)),
    },
    {
      "id": 3,
      "type": "weather",
      "priority": "low",
      "title": "Weather Update",
      "message": "Light rain expected in the next 48 hours",
      "timestamp": DateTime.now().subtract(Duration(hours: 4)),
    },
    {
      "id": 4,
      "type": "pest",
      "priority": "high",
      "title": "Pest Alert",
      "message":
          "Aphid activity detected in Field C - immediate action required",
      "timestamp": DateTime.now().subtract(Duration(hours: 6)),
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _refreshData() async {
    setState(() {
      _isLoading = true;
    });

    // Simulate API call
    await Future.delayed(Duration(seconds: 2));

    setState(() {
      _isLoading = false;
      _lastUpdated = DateTime.now();
    });
  }

  void _handleQuickAction(String action) {
    switch (action) {
      case "Get Prediction":
        Navigator.pushNamed(context, '/crop-prediction-results');
        break;
      case "View Maps":
        Navigator.pushNamed(context, '/interactive-farm-map');
        break;
      case "Check Weather":
        _showWeatherDetails();
        break;
      case "Add Field":
        Navigator.pushNamed(context, '/interactive-farm-map');
        break;
    }
  }

  void _showWeatherDetails() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: 50.h,
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.colorScheme.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: EdgeInsets.all(6.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 12.w,
                height: 0.5.h,
                decoration: BoxDecoration(
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant
                      .withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            SizedBox(height: 3.h),
            Text(
              'Weather Details',
              style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 2.h),
            WeatherWidget(weatherData: _weatherData),
          ],
        ),
      ),
    );
  }

  void _handleAlertDismiss(int alertId) {
    setState(() {
      _recentAlerts.removeWhere((alert) => alert['id'] == alertId);
    });
  }

  void _handleAlertTap(Map<String, dynamic> alert) {
    final alertType = alert['type'] as String;
    switch (alertType) {
      case 'irrigation':
        Navigator.pushNamed(context, '/irrigation-alerts');
        break;
      case 'fertilizer':
        Navigator.pushNamed(context, '/fertilizer-recommendations');
        break;
      default:
        break;
    }
  }

  void _handleFarmCardTap(String title) {
    switch (title) {
      case "Active Fields":
        Navigator.pushNamed(context, '/interactive-farm-map');
        break;
      case "Irrigation Alerts":
        Navigator.pushNamed(context, '/irrigation-alerts');
        break;
      case "Fertilizer Due":
        Navigator.pushNamed(context, '/fertilizer-recommendations');
        break;
      case "Crop Health":
        Navigator.pushNamed(context, '/crop-prediction-results');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.lightTheme.colorScheme.surface,
        elevation: 0,
        title: Row(
          children: [
            CustomIconWidget(
              iconName: 'agriculture',
              size: 7.w,
              color: AppTheme.lightTheme.colorScheme.primary,
            ),
            SizedBox(width: 2.w),
            Text(
              'SkyHarvest',
              style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppTheme.lightTheme.colorScheme.primary,
              ),
            ),
          ],
        ),
        actions: [
          Stack(
            children: [
              IconButton(
                onPressed: () {
                  // Show notifications
                },
                icon: CustomIconWidget(
                  iconName: 'notifications',
                  size: 6.w,
                  color: AppTheme.lightTheme.colorScheme.onSurface,
                ),
              ),
              if (_recentAlerts.any((alert) => alert['priority'] == 'high'))
                Positioned(
                  right: 2.w,
                  top: 2.w,
                  child: Container(
                    width: 3.w,
                    height: 3.w,
                    decoration: BoxDecoration(
                      color: AppTheme.errorLight,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
          IconButton(
            onPressed: () {
              // Show connectivity status
            },
            icon: CustomIconWidget(
              iconName: 'signal_cellular_4_bar',
              size: 5.w,
              color: AppTheme.successLight,
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              icon: CustomIconWidget(
                iconName: 'dashboard',
                size: 5.w,
                color: _tabController.index == 0
                    ? AppTheme.lightTheme.colorScheme.primary
                    : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              ),
              text: 'Dashboard',
            ),
            Tab(
              icon: CustomIconWidget(
                iconName: 'map',
                size: 5.w,
                color: _tabController.index == 1
                    ? AppTheme.lightTheme.colorScheme.primary
                    : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              ),
              text: 'Maps',
            ),
            Tab(
              icon: CustomIconWidget(
                iconName: 'analytics',
                size: 5.w,
                color: _tabController.index == 2
                    ? AppTheme.lightTheme.colorScheme.primary
                    : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              ),
              text: 'Predictions',
            ),
            Tab(
              icon: CustomIconWidget(
                iconName: 'person',
                size: 5.w,
                color: _tabController.index == 3
                    ? AppTheme.lightTheme.colorScheme.primary
                    : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              ),
              text: 'Profile',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildDashboardTab(),
          _buildMapsTab(),
          _buildPredictionsTab(),
          _buildProfileTab(),
        ],
      ),
      floatingActionButton: _tabController.index == 0
          ? FloatingActionButton(
              onPressed: () =>
                  Navigator.pushNamed(context, '/interactive-farm-map'),
              child: CustomIconWidget(
                iconName: 'add_location',
                size: 6.w,
                color: AppTheme.lightTheme.colorScheme.onPrimary,
              ),
              tooltip: 'Add Field',
            )
          : null,
    );
  }

  Widget _buildDashboardTab() {
    if (!_hasFields) {
      return EmptyStateWidget(
        onAddField: () => Navigator.pushNamed(context, '/interactive-farm-map'),
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshData,
      color: AppTheme.lightTheme.colorScheme.primary,
      child: SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Weather Widget
            WeatherWidget(weatherData: _weatherData),

            // Quick Actions
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Quick Actions',
                    style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _quickActions
                          .map((action) => QuickActionButton(
                                title: action['title'] as String,
                                iconName: action['icon'] as String,
                                onTap: () => _handleQuickAction(
                                    action['title'] as String),
                              ))
                          .toList(),
                    ),
                  ),
                ],
              ),
            ),

            // Farm Summary Cards
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Farm Overview',
                    style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Wrap(
                    children: _farmSummaryData
                        .map((data) => FarmSummaryCard(
                              title: data['title'] as String,
                              value: data['value'] as String,
                              subtitle: data['subtitle'] as String,
                              iconName: data['icon'] as String,
                              onTap: () =>
                                  _handleFarmCardTap(data['title'] as String),
                            ))
                        .toList(),
                  ),
                ],
              ),
            ),

            // Recent Alerts
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Recent Alerts',
                        style:
                            AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          // Show all alerts
                        },
                        child: Text('View All'),
                      ),
                    ],
                  ),
                  SizedBox(height: 1.h),
                  _recentAlerts.isEmpty
                      ? Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(4.w),
                          decoration: BoxDecoration(
                            color: AppTheme.lightTheme.colorScheme.surface,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            children: [
                              CustomIconWidget(
                                iconName: 'check_circle',
                                size: 12.w,
                                color: AppTheme.successLight,
                              ),
                              SizedBox(height: 2.h),
                              Text(
                                'All caught up!',
                                style: AppTheme.lightTheme.textTheme.titleMedium
                                    ?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                'No alerts at the moment',
                                style: AppTheme.lightTheme.textTheme.bodySmall,
                              ),
                            ],
                          ),
                        )
                      : Column(
                          children: _recentAlerts
                              .take(3)
                              .map((alert) => AlertItem(
                                    alertData: alert,
                                    onDismiss: () =>
                                        _handleAlertDismiss(alert['id'] as int),
                                    onTap: () => _handleAlertTap(alert),
                                  ))
                              .toList(),
                        ),
                ],
              ),
            ),

            // Last Updated
            Padding(
              padding: EdgeInsets.all(4.w),
              child: Center(
                child: Text(
                  'Last updated: ${_formatLastUpdated(_lastUpdated)}',
                  style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),

            SizedBox(height: 10.h), // Bottom padding for FAB
          ],
        ),
      ),
    );
  }

  Widget _buildMapsTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomIconWidget(
            iconName: 'map',
            size: 20.w,
            color: AppTheme.lightTheme.colorScheme.primary,
          ),
          SizedBox(height: 2.h),
          Text(
            'Interactive Farm Map',
            style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            'View and manage your farm fields',
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(height: 4.h),
          ElevatedButton(
            onPressed: () =>
                Navigator.pushNamed(context, '/interactive-farm-map'),
            child: Text('Open Map'),
          ),
        ],
      ),
    );
  }

  Widget _buildPredictionsTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomIconWidget(
            iconName: 'analytics',
            size: 20.w,
            color: AppTheme.lightTheme.colorScheme.primary,
          ),
          SizedBox(height: 2.h),
          Text(
            'Crop Predictions',
            style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            'AI-powered crop yield predictions',
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(height: 4.h),
          ElevatedButton(
            onPressed: () =>
                Navigator.pushNamed(context, '/crop-prediction-results'),
            child: Text('Get Predictions'),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(4.w),
      child: Column(
        children: [
          SizedBox(height: 2.h),
          CircleAvatar(
            radius: 15.w,
            backgroundColor: AppTheme.lightTheme.colorScheme.primary,
            child: CustomIconWidget(
              iconName: 'person',
              size: 15.w,
              color: AppTheme.lightTheme.colorScheme.onPrimary,
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            'John Farmer',
            style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            'Green Valley Farm',
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(height: 4.h),
          _buildProfileOption('Account Settings', 'settings', () {}),
          _buildProfileOption('Notifications', 'notifications', () {}),
          _buildProfileOption('Help & Support', 'help', () {}),
          _buildProfileOption('About', 'info', () {}),
          SizedBox(height: 4.h),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => Navigator.pushNamed(context, '/login-screen'),
              child: Text('Sign Out'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.errorLight,
                side: BorderSide(color: AppTheme.errorLight),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileOption(
      String title, String iconName, VoidCallback onTap) {
    return ListTile(
      leading: CustomIconWidget(
        iconName: iconName,
        size: 6.w,
        color: AppTheme.lightTheme.colorScheme.primary,
      ),
      title: Text(
        title,
        style: AppTheme.lightTheme.textTheme.titleMedium,
      ),
      trailing: CustomIconWidget(
        iconName: 'chevron_right',
        size: 5.w,
        color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
      ),
      onTap: onTap,
    );
  }

  String _formatLastUpdated(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }
}
