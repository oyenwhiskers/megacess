import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/mega_app_header.dart';
import '../../../core/widgets/mega_button.dart';
import '../../../core/widgets/mega_metric_card.dart';
import '../../authorization/data/service/auth_service.dart';
import '../../authorization/view/login_view.dart';
import '../../checker/view/analytics_view.dart' as checker;
import '../../checker/view/audit_tasks_page.dart';
import '../../checker/view/manage_attendance_view.dart';
import '../../manager/data/service/manager_service.dart';
import '../../manager/view/analytics_view.dart' as manager;
import '../../manager/view/location_view.dart';
import '../../manager/view/manager_profile_page.dart';

class AdminView extends StatefulWidget {
  final String adminName;

  const AdminView({super.key, this.adminName = 'Administrator'});

  @override
  State<AdminView> createState() => _AdminViewState();
}

class _AdminViewState extends State<AdminView> {
  final ManagerService _managerService = ManagerService();
  bool _isLoading = true;
  String? _error;
  String? _displayName;
  int _inProgress = 0;
  int _completed = 0;
  int _absent = 0;

  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }

  Future<void> _loadDashboard() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _error = null;
      });
    }

    try {
      final analytics = await _managerService.fetchManagerAnalytics();
      final profile = await _managerService.fetchProfile();
      final data = analytics['data'] as Map<String, dynamic>? ?? const {};
      final tasks = data['task_analytics'] as Map<String, dynamic>? ?? const {};

      if (!mounted) return;
      setState(() {
        _displayName = profile.userNickname;
        _inProgress = (tasks['in_progress'] as num?)?.toInt() ?? 0;
        _completed = (tasks['completed'] as num?)?.toInt() ?? 0;
        _absent = (data['total_absent'] as num?)?.toInt() ?? 0;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.toString().replaceFirst('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  void _open(Widget page) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
  }

  Future<void> _logout() async {
    await AuthService().logout();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginView()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final name = _displayName?.isNotEmpty == true
        ? _displayName!
        : widget.adminName;

    return Scaffold(
      backgroundColor: AppColors.mcBgApp,
      appBar: MegaAppHeader(
        title: 'Hello, $name',
        subtitle: 'Administrator Operations Centre',
        actions: [
          IconButton(
            tooltip: 'My profile',
            onPressed: () => _open(const ManagerProfilePage()),
            icon: const Icon(Icons.account_circle_outlined, color: Colors.white),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadDashboard,
        color: AppColors.mcForestGreen,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          children: [
            Text('Estate Overview', style: AppTypography.titleMedium),
            const SizedBox(height: 12),
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 28),
                child: Center(
                  child: CircularProgressIndicator(color: AppColors.mcForestGreen),
                ),
              )
            else ...[
              if (_error != null)
                _DashboardMessage(message: _error!, onRetry: _loadDashboard),
              Row(
                children: [
                  Expanded(
                    child: MegaMetricCard(
                      label: 'In Progress',
                      value: '$_inProgress',
                      subtitle: 'Active tasks',
                      icon: Icons.pending_actions_outlined,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: MegaMetricCard(
                      label: 'Completed',
                      value: '$_completed',
                      subtitle: 'Verified tasks',
                      icon: Icons.task_alt_outlined,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              MegaMetricCard(
                label: 'Absent Today',
                value: '$_absent',
                subtitle: 'Workers requiring attention',
                icon: Icons.person_off_outlined,
              ),
            ],
            const SizedBox(height: 24),
            Text('Administration & Operations', style: AppTypography.titleMedium),
            const SizedBox(height: 12),
            _AdminActionCard(
              title: 'Locations & Tasks',
              subtitle: 'Manage estate blocks and operational tasks',
              icon: Icons.location_on_outlined,
              onTap: () => _open(const LocationView()),
            ),
            _AdminActionCard(
              title: 'Audit Tasks',
              subtitle: 'Inspect, approve, or reject submitted field work',
              icon: Icons.fact_check_outlined,
              onTap: () => _open(const AuditTasksPage()),
            ),
            _AdminActionCard(
              title: 'Muster Attendance',
              subtitle: 'Manage daily staff and management attendance',
              icon: Icons.groups_2_outlined,
              onTap: () => _open(const ManageAttendanceView()),
            ),
            _AdminActionCard(
              title: 'Estate Analytics',
              subtitle: 'Review tasks, resource usage, and completion trends',
              icon: Icons.insights_outlined,
              onTap: () => _open(const manager.AnalyticsView()),
            ),
            _AdminActionCard(
              title: 'Verification Analytics',
              subtitle: 'Review audit, absence, and payroll-cycle metrics',
              icon: Icons.analytics_outlined,
              onTap: () => _open(const checker.AnalyticsView()),
            ),
            _AdminActionCard(
              title: 'My Profile',
              subtitle: 'Update account details and password',
              icon: Icons.manage_accounts_outlined,
              onTap: () => _open(const ManagerProfilePage()),
            ),
            const SizedBox(height: 12),
            MegaButton(
              text: 'Sign Out',
              icon: Icons.logout,
              variant: MegaButtonVariant.outline,
              width: double.infinity,
              onPressed: _logout,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _AdminActionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const _AdminActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      color: AppColors.mcBgSurface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: AppColors.mcBorder),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: AppColors.frond0,
          child: Icon(icon, color: AppColors.mcForestGreen),
        ),
        title: Text(title, style: AppTypography.titleMedium),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(subtitle, style: AppTypography.captionMuted),
        ),
        trailing: const Icon(Icons.chevron_right, color: AppColors.mcTextMuted),
        onTap: onTap,
      ),
    );
  }
}

class _DashboardMessage extends StatelessWidget {
  final String message;
  final Future<void> Function() onRetry;

  const _DashboardMessage({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.mcStatusDanger.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.cloud_off_outlined, color: AppColors.mcStatusDanger),
          const SizedBox(width: 10),
          Expanded(child: Text(message, style: AppTypography.caption)),
          TextButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}
