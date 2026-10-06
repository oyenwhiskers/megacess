import 'package:flutter/material.dart';
import 'package:megacess/core/theme/app_colors.dart';
import 'package:megacess/core/theme/app_typography.dart';
import 'package:megacess/modules/checker/data/model/audit_task_preview_model.dart';

class AuditWorkersTab extends StatelessWidget {
  final List<AuditTaskPreviewWorker> workers;
  final String taskType;

  const AuditWorkersTab({
    super.key,
    required this.workers,
    required this.taskType,
  });

  String _formatMetaKey(String key) {
    if (key.isEmpty) return key;
    final clean = key.replaceAll('_', ' ');
    return clean
        .split(' ')
        .map((word) => word.isNotEmpty
            ? '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}'
            : '')
        .join(' ');
  }

  @override
  Widget build(BuildContext context) {
    if (workers.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: AppColors.frond50,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.people_outline,
                  size: 40,
                  color: AppColors.mcForestGreen,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'No Workers Assigned',
                style: AppTypography.headingH3,
              ),
              const SizedBox(height: 8),
              Text(
                'This task has no workers registered by the mandor.',
                textAlign: TextAlign.center,
                style: AppTypography.bodySmall,
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      itemCount: workers.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final worker = workers[index];
        final initial = worker.fullName.isNotEmpty
            ? worker.fullName[0].toUpperCase()
            : 'W';

        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.mcBorder),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Worker Profile Header
              Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: AppColors.frond50,
                    child: Text(
                      initial,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.mcForestGreen,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          worker.fullName,
                          style: AppTypography.headingH4.copyWith(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        if (worker.phone.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              const Icon(
                                Icons.phone_outlined,
                                size: 12,
                                color: AppColors.textSecondary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                worker.phone,
                                style: AppTypography.bodySmall.copyWith(
                                  color: AppColors.textSecondary,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.mcBgApp,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppColors.mcBorder),
                    ),
                    child: Text(
                      'ID #${worker.id}',
                      style: AppTypography.metaLabel.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),

              // Worker Meta Breakdown
              if (worker.meta.isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.mcBgApp,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.mcBorder),
                  ),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: worker.meta.entries.map((entry) {
                      final label = _formatMetaKey(entry.key);
                      final val = entry.value.toString();
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: AppColors.mcBorder),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '$label: ',
                              style: AppTypography.metaLabel.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              val,
                              style: AppTypography.bodySmall.copyWith(
                                fontWeight: FontWeight.w700,
                                color: AppColors.mcForestGreen,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
