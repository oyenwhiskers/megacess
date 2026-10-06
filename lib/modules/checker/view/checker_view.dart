import 'package:flutter/material.dart';
import '../data/model/checker_analytics.dart';
import '../data/service/checker_analytics_service.dart';
import '../../authorization/data/service/auth_service.dart';
import '../../authorization/view/login_view.dart';
import 'manage_attendance_view.dart';
import 'audit_tasks_page.dart';
import 'checker_profile_page.dart';
import 'analytics_view.dart';
import 'package:megacess/core/config/flavor_config.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/mega_app_header.dart';
import '../../../core/widgets/mega_metric_card.dart';
import '../../../core/widgets/mega_button.dart';

class CheckerView extends StatefulWidget {
  final String checkerName;

  const CheckerView({super.key, this.checkerName = 'Checker'});

  @override
  State<CheckerView> createState() => _CheckerViewState();
}

class _CheckerViewState extends State<CheckerView> {
  late Future<CheckerAnalytics> _analyticsFuture;
  Map<String, dynamic>? _profile;
  String? _error;

  String? _getFullImageUrl(String? userImg) {
    if (userImg == null || userImg.isEmpty) {
      return null;
    }
    if (userImg.startsWith('http://') || userImg.startsWith('https://')) {
      return userImg;
    }
    return '${FlavorConfig.instance.baseDomain}/$userImg';
  }

  String? get _profileImageUrl {
    return _getFullImageUrl(_profile?['user_img']);
  }

  Future<void> _logout() async {
    await AuthService().logout();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginView()),
      (route) => false,
    );
  }

  @override
  void initState() {
    super.initState();
    _analyticsFuture = _fetchAnalytics();
  }

  Future<CheckerAnalytics> _fetchAnalytics() async {
    try {
      final service = CheckerAnalyticsService();
      final analytics = await service.fetchCheckerAnalytics();
      final profile = await service.fetchProfile();
      if (mounted) {
        setState(() {
          _profile = profile;
        });
      }
      return analytics;
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
        });
      }
      rethrow;
    }
  }

  Future<void> _refreshAnalytics() async {
    try {
      if (mounted) {
        setState(() {
          _error = null;
        });
      }
      final service = CheckerAnalyticsService();
      final newData = await service.fetchCheckerAnalytics();
      final profile = await service.fetchProfile();
      if (mounted) {
        setState(() {
          _analyticsFuture = Future.value(newData);
          _profile = profile;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final displayName = _profile?['user_nickname'] ?? widget.checkerName;
    final profileImg = _profileImageUrl;

    return Scaffold(
      backgroundColor: AppColors.mcBgApp,
      appBar: MegaAppHeader(
        title: 'Hello, $displayName',
        subtitle: 'Field Quality & Muster Inspector (Checker)',
        actions: [
          GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const CheckerProfilePage()),
              );
            },
            child: Container(
              margin: const EdgeInsets.only(right: 4),
              child: CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.frond7,
                backgroundImage: profileImg != null ? NetworkImage(profileImg) : null,
                child: profileImg == null
                    ? const Icon(Icons.person, color: Colors.white, size: 22)
                    : null,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: FutureBuilder<CheckerAnalytics>(
          future: _analyticsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.frond6),
              );
            } else if (snapshot.hasError || _error != null) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.error_outline, size: 48, color: AppColors.mcStatusDanger),
                      const SizedBox(height: 12),
                      Text('Failed to load analytics', style: AppTypography.titleMedium),
                      const SizedBox(height: 6),
                      Text(
                        _error ?? snapshot.error.toString(),
                        style: AppTypography.captionMuted,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _refreshAnalytics,
                        child: const Text('Try Again'),
                      ),
                    ],
                  ),
                ),
              );
            } else if (snapshot.hasData) {
              final data = snapshot.data!;
              return RefreshIndicator(
                onRefresh: _refreshAnalytics,
                color: AppColors.frond6,
                backgroundColor: AppColors.mcBgSurface,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Section Header
                      Text(
                        'Audit & Labor Metrics',
                        style: AppTypography.titleMedium,
                      ),
                      const SizedBox(height: 12),

                      // Metric Cards Grid
                      Row(
                        children: [
                          Expanded(
                            child: MegaMetricCard(
                              label: 'Pending Audits',
                              value: '${data.pendingTaskCount}',
                              subtitle: 'Inspections required',
                              icon: Icons.hourglass_empty,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: MegaMetricCard(
                              label: 'Absent Labor',
                              value: '${data.absentPeopleCount}',
                              subtitle: 'Unaccounted today',
                              icon: Icons.person_off_outlined,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: MegaMetricCard(
                              label: 'Completed Tasks',
                              value: '${data.completeTaskCount}',
                              subtitle: 'Verified & closed',
                              icon: Icons.check_circle_outline,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: MegaMetricCard(
                              label: 'Payroll Cycle',
                              value: '${data.timeUntilPayroll}',
                              unit: 'days',
                              subtitle: 'Remaining in period',
                              icon: Icons.calendar_today_outlined,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Checker Operations Modules
                      Text(
                        'Inspection Modules',
                        style: AppTypography.titleMedium,
                      ),
                      const SizedBox(height: 12),

                      _buildModuleTile(
                        title: 'Check Attendance',
                        subtitle: 'Daily muster roll, staff & worker check-in/out',
                        icon: Icons.fact_check_outlined,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const ManageAttendanceView()),
                          );
                        },
                      ),
                      const SizedBox(height: 10),

                      _buildModuleTile(
                        title: 'Audit Tasks',
                        subtitle: 'Inspect field quality, verify output & sign-off',
                        icon: Icons.verified_outlined,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const AuditTasksPage()),
                          );
                        },
                      ),
                      const SizedBox(height: 10),

                      _buildModuleTile(
                        title: 'Inspection Analytics',
                        subtitle: 'Auditor performance & verification history',
                        icon: Icons.analytics_outlined,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const AnalyticsView()),
                          );
                        },
                      ),

                      const SizedBox(height: 28),

                      // Sign Out Button
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
            return const SizedBox();
          },
        ),
      ),
    );
  }

  Widget _buildModuleTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.mcBgSurface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.mcBorder, width: 1),
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: const BoxDecoration(
                  color: AppColors.frond0,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(icon, color: AppColors.frond6, size: 22),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppTypography.bodyBold),
                    const SizedBox(height: 2),
                    Text(subtitle, style: AppTypography.captionMuted),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.mcTextDisabled, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
