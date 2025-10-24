import 'package:flutter/material.dart';
import 'package:megacess/modules/checker/data/model/attendance_model.dart';
import 'package:megacess/modules/checker/data/service/attendance_service.dart';
import 'package:megacess/modules/utility/secure_storage_service.dart';
import 'package:megacess/modules/checker/view/manage_attendance_details_view.dart';

class ManageAttendanceView extends StatefulWidget {
  const ManageAttendanceView({Key? key}) : super(key: key);

  @override
  State<ManageAttendanceView> createState() => _ManageAttendanceViewState();
}

class _ManageAttendanceViewState extends State<ManageAttendanceView> {
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
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 18,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Select Date:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () async {
                        final now = DateTime.now();
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: selectedDate ?? now,
                          firstDate: DateTime(now.year - 2),
                          lastDate: DateTime(now.year + 2),
                        );
                        if (picked != null) {
                          setState(() {
                            selectedDate = picked;
                            dateController.text =
                                "${picked.year.toString().padLeft(4, '0')}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
                          });
                        }
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.calendar_today,
                              color: Color(0xFF43C463),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                selectedDate != null
                                    ? getFormattedDate(selectedDate)
                                    : 'date...',
                                style: const TextStyle(fontSize: 15),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : Container(
                            margin: const EdgeInsets.only(top: 8),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF43C463),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                              ),
                              onPressed: () async {
                                if (dateController.text.isEmpty) return;
                                setState(() => isLoading = true);
                                try {
                                  final resp = await _attendanceService
                                      .createAttendance(
                                        date: dateController.text,
                                      );
                                  if (resp['success'] == true &&
                                      resp['message'] != null) {
                                    Navigator.of(context).pop();
                                    // Show custom snackbar for 1 second
                                    final overlay = Overlay.of(context);
                                    final overlayEntry = OverlayEntry(
                                      builder: (ctx) => Positioned(
                                        top:
                                            MediaQuery.of(ctx).size.height *
                                            0.45,
                                        left:
                                            MediaQuery.of(ctx).size.width *
                                            0.15,
                                        right:
                                            MediaQuery.of(ctx).size.width *
                                            0.15,
                                        child: Material(
                                          color: Colors.transparent,
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 24,
                                              vertical: 16,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(24),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black12,
                                                  blurRadius: 8,
                                                ),
                                              ],
                                            ),
                                            child: Center(
                                              child: Text(
                                                resp['message'].toString(),
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                    overlay.insert(overlayEntry);
                                    await Future.delayed(
                                      const Duration(seconds: 1),
                                    );
                                    overlayEntry.remove();
                                    _fetchAttendance();
                                  }
                                } catch (e) {
                                  Navigator.of(context).pop();
                                  final overlay = Overlay.of(context);
                                  final overlayEntry = OverlayEntry(
                                    builder: (ctx) => Positioned(
                                      top:
                                          MediaQuery.of(ctx).size.height * 0.45,
                                      left:
                                          MediaQuery.of(ctx).size.width * 0.15,
                                      right:
                                          MediaQuery.of(ctx).size.width * 0.15,
                                      child: Material(
                                        color: Colors.transparent,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 24,
                                            vertical: 16,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(
                                              24,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black12,
                                                blurRadius: 8,
                                              ),
                                            ],
                                          ),
                                          child: Center(
                                            child: Text(
                                              'Failed to add attendance.',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                                color: Colors.red,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                  overlay.insert(overlayEntry);
                                  await Future.delayed(
                                    const Duration(seconds: 1),
                                  );
                                  overlayEntry.remove();
                                }
                              },
                              child: const Text(
                                'Create',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
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

  void _onDelete(int id) async {
    // Find the date string for the selected id
    String formattedDate = '';
    final attendanceList = await _attendanceFuture;
    AttendanceItem item = attendanceList.data.firstWhere(
      (e) => e.id == id,
      orElse: () => AttendanceItem(
        id: id,
        date: '',
        status: '',
        createdAt: '',
        updatedAt: '',
      ),
    );
    try {
      final dt = DateTime.tryParse(item.date);
      if (dt != null) {
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
        formattedDate = '"${dt.day} ${months[dt.month]} ${dt.year}"';
      } else {
        formattedDate = '"${item.date}"';
      }
    } catch (_) {
      formattedDate = '"${item.date}"';
    }

    final confirm = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Remove the following date?',
                style: const TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                formattedDate,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 22),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey.shade200,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        side: const BorderSide(color: Colors.grey),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text(
                        'No',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text(
                        'Yes',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
    if (confirm == true) {
      String message = '';
      Map<String, dynamic> resp = {};
      try {
        resp = await _attendanceService.deleteAttendance(id);
        print('[DeleteAttendance] Response: $resp');
        if (resp['success'] == true) {
          message = resp['message'] ?? 'Delete successfully';
        } else {
          message = resp['message'] ?? 'Failed to delete attendance.';
        }
      } catch (e) {
        print('[DeleteAttendance] Error: $e');
        message = 'Failed to delete attendance.';
      }
      // Show custom snackbar for 1 second
      final overlay = Overlay.of(context);
      final overlayEntry = OverlayEntry(
        builder: (ctx) => Positioned(
          top: MediaQuery.of(ctx).size.height * 0.45,
          left: MediaQuery.of(ctx).size.width * 0.15,
          right: MediaQuery.of(ctx).size.width * 0.15,
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8)],
              ),
              child: Center(
                child: Text(
                  message,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: resp['success'] == true ? Colors.black : Colors.red,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      overlay.insert(overlayEntry);
      await Future.delayed(const Duration(seconds: 1));
      overlayEntry.remove();
      // Always reset to first page and clear search to ensure deleted item is not filtered or paginated out
      setState(() {
        _page = 1;
        _search = '';
        _searchController.clear();
      });
      _fetchAttendance();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD9D9D9),
      body: Stack(
        children: [
          Column(
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
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'search date',
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 14,
                      ),
                      prefixIcon: const Icon(
                        Icons.search,
                        color: Color(0xFF43C463),
                      ),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                _onSearch('');
                              },
                            )
                          : null,
                    ),
                    keyboardType: TextInputType.text,
                    onChanged: _onSearch,
                  ),
                ),
              ),
              Expanded(
                child: FutureBuilder<AttendanceListResponse>(
                  future: _attendanceFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Failed to load attendance.'));
                    } else if (!snapshot.hasData ||
                        snapshot.data!.data.isEmpty) {
                      return const Center(
                        child: Text('No attendance records found.'),
                      );
                    }
                    final attendance = snapshot.data!;
                    // Filter for partial date match if search is not empty
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
                      return const Center(
                        child: Text('No attendance records found.'),
                      );
                    }
                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final item = filtered[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
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
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            title: Row(
                              children: [
                                const Text(
                                  'Date: ',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  item.date,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _onDelete(item.id),
                            ),
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) =>
                                      // You may need to import the details view at the top
                                      // import 'manage_attendance_details_view.dart';
                                      // Pass the id and date string
                                      ManageAttendanceDetailsView(
                                        dateAttendanceId: item.id,
                                        dateLabel: item.date,
                                      ),
                                ),
                              );
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
          Positioned(
            bottom: 24,
            right: 24,
            child: FloatingActionButton(
              backgroundColor: const Color(0xFF43C463),
              child: const Icon(Icons.add, size: 32),
              onPressed: _showAddAttendanceDialog,
            ),
          ),
        ],
      ),
    );
  }
}
