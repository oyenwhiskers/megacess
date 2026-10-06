import 'logs_tab_view.dart';
import 'package:flutter/material.dart';
import 'package:megacess/core/theme/app_colors.dart';
import 'package:megacess/core/theme/app_typography.dart';
import 'package:megacess/core/widgets/mega_app_header.dart';
import 'package:megacess/core/widgets/mega_status_badge.dart';
import '../data/service/manager_dashboard_service.dart';
import 'add_worker_page.dart';
import '../data/model/task_preview_model.dart';

class TaskPreviewPage extends StatefulWidget {
  final int taskId;
  const TaskPreviewPage({super.key, required this.taskId});

  @override
  State<TaskPreviewPage> createState() => _TaskPreviewPageState();
}

class _TaskPreviewPageState extends State<TaskPreviewPage> {
  final ManagerDashboardService _service = ManagerDashboardService();
  bool _isLoading = true;
  String? _error;
  TaskPreviewModel? _task;

  @override
  void initState() {
    super.initState();
    _fetchDetail();
  }

  Future<void> _fetchDetail() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final response = await _service.fetchTaskPreview(widget.taskId);
      if (response != null && mounted) {
        _task = response;
      }
      if (mounted) {
        setState(() {
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

  Widget _buildWorkerCard(TaskWorkerModel worker) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.mcBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 20,
            backgroundColor: AppColors.frond50,
            child: Icon(Icons.person_outline, color: AppColors.mcForestGreen, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Name: ${worker.fullName}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                ...worker.meta.entries.map(
                  (e) => Text(
                    '${_capitalize(e.key)}: ${e.value}',
                    style: const TextStyle(fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => Dialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Remove Worker',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Remove ${worker.fullName} from this task?',
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 14),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: Colors.black,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    side: const BorderSide(color: Colors.grey),
                                  ),
                                  elevation: 0,
                                ),
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Cancel'),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  elevation: 0,
                                ),
                                onPressed: () {
                                  Navigator.pop(context);
                                  _removeWorkerFromTask(
                                    worker.id,
                                    worker.fullName,
                                  );
                                },
                                child: const Text('Remove'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  String _capitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1).replaceAll('_', ' ');
  }

  Future<void> _removeWorkerFromTask(int workerId, String workerName) async {
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final result = await _service.removeWorkersFromTask(
        taskId: widget.taskId,
        workerIds: [workerId],
      );

      // Pop the loading dialog
      Navigator.pop(context);

      // Handle different response status codes
      switch (result['statusCode']) {
        case 200:
          if (result['data']['success'] == true) {
            // Update the task with the new data
            if (result['data']['data'] != null) {
              setState(() {
                _task = TaskPreviewModel.fromJson(result['data']['data']);
              });
            } else {
              // Fetch updated task details
              _fetchDetail();
            }

            // Show success message
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('$workerName removed successfully!'),
                backgroundColor: Colors.green,
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  result['data']['message'] ?? 'Failed to remove worker.',
                ),
                backgroundColor: Colors.red,
              ),
            );
          }
          break;
        case 401:
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Unauthorized. Please log in again.'),
              backgroundColor: Colors.red,
            ),
          );
          break;
        case 404:
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Task or worker not found.'),
              backgroundColor: Colors.red,
            ),
          );
          break;
        case 422:
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['data']['message'] ?? 'Validation error.'),
              backgroundColor: Colors.orange,
            ),
          );
          break;
        case 500:
        default:
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                result['data']['message'] ?? 'Failed to remove worker.',
              ),
              backgroundColor: Colors.red,
            ),
          );
          break;
      }
    } catch (e) {
      // Pop the loading dialog
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _showEditTaskDialog() async {
    // Create text controllers for the form fields
    final taskNameController = TextEditingController(
      text: _task?.taskName ?? '',
    );
    final taskDateController = TextEditingController(
      text: _task?.taskDate ?? '',
    );
    String? selectedTaskType = _task?.taskType;

    // Define task types
    final taskTypes = [
      'manuring',
      'sanitation',
      'pruning',
      'harvesting',
      'planting',
    ];

    // Create a form key for validation
    final formKey = GlobalKey<FormState>();

    // Show dialog with form
    await showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: StatefulBuilder(
            builder: (context, setStateDialog) {
              return Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Edit Task',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Task Name field
                      const Text(
                        'Task Name:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: taskNameController,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.grey[200],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                          hintText: 'Enter task name',
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Task name is required';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),

                      // Task Type dropdown
                      const Text(
                        'Task Type:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.transparent),
                        ),
                        child: DropdownButtonFormField<String>(
                          initialValue: selectedTaskType,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                          ),
                          isExpanded: true,
                          hint: const Text('Select task type'),
                          items: taskTypes
                              .map(
                                (type) => DropdownMenuItem(
                                  value: type,
                                  child: Text(_capitalize(type)),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            setStateDialog(() {
                              selectedTaskType = value;
                            });
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Task type is required';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Task Date field
                      const Text(
                        'Task Date:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: taskDateController,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.grey[200],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                          hintText: 'YYYY-MM-DD',
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.calendar_today),
                            onPressed: () async {
                              final date = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime(2020),
                                lastDate: DateTime(2030),
                              );
                              if (date != null) {
                                final formattedDate =
                                    "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
                                taskDateController.text = formattedDate;
                              }
                            },
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Task date is required';
                          }

                          // Simple date validation (YYYY-MM-DD)
                          final RegExp dateRegex = RegExp(
                            r'^\d{4}-\d{2}-\d{2}$',
                          );
                          if (!dateRegex.hasMatch(value)) {
                            return 'Invalid date format (YYYY-MM-DD)';
                          }

                          return null;
                        },
                      ),
                      const SizedBox(height: 24),

                      // Action buttons
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.black,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  side: BorderSide(color: Colors.grey.shade300),
                                ),
                                elevation: 0,
                              ),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: const Text(
                                'Cancel',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.mcForestGreen,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                elevation: 0,
                              ),
                              onPressed: () {
                                if (formKey.currentState!.validate()) {
                                  Navigator.of(context).pop({
                                    'taskName': taskNameController.text.trim(),
                                    'taskType': selectedTaskType,
                                    'taskDate': taskDateController.text.trim(),
                                  });
                                }
                              },
                              child: const Text(
                                'Update',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    ).then((result) async {
      if (result != null) {
        _updateTask(
          taskName: result['taskName'],
          taskType: result['taskType'],
          taskDate: result['taskDate'],
        );
      }
    });
  }

  Future<void> _updateTask({
    required String taskName,
    required String taskType,
    required String taskDate,
  }) async {
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final result = await _service.updateTask(
        widget.taskId,
        taskName: taskName,
        taskType: taskType,
        taskDate: taskDate,
      );

      // Pop the loading dialog
      Navigator.pop(context);

      // Handle different response status codes
      switch (result['statusCode']) {
        case 200:
          if (result['data']['success'] == true) {
            // Update the task with the new data
            if (result['data']['data'] != null) {
              setState(() {
                _task = TaskPreviewModel.fromJson(result['data']['data']);
              });
            } else {
              // Fetch updated task details
              _fetchDetail();
            }

            // Show success dialog
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) => Dialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircleAvatar(
                        backgroundColor: AppColors.statusCompletedBg,
                        radius: 30,
                        child: Icon(Icons.check, color: AppColors.statusCompletedText, size: 40),
                      ),
                      const SizedBox(height: 15),
                      const Text(
                        'Task updated successfully!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );

            // Automatically close the dialog after 1.5 seconds
            Future.delayed(const Duration(milliseconds: 1500), () {
              Navigator.pop(context); // Close the dialog
            });
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  result['data']['message'] ?? 'Failed to update task.',
                ),
                backgroundColor: Colors.red,
              ),
            );
          }
          break;
        case 401:
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Unauthorized. Please log in again.'),
              backgroundColor: Colors.red,
            ),
          );
          break;
        case 404:
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Task not found.'),
              backgroundColor: Colors.red,
            ),
          );
          break;
        case 500:
        default:
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                result['data']['message'] ?? 'Failed to update task.',
              ),
              backgroundColor: Colors.red,
            ),
          );
          break;
      }
    } catch (e) {
      // Pop the loading dialog
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _showDeleteConfirmation() async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Remove the following task?',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: const BorderSide(color: Colors.grey),
                          ),
                          elevation: 0,
                        ),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text('No'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.mcForestGreen,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 0,
                        ),
                        onPressed: () {
                          Navigator.of(context).pop();
                          _deleteTask();
                        },
                        child: const Text('Yes'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _deleteTask() async {
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final result = await _service.deleteTask(widget.taskId);
      // Pop the loading dialog
      Navigator.pop(context);

      // Handle different response status codes
      switch (result['statusCode']) {
        case 200:
          if (result['data']['success'] == true) {
            // Show custom success dialog that matches the design
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) => Dialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircleAvatar(
                        backgroundColor: AppColors.statusCompletedBg,
                        radius: 30,
                        child: Icon(Icons.check, color: AppColors.statusCompletedText, size: 40),
                      ),
                      const SizedBox(height: 15),
                      const Text(
                        'Task deleted successfully!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );

            // Automatically close the dialog and navigate back after 1.5 seconds
            Future.delayed(const Duration(milliseconds: 1500), () {
              Navigator.pop(context); // Close the dialog

              // Navigate back with refresh indicator
              Navigator.pop(context, true);
            });
          }
          break;
        case 401:
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Unauthorized. Please log in again.'),
              backgroundColor: Colors.red,
            ),
          );
          break;
        case 404:
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Task not found.'),
              backgroundColor: Colors.red,
            ),
          );
          break;
        case 500:
        default:
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                result['data']['message'] ?? 'Failed to delete task.',
              ),
              backgroundColor: Colors.red,
            ),
          );
          break;
      }
    } catch (e) {
      // Pop the loading dialog
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _submitTaskToChecker() async {
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final result = await _service.submitTaskToChecker(widget.taskId);
      // Pop the loading dialog
      Navigator.pop(context);

      // Handle different response status codes
      switch (result['statusCode']) {
        case 200:
          if (result['data']['success'] == true) {
            // Update the task with the new data
            setState(() {
              _task = TaskPreviewModel.fromJson(result['data']['data']);
            });

            // Show custom success dialog that matches the design
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) => Dialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircleAvatar(
                        backgroundColor: AppColors.statusCompletedBg,
                        radius: 30,
                        child: Icon(Icons.check, color: AppColors.statusCompletedText, size: 40),
                      ),
                      const SizedBox(height: 15),
                      const Text(
                        'Task submitted successfully!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );

            // Automatically close the dialog and navigate back after 1.5 seconds
            Future.delayed(const Duration(milliseconds: 1500), () {
              Navigator.pop(context); // Close the dialog

              // Navigate back to location_tasks_detail_page and refresh it
              Navigator.pop(context, true);
            });
          }
          break;
        case 401:
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Unauthorized. Please log in again.'),
              backgroundColor: Colors.red,
            ),
          );
          break;
        case 404:
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Task not found.'),
              backgroundColor: Colors.red,
            ),
          );
          break;
        case 422:
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                result['data']['message'] ??
                    'Task must be in progress to be submitted.',
              ),
              backgroundColor: Colors.orange,
            ),
          );
          break;
        case 500:
        default:
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                result['data']['message'] ?? 'Failed to submit task.',
              ),
              backgroundColor: Colors.red,
            ),
          );
          break;
      }
    } catch (e) {
      // Pop the loading dialog
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  int _tabIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.mcBgApp,
      appBar: MegaAppHeader(
        title: 'Task #${widget.taskId}',
        subtitle: _task?.taskName ?? 'Supervisor Inspection',
        showBackButton: true,
      ),
      body: Column(
        children: [
          // Segmented Tabs
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            color: Colors.white,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppColors.mcBgApp,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.mcBorder),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _tabIndex = 0),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: _tabIndex == 0 ? Colors.white : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: _tabIndex == 0
                              ? [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.04),
                                    blurRadius: 4,
                                    offset: const Offset(0, 1),
                                  ),
                                ]
                              : null,
                        ),
                        child: Center(
                          child: Text(
                            'Task Details',
                            style: TextStyle(
                              color: _tabIndex == 0
                                  ? AppColors.mcForestDark
                                  : AppColors.textSecondary,
                              fontWeight: _tabIndex == 0
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _tabIndex = 1),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: _tabIndex == 1 ? Colors.white : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: _tabIndex == 1
                              ? [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.04),
                                    blurRadius: 4,
                                    offset: const Offset(0, 1),
                                  ),
                                ]
                              : null,
                        ),
                        child: Center(
                          child: Text(
                            'Activity Logs',
                            style: TextStyle(
                              color: _tabIndex == 1
                                  ? AppColors.mcForestDark
                                  : AppColors.textSecondary,
                              fontWeight: _tabIndex == 1
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Content
          Expanded(
            child: _tabIndex == 0
                ? _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.mcForestGreen,
                          ),
                        ),
                      )
                    : _error != null
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.error_outline,
                                    color: AppColors.statusRejectedText,
                                    size: 48,
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    'Error: $_error',
                                    textAlign: TextAlign.center,
                                    style: AppTypography.bodyRegular.copyWith(
                                      color: AppColors.statusRejectedText,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.mcForestGreen,
                                      foregroundColor: Colors.white,
                                    ),
                                    onPressed: _fetchDetail,
                                    child: const Text('Retry'),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : SingleChildScrollView(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Header Card
                                Container(
                                  padding: const EdgeInsets.all(16),
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
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: AppColors.frond50,
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                              border: Border.all(
                                                color: AppColors.frond200,
                                              ),
                                            ),
                                            child: Text(
                                              (_task?.taskType ?? '').toUpperCase(),
                                              style: const TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w700,
                                                color: AppColors.mcForestGreen,
                                                letterSpacing: 0.5,
                                              ),
                                            ),
                                          ),
                                          MegaStatusBadge.fromString(
                                            _task?.taskStatus ?? '',
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        _task?.taskName ?? '',
                                        style: AppTypography.headingH3.copyWith(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.person_outline,
                                            size: 14,
                                            color: AppColors.textSecondary,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            'Created by: ${_task?.createdBy.name ?? '-'}',
                                            style: AppTypography.caption,
                                          ),
                                          const SizedBox(width: 12),
                                          const Icon(
                                            Icons.calendar_today_outlined,
                                            size: 14,
                                            color: AppColors.textSecondary,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            _task?.createdAt.split(' ').first ?? '',
                                            style: AppTypography.caption,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 18),

                                // Worker details header
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Assigned Workers (${_task?.workers.length ?? 0})',
                                      style: AppTypography.headingH4,
                                    ),
                                    if (_task?.taskStatus.toLowerCase() ==
                                            'in_progress')
                                      TextButton.icon(
                                        icon: const Icon(Icons.add, size: 16),
                                        label: const Text('Add Worker'),
                                        style: TextButton.styleFrom(
                                          foregroundColor:
                                              AppColors.mcForestGreen,
                                        ),
                                        onPressed: () async {
                                          final result = await Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => AddWorkerPage(
                                                taskId: widget.taskId,
                                              ),
                                            ),
                                          );
                                          if (result == true) {
                                            _fetchDetail();
                                          }
                                        },
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                ..._task?.workers.map(_buildWorkerCard) ?? [],
                                if ((_task?.workers.isEmpty ?? true)) ...[
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(24),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: AppColors.mcBorder),
                                    ),
                                    child: Center(
                                      child: Column(
                                        children: [
                                          const Icon(
                                            Icons.group_outlined,
                                            size: 40,
                                            color: AppColors.textDisabled,
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            'No workers assigned yet',
                                            style: AppTypography.caption,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                                const SizedBox(height: 20),

                                // Action Buttons
                                if (_task?.taskStatus.toLowerCase() ==
                                    'in_progress') ...[
                                  Row(
                                    children: [
                                      Expanded(
                                        child: OutlinedButton.icon(
                                          icon: const Icon(
                                            Icons.edit_outlined,
                                            size: 16,
                                          ),
                                          label: const Text('Edit Task'),
                                          style: OutlinedButton.styleFrom(
                                            foregroundColor: AppColors.mcForestDark,
                                            side: const BorderSide(
                                              color: AppColors.mcBorder,
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 14,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                          ),
                                          onPressed: _showEditTaskDialog,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: OutlinedButton.icon(
                                          icon: const Icon(
                                            Icons.delete_outline,
                                            size: 16,
                                          ),
                                          label: const Text('Delete Task'),
                                          style: OutlinedButton.styleFrom(
                                            foregroundColor:
                                                AppColors.statusRejectedText,
                                            side: const BorderSide(
                                              color: AppColors
                                                  .statusRejectedBorder,
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 14,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                          ),
                                          onPressed: _showDeleteConfirmation,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton.icon(
                                      icon: const Icon(
                                        Icons.send_outlined,
                                        size: 18,
                                      ),
                                      label: const Text('Submit to Checker'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            (_task?.workers.isNotEmpty ?? false)
                                                ? AppColors.mcForestGreen
                                                : Colors.grey.shade400,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 14,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                      ),
                                      onPressed:
                                          (_task?.workers.isNotEmpty ?? false)
                                              ? () => _submitTaskToChecker()
                                              : null,
                                    ),
                                  ),
                                ],
                                const SizedBox(height: 24),
                              ],
                            ),
                          )
                : LogsTabView(taskId: widget.taskId),
          ),
        ],
      ),
    );
  }
}
