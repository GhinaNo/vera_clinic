import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../models/department.dart';

class AddEditDepartmentDialog extends StatefulWidget {
  final Department? initialDepartment;
  final String title;
  final void Function(Department department)? onSave;

  const AddEditDepartmentDialog({
    Key? key,
    this.initialDepartment,
    required this.title,
    this.onSave,
  }) : super(key: key);

  @override
  State<AddEditDepartmentDialog> createState() => _AddEditDepartmentDialogState();
}

class _AddEditDepartmentDialogState extends State<AddEditDepartmentDialog> {
  late final TextEditingController nameController;
  late final TextEditingController descriptionController;
  late final TextEditingController locationController;
  bool isButtonEnabled = false;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.initialDepartment?.name ?? '');
    descriptionController = TextEditingController(text: widget.initialDepartment?.description ?? '');
    locationController = TextEditingController(text: widget.initialDepartment?.suite_no ?? '');

    nameController.addListener(_validate);
    descriptionController.addListener(_validate);
    locationController.addListener(_validate);
    _validate();
  }

  void _validate() {
    final enabled = nameController.text.trim().isNotEmpty &&
        descriptionController.text.trim().isNotEmpty &&
        locationController.text.trim().isNotEmpty;

    if (enabled != isButtonEnabled) {
      setState(() => isButtonEnabled = enabled);
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    locationController.dispose();
    super.dispose();
  }

  Widget _buildInputField(String label, TextEditingController controller,
      {int maxLines = 1, int? maxLength}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      maxLength: maxLength,
      textAlign: TextAlign.right,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: AppColors.purple.withOpacity(0.8), fontWeight: FontWeight.w600),
        filled: true,
        fillColor: AppColors.offWhite.withOpacity(0.95),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: AppColors.purple.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: AppColors.purple, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: AppColors.offWhite,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        height: MediaQuery.of(context).size.height * 0.6,
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(widget.title,
              style: TextStyle(color: AppColors.purple, fontWeight: FontWeight.bold, fontSize: 26),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            _buildInputField('اسم القسم', nameController, maxLength: 30),
            const SizedBox(height: 25),
            _buildInputField('رقم الجناح', locationController, maxLength: 20),
            const SizedBox(height: 25),
            Expanded(child: _buildInputField('حول هذا القسم', descriptionController, maxLines: 6, maxLength: 300)),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('إلغاء', style: TextStyle(color: AppColors.purple, fontSize: 18)),
                ),
                const SizedBox(width: 20),
                ElevatedButton(
                  onPressed: isButtonEnabled ? () {
                    final department = Department(
                      name: nameController.text.trim(),
                      description: descriptionController.text.trim(),
                      suite_no: locationController.text.trim(),
                    );
                    widget.onSave?.call(department);
                  } : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isButtonEnabled ? AppColors.purple : Colors.grey,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 14),
                  ),
                  child: Text(widget.initialDepartment == null ? 'إضافة' : 'حفظ',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: AppColors.offWhite),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
