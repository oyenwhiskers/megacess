import 'package:flutter/material.dart';
import '../data/service/manager_service.dart';
import '../../authorization/data/service/auth_service.dart';
import '../../authorization/view/login_view.dart';
import 'location_view.dart';
import 'analytics_view.dart';
import 'manager_profile_page.dart';
import 'package:megacess/core/config/flavor_config.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/mega_app_header.dart';
import '../../../core/widgets/mega_metric_card.dart';
import '../../../core/widgets/mega_button.dart';

class ManagerView extends StatefulWidget {
  final String managerName;

  const ManagerView({super.key, required this.managerName});

  @override
  State<ManagerView> createState() => _ManagerViewState();
}

class _ManagerViewState extends State<ManagerView> {
  final ManagerService _managerService = ManagerService();
  int _totalInProgress = 0;
  int _totalCompleted = 0;
  bool _isLoading = true;
  Map<String, dynamic>? _profile;

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

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final analyticsData = await _managerService.fetchManagerAnalytics();
      final taskAnalytics = analyticsData['data']?['task_analytics'] ?? {};
      final profile = await _managerService.fetchProfile();

      if (mounted) {
        setState(() {
          _totalInProgress = taskAnalytics['in_progress'] ?? 0;
          _totalCompleted = taskAnalytics['completed'] ?? 0;
          _profile = {
            'user_img': profile.userImg,
            'user_nickname': profile.userNickname,
            'user_fullname': profile.userFullname,
          };
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load data: $e'),
            backgroundColor: AppColors.mcStatusDanger,
          ),
        );
      }
    }
  }

  Future<void> _refreshData() async {
    setState(() {
      _isLoading = true;
    });
    await _loadData();
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
  Widget build(BuildContext context) {
    final displayName = _profile?['user_nickname'] ?? widget.managerName;
    final profileImg = _profileImageUrl;

    return Scaffold(
      backgroundColor: AppColors.mcBgApp,
      appBar: MegaAppHeader(
        title: 'Hello, $displayName',
        subtitle: 'Estate General Manager',
        actions: [
          GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ManagerProfilePage()),
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
          onRefresh: _refreshData,
          color: AppColors.frond6,
          backgroundColor: AppColors.mcBgSurface,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Estate Operational Summary',
                  style: AppTypography.titleMedium,
                ),
                const SizedBox(height: 12),

                if (_isLoading)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 40.0),
                    child: Center(
                      child: CircularProgressIndicator(color: AppColors.frond6),
                    ),
                  )
                else ...[
                  Row(
                    children: [
                      Expanded(
                        child: MegaMetricCard(
                          label: 'In Progress Tasks',
                          value: '$_totalInProgress',
                          subtitle: 'Active across blocks',
                          icon: Icons.play_arrow_outlined,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: MegaMetricCard(
                          label: 'Completed Tasks',
                          value: '$_totalCompleted',
                          subtitle: 'Audited & verified',
                          icon: Icons.check_circle_outline,
                        ),
                      ),
                    ],
                  ),
                ],

                const SizedBox(height: 24),

                Text(
                  'Management Portals',
                  style: AppTypography.titleMedium,
                ),
                const SizedBox(height: 12),

                _buildModuleTile(
                  title: 'Block Locations & Tasks',
                  subtitle: 'Inspect estate blocks, divisions & ongoing activities',
                  icon: Icons.location_on_outlined,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const LocationView()),
                    );
                  },
                ),
                const SizedBox(height: 10),

                _buildModuleTile(
                  title: 'Estate Analytics',
                  subtitle: 'Monthly yield harvested, labor attendance & resources',
                  icon: Icons.insights_outlined,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const AnalyticsView()),
                    );
                  },
                ),

                const SizedBox(height: 28),

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
