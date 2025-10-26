import 'package:megacess/modules/checker/data/model/staff_attendance_model.dart';
import 'package:flutter/material.dart';
import 'package:megacess/modules/checker/data/model/user_attendance_model.dart';
import 'package:megacess/modules/checker/data/service/attendance_service.dart';
import 'package:megacess/modules/checker/view/manage_attendance_staff_detail_view.dart';
import 'package:megacess/modules/checker/view/manage_attendance_management_detail_view.dart';
import 'package:megacess/modules/utility/secure_storage_service.dart';

class ManageAttendanceDetailsView extends StatefulWidget {
  final int dateAttendanceId;
  final String dateLabel;
  const ManageAttendanceDetailsView({
    Key? key,
    required this.dateAttendanceId,
    required this.dateLabel,
  }) : super(key: key);

  @override
  State<ManageAttendanceDetailsView> createState() =>
      _ManageAttendanceDetailsViewState();
}

class _ManageAttendanceDetailsViewState
    extends State<ManageAttendanceDetailsView> {
  late Future<StaffAttendanceListResponse> _staffAttendanceFuture;
  late Future<UserAttendanceListResponse> _attendanceFuture;
  final TextEditingController _searchController = TextEditingController();
  String _search = '';
  int _selectedTab = 0; // 0: Management, 1: Staff

  @override
  void initState() {
    super.initState();
    _fetchAttendance();
    _fetchStaffAttendance();
  }

  void _fetchAttendance() {
    setState(() {
      _attendanceFuture = AttendanceService(
        SecureStorageService(),
      ).fetchUserAttendanceList(dateAttendanceId: widget.dateAttendanceId);
    });
  }

  void _fetchStaffAttendance() {
    setState(() {
      _staffAttendanceFuture = AttendanceService(
        SecureStorageService(),
      ).fetchStaffAttendanceList(dateAttendanceId: widget.dateAttendanceId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD9D9D9),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(
              top: 40,
              left: 16,
              right: 16,
              bottom: 18,
            ),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF43C463), Color(0xFFB2F7EF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(32),
                bottomRight: Radius.circular(32),
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
                  'Manage Attendance',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedTab = 0;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: _selectedTab == 0
                            ? Colors.white
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          'Management',
                          style: TextStyle(
                            color: _selectedTab == 0
                                ? const Color(0xFF43C463)
                                : Colors.grey,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedTab = 1;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: _selectedTab == 1
                            ? Colors.white
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          'Staff',
                          style: TextStyle(
                            color: _selectedTab == 1
                                ? const Color(0xFF43C463)
                                : Colors.grey,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Text(
                  'Date: ${widget.dateLabel}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _selectedTab == 0
                ? FutureBuilder<UserAttendanceListResponse>(
                    future: _attendanceFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(
                          child: Text('Failed to load user attendance.'),
                        );
                      } else if (!snapshot.hasData ||
                          snapshot.data!.data.isEmpty) {
                        return const Center(
                          child: Text('No user attendance records found.'),
                        );
                      }
                      final attendanceList = snapshot.data!;
                      // Filter by search
                      final filtered = _search.isEmpty
                          ? attendanceList.data
                          : attendanceList.data
                                .where(
                                  (item) => item.userName
                                      .toLowerCase()
                                      .contains(_search.toLowerCase()),
                                )
                                .toList();
                      if (filtered.isEmpty) {
                        return const Center(
                          child: Text('No user attendance records found.'),
                        );
                      }
                      return ListView.builder(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 0,
                          vertical: 8,
                        ),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final item = filtered[index];
                          return Container(
                            margin: const EdgeInsets.only(
                              bottom: 12,
                              left: 16,
                              right: 16,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 3,
                                  offset: Offset(0, 1),
                                ),
                              ],
                            ),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundImage: item.userImg.isNotEmpty
                                    ? NetworkImage(item.userImg)
                                    : const AssetImage(
                                            'assets/images/default_avatar.png',
                                          )
                                          as ImageProvider,
                                radius: 28,
                              ),
                              title: Text(
                                'Name: ${item.userName}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Status: ${item.status}'),
                                  Text(
                                    'Checked by: ${item.checkedinBy ?? '-'}',
                                  ),
                                ],
                              ),
                              trailing: const Icon(Icons.chevron_right),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              onTap: () async {
                                final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        ManageAttendanceManagementDetailView(
                                          userId: item.userId,
                                          dateAttendanceId:
                                              widget.dateAttendanceId,
                                        ),
                                  ),
                                );
                                if (result == true) {
                                  _fetchAttendance();
                                  setState(() {});
                                }
                              },
                            ),
                          );
                        },
                      );
                    },
                  )
                : FutureBuilder<StaffAttendanceListResponse>(
                    future: _staffAttendanceFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(
                          child: Text('Failed to load staff attendance.'),
                        );
                      } else if (!snapshot.hasData ||
                          snapshot.data!.data.isEmpty) {
                        return const Center(
                          child: Text('No staff attendance records found.'),
                        );
                      }
                      final staffList = snapshot.data!;
                      // Filter by search
                      final filtered = _search.isEmpty
                          ? staffList.data
                          : staffList.data
                                .where(
                                  (item) => item.staffName
                                      .toLowerCase()
                                      .contains(_search.toLowerCase()),
                                )
                                .toList();
                      if (filtered.isEmpty) {
                        return const Center(
                          child: Text('No staff attendance records found.'),
                        );
                      }
                      return ListView.builder(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 0,
                          vertical: 8,
                        ),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final item = filtered[index];
                          return Container(
                            margin: const EdgeInsets.only(
                              bottom: 12,
                              left: 16,
                              right: 16,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 3,
                                  offset: Offset(0, 1),
                                ),
                              ],
                            ),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundImage: item.staffImg.isNotEmpty
                                    ? NetworkImage(item.staffImg)
                                    : const AssetImage(
                                            'assets/images/default_avatar.png',
                                          )
                                          as ImageProvider,
                                radius: 28,
                              ),
                              title: Text(
                                'Name: ${item.staffName}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Status: ${item.status}'),
                                  Text(
                                    'Checked by: ${item.checkedinBy ?? '-'}',
                                  ),
                                ],
                              ),
                              trailing: const Icon(Icons.chevron_right),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              onTap: () async {
                                final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        ManageAttendanceStaffDetailView(
                                          staffId: item.staffId,
                                          dateAttendanceId:
                                              widget.dateAttendanceId,
                                        ),
                                  ),
                                );
                                if (result == true) {
                                  _fetchStaffAttendance();
                                  setState(() {});
                                }
                              },
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
