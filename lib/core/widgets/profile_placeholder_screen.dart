import 'package:flutter/material.dart';
import '../../services/session_service.dart';
import '../../app/routes.dart';
import '../../app/theme.dart';

class ProfilePlaceholderScreen extends StatelessWidget {
  const ProfilePlaceholderScreen({super.key});

  void _logout(BuildContext context) {
    SessionService.instance.clear();
    Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.login, (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    final user = SessionService.instance.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: AppColors.primary.withValues(alpha: 0.10),
                  child: const Icon(Icons.person, size: 32, color: AppColors.primary),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user?.name ?? 'User',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                      ),
                      const SizedBox(height: 2),
                      Text(user?.designation ?? 'Official', style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                      Text(user?.id ?? '', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            _MenuTile(icon: Icons.person_outline, label: 'Personal Information', onTap: () {}),
            _MenuTile(icon: Icons.lock_outline, label: 'Change Password', onTap: () {}),
            _MenuTile(icon: Icons.notifications_none, label: 'Notifications', onTap: () {}),
            _MenuTile(icon: Icons.settings_outlined, label: 'App Settings', onTap: () {}),
            _MenuTile(icon: Icons.help_outline, label: 'Help & Support', onTap: () {}),
            _MenuTile(icon: Icons.info_outline, label: 'About', onTap: () {}),

            const SizedBox(height: 12),
            _MenuTile(
              icon: Icons.logout,
              label: 'Logout',
              color: AppColors.error,
              onTap: () => _logout(context),
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  const _MenuTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.textPrimary;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: color == null ? Colors.white : AppColors.error.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color == null ? AppColors.border : AppColors.error.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: c),
            const SizedBox(width: 14),
            Expanded(child: Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: c))),
            if (color == null) const Icon(Icons.chevron_right, size: 18, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}