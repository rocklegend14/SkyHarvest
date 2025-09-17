import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/user_settings.dart';
import './supabase_service.dart';
import 'supabase_service.dart';

class SettingsService {
  final SupabaseClient _client = SupabaseService.instance.client;

  // Get user settings
  Future<UserSettings> getUserSettings() async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      final response =
          await _client
              .from('user_settings')
              .select()
              .eq('user_id', user.id)
              .maybeSingle();

      if (response == null) {
        // Create default settings if none exist
        return await createDefaultSettings();
      }

      return UserSettings.fromJson(response);
    } catch (error) {
      throw Exception('Failed to fetch user settings: $error');
    }
  }

  // Update user settings
  Future<UserSettings> updateSettings(Map<String, dynamic> data) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      data['updated_at'] = DateTime.now().toIso8601String();

      final response =
          await _client
              .from('user_settings')
              .update(data)
              .eq('user_id', user.id)
              .select()
              .single();

      return UserSettings.fromJson(response);
    } catch (error) {
      throw Exception('Failed to update settings: $error');
    }
  }

  // Create default settings for new user
  Future<UserSettings> createDefaultSettings() async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      final defaultSettings = {
        'user_id': user.id,
        'weather_alerts': true,
        'fertilizer_reminders': true,
        'irrigation_alerts': true,
        'preferred_units': 'metric',
        'notification_frequency': 'daily',
        'theme_preference': 'light',
        'language': 'en',
      };

      final response =
          await _client
              .from('user_settings')
              .insert(defaultSettings)
              .select()
              .single();

      return UserSettings.fromJson(response);
    } catch (error) {
      throw Exception('Failed to create default settings: $error');
    }
  }

  // Toggle notification setting
  Future<UserSettings> toggleNotificationSetting(
    String settingKey,
    bool value,
  ) async {
    try {
      return await updateSettings({settingKey: value});
    } catch (error) {
      throw Exception('Failed to toggle $settingKey: $error');
    }
  }

  // Update theme preference
  Future<UserSettings> updateThemePreference(String theme) async {
    try {
      return await updateSettings({'theme_preference': theme});
    } catch (error) {
      throw Exception('Failed to update theme preference: $error');
    }
  }

  // Update language preference
  Future<UserSettings> updateLanguagePreference(String language) async {
    try {
      return await updateSettings({'language': language});
    } catch (error) {
      throw Exception('Failed to update language preference: $error');
    }
  }

  // Update units preference
  Future<UserSettings> updateUnitsPreference(String units) async {
    try {
      return await updateSettings({'preferred_units': units});
    } catch (error) {
      throw Exception('Failed to update units preference: $error');
    }
  }

  // Update notification frequency
  Future<UserSettings> updateNotificationFrequency(String frequency) async {
    try {
      return await updateSettings({'notification_frequency': frequency});
    } catch (error) {
      throw Exception('Failed to update notification frequency: $error');
    }
  }

  // Export user data
  Future<Map<String, dynamic>> exportUserData() async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      // Get profile data
      final profileResponse =
          await _client
              .from('user_profiles')
              .select()
              .eq('id', user.id)
              .single();

      // Get fields data
      final fieldsResponse = await _client
          .from('fields')
          .select()
          .eq('owner_id', user.id);

      // Get recommendations data
      final recommendationsResponse = await _client
          .from('fertilizer_recommendations')
          .select()
          .eq('farmer_id', user.id);

      // Get settings data
      final settingsResponse =
          await _client
              .from('user_settings')
              .select()
              .eq('user_id', user.id)
              .maybeSingle();

      return {
        'profile': profileResponse,
        'fields': fieldsResponse,
        'fertilizer_recommendations': recommendationsResponse,
        'settings': settingsResponse,
        'exported_at': DateTime.now().toIso8601String(),
      };
    } catch (error) {
      throw Exception('Failed to export user data: $error');
    }
  }

  // Clear all user data (except account)
  Future<void> clearUserData() async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      // Delete fertilizer recommendations
      await _client
          .from('fertilizer_recommendations')
          .delete()
          .eq('farmer_id', user.id);

      // Delete alerts
      await _client.from('alerts').delete().eq('user_id', user.id);

      // Delete fields
      await _client.from('fields').delete().eq('owner_id', user.id);

      // Reset settings to default
      await _client.from('user_settings').delete().eq('user_id', user.id);

      await createDefaultSettings();
    } catch (error) {
      throw Exception('Failed to clear user data: $error');
    }
  }
}
