import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/mega_app_header.dart';
import '../../../core/widgets/mega_button.dart';
import '../../../core/widgets/mega_text_field.dart';
import '../data/service/staff_service.dart';
import '../data/service/manager_dashboard_service.dart';
import '../data/model/staff_brief_model.dart';

class AddWorkerPage extends StatefulWidget {
  final int taskId;
  const AddWorkerPage({super.key, required this.taskId});

  @override
  State<AddWorkerPage> createState() => _AddWorkerPageState();
}

class _AddWorkerPageState extends State<AddWorkerPage> {
  bool _isSubmitting = false;
  String? _submitError;
  List<StaffBriefModel> selectedWorkers = [];
  String? _taskType;
  bool _isLoading = true;

  // Metadata fields
  String? selectedFertilizerType;
  final TextEditingController _fertilizerAmountController =
      TextEditingController();
  String? selectedPruningType;
  String? selectedHarvestingType;
  String? selectedSanitationType;
  final TextEditingController _herbicideAmountController =
      TextEditingController();

  // Dropdown options
  List<String> fertilizerTypes = ['MOP', 'BORATE', 'NPK', 'UREA'];
  final List<String> pruningTypes = ['normal pruning', 'routine pruning'];
  final List<String> harvestingTypes = [
    'normal harvesting',
    'collect loose fruits',
  ];
  final List<String> sanitationTypes = ['spraying', 'slashing'];

  List<StaffBriefModel> _allWorkers = [];
  bool _loadingWorkers = false;

  @override
  void initState() {
    super.initState();
    _fetchTaskDetails();
  }

  @override
  void dispose() {
    _fertilizerAmountController.dispose();
    _herbicideAmountController.dispose();
    super.dispose();
  }

