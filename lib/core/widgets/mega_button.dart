import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

enum MegaButtonVariant { primary, outline, danger }

/// Standard Button with loading indicator and tactile feedback for field usage
class MegaButton extends StatelessWidget {
  final String? text;
  final String? label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final dynamic icon; // Can be IconData or Widget
  final MegaButtonVariant variant;
  final double? width;

  const MegaButton({
    super.key,
    this.text,
    this.label,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
    this.variant = MegaButtonVariant.primary,
    this.width,
  });

  String get _buttonText => text ?? label ?? '';

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    BorderSide border;

    switch (variant) {
      case MegaButtonVariant.primary:
        bg = AppColors.frond6;
        fg = Colors.white;
        border = BorderSide.none;
        break;
      case MegaButtonVariant.outline:
        bg = Colors.transparent;
        fg = AppColors.frond7;
        border = const BorderSide(color: AppColors.mcBorder, width: 1);
        break;
      case MegaButtonVariant.danger:
        bg = AppColors.mcStatusDanger;
        fg = Colors.white;
        border = BorderSide.none;
        break;
    }

    final buttonStyle = ElevatedButton.styleFrom(
      backgroundColor: bg,
      foregroundColor: fg,
      disabledBackgroundColor: AppColors.mcBorder,
      disabledForegroundColor: AppColors.mcTextDisabled,
      elevation: 0,
      minimumSize: const Size(48, 48), // 48dp touch target
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: border,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
    );

    Widget content;
    if (isLoading) {
      content = SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2.2,
          color: fg,
        ),
      );
    } else {
      Widget? iconWidget;
      if (icon is IconData) {
        iconWidget = Icon(icon as IconData, size: 18, color: fg);
      } else if (icon is Widget) {
        iconWidget = icon as Widget;
      }

      content = Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (iconWidget != null) ...[
            iconWidget,
            const SizedBox(width: 8),
          ],
          Text(_buttonText, style: AppTypography.buttonText.copyWith(color: fg)),
        ],
      );
    }

    if (width != null) {
      return SizedBox(
        width: width,
        child: ElevatedButton(
          style: buttonStyle,
          onPressed: isLoading ? null : onPressed,
          child: content,
        ),
      );
    }

    return ElevatedButton(
      style: buttonStyle,
      onPressed: isLoading ? null : onPressed,
      child: content,
    );
  }
}
