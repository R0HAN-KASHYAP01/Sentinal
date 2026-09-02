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

  void updateRole(UserRole role) {
    final user = currentUser;
    if (user != null) {
      currentUser = AppUser(id: user.id, name: user.name, role: role);
    }
  }

  void clear() {
    currentUser = null;
  }
}