import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/fertilizer_recommendation.dart';
import './supabase_service.dart';
import 'supabase_service.dart';

class FertilizerService {
  final SupabaseClient _client = SupabaseService.instance.client;

  // Get all fertilizer recommendations for current user
  Future<List<FertilizerRecommendation>> getFertilizerRecommendations() async {
    try {
      final response = await _client
          .from('fertilizer_recommendations')
          .select('''
            id, field_id, farmer_id, fertilizer_type, recommended_amount,
            application_date, application_method, cost_estimate, status, notes,
            created_at, updated_at,
            fields (id, name, area_acres, crop_type)
          ''')
          .eq('farmer_id', _client.auth.currentUser!.id)
          .order('created_at', ascending: false);

      return response
          .map<FertilizerRecommendation>(
            (item) => FertilizerRecommendation.fromJson(item),
          )
          .toList();
    } catch (error) {
      throw Exception('Failed to fetch fertilizer recommendations: $error');
    }
  }

  // Create new fertilizer recommendation
  Future<FertilizerRecommendation> createRecommendation(
    Map<String, dynamic> data,
  ) async {
    try {
      data['farmer_id'] = _client.auth.currentUser!.id;

      final response =
          await _client.from('fertilizer_recommendations').insert(data).select(
            '''
            id, field_id, farmer_id, fertilizer_type, recommended_amount,
            application_date, application_method, cost_estimate, status, notes,
            created_at, updated_at,
            fields (id, name, area_acres, crop_type)
          ''',
          ).single();

      return FertilizerRecommendation.fromJson(response);
    } catch (error) {
      throw Exception('Failed to create fertilizer recommendation: $error');
    }
  }

  // Update fertilizer recommendation
  Future<FertilizerRecommendation> updateRecommendation(
    String id,
    Map<String, dynamic> data,
  ) async {
    try {
      data['updated_at'] = DateTime.now().toIso8601String();

      final response =
          await _client
              .from('fertilizer_recommendations')
              .update(data)
              .eq('id', id)
              .eq('farmer_id', _client.auth.currentUser!.id)
              .select('''
            id, field_id, farmer_id, fertilizer_type, recommended_amount,
            application_date, application_method, cost_estimate, status, notes,
            created_at, updated_at,
            fields (id, name, area_acres, crop_type)
          ''')
              .single();

      return FertilizerRecommendation.fromJson(response);
    } catch (error) {
      throw Exception('Failed to update fertilizer recommendation: $error');
    }
  }

  // Delete fertilizer recommendation
  Future<void> deleteRecommendation(String id) async {
    try {
      await _client
          .from('fertilizer_recommendations')
          .delete()
          .eq('id', id)
          .eq('farmer_id', _client.auth.currentUser!.id);
    } catch (error) {
      throw Exception('Failed to delete fertilizer recommendation: $error');
    }
  }

  // Get recommendations by field
  Future<List<FertilizerRecommendation>> getRecommendationsByField(
    String fieldId,
  ) async {
    try {
      final response = await _client
          .from('fertilizer_recommendations')
          .select('''
            id, field_id, farmer_id, fertilizer_type, recommended_amount,
            application_date, application_method, cost_estimate, status, notes,
            created_at, updated_at,
            fields (id, name, area_acres, crop_type)
          ''')
          .eq('field_id', fieldId)
          .eq('farmer_id', _client.auth.currentUser!.id)
          .order('created_at', ascending: false);

      return response
          .map<FertilizerRecommendation>(
            (item) => FertilizerRecommendation.fromJson(item),
          )
          .toList();
    } catch (error) {
      throw Exception('Failed to fetch field recommendations: $error');
    }
  }

  // Get fertilizer statistics
  Future<Map<String, dynamic>> getFertilizerStatistics() async {
    try {
      final totalData =
          await _client
              .from('fertilizer_recommendations')
              .select('id')
              .eq('farmer_id', _client.auth.currentUser!.id)
              .count();

      final pendingData =
          await _client
              .from('fertilizer_recommendations')
              .select('id')
              .eq('farmer_id', _client.auth.currentUser!.id)
              .eq('status', 'pending')
              .count();

      final appliedData =
          await _client
              .from('fertilizer_recommendations')
              .select('id')
              .eq('farmer_id', _client.auth.currentUser!.id)
              .eq('status', 'applied')
              .count();

      final costData = await _client
          .from('fertilizer_recommendations')
          .select('cost_estimate')
          .eq('farmer_id', _client.auth.currentUser!.id)
          .eq('status', 'applied');

      double totalCost = 0.0;
      for (var item in costData) {
        totalCost += (item['cost_estimate'] as num?)?.toDouble() ?? 0.0;
      }

      return {
        'total_recommendations': totalData.count ?? 0,
        'pending_applications': pendingData.count ?? 0,
        'applied_recommendations': appliedData.count ?? 0,
        'total_cost': totalCost,
      };
    } catch (error) {
      throw Exception('Failed to fetch fertilizer statistics: $error');
    }
  }
}
