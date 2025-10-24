import 'package:flutter/material.dart';
import 'package:megacess/modules/checker/data/model/audit_task_model.dart';
import 'package:megacess/modules/checker/data/service/attendance_service.dart';
import 'package:megacess/modules/utility/secure_storage_service.dart';
import 'package:megacess/modules/checker/view/audit_task_preview_page.dart';

class ManageAuditTaskPage extends StatefulWidget {
  final int locationId;
  final String locationName;
  const ManageAuditTaskPage({
    Key? key,
    required this.locationId,
    required this.locationName,
  }) : super(key: key);

  @override
  State<ManageAuditTaskPage> createState() => _ManageAuditTaskPageState();
}

class _ManageAuditTaskPageState extends State<ManageAuditTaskPage> {
  bool _isLoading = true;
  bool _isRefreshing = false;
  String? _error;
  AuditTaskLocationDetail? _location;
  List<AuditTaskModel> _tasks = [];
  List<AuditTaskModel> _filteredTasks = [];
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

    // Add listener to search controller for real-time filtering
    _searchController.addListener(_filterTasks);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterTasks);
    _searchController.dispose();
    super.dispose();
  }

  void _filterTasks() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredTasks = _tasks.where((task) {
        // Filter by search query
        bool matchesSearch =
            query.isEmpty || task.taskName.toLowerCase().contains(query);

        // Filter by task type
        bool matchesTaskType =
            _selectedTaskType == null ||
            task.taskType.toLowerCase() == _selectedTaskType!.toLowerCase();

        // Filter by status
        bool matchesStatus =
            _selectedStatus == null ||
            task.taskStatus.toLowerCase() ==
                _selectedStatus!.toLowerCase().replaceAll('-', '_');

        return matchesSearch && matchesTaskType && matchesStatus;
      }).toList();
    });
  }

  void _applyFilters() {
    _filterTasks();
    setState(() {
      _showFilterOptions = false;
    });
  }

  void _resetFilters() {
    setState(() {
      _selectedTaskType = null;
      _selectedStatus = null;
    });
    _filterTasks();
  }

  Future<void> _fetchDetail() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final response = await AttendanceService(
        SecureStorageService(),
      ).fetchAuditLocationTasks(widget.locationId);
      _location = response.location;
      _tasks = response.tasks;
      _filteredTasks =
          response.tasks; // Initialize filtered tasks with all tasks

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

  Future<void> _refreshData() async {
    // Show loading indicator during refresh
    setState(() {
      _isRefreshing = true;
    });
    
    try {
      final response = await AttendanceService(
        SecureStorageService(),
      ).fetchAuditLocationTasks(widget.locationId);
      setState(() {
        _location = response.location;
        _tasks = response.tasks;
        // Re-apply current filters to the updated task list
        _filterTasks();
        _isRefreshing = false;
      });
      return;
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isRefreshing = false;
      });
      return;
    }
  }

  Widget _buildTaskTypeBadge(String type) {
    Color color;
    IconData icon;
    String label;
    switch (type.toLowerCase()) {
      case 'manuring':
        color = Colors.green;
        icon = Icons.eco;
        label = 'Manuring';
        break;
      case 'pruning':
        color = Colors.orange;
        icon = Icons.content_cut;
        label = 'Pruning';
        break;
      case 'sanitation':
        color = Colors.yellow[800]!;
        icon = Icons.cleaning_services;
        label = 'Sanitation';
        break;
      case 'harvesting':
        color = Colors.brown;
        icon = Icons.agriculture;
        label = 'Harvesting';
        break;
      case 'planting':
        color = Colors.teal;
        icon = Icons.grass;
        label = 'Planting';
        break;
      default:
        color = Colors.grey;
        icon = Icons.task;
        label = type;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
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

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Return true to indicate refresh is needed
        Navigator.of(context).pop(true);
        return false; // Prevent default pop behavior since we're handling it
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFD9D9D9),
        appBar: AppBar(
          backgroundColor: const Color(0xFF7ED957),
          elevation: 0,
          title: const Text(
            'Manage Audit Task',
            style: TextStyle(color: Colors.black),
          ),
          iconTheme: const IconThemeData(color: Colors.black),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.of(context).pop(true);
            },
          ),
        actions: [
          if (_selectedTaskType != null || _selectedStatus != null)
            IconButton(
              icon: const Icon(Icons.filter_alt),
              color: Colors.white,
              onPressed: _resetFilters,
              tooltip: 'Reset Filters',
            ),
        ],
      ),
      body: Stack(
        children: [
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
              ? Center(child: Text('Error: $_error'))
              : Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Location: ',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            _location?.name ?? widget.locationName,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.green[700],
                            ),
                          ),
                          const Spacer(),
                          Text('Total Tasks: ', style: TextStyle(fontSize: 14)),
                          Text(
                            '${_tasks.length}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _searchController,
                                decoration: InputDecoration(
                                  hintText: 'Enter task name..',
                                  border: InputBorder.none,
                                  isDense: true,
                                  prefixIcon: Icon(
                                    Icons.search,
                                    color: Colors.grey[700],
                                  ),
                                  suffixIcon: _searchController.text.isNotEmpty
                                      ? IconButton(
                                          icon: const Icon(
                                            Icons.clear,
                                            size: 20,
                                          ),
                                          onPressed: () {
                                            _searchController.clear();
                                          },
                                        )
                                      : null,
                                ),
                                style: const TextStyle(fontSize: 14),
                              ),
                            ),
                            const SizedBox(width: 8),
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  _showFilterOptions = !_showFilterOptions;
                                });
                              },
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: Size(60, 30),
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: Row(
                                children: [
                                  Text(
                                    'Filter',
                                    style: TextStyle(color: Colors.black87),
                                  ),
                                  Icon(
                                    Icons.filter_list,
                                    color: Colors.black87,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Filter options panel
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        height: _showFilterOptions ? 280 : 0,
                        decoration: BoxDecoration(
                          color: const Color(
                            0xFFB5EDA4,
                          ), // Light green background
                          borderRadius: BorderRadius.circular(15),
                        ),
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: _showFilterOptions ? 16 : 0,
                        ),
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.arrow_back),
                                    onPressed: () {
                                      setState(() {
                                        _showFilterOptions = false;
                                      });
                                    },
                                  ),
                                  const Text(
                                    'Filter Options',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'Select task type:',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 10,
                                runSpacing: 10,
                                children: _taskTypes.map((type) {
                                  bool isSelected = _selectedTaskType == type;
                                  return InkWell(
                                    onTap: () {
                                      setState(() {
                                        _selectedTaskType = isSelected
                                            ? null
                                            : type;
                                      });
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          color: isSelected
                                              ? Colors.green
                                              : Colors.grey.shade300,
                                          width: 2,
                                        ),
                                        boxShadow: [
                                          if (isSelected)
                                            BoxShadow(
                                              color: Colors.black.withOpacity(
                                                0.1,
                                              ),
                                              blurRadius: 4,
                                              offset: Offset(0, 2),
                                            ),
                                        ],
                                      ),
                                      child: Text(type),
                                    ),
                                  );
                                }).toList(),
                              ),
                              const SizedBox(height: 16),
                              const Divider(),
                              const SizedBox(height: 10),
                              const Text(
                                'Select status',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 10,
                                runSpacing: 10,
                                children: _statusOptions.map((status) {
                                  bool isSelected = _selectedStatus == status;
                                  return InkWell(
                                    onTap: () {
                                      setState(() {
                                        _selectedStatus = isSelected
                                            ? null
                                            : status;
                                      });
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          color: isSelected
                                              ? Colors.green
                                              : Colors.grey.shade300,
                                          width: 2,
                                        ),
                                        boxShadow: [
                                          if (isSelected)
                                            BoxShadow(
                                              color: Colors.black.withOpacity(
                                                0.1,
                                              ),
                                              blurRadius: 4,
                                              offset: Offset(0, 2),
                                            ),
                                        ],
                                      ),
                                      child: Text(status),
                                    ),
                                  );
                                }).toList(),
                              ),
                              const SizedBox(height: 16),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: Colors.black,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                  ),
                                  onPressed: _applyFilters,
                                  child: const Text(
                                    'Confirm',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'List of existing tasks',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: _filteredTasks.isEmpty
                            ? Center(
                                child: Text(
                                  _searchController.text.isEmpty
                                      ? 'No tasks found.'
                                      : 'No matching tasks found for "${_searchController.text}"',
                                ),
                              )
                            : RefreshIndicator(
                                onRefresh: _refreshData,
                                child: ListView.separated(
                                  itemCount: _filteredTasks.length,
                                  separatorBuilder: (_, __) =>
                                      const SizedBox(height: 12),
                                  itemBuilder: (context, idx) {
                                    final task = _filteredTasks[idx];
                                    return InkWell(
                                      onTap: () async {
                                        final result = await Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                AuditTaskPreviewPage(
                                                  taskId: task.id,
                                                ),
                                          ),
                                        );
                                        // If task was approved successfully, refresh the list
                                        if (result == true) {
                                          _refreshData();
                                        }
                                      },
                                      borderRadius: BorderRadius.circular(16),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black12,
                                              blurRadius: 3,
                                            ),
                                          ],
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 12,
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                _buildTaskTypeBadge(
                                                  task.taskType,
                                                ),
                                                const Spacer(),
                                                _buildStatusBadge(
                                                  task.taskStatus,
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              task.taskName,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 18,
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              'Created at: ${task.createdAt.split(' ').first}  Created by: ${task.createdBy.name}',
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: Colors.black54,
                                              ),
                                            ),
                                          ],
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
          // Loading overlay when refreshing
          if (_isRefreshing)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF7ED957)),
                ),
              ),
            ),
        ],
      ),
      ),
    );
  }
}
