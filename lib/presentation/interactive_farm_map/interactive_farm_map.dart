import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/field_bottom_sheet_widget.dart';
import './widgets/filter_menu_widget.dart';
import './widgets/map_controls_widget.dart';

class InteractiveFarmMap extends StatefulWidget {
  @override
  _InteractiveFarmMapState createState() => _InteractiveFarmMapState();
}

class _InteractiveFarmMapState extends State<InteractiveFarmMap> {
  GoogleMapController? _mapController;
  Position? _currentPosition;
  bool _isLocationPermissionGranted = false;
  bool _isSatelliteView = false;
  bool _isDrawingMode = false;
  bool _showFilterMenu = false;
  Map<String, dynamic>? _selectedField;

  // Filter states
  List<String> _selectedCropTypes = [];
  List<String> _selectedHealthStatuses = [];
  List<String> _selectedIrrigationZones = [];

  Set<Polygon> _polygons = {};
  Set<Marker> _markers = {};

  // Mock field data
  final List<Map<String, dynamic>> _fieldData = [
    {
      "id": "field_001",
      "cropType": "Wheat",
      "plantingDate": "March 15, 2024",
      "size": 12.5,
      "healthStatus": "Excellent",
      "irrigationZone": "Zone A",
      "coordinates": [
        {"lat": 37.7849, "lng": -122.4094},
        {"lat": 37.7849, "lng": -122.4084},
        {"lat": 37.7839, "lng": -122.4084},
        {"lat": 37.7839, "lng": -122.4094},
      ],
      "centerLat": 37.7844,
      "centerLng": -122.4089,
    },
    {
      "id": "field_002",
      "cropType": "Corn",
      "plantingDate": "April 2, 2024",
      "size": 8.3,
      "healthStatus": "Good",
      "irrigationZone": "Zone B",
      "coordinates": [
        {"lat": 37.7829, "lng": -122.4074},
        {"lat": 37.7829, "lng": -122.4064},
        {"lat": 37.7819, "lng": -122.4064},
        {"lat": 37.7819, "lng": -122.4074},
      ],
      "centerLat": 37.7824,
      "centerLng": -122.4069,
    },
    {
      "id": "field_003",
      "cropType": "Soybeans",
      "plantingDate": "May 10, 2024",
      "size": 15.7,
      "healthStatus": "Moderate",
      "irrigationZone": "Zone A",
      "coordinates": [
        {"lat": 37.7809, "lng": -122.4054},
        {"lat": 37.7809, "lng": -122.4044},
        {"lat": 37.7799, "lng": -122.4044},
        {"lat": 37.7799, "lng": -122.4054},
      ],
      "centerLat": 37.7804,
      "centerLng": -122.4049,
    },
    {
      "id": "field_004",
      "cropType": "Tomatoes",
      "plantingDate": "June 1, 2024",
      "size": 6.2,
      "healthStatus": "Poor",
      "irrigationZone": "Zone C",
      "coordinates": [
        {"lat": 37.7789, "lng": -122.4034},
        {"lat": 37.7789, "lng": -122.4024},
        {"lat": 37.7779, "lng": -122.4024},
        {"lat": 37.7779, "lng": -122.4034},
      ],
      "centerLat": 37.7784,
      "centerLng": -122.4029,
    },
  ];

  @override
  void initState() {
    super.initState();
    _initializeMap();
  }

  Future<void> _initializeMap() async {
    await _requestLocationPermission();
    await _getCurrentLocation();
    _createPolygonsAndMarkers();
  }

