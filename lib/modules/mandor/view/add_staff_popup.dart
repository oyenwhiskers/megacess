import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/mega_button.dart';
import '../../../core/widgets/mega_text_field.dart';
import '../data/model/staff_model.dart';
import '../data/service/staff_service.dart';

class AddStaffPopup extends StatefulWidget {
  final List<StaffModel> staffList;
  final Future<bool> Function(List<StaffModel>) onAdd;
  const AddStaffPopup({
    super.key,
    required this.staffList,
    required this.onAdd,
  });

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
  bool _isSubmitting = false;

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
    try {
      final result = await _staffService.fetchUnclaimedStaff(page: 1);
      if (mounted) {
        setState(() {
          _staff = result.staff;
          _currentPage = result.currentPage;
          _lastPage = result.lastPage;
          _isLoading = false;
          _initialLoaded = true;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
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
    try {
      final result = await _staffService.fetchUnclaimedStaff(page: nextPage);
      if (mounted) {
        setState(() {
          _staff.addAll(result.staff);
          _currentPage = result.currentPage;
          _lastPage = result.lastPage;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
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
    final double maxHeight = MediaQuery.of(context).size.height * 0.8;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        constraints: BoxConstraints(maxHeight: maxHeight),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 12, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Claim Workers',
                        style: AppTypography.headingLarge.copyWith(
                          fontSize: 17,
                          color: AppColors.mcTextPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${_selectedStaffIds.length} worker(s) selected',
                        style: AppTypography.caption.copyWith(
                          color: AppColors.mcForestGreen,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.close_rounded,
                      color: AppColors.mcTextMuted,
                      size: 22,
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: AppColors.mcBorder),

            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: MegaTextField(
                controller: _searchController,
                hintText: 'Search unclaimed workers...',
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  color: AppColors.mcTextMuted,
                  size: 20,
                ),
                suffixIcon: searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(
                          Icons.clear_rounded,
                          color: AppColors.mcTextMuted,
                          size: 18,
                        ),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => searchQuery = '');
                        },
                      )
                    : null,
                onChanged: (value) {
                  setState(() {
                    searchQuery = value;
                  });
                },
              ),
            ),

            // Worker List
            Expanded(
              child: Stack(
                children: [
                  filteredStaff.isEmpty && !_isLoading
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.person_off_outlined,
                                size: 48,
                                color: AppColors.mcTextMuted.withOpacity(0.5),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                searchQuery.isEmpty
                                    ? 'No unclaimed workers available'
                                    : 'No workers matching "$searchQuery"',
                                style: AppTypography.caption.copyWith(
                                  color: AppColors.mcTextMuted,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.separated(
                          controller: _scrollController,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 4,
                          ),
                          itemCount: filteredStaff.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            final staff = filteredStaff[index];
                            final isChecked =
                                _selectedStaffIds.contains(staff.id);
                            return InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: () {
                                setState(() {
                                  if (isChecked) {
                                    _selectedStaffIds.remove(staff.id);
                                  } else {
                                    _selectedStaffIds.add(staff.id);
                                  }
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: isChecked
                                      ? AppColors.mcForestGreen.withOpacity(0.06)
                                      : AppColors.mcBgApp,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isChecked
                                        ? AppColors.mcForestGreen
                                        : AppColors.mcBorder,
                                    width: isChecked ? 1.5 : 1,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 20,
                                      backgroundColor: AppColors.mcForestGreen
                                          .withOpacity(0.1),
                                      child: staff.staffImg.isNotEmpty
                                          ? ClipOval(
                                              child: Image.network(
                                                staff.staffImg,
                                                width: 40,
                                                height: 40,
                                                fit: BoxFit.cover,
                                                errorBuilder:
                                                    (_, __, ___) =>
                                                        const Icon(
                                                  Icons.person,
                                                  color: AppColors.mcForestGreen,
                                                ),
                                              ),
                                            )
                                          : const Icon(
                                              Icons.person,
                                              color: AppColors.mcForestGreen,
                                            ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            staff.staffFullname,
                                            style: AppTypography.labelLarge
                                                .copyWith(
                                              fontWeight: isChecked
                                                  ? FontWeight.w700
                                                  : FontWeight.w600,
                                              color: isChecked
                                                  ? AppColors.mcForestGreen
                                                  : AppColors.mcTextPrimary,
                                            ),
                                          ),
                                          if (staff.staffPhone.isNotEmpty)
                                            Text(
                                              staff.staffPhone,
                                              style: AppTypography.caption
                                                  .copyWith(
                                                color: AppColors.mcTextMuted,
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                    Checkbox(
                                      value: isChecked,
                                      activeColor: AppColors.mcForestGreen,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(4),
                                      ),
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
                                  ],
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
                      child: Center(
                        child: SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.mcForestGreen,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Footer
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                border: Border(
                  top: BorderSide(color: AppColors.mcBorder),
                ),
              ),
              child: MegaButton(
                label: _selectedStaffIds.isEmpty
                    ? 'Claim Selected (0)'
                    : 'Claim Selected (${_selectedStaffIds.length})',
                isLoading: _isSubmitting,
                onPressed: _selectedStaffIds.isEmpty || _isSubmitting
                    ? null
                    : () async {
                        setState(() => _isSubmitting = true);
                        final selected = _staff
                            .where(
                              (staff) => _selectedStaffIds.contains(staff.id),
                            )
                            .toList();
                        final result = await widget.onAdd(selected);
                        if (mounted) {
                          setState(() => _isSubmitting = false);
                          Navigator.of(context).pop(result);
                        }
                      },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
