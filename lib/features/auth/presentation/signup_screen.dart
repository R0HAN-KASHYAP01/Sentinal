import 'package:flutter/material.dart';

import '../../../models/user.dart';
import '../../../services/auth_service.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _departmentController = TextEditingController();
  final _designationController = TextEditingController();
  final _organizationController = TextEditingController();
  final _registrationController = TextEditingController();

  UserRole _selectedRole = UserRole.official;

  bool _obscurePassword = true;
  bool _agreeTerms = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _departmentController.dispose();
    _designationController.dispose();
    _organizationController.dispose();
    _registrationController.dispose();
    super.dispose();
  }

  Future<void> _signup() async {
    if (_nameController.text.trim().isEmpty) {
      _showMessage('Please enter your full name.');
      return;
    }

    if (_emailController.text.trim().isEmpty) {
      _showMessage('Please enter your email.');
      return;
    }

    if (_passwordController.text.length < 6) {
      _showMessage('Password must contain at least 6 characters.');
      return;
    }

    if (_selectedRole == UserRole.official ||
        _selectedRole == UserRole.inspector) {
      if (_departmentController.text.trim().isEmpty) {
        _showMessage('Please enter department.');
        return;
      }

      if (_designationController.text.trim().isEmpty) {
        _showMessage('Please enter designation.');
        return;
      }
    }

    if (_selectedRole == UserRole.ngoInstitute) {
      if (_organizationController.text.trim().isEmpty) {
        _showMessage('Please enter organization name.');
        return;
      }
    }

    if (!_agreeTerms) {
      _showMessage('Please agree to Terms & Conditions.');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final result = await AuthService.instance.signUp(
      fullName: _nameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
      phone: _phoneController.text.trim().isEmpty
          ? null
          : _phoneController.text.trim(),
      role: _selectedRole,
      department: _departmentController.text.trim().isEmpty
          ? null
          : _departmentController.text.trim(),
      designation: _designationController.text.trim().isEmpty
          ? null
          : _designationController.text.trim(),
      organizationName: _organizationController.text.trim().isEmpty
          ? null
          : _organizationController.text.trim(),
      registrationNumber:
          _registrationController.text.trim().isEmpty
              ? null
              : _registrationController.text.trim(),
    );

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    if (result.success) {
      _showMessage('Account created successfully!');

      await Future.delayed(const Duration(milliseconds: 800));

      if (!mounted) return;

      Navigator.pop(context);
    } else {
      _showMessage(
        result.errorMessage ?? 'Unable to create account.',
      );
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  InputDecoration _inputDecoration({
    required IconData icon,
    required String hint,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(
        color: Color(0xFF999999),
        fontSize: 13,
      ),
      prefixIcon: Icon(
        icon,
        size: 19,
        color: const Color(0xFF666666),
      ),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 14,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(9),
        borderSide: const BorderSide(
          color: Color(0xFFD5D5D5),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(9),
        borderSide: const BorderSide(
          color: Color(0xFFD5D5D5),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(9),
        borderSide: const BorderSide(
          color: Color(0xFF1D447C),
          width: 1.5,
        ),
      ),
    );
  }

  Widget _roleButton({
    required UserRole role,
    required String title,
  }) {
    final isSelected = _selectedRole == role;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedRole = role;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          height: 52,
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFFEAF1FA)
                : Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected
                  ? const Color(0xFF1D447C)
                  : const Color(0xFFD5D5D5),
              width: isSelected ? 1.2 : 1,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isSelected)
                const Icon(
                  Icons.check_circle,
                  size: 13,
                  color: Color(0xFF1D447C),
                ),
              if (isSelected)
                const SizedBox(height: 2),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isSelected
                      ? FontWeight.w600
                      : FontWeight.w500,
                  color: const Color(0xFF243B5A),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F5F7),
      body: SafeArea(
        child: Column(
          children: [
            // -------------------------------------------------
            // BLUE HEADER
            // -------------------------------------------------
            Container(
              height: 52,
              width: double.infinity,
              color: const Color(0xFF1D447C),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                    ),
                  ),
                  const Expanded(
                    child: Text(
                      'Create Account',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),

            // -------------------------------------------------
            // FORM
            // -------------------------------------------------
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  18,
                  20,
                  18,
                  30,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: 430,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Account Details',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),

                      const SizedBox(height: 15),

                      // Full Name
                      TextField(
                        controller: _nameController,
                        textCapitalization:
                            TextCapitalization.words,
                        decoration: _inputDecoration(
                          icon: Icons.person_outline,
                          hint: 'Full Name',
                        ),
                      ),

                      const SizedBox(height: 10),

                      // Email
                      TextField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: _inputDecoration(
                          icon: Icons.email_outlined,
                          hint: 'Email',
                        ),
                      ),

                      const SizedBox(height: 10),

                      // Phone
                      TextField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: _inputDecoration(
                          icon: Icons.phone_outlined,
                          hint: 'Phone Number (optional)',
                        ),
                      ),

                      const SizedBox(height: 10),

                      // Password
                      TextField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        decoration: _inputDecoration(
                          icon: Icons.lock_outline,
                          hint: 'Password',
                          suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                _obscurePassword =
                                    !_obscurePassword;
                              });
                            },
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              size: 20,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      const Text(
                        'I am a',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      const SizedBox(height: 10),

                      // -------------------------------------------------
                      // ROLE BUTTONS
                      // -------------------------------------------------
                      Row(
                        children: [
                          _roleButton(
                            role: UserRole.official,
                            title: 'Official',
                          ),
                          const SizedBox(width: 8),
                          _roleButton(
                            role: UserRole.inspector,
                            title: 'PMU /\nInspector',
                          ),
                          const SizedBox(width: 8),
                          _roleButton(
                            role: UserRole.ngoInstitute,
                            title: 'NGO /\nInstitute',
                          ),
                        ],
                      ),

                      const SizedBox(height: 18),

                      // -------------------------------------------------
                      // OFFICIAL / INSPECTOR FIELDS
                      // -------------------------------------------------
                      if (_selectedRole == UserRole.official ||
                          _selectedRole == UserRole.inspector) ...[
                        _smallLabel('Department'),

                        const SizedBox(height: 6),

                        TextField(
                          controller: _departmentController,
                          decoration: _inputDecoration(
                            icon: Icons.account_balance_outlined,
                            hint:
                                'Dept. of Social Justice & Empowerment',
                          ),
                        ),

                        const SizedBox(height: 12),

                        _smallLabel('Designation'),

                        const SizedBox(height: 6),

                        TextField(
                          controller: _designationController,
                          decoration: _inputDecoration(
                            icon: Icons.badge_outlined,
                            hint: 'Deputy Director',
                          ),
                        ),
                      ],

                      // -------------------------------------------------
                      // NGO FIELDS
                      // -------------------------------------------------
                      if (_selectedRole ==
                          UserRole.ngoInstitute) ...[
                        _smallLabel('Organization Name'),

                        const SizedBox(height: 6),

                        TextField(
                          controller: _organizationController,
                          decoration: _inputDecoration(
                            icon: Icons.business_outlined,
                            hint: 'Organization / Institute Name',
                          ),
                        ),

                        const SizedBox(height: 12),

                        _smallLabel('Registration Number'),

                        const SizedBox(height: 6),

                        TextField(
                          controller: _registrationController,
                          decoration: _inputDecoration(
                            icon: Icons.badge_outlined,
                            hint: 'Registration Number',
                          ),
                        ),
                      ],

                      const SizedBox(height: 18),

                      // -------------------------------------------------
                      // TERMS CHECKBOX
                      // -------------------------------------------------
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 28,
                            height: 28,
                            child: Checkbox(
                              value: _agreeTerms,
                              activeColor:
                                  const Color(0xFF1D447C),
                              onChanged: (value) {
                                setState(() {
                                  _agreeTerms = value ?? false;
                                });
                              },
                            ),
                          ),

                          const SizedBox(width: 6),

                          Expanded(
                            child: RichText(
                              text: const TextSpan(
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFF333333),
                                ),
                                children: [
                                  TextSpan(
                                    text: 'I agree to the ',
                                  ),
                                  TextSpan(
                                    text: 'Terms & Conditions',
                                    style: TextStyle(
                                      color: Color(0xFF1D447C),
                                      decoration:
                                          TextDecoration.underline,
                                    ),
                                  ),
                                  TextSpan(
                                    text: ' and ',
                                  ),
                                  TextSpan(
                                    text: 'Privacy Policy',
                                    style: TextStyle(
                                      color: Color(0xFF1D447C),
                                      decoration:
                                          TextDecoration.underline,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 18),

                      // -------------------------------------------------
                      // SIGN UP BUTTON
                      // -------------------------------------------------
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _signup,
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color(0xFF1D447C),
                            foregroundColor: Colors.white,
                            disabledBackgroundColor:
                                const Color(0xFF8CA4C2),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(8),
                            ),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child:
                                      CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text(
                                  'Sign up',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _smallLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 10,
        color: Colors.grey.shade600,
      ),
    );
  }
}