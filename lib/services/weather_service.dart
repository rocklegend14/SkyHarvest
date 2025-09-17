import 'dart:convert';

import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/weather_data.dart';
import './supabase_service.dart';
import 'supabase_service.dart';

class WeatherService {
  final SupabaseClient _client = SupabaseService.instance.client;
  static const String _apiKey = String.fromEnvironment('OPENWEATHER_API_KEY');
  static const String _baseUrl = 'https://api.openweathermap.org/data/2.5';

  // Get current weather from external API
  Future<WeatherData> getCurrentWeather({
    Position? position,
    String? location,
  }) async {
    try {
      String url;

      if (position != null) {
        url =
            '$_baseUrl/weather?lat=${position.latitude}&lon=${position.longitude}&appid=$_apiKey&units=metric';
      } else if (location != null) {
        url = '$_baseUrl/weather?q=$location&appid=$_apiKey&units=metric';
      } else {
        throw Exception('Either position or location must be provided');
      }

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        final weatherData = WeatherData(
          id: '',
          location: data['name'],
          latitude: data['coord']['lat']?.toDouble(),
          longitude: data['coord']['lon']?.toDouble(),
          temperature: data['main']['temp']?.toDouble(),
          humidity: data['main']['humidity']?.toDouble(),
          rainfall: (data['rain']?['1h'] ?? 0.0)?.toDouble(),
          windSpeed: data['wind']['speed']?.toDouble(),
          condition: _mapWeatherCondition(data['weather'][0]['main']),
          recordedAt: DateTime.now(),
          createdAt: DateTime.now(),
        );

        // Save to Supabase for historical data
        await saveWeatherData(weatherData);

        return weatherData;
      } else {
        throw Exception('Failed to fetch weather data: ${response.statusCode}');
      }
    } catch (error) {
      throw Exception('Weather API error: $error');
    }
  }

  // Get weather forecast
  Future<List<WeatherData>> getWeatherForecast({
    Position? position,
    String? location,
    int days = 5,
  }) async {
    try {
      String url;

      if (position != null) {
        url =
            '$_baseUrl/forecast?lat=${position.latitude}&lon=${position.longitude}&appid=$_apiKey&units=metric';
      } else if (location != null) {
        url = '$_baseUrl/forecast?q=$location&appid=$_apiKey&units=metric';
      } else {
        throw Exception('Either position or location must be provided');
      }

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<WeatherData> forecast = [];

        for (var item in data['list'].take(days * 8)) {
          // 8 forecasts per day (3-hour intervals)
          forecast.add(
            WeatherData(
              id: '',
              location: data['city']['name'],
              latitude: data['city']['coord']['lat']?.toDouble(),
              longitude: data['city']['coord']['lon']?.toDouble(),
              temperature: item['main']['temp']?.toDouble(),
              humidity: item['main']['humidity']?.toDouble(),
              rainfall: (item['rain']?['3h'] ?? 0.0)?.toDouble(),
              windSpeed: item['wind']['speed']?.toDouble(),
              condition: _mapWeatherCondition(item['weather'][0]['main']),
              recordedAt: DateTime.fromMillisecondsSinceEpoch(
                item['dt'] * 1000,
              ),
              createdAt: DateTime.now(),
            ),
          );
        }

        return forecast;
      } else {
        throw Exception(
          'Failed to fetch forecast data: ${response.statusCode}',
        );
      }
    } catch (error) {
      throw Exception('Forecast API error: $error');
    }
  }

  // Save weather data to Supabase
  Future<WeatherData> saveWeatherData(WeatherData weatherData) async {
    try {
      final response =
          await _client
              .from('weather_data')
              .insert(weatherData.toJson())
              .select()
              .single();

      return WeatherData.fromJson(response);
    } catch (error) {
      throw Exception('Failed to save weather data: $error');
    }
  }

  // Get historical weather data from Supabase
  Future<List<WeatherData>> getHistoricalWeatherData({
    String? location,
    DateTime? startDate,
    DateTime? endDate,
    int limit = 50,
  }) async {
    try {
      var query = _client.from('weather_data').select();

      if (location != null) {
        query = query.eq('location', location);
      }

      if (startDate != null) {
        query = query.gte('recorded_at', startDate.toIso8601String());
      }

      if (endDate != null) {
        query = query.lte('recorded_at', endDate.toIso8601String());
      }

      final response = await query
          .order('recorded_at', ascending: false)
          .limit(limit);

      return response
          .map<WeatherData>((item) => WeatherData.fromJson(item))
          .toList();
    } catch (error) {
      throw Exception('Failed to fetch historical weather data: $error');
    }
  }

  // Get current location
  Future<Position> getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Location services are disabled');
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permissions are denied');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permissions are permanently denied');
      }

      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
    } catch (error) {
      throw Exception('Location error: $error');
    }
  }

  // Map weather condition from API to our enum
  String _mapWeatherCondition(String apiCondition) {
    switch (apiCondition.toLowerCase()) {
      case 'clear':
        return 'sunny';
      case 'clouds':
        return 'cloudy';
      case 'rain':
      case 'drizzle':
        return 'rainy';
      case 'thunderstorm':
        return 'stormy';
      case 'mist':
      case 'fog':
        return 'foggy';
      default:
        return 'cloudy';
    }
  }

  // Get weather alerts based on conditions
  Future<List<Map<String, dynamic>>> getWeatherAlerts() async {
    try {
      final currentWeather = await getCurrentWeather(location: 'Farm Location');
      List<Map<String, dynamic>> alerts = [];

      // Check for extreme weather conditions
      if (currentWeather.rainfall != null && currentWeather.rainfall! > 10) {
        alerts.add({
          'type': 'heavy_rain',
          'priority': 'high',
          'title': 'Heavy Rainfall Alert',
          'description':
              'Heavy rainfall detected (${currentWeather.rainfall}mm). Consider drainage and equipment protection.',
        });
      }

      if (currentWeather.windSpeed != null && currentWeather.windSpeed! > 30) {
        alerts.add({
          'type': 'high_wind',
          'priority': 'medium',
          'title': 'High Wind Alert',
          'description':
              'Strong winds detected (${currentWeather.windSpeed} km/h). Secure loose equipment.',
        });
      }

      if (currentWeather.temperature != null &&
          currentWeather.temperature! < 0) {
        alerts.add({
          'type': 'frost',
          'priority': 'critical',
          'title': 'Frost Warning',
          'description':
              'Temperature below freezing (${currentWeather.temperature}°C). Protect sensitive crops.',
        });
      }

      return alerts;
    } catch (error) {
      throw Exception('Failed to generate weather alerts: $error');
    }
  }
}
