import 'package:supabase_flutter/supabase_flutter.dart';
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

class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  final SupabaseClient _client = Supabase.instance.client;

  Future<AuthResult> login(String email, String password) async {
    try {
      final res = await _client.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );
      final authUser = res.user;
      if (authUser == null) {
        return const AuthResult.failure('Login failed.');
      }
      final user = await _loadFullProfile(authUser.id, authUser.email ?? email);
      if (user == null) {
        return const AuthResult.failure('No profile found for this account.');
      }
      return AuthResult.success(user);
    } on AuthException catch (e) {
      return AuthResult.failure(e.message);
    } catch (_) {
      return const AuthResult.failure('Something went wrong. Please try again.');
    }
  }

  Future<AuthResult> signUp({
    required String fullName,
    required String email,
    required String password,
    String? phone,
    required UserRole role,
    String? department,
    String? designation,
    String? organizationName,
    String? registrationNumber,
  }) async {
    try {
      final res = await _client.auth.signUp(email: email.trim(), password: password);
      final authUser = res.user;
      if (authUser == null) {
        return const AuthResult.failure('Sign up failed.');
      }

      await _client.from('profiles').insert({
        'id': authUser.id,
        'full_name': fullName,
        'phone': phone,
        'role': _roleToDb(role),
      });

      switch (role) {
        case UserRole.official:
          await _client.from('officials').insert({
            'profile_id': authUser.id,
            'department': department,
            'designation': designation,
          });
          break;
        case UserRole.inspector:
          await _client.from('pmu_inspectors').insert({
            'profile_id': authUser.id,
            'department': department,
            'designation': designation,
          });
          break;
        case UserRole.ngoInstitute:
          String? orgId;
          final trimmedOrg = organizationName?.trim();
          if (trimmedOrg != null && trimmedOrg.isNotEmpty) {
            final existing = await _client
                .from('organizations')
                .select('id')
                .eq('name', trimmedOrg)
                .maybeSingle();
            if (existing != null) {
              orgId = existing['id'] as String;
            } else {
              final created = await _client
                  .from('organizations')
                  .insert({'name': trimmedOrg, 'created_by': authUser.id})
                  .select('id')
                  .single();
              orgId = created['id'] as String;
            }
          }
          await _client.from('ngo_institutes').insert({
            'profile_id': authUser.id,
            'organization_id': orgId,
            'registration_number': registrationNumber,
          });
          break;
      }

      final user = await _loadFullProfile(authUser.id, email);
      return AuthResult.success(user);
    } on AuthException catch (e) {
      return AuthResult.failure(e.message);
    } on PostgrestException catch (e) {
      if (e.code == '23505') {
        return const AuthResult.failure('An account with this information already exists.');
      }
      return AuthResult.failure(e.message);
    } catch (_) {
      return const AuthResult.failure('Something went wrong. Please try again.');
    }
  }

    Future<AppUser?> _loadFullProfile(String id, String email) async {
    final profile = await _client.from('profiles').select().eq('id', id).maybeSingle();
    if (profile == null) return null;

    final role = _roleFromDb(profile['role'] as String);
    Map<String, dynamic>? roleData;
    switch (role) {
      case UserRole.official:
        roleData = await _client.from('officials').select().eq('profile_id', id).maybeSingle();
        break;
      case UserRole.inspector:
        roleData = await _client.from('pmu_inspectors').select().eq('profile_id', id).maybeSingle();
        break;
      case UserRole.ngoInstitute:
        roleData = await _client.from('ngo_institutes').select().eq('profile_id', id).maybeSingle();
        break;
    }

    return AppUser(
      id: id,
      name: profile['full_name'] as String,
      email: email,
      role: role,
      status: profile['status'] as String,
      department: roleData?['department'] as String?,
      designation: roleData?['designation'] as String?,
      registrationNumber: roleData?['registration_number'] as String?,
      organizationId: roleData?['organization_id'] as String?,
    );
  }

  Future<void> logout() => _client.auth.signOut();

  String _roleToDb(UserRole role) {
    switch (role) {
      case UserRole.official:
        return 'official';
      case UserRole.inspector:
        return 'pmu_inspector';
      case UserRole.ngoInstitute:
        return 'ngo_institute';
    }
  }

  UserRole _roleFromDb(String value) {
    switch (value) {
      case 'official':
        return UserRole.official;
      case 'pmu_inspector':
        return UserRole.inspector;
      case 'ngo_institute':
        return UserRole.ngoInstitute;
      default:
        throw Exception('Unknown role: $value');
    }
  }
}