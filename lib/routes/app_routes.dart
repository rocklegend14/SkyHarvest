import 'package:flutter/material.dart';
import '../presentation/fertilizer_recommendations/fertilizer_recommendations.dart';
import '../presentation/farmer_dashboard/farmer_dashboard.dart';
import '../presentation/interactive_farm_map/interactive_farm_map.dart';
import '../presentation/crop_prediction_results/crop_prediction_results.dart';
import '../presentation/login_screen/login_screen.dart';
import '../presentation/irrigation_alerts/irrigation_alerts.dart';

class AppRoutes {
  // TODO: Add your routes here
  static const String initial = '/';
  static const String fertilizerRecommendations = '/fertilizer-recommendations';
  static const String farmerDashboard = '/farmer-dashboard';
  static const String interactiveFarmMap = '/interactive-farm-map';
  static const String cropPredictionResults = '/crop-prediction-results';
  static const String login = '/login-screen';
  static const String irrigationAlerts = '/irrigation-alerts';

  static Map<String, WidgetBuilder> routes = {
    initial: (context) => const LoginScreen(),
    fertilizerRecommendations: (context) => const FertilizerRecommendations(),
    farmerDashboard: (context) => const FarmerDashboard(),
    interactiveFarmMap: (context) => InteractiveFarmMap(),
    cropPredictionResults: (context) => const CropPredictionResults(),
    login: (context) => const LoginScreen(),
    irrigationAlerts: (context) => const IrrigationAlerts(),
    // TODO: Add your other routes here
  };
}