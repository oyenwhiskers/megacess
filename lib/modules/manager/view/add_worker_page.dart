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
  String? _taskType;
  bool _isLoading = true;
  
  // Metadata fields
  String? selectedFertilizerType;
  String? fertilizerAmount;
  String? selectedPruningType;
  String? selectedHarvestingType;
  String? selectedSanitationType;
  String? herbicideAmount;
  String? fuelAmount;
  
  // Dropdown options
  final List<String> fertilizerTypes = ['MOP', 'BORATE', 'NPK', 'UREA'];
  final List<String> pruningTypes = ['normal pruning', 'routine pruning'];
  final List<String> harvestingTypes = ['normal harvesting', 'collect loose fruits'];
  final List<String> sanitationTypes = ['spraying', 'slashing'];
  
  List<StaffBriefModel> _allWorkers = [];
  bool _loadingWorkers = false;
  String? _errorWorkers;

  @override
  void initState() {
    super.initState();
    _fetchTaskDetails();
  }
  
  Future<void> _fetchTaskDetails() async {
    setState(() { _isLoading = true; });
    try {
      final task = await ManagerDashboardService().fetchTaskPreview(widget.taskId);
      if (task != null) {
        setState(() {
          _taskType = task.taskType;
          _isLoading = false;
        });
      } else {
        setState(() {
          _submitError = "Failed to load task details";
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _submitError = e.toString();
        _isLoading = false;
      });
    }
  }

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
      StaffBriefModel? singleSelected = selectedWorkers.isNotEmpty ? selectedWorkers.first : null;
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
                    const Text('Select worker', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 320,
                      child: ListView.separated(
                        itemCount: _allWorkers.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, idx) {
                          final w = _allWorkers[idx];
                          final selected = singleSelected == w;
                          return GestureDetector(
                            onTap: () {
                              setModalState(() {
                                if (selected) {
                                  singleSelected = null;
                                } else {
                                  singleSelected = w;
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
      setState(() { 
        selectedWorkers = singleSelected != null ? [singleSelected!] : [];
      });
    } catch (e) {
      setState(() { _loadingWorkers = false; });
    }
  }
  
  String _getTaskTitle() {
    switch (_taskType) {
      case 'manuring':
        return 'Manuring Task';
      case 'pruning':
        return 'Pruning Task';
      case 'harvesting':
        return 'Harvesting Task';
      case 'sanitation':
        return 'Sanitation Task';
      case 'planting':
        return 'Planting Task';
      default:
        return 'Task Details';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD9D9D9),
      appBar: AppBar(
        backgroundColor: const Color(0xFF7ED957),
        elevation: 0,
        title: Text(
          _isLoading ? 'Assign Worker' : 'Assign Worker - ${_taskType?.toUpperCase() ?? ''}', 
          style: const TextStyle(color: Colors.black)
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : _submitError != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 48),
                  const SizedBox(height: 16),
                  Text(_submitError!, style: const TextStyle(color: Colors.red)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _fetchTaskDetails,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            )
          : Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Text(
                  _getTaskTitle(),
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)
                ),
            const SizedBox(height: 24),
            const Text('Worker:', style: TextStyle(fontWeight: FontWeight.bold)),
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
                              const Text('Tap to select a worker', style: TextStyle(color: Colors.black54, fontStyle: FontStyle.italic)),
                            ],
                          )
                        : Row(
                            children: [
                              const Icon(Icons.person, color: Color(0xFF7ED957)),
                              const SizedBox(width: 8),
                              Text(selectedWorkers[0].staffFullname, 
                                   style: const TextStyle(fontWeight: FontWeight.w500)),
                            ],
                          ),
              ),
            ),
            const SizedBox(height: 18),
            
            // Metadata fields based on task type
            if (_isLoading)
              const Center(child: CircularProgressIndicator()),
              
            // Manuring task fields
            if (!_isLoading && _taskType == 'manuring') ...[
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
            ],
            
            // Pruning task fields
            if (!_isLoading && _taskType == 'pruning') ...[
              const Text('Type of pruning:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownButton<String>(
                  value: selectedPruningType,
                  isExpanded: true,
                  underline: const SizedBox(),
                  hint: const Text('Select pruning type..'),
                  items: pruningTypes.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                  onChanged: (val) => setState(() => selectedPruningType = val),
                ),
              ),
            ],
            
            // Harvesting task fields
            if (!_isLoading && _taskType == 'harvesting') ...[
              const Text('Type of harvesting:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownButton<String>(
                  value: selectedHarvestingType,
                  isExpanded: true,
                  underline: const SizedBox(),
                  hint: const Text('Select harvesting type..'),
                  items: harvestingTypes.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                  onChanged: (val) => setState(() => selectedHarvestingType = val),
                ),
              ),
            ],
            
            // Sanitation task fields
            if (!_isLoading && _taskType == 'sanitation') ...[
              const Text('Type of sanitation:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownButton<String>(
                  value: selectedSanitationType,
                  isExpanded: true,
                  underline: const SizedBox(),
                  hint: const Text('Select sanitation type..'),
                  items: sanitationTypes.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                  onChanged: (val) => setState(() => selectedSanitationType = val),
                ),
              ),
              const SizedBox(height: 18),
              
              // Additional fields based on sanitation type
              if (selectedSanitationType == 'spraying') ...[
                const Text('Amount of herbicide used:', style: TextStyle(fontWeight: FontWeight.bold)),
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
                      hintText: 'Enter herbicide amount..',
                    ),
                    onChanged: (val) => herbicideAmount = val,
                  ),
                ),
              ],
              
              if (selectedSanitationType == 'slashing') ...[
                const Text('Amount of fuel used:', style: TextStyle(fontWeight: FontWeight.bold)),
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
                      hintText: 'Enter fuel amount..',
                    ),
                    onChanged: (val) => fuelAmount = val,
                  ),
                ),
              ],
            ],
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
                onPressed: _isSubmitting || selectedWorkers.isEmpty
                    ? null
                    : () async {
                        // Validate fields based on task type
                        if (_taskType == 'manuring' && (selectedFertilizerType == null || fertilizerAmount == null)) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Please fill in all fertilizer fields')),
                          );
                          return;
                        }
                        
                        if (_taskType == 'pruning' && selectedPruningType == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Please select pruning type')),
                          );
                          return;
                        }
                        
                        if (_taskType == 'harvesting' && selectedHarvestingType == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Please select harvesting type')),
                          );
                          return;
                        }
                        
                        if (_taskType == 'sanitation' && selectedSanitationType == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Please select sanitation type')),
                          );
                          return;
                        }
                        
                        if (_taskType == 'sanitation' && selectedSanitationType == 'spraying' && herbicideAmount == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Please enter herbicide amount')),
                          );
                          return;
                        }
                        
                        if (_taskType == 'sanitation' && selectedSanitationType == 'slashing' && fuelAmount == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Please enter fuel amount')),
                          );
                          return;
                        }
                        
                        setState(() { _isSubmitting = true; _submitError = null; });
                        try {
                          // Prepare worker data with metadata
                          final workerId = selectedWorkers[0].id;
                          Map<String, dynamic> meta = {};
                          
                          // Set metadata based on task type
                          switch (_taskType) {
                            case 'manuring':
                              meta = {
                                'fertilizer_type': selectedFertilizerType,
                                'fertilizer_amount': fertilizerAmount,
                              };
                              break;
                            case 'pruning':
                              meta = {
                                'pruning_type': selectedPruningType,
                              };
                              break;
                            case 'harvesting':
                              meta = {
                                'harvesting_type': selectedHarvestingType,
                              };
                              break;
                            case 'sanitation':
                              if (selectedSanitationType == 'spraying') {
                                meta = {
                                  'sanitation_type': selectedSanitationType,
                                  'herbicide_amount': herbicideAmount,
                                };
                              } else if (selectedSanitationType == 'slashing') {
                                meta = {
                                  'sanitation_type': selectedSanitationType,
                                  'fuel_amount': fuelAmount,
                                };
                              }
                              break;
                            case 'planting':
                              // No meta required for planting
                              meta = {};
                              break;
                          }
                          
                          final workerData = [{
                            'staff_id': workerId,
                            'meta': meta,
                          }];
                          
                          final service = ManagerDashboardService();
                          final response = await service.assignWorkersToTask(
                            taskId: widget.taskId,
                            workers: workerData,
                          );
                          
                          if (response != null && response['success'] == true) {
                            if (mounted) {
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
                                          'Worker successfully added!',
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
                                Navigator.pop(context); // Close the success dialog
                                Navigator.pop(context, true); // Return to task_preview_page with refresh trigger
                              });
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
