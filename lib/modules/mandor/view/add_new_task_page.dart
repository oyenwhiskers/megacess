import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/mega_app_header.dart';
import '../../../core/widgets/mega_button.dart';
import '../../../core/widgets/mega_text_field.dart';
import '../data/service/manager_dashboard_service.dart';

class AddNewTaskPage extends StatefulWidget {
  final int locationId;
  final String locationName;
  const AddNewTaskPage({
    super.key,
    required this.locationId,
    required this.locationName,
  });

  @override
  State<AddNewTaskPage> createState() => _AddNewTaskPageState();
}

class _AddNewTaskPageState extends State<AddNewTaskPage> {
  final ManagerDashboardService _service = ManagerDashboardService();
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _taskNameController = TextEditingController();
  String? _selectedType;
  DateTime? _selectedDate;
  bool _isSubmitting = false;
  String? _error;

  final List<String> _taskTypes = [
    'Manuring',
    'Pruning',
    'Sanitation',
    'Harvesting',
    'Planting',
  ];

  @override
  void dispose() {
    _taskNameController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() ||
        _selectedType == null ||
        _selectedDate == null) {
      if (_selectedType == null || _selectedDate == null) {
        setState(() {
          _error = 'Please complete all fields.';
        });
      }
      return;
    }
    setState(() {
      _isSubmitting = true;
      _error = null;
    });
    try {
      String typeValue;
      switch (_selectedType) {
        case 'Manuring':
          typeValue = 'manuring';
          break;
        case 'Pruning':
          typeValue = 'pruning';
          break;
        case 'Sanitation':
          typeValue = 'sanitation';
          break;
        case 'Harvesting':
          typeValue = 'harvesting';
          break;
        case 'Planting':
          typeValue = 'planting';
          break;
        default:
          typeValue = _selectedType!.toLowerCase();
      }
      final response = await _service.createTask(
        locationId: widget.locationId,
        taskName: _taskNameController.text.trim(),
        taskType: typeValue,
        taskDate: _selectedDate!.toIso8601String().split('T').first,
      );
      bool isSuccess = false;
      if (response != null &&
          response['data'] != null &&
          (response['statusCode'] == 200 || response['statusCode'] == 201)) {
        isSuccess = true;
      } else if (response != null) {
        if (response['success'] == true) {
          isSuccess = true;
        } else if (response['message'] != null &&
            response['message'].toString().toLowerCase().contains(
              'successfully',
            )) {
          isSuccess = true;
        }
      }
      if (isSuccess) {
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
                        'Task Created!',
                        style: AppTypography.headingLarge.copyWith(
                          fontSize: 18,
                          color: AppColors.mcTextPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Group task has been successfully scheduled.',
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
            Navigator.of(context).pop(true);
          }
        }
      } else {
        setState(() {
          _error = response?['message'] ?? 'Failed to create task.';
        });
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  void _showTaskTypePicker() async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: Colors.white,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Select Task Type',
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
                ..._taskTypes.map(
                  (type) {
                    final isSelected = _selectedType == type;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 6),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.mcForestGreen.withOpacity(0.08)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                        border: isSelected
                            ? Border.all(color: AppColors.mcForestGreen)
                            : null,
                      ),
                      child: ListTile(
                        dense: true,
                        title: Text(
                          type,
                          style: AppTypography.bodyMedium.copyWith(
                            fontWeight: isSelected
                                ? FontWeight.w700
                                : FontWeight.w500,
                            color: isSelected
                                ? AppColors.mcForestGreen
                                : AppColors.mcTextPrimary,
                          ),
                        ),
                        trailing: isSelected
                            ? const Icon(
                                Icons.check_rounded,
                                color: AppColors.mcForestGreen,
                                size: 20,
                              )
                            : null,
                        onTap: () => Navigator.of(context).pop(type),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
    if (selected != null) {
      setState(() {
        _selectedType = selected;
      });
    }
  }

  void _showDatePicker() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: DateTime(now.year - 2),
      lastDate: DateTime(now.year + 2),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.mcForestGreen,
              onPrimary: Colors.white,
              onSurface: AppColors.mcTextPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
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
              title: 'Create Task',
              subtitle: widget.locationName,
              showBackButton: true,
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
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
                              'Task Details',
                              style: AppTypography.headingLarge.copyWith(
                                fontSize: 16,
                                color: AppColors.mcTextPrimary,
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Task name field
                            MegaTextField(
                              controller: _taskNameController,
                              label: 'Task Name',
                              hintText: 'e.g. Block A Manuring Cycle 2',
                              prefixIcon: const Icon(
                                Icons.assignment_outlined,
                                color: AppColors.mcTextMuted,
                                size: 20,
                              ),
                              validator: (v) => v == null || v.trim().isEmpty
                                  ? 'Task name is required'
                                  : null,
                            ),
                            const SizedBox(height: 16),

                            // Type of task selector
                            Text(
                              'Task Type',
                              style: AppTypography.labelLarge.copyWith(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.mcTextPrimary,
                              ),
                            ),
                            const SizedBox(height: 6),
                            InkWell(
                              borderRadius: BorderRadius.circular(10),
                              onTap: _showTaskTypePicker,
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 14,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: AppColors.mcBorder,
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.category_outlined,
                                          color: AppColors.mcTextMuted,
                                          size: 20,
                                        ),
                                        const SizedBox(width: 10),
                                        Text(
                                          _selectedType ?? 'Select task type...',
                                          style: AppTypography.bodyMedium
                                              .copyWith(
                                            color: _selectedType == null
                                                ? AppColors.mcTextMuted
                                                : AppColors.mcTextPrimary,
                                            fontWeight: _selectedType == null
                                                ? FontWeight.normal
                                                : FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const Icon(
                                      Icons.keyboard_arrow_down_rounded,
                                      color: AppColors.mcTextMuted,
                                      size: 22,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Date picker selector
                            Text(
                              'Task Scheduled Date',
                              style: AppTypography.labelLarge.copyWith(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.mcTextPrimary,
                              ),
                            ),
                            const SizedBox(height: 6),
                            InkWell(
                              borderRadius: BorderRadius.circular(10),
                              onTap: _showDatePicker,
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 14,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: AppColors.mcBorder,
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.calendar_today_outlined,
                                          color: AppColors.mcTextMuted,
                                          size: 19,
                                        ),
                                        const SizedBox(width: 10),
                                        Text(
                                          _selectedDate == null
                                              ? 'Select date...'
                                              : _selectedDate!
                                                  .toIso8601String()
                                                  .split('T')
                                                  .first,
                                          style: AppTypography.bodyMedium
                                              .copyWith(
                                            color: _selectedDate == null
                                                ? AppColors.mcTextMuted
                                                : AppColors.mcTextPrimary,
                                            fontWeight: _selectedDate == null
                                                ? FontWeight.normal
                                                : FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const Icon(
                                      Icons.event_rounded,
                                      color: AppColors.mcTextMuted,
                                      size: 20,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (_error != null) ...[
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
                            _error!,
                            style: AppTypography.caption.copyWith(
                              color: AppColors.mcStatusRed,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 24),
                      MegaButton(
                        label: 'Create Task',
                        isLoading: _isSubmitting,
                        onPressed: _isSubmitting ? null : _submit,
                        icon: const Icon(
                          Icons.add_task_rounded,
                          color: Colors.white,
                          size: 20,
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
