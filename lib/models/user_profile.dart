/// User Profile model representing extended user information
class UserProfile {
  final int id;
  final int userId;
  final String? phone;
  final DateTime? dateOfBirth;
  final String? gender;
  final String? bio;
  final String? profilePicture;
  final String? location;
  final Map<String, dynamic>? preferences;
  final bool isActive;
  final DateTime? lastLoginAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserProfile({
    required this.id,
    required this.userId,
    this.phone,
    this.dateOfBirth,
    this.gender,
    this.bio,
    this.profilePicture,
    this.location,
    this.preferences,
    required this.isActive,
    this.lastLoginAt,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Create UserProfile from JSON response
  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      phone: json['phone'] as String?,
      dateOfBirth: json['date_of_birth'] != null
          ? DateTime.parse(json['date_of_birth'])
          : null,
      gender: json['gender'] as String?,
      bio: json['bio'] as String?,
      profilePicture: json['profile_picture'] as String?,
      location: json['location'] as String?,
      preferences: json['preferences'] as Map<String, dynamic>?,
      isActive: json['is_active'] ?? true,
      lastLoginAt: json['last_login_at'] != null
          ? DateTime.parse(json['last_login_at'])
          : null,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  /// Convert UserProfile to JSON for API requests
  Map<String, dynamic> toJson() {
    return {
      'phone': phone,
      'date_of_birth': dateOfBirth?.toIso8601String().split('T')[0], // Date only
      'gender': gender,
      'bio': bio,
      'location': location,
      'preferences': preferences,
    };
  }

  /// Convert full UserProfile to JSON (including read-only fields)
  Map<String, dynamic> toFullJson() {
    return {
      'id': id,
      'user_id': userId,
      'phone': phone,
      'date_of_birth': dateOfBirth?.toIso8601String().split('T')[0],
      'gender': gender,
      'bio': bio,
      'profile_picture': profilePicture,
      'location': location,
      'preferences': preferences,
      'is_active': isActive,
      'last_login_at': lastLoginAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Create a copy with updated fields
  UserProfile copyWith({
    int? id,
    int? userId,
    String? phone,
    DateTime? dateOfBirth,
    String? gender,
    String? bio,
    String? profilePicture,
    String? location,
    Map<String, dynamic>? preferences,
    bool? isActive,
    DateTime? lastLoginAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserProfile(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      phone: phone ?? this.phone,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      bio: bio ?? this.bio,
      profilePicture: profilePicture ?? this.profilePicture,
      location: location ?? this.location,
      preferences: preferences ?? this.preferences,
      isActive: isActive ?? this.isActive,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Get preference value by key
  T? getPreference<T>(String key) {
    return preferences?[key] as T?;
  }

  /// Set preference value
  UserProfile setPreference(String key, dynamic value) {
    final newPreferences = Map<String, dynamic>.from(preferences ?? {});
    newPreferences[key] = value;
    return copyWith(preferences: newPreferences);
  }

  @override
  String toString() {
    return 'UserProfile{id: $id, userId: $userId, phone: $phone, location: $location}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserProfile &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          userId == other.userId;

  @override
  int get hashCode => id.hashCode ^ userId.hashCode;
}
