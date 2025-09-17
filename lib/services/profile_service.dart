import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/user_profile.dart';
import './supabase_service.dart';
import 'supabase_service.dart';

class ProfileService {
  final SupabaseClient _client = SupabaseService.instance.client;
  final ImagePicker _imagePicker = ImagePicker();

  // Get current user profile
  Future<UserProfile> getCurrentUserProfile() async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      final response =
          await _client
              .from('user_profiles')
              .select()
              .eq('id', user.id)
              .single();

      return UserProfile.fromJson(response);
    } catch (error) {
      throw Exception('Failed to fetch user profile: $error');
    }
  }

  // Update user profile
  Future<UserProfile> updateProfile(Map<String, dynamic> data) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      data['updated_at'] = DateTime.now().toIso8601String();

      final response =
          await _client
              .from('user_profiles')
              .update(data)
              .eq('id', user.id)
              .select()
              .single();

      return UserProfile.fromJson(response);
    } catch (error) {
      throw Exception('Failed to update profile: $error');
    }
  }

  // Upload profile image
  Future<String> uploadProfileImage() async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (image == null) {
        throw Exception('No image selected');
      }

      final file = File(image.path);
      final fileName =
          '${user.id}_${DateTime.now().millisecondsSinceEpoch}.jpg';

      await _client.storage.from('profiles').upload('avatars/$fileName', file);

      final url = _client.storage
          .from('profiles')
          .getPublicUrl('avatars/$fileName');

      // Update profile with new image URL
      await updateProfile({'profile_image_url': url});

      return url;
    } catch (error) {
      throw Exception('Failed to upload profile image: $error');
    }
  }

  // Change password
  Future<void> changePassword(String newPassword) async {
    try {
      await _client.auth.updateUser(UserAttributes(password: newPassword));
    } catch (error) {
      throw Exception('Failed to change password: $error');
    }
  }

  // Update email
  Future<void> updateEmail(String newEmail) async {
    try {
      await _client.auth.updateUser(UserAttributes(email: newEmail));
    } catch (error) {
      throw Exception('Failed to update email: $error');
    }
  }

  // Delete account
  Future<void> deleteAccount() async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      // Delete profile data first
      await _client.from('user_profiles').delete().eq('id', user.id);

      // Sign out user
      await _client.auth.signOut();
    } catch (error) {
      throw Exception('Failed to delete account: $error');
    }
  }

  // Get profile statistics
  Future<Map<String, dynamic>> getProfileStatistics() async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      final fieldsData =
          await _client
              .from('fields')
              .select('id')
              .eq('owner_id', user.id)
              .count();

      final recommendationsData =
          await _client
              .from('fertilizer_recommendations')
              .select('id')
              .eq('farmer_id', user.id)
              .count();

      final alertsData =
          await _client
              .from('alerts')
              .select('id')
              .eq('user_id', user.id)
              .eq('is_read', false)
              .count();

      final profile = await getCurrentUserProfile();

      return {
        'total_fields': fieldsData.count ?? 0,
        'total_recommendations': recommendationsData.count ?? 0,
        'unread_alerts': alertsData.count ?? 0,
        'total_farm_area': profile.totalAreaAcres ?? 0.0,
        'account_created': profile.createdAt,
      };
    } catch (error) {
      throw Exception('Failed to fetch profile statistics: $error');
    }
  }

  // Get all user fields
  Future<List<Map<String, dynamic>>> getUserFields() async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      final response = await _client
          .from('fields')
          .select()
          .eq('owner_id', user.id)
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (error) {
      throw Exception('Failed to fetch user fields: $error');
    }
  }

  // Create new field
  Future<Map<String, dynamic>> createField(
    Map<String, dynamic> fieldData,
  ) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      fieldData['owner_id'] = user.id;

      final response =
          await _client.from('fields').insert(fieldData).select().single();

      return response;
    } catch (error) {
      throw Exception('Failed to create field: $error');
    }
  }

  // Update field
  Future<Map<String, dynamic>> updateField(
    String fieldId,
    Map<String, dynamic> fieldData,
  ) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      fieldData['updated_at'] = DateTime.now().toIso8601String();

      final response =
          await _client
              .from('fields')
              .update(fieldData)
              .eq('id', fieldId)
              .eq('owner_id', user.id)
              .select()
              .single();

      return response;
    } catch (error) {
      throw Exception('Failed to update field: $error');
    }
  }

  // Delete field
  Future<void> deleteField(String fieldId) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      await _client
          .from('fields')
          .delete()
          .eq('id', fieldId)
          .eq('owner_id', user.id);
    } catch (error) {
      throw Exception('Failed to delete field: $error');
    }
  }
}
