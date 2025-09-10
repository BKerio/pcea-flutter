import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _companyController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _selectedCountryCode;

  final List<Map<String, String>> _countryCodes = [
    {'code': '+254', 'name': 'Kenya', 'flag': '🇰🇪'},
    {'code': '+256', 'name': 'Uganda', 'flag': '🇺🇬'},
    {'code': '+255', 'name': 'Tanzania', 'flag': '🇹🇿'},
    {'code': '+250', 'name': 'Rwanda', 'flag': '🇷🇼'},
    {'code': '+257', 'name': 'Burundi', 'flag': '🇧🇮'},
  ];

  Future<void> signUp() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final authService = AuthService();
        
        // Create password confirmation (using same password for now)
        final result = await authService.register(
          name: _usernameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text,
          passwordConfirmation: _passwordController.text,
        );

        if (result.success) {
          // Registration successful
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Registration successful! You are now logged in.',
                style: TextStyle(
                  fontWeight: FontWeight.normal,
                  color: Colors.white,
                ),
              ),
              backgroundColor: Colors.green,
            ),
          );
          
          // Navigate to role-specific dashboard
          final dashboardRoute = authService.dashboardRoute ?? '/member/dashboard';
          Navigator.pushNamedAndRemoveUntil(
            context, 
            dashboardRoute,
            (route) => false,
          );
        } else {
          // Show error message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                result.firstError,
                style: const TextStyle(
                  fontWeight: FontWeight.normal,
                  color: Colors.white,
                ),
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Registration failed: ${error.toString()}',
              style: const TextStyle(
                fontWeight: FontWeight.normal,
                color: Colors.white,
              ),
            ),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
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
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 15),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      "Join Us Today and Unlock Exceptional Service Beyond Expectations!",
                      style: const TextStyle(
                        fontSize: 20,
                        color: Color(0xFF35C2C1),
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Username
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _buildTextField(
                    controller: _usernameController,
                    hintText: 'Enter Your Username',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your username';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 15),

                // Email
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _buildTextField(
                    controller: _emailController,
                    hintText: 'Enter Your Email',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      if (!value.endsWith('@gmail.com')) {
                        return 'Please use a valid Gmail account';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 15),

                // Company
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _buildTextField(
                    controller: _companyController,
                    hintText: 'Provide company name (Millenium Partner)',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your company name';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 15),

                // Phone
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width * 0.3,
                        child: DropdownButtonFormField<String>(
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                          ),
                          value: _selectedCountryCode,
                          hint: const Text(
                            'Code',
                            style: TextStyle(color: Color(0xFF8391A1)),
                          ),
                          items: _countryCodes.map((country) {
                            return DropdownMenuItem<String>(
                              value: country['code'],
                              child: Row(
                                children: [
                                  Text(country['flag']!),
                                  const SizedBox(width: 5),
                                  Text(country['code']!),
                                ],
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedCountryCode = value;
                            });
                          },
                          validator: (value) {
                            if (value == null) {
                              return 'Select country code';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Flexible(
                        child: _buildTextField(
                          controller: _phoneController,
                          hintText: 'Enter Phone Number',
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Enter phone number';
                            }
                            if (value.length != 9 ||
                                !RegExp(r'^[0-9]+$').hasMatch(value)) {
                              return 'Must be 9 digits, remove leading 0!';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 15),

                // Password
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _buildTextField(
                    controller: _passwordController,
                    hintText: 'Enter Your Password',
                    obscureText: _obscurePassword,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      return null;
                    },
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: const Color(0xFF8391A1),
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 15),

                // Submit Button
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 5,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: MaterialButton(
                          color: const Color(0xFF35C2C1),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          onPressed: _isLoading ? null : signUp,
                          child: Padding(
                            padding: const EdgeInsets.all(15.0),
                            child: _isLoading
                                ? const CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.blue,
                                    ),
                                  )
                                : const Text(
                                    "Register",
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 18,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  child: Row(
                    children: const [
                      Expanded(
                        child: Divider(color: Color(0xFFE8ECF4), thickness: 3),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Text("Or"),
                      ),
                      Expanded(
                        child: Divider(color: Color(0xFFE8ECF4), thickness: 3),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Select Role to Login",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    String? Function(String?)? validator,
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: Color(0xFF8391A1)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        suffixIcon: suffixIcon,
      ),
      validator: validator,
    );
  }
}
