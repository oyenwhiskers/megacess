import 'package:flutter/material.dart';
import '../data/service/staff_service.dart';
import '../data/service/manager_dashboard_service.dart';
import '../data/model/staff_brief_model.dart';

class AddWorkerPage extends StatefulWidget {
  final int taskId;
  const AddWorkerPage({Key? key, required this.taskId}) : super(key: key);

  @override
  State<AddWorkerPage> createState() => _AddWorkerPageState();
}

class _AddWorkerPageState extends State<AddWorkerPage> {
  bool _isSubmitting = false;
  String? _submitError;
  List<StaffBriefModel> selectedWorkers = [];
  String? selectedFertilizerType;
  String? fertilizerAmount;
  final List<String> fertilizerTypes = ['MOP', 'BORATE', 'NPK', 'UREA'];
  List<StaffBriefModel> _allWorkers = [];
  bool _loadingWorkers = false;
  String? _errorWorkers;

  Future<void> _selectWorkers() async {
    setState(() { _loadingWorkers = true; });
    try {
      final staffModels = await StaffService().fetchClaimedStaff();
      final workers = staffModels.map((s) => StaffBriefModel(
        id: s.id,
        staffFullname: s.staffFullname,
        staffPhone: s.staffPhone,
        staffDob: s.staffDob,
        staffImg: s.staffImg,
        staffGender: s.staffGender,
      )).toList();
      setState(() { _allWorkers = workers; _loadingWorkers = false; });
      List<StaffBriefModel> tempSelected = List.from(selectedWorkers);
      await showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
        ),
        builder: (context) {
          return StatefulBuilder(
            builder: (context, setModalState) {
              return Padding(
                padding: const EdgeInsets.only(top: 18, left: 18, right: 18, bottom: 18),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('List of present workers', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 320,
                      child: ListView.separated(
                        itemCount: _allWorkers.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, idx) {
                          final w = _allWorkers[idx];
                          final selected = tempSelected.contains(w);
                          return GestureDetector(
                            onTap: () {
                              setModalState(() {
                                if (selected) {
                                  tempSelected.remove(w);
                                } else {
                                  tempSelected.add(w);
                                }
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 18),
                              decoration: BoxDecoration(
                                color: selected ? const Color(0xFF7ED957) : Colors.white,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: Colors.black12),
                                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 2)],
                              ),
                              child: Row(
                                children: [
                                  const CircleAvatar(backgroundColor: Color(0xFFD9D9D9), child: Icon(Icons.person, color: Colors.grey)),
                                  const SizedBox(width: 16),
                                  Expanded(child: Text('Name: ${w.staffFullname}', style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 16))),
                                  if (selected)
                                    const Icon(Icons.check_circle, color: Colors.green),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 18),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          elevation: 0,
                        ),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text('Confirm', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      );
      setState(() { selectedWorkers = List.from(tempSelected); });
    } catch (e) {
      setState(() { _loadingWorkers = false; });
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
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            const Text('Manuring & Packing:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 24),
            const Text('Workers:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            GestureDetector(
              onTap: _selectWorkers,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.black12),
                ),
                child: _loadingWorkers
                    ? Row(
                        children: [
                          const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          const SizedBox(width: 12),
                          const Text('Loading workers...', style: TextStyle(color: Colors.black54, fontStyle: FontStyle.italic)),
                        ],
                      )
                    : selectedWorkers.isEmpty
                        ? Row(
                            children: [
                              const Icon(Icons.person_outline, color: Colors.black26),
                              const SizedBox(width: 8),
                              const Text('Tap to select workers', style: TextStyle(color: Colors.black54, fontStyle: FontStyle.italic)),
                            ],
                          )
                        : Wrap(
                            spacing: 8,
                            runSpacing: 4,
                            children: selectedWorkers.map((w) => Chip(
                              label: Text(w.staffFullname),
                              backgroundColor: const Color(0xFF7ED957),
                            )).toList(),
                          ),
              ),
            ),
            const SizedBox(height: 18),
            const Text('Type of fertilizer used:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButton<String>(
                value: selectedFertilizerType,
                isExpanded: true,
                underline: const SizedBox(),
                hint: const Text('Select one..'),
                items: fertilizerTypes.map((f) => DropdownMenuItem(value: f, child: Text(f))).toList(),
                onChanged: (val) => setState(() => selectedFertilizerType = val),
              ),
            ),
            const SizedBox(height: 18),
            const Text('Amount of fertilizer used (kg):', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: TextField(
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Enter amount..',
                ),
                onChanged: (val) => fertilizerAmount = val,
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  elevation: 0,
                ),
                onPressed: _isSubmitting
                    ? null
                    : () async {
                        setState(() { _isSubmitting = true; _submitError = null; });
                        try {
                          // Send only worker IDs as required by backend
                          final workerIds = selectedWorkers.map((w) => w.id).toList();
                          final service = ManagerDashboardService();
                          final response = await service.assignWorkersToTask(
                            taskId: widget.taskId,
                            workerIds: workerIds,
                          );
                          if (response != null && response['success'] == true) {
                            if (mounted) {
                              showDialog(
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
                                          const Text('Worker successfully added!', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
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
                              Navigator.of(context).pop(true);
                            }
                          } else {
                            setState(() { _submitError = response?['message'] ?? 'Failed to assign workers.'; });
                          }
                        } catch (e) {
                          setState(() { _submitError = e.toString(); });
                        } finally {
                          setState(() { _isSubmitting = false; });
                        }
                      },
                child: _isSubmitting
                    ? const SizedBox(height: 18, child: Center(child: CircularProgressIndicator(strokeWidth: 2)))
                    : const Text('Confirm', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
