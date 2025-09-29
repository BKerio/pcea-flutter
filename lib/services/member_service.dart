import '../models/member.dart';
import 'api_service.dart';

/// Service for handling member-specific operations
class MemberService {
  static final MemberService _instance = MemberService._internal();
  factory MemberService() => _instance;
  MemberService._internal();

  Member? _currentMember;

  /// Get current member
  Member? get currentMember => _currentMember;

  /// Register a new member
  Future<MemberAuthResult> register(MemberRegistrationRequest request) async {
    try {
      // Validate request
      final validationErrors = request.validate();
      if (validationErrors.isNotEmpty) {
        return MemberAuthResult.failure(
          'Validation failed',
          validationErrors,
        );
      }

      final response = await ApiService.registerMember(
        fullName: request.fullName,
        dateOfBirth: request.dateOfBirth,
        nationalId: request.nationalId,
        email: request.email,
        gender: request.gender,
        maritalStatus: request.maritalStatus,
        presbytery: request.presbytery,
        parish: request.parish,
        congregation: request.congregation,
        primarySchool: request.primarySchool,
        isBaptized: request.isBaptized,
        takesHolyCommunion: request.takesHolyCommunion,
        telephone: request.telephone,
        locationCounty: request.locationCounty,
        locationSubcounty: request.locationSubcounty,
        password: request.password,
        passwordConfirmation: request.passwordConfirmation,
        dependencies: request.dependencies.map((dep) => dep.toJson()).toList(),
      );

      if (response.isSuccess && response.data != null) {
        // Parse member data
        if (response.data['member'] != null) {
          _currentMember = Member.fromJson(response.data['member']);
        }
        
        return MemberAuthResult.success(
          response.data['message'] ?? 'Registration successful',
          loginInfo: response.data['login_info'],
        );
      } else {
        return MemberAuthResult.failure(response.message, response.errorMessages);
      }
    } catch (e) {
      return MemberAuthResult.failure('Registration failed', [e.toString()]);
    }
  }

  /// Login member with identifier (National ID or E-Kanisa number)
  Future<MemberAuthResult> login({
    required String identifier,
    required String password,
  }) async {
    try {
      final response = await ApiService.memberLogin(
        identifier: identifier,
        password: password,
      );

      if (response.isSuccess && response.data != null) {
        // Parse member data
        if (response.data['member'] != null) {
          _currentMember = Member.fromJson(response.data['member']);
        }
        
        return MemberAuthResult.success(
          response.data['message'] ?? 'Login successful',
          member: _currentMember,
        );
      } else {
        return MemberAuthResult.failure(response.message, response.errorMessages);
      }
    } catch (e) {
      return MemberAuthResult.failure('Login failed', [e.toString()]);
    }
  }

  /// Get member profile
  Future<MemberResult> getProfile() async {
    try {
      final response = await ApiService.getMemberProfile();
      
      if (response.isSuccess && response.data != null) {
        _currentMember = Member.fromJson(response.data['member']);
        return MemberResult.success('Profile loaded successfully', _currentMember);
      } else {
        return MemberResult.failure(response.message, response.errorMessages);
      }
    } catch (e) {
      return MemberResult.failure('Failed to load profile', [e.toString()]);
    }
  }

  /// Update member profile
  Future<MemberResult> updateProfile(Map<String, dynamic> data) async {
    try {
      final response = await ApiService.updateMemberProfile(data);
      
      if (response.isSuccess && response.data != null) {
        _currentMember = Member.fromJson(response.data['member']);
        return MemberResult.success('Profile updated successfully', _currentMember);
      } else {
        return MemberResult.failure(response.message, response.errorMessages);
      }
    } catch (e) {
      return MemberResult.failure('Failed to update profile', [e.toString()]);
    }
  }