  Future<void> _fetchTaskDetails() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final service = ManagerDashboardService();
      final task = await service.fetchTaskPreview(widget.taskId);
      final dynamicFertilizers = await service.fetchFertilizerTypes();
      if (!mounted) return;
      if (task != null) {
        setState(() {
          _taskType = task.taskType;
          if (dynamicFertilizers.isNotEmpty) {
            fertilizerTypes = dynamicFertilizers;
          }
          _isLoading = false;
        });
      } else {
        setState(() {
          _submitError = "Failed to load task details";
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _submitError = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _selectWorkers() async {
    setState(() {
      _loadingWorkers = true;
    });
    try {
      final staffModels = await StaffService().fetchClaimedStaff();
      final workers = staffModels
          .map(
            (s) => StaffBriefModel(
              id: s.id,
              staffFullname: s.staffFullname,
              staffPhone: s.staffPhone,
              staffDob: s.staffDob,
              staffImg: s.staffImg,
              staffGender: s.staffGender,
            ),
          )
          .toList();
      if (!mounted) return;
      setState(() {
        _allWorkers = workers;
        _loadingWorkers = false;
      });

      StaffBriefModel? singleSelected =
          selectedWorkers.isNotEmpty ? selectedWorkers.first : null;

      await showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (context) {
          return StatefulBuilder(
            builder: (context, setModalState) {
              return SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 20,
                    horizontal: 16,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Select Worker',
                            style: AppTypography.headingLarge.copyWith(
                              fontSize: 16,
                              color: AppColors.mcTextPrimary,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close_rounded, size: 20),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                        ],
                      ),
                      const Divider(color: AppColors.mcBorder),
                      SizedBox(
                        height: 320,
                        child: _allWorkers.isEmpty
                            ? Center(
                                child: Text(
                                  'No claimed workers found',
                                  style: AppTypography.bodyMedium.copyWith(
                                    color: AppColors.mcTextMuted,
                                  ),
                                ),
                              )
                            : ListView.separated(
                                itemCount: _allWorkers.length,
                                separatorBuilder: (_, __) =>
                                    const SizedBox(height: 8),
                                itemBuilder: (context, idx) {
                                  final w = _allWorkers[idx];
                                  final selected =
                                      singleSelected?.id == w.id;
                                  return InkWell(
                                    borderRadius: BorderRadius.circular(12),
                                    onTap: () {
                                      setModalState(() {
                                        singleSelected = selected ? null : w;
                                      });
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: selected
                                            ? AppColors.mcForestGreen
                                                .withOpacity(0.08)
                                            : Colors.white,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: selected
                                              ? AppColors.mcForestGreen
                                              : AppColors.mcBorder,
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          CircleAvatar(
                                            radius: 20,
                                            backgroundColor: AppColors
                                                .mcForestGreen
                                                .withOpacity(0.1),
                                            child: w.staffImg.isNotEmpty
                                                ? ClipOval(
                                                    child: Image.network(
                                                      w.staffImg,
                                                      width: 40,
                                                      height: 40,
                                                      fit: BoxFit.cover,
                                                      errorBuilder:
                                                          (_, __, ___) =>
                                                              const Icon(
                                                        Icons.person,
                                                        color: AppColors
                                                            .mcForestGreen,
                                                      ),
                                                    ),
                                                  )
                                                : const Icon(
                                                    Icons.person,
                                                    color: AppColors
                                                        .mcForestGreen,
                                                  ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  w.staffFullname,
                                                  style: AppTypography
                                                      .labelLarge
                                                      .copyWith(
                                                    color: selected
                                                        ? AppColors.mcForestGreen
                                                        : AppColors
                                                            .mcTextPrimary,
                                                    fontWeight: selected
                                                        ? FontWeight.w700
                                                        : FontWeight.w600,
                                                  ),
                                                ),
                                                if (w.staffPhone.isNotEmpty)
                                                  Text(
                                                    w.staffPhone,
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
                                          if (selected)
                                            const Icon(
                                              Icons.check_circle_rounded,
                                              color: AppColors.mcForestGreen,
                                              size: 22,
                                            ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ),
                      const SizedBox(height: 16),
                      MegaButton(
                        label: 'Confirm Selection',
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      );

      if (mounted) {
        setState(() {
          selectedWorkers =
              singleSelected != null ? [singleSelected!] : [];
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loadingWorkers = false;
        });
      }
    }
  }

  String _getTaskTitle() {
    switch (_taskType) {
      case 'manuring':
        return 'Manuring Task';
      case 'pruning':
        return 'Pruning Task';
      case 'harvesting':
        return 'Harvesting Task';
      case 'sanitation':
        return 'Sanitation Task';
      case 'planting':
        return 'Planting Task';
      default:
        return 'Task Details';
    }
  }

  Future<void> _submitAssignment() async {
    if (selectedWorkers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a worker first'),
          backgroundColor: AppColors.mcStatusRed,
        ),
      );
      return;
    }

    final fertilizerAmount = _fertilizerAmountController.text.trim();
    final herbicideAmount = _herbicideAmountController.text.trim();

    if (_taskType == 'manuring' &&
        (selectedFertilizerType == null || fertilizerAmount.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select fertilizer type and enter amount'),
          backgroundColor: AppColors.mcStatusRed,
        ),
      );
      return;
    }

    if (_taskType == 'pruning' && selectedPruningType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select pruning type'),
          backgroundColor: AppColors.mcStatusRed,
        ),
      );
      return;
    }

    if (_taskType == 'harvesting' && selectedHarvestingType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select harvesting type'),
          backgroundColor: AppColors.mcStatusRed,
        ),
      );
      return;
    }

    if (_taskType == 'sanitation' && selectedSanitationType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select sanitation type'),
          backgroundColor: AppColors.mcStatusRed,
        ),
      );
      return;
    }

    if (_taskType == 'sanitation' &&
        selectedSanitationType == 'spraying' &&
        herbicideAmount.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter herbicide amount'),
          backgroundColor: AppColors.mcStatusRed,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
      _submitError = null;
    });

    try {
      final workerId = selectedWorkers[0].id;
      Map<String, dynamic> meta = {};

      switch (_taskType) {
        case 'manuring':
          meta = {
            'fertilizer_type': selectedFertilizerType,
            'fertilizer_amount': fertilizerAmount,
          };
          break;
        case 'pruning':
          meta = {
            'pruning_type': selectedPruningType,
          };
          break;
        case 'harvesting':
          meta = {
            'harvesting_type': selectedHarvestingType,
          };
          break;
        case 'sanitation':
          if (selectedSanitationType == 'spraying') {
            meta = {
              'sanitation_type': selectedSanitationType,
              'herbicide_amount': herbicideAmount,
            };
          } else if (selectedSanitationType == 'slashing') {
            meta = {
              'sanitation_type': selectedSanitationType,
            };
          }
          break;
        case 'planting':
          meta = {};
          break;
      }

      final workerData = [
        {'staff_id': workerId, 'meta': meta},
      ];

      final service = ManagerDashboardService();
      final response = await service.assignWorkersToTask(
        taskId: widget.taskId,
        workers: workerData,
      );

      if (response != null && response['success'] == true) {
        if (mounted) {
          await showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => Center(
              child: Material(
                color: Colors.transparent,
                child: Container(
                  width: 280,
                  padding: const EdgeInsets.symmetric(
                    vertical: 28,
                    horizontal: 24,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.mcBorder),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.mcForestGreen.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check_circle_rounded,
                          color: AppColors.mcForestGreen,
                          size: 48,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Worker Assigned!',
                        style: AppTypography.headingLarge.copyWith(
                          fontSize: 18,
                          color: AppColors.mcTextPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Worker and parameters have been successfully assigned to this task.',
                        textAlign: TextAlign.center,
                        style: AppTypography.caption.copyWith(
                          color: AppColors.mcTextMuted,
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: MegaButton(
                          label: 'Done',
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
          if (mounted) {
            Navigator.pop(context, true);
          }
        }
      } else {
        if (mounted) {
          setState(() {
            _submitError = response?['message'] ?? 'Failed to assign workers.';
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _submitError = e.toString();
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.mcBgApp,
      body: SafeArea(
        child: Column(
          children: [
            MegaAppHeader(
              title: 'Assign Worker',
              subtitle: _getTaskTitle(),
              showBackButton: true,
            ),
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.mcForestGreen,
                      ),
                    )
                  : _submitError != null && selectedWorkers.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.error_outline_rounded,
                            color: AppColors.mcStatusRed,
                            size: 48,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _submitError!,
                            style: AppTypography.bodyMedium.copyWith(
                              color: AppColors.mcStatusRed,
                            ),
                          ),
                          const SizedBox(height: 16),
                          MegaButton(
                            label: 'Retry',
                            onPressed: _fetchTaskDetails,
                          ),
                        ],
                      ),
                    )
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
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
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Select Worker',
                                  style: AppTypography.labelLarge.copyWith(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.mcTextPrimary,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                InkWell(
                                  borderRadius: BorderRadius.circular(12),
                                  onTap: _selectWorkers,
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: AppColors.mcBorder,
                                      ),
                                    ),
                                    child: _loadingWorkers
                                        ? const Row(
                                            children: [
                                              SizedBox(
                                                width: 18,
                                                height: 18,
                                                child:
                                                    CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                  color:
                                                      AppColors.mcForestGreen,
                                                ),
                                              ),
                                              SizedBox(width: 12),
                                              Text('Loading workers...'),
                                            ],
                                          )
                                        : selectedWorkers.isEmpty
                                        ? Row(
                                            children: [
                                              const Icon(
                                                Icons.person_add_outlined,
                                                color: AppColors.mcTextMuted,
                                                size: 22,
                                              ),
                                              const SizedBox(width: 10),
                                              Text(
                                                'Tap to choose a worker...',
                                                style: AppTypography
                                                    .bodyMedium
                                                    .copyWith(
                                                  color: AppColors.mcTextMuted,
                                                ),
                                              ),
                                            ],
                                          )
                                        : Row(
                                            children: [
                                              CircleAvatar(
                                                radius: 20,
                                                backgroundColor: AppColors
                                                    .mcForestGreen
                                                    .withOpacity(0.1),
                                                child: const Icon(
                                                  Icons.person_rounded,
                                                  color:
                                                      AppColors.mcForestGreen,
                                                ),
                                              ),
                                              const SizedBox(width: 12),
                                              Expanded(
                                                child: Text(
                                                  selectedWorkers[0]
                                                      .staffFullname,
                                                  style: AppTypography
                                                      .labelLarge
                                                      .copyWith(
                                                    fontWeight:
                                                        FontWeight.w600,
                                                    color: AppColors
                                                        .mcTextPrimary,
                                                  ),
                                                ),
                                              ),
                                              const Icon(
                                                Icons.check_circle_rounded,
                                                color: AppColors.mcForestGreen,
                                                size: 20,
                                              ),
                                            ],
                                          ),
                                  ),
                                ),

                                // Task Type Specific Form Elements
                                if (_taskType == 'manuring') ...[
                                  const SizedBox(height: 18),
                                  Text(
                                    'Fertilizer Type',
                                    style: AppTypography.labelLarge.copyWith(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.mcTextPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: AppColors.mcBorder,
                                      ),
                                    ),
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButton<String>(
                                        value: selectedFertilizerType,
                                        isExpanded: true,
                                        hint: Text(
                                          'Select fertilizer...',
                                          style: AppTypography.bodyMedium
                                              .copyWith(
                                            color: AppColors.mcTextMuted,
                                          ),
                                        ),
                                        items: fertilizerTypes
                                            .map(
                                              (f) => DropdownMenuItem(
                                                value: f,
                                                child: Text(
                                                  f,
                                                  style: AppTypography
                                                      .bodyMedium,
                                                ),
                                              ),
                                            )
                                            .toList(),
                                        onChanged: (val) => setState(
                                          () => selectedFertilizerType = val,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 18),
                                  MegaTextField(
                                    controller: _fertilizerAmountController,
                                    label: 'Fertilizer Amount (kg)',
                                    hintText: 'e.g. 50',
                                    keyboardType: TextInputType.number,
                                    prefixIcon: const Icon(
                                      Icons.scale_outlined,
                                      color: AppColors.mcTextMuted,
                                      size: 20,
                                    ),
                                  ),
                                ],

                                if (_taskType == 'pruning') ...[
                                  const SizedBox(height: 18),
                                  Text(
                                    'Pruning Type',
                                    style: AppTypography.labelLarge.copyWith(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.mcTextPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: AppColors.mcBorder,
                                      ),
                                    ),
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButton<String>(
                                        value: selectedPruningType,
                                        isExpanded: true,
                                        hint: Text(
                                          'Select pruning type...',
                                          style: AppTypography.bodyMedium
                                              .copyWith(
                                            color: AppColors.mcTextMuted,
                                          ),
                                        ),
                                        items: pruningTypes
                                            .map(
                                              (t) => DropdownMenuItem(
                                                value: t,
                                                child: Text(
                                                  t,
                                                  style: AppTypography
                                                      .bodyMedium,
                                                ),
                                              ),
                                            )
                                            .toList(),
                                        onChanged: (val) => setState(
                                          () => selectedPruningType = val,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],

                                if (_taskType == 'harvesting') ...[
                                  const SizedBox(height: 18),
                                  Text(
                                    'Harvesting Type',
                                    style: AppTypography.labelLarge.copyWith(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.mcTextPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: AppColors.mcBorder,
                                      ),
                                    ),
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButton<String>(
                                        value: selectedHarvestingType,
                                        isExpanded: true,
                                        hint: Text(
                                          'Select harvesting type...',
                                          style: AppTypography.bodyMedium
                                              .copyWith(
                                            color: AppColors.mcTextMuted,
                                          ),
                                        ),
                                        items: harvestingTypes
                                            .map(
                                              (t) => DropdownMenuItem(
                                                value: t,
                                                child: Text(
                                                  t,
                                                  style: AppTypography
                                                      .bodyMedium,
                                                ),
                                              ),
                                            )
                                            .toList(),
                                        onChanged: (val) => setState(
                                          () => selectedHarvestingType = val,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],

                                if (_taskType == 'sanitation') ...[
                                  const SizedBox(height: 18),
                                  Text(
                                    'Sanitation Type',
                                    style: AppTypography.labelLarge.copyWith(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.mcTextPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: AppColors.mcBorder,
                                      ),
                                    ),
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButton<String>(
                                        value: selectedSanitationType,
                                        isExpanded: true,
                                        hint: Text(
                                          'Select sanitation type...',
                                          style: AppTypography.bodyMedium
                                              .copyWith(
                                            color: AppColors.mcTextMuted,
                                          ),
                                        ),
                                        items: sanitationTypes
                                            .map(
                                              (t) => DropdownMenuItem(
                                                value: t,
                                                child: Text(
                                                  t,
                                                  style: AppTypography
                                                      .bodyMedium,
                                                ),
                                              ),
                                            )
                                            .toList(),
                                        onChanged: (val) => setState(
                                          () => selectedSanitationType = val,
                                        ),
                                      ),
                                    ),
                                  ),
                                  if (selectedSanitationType == 'spraying') ...[
                                    const SizedBox(height: 18),
                                    MegaTextField(
                                      controller: _herbicideAmountController,
                                      label: 'Herbicide Amount (L)',
                                      hintText: 'e.g. 15',
                                      keyboardType: TextInputType.number,
                                      prefixIcon: const Icon(
                                        Icons.opacity_outlined,
                                        color: AppColors.mcTextMuted,
                                        size: 20,
                                      ),
                                    ),
                                  ],
                                ],
                              ],
                            ),
                          ),

                          if (_submitError != null) ...[
                            const SizedBox(height: 14),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.mcStatusRed.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: AppColors.mcStatusRed.withOpacity(0.3),
                                ),
                              ),
                              child: Text(
                                _submitError!,
                                style: AppTypography.caption.copyWith(
                                  color: AppColors.mcStatusRed,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],

                          const SizedBox(height: 24),
                          MegaButton(
                            label: 'Assign Worker',
                            isLoading: _isSubmitting,
                            onPressed: _isSubmitting || selectedWorkers.isEmpty
                                ? null
                                : _submitAssignment,
                            icon: const Icon(
                              Icons.person_add_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
