class UserSettings {
  final String id;
  final String userId;
  final bool weatherAlerts;
  final bool fertilizerReminders;
  final bool irrigationAlerts;
  final String preferredUnits;
  final String notificationFrequency;
  final String themePreference;
  final String language;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserSettings({
    required this.id,
    required this.userId,
    required this.weatherAlerts,
    required this.fertilizerReminders,
    required this.irrigationAlerts,
    required this.preferredUnits,
    required this.notificationFrequency,
    required this.themePreference,
    required this.language,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserSettings.fromJson(Map<String, dynamic> json) {
    return UserSettings(
      id: json['id'],
      userId: json['user_id'],
      weatherAlerts: json['weather_alerts'] ?? true,
      fertilizerReminders: json['fertilizer_reminders'] ?? true,
      irrigationAlerts: json['irrigation_alerts'] ?? true,
      preferredUnits: json['preferred_units'] ?? 'metric',
      notificationFrequency: json['notification_frequency'] ?? 'daily',
      themePreference: json['theme_preference'] ?? 'light',
      language: json['language'] ?? 'en',
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'weather_alerts': weatherAlerts,
      'fertilizer_reminders': fertilizerReminders,
      'irrigation_alerts': irrigationAlerts,
      'preferred_units': preferredUnits,
      'notification_frequency': notificationFrequency,
      'theme_preference': themePreference,
      'language': language,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  String get unitsDisplay {
    switch (preferredUnits) {
      case 'metric':
        return 'Metric (°C, km/h, mm)';
      case 'imperial':
        return 'Imperial (°F, mph, in)';
      default:
        return preferredUnits;
    }
  }

  String get frequencyDisplay {
    switch (notificationFrequency) {
      case 'daily':
        return 'Daily';
      case 'weekly':
        return 'Weekly';
      case 'monthly':
        return 'Monthly';
      case 'immediate':
        return 'Immediate';
      default:
        return notificationFrequency;
    }
  }

  String get themeDisplay {
    switch (themePreference) {
      case 'light':
        return 'Light';
      case 'dark':
        return 'Dark';
      case 'system':
        return 'System Default';
      default:
        return themePreference;
    }
  }

  String get languageDisplay {
    switch (language) {
      case 'en':
        return 'English';
      case 'es':
        return 'Spanish';
      case 'fr':
        return 'French';
      case 'de':
        return 'German';
      default:
        return language;
    }
  }
}
