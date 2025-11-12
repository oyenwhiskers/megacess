import 'package:flutter/material.dart';
import '../data/service/manager_dashboard_service.dart';
import '../data/model/task_log_model.dart';

class LogsTabView extends StatefulWidget {
  final int taskId;
  const LogsTabView({Key? key, required this.taskId}) : super(key: key);

  @override
  State<LogsTabView> createState() => _LogsTabViewState();
}

class _LogsTabViewState extends State<LogsTabView> {
  final ManagerDashboardService _service = ManagerDashboardService();
  bool _isLoading = true;
  String? _error;
  List<TaskLogModel> _logs = [];

  @override
  void initState() {
    super.initState();
    _fetchLogs();
  }

  Future<void> _fetchLogs() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final logs = await _service.fetchTaskLogs(widget.taskId);
      setState(() {
        _logs = logs;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'in_progress':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  String _statusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return 'Approved';
      case 'rejected':
        return 'Rejected';
      case 'in_progress':
        return 'In-progress';
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? const Center(child: CircularProgressIndicator())
        : _error != null
        ? Center(child: Text('Error: $_error'))
        : _logs.isEmpty
        ? const Center(child: Text('No logs found.'))
        : ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
            itemCount: _logs.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, idx) {
              final log = _logs[idx];
              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: _statusColor(log.taskStatus),
                    width: 2,
                  ),
                ),
                child: Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
                      child: Text(
                        log.remarks,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Positioned(
                      right: 16,
                      bottom: 8,
                      child: Text(
                        log.createdAt.split(' ').first,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black54,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
  }
}
