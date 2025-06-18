import 'package:flutter/material.dart';
import 'package:vera_clinic/core/theme/app_theme.dart';

class EditFormDialog extends StatelessWidget {
  final String title;
  final List<Widget> fields;
  final VoidCallback onSave;
  final VoidCallback onCancel;
  final String saveButtonLabel;

  const EditFormDialog({
    super.key,
    required this.title,
    required this.fields,
    required this.onSave,
    required this.onCancel,
    this.saveButtonLabel = 'حفظ',
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.offWhite,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(
        title,
        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.purple),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: fields,
        ),
      ),
      actions: [
        TextButton(
          onPressed: onCancel,
          child: const Text('إلغاء'),
        ),
        ElevatedButton(
          onPressed: onSave,
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.purple),
          child: Text(saveButtonLabel),
        ),
      ],
    );
  }
}
