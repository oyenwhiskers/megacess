import 'package:flutter/material.dart';
import 'package:megacess/modules/checker/data/model/audit_task_preview_model.dart';
import 'package:megacess/modules/checker/data/service/attendance_service.dart';
import 'package:megacess/modules/utility/secure_storage_service.dart';

class AuditTaskPreviewPage extends StatefulWidget {
  final int taskId;
  const AuditTaskPreviewPage({Key? key, required this.taskId}) : super(key: key);

  @override
  State<AuditTaskPreviewPage> createState() => _AuditTaskPreviewPageState();
}

class _AuditTaskPreviewPageState extends State<AuditTaskPreviewPage> {
  bool _isLoading = true;
  String? _error;
  AuditTaskPreviewModel? _task;

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
      final response = await AttendanceService(SecureStorageService()).fetchAuditTaskPreview(widget.taskId);
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
      child: Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD9D9D9),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.only(top: 32, left: 16, right: 16, bottom: 18),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF43C463), Color(0xFFB2F7EF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(32),
              bottomRight: Radius.circular(32),
            ),
          ),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () => Navigator.of(context).pop(),
              ),
              const SizedBox(width: 8),
              const Text('Audit Task', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 18)),
            ],
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text('Error: $_error'))
              : _task == null
                  ? const Center(child: Text('No data found.'))
                  : SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(_task!.taskName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
                                    Text(_task!.taskType, style: const TextStyle(fontSize: 15, color: Colors.black54)),
                                  ],
                                ),
                              ),
                              _buildStatusBadge(_task!.taskStatus),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text('Created by:', style: const TextStyle(fontSize: 14, color: Colors.black54)),
                          Text(_task!.createdBy.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                          const SizedBox(height: 2),
                          Text('Created at: ${_task!.taskDate}', style: const TextStyle(fontSize: 13, color: Colors.black54)),
                          const SizedBox(height: 18),
                          const Text('Worker details:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          const SizedBox(height: 8),
                          ..._task!.workers.map((worker) => Container(
                                margin: const EdgeInsets.only(bottom: 10),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 2)],
                                ),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: Colors.green[100],
                                    child: const Icon(Icons.person, color: Colors.green),
                                  ),
                                  title: Text('Name: ${worker.fullName}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      if (worker.meta['fertilizer_type'] != null)
                                        Text('Fertilizer took: ${worker.meta['fertilizer_type']}', style: const TextStyle(fontSize: 13)),
                                      if (worker.meta['fertilizer_amount'] != null)
                                        Text('Amount (bags): ${worker.meta['fertilizer_amount']}', style: const TextStyle(fontSize: 13)),
                                    ],
                                  ),
                                ),
                              )),
                          const SizedBox(height: 18),
                          const Text('Evidence:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          const SizedBox(height: 4),
                          const Text('Media(insert at least one):', style: TextStyle(fontSize: 13, color: Colors.black54)),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.grey.shade300),
                                ),
                                child: const Icon(Icons.camera_alt, size: 32, color: Colors.grey),
                              ),
                              const SizedBox(width: 12),
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.grey.shade300),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 18),
                          Center(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                                minimumSize: const Size.fromHeight(44),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                elevation: 0,
                              ),
                              onPressed: () {},
                              child: const Text('Task Rejected', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            ),
                          ),
                        ],
                      ),
                    ),
    );
  }
}
