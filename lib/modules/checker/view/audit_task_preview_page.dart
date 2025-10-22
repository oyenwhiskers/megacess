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
  
  // Helper function to capitalize a string
  String _capitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1);
  }
  
  // Helper function to format meta keys for display
  String _formatMetaKey(String key) {
    // Replace underscores with spaces
    String formatted = key.replaceAll('_', ' ');
    
    // Capitalize each word
    List<String> words = formatted.split(' ');
    words = words.map((word) => _capitalize(word)).toList();
    
    // Join the words back together
    return words.join(' ');
  }

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
    Color backgroundColor;
    Color textColor;
    String label;
    switch (status.toLowerCase()) {
      case 'in_progress':
        backgroundColor = Colors.blue;
        textColor = Colors.white;
        label = 'In-progress';
        break;
      case 'completed':
        backgroundColor = Colors.green;
        textColor = Colors.white;
        label = 'Completed';
        break;
      case 'pending':
        backgroundColor = Colors.amber; // Yellow background as shown in the image
        textColor = Colors.black; // Black text for better contrast on yellow
        label = 'Pending';
        break;
      default:
        backgroundColor = Colors.grey;
        textColor = Colors.white;
        label = status;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16), // More rounded corners
      ),
      child: Text(label, style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 13)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD9D9D9),
      appBar: AppBar(
        backgroundColor: const Color(0xFF7ED957),
        elevation: 0,
        title: const Text('Audit Task', style: TextStyle(color: Colors.black)),
        iconTheme: const IconThemeData(color: Colors.black),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text('Error: $_error'))
              : _task == null
                  ? const Center(child: Text('No data found.'))
                  : SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 16), // Add some space at the top
                          // Task header - simpler design as in the image
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _task!.taskName,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 24,
                                        color: Colors.black,
                                      ),
                                    ),
                                    Text(
                                      _task!.taskType,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        color: Colors.black54,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              _buildStatusBadge(_task!.taskStatus),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Created by:',
                            style: const TextStyle(fontSize: 14, color: Colors.black),
                          ),
                          Text(
                            _task!.createdBy.name,
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Created at:',
                            style: const TextStyle(fontSize: 14, color: Colors.black),
                          ),
                          Text(
                            _task!.taskDate,
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 16),
                          const Text('Worker details:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          const SizedBox(height: 8),
                          ..._task!.workers.map((worker) => Container(
                                margin: const EdgeInsets.only(bottom: 10),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 2)],
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: 50,
                                      height: 50,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(color: Colors.grey.shade300),
                                        color: Colors.white,
                                      ),
                                      child: const Center(
                                        child: Icon(Icons.person_outline, color: Colors.black, size: 30),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text('Name: ${worker.fullName}', style: const TextStyle(fontSize: 14)),
                                          // Dynamically display all meta fields
                                          ...worker.meta.entries.map((entry) {
                                            final String formattedKey = _formatMetaKey(entry.key);
                                            return Text(
                                              '$formattedKey: ${entry.value}',
                                              style: const TextStyle(fontSize: 14),
                                            );
                                          }).toList(),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              )),
                          const SizedBox(height: 18),
                          const Text('Evidence:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          const SizedBox(height: 4),
                          const Text('Media(insert at least one):', style: TextStyle(fontSize: 13, color: Colors.black54)),
                          const SizedBox(height: 8),
                          Container(
                            height: 180,
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: [
                                  // Image 1
                                  Container(
                                    width: 160,
                                    height: 160,
                                    margin: const EdgeInsets.only(right: 12),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: Colors.grey.shade300),
                                    ),
                                    child: const Center(
                                      child: Icon(Icons.image, size: 32, color: Colors.grey),
                                    ),
                                  ),
                                  // Image 2
                                  Container(
                                    width: 160,
                                    height: 160,
                                    margin: const EdgeInsets.only(right: 12),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: Colors.grey.shade300),
                                    ),
                                    child: const Center(
                                      child: Icon(Icons.image, size: 32, color: Colors.grey),
                                    ),
                                  ),
                                  // Image 3
                                  Container(
                                    width: 160,
                                    height: 160,
                                    margin: const EdgeInsets.only(right: 12),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: Colors.grey.shade300),
                                    ),
                                    child: const Center(
                                      child: Icon(Icons.image, size: 32, color: Colors.grey),
                                    ),
                                  ),
                                  // Video
                                  Container(
                                    width: 160,
                                    height: 160,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: Colors.grey.shade300),
                                    ),
                                    child: const Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        Icon(Icons.video_library, size: 32, color: Colors.grey),
                                        Positioned(
                                          bottom: 10,
                                          child: Text(
                                            "Video",
                                            style: TextStyle(color: Colors.black54),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          Row(
                            children: [
                              Expanded(
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
                                  child: const Text('Task Rejected', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF7ED957),
                                    foregroundColor: Colors.white,
                                    minimumSize: const Size.fromHeight(44),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    elevation: 0,
                                  ),
                                  onPressed: () {},
                                  child: const Text('Task Approved', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: Colors.black,
                                    minimumSize: const Size.fromHeight(44),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    elevation: 0,
                                  ),
                                  onPressed: () {},
                                  child: const Text('Save', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
    );
  }
}
