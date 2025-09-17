import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../models/fertilizer_recommendation.dart';
import '../../services/fertilizer_service.dart';
import '../../widgets/custom_icon_widget.dart';
import './widgets/add_recommendation_bottom_sheet.dart';
import './widgets/filter_bar_widget.dart';
import './widgets/recommendation_card_widget.dart';
import './widgets/statistics_card_widget.dart';
import 'widgets/add_recommendation_bottom_sheet.dart';
import 'widgets/filter_bar_widget.dart';
import 'widgets/recommendation_card_widget.dart';
import 'widgets/statistics_card_widget.dart';

class EnhancedFertilizerRecommendations extends StatefulWidget {
  const EnhancedFertilizerRecommendations({super.key});

  @override
  State<EnhancedFertilizerRecommendations> createState() =>
      _EnhancedFertilizerRecommendationsState();
}

class _EnhancedFertilizerRecommendationsState
    extends State<EnhancedFertilizerRecommendations> {
  final FertilizerService _fertilizerService = FertilizerService();
  List<FertilizerRecommendation> _recommendations = [];
  List<FertilizerRecommendation> _filteredRecommendations = [];
  Map<String, dynamic> _statistics = {};
  bool _isLoading = false;
  String _selectedFilter = 'all';
  String _sortBy = 'date';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final recommendationsResult =
          await _fertilizerService.getFertilizerRecommendations();
      final statisticsResult =
          await _fertilizerService.getFertilizerStatistics();

      setState(() {
        _recommendations = recommendationsResult;
        _statistics = statisticsResult;
        _applyFilters();
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error loading data: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _applyFilters() {
    List<FertilizerRecommendation> filtered = List.from(_recommendations);

    // Apply status filter
    if (_selectedFilter != 'all') {
      filtered =
          filtered.where((rec) => rec.status == _selectedFilter).toList();
    }

    // Apply sorting
    switch (_sortBy) {
      case 'date':
        filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case 'application_date':
        filtered.sort((a, b) => a.applicationDate.compareTo(b.applicationDate));
        break;
      case 'cost':
        filtered.sort(
          (a, b) => (b.costEstimate ?? 0).compareTo(a.costEstimate ?? 0),
        );
        break;
      case 'amount':
        filtered.sort(
          (a, b) => b.recommendedAmount.compareTo(a.recommendedAmount),
        );
        break;
    }

    setState(() => _filteredRecommendations = filtered);
  }

  void _showAddRecommendationSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => AddRecommendationBottomSheet(
            onRecommendationAdded: () {
              _loadData();
            },
          ),
    );
  }

  void _updateRecommendationStatus(String id, String newStatus) async {
    try {
      await _fertilizerService.updateRecommendation(id, {'status': newStatus});
      _loadData();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Recommendation updated successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating recommendation: $e')),
      );
    }
  }

  void _deleteRecommendation(String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Delete Recommendation'),
            content: Text(
              'Are you sure you want to delete this recommendation?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text('Delete', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      try {
        await _fertilizerService.deleteRecommendation(id);
        _loadData();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Recommendation deleted successfully')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting recommendation: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Fertilizer Recommendations',
          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600),
        ),
        actions: [IconButton(onPressed: _loadData, icon: Icon(Icons.refresh))],
      ),
      body:
          _isLoading
              ? Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                onRefresh: _loadData,
                child: SingleChildScrollView(
                  physics: AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Statistics Cards
                      if (_statistics.isNotEmpty)
                        StatisticsCardWidget(statistics: _statistics),

                      SizedBox(height: 20),

                      // Filter and Sort Bar
                      FilterBarWidget(
                        selectedFilter: _selectedFilter,
                        sortBy: _sortBy,
                        onFilterChanged: (filter) {
                          setState(() => _selectedFilter = filter);
                          _applyFilters();
                        },
                        onSortChanged: (sort) {
                          setState(() => _sortBy = sort);
                          _applyFilters();
                        },
                      ),

                      SizedBox(height: 20),

                      // Recommendations List
                      if (_filteredRecommendations.isEmpty)
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
                                'No recommendations found',
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Create your first fertilizer recommendation',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: Colors.grey[500],
                                ),
                              ),
                            ],
                          ),
                        )
                      else
                        ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: _filteredRecommendations.length,
                          itemBuilder: (context, index) {
                            final recommendation =
                                _filteredRecommendations[index];
                            return RecommendationCardWidget(
                              recommendation: recommendation,
                              onStatusChanged: _updateRecommendationStatus,
                              onDelete: _deleteRecommendation,
                            );
                          },
                        ),

                      SizedBox(height: 80), // Space for FAB
                    ],
                  ),
                ),
              ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddRecommendationSheet,
        backgroundColor: Colors.green[600],
        icon: Icon(Icons.add, color: Colors.white),
        label: Text(
          'Add Recommendation',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
