import 'package:flutter/material.dart';
import 'package:megacess/core/theme/app_colors.dart';
import 'package:megacess/core/theme/app_typography.dart';
import 'package:megacess/core/widgets/mega_app_header.dart';
import 'package:megacess/modules/checker/data/model/attendance_model.dart';
import 'package:megacess/modules/checker/data/service/attendance_service.dart';
import 'package:megacess/modules/utility/secure_storage_service.dart';
import 'package:megacess/modules/checker/view/manage_attendance_details_view.dart';

class ManageAttendanceView extends StatefulWidget {
  const ManageAttendanceView({super.key});

  @override
  State<ManageAttendanceView> createState() => _ManageAttendanceViewState();
}

class _ManageAttendanceViewState extends State<ManageAttendanceView> {
  late AttendanceService _attendanceService;
  late Future<AttendanceListResponse> _attendanceFuture;
  final TextEditingController _searchController = TextEditingController();
  int _page = 1;
  String _search = '';

  @override
  void initState() {
    super.initState();
    _attendanceService = AttendanceService(SecureStorageService());
    _fetchAttendance();
  }

  void _fetchAttendance() {
    setState(() {
      _attendanceFuture = _attendanceService.fetchAttendanceList(
        page: _page,
        search: _search,
      );
    });
  }

  void _onSearch(String value) {
    _page = 1;
    _search = value.trim();
    _fetchAttendance();
  }

