import 'package:flutter/material.dart';
import '../data/service/manager_dashboard_service.dart';
import '../data/model/task_model.dart';
import 'add_new_task_page.dart';
import 'task_preview_page.dart';

class LocationTasksDetailPage extends StatefulWidget {
  final int locationId;
  final String locationName;
  const LocationTasksDetailPage({
    Key? key,
    required this.locationId,
    required this.locationName,
  }) : super(key: key);

  @override
  State<LocationTasksDetailPage> createState() =>
      _LocationTasksDetailPageState();
}

class _LocationTasksDetailPageState extends State<LocationTasksDetailPage> {
  final ManagerDashboardService _service = ManagerDashboardService();
  bool _isLoading = true;
  String? _error;
  LocationDetailModel? _location;
  List<TaskDetailModel> _tasks = [];
  List<TaskDetailModel> _filteredTasks = [];
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  // Pagination variables
  int _currentPage = 1;
  int _lastPage = 1;
  int _totalTasksFromServer = 0;
  bool _isLoadingMore = false;
  bool _hasMoreData = true;

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

    // Add listener to scroll controller for pagination
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterTasks);
    _searchController.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    // Don't load more if filters are active (filters work on client-side data only)
    bool hasActiveFilters = _selectedTaskType != null || _selectedStatus != null;
    
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !_isLoadingMore &&
        _hasMoreData &&
        !hasActiveFilters) {
      _loadMoreTasks();
    }
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
      _currentPage = 1;
      _hasMoreData = true;
    });
    try {
      final response = await _service.fetchLocationTasksDetail(
        widget.locationId,
        page: 1,
      );
      if (response != null) {
        _location = response.location;
        _tasks = response.tasks;
        _filteredTasks = response.tasks;
        
        // Update pagination info
        if (response.pagination != null) {
          _currentPage = response.pagination!.currentPage;
          _lastPage = response.pagination!.lastPage;
          _totalTasksFromServer = response.pagination!.total;
          _hasMoreData = _currentPage < _lastPage;
        }
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

  Future<void> _loadMoreTasks() async {
    if (_isLoadingMore || !_hasMoreData) return;

    setState(() {
      _isLoadingMore = true;
    });

    try {
      final nextPage = _currentPage + 1;
      final response = await _service.fetchLocationTasksDetail(
        widget.locationId,
        page: nextPage,
      );
      
      if (response != null && response.tasks.isNotEmpty) {
        setState(() {
          _tasks.addAll(response.tasks);
          
          // Update pagination info
          if (response.pagination != null) {
            _currentPage = response.pagination!.currentPage;
            _lastPage = response.pagination!.lastPage;
            _totalTasksFromServer = response.pagination!.total;
            _hasMoreData = _currentPage < _lastPage;
          }
          
          // Re-apply filters to include new tasks
          _filterTasks();
          _isLoadingMore = false;
        });
      } else {
        setState(() {
          _hasMoreData = false;
          _isLoadingMore = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoadingMore = false;
      });
    }
  }

  Future<void> _refreshData() async {
    // Reset pagination and reload from page 1
    setState(() {
      _currentPage = 1;
      _hasMoreData = true;
    });
    
    try {
      final response = await _service.fetchLocationTasksDetail(
        widget.locationId,
        page: 1,
      );
      if (response != null) {
        setState(() {
          _location = response.location;
          _tasks = response.tasks;
          
          // Update pagination info
          if (response.pagination != null) {
            _currentPage = response.pagination!.currentPage;
            _lastPage = response.pagination!.lastPage;
            _totalTasksFromServer = response.pagination!.total;
            _hasMoreData = _currentPage < _lastPage;
          }
          
          // Re-apply current filters to the updated task list
          _filterTasks();
        });
      }
      return;
    } catch (e) {
      setState(() {
        _error = e.toString();
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
    // Calculate if we have active filters
    bool hasActiveFilters =
        _selectedTaskType != null || _selectedStatus != null;

    return Scaffold(
      backgroundColor: const Color(0xFFD9D9D9),
      appBar: AppBar(
        backgroundColor: const Color(0xFF7ED957),
        elevation: 0,
        title: const Text('Manage Task', style: TextStyle(color: Colors.black)),
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          if (hasActiveFilters)
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
                          Text('Tasks: ', style: TextStyle(fontSize: 14)),
                          Text(
                            _totalTasksFromServer > 0
                                ? '${_tasks.length}/$_totalTasksFromServer'
                                : '${_tasks.length}',
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
                                  controller: _scrollController,
                                  itemCount: _filteredTasks.length + (_isLoadingMore ? 1 : 0),
                                  separatorBuilder: (_, __) =>
                                      const SizedBox(height: 12),
                                  itemBuilder: (context, idx) {
                                    // Show loading indicator at the bottom
                                    if (idx == _filteredTasks.length) {
                                      return const Padding(
                                        padding: EdgeInsets.symmetric(vertical: 16),
                                        child: Center(
                                          child: CircularProgressIndicator(),
                                        ),
                                      );
                                    }
                                    
                                    final task = _filteredTasks[idx];
                                    return InkWell(
                                      onTap: () async {
                                        final result = await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                TaskPreviewPage(
                                                  taskId: task.id,
                                                ),
                                          ),
                                        );

                                        // If returned with result true, refresh the page
                                        if (result == true) {
                                          _fetchDetail();
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
          Positioned(
            bottom: 18,
            right: 18,
            child: FloatingActionButton(
              backgroundColor: Colors.white,
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
                side: BorderSide(color: Colors.black12),
              ),
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddNewTaskPage(
                      locationId: widget.locationId,
                      locationName: widget.locationName,
                    ),
                  ),
                );
                if (result == true) {
                  _fetchDetail();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Task added successfully!')),
                  );
                }
              },
              child: const Icon(Icons.add, color: Colors.black, size: 32),
            ),
          ),
        ],
      ),
    );
  }
}
