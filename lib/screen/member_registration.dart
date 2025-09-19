import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import '../services/auth_service.dart';
import '../services/location_service.dart';
import '../models/member.dart';
import '../models/location.dart';
import '../config/api_config.dart';
import '../dashboards/member_dashboard.dart';

class MemberRegistrationScreen extends StatefulWidget {
  const MemberRegistrationScreen({Key? key}) : super(key: key);

  @override
  State<MemberRegistrationScreen> createState() => _MemberRegistrationScreenState();
}

class _MemberRegistrationScreenState extends State<MemberRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _pageController = PageController();
  
  // Controllers for form fields
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _nationalIdController = TextEditingController();
  final _primarySchoolController = TextEditingController();
  final _presbyteryController = TextEditingController();
  final _parishController = TextEditingController();
  final _congregationController = TextEditingController();
  final _telephoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // Form state
  DateTime? _dateOfBirth;
  String? _selectedGender;
  String? _selectedMaritalStatus;
  bool _isBaptized = false;
  bool _takesHolyCommunion = false;
  County? _selectedCounty;
  Constituency? _selectedConstituency;
  
  // Dependencies
  List<Dependent> _dependencies = [];
  
  // UI state
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  int _currentPage = 0;
  String? _errorMessage;
  
  // Location data
  List<County> _counties = [];
  List<Constituency> _constituencies = [];
  final LocationService _locationService = LocationService();

  // Gender options
  final List<String> _genderOptions = ['Male', 'Female'];
  
  // Marital status options
  final List<String> _maritalStatusOptions = [
    'Single',
    'Married (Customary)',
    'Married (Church Wedding)',
  ];

  @override
  void initState() {
    super.initState();
    _loadLocationData();
    
    // Debug: Print initial state
    print('🎯 MemberRegistrationScreen initialized');
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _nationalIdController.dispose();
    _primarySchoolController.dispose();
    _presbyteryController.dispose();
    _parishController.dispose();
    _congregationController.dispose();
    _telephoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  /// Load location data
  Future<void> _loadLocationData() async {
    try {
      print('📍 Loading location data...');
      print('📍 API Base URL: ${ApiConfig.currentUrl}');
      
      _counties = await _locationService.getCounties();
      print('📍 Successfully loaded ${_counties.length} counties');
      print('📍 Counties: ${_counties.map((c) => c.countyName).take(3).join(", ")}...');
      
      setState(() {});
    } catch (e) {
      print('❌ Error loading counties: $e');
      
      // Show error message to user
      setState(() {
        _errorMessage = 'Failed to load location data. Please check your connection.';
      });
      
      // Show debug information
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Counties loading failed: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }

  /// Load constituencies when county is selected
  Future<void> _loadConstituencies(County county) async {
    try {
      print('🏘️ Loading constituencies for ${county.countyName}...');
      
      _constituencies = await _locationService.getConstituencies(county.id);
      print('🏘️ Successfully loaded ${_constituencies.length} constituencies');
      
      setState(() {
        _selectedConstituency = null; // Reset constituency selection
      });
    } catch (e) {
      print('❌ Error loading constituencies: $e');
      
      // Show error message to user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Constituencies loading failed for ${county.countyName}: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  /// Calculate age from date of birth
  int? get _calculatedAge {
    if (_dateOfBirth == null) return null;
    final now = DateTime.now();
    int age = now.year - _dateOfBirth!.year;
    if (now.month < _dateOfBirth!.month || 
        (now.month == _dateOfBirth!.month && now.day < _dateOfBirth!.day)) {
      age--;
    }
    return age;
  }

  /// Check if National ID is required
  bool get _isNationalIdRequired {
    return _calculatedAge != null && _calculatedAge! >= 18;
  }

  /// Handle form submission
  Future<void> _handleRegistration() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      print('🚀 Starting member registration...');
      print('🔍 Form: Full Name Controller = "${_fullNameController.text}"');
      print('🔍 Form: Email Controller = "${_emailController.text}"');
      print('🔍 Form: National ID Controller = "${_nationalIdController.text}"');
      
      final request = MemberRegistrationRequest(
        fullName: _fullNameController.text.trim(),
        dateOfBirth: _dateOfBirth!,
        nationalId: _nationalIdController.text.trim().isEmpty ? null : _nationalIdController.text.trim(),
        email: _emailController.text.trim(),
        gender: _selectedGender!,
        maritalStatus: _selectedMaritalStatus!,
        presbytery: _presbyteryController.text.trim(),
        parish: _parishController.text.trim(),
        congregation: _congregationController.text.trim(),
        primarySchool: _primarySchoolController.text.trim().isEmpty ? null : _primarySchoolController.text.trim(),
        isBaptized: _isBaptized,
        takesHolyCommunion: _takesHolyCommunion,
        telephone: _telephoneController.text.trim().isEmpty ? null : _telephoneController.text.trim(),
        locationCounty: _selectedCounty?.countyName,
        locationSubcounty: _selectedConstituency?.constituencyName,
        password: _passwordController.text,
        passwordConfirmation: _confirmPasswordController.text,
        dependencies: _dependencies,
      );

      print('📦 Registration request prepared for: ${request.email}');
      
      final authService = AuthService();
      final result = await authService.registerMember(request);
      
      print('📦 Registration result: Success=${result.success}, Message=${result.message}');

      if (result.success) {
        print('✅ Registration successful, preparing navigation...');
        
        // Clear loading state
        setState(() {
          _isLoading = false;
        });
        
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Registration successful! Redirecting to dashboard...',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );

        // Use direct navigation to member dashboard - bypass named routes
        await Future.delayed(const Duration(milliseconds: 1000));
        
        if (mounted) {
          print('🔄 Attempting navigation to MemberDashboard...');
          
          // Direct navigation using MaterialPageRoute
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const MemberDashboard()),
            (route) => false,
          );
          
          print('✅ Navigation command executed successfully');
        } else {
          print('❌ Widget unmounted, cannot navigate');
        }
      } else {
        print('❌ Registration failed: ${result.firstError}');
        setState(() {
          _errorMessage = result.firstError;
        });
      }
    } catch (e) {
      print('💥 Registration exception: $e');
      setState(() {
        _errorMessage = 'Registration failed: ${e.toString()}';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// Navigate to next page
  void _nextPage() {
    if (_currentPage < 3) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  /// Navigate to previous page
  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  /// Validate current page
  bool _validateCurrentPage() {
    switch (_currentPage) {
      case 0:
        return _fullNameController.text.trim().isNotEmpty &&
               _emailController.text.trim().isNotEmpty &&
               _emailController.text.contains('@') &&
               _dateOfBirth != null &&
               _selectedGender != null &&
               _selectedMaritalStatus != null &&
               (!_isNationalIdRequired || _nationalIdController.text.trim().isNotEmpty);
      case 1:
        return _presbyteryController.text.trim().isNotEmpty &&
               _parishController.text.trim().isNotEmpty &&
               _congregationController.text.trim().isNotEmpty;
      case 2:
        return _passwordController.text.length >= 6 &&
               _passwordController.text == _confirmPasswordController.text;
      case 3:
        return true; // Dependents are optional
      default:
        return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 241, 242, 243),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text(
          'Member Registration',
          style: TextStyle(color: Colors.black),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(8),
          child: LinearProgressIndicator(
            value: (_currentPage + 1) / 4,
            backgroundColor: Colors.grey[300],
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF35C2C1)),
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            // Error message
            if (_errorMessage != null) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  border: Border.all(color: Colors.red.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _errorMessage!,
                  style: TextStyle(
                    color: Colors.red.shade700,
                    fontSize: 14,
                  ),
                ),
              ),
            ],

            // Page content
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (page) {
                  setState(() {
                    _currentPage = page;
                  });
                },
                children: [
                  _buildPersonalInfoPage(),
                  _buildChurchInfoPage(),
                  _buildPasswordPage(),
                  _buildDependentsPage(),
                ],
              ),
            ),

            // Navigation buttons
            _buildNavigationButtons(),
          ],
        ),
      ),
    );
  }

  /// Build personal information page
  Widget _buildPersonalInfoPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Personal Information',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF35C2C1),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Please provide your personal details',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 24),

          // Full Name
          TextFormField(
            controller: _fullNameController,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              labelText: 'Full Name *',
              hintText: 'Enter your full name',
              prefixIcon: Icon(Icons.person),
              border: OutlineInputBorder(),
            ),
            onChanged: (value) => setState(() {}),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Full name is required';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Email
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: 'Email Address *',
              hintText: 'Enter your email address',
              prefixIcon: Icon(Icons.email),
              border: OutlineInputBorder(),
            ),
            onChanged: (value) => setState(() {}),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Email is required';
              }
              if (!value.contains('@')) {
                return 'Please enter a valid email';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Date of Birth
          InkWell(
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: DateTime.now().subtract(const Duration(days: 365 * 25)),
                firstDate: DateTime(1900),
                lastDate: DateTime.now(),
              );
              if (date != null) {
                setState(() {
                  _dateOfBirth = date;
                });
              }
            },
            child: InputDecorator(
              decoration: const InputDecoration(
                labelText: 'Date of Birth *',
                prefixIcon: Icon(Icons.calendar_today),
                border: OutlineInputBorder(),
              ),
              child: Text(
                _dateOfBirth != null
                    ? '${_dateOfBirth!.day}/${_dateOfBirth!.month}/${_dateOfBirth!.year}'
                    : 'Select your date of birth',
                style: TextStyle(
                  color: _dateOfBirth != null ? Colors.black : Colors.grey,
                ),
              ),
            ),
          ),
          if (_calculatedAge != null) ...[
            const SizedBox(height: 8),
            Text(
              'Age: $_calculatedAge years',
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
            ),
          ],
          const SizedBox(height: 16),

          // National ID (conditional)
          TextFormField(
            controller: _nationalIdController,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(8),
            ],
            decoration: InputDecoration(
              labelText: _isNationalIdRequired ? 'National ID *' : 'National ID (Optional)',
              hintText: 'Enter your National ID',
              prefixIcon: const Icon(Icons.badge),
              border: const OutlineInputBorder(),
              helperText: _isNationalIdRequired 
                  ? 'Required for members 18 years and above'
                  : 'Optional for members under 18',
            ),
            onChanged: (value) => setState(() {}),
            validator: (value) {
              if (_isNationalIdRequired && (value == null || value.trim().isEmpty)) {
                return 'National ID is required for members 18 years and above';
              }
              if (value != null && value.isNotEmpty && value.length != 8) {
                return 'National ID must be exactly 8 digits';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Gender
          DropdownButtonFormField<String>(
            value: _selectedGender,
            decoration: const InputDecoration(
              labelText: 'Gender *',
              prefixIcon: Icon(Icons.person_outline),
              border: OutlineInputBorder(),
            ),
            items: _genderOptions.map((gender) {
              return DropdownMenuItem(
                value: gender,
                child: Text(gender),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedGender = value;
              });
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please select your gender';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Marital Status
          DropdownButtonFormField<String>(
            value: _selectedMaritalStatus,
            decoration: const InputDecoration(
              labelText: 'Marital Status *',
              prefixIcon: Icon(Icons.favorite),
              border: OutlineInputBorder(),
            ),
            items: _maritalStatusOptions.map((status) {
              return DropdownMenuItem(
                value: status,
                child: Text(status),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedMaritalStatus = value;
              });
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please select your marital status';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Primary School (Optional)
          TextFormField(
            controller: _primarySchoolController,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              labelText: 'Primary School (Optional)',
              hintText: 'Enter your primary school',
              prefixIcon: Icon(Icons.school),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),

          // Telephone (Optional)
          TextFormField(
            controller: _telephoneController,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              labelText: 'Telephone (Optional)',
              hintText: 'Enter your phone number',
              prefixIcon: Icon(Icons.phone),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),

          // Location - County
          DropdownButtonFormField<County>(
            value: _selectedCounty,
            decoration: const InputDecoration(
              labelText: 'County (Optional)',
              prefixIcon: Icon(Icons.location_on),
              border: OutlineInputBorder(),
            ),
            items: _counties.isEmpty ? [] : _counties.map((county) {
              return DropdownMenuItem(
                value: county,
                child: Text(county.countyName),
              );
            }).toList(),
            onChanged: _counties.isEmpty ? null : (county) {
              setState(() {
                _selectedCounty = county;
                if (county != null) {
                  _loadConstituencies(county);
                }
              });
            },
            hint: _counties.isEmpty 
                ? const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      SizedBox(width: 8),
                      Text('Loading counties...'),
                    ],
                  )
                : const Text('Select your county'),
          ),
          const SizedBox(height: 16),

          // Location - Constituency
          DropdownButtonFormField<Constituency>(
            value: _selectedConstituency,
            decoration: const InputDecoration(
              labelText: 'Constituency (Optional)',
              prefixIcon: Icon(Icons.location_city),
              border: OutlineInputBorder(),
            ),
            items: _constituencies.isEmpty ? [] : _constituencies.map((constituency) {
              return DropdownMenuItem(
                value: constituency,
                child: Text(constituency.constituencyName),
              );
            }).toList(),
            onChanged: _constituencies.isEmpty ? null : (constituency) {
              setState(() {
                _selectedConstituency = constituency;
              });
            },
            hint: _selectedCounty == null
                ? const Text('Select a county first')
                : _constituencies.isEmpty
                    ? const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          SizedBox(width: 8),
                          Text('Loading constituencies...'),
                        ],
                      )
                    : const Text('Select your constituency'),
          ),
          const SizedBox(height: 16),

          // Baptized checkbox
          Row(
            children: [
              Checkbox(
                value: _isBaptized,
                onChanged: (value) {
                  setState(() {
                    _isBaptized = value ?? false;
                  });
                },
              ),
              const Expanded(
                child: Text('I am baptized'),
              ),
            ],
          ),

          // Holy Communion checkbox
          Row(
            children: [
              Checkbox(
                value: _takesHolyCommunion,
                onChanged: (value) {
                  setState(() {
                    _takesHolyCommunion = value ?? false;
                  });
                },
              ),
              const Expanded(
                child: Text('I take Holy Communion'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Build church information page
  Widget _buildChurchInfoPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Church Information',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF35C2C1),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Please provide your church details',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 24),

          // Presbytery
          TextFormField(
            controller: _presbyteryController,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              labelText: 'Presbytery *',
              hintText: 'Enter your presbytery',
              prefixIcon: Icon(Icons.church),
              border: OutlineInputBorder(),
            ),
            onChanged: (value) => setState(() {}),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Presbytery is required';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Parish
          TextFormField(
            controller: _parishController,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              labelText: 'Parish *',
              hintText: 'Enter your parish',
              prefixIcon: Icon(Icons.church),
              border: OutlineInputBorder(),
            ),
            onChanged: (value) => setState(() {}),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Parish is required';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Congregation
          TextFormField(
            controller: _congregationController,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              labelText: 'Congregation *',
              hintText: 'Enter your congregation',
              prefixIcon: Icon(Icons.people),
              border: OutlineInputBorder(),
            ),
            onChanged: (value) => setState(() {}),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Congregation is required';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  /// Build password page
  Widget _buildPasswordPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Account Security',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF35C2C1),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Create a secure password for your account',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 24),

          // Password
          TextFormField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            decoration: InputDecoration(
              labelText: 'Password *',
              hintText: 'Enter your password',
              prefixIcon: const Icon(Icons.lock),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility : Icons.visibility_off,
                ),
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              ),
              border: const OutlineInputBorder(),
              helperText: 'Password must be at least 6 characters long',
            ),
            onChanged: (value) => setState(() {}),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Password is required';
              }
              if (value.length < 6) {
                return 'Password must be at least 6 characters';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Confirm Password
          TextFormField(
            controller: _confirmPasswordController,
            obscureText: _obscureConfirmPassword,
            decoration: InputDecoration(
              labelText: 'Confirm Password *',
              hintText: 'Confirm your password',
              prefixIcon: const Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureConfirmPassword ? Icons.visibility : Icons.visibility_off,
                ),
                onPressed: () {
                  setState(() {
                    _obscureConfirmPassword = !_obscureConfirmPassword;
                  });
                },
              ),
              border: const OutlineInputBorder(),
            ),
            onChanged: (value) => setState(() {}),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please confirm your password';
              }
              if (value != _passwordController.text) {
                return 'Passwords do not match';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  /// Build dependents page
  Widget _buildDependentsPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Dependents (Optional)',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF35C2C1),
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Add your dependents if any',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              TextButton.icon(
                onPressed: _addDependent,
                icon: const Icon(Icons.add),
                label: const Text('Add Dependent'),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Dependents list
          if (_dependencies.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(40),
                child: Column(
                  children: [
                    Icon(
                      Icons.family_restroom,
                      size: 80,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'No dependents added yet',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'You can add dependents now or later from your profile',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _dependencies.length,
              itemBuilder: (context, index) {
                final dependent = _dependencies[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: const CircleAvatar(
                      child: Icon(Icons.person),
                    ),
                    title: Text(dependent.name),
                    subtitle: Text(
                      'Born: ${dependent.yearOfBirth} • Age: ${dependent.age}',
                    ),
                    trailing: PopupMenuButton(
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit, size: 16),
                              SizedBox(width: 8),
                              Text('Edit'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete, size: 16, color: Colors.red),
                              SizedBox(width: 8),
                              Text('Delete', style: TextStyle(color: Colors.red)),
                            ],
                          ),
                        ),
                      ],
                      onSelected: (value) {
                        if (value == 'edit') {
                          _editDependent(index);
                        } else if (value == 'delete') {
                          _deleteDependent(index);
                        }
                      },
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  /// Build navigation buttons
  Widget _buildNavigationButtons() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          if (_currentPage > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: _previousPage,
                child: const Text('Previous'),
              ),
            ),
          if (_currentPage > 0) const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: _isLoading 
                  ? null 
                  : (_currentPage < 3 
                      ? (_validateCurrentPage() ? _nextPage : null)
                      : _handleRegistration),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF35C2C1),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      _currentPage < 3 ? 'Next' : 'Register',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  /// Add dependent dialog
  void _addDependent() {
    _showDependentDialog();
  }

  /// Edit dependent dialog
  void _editDependent(int index) {
    _showDependentDialog(dependent: _dependencies[index], index: index);
  }

  /// Delete dependent
  void _deleteDependent(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Dependent'),
        content: Text('Are you sure you want to remove ${_dependencies[index].name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _dependencies.removeAt(index);
              });
              Navigator.of(context).pop();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  /// Show dependent dialog
  void _showDependentDialog({Dependent? dependent, int? index}) {
    final nameController = TextEditingController(text: dependent?.name ?? '');
    final schoolController = TextEditingController(text: dependent?.school ?? '');
    final birthCertController = TextEditingController(text: dependent?.birthCertNumber ?? '');
    int selectedYear = dependent?.yearOfBirth ?? DateTime.now().year;
    bool isBaptized = dependent?.isBaptized ?? false;
    bool takesHolyCommunion = dependent?.takesHolyCommunion ?? false;
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(dependent == null ? 'Add Dependent' : 'Edit Dependent'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Name
                TextFormField(
                  controller: nameController,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'Full Name *',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Year of Birth
                DropdownButtonFormField<int>(
                  value: selectedYear,
                  decoration: const InputDecoration(
                    labelText: 'Year of Birth *',
                    border: OutlineInputBorder(),
                  ),
                  items: List.generate(
                    DateTime.now().year - 1900 + 1,
                    (index) => DateTime.now().year - index,
                  ).map((year) {
                    return DropdownMenuItem(
                      value: year,
                      child: Text(year.toString()),
                    );
                  }).toList(),
                  onChanged: (year) {
                    if (year != null) {
                      setDialogState(() {
                        selectedYear = year;
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),
                
                // Birth Certificate Number (Optional)
                TextFormField(
                  controller: birthCertController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(9),
                  ],
                  decoration: const InputDecoration(
                    labelText: 'Birth Certificate Number (Optional)',
                    border: OutlineInputBorder(),
                    helperText: 'Must be exactly 9 digits if provided',
                  ),
                ),
                const SizedBox(height: 16),
                
                // School (Optional)
                TextFormField(
                  controller: schoolController,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'School (Optional)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Baptized checkbox
                CheckboxListTile(
                  value: isBaptized,
                  title: const Text('Is Baptized'),
                  onChanged: (value) {
                    setDialogState(() {
                      isBaptized = value ?? false;
                    });
                  },
                ),
                
                // Holy Communion checkbox
                CheckboxListTile(
                  value: takesHolyCommunion,
                  title: const Text('Takes Holy Communion'),
                  onChanged: (value) {
                    setDialogState(() {
                      takesHolyCommunion = value ?? false;
                    });
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Name is required')),
                  );
                  return;
                }
                
                final birthCert = birthCertController.text.trim();
                if (birthCert.isNotEmpty && birthCert.length != 9) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Birth certificate number must be exactly 9 digits')),
                  );
                  return;
                }
                
                final newDependent = Dependent(
                  name: nameController.text.trim(),
                  yearOfBirth: selectedYear,
                  birthCertNumber: birthCert.isEmpty ? null : birthCert,
                  school: schoolController.text.trim().isEmpty ? null : schoolController.text.trim(),
                  isBaptized: isBaptized,
                  takesHolyCommunion: takesHolyCommunion,
                );
                
                setState(() {
                  if (index != null) {
                    _dependencies[index] = newDependent;
                  } else {
                    _dependencies.add(newDependent);
                  }
                });
                
                Navigator.of(context).pop();
              },
              child: Text(dependent == null ? 'Add' : 'Update'),
            ),
          ],
        ),
      ),
    );
  }
}
