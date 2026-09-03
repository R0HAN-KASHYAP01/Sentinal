import 'package:flutter/material.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../services/auth_service.dart';
import '../../../models/user.dart';
import '../../../app/routes.dart';
import '../../../app/theme.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  final _departmentController = TextEditingController();
  final _designationController = TextEditingController();
  final _organizationController = TextEditingController();
  final _registrationController = TextEditingController();

  UserRole _role = UserRole.official;
  bool _obscurePassword = true;
  bool _isLoading = false;
  String? _errorMessage;

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

  Future<void> _handleSignup() async {
    setState(() => _errorMessage = null);

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    final result = await AuthService.instance.signUp(
      fullName: _nameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
      phone: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
      role: _role,
      department: _departmentController.text.trim().isEmpty ? null : _departmentController.text.trim(),
      designation: _designationController.text.trim().isEmpty ? null : _designationController.text.trim(),
      organizationName: _organizationController.text.trim().isEmpty ? null : _organizationController.text.trim(),
      registrationNumber: _registrationController.text.trim().isEmpty ? null : _registrationController.text.trim(),
    );

    if (!mounted) return;

    setState(() => _isLoading = false);

    if (result.success) {
      // Account created with status 'pending' until an admin approves it.
      Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.login, (route) => false);
    } else {
      setState(() => _errorMessage = result.errorMessage ?? 'Sign up failed.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Account')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppCard(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text('Account Details', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 16),

                      AppTextField(
                        label: 'Full Name',
                        controller: _nameController,
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter your name.' : null,
                      ),
                      const SizedBox(height: 14),

                      AppTextField(
                        label: 'Email',
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return 'Please enter your email.';
                          if (!v.contains('@')) return 'Please enter a valid email.';
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),

                      AppTextField(
                        label: 'Phone Number (optional)',
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 14),

                      AppTextField(
                        label: 'Password',
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        suffixIcon: IconButton(
                          icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Please enter a password.';
                          if (v.length < 6) return 'Password must be at least 6 characters.';
                          return null;
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                AppCard(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text('I am a', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 12),
                      SegmentedButton<UserRole>(
                        segments: const [
                          ButtonSegment(value: UserRole.official, label: Text('Official')),
                          ButtonSegment(value: UserRole.inspector, label: Text('PMU / Inspector')),
                          ButtonSegment(value: UserRole.ngoInstitute, label: Text('NGO / Institute')),
                        ],
                        selected: {_role},
                        onSelectionChanged: (selection) => setState(() => _role = selection.first),
                      ),
                      const SizedBox(height: 16),

                      if (_role == UserRole.official) ...[
                        AppTextField(
                          label: 'Department (e.g. Dept. of Social Justice & Empowerment)',
                          controller: _departmentController,
                          validator: (v) => (v == null || v.trim().isEmpty) ? 'Department is required.' : null,
                        ),
                        const SizedBox(height: 14),
                        AppTextField(
                          label: 'Designation (e.g. Deputy Director)',
                          controller: _designationController,
                          validator: (v) => (v == null || v.trim().isEmpty) ? 'Designation is required.' : null,
                        ),
                      ],

                      if (_role == UserRole.inspector) ...[
                        AppTextField(
                          label: 'PMU Department / Unit (e.g. Project Monitoring Unit)',
                          controller: _departmentController,
                          validator: (v) => (v == null || v.trim().isEmpty) ? 'Department is required.' : null,
                        ),
                        const SizedBox(height: 14),
                        AppTextField(
                          label: 'Designation (optional, e.g. Program Officer)',
                          controller: _designationController,
                        ),
                      ],

                      if (_role == UserRole.ngoInstitute) ...[
                        AppTextField(
                          label: 'Organization / NGO Name (e.g. Prayas Foundation)',
                          controller: _organizationController,
                          validator: (v) => (v == null || v.trim().isEmpty) ? 'Organization name is required.' : null,
                        ),
                        const SizedBox(height: 14),
                        AppTextField(
                          label: 'Registration Number (optional, e.g. NGO/2019/00123)',
                          controller: _registrationController,
                        ),
                      ],
                    ],
                  ),
                ),

                if (_errorMessage != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline, size: 16, color: AppColors.error),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(_errorMessage!, style: const TextStyle(color: AppColors.error, fontSize: 12)),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 20),

                PrimaryButton(
                  label: _isLoading ? 'Creating account...' : 'Sign up',
                  onPressed: _isLoading ? () {} : _handleSignup,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}