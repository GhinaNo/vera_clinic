import 'package:flutter/material.dart';
import '../../../core/widgets/edit_form_dialog.dart';
import '../models/department.dart';
import '../../../core/theme/app_theme.dart';

class EditDepartmentDialog extends StatefulWidget {
  final Department department;
  final void Function(Department updatedDepartment) onSave;

  const EditDepartmentDialog({
    super.key,
    required this.department,
    required this.onSave,
  });

  @override
  State<EditDepartmentDialog> createState() => _EditDepartmentDialogState();
}

class _EditDepartmentDialogState extends State<EditDepartmentDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController nameController;
  late TextEditingController supervisorController;
  late TextEditingController descriptionController;
  late TextEditingController locationController;

  static const int maxNameLength = 30;
  static const int maxSupervisorLength = 30;
  static const int maxDescriptionLength = 300;
  static const int maxLocationLength = 20;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.department.name);
    supervisorController = TextEditingController(text: widget.department.supervisor);
    descriptionController = TextEditingController(text: widget.department.description);
    locationController = TextEditingController(text: widget.department.location);
  }

  InputDecoration _inputDecoration(String label, int maxLength, TextEditingController controller) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: AppColors.purple.withOpacity(0.8), fontWeight: FontWeight.w600),
      filled: true,
      fillColor: AppColors.offWhite.withOpacity(0.9),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide(color: AppColors.purple.withOpacity(0.3), width: 1.8),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide(color: AppColors.purple, width: 2.8),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      counterText: '${controller.text.length} / $maxLength',
      counterStyle: TextStyle(
        color: controller.text.length > maxLength ? Colors.red : AppColors.purple.withOpacity(0.7),
        fontSize: 12,
      ),
    );
  }

  void _handleSave() {
    if (!_formKey.currentState!.validate()) return;

    final updated = Department(
      name: nameController.text.trim(),
      supervisor: supervisorController.text.trim(),
      description: descriptionController.text.trim(),
      location: locationController.text.trim(),
    );

    widget.onSave(updated);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: EditFormDialog(
        title: 'تعديل القسم',
        onCancel: () => Navigator.pop(context),
        onSave: _handleSave,
        fields: [
          TextFormField(
            controller: nameController,
            maxLength: maxNameLength,
            decoration: _inputDecoration('اسم القسم', maxNameLength, nameController),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'يرجى إدخال اسم القسم';
              }
              if (value.length > maxNameLength) {
                return 'عدد الأحرف لا يجب أن يتجاوز $maxNameLength';
              }
              return null;
            },
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: supervisorController,
            maxLength: maxSupervisorLength,
            decoration: _inputDecoration('الطبيب المشرف', maxSupervisorLength, supervisorController),
            validator: (value) {
              if (value != null && value.length > maxSupervisorLength) {
                return 'عدد الأحرف لا يجب أن يتجاوز $maxSupervisorLength';
              }
              return null;
            },
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: descriptionController,
            maxLength: maxDescriptionLength,
            maxLines: 4,
            decoration: _inputDecoration('حول هذا القسم', maxDescriptionLength, descriptionController),
            validator: (value) {
              if (value != null && value.length > maxDescriptionLength) {
                return 'عدد الأحرف لا يجب أن يتجاوز $maxDescriptionLength';
              }
              return null;
            },
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: locationController,
            maxLength: maxLocationLength,
            decoration: _inputDecoration('رقم الجناح', maxLocationLength, locationController),
            validator: (value) {
              if (value != null && value.length > maxLocationLength) {
                return 'عدد الأحرف لا يجب أن يتجاوز $maxLocationLength';
              }
              return null;
            },
            onChanged: (_) => setState(() {}),
          ),
        ],
      ),
    );
  }
}