  /// Update member avatar
  Future<ServiceResult> updateAvatar(String imagePath) async {
    try {
      final response = await ApiService.updateMemberAvatar(imagePath);
      
      if (response.isSuccess) {
        return ServiceResult.success('Avatar updated successfully');
      } else {
        return ServiceResult.failure(response.message, response.errorMessages);
      }
    } catch (e) {
      return ServiceResult.failure('Failed to update avatar', [e.toString()]);
    }
  }

  /// Get member dependents
  Future<DependentsResult> getDependents() async {
    try {
      print('🔍 MemberService: Calling getMemberDependents API...');
      final response = await ApiService.getMemberDependents();
      
      print('📡 API Response received:');
      print('   Success: ${response.isSuccess}');
      print('   Data: ${response.data}');
      print('   Message: ${response.message}');
      
      if (response.isSuccess && response.data != null) {
        if (response.data.containsKey('dependents')) {
          final dependentsData = response.data['dependents'] as List<dynamic>;
          print('📋 Dependents raw data: $dependentsData');
          
          final dependents = dependentsData
              .map((dep) {
                print('🔄 Parsing dependent: $dep');
                return Dependent.fromJson(dep as Map<String, dynamic>);
              })
              .toList();
          
          print('✅ Successfully parsed ${dependents.length} dependents');
          return DependentsResult.success('Dependents loaded successfully', dependents);
        } else {
          print('⚠️ No dependents key in response data');
          return DependentsResult.success('No dependents found', []);
        }
      } else {
        print('❌ API call failed: ${response.message}');
        return DependentsResult.failure(response.message, response.errorMessages);
      }
    } catch (e, stackTrace) {
      print('💥 Exception in getDependents: $e');
      print('📚 Stack trace: $stackTrace');
      return DependentsResult.failure('Failed to load dependents', [e.toString()]);
    }
  }

  /// Add dependent
  Future<DependentResult> addDependent(Dependent dependent) async {
    try {
      final response = await ApiService.addMemberDependent(dependent.toJson());
      
      if (response.isSuccess && response.data != null) {
        final newDependent = Dependent.fromJson(response.data['dependent']);
        return DependentResult.success('Dependent added successfully', newDependent);
      } else {
        return DependentResult.failure(response.message, response.errorMessages);
      }
    } catch (e) {
      return DependentResult.failure('Failed to add dependent', [e.toString()]);
    }
  }

  /// Update dependent
  Future<DependentResult> updateDependent(int dependentId, Dependent dependent) async {
    try {
      final response = await ApiService.updateMemberDependent(dependentId, dependent.toJson());
      
      if (response.isSuccess && response.data != null) {
        final updatedDependent = Dependent.fromJson(response.data['dependent']);
        return DependentResult.success('Dependent updated successfully', updatedDependent);
      } else {
        return DependentResult.failure(response.message, response.errorMessages);
      }
    } catch (e) {
      return DependentResult.failure('Failed to update dependent', [e.toString()]);
    }
  }

  /// Delete dependent
  Future<ServiceResult> deleteDependent(int dependentId) async {
    try {
      final response = await ApiService.deleteMemberDependent(dependentId);
      
      if (response.isSuccess) {
        return ServiceResult.success('Dependent deleted successfully');
      } else {
        return ServiceResult.failure(response.message, response.errorMessages);
      }
    } catch (e) {
      return ServiceResult.failure('Failed to delete dependent', [e.toString()]);
    }
  }

  /// Clear member data
  void clearMemberData() {
    _currentMember = null;
  }

  /// Check if identifier is likely a National ID or E-Kanisa number
  static IdentifierType getIdentifierType(String identifier) {
    // E-Kanisa numbers start with 'E-' and are 8 characters total
    if (identifier.toUpperCase().startsWith('E-') && identifier.length == 8) {
      return IdentifierType.ekanisa;
    }
    
    // National IDs are typically 8 digits
    if (RegExp(r'^\d{8}$').hasMatch(identifier)) {
      return IdentifierType.nationalId;
    }
    
    // Could be either, let the server decide
    return IdentifierType.unknown;
  }

