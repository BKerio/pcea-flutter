/// Member model representing member-specific information
class Member {
  final int id;
  final String fullName;
  final DateTime dateOfBirth;
  final String? nationalId;
  final String eKanisaNumber;
  final String email;
  final String gender;
  final String maritalStatus;
  final String presbytery;
  final String parish;
  final String congregation;
  final String? primarySchool;
  final bool isBaptized;
  final bool takesHolyCommunion;
  final String? telephone;
  final String? locationCounty;
  final String? locationSubcounty;
  final String? profileImage;
  final bool isActive;
  final int age;
  final List<Dependent> dependencies;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Member({
    required this.id,
    required this.fullName,
    required this.dateOfBirth,
    this.nationalId,
    required this.eKanisaNumber,
    required this.email,
    required this.gender,
    required this.maritalStatus,
    required this.presbytery,
    required this.parish,
    required this.congregation,
    this.primarySchool,
    required this.isBaptized,
    required this.takesHolyCommunion,
    this.telephone,
    this.locationCounty,
    this.locationSubcounty,
    this.profileImage,
    required this.isActive,
    required this.age,
    required this.dependencies,
    required this.createdAt,
    this.updatedAt,
  });

  /// Create Member from JSON response
  factory Member.fromJson(Map<String, dynamic> json) {
    return Member(
      id: json['id'] as int,
      fullName: json['full_name'] as String,
      dateOfBirth: DateTime.parse(json['date_of_birth']),
      nationalId: json['national_id']?.toString(),
      eKanisaNumber: json['e_kanisa_number'] as String,
      email: json['email'] as String,
      gender: json['gender'] as String,
      maritalStatus: json['marital_status'] as String,
      presbytery: json['presbytery'] as String,
      parish: json['parish'] as String,
      congregation: json['congregation'] as String,
      primarySchool: json['primary_school']?.toString(),
      isBaptized: json['is_baptized'] == true || json['is_baptized'] == 1,
      takesHolyCommunion: json['takes_holy_communion'] == true || json['takes_holy_communion'] == 1,
      telephone: json['telephone']?.toString(),
      locationCounty: json['location_county']?.toString(),
      locationSubcounty: json['location_subcounty']?.toString(),
      profileImage: json['profile_image']?.toString(),
      isActive: json['is_active'] == true || json['is_active'] == 1,
      age: json['age'] as int,
      dependencies: (json['dependencies'] as List<dynamic>?)
              ?.map((dep) => Dependent.fromJson(dep as Map<String, dynamic>))
              .toList() ??
          [],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at']) 
          : null,
    );
  }

