import 'package:flutter/material.dart';
import '../data/service/manager_dashboard_service.dart';
import '../data/model/task_model.dart';
import 'add_new_task_page.dart';
import 'task_preview_page.dart';

class LocationTasksDetailPage extends StatefulWidget {
  final int locationId;
  final String locationName;
  const LocationTasksDetailPage({Key? key, required this.locationId, required this.locationName}) : super(key: key);

  @override
  State<LocationTasksDetailPage> createState() => _LocationTasksDetailPageState();
}

class _LocationTasksDetailPageState extends State<LocationTasksDetailPage> {
  final ManagerDashboardService _service = ManagerDashboardService();
  bool _isLoading = true;
  String? _error;
  LocationDetailModel? _location;
  List<TaskDetailModel> _tasks = [];

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
      final response = await _service.fetchLocationTasksDetail(widget.locationId);
      if (response != null) {
        _location = response.location;
        _tasks = response.tasks;
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
          Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 15)),
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
      child: Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD9D9D9),
      appBar: AppBar(
        backgroundColor: const Color(0xFF7ED957),
        elevation: 0,
        title: const Text('Manage Task', style: TextStyle(color: Colors.black)),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Stack(
        children: [
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
                  ? Center(child: Text('Error: $_error'))
                  : Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text('Location: ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              Text(_location?.name ?? widget.locationName, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.green[700])),
                              const Spacer(),
                              Text('Total Tasks: ', style: TextStyle(fontSize: 14)),
                              Text('${_location?.taskCount ?? 0}', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                const Text('Search task:', style: TextStyle(fontWeight: FontWeight.bold)),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: TextField(
                                    decoration: InputDecoration(
                                      hintText: 'Enter task name..',
                                      border: InputBorder.none,
                                      isDense: true,
                                    ),
                                    style: const TextStyle(fontSize: 14),
                                    // TODO: Implement search logic
                                  ),
                                ),
                                Icon(Icons.filter_alt_outlined, color: Colors.grey[700]),
                              ],
                            ),
                          ),
                          const SizedBox(height: 18),
                          const Text('List of existing tasks', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          const SizedBox(height: 8),
                          Expanded(
                            child: _tasks.isEmpty
                                ? const Center(child: Text('No tasks found.'))
                                : ListView.separated(
                                    itemCount: _tasks.length,
                                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                                    itemBuilder: (context, idx) {
                                      final task = _tasks[idx];
                                      return InkWell(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => TaskPreviewPage(taskId: task.id),
                                            ),
                                          );
                                        },
                                        borderRadius: BorderRadius.circular(16),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(16),
                                            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 3)],
                                          ),
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
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
                                              Text(task.taskName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                                              const SizedBox(height: 2),
                                              Text('Created at: ${task.createdAt.split(' ').first}  Created by: ${task.createdBy.name}', style: const TextStyle(fontSize: 12, color: Colors.black54)),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
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
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30), side: BorderSide(color: Colors.black12)),
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
