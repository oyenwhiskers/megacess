import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

/// Standard Metric KPI Card matching the MegaCess Web Dashboard
/// Flat card with 1px border, bold number, quiet uppercase title, and circular icon badge.
class MegaMetricCard extends StatelessWidget {
  final String label;
  final String value;
  final String? unit;
  final String subtitle;
  final IconData icon;
  final VoidCallback? onTap;

  const MegaMetricCard({
    super.key,
    required this.label,
    required this.value,
    this.unit,
    required this.subtitle,
    required this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.mcBgSurface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.mcBorder, width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      label.toUpperCase(),
                      style: AppTypography.caption.copyWith(
                        letterSpacing: 0.6,
                        fontWeight: FontWeight.w700,
                        fontSize: 10.5,
                        color: AppColors.mcTextSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    width: 28,
                    height: 28,
                    decoration: const BoxDecoration(
                      color: AppColors.frond0,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Icon(icon, size: 15, color: AppColors.frond6),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(value, style: AppTypography.heroNumber),
                  if (unit != null) ...[
                    const SizedBox(width: 4),
                    Text(unit!, style: AppTypography.captionMuted),
                  ],
                ],
              ),
              const SizedBox(height: 6),
              Text(
                subtitle,
                style: AppTypography.captionMuted,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
