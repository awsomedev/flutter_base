import 'package:flutter/material.dart';
import 'package:madeira/app/app_essentials/colors.dart';

class ConfirmationDialog extends StatelessWidget {
  final String title;
  final String message;
  final String confirmText;
  final String cancelText;
  final VoidCallback onConfirm;
  final VoidCallback? onCancel;

  const ConfirmationDialog({
    Key? key,
    required this.title,
    required this.message,
    this.confirmText = 'Yes',
    this.cancelText = 'No',
    required this.onConfirm,
    this.onCancel,
  }) : super(key: key);

  static Future<bool?> show({
    required BuildContext context,
    required String title,
    required String message,
    String confirmText = 'Yes',
    String cancelText = 'No',
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return ConfirmationDialog(
          title: title,
          message: message,
          confirmText: confirmText,
          cancelText: cancelText,
          onConfirm: onConfirm ?? () => Navigator.of(context).pop(true),
          onCancel: onCancel ?? () => Navigator.of(context).pop(false),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      content: Text(
        message,
        style: const TextStyle(
          fontSize: 16,
          color: AppColors.textPrimary,
        ),
      ),
      actions: [
        TextButton(
          onPressed: onCancel ?? () => Navigator.of(context).pop(false),
          child: Text(
            cancelText,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 16,
            ),
          ),
        ),
        TextButton(
          onPressed: onConfirm,
          child: Text(
            confirmText,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
            ),
          ),
        ),
      ],
    );
  }
}
