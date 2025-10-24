import 'logs_tab_view.dart';
import 'package:flutter/material.dart';
import '../data/service/manager_dashboard_service.dart';
import 'add_worker_page.dart';
import '../data/model/task_preview_model.dart';

class TaskPreviewPage extends StatefulWidget {
  final int taskId;
  const TaskPreviewPage({Key? key, required this.taskId}) : super(key: key);

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
      if (response != null) {
        _task = response;
      }
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    String label;
    switch (status.toLowerCase()) {
      case 'in_progress':
        color = Colors.blue;
        label = 'In-progress';
        break;
      case 'completed':
        color = Colors.green;
        label = 'Completed';
        break;
      case 'pending':
        color = Colors.orange;
        label = 'Pending';
        break;
      default:
        color = Colors.grey;
        label = status;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 13,
        ),
      ),
    );
  }

  Widget _buildWorkerCard(TaskWorkerModel worker) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 2)],
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 22,
            backgroundColor: Color(0xFFD9D9D9),
            child: Icon(Icons.person, color: Colors.grey, size: 28),
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
        ],
      ),
    );
  }

  String _capitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1).replaceAll('_', ' ');
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
                          value: selectedTaskType,
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
                                backgroundColor: const Color(0xFF7ED957),
                                foregroundColor: Colors.black,
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
                        backgroundColor: Color(0xFF7ED957),
                        radius: 30,
                        child: Icon(Icons.check, color: Colors.white, size: 40),
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
                          backgroundColor: const Color(0xFF7ED957),
                          foregroundColor: Colors.black,
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
                        backgroundColor: Color(0xFF7ED957),
                        radius: 30,
                        child: Icon(Icons.check, color: Colors.white, size: 40),
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
                        backgroundColor: Color(0xFF7ED957),
                        radius: 30,
                        child: Icon(Icons.check, color: Colors.white, size: 40),
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
      backgroundColor: const Color(0xFFD9D9D9),
      appBar: AppBar(
        backgroundColor: const Color(0xFF7ED957),
        elevation: 0,
        title: const Text(
          'Task Preview',
          style: TextStyle(color: Colors.black),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _tabIndex == 0
                          ? const Color(0xFF7ED957)
                          : Colors.white,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 0,
                    ),
                    onPressed: () => setState(() => _tabIndex = 0),
                    child: const Text(
                      'Details',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _tabIndex == 1
                          ? const Color(0xFF7ED957)
                          : Colors.white,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 0,
                    ),
                    onPressed: () => setState(() => _tabIndex = 1),
                    child: const Text(
                      'Logs',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _tabIndex == 0
                ? _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _error != null
                      ? Center(child: Text('Error: $_error'))
                      : SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 18,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          _task?.taskName ?? '',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 22,
                                          ),
                                        ),
                                        Text(
                                          _task?.taskType ?? '',
                                          style: const TextStyle(
                                            fontSize: 15,
                                            color: Colors.black54,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  _buildStatusBadge(_task?.taskStatus ?? ''),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Created by: ${_task?.createdBy.name ?? ''}',
                                style: const TextStyle(fontSize: 13),
                              ),
                              Text(
                                'Created at: ${_task?.createdAt.split(' ').first ?? ''}',
                                style: const TextStyle(fontSize: 13),
                              ),
                              const SizedBox(height: 18),
                              const Text(
                                'Worker details:',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              ..._task?.workers.map(_buildWorkerCard) ?? [],
                              const SizedBox(height: 12),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: _task?.taskStatus.toLowerCase() == 'pending'
                                        ? Colors.grey
                                        : const Color(0xFF7ED957),
                                    foregroundColor: Colors.black,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    elevation: 0,
                                  ),
                                  icon: const Icon(
                                    Icons.add,
                                    color: Colors.black,
                                  ),
                                  label: const Text(
                                    'Add worker',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  onPressed: _task?.taskStatus.toLowerCase() == 'pending'
                                      ? null
                                      : () async {
                                    final result = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => AddWorkerPage(
                                          taskId: widget.taskId,
                                        ),
                                      ),
                                    );
                                    if (result == true) {
                                      _fetchDetail(); // Refresh the task details
                                    }
                                  },
                                ),
                              ),
                              const SizedBox(height: 18),
                              Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.white,
                                        foregroundColor: Colors.black,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                        elevation: 0,
                                      ),
                                      onPressed:
                                          _task?.taskStatus.toLowerCase() ==
                                              'in_progress'
                                          ? _showEditTaskDialog
                                          : null,
                                      child: const Text(
                                        'Edit',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.white,
                                        foregroundColor: Colors.black,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                        elevation: 0,
                                      ),
                                      onPressed:
                                          _task?.taskStatus.toLowerCase() ==
                                              'in_progress'
                                          ? () => _submitTaskToChecker()
                                          : null,
                                      child: const Text(
                                        'Send to checker',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.white,
                                        foregroundColor: Colors.red,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                        elevation: 0,
                                      ),
                                      onPressed: _showDeleteConfirmation,
                                      child: const Text(
                                        'Remove',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
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
