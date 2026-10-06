import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

/// Form Input Text Field styled with subtle frond focus borders and quiet labels
class MegaTextField extends StatelessWidget {
  final TextEditingController controller;
  final String? label;
  final String? hint;
  final String? hintText;
  final dynamic prefixIcon; // Can be IconData or Widget
  final Widget? suffixIcon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;
  final int maxLines;

  const MegaTextField({
    super.key,
    required this.controller,
    this.label,
    this.hint,
    this.hintText,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.keyboardType,
    this.validator,
    this.onChanged,
    this.maxLines = 1,
  });

  String? get _resolvedHint => hintText ?? hint;

  @override
  Widget build(BuildContext context) {
    Widget? prefixWidget;
    if (prefixIcon is IconData) {
      prefixWidget = Icon(prefixIcon as IconData, size: 20, color: AppColors.mcTextSecondary);
    } else if (prefixIcon is Widget) {
      prefixWidget = prefixIcon as Widget;
    }

    final field = TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      onChanged: onChanged,
      style: AppTypography.bodyRegular,
      decoration: InputDecoration(
        hintText: _resolvedHint,
        hintStyle: AppTypography.captionMuted.copyWith(color: AppColors.mcTextDisabled),
        prefixIcon: prefixWidget,
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: AppColors.mcBgSurface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.mcBorder, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.mcBorder, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.frond6, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.mcStatusDanger, width: 1),
        ),
      ),
    );

    if (label == null || label!.isEmpty) {
      return field;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label!,
          style: AppTypography.caption.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 6),
        field,
      ],
    );
  }
}
