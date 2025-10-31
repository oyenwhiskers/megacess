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
  late Future<UserAttendanceListResponse> _attendanceFuture;
  final TextEditingController _searchController = TextEditingController();
  String _search = '';
  int _selectedTab = 0; // 0: Management, 1: Staff

  // Pagination variables for staff
  final ScrollController _staffScrollController = ScrollController();
  List<StaffAttendanceItem> _staffList = [];
  int _staffCurrentPage = 1;
  int _staffLastPage = 1;
  int _staffTotalFromServer = 0;
  bool _isLoadingMoreStaff = false;
  bool _hasMoreStaffData = true;
  bool _isLoadingStaff = true;
  String? _staffError;

  @override
  void initState() {
    super.initState();
    _fetchAttendance();
    _fetchStaffAttendanceWithPagination();
    
    // Add scroll listener for staff tab
    _staffScrollController.addListener(_onStaffScroll);
  }

  @override
  void dispose() {
    _staffScrollController.removeListener(_onStaffScroll);
    _staffScrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onStaffScroll() {
    final pixels = _staffScrollController.position.pixels;
    final maxScroll = _staffScrollController.position.maxScrollExtent;
    print('Scroll position: $pixels / $maxScroll'); // Debug
    print('Loading more: $_isLoadingMoreStaff, Has more: $_hasMoreStaffData'); // Debug
    
    if (pixels >= maxScroll - 200 &&
        !_isLoadingMoreStaff &&
        _hasMoreStaffData) {
      print('Triggering load more staff...'); // Debug
      _loadMoreStaff();
    }
  }

  Future<void> _fetchStaffAttendanceWithPagination() async {
    setState(() {
      _isLoadingStaff = true;
      _staffError = null;
      _staffCurrentPage = 1;
      _hasMoreStaffData = true;
    });
    
    try {
      final response = await AttendanceService(
        SecureStorageService(),
      ).fetchStaffAttendanceList(
        dateAttendanceId: widget.dateAttendanceId,
        page: 1,
      );
      
      print('Initial fetch - Page: ${response.currentPage}/${response.lastPage}, Total: ${response.total}'); // Debug
      
      setState(() {
        _staffList = response.data;
        _staffCurrentPage = response.currentPage;
        _staffLastPage = response.lastPage;
        _staffTotalFromServer = response.total;
        _hasMoreStaffData = _staffCurrentPage < _staffLastPage;
        _isLoadingStaff = false;
      });
      
      print('Staff loaded: ${_staffList.length}, Has more: $_hasMoreStaffData'); // Debug
    } catch (e) {
      print('Error loading staff attendance: $e'); // Debug print
      setState(() {
        _staffError = 'Failed to load staff attendance: ${e.toString()}';
        _isLoadingStaff = false;
      });
    }
  }

  Future<void> _loadMoreStaff() async {
    if (_isLoadingMoreStaff || !_hasMoreStaffData) {
      print('Load more blocked - Loading: $_isLoadingMoreStaff, Has more: $_hasMoreStaffData'); // Debug
      return;
    }

    print('Loading more staff - Current page: $_staffCurrentPage, Last page: $_staffLastPage'); // Debug

    setState(() {
      _isLoadingMoreStaff = true;
    });

    try {
      final nextPage = _staffCurrentPage + 1;
      print('Fetching page: $nextPage'); // Debug
      
      final response = await AttendanceService(
        SecureStorageService(),
      ).fetchStaffAttendanceList(
        dateAttendanceId: widget.dateAttendanceId,
        page: nextPage,
      );
      
      print('Loaded ${response.data.length} more staff'); // Debug
      
      if (response.data.isNotEmpty) {
        setState(() {
          _staffList.addAll(response.data);
          _staffCurrentPage = response.currentPage;
          _staffLastPage = response.lastPage;
          _staffTotalFromServer = response.total;
          _hasMoreStaffData = _staffCurrentPage < _staffLastPage;
          _isLoadingMoreStaff = false;
        });
        print('Total staff now: ${_staffList.length}'); // Debug
      } else {
        setState(() {
          _hasMoreStaffData = false;
          _isLoadingMoreStaff = false;
        });
        print('No more data to load'); // Debug
      }
    } catch (e) {
      print('Error loading more staff: $e'); // Debug
      setState(() {
        _isLoadingMoreStaff = false;
      });
    }
  }

  void _fetchAttendance() {
    setState(() {
      _attendanceFuture = AttendanceService(
        SecureStorageService(),
      ).fetchUserAttendanceList(dateAttendanceId: widget.dateAttendanceId);
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
                if (_selectedTab == 1 && _staffTotalFromServer > 0) ...[
                  const Spacer(),
                  Text(
                    'Staff: ${_staffList.length}/$_staffTotalFromServer',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
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
                : _isLoadingStaff
                    ? const Center(child: CircularProgressIndicator())
                    : _staffError != null
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.error_outline,
                                color: Colors.red,
                                size: 48,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                _staffError!,
                                textAlign: TextAlign.center,
                                style: const TextStyle(color: Colors.red),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: _fetchStaffAttendanceWithPagination,
                                child: const Text('Retry'),
                              ),
                            ],
                          ),
                        ),
                      )
                    : _staffList.isEmpty
                    ? const Center(
                        child: Text('No staff attendance records found.'),
                      )
                    : Column(
                        children: [
                          Expanded(
                            child: ListView.builder(
                              controller: _staffScrollController,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 0,
                                vertical: 8,
                              ),
                              itemCount: _staffList.length,
                              itemBuilder: (context, index) {
                                final item = _staffList[index];
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
                                        _fetchStaffAttendanceWithPagination();
                                        setState(() {});
                                      }
                                    },
                                  ),
                                );
                              },
                            ),
                          ),
                          // Load More Button
                          if (_hasMoreStaffData || _isLoadingMoreStaff)
                            Container(
                              padding: const EdgeInsets.all(16),
                              child: _isLoadingMoreStaff
                                  ? const Center(
                                      child: CircularProgressIndicator(),
                                    )
                                  : ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFF43C463),
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 32,
                                          vertical: 12,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                      ),
                                      onPressed: _loadMoreStaff,
                                      child: Text(
                                        'Load More (${_staffList.length}/$_staffTotalFromServer)',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                            ),
                        ],
                      ),
          ),
        ],
      ),
    );
  }
}