  /// Validate identifier format
  static String? validateIdentifier(String identifier) {
    if (identifier.trim().isEmpty) {
      return 'Identifier is required';
    }
    
    final trimmed = identifier.trim();
    final type = getIdentifierType(trimmed);
    
    if (type == IdentifierType.ekanisa) {
      // Validate E-Kanisa number format
      if (!RegExp(r'^E-\d{6}$').hasMatch(trimmed.toUpperCase())) {
        return 'E-Kanisa number must be in format E-123456';
      }
    } else if (type == IdentifierType.nationalId) {
      // Validate National ID format
      if (!RegExp(r'^\d{8}$').hasMatch(trimmed)) {
        return 'National ID must be 8 digits';
      }
    }
    
    return null; // Valid
  }
}

/// Identifier type enum
enum IdentifierType {
  nationalId,
  ekanisa,
  unknown,
}

/// Base service result class
class ServiceResult {
  final bool success;
  final String message;
  final List<String> errors;

  ServiceResult._({
    required this.success,
    required this.message,
    required this.errors,
  });

  factory ServiceResult.success(String message) {
    return ServiceResult._(
      success: true,
      message: message,
      errors: [],
    );
  }

  factory ServiceResult.failure(String message, [List<String>? errors]) {
    return ServiceResult._(
      success: false,
      message: message,
      errors: errors ?? [],
    );
  }

  bool get hasErrors => errors.isNotEmpty;
  String get firstError => errors.isNotEmpty ? errors.first : message;
}

/// Member authentication result
class MemberAuthResult extends ServiceResult {
  final Member? member;
  final Map<String, dynamic>? loginInfo;

  MemberAuthResult._({
    required bool success,
    required String message,
    required List<String> errors,
    this.member,
    this.loginInfo,
  }) : super._(success: success, message: message, errors: errors);

  factory MemberAuthResult.success(
    String message, {
    Member? member,
    Map<String, dynamic>? loginInfo,
  }) {
    return MemberAuthResult._(
      success: true,
      message: message,
      errors: [],
      member: member,
      loginInfo: loginInfo,
    );
  }

  factory MemberAuthResult.failure(String message, [List<String>? errors]) {
    return MemberAuthResult._(
      success: false,
      message: message,
      errors: errors ?? [],
    );
  }
}

/// Member result
class MemberResult extends ServiceResult {
  final Member? member;

  MemberResult._({
    required bool success,
    required String message,
    required List<String> errors,
    this.member,
  }) : super._(success: success, message: message, errors: errors);

  factory MemberResult.success(String message, Member? member) {
    return MemberResult._(
      success: true,
      message: message,
      errors: [],
      member: member,
    );
  }

  factory MemberResult.failure(String message, [List<String>? errors]) {
    return MemberResult._(
      success: false,
      message: message,
      errors: errors ?? [],
    );
  }
}

/// Dependents result
class DependentsResult extends ServiceResult {
  final List<Dependent>? dependents;

  DependentsResult._({
    required bool success,
    required String message,
    required List<String> errors,
    this.dependents,
  }) : super._(success: success, message: message, errors: errors);

  factory DependentsResult.success(String message, List<Dependent> dependents) {
    return DependentsResult._(
      success: true,
      message: message,
      errors: [],
      dependents: dependents,
    );
  }

  factory DependentsResult.failure(String message, [List<String>? errors]) {
    return DependentsResult._(
      success: false,
      message: message,
      errors: errors ?? [],
    );
  }
}

/// Dependent result
class DependentResult extends ServiceResult {
  final Dependent? dependent;

  DependentResult._({
    required bool success,
    required String message,
    required List<String> errors,
    this.dependent,
  }) : super._(success: success, message: message, errors: errors);

  factory DependentResult.success(String message, Dependent dependent) {
    return DependentResult._(
      success: true,
      message: message,
      errors: [],
      dependent: dependent,
    );
  }

  factory DependentResult.failure(String message, [List<String>? errors]) {
    return DependentResult._(
      success: false,
      message: message,
      errors: errors ?? [],
    );
  }
}
