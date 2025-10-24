import 'package:flutter/material.dart';
import '../data/model/staff_model.dart';
import '../data/service/staff_service.dart';

class AddStaffPopup extends StatefulWidget {
  final List<StaffModel> staffList;
  final Future<bool> Function(List<StaffModel>) onAdd;
  const AddStaffPopup({Key? key, required this.staffList, required this.onAdd})
    : super(key: key);

  @override
  State<AddStaffPopup> createState() => _AddStaffPopupState();
}

class _AddStaffPopupState extends State<AddStaffPopup> {
  final TextEditingController _searchController = TextEditingController();
  final Set<int> _selectedStaffIds = {};
  String searchQuery = '';
  final StaffService _staffService = StaffService();
  final ScrollController _scrollController = ScrollController();
  List<StaffModel> _staff = [];
  int _currentPage = 1;
  int _lastPage = 1;
  bool _isLoading = false;
  bool _initialLoaded = false;

  @override
  void initState() {
    super.initState();
    _staff = List<StaffModel>.from(widget.staffList);
    _fetchInitial();
    _scrollController.addListener(_onScroll);
  }

  void _fetchInitial() async {
    if (_initialLoaded) return;
    setState(() => _isLoading = true);
    final result = await _staffService.fetchUnclaimedStaff(page: 1);
    setState(() {
      _staff = result.staff;
      _currentPage = result.currentPage;
      _lastPage = result.lastPage;
      _isLoading = false;
      _initialLoaded = true;
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 100 &&
        !_isLoading &&
        _currentPage < _lastPage) {
      _fetchMore();
    }
  }

  void _fetchMore() async {
    setState(() => _isLoading = true);
    final nextPage = _currentPage + 1;
    final result = await _staffService.fetchUnclaimedStaff(page: nextPage);
    setState(() {
      _staff.addAll(result.staff);
      _currentPage = result.currentPage;
      _lastPage = result.lastPage;
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredStaff = _staff
        .where(
          (staff) => staff.staffFullname.toLowerCase().contains(
            searchQuery.toLowerCase(),
          ),
        )
        .toList();
    final double maxHeight = MediaQuery.of(context).size.height * 0.75;
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
      child: Container(
        constraints: BoxConstraints(maxHeight: maxHeight),
        color: Colors.transparent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Color(0xFF7ED957),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Select Staff:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  GestureDetector(
                    child: const Icon(Icons.close, color: Colors.black),
                    onTap: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            Container(
              color: Color(0xFF7ED957),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'name...',
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
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
            Expanded(
              child: Stack(
                children: [
                  ListView.builder(
                    controller: _scrollController,
                    padding: EdgeInsets.zero,
                    itemCount: filteredStaff.length,
                    itemBuilder: (context, index) {
                      final staff = filteredStaff[index];
                      return Container(
                        margin: const EdgeInsets.symmetric(
                          vertical: 6,
                          horizontal: 18,
                        ),
                        child: Card(
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          color: Colors.white,
                          child: ListTile(
                            leading: const Icon(
                              Icons.account_circle,
                              size: 40,
                              color: Colors.black45,
                            ),
                            title: Text(
                              staff.staffFullname,
                              style: const TextStyle(fontSize: 16),
                            ),
                            trailing: Checkbox(
                              value: _selectedStaffIds.contains(staff.id),
                              onChanged: (checked) {
                                setState(() {
                                  if (checked == true) {
                                    _selectedStaffIds.add(staff.id);
                                  } else {
                                    _selectedStaffIds.remove(staff.id);
                                  }
                                });
                              },
                            ),
                            onTap: () {
                              setState(() {
                                if (_selectedStaffIds.contains(staff.id)) {
                                  _selectedStaffIds.remove(staff.id);
                                } else {
                                  _selectedStaffIds.add(staff.id);
                                }
                              });
                            },
                          ),
                        ),
                      );
                    },
                  ),
                  if (_isLoading)
                    const Positioned(
                      left: 0,
                      right: 0,
                      bottom: 8,
                      child: Center(child: CircularProgressIndicator()),
                    ),
                ],
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: Color(0xFF7ED957),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              width: double.infinity,
              child: TextButton(
                onPressed: () async {
                  final selected = _staff
                      .where((staff) => _selectedStaffIds.contains(staff.id))
                      .toList();
                  final result = await widget.onAdd(selected);
                  Navigator.of(context).pop(result);
                },
                child: const Text(
                  'Add',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 18,
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
