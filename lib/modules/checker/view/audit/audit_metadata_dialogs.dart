import 'package:flutter/material.dart';
import 'package:megacess/core/theme/app_colors.dart';
import 'package:megacess/core/theme/app_typography.dart';
import 'package:megacess/modules/checker/data/model/audit_task_preview_model.dart';

/// Shows the appropriate metadata input dialog based on the task type.
/// Returns a map of "worker_id:task_type" -> value, or null if cancelled.
Future<Map<String, String>?> showAuditMetadataDialog({
  required BuildContext context,
  required AuditTaskPreviewModel task,
}) async {
  if (task.workers.isEmpty) {
    return <String, String>{};
  }

  final taskType = task.taskType.toLowerCase();

  if (taskType == 'sanitation') {
    return _showSanitationDialog(context, task);
  } else if (taskType == 'manuring') {
    return _showManuringDialog(context, task);
  } else if (taskType == 'harvesting') {
    return _showHarvestingDialog(context, task);
  } else if (taskType == 'pruning') {
    return _showPruningDialog(context, task);
  } else if (taskType == 'planting') {
    return _showPlantingDialog(context, task);
  } else {
    // For other task types, return empty map
    return <String, String>{};
  }
}

/// Generic dialog builder for worker metadata with Mantine v7 design styling
Future<Map<String, String>?> _showWorkerMetaModal({
  required BuildContext context,
  required String title,
  required String subtitle,
  required List<_WorkerTaskInputDef> inputDefs,
}) async {
  final Map<String, TextEditingController> controllers = {
    for (var def in inputDefs) def.key: TextEditingController(),
  };

  final formKey = GlobalKey<FormState>();

  final result = await showDialog<Map<String, String>>(
    context: context,
    barrierDismissible: false,
    builder: (dialogCtx) {
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 480, maxHeight: 600),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.fromLTRB(20, 18, 16, 16),
                decoration: const BoxDecoration(
                  color: AppColors.mcForestGreen,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.fact_check_outlined,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: AppTypography.headingH4.copyWith(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            subtitle,
                            style: AppTypography.bodySmall.copyWith(
                              color: Colors.white.withValues(alpha: 0.8),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white70, size: 20),
                      onPressed: () => Navigator.of(dialogCtx).pop(null),
                      tooltip: 'Cancel',
                    ),
                  ],
                ),
              ),

              // Inputs List
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                  child: Form(
                    key: formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ENTER VERIFIED QUANTITIES',
                          style: AppTypography.metaLabel.copyWith(
                            letterSpacing: 0.8,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ...inputDefs.map((def) {
                          final controller = controllers[def.key]!;
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.mcBgApp,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.mcBorder),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 14,
                                      backgroundColor: AppColors.frond50,
                                      child: Text(
                                        def.workerName.isNotEmpty
                                            ? def.workerName[0].toUpperCase()
                                            : 'W',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.mcForestGreen,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        def.workerName,
                                        style: AppTypography.headingH4.copyWith(
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 3,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.mcForestGreen.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        def.taskTypeLabel.toUpperCase(),
                                        style: const TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.mcForestGreen,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                TextFormField(
                                  controller: controller,
                                  keyboardType: const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                                  style: AppTypography.bodyRegular,
                                  decoration: InputDecoration(
                                    isDense: true,
                                    filled: true,
                                    fillColor: Colors.white,
                                    hintText: 'Enter ${def.unitLabel}',
                                    hintStyle: AppTypography.quietLabel,
                                    suffixText: def.unitLabel,
                                    suffixStyle: AppTypography.metaLabel,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: const BorderSide(
                                        color: AppColors.mcBorder,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: const BorderSide(
                                        color: AppColors.mcForestGreen,
                                        width: 1.5,
                                      ),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 10,
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'Required value';
                                    }
                                    if (double.tryParse(value.trim()) == null) {
                                      return 'Enter a valid number';
                                    }
                                    return null;
                                  },
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ),
              ),

              // Bottom Actions
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                decoration: const BoxDecoration(
                  border: Border(top: BorderSide(color: AppColors.mcBorder)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.textPrimary,
                          side: const BorderSide(color: AppColors.mcBorder),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onPressed: () => Navigator.of(dialogCtx).pop(null),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.mcForestGreen,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onPressed: () {
                          if (formKey.currentState?.validate() == true) {
                            final out = <String, String>{};
                            for (var def in inputDefs) {
                              out[def.key] = controllers[def.key]!.text.trim();
                            }
                            Navigator.of(dialogCtx).pop(out);
                          }
                        },
                        child: const Text(
                          'Confirm & Proceed',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    },
  );

  for (var c in controllers.values) {
    c.dispose();
  }

  return result;
}

class _WorkerTaskInputDef {
  final String key;
  final String workerName;
  final String taskTypeLabel;
  final String unitLabel;

  _WorkerTaskInputDef({
    required this.key,
    required this.workerName,
    required this.taskTypeLabel,
    required this.unitLabel,
  });
}

// 1. Sanitation
Future<Map<String, String>?> _showSanitationDialog(
  BuildContext context,
  AuditTaskPreviewModel task,
) {
  final List<_WorkerTaskInputDef> defs = [];

  for (var worker in task.workers) {
    String? workerTaskType;
    if (worker.meta.containsKey('spraying')) {
      workerTaskType = 'spraying';
    } else if (worker.meta.containsKey('slashing')) {
      workerTaskType = 'slashing';
    } else if (worker.meta.containsKey('sanitation_type')) {
      final st = worker.meta['sanitation_type']?.toString().toLowerCase();
      if (st == 'spraying' || st == 'slashing') workerTaskType = st;
    } else if (worker.meta.containsKey('task_type')) {
      final tt = worker.meta['task_type']?.toString().toLowerCase();
      if (tt == 'spraying' || tt == 'slashing') workerTaskType = tt;
    }

    if (workerTaskType == null) {
      defs.add(
        _WorkerTaskInputDef(
          key: '${worker.id}:spraying',
          workerName: worker.fullName,
          taskTypeLabel: 'Spraying',
          unitLabel: 'acre amount',
        ),
      );
      defs.add(
        _WorkerTaskInputDef(
          key: '${worker.id}:slashing',
          workerName: worker.fullName,
          taskTypeLabel: 'Slashing',
          unitLabel: 'acre amount',
        ),
      );
    } else {
      defs.add(
        _WorkerTaskInputDef(
          key: '${worker.id}:$workerTaskType',
          workerName: worker.fullName,
          taskTypeLabel: workerTaskType == 'spraying' ? 'Spraying' : 'Slashing',
          unitLabel: 'acre amount',
        ),
      );
    }
  }

  return _showWorkerMetaModal(
    context: context,
    title: 'Sanitation Audit Data',
    subtitle: 'Enter sprayed/slashed acreage per worker',
    inputDefs: defs,
  );
}

// 2. Manuring
Future<Map<String, String>?> _showManuringDialog(
  BuildContext context,
  AuditTaskPreviewModel task,
) {
  final List<_WorkerTaskInputDef> defs = [
    for (var worker in task.workers)
      _WorkerTaskInputDef(
        key: '${worker.id}:manuring',
        workerName: worker.fullName,
        taskTypeLabel: 'Manuring',
        unitLabel: 'tree amount',
      ),
  ];

  return _showWorkerMetaModal(
    context: context,
    title: 'Manuring Audit Data',
    subtitle: 'Enter palms/trees fertilized per worker',
    inputDefs: defs,
  );
}

// 3. Harvesting
Future<Map<String, String>?> _showHarvestingDialog(
  BuildContext context,
  AuditTaskPreviewModel task,
) {
  final List<_WorkerTaskInputDef> defs = [];

  for (var worker in task.workers) {
    String? harvestingType;
    if (worker.meta.containsKey('normal harvesting')) {
      harvestingType = 'normal harvesting';
    } else if (worker.meta.containsKey('collect loose fruits')) {
      harvestingType = 'collect loose fruits';
    } else if (worker.meta.containsKey('harvesting_type')) {
      final ht = worker.meta['harvesting_type']?.toString().toLowerCase();
      if (ht == 'normal harvesting' || ht == 'collect loose fruits') {
        harvestingType = ht;
      }
    }

    if (harvestingType == null) {
      defs.add(
        _WorkerTaskInputDef(
          key: '${worker.id}:normal harvesting',
          workerName: worker.fullName,
          taskTypeLabel: 'Normal Harvesting',
          unitLabel: 'kg amount',
        ),
      );
      defs.add(
        _WorkerTaskInputDef(
          key: '${worker.id}:collect loose fruits',
          workerName: worker.fullName,
          taskTypeLabel: 'Loose Fruits',
          unitLabel: 'kg amount',
        ),
      );
    } else {
      defs.add(
        _WorkerTaskInputDef(
          key: '${worker.id}:$harvestingType',
          workerName: worker.fullName,
          taskTypeLabel: harvestingType == 'normal harvesting'
              ? 'Normal Harvesting'
              : 'Loose Fruits',
          unitLabel: 'kg amount',
        ),
      );
    }
  }

  return _showWorkerMetaModal(
    context: context,
    title: 'Harvesting Audit Data',
    subtitle: 'Enter bunches or loose fruit weight per worker',
    inputDefs: defs,
  );
}

// 4. Pruning
Future<Map<String, String>?> _showPruningDialog(
  BuildContext context,
  AuditTaskPreviewModel task,
) {
  final List<_WorkerTaskInputDef> defs = [];

  for (var worker in task.workers) {
    String? pruningType;
    if (worker.meta.containsKey('normal pruning')) {
      pruningType = 'normal pruning';
    } else if (worker.meta.containsKey('routine pruning')) {
      pruningType = 'routine pruning';
    }

    if (pruningType == null) {
      defs.add(
        _WorkerTaskInputDef(
          key: '${worker.id}:normal pruning',
          workerName: worker.fullName,
          taskTypeLabel: 'Normal Pruning',
          unitLabel: 'tree amount',
        ),
      );
      defs.add(
        _WorkerTaskInputDef(
          key: '${worker.id}:routine pruning',
          workerName: worker.fullName,
          taskTypeLabel: 'Routine Pruning',
          unitLabel: 'acre amount',
        ),
      );
    } else {
      defs.add(
        _WorkerTaskInputDef(
          key: '${worker.id}:$pruningType',
          workerName: worker.fullName,
          taskTypeLabel: pruningType == 'normal pruning'
              ? 'Normal Pruning'
              : 'Routine Pruning',
          unitLabel: pruningType == 'normal pruning'
              ? 'tree amount'
              : 'acre amount',
        ),
      );
    }
  }

  return _showWorkerMetaModal(
    context: context,
    title: 'Pruning Audit Data',
    subtitle: 'Enter pruned palms or acreage per worker',
    inputDefs: defs,
  );
}

// 5. Planting
Future<Map<String, String>?> _showPlantingDialog(
  BuildContext context,
  AuditTaskPreviewModel task,
) {
  final List<_WorkerTaskInputDef> defs = [
    for (var worker in task.workers)
      _WorkerTaskInputDef(
        key: '${worker.id}:planting',
        workerName: worker.fullName,
        taskTypeLabel: 'Planting',
        unitLabel: 'tree amount',
      ),
  ];

  return _showWorkerMetaModal(
    context: context,
    title: 'Planting Audit Data',
    subtitle: 'Enter seedlings planted per worker',
    inputDefs: defs,
  );
}
