import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

enum MegaStatus { completed, inProgress, pending, rejected }

/// Standard Status Pill Badge combining explicit icon and semantic color
class MegaStatusBadge extends StatelessWidget {
  final dynamic status;
  final String? customLabel;
  final Color? color;

  const MegaStatusBadge({
    super.key,
    required this.status,
    this.customLabel,
    this.color,
  });

  /// Factory helper to build a badge directly from API status strings
  factory MegaStatusBadge.fromString(
    String statusStr, {
    Key? key,
    String? customLabel,
    Color? color,
  }) {
    return MegaStatusBadge(
      key: key,
      status: statusStr,
      customLabel: customLabel,
      color: color,
    );
  }

  MegaStatus _resolveStatus(dynamic s) {
    if (s is MegaStatus) return s;
    final clean = (s?.toString() ?? '').toLowerCase();
    if (clean.contains('complete') ||
        clean.contains('approved') ||
        clean.contains('done') ||
        clean.contains('active')) {
      return MegaStatus.completed;
    } else if (clean.contains('progress') || clean.contains('ongoing')) {
      return MegaStatus.inProgress;
    } else if (clean.contains('reject') || clean.contains('failed') || clean.contains('absent')) {
      return MegaStatus.rejected;
    } else {
      return MegaStatus.pending;
    }
  }

  @override
  Widget build(BuildContext context) {
    final resolved = _resolveStatus(status);
    Color bg;
    Color fg;
    IconData icon;
    String label;

    switch (resolved) {
      case MegaStatus.completed:
        bg = color?.withOpacity(0.12) ?? AppColors.mcStatusSuccessBg;
        fg = color ?? AppColors.mcStatusSuccess;
        icon = Icons.check_circle_outline;
        label = customLabel ?? (status is String ? status : 'Completed');
        break;
      case MegaStatus.inProgress:
        bg = color?.withOpacity(0.12) ?? AppColors.mcStatusProgressBg;
        fg = color ?? AppColors.mcStatusProgress;
        icon = Icons.schedule;
        label = customLabel ?? (status is String ? status : 'In progress');
        break;
      case MegaStatus.pending:
        bg = color?.withOpacity(0.12) ?? AppColors.mcStatusPendingBg;
        fg = color ?? AppColors.mcStatusPending;
        icon = Icons.hourglass_empty;
        label = customLabel ?? (status is String ? status : 'Pending');
        break;
      case MegaStatus.rejected:
        bg = color?.withOpacity(0.12) ?? AppColors.mcStatusDangerBg;
        fg = color ?? AppColors.mcStatusDanger;
        icon = Icons.cancel_outlined;
        label = customLabel ?? (status is String ? status : 'Rejected');
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: fg.withOpacity(0.25), width: 0.8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: fg),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTypography.badgeLabel.copyWith(color: fg),
          ),
        ],
      ),
    );
  }
}
