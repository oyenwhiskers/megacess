import 'package:flutter/material.dart';
import 'package:megacess/core/theme/app_colors.dart';
import 'package:megacess/core/theme/app_typography.dart';
import 'package:megacess/core/widgets/mega_app_header.dart';
import 'package:megacess/modules/checker/data/model/staff_attendance_model.dart';
import 'package:megacess/modules/checker/data/model/user_attendance_model.dart';
import 'package:megacess/modules/checker/data/service/attendance_service.dart';
import 'package:megacess/modules/checker/view/manage_attendance_management_detail_view.dart';
import 'package:megacess/modules/checker/view/manage_attendance_staff_detail_view.dart';
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
  int _selectedTab = 0; // 0: Management, 1: Staff

  // Pagination & state for Management
  final ScrollController _managementScrollController = ScrollController();
  List<UserAttendanceItem> _managementList = [];
  int _managementCurrentPage = 1;
  int _managementLastPage = 1;
  int _managementTotalFromServer = 0;
  bool _isLoadingManagement = true;
  String? _managementError;
  final int _managementPerPage = 15;

  // Pagination & state for Staff
  final ScrollController _staffScrollController = ScrollController();
  List<StaffAttendanceItem> _staffList = [];
  int _staffCurrentPage = 1;
  int _staffLastPage = 1;
  int _staffTotalFromServer = 0;
  bool _isLoadingStaff = true;
  String? _staffError;
  final int _staffPerPage = 15;

  late final AttendanceService _attendanceService;

  @override
  void initState() {
    super.initState();
    _attendanceService = AttendanceService(SecureStorageService());
    _fetchManagementAttendanceWithPagination();
    _fetchStaffAttendanceWithPagination();
  }

  @override
  void dispose() {
    _managementScrollController.dispose();
    _staffScrollController.dispose();
    super.dispose();
  }

  // ==========================================
  // MANAGEMENT PAGINATION
  // ==========================================

  Future<void> _fetchManagementAttendanceWithPagination({int page = 1}) async {
    setState(() {
      _isLoadingManagement = true;
      _managementError = null;
      if (page == 1) {
        _managementCurrentPage = 1;
      }
    });

    try {
      final response = await _attendanceService.fetchUserAttendanceList(
        dateAttendanceId: widget.dateAttendanceId,
        page: page,
        perPage: _managementPerPage,
      );

      if (mounted) {
        setState(() {
          _managementList = response.data;
          _managementCurrentPage = response.currentPage;
          _managementLastPage = response.lastPage;
          _managementTotalFromServer = response.total;
          _isLoadingManagement = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _managementError = 'Failed to load management attendance: $e';
          _isLoadingManagement = false;
        });
      }
    }
  }

  Future<void> _loadManagementPage(int page) async {
    setState(() {
      _isLoadingManagement = true;
      _managementError = null;
      _managementList.clear();
    });

    try {
      final response = await _attendanceService.fetchUserAttendanceList(
        dateAttendanceId: widget.dateAttendanceId,
        page: page,
        perPage: _managementPerPage,
      );

      if (mounted) {
        setState(() {
          _managementList = response.data;
          _managementCurrentPage = response.currentPage;
          _managementLastPage = response.lastPage;
          _managementTotalFromServer = response.total;
          _isLoadingManagement = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _managementError = 'Failed to load management attendance: $e';
          _isLoadingManagement = false;
        });
      }
    }
  }

  void _goToFirstManagementPage() {
    if (_managementCurrentPage > 1) _loadManagementPage(1);
  }

  void _goToPreviousManagementPage() {
    if (_managementCurrentPage > 1) {
      _loadManagementPage(_managementCurrentPage - 1);
    }
  }

  void _goToNextManagementPage() {
    if (_managementCurrentPage < _managementLastPage) {
      _loadManagementPage(_managementCurrentPage + 1);
    }
  }

  void _goToLastManagementPage() {
    if (_managementCurrentPage < _managementLastPage) {
      _loadManagementPage(_managementLastPage);
    }
  }

  // ==========================================
  // STAFF PAGINATION
  // ==========================================

  Future<void> _fetchStaffAttendanceWithPagination({int page = 1}) async {
    setState(() {
      _isLoadingStaff = true;
      _staffError = null;
      if (page == 1) {
        _staffCurrentPage = 1;
      }
    });

    try {
      final response = await _attendanceService.fetchStaffAttendanceList(
        dateAttendanceId: widget.dateAttendanceId,
        page: page,
        perPage: _staffPerPage,
      );

      if (mounted) {
        setState(() {
          _staffList = response.data;
          _staffCurrentPage = response.currentPage;
          _staffLastPage = response.lastPage;
          _staffTotalFromServer = response.total;
          _isLoadingStaff = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _staffError = 'Failed to load staff attendance: $e';
          _isLoadingStaff = false;
        });
      }
    }
  }

  Future<void> _loadStaffPage(int page) async {
    setState(() {
      _isLoadingStaff = true;
      _staffError = null;
      _staffList.clear();
    });

    try {
      final response = await _attendanceService.fetchStaffAttendanceList(
        dateAttendanceId: widget.dateAttendanceId,
        page: page,
        perPage: _staffPerPage,
      );

      if (mounted) {
        setState(() {
          _staffList = response.data;
          _staffCurrentPage = response.currentPage;
          _staffLastPage = response.lastPage;
          _staffTotalFromServer = response.total;
          _isLoadingStaff = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _staffError = 'Failed to load staff attendance: $e';
          _isLoadingStaff = false;
        });
      }
    }
  }

  void _goToFirstPage() {
    if (_staffCurrentPage > 1) _loadStaffPage(1);
  }

  void _goToPreviousPage() {
    if (_staffCurrentPage > 1) _loadStaffPage(_staffCurrentPage - 1);
  }

  void _goToNextPage() {
    if (_staffCurrentPage < _staffLastPage) {
      _loadStaffPage(_staffCurrentPage + 1);
    }
  }

  void _goToLastPage() {
    if (_staffCurrentPage < _staffLastPage) {
      _loadStaffPage(_staffLastPage);
    }
  }

  // ==========================================
  // BADGES & HELPERS
  // ==========================================

  Widget _buildAttendanceBadge(String status) {
    Color bg;
    Color fg;
    IconData icon;
    String label = status;

    final lower = status.toLowerCase();
    if (lower == 'present' || lower == 'checked_in' || lower == 'checked in') {
      bg = AppColors.statusCompletedBg;
      fg = AppColors.statusCompletedText;
      icon = Icons.check_circle_outline;
      label = 'Present';
    } else if (lower == 'absent') {
      bg = AppColors.statusRejectedBg;
      fg = AppColors.statusRejectedText;
      icon = Icons.cancel_outlined;
      label = 'Absent';
    } else if (lower.contains('leave')) {
      bg = AppColors.statusPendingBg;
      fg = AppColors.statusPendingText;
      icon = Icons.beach_access_outlined;
      label = 'On Leave';
    } else if (lower == 'late') {
      bg = const Color(0xFFFEF3C7);
      fg = const Color(0xFFB45309);
      icon = Icons.access_time_outlined;
      label = 'Late';
    } else {
      bg = Colors.grey.shade100;
      fg = AppColors.textSecondary;
      icon = Icons.help_outline;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: fg.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: fg),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // BUILD
  // ==========================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.mcBgApp,
      appBar: MegaAppHeader(
        title: 'Attendance Roster',
        subtitle: widget.dateLabel,
        showBackButton: true,
      ),
      body: Column(
        children: [
          // Segmented Tab Selector
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            color: Colors.white,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppColors.mcBgApp,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.mcBorder),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _TabButton(
                      label: 'Management',
                      count: _managementTotalFromServer,
                      isSelected: _selectedTab == 0,
                      onTap: () => setState(() => _selectedTab = 0),
                    ),
                  ),
                  Expanded(
                    child: _TabButton(
                      label: 'Staff',
                      count: _staffTotalFromServer,
                      isSelected: _selectedTab == 1,
                      onTap: () => setState(() => _selectedTab = 1),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Tab Content
          Expanded(
            child: _selectedTab == 0
                ? _buildManagementSection()
                : _buildStaffSection(),
          ),
        ],
      ),
    );
  }

  Widget _buildManagementSection() {
    if (_isLoadingManagement) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.mcForestGreen),
        ),
      );
    }

    if (_managementError != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                color: AppColors.statusRejectedText,
                size: 48,
              ),
              const SizedBox(height: 12),
              Text(
                _managementError!,
                textAlign: TextAlign.center,
                style: AppTypography.bodyRegular.copyWith(
                  color: AppColors.statusRejectedText,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.mcForestGreen,
                  foregroundColor: Colors.white,
                ),
                onPressed: _fetchManagementAttendanceWithPagination,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_managementList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.people_outline,
              size: 48,
              color: AppColors.textDisabled,
            ),
            const SizedBox(height: 12),
            Text(
              'No management attendance records found.',
              style: AppTypography.bodyRegular.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Sub-bar with count info
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Showing ${((_managementCurrentPage - 1) * _managementPerPage) + 1}–${(_managementCurrentPage * _managementPerPage > _managementTotalFromServer) ? _managementTotalFromServer : (_managementCurrentPage * _managementPerPage)} of $_managementTotalFromServer',
                style: AppTypography.caption,
              ),
              Text(
                'Page $_managementCurrentPage of $_managementLastPage',
                style: AppTypography.caption.copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),

        // List
        Expanded(
          child: ListView.builder(
            controller: _managementScrollController,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            itemCount: _managementList.length,
            itemBuilder: (context, index) {
              final item = _managementList[index];
              return _AttendanceCard(
                imageUrl: item.userImg,
                name: item.userName,
                statusWidget: _buildAttendanceBadge(item.status),
                checkedBy: item.checkedinBy,
                checkInTime: item.checkIn,
                checkOutTime: item.checkOut,
                onTap: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          ManageAttendanceManagementDetailView(
                            userId: item.userId,
                            dateAttendanceId: widget.dateAttendanceId,
                          ),
                    ),
                  );
                  if (result == true) {
                    _fetchManagementAttendanceWithPagination(
                      page: _managementCurrentPage,
                    );
                  }
                },
              );
            },
          ),
        ),

        // Pagination Footer
        _PaginationFooter(
          currentPage: _managementCurrentPage,
          lastPage: _managementLastPage,
          onFirst: _managementCurrentPage > 1 ? _goToFirstManagementPage : null,
          onPrev: _managementCurrentPage > 1 ? _goToPreviousManagementPage : null,
          onNext: _managementCurrentPage < _managementLastPage
              ? _goToNextManagementPage
              : null,
          onLast: _managementCurrentPage < _managementLastPage
              ? _goToLastManagementPage
              : null,
        ),
      ],
    );
  }

  Widget _buildStaffSection() {
    if (_isLoadingStaff) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.mcForestGreen),
        ),
      );
    }

    if (_staffError != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                color: AppColors.statusRejectedText,
                size: 48,
              ),
              const SizedBox(height: 12),
              Text(
                _staffError!,
                textAlign: TextAlign.center,
                style: AppTypography.bodyRegular.copyWith(
                  color: AppColors.statusRejectedText,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.mcForestGreen,
                  foregroundColor: Colors.white,
                ),
                onPressed: _fetchStaffAttendanceWithPagination,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_staffList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.people_outline,
              size: 48,
              color: AppColors.textDisabled,
            ),
            const SizedBox(height: 12),
            Text(
              'No staff attendance records found.',
              style: AppTypography.bodyRegular.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Sub-bar with count info
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Showing ${((_staffCurrentPage - 1) * _staffPerPage) + 1}–${(_staffCurrentPage * _staffPerPage > _staffTotalFromServer) ? _staffTotalFromServer : (_staffCurrentPage * _staffPerPage)} of $_staffTotalFromServer',
                style: AppTypography.caption,
              ),
              Text(
                'Page $_staffCurrentPage of $_staffLastPage',
                style: AppTypography.caption.copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),

        // List
        Expanded(
          child: ListView.builder(
            controller: _staffScrollController,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            itemCount: _staffList.length,
            itemBuilder: (context, index) {
              final item = _staffList[index];
              return _AttendanceCard(
                imageUrl: item.staffImg,
                name: item.staffName,
                statusWidget: _buildAttendanceBadge(item.status),
                checkedBy: item.checkedinBy,
                checkInTime: item.checkIn,
                checkOutTime: item.checkOut,
                onTap: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          ManageAttendanceStaffDetailView(
                            staffId: item.staffId,
                            dateAttendanceId: widget.dateAttendanceId,
                          ),
                    ),
                  );
                  if (result == true) {
                    _fetchStaffAttendanceWithPagination(
                      page: _staffCurrentPage,
                    );
                  }
                },
              );
            },
          ),
        ),

        // Pagination Footer
        _PaginationFooter(
          currentPage: _staffCurrentPage,
          lastPage: _staffLastPage,
          onFirst: _staffCurrentPage > 1 ? _goToFirstPage : null,
          onPrev: _staffCurrentPage > 1 ? _goToPreviousPage : null,
          onNext: _staffCurrentPage < _staffLastPage ? _goToNextPage : null,
          onLast: _staffCurrentPage < _staffLastPage ? _goToLastPage : null,
        ),
      ],
    );
  }
}

