import 'package:flutter/material.dart';
import '../data/service/manager_dashboard_service.dart';

class AddNewTaskPage extends StatefulWidget {
  final int locationId;
  final String locationName;
  const AddNewTaskPage({Key? key, required this.locationId, required this.locationName}) : super(key: key);

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
    'Manuring & Packing',
    'Pruning',
    'Sanitation',
    'Harvesting',
    'Planting',
  ];

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || _selectedType == null || _selectedDate == null) return;
    setState(() { _isSubmitting = true; _error = null; });
    try {
      String typeValue;
      switch (_selectedType) {
        case 'Manuring & Packing':
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
      if (response != null && response['data'] != null && (response['statusCode'] == 200 || response['statusCode'] == 201)) {
        isSuccess = true;
      } else if (response != null) {
        if (response['success'] == true) {
          isSuccess = true;
        } else if (response['message'] != null && response['message'].toString().toLowerCase().contains('successfully')) {
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
                  width: 260,
                  padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.check_circle, color: Color(0xFF43C463), size: 56),
                      const SizedBox(height: 18),
                      const Text('Group Task successfully created!', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
                      const SizedBox(height: 18),
                      SizedBox(
                        width: 120,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF43C463),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            elevation: 0,
                          ),
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('OK', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
          Navigator.of(context).pop(true); // return success
        }
      } else {
        setState(() { _error = response?['message'] ?? 'Failed to create task.'; });
      }
    } catch (e) {
      setState(() { _error = e.toString(); });
    } finally {
      setState(() { _isSubmitting = false; });
    }
  }

  void _showTaskTypePicker() async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFF7ED957),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Text('Choose the type of task', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
              const SizedBox(height: 10),
              ..._taskTypes.map((type) => ListTile(
                title: Center(child: Text(type, style: const TextStyle(fontSize: 16))),
                onTap: () => Navigator.of(context).pop(type),
              )),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
    if (selected != null) {
      setState(() { _selectedType = selected; });
    }
  }

  void _showDatePicker() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(now.year - 2),
      lastDate: DateTime(now.year + 2),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: const Color(0xFF7ED957),
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() { _selectedDate = picked; });
    }
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                const Center(
                  child: Text('Add new task:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                ),
                const SizedBox(height: 18),
                const Text('Task name:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _taskNameController,
                  decoration: InputDecoration(
                    hintText: 'Enter task name..',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  ),
                  validator: (v) => v == null || v.trim().isEmpty ? 'Task name required' : null,
                ),
                const SizedBox(height: 18),
                const Text('Type of task:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                GestureDetector(
                  onTap: _showTaskTypePicker,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(_selectedType ?? 'Select one..', style: TextStyle(fontSize: 15, color: _selectedType == null ? Colors.grey : Colors.black)),
                  ),
                ),
                const SizedBox(height: 18),
                const Text('Date created:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                GestureDetector(
                  onTap: _showDatePicker,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(_selectedDate == null ? 'Select one..' : _selectedDate!.toIso8601String().split('T').first, style: TextStyle(fontSize: 15, color: _selectedDate == null ? Colors.grey : Colors.black)),
                  ),
                ),
                const SizedBox(height: 28),
                if (_error != null) ...[
                  Text(_error!, style: const TextStyle(color: Colors.red)),
                  const SizedBox(height: 10),
                ],
                Center(
                  child: SizedBox(
                    width: 180,
                    height: 44,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        side: const BorderSide(color: Colors.black12),
                      ),
                      onPressed: _isSubmitting ? null : _submit,
                      child: _isSubmitting
                          ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2))
                          : const Text('Confirm', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
