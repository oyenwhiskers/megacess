import 'package:flutter/material.dart';
import 'package:megacess/core/theme/app_colors.dart';
import 'package:megacess/core/theme/app_typography.dart';
import 'package:megacess/core/widgets/mega_status_badge.dart';
import 'package:megacess/modules/checker/data/model/audit_task_preview_model.dart';

class AuditOverviewTab extends StatelessWidget {
  final AuditTaskPreviewModel task;
  final int videoCount;
  final int imageCount;

  const AuditOverviewTab({
    super.key,
    required this.task,
    required this.videoCount,
    required this.imageCount,
  });

  @override
  Widget build(BuildContext context) {
    final bool hasVideo = videoCount > 0;
    final bool hasImage = imageCount > 0;
    final bool isReadyForApproval = hasVideo && hasImage;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Primary Header Card
          Container(
            padding: const EdgeInsets.all(16),
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.frond50,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: AppColors.frond200),
                      ),
                      child: Text(
                        task.taskType.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.mcForestGreen,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    MegaStatusBadge.fromString(task.taskStatus),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  task.taskName,
                  style: AppTypography.headingH3.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      task.location.name.isNotEmpty
                          ? task.location.name
                          : 'Estate Location #${task.location.id}',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 2. Audit Verification Status Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isReadyForApproval
                    ? AppColors.frond300
                    : AppColors.statusPendingBg,
              ),
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
                Row(
                  children: [
                    Icon(
                      isReadyForApproval
                          ? Icons.check_circle_outline
                          : Icons.pending_actions_outlined,
                      color: isReadyForApproval
                          ? AppColors.statusCompletedText
                          : AppColors.statusPendingText,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'AUDIT EVIDENCE REQUIREMENTS',
                      style: AppTypography.metaLabel.copyWith(
                        letterSpacing: 0.6,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                _RequirementRow(
                  label: 'Video Evidence (Max 30s)',
                  isMet: hasVideo,
                  statusText: hasVideo
                      ? '$videoCount video recorded'
                      : 'Missing (Required for approval)',
                ),
                const Divider(height: 16, color: AppColors.mcBorder),
                _RequirementRow(
                  label: 'Photo Evidence',
                  isMet: hasImage,
                  statusText: hasImage
                      ? '$imageCount photo(s) attached'
                      : 'Missing (Required for approval)',
                ),
                const Divider(height: 16, color: AppColors.mcBorder),
                _RequirementRow(
                  label: 'Assigned Workers',
                  isMet: task.workers.isNotEmpty,
                  statusText: '${task.workers.length} worker(s) registered',
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 3. Operational Timeline Card
          Container(
            padding: const EdgeInsets.all(16),
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
                Text(
                  'TIMELINE & CREATION',
                  style: AppTypography.metaLabel.copyWith(
                    letterSpacing: 0.6,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 14),
                _InfoTile(
                  icon: Icons.person_outline,
                  label: 'Created by Mandor',
                  value: task.createdBy.name.isNotEmpty
                      ? task.createdBy.name
                      : 'Mandor #${task.createdBy.id}',
                ),
                const SizedBox(height: 12),
                _InfoTile(
                  icon: Icons.calendar_today_outlined,
                  label: 'Scheduled Task Date',
                  value: task.taskDate.isNotEmpty ? task.taskDate : '-',
                ),
                if (task.submittedAt != null && task.submittedAt!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  _InfoTile(
                    icon: Icons.access_time,
                    label: 'Submitted for Audit',
                    value: task.submittedAt!,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RequirementRow extends StatelessWidget {
  final String label;
  final bool isMet;
  final String statusText;

  const _RequirementRow({
    required this.label,
    required this.isMet,
    required this.statusText,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: isMet ? AppColors.statusCompletedBg : AppColors.mcBgApp,
            shape: BoxShape.circle,
            border: Border.all(
              color: isMet ? AppColors.statusCompletedBorder : AppColors.mcBorder,
            ),
          ),
          child: Icon(
            isMet ? Icons.check : Icons.close,
            size: 16,
            color: isMet
                ? AppColors.statusCompletedText
                : AppColors.textSecondary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTypography.headingH4.copyWith(fontSize: 13),
              ),
              Text(
                statusText,
                style: AppTypography.bodySmall.copyWith(
                  color: isMet
                      ? AppColors.statusCompletedText
                      : AppColors.statusRejectedText,
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.mcBgApp,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.mcBorder),
          ),
          child: Icon(icon, size: 18, color: AppColors.mcForestGreen),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AppTypography.quietLabel),
              const SizedBox(height: 2),
              Text(
                value,
                style: AppTypography.bodyRegular.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