  Future<void> _requestLocationPermission() async {
    if (kIsWeb) {
      _isLocationPermissionGranted = true;
      return;
    }

    final status = await Permission.location.request();
    setState(() {
      _isLocationPermissionGranted = status.isGranted;
    });

    if (!status.isGranted) {
      _showPermissionDialog();
    }
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Location Permission Required'),
        content: Text(
            'This app needs location access to show your position on the map and provide location-based features.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            child: Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  Future<void> _getCurrentLocation() async {
    if (!_isLocationPermissionGranted) return;

    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
        _currentPosition = position;
      });
    } catch (e) {
      print('Error getting location: $e');
    }
  }

  void _createPolygonsAndMarkers() {
    final polygons = <Polygon>{};
    final markers = <Marker>{};

    for (final field in _getFilteredFields()) {
      final coordinates = (field['coordinates'] as List).map((coord) {
        return LatLng(coord['lat'] as double, coord['lng'] as double);
      }).toList();

      // Create polygon
      polygons.add(
        Polygon(
          polygonId: PolygonId(field['id'] as String),
          points: coordinates,
          fillColor: _getHealthStatusColor(field['healthStatus'] as String)
              .withValues(alpha: 0.3),
          strokeColor: _getHealthStatusColor(field['healthStatus'] as String),
          strokeWidth: 2,
          onTap: () => _onFieldTapped(field),
        ),
      );

      // Create marker at field center
      markers.add(
        Marker(
          markerId: MarkerId(field['id'] as String),
          position: LatLng(
              field['centerLat'] as double, field['centerLng'] as double),
          infoWindow: InfoWindow(
            title: field['cropType'] as String,
            snippet: 'Health: ${field['healthStatus']}',
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(
              _getMarkerHue(field['healthStatus'] as String)),
          onTap: () => _onFieldTapped(field),
        ),
      );
    }

    setState(() {
      _polygons = polygons;
      _markers = markers;
    });
  }

  List<Map<String, dynamic>> _getFilteredFields() {
    return _fieldData.where((field) {
      final cropMatch = _selectedCropTypes.isEmpty ||
          _selectedCropTypes.contains(field['cropType']);
      final healthMatch = _selectedHealthStatuses.isEmpty ||
          _selectedHealthStatuses.contains(field['healthStatus']);
      final zoneMatch = _selectedIrrigationZones.isEmpty ||
          _selectedIrrigationZones.contains(field['irrigationZone']);

      return cropMatch && healthMatch && zoneMatch;
    }).toList();
  }

  Color _getHealthStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'excellent':
        return AppTheme.successLight;
      case 'good':
        return AppTheme.lightTheme.primaryColor;
      case 'moderate':
        return AppTheme.warningLight;
      case 'poor':
        return AppTheme.lightTheme.colorScheme.error;
      default:
        return Colors.grey;
    }
  }

  double _getMarkerHue(String status) {
    switch (status.toLowerCase()) {
      case 'excellent':
        return BitmapDescriptor.hueGreen;
      case 'good':
        return BitmapDescriptor.hueBlue;
      case 'moderate':
        return BitmapDescriptor.hueOrange;
      case 'poor':
        return BitmapDescriptor.hueRed;
      default:
        return BitmapDescriptor.hueViolet;
    }
  }

  void _onFieldTapped(Map<String, dynamic> field) {
    HapticFeedback.lightImpact();
    setState(() {
      _selectedField = field;
    });
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;

    // Set initial camera position to user location or default
    if (_currentPosition != null) {
      _mapController!.animateCamera(
        CameraUpdate.newLatLng(
          LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
        ),
      );
    }
  }

  void _centerOnUserLocation() async {
    if (_mapController == null) return;

    if (_currentPosition == null) {
      await _getCurrentLocation();
    }

    if (_currentPosition != null) {
      _mapController!.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
          15.0,
        ),
      );
    }
  }

  void _toggleMapType() {
    setState(() {
      _isSatelliteView = !_isSatelliteView;
    });
  }

  void _showFilterMenuDialog() {
    setState(() {
      _showFilterMenu = true;
    });
  }

  void _hideFilterMenu() {
    setState(() {
      _showFilterMenu = false;
    });
  }

  void _applyFilters() {
    _createPolygonsAndMarkers();
    _hideFilterMenu();
  }

  void _clearFilters() {
    setState(() {
      _selectedCropTypes.clear();
      _selectedHealthStatuses.clear();
      _selectedIrrigationZones.clear();
    });
    _createPolygonsAndMarkers();
  }

  void _closeBottomSheet() {
    setState(() {
      _selectedField = null;
    });
  }

  void _navigateToGetPrediction() {
    Navigator.pushNamed(context, '/crop-prediction-results');
  }

  void _navigateToScheduleIrrigation() {
    Navigator.pushNamed(context, '/irrigation-alerts');
  }

  void _navigateToViewHistory() {
    Navigator.pushNamed(context, '/farmer-dashboard');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Google Map
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(
              target: _currentPosition != null
                  ? LatLng(
                      _currentPosition!.latitude, _currentPosition!.longitude)
                  : LatLng(37.7849, -122.4094), // Default to San Francisco
              zoom: 14.0,
            ),
            mapType: _isSatelliteView ? MapType.satellite : MapType.normal,
            polygons: _polygons,
            markers: _markers,
            myLocationEnabled: _isLocationPermissionGranted,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            mapToolbarEnabled: false,
            onTap: (LatLng position) {
              if (_selectedField != null) {
                _closeBottomSheet();
              }
            },
            onLongPress: _isDrawingMode
                ? null
                : (LatLng position) {
                    HapticFeedback.mediumImpact();
                    // Future enhancement: Start drawing mode
                  },
          ),

          // Map Controls
          MapControlsWidget(
            onLocationPressed: _centerOnUserLocation,
            onLayerToggle: _toggleMapType,
            onFilterPressed: _showFilterMenuDialog,
            isSatelliteView: _isSatelliteView,
          ),

          // Filter Menu Overlay
          if (_showFilterMenu)
            Positioned.fill(
              child: GestureDetector(
                onTap: _hideFilterMenu,
                child: Container(
                  color: Colors.black.withValues(alpha: 0.5),
                  child: Center(
                    child: FilterMenuWidget(
                      selectedCropTypes: _selectedCropTypes,
                      selectedHealthStatuses: _selectedHealthStatuses,
                      selectedIrrigationZones: _selectedIrrigationZones,
                      onCropTypesChanged: (types) {
                        setState(() {
                          _selectedCropTypes = types;
                        });
                      },
                      onHealthStatusesChanged: (statuses) {
                        setState(() {
                          _selectedHealthStatuses = statuses;
                        });
                      },
                      onIrrigationZonesChanged: (zones) {
                        setState(() {
                          _selectedIrrigationZones = zones;
                        });
                      },
                      onApplyFilters: _applyFilters,
                      onClearFilters: _clearFilters,
                    ),
                  ),
                ),
              ),
            ),

          // Field Bottom Sheet
          if (_selectedField != null)
            FieldBottomSheetWidget(
              selectedField: _selectedField,
              onGetPrediction: _navigateToGetPrediction,
              onScheduleIrrigation: _navigateToScheduleIrrigation,
              onViewHistory: _navigateToViewHistory,
              onClose: _closeBottomSheet,
            ),

          // Back button
          Positioned(
            top: 8.h,
            left: 4.w,
            child: Container(
              width: 12.w,
              height: 6.h,
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.surface,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => Navigator.pop(context),
                  borderRadius: BorderRadius.circular(8),
                  child: Center(
                    child: CustomIconWidget(
                      iconName: 'arrow_back',
                      color: AppTheme.lightTheme.colorScheme.onSurface,
                      size: 24,
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Loading indicator for location
          if (!_isLocationPermissionGranted || _currentPosition == null)
            Positioned(
              bottom: 20.h,
              left: 4.w,
              right: 4.w,
              child: Container(
                padding: EdgeInsets.all(4.w),
                decoration: BoxDecoration(
                  color: AppTheme.lightTheme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: 5.w,
                      height: 5.w,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppTheme.lightTheme.primaryColor,
                        ),
                      ),
                    ),
                    SizedBox(width: 3.w),
                    Expanded(
                      child: Text(
                        _isLocationPermissionGranted
                            ? 'Getting your location...'
                            : 'Location permission required for full functionality',
                        style: AppTheme.lightTheme.textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }
}