  Future<void> _showAddAttendanceDialog() async {
    DateTime? selectedDate;
    final TextEditingController dateController = TextEditingController();
    bool isLoading = false;

    String getFormattedDate(DateTime? date) {
      if (date == null) return '';
      final months = [
        '',
        'January',
        'February',
        'March',
        'April',
        'May',
        'June',
        'July',
        'August',
        'September',
        'October',
        'November',
        'December',
      ];
      return '${date.day} ${months[date.month]} ${date.year}';
    }

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) {
        return StatefulBuilder(
          builder: (dialogCtx, setDialogState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 400),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'New Muster Attendance',
                          style: AppTypography.headingH4,
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: AppColors.textSecondary),
                          onPressed: () => Navigator.of(dialogCtx).pop(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Select date to initialize muster attendance roster:',
                      style: AppTypography.bodySmall,
                    ),
                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: () async {
                        final now = DateTime.now();
                        final picked = await showDatePicker(
                          context: dialogCtx,
                          initialDate: selectedDate ?? now,
                          firstDate: DateTime(now.year - 2),
                          lastDate: DateTime(now.year + 2),
                          builder: (context, child) {
                            return Theme(
                              data: Theme.of(context).copyWith(
                                colorScheme: const ColorScheme.light(
                                  primary: AppColors.mcForestGreen,
                                  onPrimary: Colors.white,
                                  surface: Colors.white,
                                  onSurface: AppColors.textPrimary,
                                ),
                              ),
                              child: child!,
                            );
                          },
                        );
                        if (picked != null) {
                          setDialogState(() {
                            selectedDate = picked;
                            dateController.text =
                                "${picked.year.toString().padLeft(4, '0')}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
                          });
                        }
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.mcBgApp,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.mcBorder),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.calendar_today_outlined,
                              color: AppColors.mcForestGreen,
                              size: 18,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                selectedDate != null
                                    ? getFormattedDate(selectedDate)
                                    : 'Select attendance date...',
                                style: AppTypography.bodyRegular.copyWith(
                                  color: selectedDate != null
                                      ? AppColors.textPrimary
                                      : AppColors.mcTextDisabled,
                                  fontWeight: selectedDate != null
                                      ? FontWeight.w600
                                      : FontWeight.w400,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    isLoading
                        ? const Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppColors.mcForestGreen,
                              ),
                            ),
                          )
                        : ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.mcForestGreen,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 13),
                            ),
                            onPressed: () async {
                              if (dateController.text.isEmpty) return;
                              setDialogState(() => isLoading = true);
                              try {
                                final resp = await _attendanceService
                                    .createAttendance(
                                      date: dateController.text,
                                    );
                                if (resp['success'] == true) {
                                  if (dialogCtx.mounted) {
                                    Navigator.of(dialogCtx).pop();
                                  }
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          resp['message']?.toString() ??
                                              'Attendance initialized',
                                        ),
                                        backgroundColor:
                                            AppColors.statusCompletedText,
                                      ),
                                    );
                                    _fetchAttendance();
                                  }
                                } else {
                                  setDialogState(() => isLoading = false);
                                  if (dialogCtx.mounted) {
                                    ScaffoldMessenger.of(dialogCtx).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          resp['message']?.toString() ??
                                              'Failed to add attendance.',
                                        ),
                                        backgroundColor:
                                            AppColors.statusRejectedText,
                                      ),
                                    );
                                  }
                                }
                              } catch (e) {
                                setDialogState(() => isLoading = false);
                                if (dialogCtx.mounted) {
                                  ScaffoldMessenger.of(dialogCtx).showSnackBar(
                                    SnackBar(
                                      content: Text('Error: $e'),
                                      backgroundColor:
                                          AppColors.statusRejectedText,
                                    ),
                                  );
                                }
                              }
                            },
                            child: const Text(
                              'Create Attendance',
                              style: TextStyle(fontWeight: FontWeight.w700),
                            ),
                          ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.mcBgApp,
      appBar: const MegaAppHeader(
        title: 'Muster Attendance',
        showBackButton: true,
      ),
      body: Column(
        children: [
          // Search Input Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.mcBorder),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                style: AppTypography.bodyRegular,
                decoration: InputDecoration(
                  hintText: 'Search date (YYYY-MM-DD)...',
                  hintStyle: AppTypography.quietLabel,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: AppColors.mcForestGreen,
                    size: 20,
                  ),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(
                            Icons.clear,
                            size: 18,
                            color: AppColors.textSecondary,
                          ),
                          onPressed: () {
                            _searchController.clear();
                            _onSearch('');
                          },
                        )
                      : null,
                ),
                onChanged: _onSearch,
              ),
            ),
          ),

          // Attendance Record List
          Expanded(
            child: FutureBuilder<AttendanceListResponse>(
              future: _attendanceFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.mcForestGreen,
                      ),
                    ),
                  );
                } else if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            color: AppColors.statusRejectedText,
                            size: 40,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Failed to load attendance records.',
                            style: AppTypography.headingH4,
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.mcForestGreen,
                              foregroundColor: Colors.white,
                            ),
                            onPressed: _fetchAttendance,
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  );
                } else if (!snapshot.hasData || snapshot.data!.data.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: const BoxDecoration(
                            color: AppColors.frond50,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.event_busy,
                            size: 36,
                            color: AppColors.mcForestGreen,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'No Attendance Records',
                          style: AppTypography.headingH4,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Tap + to create a new date muster',
                          style: AppTypography.bodySmall,
                        ),
                      ],
                    ),
                  );
                }

                final attendance = snapshot.data!;
                final filtered = _search.isEmpty
                    ? attendance.data
                    : attendance.data
                        .where(
                          (item) => item.date.toLowerCase().contains(
                            _search.toLowerCase(),
                          ),
                        )
                        .toList();

                if (filtered.isEmpty) {
                  return Center(
                    child: Text(
                      'No matching attendance records found.',
                      style: AppTypography.bodySmall,
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 90),
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final item = filtered[index];
                    return InkWell(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => ManageAttendanceDetailsView(
                              dateAttendanceId: item.id,
                              dateLabel: item.date,
                            ),
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.mcBorder),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.03),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppColors.frond50,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Icons.calendar_today_outlined,
                                color: AppColors.mcForestGreen,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.date,
                                    style: AppTypography.headingH4.copyWith(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    'Muster Roster #${item.id}',
                                    style: AppTypography.metaLabel,
                                  ),
                                ],
                              ),
                            ),
                            const Icon(
                              Icons.arrow_forward_ios,
                              size: 14,
                              color: AppColors.textSecondary,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.mcForestDark,
        foregroundColor: Colors.white,
        elevation: 3,
        onPressed: _showAddAttendanceDialog,
        child: const Icon(Icons.add, size: 28),
      ),
    );
  }
}
