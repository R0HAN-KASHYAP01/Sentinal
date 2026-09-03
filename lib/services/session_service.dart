import '../models/user.dart';

/// Lightweight in-memory session state.
/// No persistence yet — resets when the app restarts.
class SessionService {
  SessionService._();
  static final SessionService instance = SessionService._();

  AppUser? currentUser;

  bool get isLoggedIn => currentUser != null;

  void setUser(AppUser user) {
    currentUser = user;
  }

  // Kept for role_selection_screen.dart, which is currently unused in the
  // real login flow (role now comes from Supabase) but is left in the
  // codebase rather than deleted. Not called anywhere in the live auth path.
  void updateRole(UserRole role) {
    final user = currentUser;
    if (user != null) {
      currentUser = AppUser(
        id: user.id,
        name: user.name,
        email: user.email,
        role: role,
        status: user.status,
        department: user.department,
        designation: user.designation,
        registrationNumber: user.registrationNumber,
      );
    }
  }

  void clear() {
    currentUser = null;
  }
}