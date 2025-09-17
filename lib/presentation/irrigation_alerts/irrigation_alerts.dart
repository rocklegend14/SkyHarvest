import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/add_alert_bottom_sheet.dart';
import './widgets/alert_card_widget.dart';
import './widgets/empty_state_widget.dart';
import './widgets/filter_chips_widget.dart';

class IrrigationAlerts extends StatefulWidget {
  const IrrigationAlerts({Key? key}) : super(key: key);

  @override
  State<IrrigationAlerts> createState() => _IrrigationAlertsState();
}

class _IrrigationAlertsState extends State<IrrigationAlerts> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'all';
  bool _isSearching = false;
  List<Map<String, dynamic>> _alerts = [];
  List<Map<String, dynamic>> _filteredAlerts = [];

  @override
  void initState() {
    super.initState();
    _initializeMockData();
    _filteredAlerts = List.from(_alerts);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _initializeMockData() {
    final now = DateTime.now();
    _alerts = [
      {
        'id': 1,
        'fieldName': 'North Field A',
        'cropType': 'Wheat',
        'urgency': 'high',
        'scheduledTime': now.add(Duration(hours: 2)),
        'waterAmount': 1500,
        'soilMoisture': 25,
        'weatherCondition': 'Sunny, 28°C',
        'isCompleted': false,
      },
      {
        'id': 2,
        'fieldName': 'South Field B',
        'cropType': 'Tomatoes',
        'urgency': 'medium',
        'scheduledTime': now.add(Duration(hours: 6)),
        'waterAmount': 800,
        'soilMoisture': 35,
        'weatherCondition': 'Partly Cloudy, 25°C',
        'isCompleted': false,
      },
      {
        'id': 3,
        'fieldName': 'East Field C',
        'cropType': 'Corn',
        'urgency': 'low',
        'scheduledTime': now.add(Duration(days: 1)),
        'waterAmount': 2000,
        'soilMoisture': 45,
        'weatherCondition': 'Cloudy, 22°C',
        'isCompleted': false,
      },
      {
        'id': 4,
        'fieldName': 'West Field D',
        'cropType': 'Rice',
        'urgency': 'high',
        'scheduledTime': now.add(Duration(minutes: 30)),
        'waterAmount': 3000,
        'soilMoisture': 20,
        'weatherCondition': 'Hot, 32°C',
        'isCompleted': false,
      },
      {
        'id': 5,
        'fieldName': 'Central Field E',
        'cropType': 'Soybeans',
        'urgency': 'medium',
        'scheduledTime': now.add(Duration(hours: 12)),
        'waterAmount': 1200,
        'soilMoisture': 40,
        'weatherCondition': 'Mild, 24°C',
        'isCompleted': false,
      },
    ];
  }

  void _filterAlerts() {
    setState(() {
      _filteredAlerts = _alerts.where((alert) {
        // Search filter
        final searchQuery = _searchController.text.toLowerCase();
        final matchesSearch = searchQuery.isEmpty ||
            (alert['fieldName'] as String)
                .toLowerCase()
                .contains(searchQuery) ||
            (alert['cropType'] as String).toLowerCase().contains(searchQuery);

        // Category filter
        bool matchesFilter = true;
        switch (_selectedFilter) {
          case 'urgent':
            matchesFilter = alert['urgency'] == 'high';
            break;
          case 'field':
            // Sort by field name (already matches search if needed)
            break;
          case 'crop':
            // Sort by crop type (already matches search if needed)
            break;
          case 'all':
          default:
            matchesFilter = true;
            break;
        }

        return matchesSearch &&
            matchesFilter &&
            !(alert['isCompleted'] as bool);
      }).toList();

      // Sort by urgency and time
      _filteredAlerts.sort((a, b) {
        // First sort by urgency
        final urgencyOrder = {'high': 0, 'medium': 1, 'low': 2};
        final urgencyComparison = (urgencyOrder[a['urgency']] ?? 2)
            .compareTo(urgencyOrder[b['urgency']] ?? 2);

        if (urgencyComparison != 0) return urgencyComparison;

        // Then sort by scheduled time
        final timeA = a['scheduledTime'] as DateTime;
        final timeB = b['scheduledTime'] as DateTime;
        return timeA.compareTo(timeB);
      });
    });
  }

  void _onSearchChanged(String query) {
    _filterAlerts();
  }

  void _onFilterChanged(String filter) {
    setState(() {
      _selectedFilter = filter;
    });
    _filterAlerts();
  }

  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) {
        _searchController.clear();
        _filterAlerts();
      }
    });
  }

  Future<void> _refreshAlerts() async {
    // Simulate API call
    await Future.delayed(Duration(seconds: 1));

    // Update weather conditions and soil moisture
    setState(() {
      for (var alert in _alerts) {
        alert['soilMoisture'] =
            20 + (DateTime.now().millisecondsSinceEpoch % 40);
        final conditions = ['Sunny', 'Partly Cloudy', 'Cloudy', 'Light Rain'];
        alert['weatherCondition'] =
            '${conditions[DateTime.now().millisecondsSinceEpoch % conditions.length]}, ${20 + (DateTime.now().millisecondsSinceEpoch % 15)}°C';
      }
    });
    _filterAlerts();
  }

  void _showAddAlertBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddAlertBottomSheet(
        onAddAlert: _addNewAlert,
      ),
    );
  }

  void _addNewAlert(Map<String, dynamic> newAlert) {
    setState(() {
      _alerts.add(newAlert);
    });
    _filterAlerts();
  }

  void _markAlertComplete(int alertId) {
    setState(() {
      final alertIndex = _alerts.indexWhere((alert) => alert['id'] == alertId);
      if (alertIndex != -1) {
        _alerts[alertIndex]['isCompleted'] = true;
      }
    });
    _filterAlerts();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Irrigation alert marked as complete'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            setState(() {
              final alertIndex =
                  _alerts.indexWhere((alert) => alert['id'] == alertId);
              if (alertIndex != -1) {
                _alerts[alertIndex]['isCompleted'] = false;
              }
            });
            _filterAlerts();
          },
        ),
      ),
    );
  }

  void _deleteAlert(int alertId) {
    final alertIndex = _alerts.indexWhere((alert) => alert['id'] == alertId);
    if (alertIndex != -1) {
      final deletedAlert = _alerts[alertIndex];
      setState(() {
        _alerts.removeAt(alertIndex);
      });
      _filterAlerts();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Alert deleted'),
          action: SnackBarAction(
            label: 'Undo',
            onPressed: () {
              setState(() {
                _alerts.insert(alertIndex, deletedAlert);
              });
              _filterAlerts();
            },
          ),
        ),
      );
    }
  }

  void _snoozeAlert(int alertId) {
    setState(() {
      final alertIndex = _alerts.indexWhere((alert) => alert['id'] == alertId);
      if (alertIndex != -1) {
        final currentTime = _alerts[alertIndex]['scheduledTime'] as DateTime;
        _alerts[alertIndex]['scheduledTime'] =
            currentTime.add(Duration(hours: 1));
      }
    });
    _filterAlerts();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Alert snoozed for 1 hour')),
    );
  }

  void _rescheduleAlert(int alertId) {
    // In a real app, this would open a date/time picker
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Reschedule functionality would open here')),
    );
  }

  void _editAlert(int alertId) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Edit alert functionality would open here')),
    );
  }

  void _viewFieldMap(int alertId) {
    Navigator.pushNamed(context, '/interactive-farm-map');
  }

  void _shareAlert(int alertId) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Share functionality would open here')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Search alerts...',
                  border: InputBorder.none,
                  hintStyle: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  ),
                ),
                style: AppTheme.lightTheme.textTheme.bodyLarge,
                onChanged: _onSearchChanged,
              )
            : Text(
                'Irrigation Alerts',
                style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
        actions: [
          IconButton(
            onPressed: _toggleSearch,
            icon: CustomIconWidget(
              iconName: _isSearching ? 'close' : 'search',
              color: AppTheme.lightTheme.colorScheme.onSurface,
              size: 24,
            ),
          ),
          PopupMenuButton<String>(
            icon: CustomIconWidget(
              iconName: 'more_vert',
              color: AppTheme.lightTheme.colorScheme.onSurface,
              size: 24,
            ),
            onSelected: (value) {
              switch (value) {
                case 'dashboard':
                  Navigator.pushNamed(context, '/farmer-dashboard');
                  break;
                case 'map':
                  Navigator.pushNamed(context, '/interactive-farm-map');
                  break;
                case 'predictions':
                  Navigator.pushNamed(context, '/crop-prediction-results');
                  break;
                case 'fertilizer':
                  Navigator.pushNamed(context, '/fertilizer-recommendations');
                  break;
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'dashboard',
                child: Row(
                  children: [
                    CustomIconWidget(
                      iconName: 'dashboard',
                      color: AppTheme.lightTheme.colorScheme.onSurface,
                      size: 20,
                    ),
                    SizedBox(width: 3.w),
                    Text('Dashboard'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'map',
                child: Row(
                  children: [
                    CustomIconWidget(
                      iconName: 'map',
                      color: AppTheme.lightTheme.colorScheme.onSurface,
                      size: 20,
                    ),
                    SizedBox(width: 3.w),
                    Text('Farm Map'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'predictions',
                child: Row(
                  children: [
                    CustomIconWidget(
                      iconName: 'analytics',
                      color: AppTheme.lightTheme.colorScheme.onSurface,
                      size: 20,
                    ),
                    SizedBox(width: 3.w),
                    Text('Predictions'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'fertilizer',
                child: Row(
                  children: [
                    CustomIconWidget(
                      iconName: 'eco',
                      color: AppTheme.lightTheme.colorScheme.onSurface,
                      size: 20,
                    ),
                    SizedBox(width: 3.w),
                    Text('Fertilizer'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter chips
          FilterChipsWidget(
            selectedFilter: _selectedFilter,
            onFilterChanged: _onFilterChanged,
          ),

          // Main content
          Expanded(
            child: _filteredAlerts.isEmpty
                ? EmptyStateWidget(
                    onAddFirstAlert: _showAddAlertBottomSheet,
                  )
                : RefreshIndicator(
                    onRefresh: _refreshAlerts,
                    color: AppTheme.lightTheme.colorScheme.primary,
                    child: ListView.builder(
                      padding: EdgeInsets.only(bottom: 10.h),
                      itemCount: _filteredAlerts.length,
                      itemBuilder: (context, index) {
                        final alert = _filteredAlerts[index];
                        return AlertCardWidget(
                          alert: alert,
                          onMarkComplete: () =>
                              _markAlertComplete(alert['id'] as int),
                          onSnooze: () => _snoozeAlert(alert['id'] as int),
                          onReschedule: () =>
                              _rescheduleAlert(alert['id'] as int),
                          onDelete: () => _deleteAlert(alert['id'] as int),
                          onEdit: () => _editAlert(alert['id'] as int),
                          onViewMap: () => _viewFieldMap(alert['id'] as int),
                          onShare: () => _shareAlert(alert['id'] as int),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddAlertBottomSheet,
        icon: CustomIconWidget(
          iconName: 'add',
          color: Colors.white,
          size: 24,
        ),
        label: Text(
          'Add Alert',
          style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: AppTheme.lightTheme.colorScheme.primary,
      ),
    );
  }
}