// ==========================================
// SUB-WIDGETS
// ==========================================

class _TabButton extends StatelessWidget {
  final String label;
  final int count;
  final bool isSelected;
  final VoidCallback onTap;

  const _TabButton({
    required this.label,
    required this.count,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: isSelected
                      ? AppColors.mcForestDark
                      : AppColors.textSecondary,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  fontSize: 14,
                ),
              ),
              if (count > 0) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.frond50 : Colors.black12,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '$count',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: isSelected
                          ? AppColors.mcForestGreen
                          : AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _AttendanceCard extends StatelessWidget {
  final String imageUrl;
  final String name;
  final Widget statusWidget;
  final String? checkedBy;
  final String? checkInTime;
  final String? checkOutTime;
  final VoidCallback onTap;

  const _AttendanceCard({
    required this.imageUrl,
    required this.name,
    required this.statusWidget,
    this.checkedBy,
    this.checkInTime,
    this.checkOutTime,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.mcBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                // Avatar
                CircleAvatar(
                  radius: 24,
                  backgroundColor: AppColors.frond50,
                  backgroundImage: imageUrl.isNotEmpty
                      ? NetworkImage(imageUrl)
                      : null,
                  child: imageUrl.isEmpty
                      ? const Icon(
                          Icons.person_outline,
                          color: AppColors.mcForestGreen,
                          size: 24,
                        )
                      : null,
                ),
                const SizedBox(width: 14),

                // Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              name,
                              style: AppTypography.headingH4.copyWith(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          statusWidget,
                        ],
                      ),
                      const SizedBox(height: 6),
                      if (checkedBy != null && checkedBy!.isNotEmpty)
                        Text(
                          'Checked by: $checkedBy',
                          style: AppTypography.caption,
                        ),
                      if (checkInTime != null || checkOutTime != null) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            if (checkInTime != null)
                              Text(
                                'In: $checkInTime',
                                style: AppTypography.caption.copyWith(
                                  fontSize: 11,
                                  color: AppColors.statusCompletedText,
                                ),
                              ),
                            if (checkInTime != null && checkOutTime != null)
                              const SizedBox(width: 8),
                            if (checkOutTime != null)
                              Text(
                                'Out: $checkOutTime',
                                style: AppTypography.caption.copyWith(
                                  fontSize: 11,
                                  color: AppColors.statusRejectedText,
                                ),
                              ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.chevron_right,
                  color: AppColors.textDisabled,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PaginationFooter extends StatelessWidget {
  final int currentPage;
  final int lastPage;
  final VoidCallback? onFirst;
  final VoidCallback? onPrev;
  final VoidCallback? onNext;
  final VoidCallback? onLast;

  const _PaginationFooter({
    required this.currentPage,
    required this.lastPage,
    this.onFirst,
    this.onPrev,
    this.onNext,
    this.onLast,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.mcBorder)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Left navigation
            Row(
              children: [
                IconButton(
                  onPressed: onFirst,
                  icon: const Icon(Icons.first_page, size: 20),
                  tooltip: 'First Page',
                  style: IconButton.styleFrom(
                    backgroundColor: onFirst != null
                        ? AppColors.frond50
                        : Colors.grey.shade100,
                    foregroundColor: onFirst != null
                        ? AppColors.mcForestGreen
                        : AppColors.textDisabled,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: onPrev,
                  icon: const Icon(Icons.chevron_left, size: 20),
                  tooltip: 'Previous Page',
                  style: IconButton.styleFrom(
                    backgroundColor: onPrev != null
                        ? AppColors.frond50
                        : Colors.grey.shade100,
                    foregroundColor: onPrev != null
                        ? AppColors.mcForestGreen
                        : AppColors.textDisabled,
                  ),
                ),
              ],
            ),

            // Page indicator pill
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.frond50,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.frond200),
              ),
              child: Text(
                '$currentPage / $lastPage',
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  color: AppColors.mcForestGreen,
                ),
              ),
            ),

            // Right navigation
            Row(
              children: [
                IconButton(
                  onPressed: onNext,
                  icon: const Icon(Icons.chevron_right, size: 20),
                  tooltip: 'Next Page',
                  style: IconButton.styleFrom(
                    backgroundColor: onNext != null
                        ? AppColors.frond50
                        : Colors.grey.shade100,
                    foregroundColor: onNext != null
                        ? AppColors.mcForestGreen
                        : AppColors.textDisabled,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: onLast,
                  icon: const Icon(Icons.last_page, size: 20),
                  tooltip: 'Last Page',
                  style: IconButton.styleFrom(
                    backgroundColor: onLast != null
                        ? AppColors.frond50
                        : Colors.grey.shade100,
                    foregroundColor: onLast != null
                        ? AppColors.mcForestGreen
                        : AppColors.textDisabled,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
