import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sizer/sizer.dart';

import '../../models/weather_data.dart';
import '../../services/weather_service.dart';
import '../../widgets/custom_icon_widget.dart';
import './widgets/current_weather_card.dart';
import './widgets/historical_weather_chart.dart';
import './widgets/weather_alerts_widget.dart';
import './widgets/weather_forecast_list.dart';
import 'widgets/current_weather_card.dart';
import 'widgets/historical_weather_chart.dart';
import 'widgets/weather_alerts_widget.dart';
import 'widgets/weather_forecast_list.dart';

class WeatherIntegration extends StatefulWidget {
  const WeatherIntegration({super.key});

  @override
  State<WeatherIntegration> createState() => _WeatherIntegrationState();
}

class _WeatherIntegrationState extends State<WeatherIntegration>
    with TickerProviderStateMixin {
  final WeatherService _weatherService = WeatherService();

  WeatherData? _currentWeather;
  List<WeatherData> _forecast = [];
  List<WeatherData> _historicalData = [];
  List<Map<String, dynamic>> _weatherAlerts = [];

  bool _isLoadingCurrent = false;
  bool _isLoadingForecast = false;
  bool _isLoadingHistorical = false;
  bool _isLoadingAlerts = false;

  Position? _currentPosition;
  String _selectedLocation = 'Farm Location';

  late TabController _tabController;

  final List<String> _predefinedLocations = [
    'Farm Location',
    'New York',
    'Los Angeles',
    'Chicago',
    'Houston',
    'Phoenix',
    'Philadelphia',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _initializeWeatherData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _initializeWeatherData() async {
    await _requestLocationPermission();
    await _getCurrentPosition();
    await _loadAllWeatherData();
  }

  Future<void> _requestLocationPermission() async {
    try {
      final status = await Permission.location.request();
      if (status.isDenied) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Location permission denied. Using default location.',
            ),
          ),
        );
      }
    } catch (e) {
      print('Permission error: $e');
    }
  }

  Future<void> _getCurrentPosition() async {
    try {
      _currentPosition = await _weatherService.getCurrentLocation();
    } catch (e) {
      print('Location error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unable to get current location. Using default.'),
        ),
      );
    }
  }

  Future<void> _loadAllWeatherData() async {
    await Future.wait([
      _loadCurrentWeather(),
      _loadForecast(),
      _loadHistoricalWeather(),
      _loadWeatherAlerts(),
    ]);
  }

  Future<void> _loadCurrentWeather() async {
    setState(() => _isLoadingCurrent = true);
    try {
      WeatherData currentWeather;
      if (_currentPosition != null && _selectedLocation == 'Farm Location') {
        currentWeather = await _weatherService.getCurrentWeather(
          position: _currentPosition,
        );
      } else {
        currentWeather = await _weatherService.getCurrentWeather(
          location: _selectedLocation,
        );
      }
      setState(() => _currentWeather = currentWeather);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading current weather: $e')),
      );
    } finally {
      setState(() => _isLoadingCurrent = false);
    }
  }

  Future<void> _loadForecast() async {
    setState(() => _isLoadingForecast = true);
    try {
      List<WeatherData> forecast;
      if (_currentPosition != null && _selectedLocation == 'Farm Location') {
        forecast = await _weatherService.getWeatherForecast(
          position: _currentPosition,
        );
      } else {
        forecast = await _weatherService.getWeatherForecast(
          location: _selectedLocation,
        );
      }
      setState(() => _forecast = forecast);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error loading forecast: $e')));
    } finally {
      setState(() => _isLoadingForecast = false);
    }
  }

  Future<void> _loadHistoricalWeather() async {
    setState(() => _isLoadingHistorical = true);
    try {
      final endDate = DateTime.now();
      final startDate = endDate.subtract(Duration(days: 7));

      final historical = await _weatherService.getHistoricalWeatherData(
        location: _selectedLocation,
        startDate: startDate,
        endDate: endDate,
      );
      setState(() => _historicalData = historical);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading historical data: $e')),
      );
    } finally {
      setState(() => _isLoadingHistorical = false);
    }
  }

  Future<void> _loadWeatherAlerts() async {
    setState(() => _isLoadingAlerts = true);
    try {
      final alerts = await _weatherService.getWeatherAlerts();
      setState(() => _weatherAlerts = alerts);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading weather alerts: $e')),
      );
    } finally {
      setState(() => _isLoadingAlerts = false);
    }
  }

  Future<void> _refreshWeatherData() async {
    await _loadAllWeatherData();
  }

  void _changeLocation(String newLocation) {
    setState(() => _selectedLocation = newLocation);
    _loadAllWeatherData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Weather Integration',
          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: Icon(Icons.location_on),
            onSelected: _changeLocation,
            itemBuilder: (context) {
              return _predefinedLocations.map((location) {
                return PopupMenuItem<String>(
                  value: location,
                  child: Row(
                    children: [
                      Icon(
                        _selectedLocation == location
                            ? Icons.check
                            : Icons.location_city,
                        size: 20,
                        color:
                            _selectedLocation == location
                                ? Colors.blue
                                : Colors.grey[600],
                      ),
                      SizedBox(width: 8),
                      Text(location),
                    ],
                  ),
                );
              }).toList();
            },
          ),
          IconButton(onPressed: _refreshWeatherData, icon: Icon(Icons.refresh)),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: [
            Tab(text: 'Current'),
            Tab(text: 'Forecast'),
            Tab(text: 'Historical'),
            Tab(text: 'Alerts'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Current Weather Tab
          RefreshIndicator(
            onRefresh: _refreshWeatherData,
            child: SingleChildScrollView(
              physics: AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Location Info
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue[200]!),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.location_on, color: Colors.blue[700]),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _selectedLocation == 'Farm Location'
                                ? 'Current Farm Location'
                                : _selectedLocation,
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.blue[700],
                            ),
                          ),
                        ),
                        if (_isLoadingCurrent)
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.blue[700],
                              strokeWidth: 2,
                            ),
                          ),
                      ],
                    ),
                  ),

                  SizedBox(height: 20),

                  // Current Weather Card
                  if (_currentWeather != null)
                    CurrentWeatherCard(weatherData: _currentWeather!)
                  else if (!_isLoadingCurrent)
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(40),
                      child: Column(
                        children: [
                          CustomIconWidget(
                            iconPath: 'assets/images/sad_face.svg',
                            height: 80,
                            width: 80,
                          ),
                          SizedBox(height: 20),
                          Text(
                            'Weather data not available',
                            style: TextStyle(
                              fontSize: 16.sp,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),

          // Forecast Tab
          RefreshIndicator(
            onRefresh: _refreshWeatherData,
            child:
                _isLoadingForecast
                    ? Center(child: CircularProgressIndicator())
                    : _forecast.isNotEmpty
                    ? WeatherForecastList(forecast: _forecast)
                    : SingleChildScrollView(
                      physics: AlwaysScrollableScrollPhysics(),
                      child: Container(
                        width: double.infinity,
                        height: MediaQuery.of(context).size.height * 0.6,
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
                              'No forecast data available',
                              style: TextStyle(
                                fontSize: 16.sp,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
          ),

          // Historical Tab
          RefreshIndicator(
            onRefresh: _refreshWeatherData,
            child:
                _isLoadingHistorical
                    ? Center(child: CircularProgressIndicator())
                    : _historicalData.isNotEmpty
                    ? HistoricalWeatherChart(historicalData: _historicalData)
                    : SingleChildScrollView(
                      physics: AlwaysScrollableScrollPhysics(),
                      child: Container(
                        width: double.infinity,
                        height: MediaQuery.of(context).size.height * 0.6,
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
                              'No historical data available',
                              style: TextStyle(
                                fontSize: 16.sp,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
          ),

          // Alerts Tab
          RefreshIndicator(
            onRefresh: _refreshWeatherData,
            child:
                _isLoadingAlerts
                    ? Center(child: CircularProgressIndicator())
                    : WeatherAlertsWidget(alerts: _weatherAlerts),
          ),
        ],
      ),
    );
  }
}
