import 'package:flutter/material.dart';
import 'dart:async';
import '../data/service/staff_service.dart';
import '../data/model/staff_model.dart';
import 'staff_detail_page.dart';

class MyStaffPage extends StatefulWidget {
  const MyStaffPage({super.key});

  @override
  State<MyStaffPage> createState() => _MyStaffPageState();
}

class _MyStaffPageState extends State<MyStaffPage> {
  Timer? _refreshTimer;
  final TextEditingController _searchController = TextEditingController();
  final StaffService _staffService = StaffService();
  List<StaffModel> staffList = [];
  String searchQuery = '';
  bool _isLoadingStaff = true;

  @override
  void initState() {
    super.initState();
    _fetchClaimedStaff();
    _refreshTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      _fetchClaimedStaff();
    });
    _refreshTimer?.cancel();
  }

  Future<void> _fetchClaimedStaff() async {
    setState(() {
      _isLoadingStaff = true;
    });
    try {
      final staff = await _staffService.fetchClaimedStaff();
      setState(() {
        staffList = staff;
        _isLoadingStaff = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingStaff = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to load staff: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredStaff = staffList
        .where(
          (staff) => staff.staffFullname.toLowerCase().contains(
            searchQuery.toLowerCase(),
          ),
        )
        .toList();
    return Scaffold(
      backgroundColor: const Color(0xFFD9D9D9),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.only(
                left: 12,
                right: 12,
                top: 18,
                bottom: 12,
              ),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF7ED957), Color(0xFFB2F7EF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.black),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'My Staff',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'search staff...',
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                onChanged: (value) {
                  setState(() {
                    searchQuery = value;
                  });
                },
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _isLoadingStaff
                  ? const Center(child: CircularProgressIndicator())
                  : filteredStaff.isEmpty
                  ? const Center(child: Text('No staff found'))
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      itemCount: filteredStaff.length,
                      itemBuilder: (context, index) {
                        final staff = filteredStaff[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: Card(
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            color: Colors.white,
                            child: ListTile(
                              leading: staff.staffImg.isNotEmpty
                                  ? CircleAvatar(
                                      radius: 22,
                                      backgroundColor: Colors.grey[200],
                                      child: ClipOval(
                                        child: Image.network(
                                          staff.staffImg,
                                          width: 44,
                                          height: 44,
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) {
                                                return const Icon(
                                                  Icons.account_circle,
                                                  size: 40,
                                                  color: Colors.black45,
                                                );
                                              },
                                        ),
                                      ),
                                    )
                                  : const Icon(
                                      Icons.account_circle,
                                      size: 40,
                                      color: Colors.black45,
                                    ),
                              title: Text(
                                staff.staffFullname,
                                style: const TextStyle(fontSize: 16),
                              ),
                              subtitle: Text(staff.staffPhone),
                              trailing: const Icon(Icons.chevron_right),
                              onTap: () async {
                                final result = await Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        StaffDetailPage(staffId: staff.id),
                                  ),
                                );
                                if (result == true) {
                                  _fetchClaimedStaff();
                                }
                              },
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
