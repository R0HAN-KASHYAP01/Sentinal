import 'package:flutter/material.dart';
import '../../../core/widgets/dashboard_header.dart';
import '../../../core/widgets/section_header.dart';
import '../../../core/widgets/quick_action_card.dart';
import '../../../core/widgets/summary_stat_card.dart';
import '../../../services/session_service.dart';
import '../../../services/auth_service.dart';
import '../../../services/ngo_reports_service.dart';
import '../../../services/ngo_camera_service.dart';
import '../../../app/routes.dart';

class NgoDashboardScreen extends StatefulWidget {
  const NgoDashboardScreen({super.key});

  @override
  State<NgoDashboardScreen> createState() => _NgoDashboardScreenState();
}

class _NgoDashboardScreenState extends State<NgoDashboardScreen> {
  int? _reportsCount;
  int? _feedsCount;
  bool _loadingStats = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final user = SessionService.instance.currentUser;
    if (user == null) return;

    try {
      final reports = await NgoReportsService.instance.fetchReports(user.id);
      final feeds = await NgoCameraService.instance.fetchFeeds(user.id);
      if (!mounted) return;
      setState(() {
        _reportsCount = reports.length;
        _feedsCount = feeds.length;
        _loadingStats = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loadingStats = false);
    }
  }

  Future<void> _handleLogout() async {
    await AuthService.instance.logout();
    SessionService.instance.clear();
    if (!mounted) return;
    Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.login, (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    final user = SessionService.instance.currentUser;

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadStats,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              DashboardHeader(
                greeting: 'Welcome',
                userName: user?.name ?? 'NGO / Institute',
                onNotificationTap: () {},
                onLogoutTap: _handleLogout,
              ),
              const SizedBox(height: 24),

              const SectionHeader(title: 'Quick Actions'),
              const SizedBox(height: 12),
              GridView.count(
                crossAxisCount: 3,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.95,
                children: [
                  QuickActionCard(
                    icon: Icons.groups_outlined,
                    label: 'Daily Attendance',
                    onTap: () => Navigator.of(context).pushNamed(AppRoutes.ngoAttendance),
                  ),
                  QuickActionCard(
                    icon: Icons.description_outlined,
                    label: 'Reports',
                    onTap: () => Navigator.of(context).pushNamed(AppRoutes.ngoReports),
                  ),
                  QuickActionCard(
                    icon: Icons.videocam_outlined,
                    label: 'Camera / Video',
                    onTap: () => Navigator.of(context).pushNamed(AppRoutes.ngoCamera),
                  ),
                ],
              ),

              const SizedBox(height: 24),
              const SectionHeader(title: 'Overview'),
              const SizedBox(height: 12),
              _loadingStats
                  ? const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Center(child: CircularProgressIndicator(strokeWidth: 2.4)),
                    )
                  : Row(
                      children: [
                        Expanded(
                          child: SummaryStatCard(
                            icon: Icons.description_outlined,
                            label: 'Reports Submitted',
                            count: '${_reportsCount ?? 0}',
                            onTap: () => Navigator.of(context).pushNamed(AppRoutes.ngoReports),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: SummaryStatCard(
                            icon: Icons.videocam_outlined,
                            label: 'Camera Feeds',
                            count: '${_feedsCount ?? 0}',
                            onTap: () => Navigator.of(context).pushNamed(AppRoutes.ngoCamera),
                          ),
                        ),
                      ],
                    ),
            ],
          ),
        ),
      ),
    );
  }
}