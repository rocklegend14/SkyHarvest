class WeatherData {
  final String id;
  final String location;
  final double? latitude;
  final double? longitude;
  final double? temperature;
  final double? humidity;
  final double? rainfall;
  final double? windSpeed;
  final String condition;
  final DateTime recordedAt;
  final DateTime createdAt;

  WeatherData({
    required this.id,
    required this.location,
    this.latitude,
    this.longitude,
    this.temperature,
    this.humidity,
    this.rainfall,
    this.windSpeed,
    required this.condition,
    required this.recordedAt,
    required this.createdAt,
  });

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    return WeatherData(
      id: json['id'] ?? '',
      location: json['location'],
      latitude:
          json['latitude'] != null
              ? (json['latitude'] as num).toDouble()
              : null,
      longitude:
          json['longitude'] != null
              ? (json['longitude'] as num).toDouble()
              : null,
      temperature:
          json['temperature'] != null
              ? (json['temperature'] as num).toDouble()
              : null,
      humidity:
          json['humidity'] != null
              ? (json['humidity'] as num).toDouble()
              : null,
      rainfall:
          json['rainfall'] != null
              ? (json['rainfall'] as num).toDouble()
              : null,
      windSpeed:
          json['wind_speed'] != null
              ? (json['wind_speed'] as num).toDouble()
              : null,
      condition: json['condition'],
      recordedAt: DateTime.parse(json['recorded_at']),
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'location': location,
      'latitude': latitude,
      'longitude': longitude,
      'temperature': temperature,
      'humidity': humidity,
      'rainfall': rainfall,
      'wind_speed': windSpeed,
      'condition': condition,
      'recorded_at': recordedAt.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }

  String get conditionDisplay {
    switch (condition) {
      case 'sunny':
        return 'Sunny';
      case 'cloudy':
        return 'Cloudy';
      case 'rainy':
        return 'Rainy';
      case 'stormy':
        return 'Stormy';
      case 'foggy':
        return 'Foggy';
      default:
        return condition;
    }
  }

  String get conditionIcon {
    switch (condition) {
      case 'sunny':
        return '☀️';
      case 'cloudy':
        return '☁️';
      case 'rainy':
        return '🌧️';
      case 'stormy':
        return '⛈️';
      case 'foggy':
        return '🌫️';
      default:
        return '🌤️';
    }
  }

  String get temperatureDisplay {
    if (temperature == null) return 'N/A';
    return '${temperature!.toStringAsFixed(1)}°C';
  }

  String get humidityDisplay {
    if (humidity == null) return 'N/A';
    return '${humidity!.toStringAsFixed(0)}%';
  }

  String get rainfallDisplay {
    if (rainfall == null) return '0mm';
    return '${rainfall!.toStringAsFixed(1)}mm';
  }

  String get windSpeedDisplay {
    if (windSpeed == null) return 'N/A';
    return '${windSpeed!.toStringAsFixed(1)} km/h';
  }
}
