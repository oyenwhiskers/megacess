import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/mega_app_header.dart';
import '../../../core/widgets/mega_status_badge.dart';
import '../../../core/widgets/mega_text_field.dart';
import '../data/service/manager_service.dart';
import '../data/model/manager_models.dart';

class ManageTasksView extends StatefulWidget {
  final int locationId;
  final String locationName;

  const ManageTasksView({
    super.key,
    required this.locationId,
    required this.locationName,
  });

  @override
  State<ManageTasksView> createState() => _ManageTasksViewState();
}

class _ManageTasksViewState extends State<ManageTasksView> {
  final ManagerService _service = ManagerService();
  bool _isLoading = true;
  String? _error;
  LocationItem? _location;
  List<WorkerWithTasks> _workers = [];
  List<WorkerWithTasks> _filteredWorkers = [];
  final TextEditingController _searchController = TextEditingController();

  // Filter variables
  bool _showFilterOptions = false;
  String? _selectedTaskType;
  String? _selectedStatus;
  final List<String> _taskTypes = [
    'Manuring',
    'Pruning',
    'Sanitation',
    'Harvesting',
    'Planting',
  ];
  final List<String> _statusOptions = ['In-progress', 'Pending', 'Completed'];

  @override
  void initState() {
    super.initState();
    _fetchDetail();
    _searchController.addListener(_filterWorkers);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterWorkers);
    _searchController.dispose();
    super.dispose();
  }

  void _filterWorkers() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredWorkers = _workers.where((worker) {
        bool matchesSearch =
            query.isEmpty || worker.workerName.toLowerCase().contains(query);

        bool matchesTaskType =
            _selectedTaskType == null ||
            worker.tasks.any(
              (task) =>
                  task.taskType.toLowerCase() ==
                  _selectedTaskType!.toLowerCase(),
            );

        bool matchesStatus =
            _selectedStatus == null ||
            worker.tasks.any(
              (task) =>
                  task.taskStatus.toLowerCase() ==
                  _selectedStatus!.toLowerCase().replaceAll('-', '_'),
            );

        return matchesSearch && matchesTaskType && matchesStatus;
      }).toList();
    });
  }

  void _resetFilters() {
    setState(() {
      _selectedTaskType = null;
      _selectedStatus = null;
    });
    _filterWorkers();
  }

  void _showWorkerTasksDialog(WorkerWithTasks worker) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: Colors.white,
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.75,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Dialog Header
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 12, 14),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor:
                          AppColors.mcForestGreen.withOpacity(0.1),
                      child: const Icon(
                        Icons.person_rounded,
                        color: AppColors.mcForestGreen,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            worker.workerName,
                            style: AppTypography.headingLarge.copyWith(
                              fontSize: 16,
                              color: AppColors.mcTextPrimary,
                            ),
                          ),
                          Text(
                            worker.workerPhone.isNotEmpty
                                ? worker.workerPhone
                                : 'No phone number',
                            style: AppTypography.caption.copyWith(
                              color: AppColors.mcTextMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, size: 20),
                      color: AppColors.mcTextMuted,
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: AppColors.mcBorder),

              // Tasks List
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  padding: const EdgeInsets.all(16),
                  itemCount: worker.tasks.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final task = worker.tasks[index];
                    return Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.mcBgApp,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.mcBorder),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              _buildTaskTypeBadge(task.taskType),
                              const Spacer(),
                              MegaStatusBadge(status: task.taskStatus),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            task.taskName,
                            style: AppTypography.labelLarge.copyWith(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.mcTextPrimary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Icon(
                                Icons.calendar_today_outlined,
                                size: 13,
                                color: AppColors.mcTextMuted,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                task.taskDate,
                                style: AppTypography.caption.copyWith(
                                  color: AppColors.mcTextMuted,
                                ),
                              ),
                            ],
                          ),
                          if (task.meta.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            const Divider(height: 1, color: AppColors.mcBorder),
                            const SizedBox(height: 8),
                            ...task.meta.entries.map((entry) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 3),
                                child: Row(
                                  children: [
                                    Text(
                                      '${entry.key.replaceAll('_', ' ')}: ',
                                      style: AppTypography.caption.copyWith(
                                        color: AppColors.mcTextMuted,
                                      ),
                                    ),
                                    Text(
                                      entry.value.toString(),
                                      style: AppTypography.caption.copyWith(
                                        color: AppColors.mcTextPrimary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }),
                          ],
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _fetchDetail() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final response = await _service.fetchLocationTasksBreakdown(
        widget.locationId,
      );
      if (mounted) {
        setState(() {
          _location = response.location;
          _workers = response.workers;
          _filteredWorkers = _workers;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _refreshData() async {
    try {
      final response = await _service.fetchLocationTasksBreakdown(
        widget.locationId,
      );
      if (mounted) {
        setState(() {
          _location = response.location;
          _workers = response.workers;
          _filterWorkers();
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
        });
      }
    }
  }

  Widget _buildTaskTypeBadge(String type) {
    Color color;
    IconData icon;
    String label;
    switch (type.toLowerCase()) {
      case 'manuring':
        color = AppColors.mcForestGreen;
        icon = Icons.eco_outlined;
        label = 'Manuring';
        break;
      case 'pruning':
        color = Colors.orange;
        icon = Icons.content_cut_outlined;
        label = 'Pruning';
        break;
      case 'sanitation':
        color = Colors.amber[800]!;
        icon = Icons.cleaning_services_outlined;
        label = 'Sanitation';
        break;
      case 'harvesting':
        color = Colors.deepOrange;
        icon = Icons.agriculture_outlined;
        label = 'Harvesting';
        break;
      case 'planting':
        color = Colors.teal;
        icon = Icons.grass_outlined;
        label = 'Planting';
        break;
      default:
        color = AppColors.mcTextMuted;
        icon = Icons.task_outlined;
        label = type;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTypography.caption.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool hasActiveFilters =
        _selectedTaskType != null || _selectedStatus != null;

    return Scaffold(
      backgroundColor: AppColors.mcBgApp,
      body: SafeArea(
        child: Column(
          children: [
            MegaAppHeader(
              title: 'Manage Tasks',
              subtitle: _location?.name ?? widget.locationName,
              showBackButton: true,
              actions: [
                if (hasActiveFilters)
                  IconButton(
                    icon: const Icon(
                      Icons.filter_alt_off_rounded,
                      color: AppColors.mcStatusRed,
                      size: 20,
                    ),
                    onPressed: _resetFilters,
                    tooltip: 'Reset Filters',
                  ),
              ],
            ),
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.mcForestGreen,
                      ),
                    )
                  : _error != null
                  ? Center(
                      child: Text(
                        'Error: $_error',
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.mcStatusRed,
                        ),
                      ),
                    )
                  : RefreshIndicator(
                      color: AppColors.mcForestGreen,
                      onRefresh: _refreshData,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header Stats Row
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.group_outlined,
                                      size: 18,
                                      color: AppColors.mcForestGreen,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      '${_filteredWorkers.length} workers with tasks',
                                      style: AppTypography.labelLarge.copyWith(
                                        color: AppColors.mcTextPrimary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                                TextButton.icon(
                                  onPressed: () {
                                    setState(() {
                                      _showFilterOptions = !_showFilterOptions;
                                    });
                                  },
                                  style: TextButton.styleFrom(
                                    foregroundColor: hasActiveFilters
                                        ? AppColors.mcForestGreen
                                        : AppColors.mcTextMuted,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                  ),
                                  icon: Icon(
                                    _showFilterOptions
                                        ? Icons.expand_less_rounded
                                        : Icons.tune_rounded,
                                    size: 18,
                                  ),
                                  label: Text(
                                    hasActiveFilters
                                        ? 'Filtered'
                                        : 'Filters',
                                    style: AppTypography.caption.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: hasActiveFilters
                                          ? AppColors.mcForestGreen
                                          : AppColors.mcTextMuted,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),

                            // Search bar
                            MegaTextField(
                              controller: _searchController,
                              hintText: 'Search by worker name...',
                              prefixIcon: const Icon(
                                Icons.search_rounded,
                                color: AppColors.mcTextMuted,
                                size: 20,
                              ),
                              suffixIcon: _searchController.text.isNotEmpty
                                  ? IconButton(
                                      icon: const Icon(
                                        Icons.clear_rounded,
                                        color: AppColors.mcTextMuted,
                                        size: 18,
                                      ),
                                      onPressed: () =>
                                          _searchController.clear(),
                                    )
                                  : null,
                            ),

                            // Filter collapsible panel
                            if (_showFilterOptions) ...[
                              const SizedBox(height: 10),
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: AppColors.mcBorder,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.03),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Task Type',
                                      style: AppTypography.caption.copyWith(
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.mcTextPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Wrap(
                                      spacing: 8,
                                      runSpacing: 8,
                                      children: _taskTypes.map((type) {
                                        final isSel =
                                            _selectedTaskType == type;
                                        return FilterChip(
                                          label: Text(type),
                                          selected: isSel,
                                          selectedColor: AppColors
                                              .mcForestGreen
                                              .withOpacity(0.15),
                                          checkmarkColor:
                                              AppColors.mcForestGreen,
                                          labelStyle: AppTypography.caption
                                              .copyWith(
                                            color: isSel
                                                ? AppColors.mcForestGreen
                                                : AppColors.mcTextPrimary,
                                            fontWeight: isSel
                                                ? FontWeight.w700
                                                : FontWeight.w500,
                                          ),
                                          backgroundColor: AppColors.mcBgApp,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            side: BorderSide(
                                              color: isSel
                                                  ? AppColors.mcForestGreen
                                                  : AppColors.mcBorder,
                                            ),
                                          ),
                                          onSelected: (val) {
                                            setState(() {
                                              _selectedTaskType =
                                                  val ? type : null;
                                            });
                                            _filterWorkers();
                                          },
                                        );
                                      }).toList(),
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      'Status',
                                      style: AppTypography.caption.copyWith(
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.mcTextPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Wrap(
                                      spacing: 8,
                                      runSpacing: 8,
                                      children: _statusOptions.map((st) {
                                        final isSel = _selectedStatus == st;
                                        return FilterChip(
                                          label: Text(st),
                                          selected: isSel,
                                          selectedColor: AppColors
                                              .mcForestGreen
                                              .withOpacity(0.15),
                                          checkmarkColor:
                                              AppColors.mcForestGreen,
                                          labelStyle: AppTypography.caption
                                              .copyWith(
                                            color: isSel
                                                ? AppColors.mcForestGreen
                                                : AppColors.mcTextPrimary,
                                            fontWeight: isSel
                                                ? FontWeight.w700
                                                : FontWeight.w500,
                                          ),
                                          backgroundColor: AppColors.mcBgApp,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            side: BorderSide(
                                              color: isSel
                                                  ? AppColors.mcForestGreen
                                                  : AppColors.mcBorder,
                                            ),
                                          ),
                                          onSelected: (val) {
                                            setState(() {
                                              _selectedStatus =
                                                  val ? st : null;
                                            });
                                            _filterWorkers();
                                          },
                                        );
                                      }).toList(),
                                    ),
                                  ],
                                ),
                              ),
                            ],

                            const SizedBox(height: 12),

                            // Workers List
                            Expanded(
                              child: _filteredWorkers.isEmpty
                                  ? ListView(
                                      children: [
                                        SizedBox(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.3,
                                          child: Center(
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Icon(
                                                  Icons.assignment_late_outlined,
                                                  size: 48,
                                                  color: AppColors.mcTextMuted
                                                      .withOpacity(0.5),
                                                ),
                                                const SizedBox(height: 10),
                                                Text(
                                                  'No workers found matching filters',
                                                  style: AppTypography
                                                      .bodyMedium
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
                                      padding: const EdgeInsets.only(
                                        bottom: 16,
                                      ),
                                      itemCount: _filteredWorkers.length,
                                      separatorBuilder: (_, __) =>
                                          const SizedBox(height: 10),
                                      itemBuilder: (context, idx) {
                                        final worker = _filteredWorkers[idx];
                                        return Container(
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(14),
                                            border: Border.all(
                                              color: AppColors.mcBorder,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black
                                                    .withOpacity(0.02),
                                                blurRadius: 6,
                                                offset: const Offset(0, 2),
                                              ),
                                            ],
                                          ),
                                          child: Material(
                                            color: Colors.transparent,
                                            child: InkWell(
                                              borderRadius:
                                                  BorderRadius.circular(14),
                                              onTap: () =>
                                                  _showWorkerTasksDialog(
                                                worker,
                                              ),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(14),
                                                child: Row(
                                                  children: [
                                                    CircleAvatar(
                                                      radius: 20,
                                                      backgroundColor: AppColors
                                                          .mcForestGreen
                                                          .withOpacity(0.08),
                                                      child: Text(
                                                        '${idx + 1}',
                                                        style: AppTypography
                                                            .labelLarge
                                                            .copyWith(
                                                          color: AppColors
                                                              .mcForestGreen,
                                                          fontWeight:
                                                              FontWeight.w700,
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(width: 12),
                                                    Expanded(
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(
                                                            worker.workerName,
                                                            style: AppTypography
                                                                .labelLarge
                                                                .copyWith(
                                                              fontSize: 15,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              color: AppColors
                                                                  .mcTextPrimary,
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                            height: 3,
                                                          ),
                                                          Text(
                                                            worker.workerPhone
                                                                    .isNotEmpty
                                                                ? worker
                                                                    .workerPhone
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
                                                    ),
                                                    Container(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                        horizontal: 10,
                                                        vertical: 4,
                                                      ),
                                                      decoration: BoxDecoration(
                                                        color: AppColors
                                                            .mcForestGreen
                                                            .withOpacity(0.08),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(20),
                                                        border: Border.all(
                                                          color: AppColors
                                                              .mcForestGreen
                                                              .withOpacity(0.2),
                                                        ),
                                                      ),
                                                      child: Text(
                                                        '${worker.totalTasks} task${worker.totalTasks > 1 ? 's' : ''}',
                                                        style: AppTypography
                                                            .caption
                                                            .copyWith(
                                                          color: AppColors
                                                              .mcForestGreen,
                                                          fontWeight:
                                                              FontWeight.w700,
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(width: 8),
                                                    const Icon(
                                                      Icons
                                                          .chevron_right_rounded,
                                                      color: AppColors
                                                          .mcForestGreen,
                                                      size: 20,
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
                          ],
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
