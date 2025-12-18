import 'package:flutter/material.dart';
import '../data/service/manager_service.dart';
import '../data/model/manager_models.dart';

class ManageTasksView extends StatefulWidget {
  final int locationId;
  final String locationName;

  const ManageTasksView({
    Key? key,
    required this.locationId,
    required this.locationName,
  }) : super(key: key);

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

    // Add listener to search controller for real-time filtering
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
        // Filter by search query (worker name)
        bool matchesSearch =
            query.isEmpty || worker.workerName.toLowerCase().contains(query);

        // Filter by task type (check if worker has any task matching the type)
        bool matchesTaskType =
            _selectedTaskType == null ||
            worker.tasks.any(
              (task) =>
                  task.taskType.toLowerCase() ==
                  _selectedTaskType!.toLowerCase(),
            );

        // Filter by status (check if worker has any task matching the status)
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

  void _applyFilters() {
    _filterWorkers();
    setState(() {
      _showFilterOptions = false;
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.7,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF43C463),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(18),
                    topRight: Radius.circular(18),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            worker.workerName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            worker.workerPhone,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  padding: const EdgeInsets.all(16),
                  itemCount: worker.tasks.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final task = worker.tasks[index];
                    return Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              _buildTaskTypeBadge(task.taskType),
                              const Spacer(),
                              _buildStatusBadge(task.taskStatus),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            task.taskName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Icon(
                                Icons.calendar_today,
                                size: 14,
                                color: Colors.grey[600],
                              ),
                              const SizedBox(width: 4),
                              Text(
                                task.taskDate,
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          if (task.meta.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            const Divider(height: 1),
                            const SizedBox(height: 8),
                            ...task.meta.entries.map((entry) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 4),
                                child: Row(
                                  children: [
                                    Text(
                                      '${entry.key.replaceAll('_', ' ')}: ',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    Text(
                                      entry.value.toString(),
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
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
      _location = response.location;
      _workers = response.workers;
      _filteredWorkers =
          _workers; // Initialize filtered workers with all workers
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
    // Don't show the loading indicator during refresh
    try {
      final response = await _service.fetchLocationTasksBreakdown(
        widget.locationId,
      );
      setState(() {
        _location = response.location;
        _workers = response.workers;
        // Re-apply current filters to the updated workers list
        _filterWorkers();
      });
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 12,
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 11,
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
        backgroundColor: const Color(0xFF43C463),
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
                          Text(
                            'Total Workers: ',
                            style: TextStyle(fontSize: 14),
                          ),
                          Text(
                            '${_workers.length}',
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
                                  hintText: 'Enter worker name..',
                                  border: InputBorder.none,
                                  isDense: true,
                                  prefixIcon: Icon(
                                    Icons.search,
                                    color: Colors.grey[700],
                                  ),
                                  suffixIcon: _searchController.text.isNotEmpty
                                      ? IconButton(
                                          icon: Icon(Icons.clear),
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
                                        color: isSelected
                                            ? Colors.white
                                            : Colors.white.withOpacity(0.5),
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          color: isSelected
                                              ? Colors.green
                                              : Colors.grey.shade300,
                                          width: isSelected ? 2 : 1,
                                        ),
                                      ),
                                      child: Text(
                                        type,
                                        style: TextStyle(
                                          color: isSelected
                                              ? Colors.green
                                              : Colors.black87,
                                          fontWeight: isSelected
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                        ),
                                      ),
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
                                        color: isSelected
                                            ? Colors.white
                                            : Colors.white.withOpacity(0.5),
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          color: isSelected
                                              ? Colors.blue
                                              : Colors.grey.shade300,
                                          width: isSelected ? 2 : 1,
                                        ),
                                      ),
                                      child: Text(
                                        status,
                                        style: TextStyle(
                                          color: isSelected
                                              ? Colors.blue
                                              : Colors.black87,
                                          fontWeight: isSelected
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                        ),
                                      ),
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
                        'List of workers',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: _filteredWorkers.isEmpty
                            ? Center(
                                child: Text(
                                  _searchController.text.isEmpty
                                      ? 'No workers found.'
                                      : 'No matching workers found for "${_searchController.text}"',
                                ),
                              )
                            : RefreshIndicator(
                                onRefresh: _refreshData,
                                child: ListView.separated(
                                  itemCount: _filteredWorkers.length,
                                  separatorBuilder: (_, __) =>
                                      const SizedBox(height: 12),
                                  itemBuilder: (context, idx) {
                                    final worker = _filteredWorkers[idx];
                                    return InkWell(
                                      onTap: () async {
                                        // Show worker tasks detail
                                        _showWorkerTasksDialog(worker);
                                      },
                                      borderRadius: BorderRadius.circular(16),
                                      child: Container(
                                        padding: const EdgeInsets.all(14),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(
                                                0.08,
                                              ),
                                              blurRadius: 4,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Container(
                                                  width: 40,
                                                  height: 40,
                                                  decoration: BoxDecoration(
                                                    color: const Color(
                                                      0xFF43C463,
                                                    ),
                                                    shape: BoxShape.circle,
                                                  ),
                                                  child: Center(
                                                    child: Text(
                                                      '${idx + 1}',
                                                      style: const TextStyle(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 16,
                                                      ),
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
                                                        style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 15,
                                                        ),
                                                      ),
                                                      const SizedBox(height: 4),
                                                      Text(
                                                        worker.workerPhone,
                                                        style: const TextStyle(
                                                          color: Colors.grey,
                                                          fontSize: 12,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Container(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 12,
                                                        vertical: 6,
                                                      ),
                                                  decoration: BoxDecoration(
                                                    color: const Color(
                                                      0xFF43C463,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          20,
                                                        ),
                                                  ),
                                                  child: Text(
                                                    '${worker.totalTasks} tasks',
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            if (worker.tasks.isNotEmpty) ...[
                                              const SizedBox(height: 12),
                                              const Divider(height: 1),
                                              const SizedBox(height: 8),
                                              Wrap(
                                                spacing: 6,
                                                runSpacing: 6,
                                                children: worker.tasks.map((
                                                  task,
                                                ) {
                                                  return _buildTaskTypeBadge(
                                                    task.taskType,
                                                  );
                                                }).toList(),
                                              ),
                                            ],
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
        ],
      ),
    );
  }
}
