import 'package:flutter/material.dart';
import '../data/service/staff_service.dart';
import '../view/add_staff_popup.dart';

class MyStaffPage extends StatefulWidget {
  const MyStaffPage({Key? key}) : super(key: key);

  @override
  State<MyStaffPage> createState() => _MyStaffPageState();
}

class _MyStaffPageState extends State<MyStaffPage> {
  final TextEditingController _searchController = TextEditingController();
  final StaffService _staffService = StaffService();
  List<String> staffList = [
  ];
  String searchQuery = '';
  bool _isLoadingPopup = false;

  @override
  Widget build(BuildContext context) {
    final filteredStaff = staffList
        .where((staff) => staff.toLowerCase().contains(searchQuery.toLowerCase()))
        .toList();
    return Scaffold(
      backgroundColor: const Color(0xFFD9D9D9),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.only(left: 12, right: 12, top: 18, bottom: 12),
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
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                itemCount: filteredStaff.length,
                itemBuilder: (context, index) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      color: Colors.white,
                      child: ListTile(
                        leading: const Icon(Icons.account_circle, size: 40, color: Colors.black45),
                        title: Text(filteredStaff[index], style: const TextStyle(fontSize: 16)),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {},
                      ),
                    ),
                  );
                },
              ),
            ),
            if (_isLoadingPopup)
              const Center(child: CircularProgressIndicator()),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF219653),
        child: const Icon(Icons.add, size: 32),
        onPressed: () async {
          setState(() {
            _isLoadingPopup = true;
          });
          try {
            final paginatedResult = await _staffService.fetchUnclaimedStaff();
            // Print staff list to console for debugging
            for (var staff in paginatedResult.staff) {
              print('Staff: id=${staff.id}, name=${staff.staffFullname}, phone=${staff.staffPhone}');
            }
            setState(() {
              _isLoadingPopup = false;
            });
            if (mounted) {
              showDialog(
                context: context,
                builder: (context) => AddStaffPopup(
                  staffList: paginatedResult.staff,
                  onAdd: (selectedStaff) {
                    // Handle add logic here
                  },
                  // TODO: Pass pagination info and implement infinite scroll in AddStaffPopup
                ),
              );
            }
          } catch (e) {
            setState(() {
              _isLoadingPopup = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed to load staff: $e')),
            );
          }
        },
      ),
    );
  }
}
