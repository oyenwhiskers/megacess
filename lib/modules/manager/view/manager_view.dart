import 'package:flutter/material.dart';
import '../data/service/manager_service.dart';
import '../data/model/manager_models.dart';
import '../../authorization/view/login_view.dart';
import '../../utility/secure_storage_service.dart';
import 'location_view.dart';
import 'analytics_view.dart';
import 'manager_profile_page.dart';

class ManagerView extends StatefulWidget {
  final String managerName;
  
  const ManagerView({
    Key? key, 
    required this.managerName
  }) : super(key: key);

  @override
  State<ManagerView> createState() => _ManagerViewState();
}

class _ManagerViewState extends State<ManagerView> {
  final ManagerService _managerService = ManagerService();
  ManagerStats? _stats;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final stats = await _managerService.getManagerStats();
      setState(() {
        _stats = stats;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load data: $e')),
      );
    }
  }

  Future<void> _refreshData() async {
    setState(() {
      _isLoading = true;
    });
    try {
      await _loadData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Data refreshed successfully'),
            backgroundColor: Color(0xFF43C463),
            duration: Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      // Error is already handled in _loadData()
    }
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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD9D9D9),
      body: SafeArea(
        child: Stack(
          children: [
            // Main content with RefreshIndicator
            RefreshIndicator(
              onRefresh: _refreshData,
              color: const Color(0xFF43C463),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                  // Header section
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 20,
                    ),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF43C463), Color(0xFF70E4A6)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(32),
                        bottomRight: Radius.circular(32),
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
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const ManagerProfilePage(),
                              ),
                            );
                          },
                          child: const CircleAvatar(
                            backgroundColor: Colors.white,
                            child: Icon(
                              Icons.person,
                              color: Colors.grey,
                              size: 28,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                      const SizedBox(height: 18),
                      
                      // Content area
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Column(
                          children: [
                          // Statistics Cards
                          Column(
                                children: [
                                  // Total In-Progress Card
                                  Card(
                                    elevation: 0,
                                    color: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
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
                                                'Total In-Progress',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 15,
                                                ),
                                              ),
                                              const SizedBox(width: 6),
                                              const Icon(
                                                Icons.arrow_forward,
                                                size: 18,
                                                color: Color(0xFF43C463),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            '${_stats?.totalInProgress ?? 27}',
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
                                  
                                  // Total Completed Card
                                  Card(
                                    elevation: 0,
                                    color: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 14.0,
                                        horizontal: 8.0,
                                      ),
                                      child: Column(
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              const Icon(
                                                Icons.check_circle,
                                                color: Color(0xFF43C463),
                                              ),
                                              const SizedBox(width: 6),
                                              const Text(
                                                'Total Completed',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 15,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            '${_stats?.totalCompleted ?? 67}',
                                            style: const TextStyle(
                                              fontSize: 22,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF43C463),
                                            ),
                                          ),
                                        ],
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
                          
                          // Module Items
                          Card(
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            color: Colors.white,
                            child: ListTile(
                              leading: const Icon(
                                Icons.location_on,
                                color: Colors.teal,
                                size: 26,
                              ),
                              title: const Text(
                                'View Tasks',
                                style: TextStyle(fontSize: 15),
                              ),
                              trailing: const Icon(Icons.chevron_right),
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(builder: (_) => const LocationView()),
                                );
                              },
                            ),
                          ),
                          
                          Card(
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            color: Colors.white,
                            child: ListTile(
                              leading: const Icon(
                                Icons.analytics,
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
                                  MaterialPageRoute(builder: (_) => const AnalyticsView()),
                                );
                              },
                            ),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Logout Button
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            minimumSize: const Size.fromHeight(48),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          icon: const Icon(Icons.logout),
                          label: const Text(
                            'LOG OUT',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          onPressed: _logout,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            // Loading overlay in background layer
            if (_isLoading)
              Positioned.fill(
                child: Container(
                  color: Colors.black.withOpacity(0.1),
                  child: const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF43C463),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

}