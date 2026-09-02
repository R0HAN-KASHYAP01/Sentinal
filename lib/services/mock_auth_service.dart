import '../models/user.dart';

class AuthResult {
  final bool success;
  final AppUser? user;
  final String? errorMessage;

  const AuthResult.success(this.user)
      : success = true,
        errorMessage = null;

  const AuthResult.failure(this.errorMessage)
      : success = false,
        user = null;
}

class MockAuthService {
  MockAuthService._();
  static final MockAuthService instance = MockAuthService._();

  final Map<String, Map<String, dynamic>> _testAccounts = {
    'official@test.com': {
      'password': '123456',
      'name': 'DoSJE Official',
      'role': UserRole.official,
    },
    'inspector@test.com': {
      'password': '123456',
      'name': 'PMU Inspector',
      'role': UserRole.inspector,
    },
  };

  Future<AuthResult> login(String id, String password) async {
    await Future.delayed(const Duration(seconds: 1));

    final account = _testAccounts[id.trim().toLowerCase()];

    if (account == null || account['password'] != password) {
      return const AuthResult.failure('Invalid ID or password.');
    }

    final user = AppUser(
      id: id.trim().toLowerCase(),
      name: account['name'] as String,
      role: account['role'] as UserRole,
    );

    return AuthResult.success(user);
  }
}