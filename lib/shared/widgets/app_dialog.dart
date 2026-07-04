// lib/shared/widgets/app_dialog.dart
// Reusable confirmation and success dialogs

import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_typography.dart';
import 'app_button.dart';

// ── Confirmation Dialog ───────────────────────────────
Future<bool?> showConfirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  String confirmLabel = 'Konfirmasi',
  String cancelLabel = 'Batal',
  Color? confirmColor,
  IconData? icon,
}) {
  return showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusXxl),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusXxl),
                ),
                child: Icon(icon, size: 32, color: AppColors.primary),
              ),
              const SizedBox(height: 16),
            ],
            Text(title, style: AppTypography.headlineSmall),
            const SizedBox(height: 8),
            Text(
              message,
              style: AppTypography.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: AppSecondaryButton(
                    label: cancelLabel,
                    onTap: () => Navigator.of(ctx).pop(false),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AppPrimaryButton(
                    label: confirmLabel,
                    onTap: () => Navigator.of(ctx).pop(true),
                    backgroundColor: confirmColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

// ── Success Dialog ────────────────────────────────────
Future<void> showSuccessDialog(
  BuildContext context, {
  required String title,
  required String message,
  String buttonLabel = 'OK',
  VoidCallback? onDismiss,
}) {
  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusXxl),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.successLight,
                borderRadius: BorderRadius.circular(AppDimensions.radiusXxl),
              ),
              child: const Icon(
                Icons.check_circle_rounded,
                size: 40,
                color: AppColors.success,
              ),
            ),
            const SizedBox(height: 16),
            Text(title, style: AppTypography.headlineSmall),
            const SizedBox(height: 8),
            Text(
              message,
              style: AppTypography.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            AppPrimaryButton(
              label: buttonLabel,
              onTap: () {
                Navigator.of(ctx).pop();
                onDismiss?.call();
              },
              backgroundColor: AppColors.success,
            ),
          ],
        ),
      ),
    ),
  );
}
