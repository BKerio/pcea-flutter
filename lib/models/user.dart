/// User model representing the basic user information
class User {
  final int id;
  final String name;
  final String email;
  final String role;
  final String roleDisplay;
  final String? dashboardRoute;
  final DateTime? emailVerifiedAt;
  final DateTime createdAt;
  final DateTime? updatedAt;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.roleDisplay,
    this.dashboardRoute,
    this.emailVerifiedAt,
    required this.createdAt,
    this.updatedAt,
  });

  /// Create User from JSON response
  factory User.fromJson(Map<String, dynamic> json) {
    // Safely extract role information with defaults
    final roleValue = json['role'];
    final roleDisplayValue = json['role_display'];
    
    return User(
      id: json['id'] as int,
      name: json['name'] as String,
      email: json['email'] as String,
      role: roleValue != null ? roleValue.toString() : 'member',
      roleDisplay: roleDisplayValue != null ? roleDisplayValue.toString() : 'Member',
      dashboardRoute: json['dashboard_route']?.toString(),
      emailVerifiedAt: json['email_verified_at'] != null
          ? DateTime.parse(json['email_verified_at'])
          : null,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : DateTime.now(),
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at']) 
          : null,
    );
  }

  /// Convert User to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'role_display': roleDisplay,
      'dashboard_route': dashboardRoute,
      'email_verified_at': emailVerifiedAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  /// Create a copy with updated fields
  User copyWith({
    int? id,
    String? name,
    String? email,
    String? role,
    String? roleDisplay,
    String? dashboardRoute,
    DateTime? emailVerifiedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      roleDisplay: roleDisplay ?? this.roleDisplay,
      dashboardRoute: dashboardRoute ?? this.dashboardRoute,
      emailVerifiedAt: emailVerifiedAt ?? this.emailVerifiedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'User{id: $id, name: $name, email: $email}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is User &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          email == other.email;

  @override
  int get hashCode => id.hashCode ^ email.hashCode;
}
