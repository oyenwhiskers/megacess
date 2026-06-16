import 'package:flutter/material.dart';
import '../data/model/staff_model.dart';
import '../data/service/staff_service.dart';

class StaffDetailPage extends StatefulWidget {
  final int staffId;
  const StaffDetailPage({super.key, required this.staffId});

  @override
  State<StaffDetailPage> createState() => _StaffDetailPageState();
}

class _StaffDetailPageState extends State<StaffDetailPage> {
  StaffModel? staff;
  bool isLoading = true;
  final StaffService _staffService = StaffService();

  @override
  void initState() {
    super.initState();
    _fetchDetail();
  }

  Future<void> _fetchDetail() async {
    setState(() => isLoading = true);
    staff = await _staffService.getStaffDetail(widget.staffId);
    setState(() => isLoading = false);
  }

  int getAge(String dob) {
    try {
      final birthDate = DateTime.parse(dob);
      final now = DateTime.now();
      int age = now.year - birthDate.year;
      if (now.month < birthDate.month ||
          (now.month == birthDate.month && now.day < birthDate.day)) {
        age--;
      }
      return age;
    } catch (_) {
      return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD9D9D9),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : staff == null
          ? const Center(child: Text('Staff not found'))
          : Column(
              children: [
                // Header gradient
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.only(
                    left: 0,
                    right: 0,
                    top: 0,
                    bottom: 32,
                  ),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF7ED957), Color(0xFFB2F7EF)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(32),
                      bottomRight: Radius.circular(32),
                    ),
                  ),
                  child: SafeArea(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.arrow_back,
                            color: Colors.black,
                          ),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                        const SizedBox(width: 8),
                        const Padding(
                          padding: EdgeInsets.only(top: 12.0),
                          child: Text(
                            'My Staff',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                // Avatar
                Center(
                  child: staff!.staffImg.isNotEmpty
                      ? CircleAvatar(
                          radius: 54,
                          backgroundColor: Colors.white,
                          backgroundImage: NetworkImage(staff!.staffImg),
                        )
                      : CircleAvatar(
                          radius: 54,
                          backgroundColor: Colors.white,
                          child: Icon(
                            Icons.account_circle,
                            size: 90,
                            color: Colors.black26,
                          ),
                        ),
                ),
                const SizedBox(height: 24),
                // Info Card
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 20,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.07),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Name: ${staff!.staffFullname}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Gender: ${staff!.staffGender}',
                        style: const TextStyle(fontSize: 15),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Age: ${getAge(staff!.staffDob)}',
                        style: const TextStyle(fontSize: 15),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Phone Number: ${staff!.staffPhone}',
                        style: const TextStyle(fontSize: 15),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Attendance Record (This Month): ${staff!.attendanceCountMonth ?? '-'}',
                        style: const TextStyle(fontSize: 15),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
              ],
            ),
    );
  }
}