  /// Convert Member to JSON for API requests
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'date_of_birth': dateOfBirth.toIso8601String().split('T')[0],
      'national_id': nationalId,
      'e_kanisa_number': eKanisaNumber,
      'email': email,
      'gender': gender,
      'marital_status': maritalStatus,
      'presbytery': presbytery,
      'parish': parish,
      'congregation': congregation,
      'primary_school': primarySchool,
      'is_baptized': isBaptized,
      'takes_holy_communion': takesHolyCommunion,
      'telephone': telephone,
      'location_county': locationCounty,
      'location_subcounty': locationSubcounty,
      'profile_image': profileImage,
      'is_active': isActive,
      'age': age,
      'dependencies': dependencies.map((dep) => dep.toJson()).toList(),
    };
  }

  /// Create a copy of Member with updated fields
  Member copyWith({
    int? id,
    String? fullName,
    DateTime? dateOfBirth,
    String? nationalId,
    String? eKanisaNumber,
    String? email,
    String? gender,
    String? maritalStatus,
    String? presbytery,
    String? parish,
    String? congregation,
    String? primarySchool,
    bool? isBaptized,
    bool? takesHolyCommunion,
    String? telephone,
    String? locationCounty,
    String? locationSubcounty,
    String? profileImage,
    bool? isActive,
    int? age,
    List<Dependent>? dependencies,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Member(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      nationalId: nationalId ?? this.nationalId,
      eKanisaNumber: eKanisaNumber ?? this.eKanisaNumber,
      email: email ?? this.email,
      gender: gender ?? this.gender,
      maritalStatus: maritalStatus ?? this.maritalStatus,
      presbytery: presbytery ?? this.presbytery,
      parish: parish ?? this.parish,
      congregation: congregation ?? this.congregation,
      primarySchool: primarySchool ?? this.primarySchool,
      isBaptized: isBaptized ?? this.isBaptized,
      takesHolyCommunion: takesHolyCommunion ?? this.takesHolyCommunion,
      telephone: telephone ?? this.telephone,
      locationCounty: locationCounty ?? this.locationCounty,
      locationSubcounty: locationSubcounty ?? this.locationSubcounty,
      profileImage: profileImage ?? this.profileImage,
      isActive: isActive ?? this.isActive,
      age: age ?? this.age,
      dependencies: dependencies ?? this.dependencies,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Get display name for login method
  String get loginMethodDisplay {
    if (nationalId != null && nationalId!.isNotEmpty) {
      return "National ID or E-Kanisa number";
    }
    return "E-Kanisa number only";
  }

  /// Check if member can login with National ID
  bool get canLoginWithNationalId {
    return nationalId != null && nationalId!.isNotEmpty;
  }
}

/// Dependent model representing member dependents
class Dependent {
  final int? id;
  final String name;
  final int yearOfBirth;
  final String? birthCertNumber;
  final bool isBaptized;
  final bool takesHolyCommunion;
  final String? school;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Dependent({
    this.id,
    required this.name,
    required this.yearOfBirth,
    this.birthCertNumber,
    required this.isBaptized,
    required this.takesHolyCommunion,
    this.school,
    this.createdAt,
    this.updatedAt,
  });

  /// Create Dependent from JSON response
  factory Dependent.fromJson(Map<String, dynamic> json) {
    return Dependent(
      id: json['id'] as int?,
      name: json['name'] as String,
      yearOfBirth: json['year_of_birth'] as int,
      birthCertNumber: json['birth_cert_number']?.toString(),
      isBaptized: json['is_baptized'] == true || json['is_baptized'] == 1,
      takesHolyCommunion: json['takes_holy_communion'] == true || json['takes_holy_communion'] == 1,
      school: json['school']?.toString(),
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : null,
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at']) 
          : null,
    );
  }

  /// Convert Dependent to JSON for API requests
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'year_of_birth': yearOfBirth,
      'birth_cert_number': birthCertNumber,
      'is_baptized': isBaptized,
      'takes_holy_communion': takesHolyCommunion,
      'school': school,
    };
  }

  /// Create a copy of Dependent with updated fields
  Dependent copyWith({
    int? id,
    String? name,
    int? yearOfBirth,
    String? birthCertNumber,
    bool? isBaptized,
    bool? takesHolyCommunion,
    String? school,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Dependent(
      id: id ?? this.id,
      name: name ?? this.name,
      yearOfBirth: yearOfBirth ?? this.yearOfBirth,
      birthCertNumber: birthCertNumber ?? this.birthCertNumber,
      isBaptized: isBaptized ?? this.isBaptized,
      takesHolyCommunion: takesHolyCommunion ?? this.takesHolyCommunion,
      school: school ?? this.school,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Get calculated age based on year of birth
  int get age {
    return DateTime.now().year - yearOfBirth;
  }
}

/// Member registration request model
class MemberRegistrationRequest {
  final String fullName;
  final DateTime dateOfBirth;
  final String? nationalId;
  final String email;
  final String gender;
  final String maritalStatus;
  final String presbytery;
  final String parish;
  final String congregation;
  final String? primarySchool;
  final bool isBaptized;
  final bool takesHolyCommunion;
  final String? telephone;
  final String? locationCounty;
  final String? locationSubcounty;
  final String password;
  final String passwordConfirmation;
  final List<Dependent> dependencies;

  MemberRegistrationRequest({
    required this.fullName,
    required this.dateOfBirth,
    this.nationalId,
    required this.email,
    required this.gender,
    required this.maritalStatus,
    required this.presbytery,
    required this.parish,
    required this.congregation,
    this.primarySchool,
    required this.isBaptized,
    required this.takesHolyCommunion,
    this.telephone,
    this.locationCounty,
    this.locationSubcounty,
    required this.password,
    required this.passwordConfirmation,
    required this.dependencies,
  });

  /// Convert to JSON for API request
  Map<String, dynamic> toJson() {
    return {
      'full_name': fullName,
      'date_of_birth': dateOfBirth.toIso8601String().split('T')[0],
      'national_id': nationalId,
      'email': email,
      'gender': gender,
      'marital_status': maritalStatus,
      'presbytery': presbytery,
      'parish': parish,
      'congregation': congregation,
      'primary_school': primarySchool,
      'is_baptized': isBaptized,
      'takes_holy_communion': takesHolyCommunion,
      'telephone': telephone,
      'location_county': locationCounty,
      'location_subcounty': locationSubcounty,
      'password': password,
      'password_confirmation': passwordConfirmation,
      'dependencies': dependencies.map((dep) => dep.toJson()).toList(),
    };
  }

  /// Validate the registration data
  List<String> validate() {
    final errors = <String>[];

    // Required fields validation
    if (fullName.trim().isEmpty) errors.add('Full name is required');
    if (email.trim().isEmpty) errors.add('Email is required');
    if (!email.contains('@')) errors.add('Please enter a valid email');
    if (gender.isEmpty) errors.add('Gender is required');
    if (maritalStatus.isEmpty) errors.add('Marital status is required');
    if (presbytery.trim().isEmpty) errors.add('Presbytery is required');
    if (parish.trim().isEmpty) errors.add('Parish is required');
    if (congregation.trim().isEmpty) errors.add('Congregation is required');
    if (password.length < 6) errors.add('Password must be at least 6 characters');
    if (password != passwordConfirmation) errors.add('Passwords do not match');

    // Age-based validation
    final age = DateTime.now().year - dateOfBirth.year;
    if (age >= 18 && (nationalId == null || nationalId!.trim().isEmpty)) {
      errors.add('National ID is required for members 18 years and above');
    }

    // Dependent validation
    for (int i = 0; i < dependencies.length; i++) {
      final dep = dependencies[i];
      if (dep.name.trim().isEmpty) {
        errors.add('Dependent ${i + 1}: Name is required');
      }
      if (dep.yearOfBirth < 1900 || dep.yearOfBirth > DateTime.now().year) {
        errors.add('Dependent ${i + 1}: Invalid year of birth');
      }
      if (dep.birthCertNumber != null && 
          dep.birthCertNumber!.isNotEmpty && 
          dep.birthCertNumber!.length != 9) {
        errors.add('Dependent ${i + 1}: Birth certificate number must be exactly 9 digits');
      }
    }

    return errors;
  }
}

/// Member login response model
class MemberLoginResponse {
  final String message;
  final MemberUser user;
  final Member member;
  final String accessToken;
  final String tokenType;

  MemberLoginResponse({
    required this.message,
    required this.user,
    required this.member,
    required this.accessToken,
    required this.tokenType,
  });

  factory MemberLoginResponse.fromJson(Map<String, dynamic> json) {
    return MemberLoginResponse(
      message: json['message'] as String,
      user: MemberUser.fromJson(json['user'] as Map<String, dynamic>),
      member: Member.fromJson(json['member'] as Map<String, dynamic>),
      accessToken: json['access_token'] as String,
      tokenType: json['token_type'] as String,
    );
  }
}

/// Member user model (different from regular user)
class MemberUser {
  final int id;
  final String name;
  final String email;
  final String role;
  final String? eKanisaNumber;
  final String? nationalId;
  final bool isMember;

  MemberUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.eKanisaNumber,
    this.nationalId,
    required this.isMember,
  });

  factory MemberUser.fromJson(Map<String, dynamic> json) {
    return MemberUser(
      id: json['id'] as int,
      name: json['name'] as String,
      email: json['email'] as String,
      role: json['role'] as String,
      eKanisaNumber: json['e_kanisa_number']?.toString(),
      nationalId: json['national_id']?.toString(),
      isMember: json['is_member'] == true || json['is_member'] == 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'e_kanisa_number': eKanisaNumber,
      'national_id': nationalId,
      'is_member': isMember,
    };
  }
}
