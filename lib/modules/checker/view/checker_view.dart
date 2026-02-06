import 'package:megacess/modules/checker/view/analytics_view.dart';

import 'package:flutter/material.dart';

import '../data/model/checker_analytics.dart';
import '../data/service/checker_analytics_service.dart';
import '../../authorization/view/login_view.dart';
import '../../utility/secure_storage_service.dart';
import 'manage_attendance_view.dart';
import 'audit_tasks_page.dart';
import 'checker_profile_page.dart';
import 'package:megacess/core/config/flavor_config.dart';

class CheckerView extends StatefulWidget {
  final String checkerName;

  const CheckerView({super.key, this.checkerName = 'checker_name'});

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

    // Check if the URL already starts with http:// or https://
    if (userImg.startsWith('http://') || userImg.startsWith('https://')) {
      return userImg;
    }

    // If not, prepend the base URL
    return '${FlavorConfig.instance.baseDomain}/$userImg';
  }

  String? get _profileImageUrl {
    return _getFullImageUrl(_profile?['user_img']);
  }

  Future<void> _logout() async {
    // Remove session/token from secure storage
    final storage = SecureStorageService();
    await storage.deleteToken();
    await storage.deleteUserRole();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => LoginView()),
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
      setState(() {
        _profile = profile;
      });
      return analytics;
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
      rethrow;
    }
  }

  Future<void> _refreshAnalytics() async {
    try {
      setState(() {
        _error = null;
      });
      final service = CheckerAnalyticsService();
      final newData = await service.fetchCheckerAnalytics();
      final profile = await service.fetchProfile();
      setState(() {
        _analyticsFuture = Future.value(newData);
        _profile = profile;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD9D9D9),
      body: SafeArea(
        child: FutureBuilder<CheckerAnalytics>(
          future: _analyticsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError || _error != null) {
              return Center(
                child: Text(
                  _error ?? 'Failed to load analytics',
                  style: const TextStyle(color: Colors.red),
                ),
              );
            } else if (snapshot.hasData) {
              final data = snapshot.data!;
              return RefreshIndicator(
                onRefresh: _refreshAnalytics,
                color: const Color(0xFF7ED957),
                backgroundColor: Colors.white,
                strokeWidth: 3.0,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12.0,
                      vertical: 8.0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 16,
                          ),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF7ED957), Color(0xFFB2F7EF)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(24),
                              bottomRight: Radius.circular(24),
                              topLeft: Radius.circular(12),
                              topRight: Radius.circular(12),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Hello, ${_profile?['user_nickname'] ?? widget.checkerName}',
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              Stack(
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              const CheckerProfilePage(),
                                        ),
                                      );
                                    },
                                    child: CircleAvatar(
                                      backgroundColor: Colors.white,
                                      radius: 22,
                                      backgroundImage: _profileImageUrl != null
                                          ? NetworkImage(_profileImageUrl!)
                                          : null,
                                      child: _profileImageUrl == null
                                          ? Icon(
                                              Icons.person,
                                              color: Colors.grey[700],
                                              size: 28,
                                            )
                                          : null,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Days before payroll
                        Card(
                          elevation: 2,
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 18.0,
                              horizontal: 8.0,
                            ),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text(
                                      'Days before payroll',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    SizedBox(width: 6),
                                    const Icon(
                                      Icons.payments,
                                      size: 18,
                                      color: Colors.purple,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  '${data.timeUntilPayroll}',
                                  style: const TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),

                        // Pending Approval
                        Card(
                          elevation: 1,
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12.0),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.pause_circle_filled,
                                      color: Colors.amber,
                                    ),
                                    SizedBox(width: 6),
                                    const Text(
                                      'Pending Approval',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  '${data.pendingTaskCount}',
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.amber,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 8),

                        // Absent & Completed
                        Row(
                          children: [
                            Expanded(
                              child: Card(
                                elevation: 1,
                                color: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12.0,
                                  ),
                                  child: Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          const Icon(
                                            Icons.remove_circle,
                                            color: Colors.red,
                                          ),
                                          SizedBox(width: 4),
                                          const Text(
                                            'Absent',
                                            style: TextStyle(fontSize: 13),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '${data.absentPeopleCount}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                          color: Colors.red,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Card(
                                elevation: 1,
                                color: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12.0,
                                  ),
                                  child: Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          const Icon(
                                            Icons.check_circle,
                                            color: Colors.green,
                                          ),
                                          SizedBox(width: 4),
                                          const Text(
                                            'Completed',
                                            style: TextStyle(fontSize: 13),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '${data.completeTaskCount}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                          color: Colors.green,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),

                        // Modules Section
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Modules:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Module Cards
                        Card(
                          elevation: 1,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          color: Colors.white,
                          child: ListTile(
                            leading: const Icon(
                              Icons.verified_user,
                              color: Colors.teal,
                              size: 26,
                            ),
                            title: const Text(
                              'Check Attendance',
                              style: TextStyle(fontSize: 15),
                            ),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const ManageAttendanceView(),
                                ),
                              );
                            },
                          ),
                        ),
                        Card(
                          elevation: 1,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          color: Colors.white,
                          child: ListTile(
                            leading: const Icon(
                              Icons.assignment,
                              color: Colors.teal,
                              size: 26,
                            ),
                            title: const Text(
                              'Audit Tasks',
                              style: TextStyle(fontSize: 15),
                            ),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const AuditTasksPage(),
                                ),
                              );
                            },
                          ),
                        ),
                        Card(
                          elevation: 1,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          color: Colors.white,
                          child: ListTile(
                            leading: const Icon(
                              Icons.bar_chart,
                              color: Colors.teal,
                              size: 26,
                            ),
                            title: const Text(
                              'Analytics',
                              style: TextStyle(fontSize: 15),
                            ),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => const AnalyticsView(),
                                ),
                              );
                            },
                          ),
                        ),

                        // Logout Button
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4.0,
                            vertical: 16.0,
                          ),
                          child: SizedBox(
                            width: double.infinity,
                            height: 46,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                elevation: 0,
                              ),
                              onPressed: _logout,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.logout, size: 20),
                                  const SizedBox(width: 8),
                                  const Text(
                                    'LOG OUT',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
              // (Removed duplicate/invalid _logout at the end of the file)
            } else {
              return const Center(child: Text('No data available'));
            }
          },
        ),
      ),
    );
  }
}
