class UserProfile {
  final String id;
  final String email;
  final String fullName;
  final String? phone;
  final String role;
  final String? farmName;
  final String? farmLocation;
  final double? totalAreaAcres;
  final String? profileImageUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserProfile({
    required this.id,
    required this.email,
    required this.fullName,
    this.phone,
    required this.role,
    this.farmName,
    this.farmLocation,
    this.totalAreaAcres,
    this.profileImageUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'],
      email: json['email'],
      fullName: json['full_name'],
      phone: json['phone'],
      role: json['role'],
      farmName: json['farm_name'],
      farmLocation: json['farm_location'],
      totalAreaAcres:
          json['total_area_acres'] != null
              ? (json['total_area_acres'] as num).toDouble()
              : null,
      profileImageUrl: json['profile_image_url'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'phone': phone,
      'role': role,
      'farm_name': farmName,
      'farm_location': farmLocation,
      'total_area_acres': totalAreaAcres,
      'profile_image_url': profileImageUrl,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  String get roleDisplay {
    switch (role) {
      case 'farmer':
        return 'Farmer';
      case 'admin':
        return 'Administrator';
      case 'consultant':
        return 'Consultant';
      default:
        return role;
    }
  }

  String get initials {
    List<String> nameParts = fullName.split(' ');
    if (nameParts.length >= 2) {
      return '${nameParts[0][0]}${nameParts[1][0]}'.toUpperCase();
    } else if (nameParts.isNotEmpty) {
      return nameParts[0][0].toUpperCase();
    }
    return 'U';
  }
}
