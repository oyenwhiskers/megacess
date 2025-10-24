import 'package:flutter/material.dart';
import '../view-model/manager_dashboard_view_model.dart';
import 'my_staff_page.dart';
import 'analytics_page.dart';
import 'manage_tasks_page.dart';
import '../../authorization/view/login_view.dart';

class ManagerView extends StatefulWidget {
  final String managerName;
  const ManagerView({Key? key, this.managerName = 'manager_name'})
    : super(key: key);

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
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final analytics = _viewModel.analytics;
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: SafeArea(
        child: SingleChildScrollView(
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
                    gradient: LinearGradient(
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
                        'Hello, ${widget.managerName}',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      Stack(
                        children: [
                          CircleAvatar(
                            backgroundColor: Colors.white,
                            radius: 22,
                            child: Icon(
                              Icons.person,
                              color: Colors.grey[700],
                              size: 28,
                            ),
                          ),
                          Positioned(
                            top: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.redAccent,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                'DEBUG',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _viewModel.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : analytics == null
                    ? Center(child: Text(_viewModel.errorMessage ?? 'No data'))
                    : Column(
                        children: [
                          Card(
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                            color: Colors.white,
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
                                      Text(
                                        'Total Tasks',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      SizedBox(width: 6),
                                      Icon(
                                        Icons.calendar_today,
                                        size: 18,
                                        color: Colors.grey[700],
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 6),
                                  Text(
                                    '${analytics.totalTasks}',
                                    style: TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: Card(
                                  elevation: 1,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  color: Colors.white,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12.0,
                                    ),
                                    child: Column(
                                      children: [
                                        Icon(
                                          Icons.play_arrow,
                                          color: Colors.green,
                                          size: 22,
                                        ),
                                        SizedBox(height: 2),
                                        Text(
                                          'In-Progress',
                                          style: TextStyle(fontSize: 13),
                                        ),
                                        SizedBox(height: 2),
                                        Text(
                                          '${analytics.inProgress}',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: 8),
                              Expanded(
                                child: Card(
                                  elevation: 1,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  color: Colors.white,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12.0,
                                    ),
                                    child: Column(
                                      children: [
                                        Icon(
                                          Icons.pause_circle_filled,
                                          color: Colors.amber,
                                          size: 22,
                                        ),
                                        SizedBox(height: 2),
                                        Text(
                                          'Pending',
                                          style: TextStyle(fontSize: 13),
                                        ),
                                        SizedBox(height: 2),
                                        Text(
                                          '${analytics.pending}',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                            color: Colors.amber,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: Card(
                                  elevation: 1,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  color: Colors.white,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12.0,
                                    ),
                                    child: Column(
                                      children: [
                                        Icon(
                                          Icons.cancel,
                                          color: Colors.red,
                                          size: 22,
                                        ),
                                        SizedBox(height: 2),
                                        Text(
                                          'Reject',
                                          style: TextStyle(fontSize: 13),
                                        ),
                                        SizedBox(height: 2),
                                        Text(
                                          '${analytics.rejected}',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                            color: Colors.red,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: 8),
                              Expanded(
                                child: Card(
                                  elevation: 1,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  color: Colors.white,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12.0,
                                    ),
                                    child: Column(
                                      children: [
                                        Icon(
                                          Icons.check_circle,
                                          color: Colors.green,
                                          size: 22,
                                        ),
                                        SizedBox(height: 2),
                                        Text(
                                          'Completed',
                                          style: TextStyle(fontSize: 13),
                                        ),
                                        SizedBox(height: 2),
                                        Text(
                                          '${analytics.completed}',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
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
                          SizedBox(height: 14),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Modules:',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                          ),
                          SizedBox(height: 8),
                          Card(
                            elevation: 1,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            color: Colors.white,
                            child: ListTile(
                              leading: Icon(
                                Icons.groups,
                                color: Colors.teal,
                                size: 26,
                              ),
                              title: Text(
                                'My Staff',
                                style: TextStyle(fontSize: 15),
                              ),
                              trailing: Icon(Icons.chevron_right),
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => const MyStaffPage(),
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
                              leading: Icon(
                                Icons.assignment,
                                color: Colors.teal,
                                size: 26,
                              ),
                              title: Text(
                                'Manage Tasks',
                                style: TextStyle(fontSize: 15),
                              ),
                              trailing: Icon(Icons.chevron_right),
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const ManageTasksPage(),
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
                              leading: Icon(
                                Icons.bar_chart,
                                color: Colors.teal,
                                size: 26,
                              ),
                              title: Text(
                                'Analytics',
                                style: TextStyle(fontSize: 15),
                              ),
                              trailing: Icon(Icons.chevron_right),
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => const AnalyticsPage(),
                                  ),
                                );
                              },
                            ),
                          ),
                          // LOG OUT BUTTON directly after modules
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 4.0,
                              vertical: 16.0,
                            ),
                            child: SizedBox(
                              width: double.infinity,
                              height: 54,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  elevation: 0,
                                ),
                                onPressed: () async {
                                  await _viewModel.logout();
                                  if (mounted) {
                                    Navigator.of(context).pushAndRemoveUntil(
                                      MaterialPageRoute(
                                        builder: (_) => LoginView(),
                                      ),
                                      (route) => false,
                                    );
                                  }
                                },
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.logout, size: 22),
                                    const SizedBox(width: 10),
                                    const Text(
                                      'LOG OUT',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                // ... Add bottom navigation or other widgets as needed
              ],
            ),
          ),
        ),
      ),
    );
  }
}
