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
    super.key,
    required this.dateAttendanceId,
    required this.dateLabel,
  });

  @override
  State<ManageAttendanceDetailsView> createState() =>
      _ManageAttendanceDetailsViewState();
}

class _ManageAttendanceDetailsViewState
    extends State<ManageAttendanceDetailsView> {
  final TextEditingController _searchController = TextEditingController();
  final String _search = '';
  int _selectedTab = 0; // 0: Management, 1: Staff

  // Pagination variables for management
  final ScrollController _managementScrollController = ScrollController();
  List<UserAttendanceItem> _managementList = [];
  int _managementCurrentPage = 1;
  int _managementLastPage = 1;
  int _managementTotalFromServer = 0;
  bool _isLoadingManagement = true;
  String? _managementError;
  final int _managementPerPage = 15;

  // Pagination variables for staff
  final ScrollController _staffScrollController = ScrollController();
  List<StaffAttendanceItem> _staffList = [];
  int _staffCurrentPage = 1;
  int _staffLastPage = 1;
  int _staffTotalFromServer = 0;
  bool _isLoadingStaff = true;
  String? _staffError;
  final int _staffPerPage = 15;

  @override
  void initState() {
    super.initState();
    _fetchManagementAttendanceWithPagination();
    _fetchStaffAttendanceWithPagination();
  }

  @override
  void dispose() {
    _managementScrollController.dispose();
    _staffScrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchStaffAttendanceWithPagination({int page = 1}) async {
    setState(() {
      _isLoadingStaff = true;
      _staffError = null;
      if (page == 1) {
        _staffCurrentPage = 1;
      }
    });

    try {
      print(
        'Fetching staff attendance - Page: $page, Per Page: $_staffPerPage',
      );

      // Use only Staff Attendance endpoint for real attendance data
      final response = await AttendanceService(SecureStorageService())
          .fetchStaffAttendanceList(
            dateAttendanceId: widget.dateAttendanceId,
            page: page,
            perPage: _staffPerPage,
          );

      print(
        'Loaded page ${response.currentPage}/${response.lastPage} - ${response.data.length} staff with real attendance',
      );

      print('Response pagination details:');
      print('  currentPage: ${response.currentPage}');
      print('  lastPage: ${response.lastPage}');
      print('  total: ${response.total}');
      print('  perPage: ${response.perPage}');
      print('  from: ${response.from}');
      print('  to: ${response.to}');

      // Debug: Print first few staff status
      if (response.data.isNotEmpty) {
        print('Real attendance data:');
        for (var i = 0; i < response.data.length.clamp(0, 3); i++) {
          final staff = response.data[i];
          print('  ${staff.staffName}: ${staff.status} (ID: ${staff.staffId})');
        }
      }

      setState(() {
        _staffList = response.data;
        _staffCurrentPage = response.currentPage;
        _staffLastPage = response.lastPage;
        _staffTotalFromServer = response.total;
        _isLoadingStaff = false;
      });

      print('UI state updated:');
      print('  _staffCurrentPage: $_staffCurrentPage');
      print('  _staffLastPage: $_staffLastPage');
      print('  _staffTotalFromServer: $_staffTotalFromServer');
      print('  _staffList.length: ${_staffList.length}');
    } catch (e) {
      print('Error loading staff: $e');
      setState(() {
        _staffError = 'Failed to load staff attendance: ${e.toString()}';
        _isLoadingStaff = false;
      });
    }
  }

  Future<void> _loadStaffPage(int page) async {
    setState(() {
      _isLoadingStaff = true;
      _staffError = null;
      // Clear current list when loading a specific page
      _staffList.clear();
    });

    try {
      // Use only Staff Attendance endpoint for real attendance data
      final response = await AttendanceService(SecureStorageService())
          .fetchStaffAttendanceList(
            dateAttendanceId: widget.dateAttendanceId,
            page: page,
            perPage: _staffPerPage,
          );

      setState(() {
        _staffList = response.data;
        _staffCurrentPage = response.currentPage;
        _staffLastPage = response.lastPage;
        _staffTotalFromServer = response.total;
        _isLoadingStaff = false;
      });
    } catch (e) {
      setState(() {
        _staffError = 'Failed to load staff attendance: ${e.toString()}';
        _isLoadingStaff = false;
      });
    }
  }

  void _goToNextPage() {
    if (_staffCurrentPage < _staffLastPage) {
      _loadStaffPage(_staffCurrentPage + 1);
    }
  }

  void _goToPreviousPage() {
    if (_staffCurrentPage > 1) {
      _loadStaffPage(_staffCurrentPage - 1);
    }
  }

  void _goToFirstPage() {
    if (_staffCurrentPage > 1) {
      _loadStaffPage(1);
    }
  }

  void _goToLastPage() {
    if (_staffCurrentPage < _staffLastPage) {
      _loadStaffPage(_staffLastPage);
    }
  }

  Future<void> _fetchManagementAttendanceWithPagination({int page = 1}) async {
    setState(() {
      _isLoadingManagement = true;
      _managementError = null;
      if (page == 1) {
        _managementCurrentPage = 1;
      }
    });

    try {
      print(
        'Fetching management attendance - Page: $page, Per Page: $_managementPerPage',
      );

      final response = await AttendanceService(SecureStorageService())
          .fetchUserAttendanceList(
            dateAttendanceId: widget.dateAttendanceId,
            page: page,
            perPage: _managementPerPage,
          );

      print(
        'Loaded page ${response.currentPage}/${response.lastPage} - ${response.data.length} management with real attendance',
      );

      print('Management response pagination details:');
      print('  currentPage: ${response.currentPage}');
      print('  lastPage: ${response.lastPage}');
      print('  total: ${response.total}');
      print('  perPage: ${response.perPage}');
      print('  from: ${response.from}');
      print('  to: ${response.to}');

      // Debug: Print first few management status
      if (response.data.isNotEmpty) {
        print('Real management attendance data:');
        for (var i = 0; i < response.data.length.clamp(0, 3); i++) {
          final user = response.data[i];
          print('  ${user.userName}: ${user.status} (ID: ${user.userId})');
        }
      }

      setState(() {
        _managementList = response.data;
        _managementCurrentPage = response.currentPage;
        _managementLastPage = response.lastPage;
        _managementTotalFromServer = response.total;
        _isLoadingManagement = false;
      });

      print('Management UI state updated:');
      print('  _managementCurrentPage: $_managementCurrentPage');
      print('  _managementLastPage: $_managementLastPage');
      print('  _managementTotalFromServer: $_managementTotalFromServer');
      print('  _managementList.length: ${_managementList.length}');
    } catch (e) {
      print('Error loading management: $e');
      setState(() {
        _managementError =
            'Failed to load management attendance: ${e.toString()}';
        _isLoadingManagement = false;
      });
    }
  }

  Future<void> _loadManagementPage(int page) async {
    setState(() {
      _isLoadingManagement = true;
      _managementError = null;
      // Clear current list when loading a specific page
      _managementList.clear();
    });

    try {
      final response = await AttendanceService(SecureStorageService())
          .fetchUserAttendanceList(
            dateAttendanceId: widget.dateAttendanceId,
            page: page,
            perPage: _managementPerPage,
          );

      setState(() {
        _managementList = response.data;
        _managementCurrentPage = response.currentPage;
        _managementLastPage = response.lastPage;
        _managementTotalFromServer = response.total;
        _isLoadingManagement = false;
      });
    } catch (e) {
      setState(() {
        _managementError =
            'Failed to load management attendance: ${e.toString()}';
        _isLoadingManagement = false;
      });
    }
  }

  void _goToNextManagementPage() {
    if (_managementCurrentPage < _managementLastPage) {
      _loadManagementPage(_managementCurrentPage + 1);
    }
  }

  void _goToPreviousManagementPage() {
    if (_managementCurrentPage > 1) {
      _loadManagementPage(_managementCurrentPage - 1);
    }
  }

  void _goToFirstManagementPage() {
    if (_managementCurrentPage > 1) {
      _loadManagementPage(1);
    }
  }

  void _goToLastManagementPage() {
    if (_managementCurrentPage < _managementLastPage) {
      _loadManagementPage(_managementLastPage);
    }
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
                if (_selectedTab == 0 && _managementTotalFromServer > 0) ...[
                  const Spacer(),
                  Text(
                    'Total Management: $_managementTotalFromServer',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
                if (_selectedTab == 1 && _staffTotalFromServer > 0) ...[
                  const Spacer(),
                  Text(
                    'Total Staff: $_staffTotalFromServer',
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
                ? _isLoadingManagement
                      ? const Center(child: CircularProgressIndicator())
                      : _managementError != null
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
                                  _managementError!,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(color: Colors.red),
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed:
                                      _fetchManagementAttendanceWithPagination,
                                  child: const Text('Retry'),
                                ),
                              ],
                            ),
                          ),
                        )
                      : _managementList.isEmpty
                      ? const Center(
                          child: Text(
                            'No management attendance records found.',
                          ),
                        )
                      : Column(
                          children: [
                            // Page info header
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              child: Row(
                                children: [
                                  Text(
                                    'Page $_managementCurrentPage of $_managementLastPage',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    'Showing ${((_managementCurrentPage - 1) * _managementPerPage) + 1}-${(_managementCurrentPage * _managementPerPage > _managementTotalFromServer) ? _managementTotalFromServer : (_managementCurrentPage * _managementPerPage)} of $_managementTotalFromServer',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Divider(height: 1),
                            // Management list
                            Expanded(
                              child: ListView.builder(
                                controller: _managementScrollController,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 0,
                                  vertical: 8,
                                ),
                                itemCount: _managementList.length,
                                itemBuilder: (context, index) {
                                  final item = _managementList[index];
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
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text('Status: ${item.status}'),
                                          Text(
                                            'Checked by: ${item.checkedinBy ?? '-'}',
                                          ),
                                        ],
                                      ),
                                      trailing: const Icon(Icons.chevron_right),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
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
                                          _fetchManagementAttendanceWithPagination(
                                            page: _managementCurrentPage,
                                          );
                                          setState(() {});
                                        }
                                      },
                                    ),
                                  );
                                },
                              ),
                            ),
                            // Pagination controls
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                border: Border(
                                  top: BorderSide(
                                    color: Colors.grey,
                                    width: 0.5,
                                  ),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  // First and Previous buttons
                                  Row(
                                    children: [
                                      // First page button
                                      IconButton(
                                        onPressed: _managementCurrentPage > 1
                                            ? _goToFirstManagementPage
                                            : null,
                                        icon: const Icon(Icons.first_page),
                                        style: IconButton.styleFrom(
                                          backgroundColor:
                                              _managementCurrentPage > 1
                                              ? const Color(0xFF43C463)
                                              : Colors.grey[300],
                                          foregroundColor:
                                              _managementCurrentPage > 1
                                              ? Colors.white
                                              : Colors.grey,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      // Previous page button
                                      IconButton(
                                        onPressed: _managementCurrentPage > 1
                                            ? _goToPreviousManagementPage
                                            : null,
                                        icon: const Icon(Icons.chevron_left),
                                        style: IconButton.styleFrom(
                                          backgroundColor:
                                              _managementCurrentPage > 1
                                              ? const Color(0xFF43C463)
                                              : Colors.grey[300],
                                          foregroundColor:
                                              _managementCurrentPage > 1
                                              ? Colors.white
                                              : Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                  // Page indicator
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(
                                        0xFF43C463,
                                      ).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      '$_managementCurrentPage / $_managementLastPage',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF43C463),
                                      ),
                                    ),
                                  ),
                                  // Next and Last buttons
                                  Row(
                                    children: [
                                      // Next page button
                                      IconButton(
                                        onPressed:
                                            _managementCurrentPage <
                                                _managementLastPage
                                            ? _goToNextManagementPage
                                            : null,
                                        icon: const Icon(Icons.chevron_right),
                                        style: IconButton.styleFrom(
                                          backgroundColor:
                                              _managementCurrentPage <
                                                  _managementLastPage
                                              ? const Color(0xFF43C463)
                                              : Colors.grey[300],
                                          foregroundColor:
                                              _managementCurrentPage <
                                                  _managementLastPage
                                              ? Colors.white
                                              : Colors.grey,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      // Last page button
                                      IconButton(
                                        onPressed:
                                            _managementCurrentPage <
                                                _managementLastPage
                                            ? _goToLastManagementPage
                                            : null,
                                        icon: const Icon(Icons.last_page),
                                        style: IconButton.styleFrom(
                                          backgroundColor:
                                              _managementCurrentPage <
                                                  _managementLastPage
                                              ? const Color(0xFF43C463)
                                              : Colors.grey[300],
                                          foregroundColor:
                                              _managementCurrentPage <
                                                  _managementLastPage
                                              ? Colors.white
                                              : Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
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
                      // Page info header
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: Row(
                          children: [
                            Text(
                              'Page $_staffCurrentPage of $_staffLastPage',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              'Showing ${((_staffCurrentPage - 1) * _staffPerPage) + 1}-${(_staffCurrentPage * _staffPerPage > _staffTotalFromServer) ? _staffTotalFromServer : (_staffCurrentPage * _staffPerPage)} of $_staffTotalFromServer',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Divider(height: 1),
                      // Staff list
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
                                    _fetchStaffAttendanceWithPagination(
                                      page: _staffCurrentPage,
                                    );
                                    setState(() {});
                                  }
                                },
                              ),
                            );
                          },
                        ),
                      ),
                      // Pagination controls
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          border: Border(
                            top: BorderSide(color: Colors.grey, width: 0.5),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // First and Previous buttons
                            Row(
                              children: [
                                // First page button
                                IconButton(
                                  onPressed: _staffCurrentPage > 1
                                      ? _goToFirstPage
                                      : null,
                                  icon: const Icon(Icons.first_page),
                                  style: IconButton.styleFrom(
                                    backgroundColor: _staffCurrentPage > 1
                                        ? const Color(0xFF43C463)
                                        : Colors.grey[300],
                                    foregroundColor: _staffCurrentPage > 1
                                        ? Colors.white
                                        : Colors.grey,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                // Previous page button
                                IconButton(
                                  onPressed: _staffCurrentPage > 1
                                      ? _goToPreviousPage
                                      : null,
                                  icon: const Icon(Icons.chevron_left),
                                  style: IconButton.styleFrom(
                                    backgroundColor: _staffCurrentPage > 1
                                        ? const Color(0xFF43C463)
                                        : Colors.grey[300],
                                    foregroundColor: _staffCurrentPage > 1
                                        ? Colors.white
                                        : Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                            // Page indicator
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF43C463).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                '$_staffCurrentPage / $_staffLastPage',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF43C463),
                                ),
                              ),
                            ),
                            // Next and Last buttons
                            Row(
                              children: [
                                // Next page button
                                IconButton(
                                  onPressed: _staffCurrentPage < _staffLastPage
                                      ? _goToNextPage
                                      : null,
                                  icon: const Icon(Icons.chevron_right),
                                  style: IconButton.styleFrom(
                                    backgroundColor:
                                        _staffCurrentPage < _staffLastPage
                                        ? const Color(0xFF43C463)
                                        : Colors.grey[300],
                                    foregroundColor:
                                        _staffCurrentPage < _staffLastPage
                                        ? Colors.white
                                        : Colors.grey,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                // Last page button
                                IconButton(
                                  onPressed: _staffCurrentPage < _staffLastPage
                                      ? _goToLastPage
                                      : null,
                                  icon: const Icon(Icons.last_page),
                                  style: IconButton.styleFrom(
                                    backgroundColor:
                                        _staffCurrentPage < _staffLastPage
                                        ? const Color(0xFF43C463)
                                        : Colors.grey[300],
                                    foregroundColor:
                                        _staffCurrentPage < _staffLastPage
                                        ? Colors.white
                                        : Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ],
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
