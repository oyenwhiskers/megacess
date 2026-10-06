import 'package:flutter/material.dart';
import '../view-model/manager_dashboard_view_model.dart';
import 'my_staff_page.dart';
import 'analytics_page.dart';
import 'manage_tasks_page.dart';
import 'mandor_profile_page.dart';
import '../../authorization/view/login_view.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/mega_app_header.dart';
import '../../../core/widgets/mega_metric_card.dart';
import '../../../core/widgets/mega_button.dart';

class ManagerView extends StatefulWidget {
  final String managerName;
  const ManagerView({super.key, this.managerName = 'manager_name'});

  @override
  State<ManagerView> createState() => _ManagerViewState();
}

class _ManagerViewState extends State<ManagerView> {
  final ManagerDashboardViewModel _viewModel = ManagerDashboardViewModel();

  @override
  void initState() {
    super.initState();
    _loadAnalytics();
  }

  Future<void> _loadAnalytics() async {
    await _viewModel.loadAnalytics();
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final analytics = _viewModel.analytics;
    final userName = _viewModel.profile?['user_nickname'] ?? widget.managerName;
    final profileImg = _viewModel.profileImageUrl;

    return Scaffold(
      backgroundColor: AppColors.mcBgApp,
      appBar: MegaAppHeader(
        title: 'Hello, $userName',
        subtitle: 'Estate Supervisor (Mandor)',
        actions: [
          GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const MandorProfilePage()),
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
        child: RefreshIndicator(
          onRefresh: _loadAnalytics,
          color: AppColors.frond6,
          backgroundColor: AppColors.mcBgSurface,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header section title
                Text(
                  'Task Overview',
                  style: AppTypography.titleMedium,
                ),
                const SizedBox(height: 12),

                if (_viewModel.isLoading)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 40.0),
                    child: Center(child: CircularProgressIndicator(color: AppColors.frond6)),
                  )
                else if (analytics == null)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.mcBgSurface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.mcBorder),
                    ),
                    child: Center(
                      child: Text(
                        _viewModel.errorMessage ?? 'No task analytics data available.',
                        style: AppTypography.caption,
                      ),
                    ),
                  )
                else ...[
                  // Grid of KPI Metric Cards
                  Row(
                    children: [
                      Expanded(
                        child: MegaMetricCard(
                          label: 'Total Tasks',
                          value: '${analytics.totalTasks}',
                          subtitle: 'All assigned tasks',
                          icon: Icons.assignment_outlined,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: MegaMetricCard(
                          label: 'In Progress',
                          value: '${analytics.inProgress}',
                          subtitle: 'Active in field',
                          icon: Icons.play_arrow_outlined,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: MegaMetricCard(
                          label: 'Pending',
                          value: '${analytics.pending}',
                          subtitle: 'Awaiting audit',
                          icon: Icons.hourglass_empty,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: MegaMetricCard(
                          label: 'Completed',
                          value: '${analytics.completed}',
                          subtitle: 'Verified & closed',
                          icon: Icons.check_circle_outline,
                        ),
                      ),
                    ],
                  ),
                ],

                const SizedBox(height: 24),

                // Operational Modules Section
                Text(
                  'Operations & Labor',
                  style: AppTypography.titleMedium,
                ),
                const SizedBox(height: 12),

                _buildModuleTile(
                  context,
                  title: 'Manage Tasks',
                  subtitle: 'Create tasks, select blocks & assign workers',
                  icon: Icons.fact_check_outlined,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const ManageTasksPage()),
                    );
                  },
                ),
                const SizedBox(height: 10),

                _buildModuleTile(
                  context,
                  title: 'My Staff',
                  subtitle: 'Worker directory, active crew & assignments',
                  icon: Icons.badge_outlined,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const MyStaffPage()),
                    );
                  },
                ),
                const SizedBox(height: 10),

                _buildModuleTile(
                  context,
                  title: 'Task Analytics',
                  subtitle: 'Field logs, block productivity & progress',
                  icon: Icons.insights_outlined,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const AnalyticsPage()),
                    );
                  },
                ),

                const SizedBox(height: 28),

                // Sign out button
                MegaButton(
                  text: 'Sign Out',
                  icon: Icons.logout,
                  variant: MegaButtonVariant.outline,
                  width: double.infinity,
                  onPressed: () async {
                    await _viewModel.logout();
                    if (context.mounted) {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (_) => const LoginView()),
                        (route) => false,
                      );
                    }
                  },
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModuleTile(
    BuildContext context, {
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
