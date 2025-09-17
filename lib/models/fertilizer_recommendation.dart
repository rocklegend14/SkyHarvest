class FertilizerRecommendation {
  final String id;
  final String fieldId;
  final String farmerId;
  final String fertilizerType;
  final double recommendedAmount;
  final DateTime applicationDate;
  final String? applicationMethod;
  final double? costEstimate;
  final String status;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Field? field;

  FertilizerRecommendation({
    required this.id,
    required this.fieldId,
    required this.farmerId,
    required this.fertilizerType,
    required this.recommendedAmount,
    required this.applicationDate,
    this.applicationMethod,
    this.costEstimate,
    required this.status,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
    this.field,
  });

  factory FertilizerRecommendation.fromJson(Map<String, dynamic> json) {
    return FertilizerRecommendation(
      id: json['id'],
      fieldId: json['field_id'],
      farmerId: json['farmer_id'],
      fertilizerType: json['fertilizer_type'],
      recommendedAmount: (json['recommended_amount'] as num).toDouble(),
      applicationDate: DateTime.parse(json['application_date']),
      applicationMethod: json['application_method'],
      costEstimate:
          json['cost_estimate'] != null
              ? (json['cost_estimate'] as num).toDouble()
              : null,
      status: json['status'],
      notes: json['notes'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      field: json['fields'] != null ? Field.fromJson(json['fields']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'field_id': fieldId,
      'farmer_id': farmerId,
      'fertilizer_type': fertilizerType,
      'recommended_amount': recommendedAmount,
      'application_date': applicationDate.toIso8601String().split('T')[0],
      'application_method': applicationMethod,
      'cost_estimate': costEstimate,
      'status': status,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  String get statusDisplay {
    switch (status) {
      case 'pending':
        return 'Pending';
      case 'applied':
        return 'Applied';
      case 'cancelled':
        return 'Cancelled';
      default:
        return status;
    }
  }

  String get fertilizerTypeDisplay {
    switch (fertilizerType) {
      case 'nitrogen':
        return 'Nitrogen';
      case 'phosphorus':
        return 'Phosphorus';
      case 'potassium':
        return 'Potassium';
      case 'organic':
        return 'Organic';
      case 'compound':
        return 'Compound';
      default:
        return fertilizerType;
    }
  }
}

class Field {
  final String id;
  final String name;
  final double areaAcres;
  final String cropType;

  Field({
    required this.id,
    required this.name,
    required this.areaAcres,
    required this.cropType,
  });

  factory Field.fromJson(Map<String, dynamic> json) {
    return Field(
      id: json['id'],
      name: json['name'],
      areaAcres: (json['area_acres'] as num).toDouble(),
      cropType: json['crop_type'],
    );
  }
}
