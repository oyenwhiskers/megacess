import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/mega_app_header.dart';
import '../../../core/widgets/mega_text_field.dart';
import '../data/model/staff_model.dart';
import '../data/service/staff_service.dart';
import 'staff_detail_page.dart';

class MyStaffPage extends StatefulWidget {
  const MyStaffPage({super.key});

  @override
  State<MyStaffPage> createState() => _MyStaffPageState();
}

class _MyStaffPageState extends State<MyStaffPage> {
  Timer? _refreshTimer;
  final TextEditingController _searchController = TextEditingController();
  final StaffService _staffService = StaffService();
  List<StaffModel> staffList = [];
  String searchQuery = '';
  bool _isLoadingStaff = true;

  @override
  void initState() {
    super.initState();
    _fetchClaimedStaff();
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchClaimedStaff() async {
    setState(() {
      _isLoadingStaff = true;
    });
    try {
      final staff = await _staffService.fetchClaimedStaff();
      if (mounted) {
        setState(() {
          staffList = staff;
          _isLoadingStaff = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingStaff = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load staff: $e'),
            backgroundColor: AppColors.mcStatusRed,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredStaff = staffList
        .where(
          (staff) => staff.staffFullname.toLowerCase().contains(
            searchQuery.toLowerCase(),
          ),
        )
        .toList();

    return Scaffold(
      backgroundColor: AppColors.mcBgApp,
      body: SafeArea(
        child: Column(
          children: [
            MegaAppHeader(
              title: 'My Staff',
              subtitle: 'Claimed plantation workers',
              showBackButton: true,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: MegaTextField(
                controller: _searchController,
                hintText: 'Search staff by name...',
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
            Expanded(
              child: _isLoadingStaff
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.mcForestGreen,
                      ),
                    )
                  : RefreshIndicator(
                      color: AppColors.mcForestGreen,
                      onRefresh: _fetchClaimedStaff,
                      child: filteredStaff.isEmpty
                          ? ListView(
                              children: [
                                SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height * 0.4,
                                  child: Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.group_outlined,
                                          size: 56,
                                          color: AppColors.mcTextMuted
                                              .withOpacity(0.5),
                                        ),
                                        const SizedBox(height: 12),
                                        Text(
                                          searchQuery.isEmpty
                                              ? 'No staff assigned yet'
                                              : 'No staff matching "$searchQuery"',
                                          style: AppTypography.bodyMedium
                                              .copyWith(
                                                color: AppColors.mcTextMuted,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : ListView.separated(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16.0,
                                vertical: 8.0,
                              ),
                              itemCount: filteredStaff.length,
                              separatorBuilder: (context, index) =>
                                  const SizedBox(height: 10),
                              itemBuilder: (context, index) {
                                final staff = filteredStaff[index];
                                return Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: AppColors.mcBorder,
                                      width: 1,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.02),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(14),
                                      onTap: () async {
                                        final result =
                                            await Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                StaffDetailPage(
                                              staffId: staff.id,
                                            ),
                                          ),
                                        );
                                        if (result == true) {
                                          _fetchClaimedStaff();
                                        }
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.all(12.0),
                                        child: Row(
                                          children: [
                                            CircleAvatar(
                                              radius: 24,
                                              backgroundColor: AppColors
                                                  .mcForestGreen
                                                  .withOpacity(0.08),
                                              child: staff.staffImg.isNotEmpty
                                                  ? ClipOval(
                                                      child: Image.network(
                                                        staff.staffImg,
                                                        width: 48,
                                                        height: 48,
                                                        fit: BoxFit.cover,
                                                        errorBuilder:
                                                            (context, error,
                                                                stackTrace) {
                                                          return const Icon(
                                                            Icons.person_rounded,
                                                            size: 26,
                                                            color: AppColors
                                                                .mcForestGreen,
                                                          );
                                                        },
                                                      ),
                                                    )
                                                  : const Icon(
                                                      Icons.person_rounded,
                                                      size: 26,
                                                      color: AppColors
                                                          .mcForestGreen,
                                                    ),
                                            ),
                                            const SizedBox(width: 14),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    staff.staffFullname,
                                                    style: AppTypography
                                                        .labelLarge
                                                        .copyWith(
                                                      fontSize: 15,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: AppColors
                                                          .mcTextPrimary,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 3),
                                                  Row(
                                                    children: [
                                                      const Icon(
                                                        Icons.phone_outlined,
                                                        size: 13,
                                                        color: AppColors
                                                            .mcTextMuted,
                                                      ),
                                                      const SizedBox(width: 4),
                                                      Text(
                                                        staff.staffPhone.isNotEmpty
                                                            ? staff.staffPhone
                                                            : 'No phone',
                                                        style: AppTypography
                                                            .caption
                                                            .copyWith(
                                                          color: AppColors
                                                              .mcTextMuted,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const Icon(
                                              Icons.chevron_right_rounded,
                                              color: AppColors.mcForestGreen,
                                              size: 22,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
