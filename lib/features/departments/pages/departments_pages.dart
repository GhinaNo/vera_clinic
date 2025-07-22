import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_theme.dart';
import '../models/department.dart';
import '../widgets/department_card.dart';
import '../cubit/departments_cubit.dart';

class DepartmentsPage extends StatefulWidget {
  const DepartmentsPage({super.key});

  @override
  State<DepartmentsPage> createState() => _DepartmentsPageState();
}

class _DepartmentsPageState extends State<DepartmentsPage> {
  void _showAddDialog() {
    final departmentsCubit = context.read<DepartmentsCubit>();

    showDialog(
      context: context,
      builder: (context) {
        return AddEditDepartmentDialog(
          title: 'إضافة قسم جديد',
          onSave: (department) {
            departmentsCubit.addDepartment(department);
            Navigator.pop(context);
          },
        );
      },
    );
  }

  void _showEditDialog(Department department, int index) {
    final departmentsCubit = context.read<DepartmentsCubit>();

    showDialog(
      context: context,
      builder: (context) {
        return AddEditDepartmentDialog(
          initialDepartment: department,
          title: 'تعديل قسم',
          onSave: (updatedDepartment) async {
            final confirmed = await _showConfirmDialog(
              'تأكيد التغييرات',
              'هل أنت متأكد من حفظ هذه التغييرات؟',
            );
            if (confirmed == true) {
              departmentsCubit.updateDepartment(index, updatedDepartment);
              Navigator.pop(context);
            }
          },
        );
      },
    );
  }

  Future<bool?> _showConfirmDialog(String title, String content) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: AppColors.offWhite,
        title: Text(title,
            style: TextStyle(
                color: AppColors.purple, fontWeight: FontWeight.bold)),
        content: Text(content, textAlign: TextAlign.right),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('إلغاء', style: TextStyle(color: AppColors.purple)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.purple,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('تأكيد'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DepartmentsCubit, List<Department>>(
      builder: (context, departments) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton.icon(
                  onPressed: _showAddDialog,
                  icon: const Icon(Icons.add, color: Colors.white),
                  label: const Text('قسم جديد',
                      style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.purple),
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: departments.isEmpty
                      ? Center(
                    key: const ValueKey('empty'),
                    child: Text(
                      'لا توجد أقسام حالياً',
                      style: TextStyle(
                          color: Colors.grey.shade600, fontSize: 16),
                    ),
                  )
                      : GridView.builder(
                    key: const ValueKey('grid'),
                    itemCount: departments.length,
                    gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      childAspectRatio: 1.2,
                      crossAxisSpacing: 15,
                      mainAxisSpacing: 15,
                    ),
                    itemBuilder: (context, index) {
                      final department = departments[index];
                      return DepartmentCard(
                        department: department,
                        onEdit: () => _showEditDialog(department, index),
                        onDelete: () async {
                          final confirmed = await _showConfirmDialog(
                            'تأكيد الحذف',
                            'هل أنت متأكد من حذف هذا القسم؟',
                          );
                          if (confirmed == true) {
                            context
                                .read<DepartmentsCubit>()
                                .removeDepartment(index);
                          }
                        },
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class AddEditDepartmentDialog extends StatefulWidget {
  final Department? initialDepartment;
  final String title;
  final void Function(Department department) onSave;

  const AddEditDepartmentDialog({
    Key? key,
    this.initialDepartment,
    required this.title,
    required this.onSave,
  }) : super(key: key);

  @override
  State<AddEditDepartmentDialog> createState() => _AddEditDepartmentDialogState();
}

class _AddEditDepartmentDialogState extends State<AddEditDepartmentDialog> {
  late final TextEditingController nameController;
  late final TextEditingController supervisorController;
  late final TextEditingController descriptionController;
  late final TextEditingController locationController;

  bool isButtonEnabled = false;

  @override
  void initState() {
    super.initState();

    nameController = TextEditingController(text: widget.initialDepartment?.name ?? '');
    supervisorController = TextEditingController(text: widget.initialDepartment?.supervisor ?? '');
    descriptionController = TextEditingController(text: widget.initialDepartment?.description ?? '');
    locationController = TextEditingController(text: widget.initialDepartment?.location ?? '');

    nameController.addListener(_validate);
    supervisorController.addListener(_validate);
    descriptionController.addListener(_validate);
    locationController.addListener(_validate);

    _validate();
  }

  void _validate() {
    final enabled = nameController.text.trim().isNotEmpty &&
        supervisorController.text.trim().isNotEmpty &&
        descriptionController.text.trim().isNotEmpty &&
        locationController.text.trim().isNotEmpty;

    if (enabled != isButtonEnabled) {
      setState(() {
        isButtonEnabled = enabled;
      });
    }
  }

  @override
  void dispose() {
    nameController.removeListener(_validate);
    supervisorController.removeListener(_validate);
    descriptionController.removeListener(_validate);
    locationController.removeListener(_validate);

    nameController.dispose();
    supervisorController.dispose();
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
        labelStyle: TextStyle(
            color: AppColors.purple.withOpacity(0.8),
            fontWeight: FontWeight.w600),
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
        height: MediaQuery.of(context).size.height * 0.7,
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              widget.title,
              style: TextStyle(
                color: AppColors.purple,
                fontWeight: FontWeight.bold,
                fontSize: 26,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            Row(
              children: [
                Expanded(
                    child: _buildInputField('اسم القسم', nameController,
                        maxLength: 30)),
                const SizedBox(width: 24),
                Expanded(
                    child: _buildInputField('الطبيب المشرف', supervisorController,
                        maxLength: 30)),
              ],
            ),
            const SizedBox(height: 25),
            _buildInputField('رقم الجناح', locationController, maxLength: 20),
            const SizedBox(height: 25),
            Expanded(
                child: _buildInputField('حول هذا القسم', descriptionController,
                    maxLines: 6, maxLength: 300)),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('إلغاء',
                      style:
                      TextStyle(color: AppColors.purple, fontSize: 18)),
                ),
                const SizedBox(width: 20),
                ElevatedButton(
                  onPressed: isButtonEnabled
                      ? () {
                    final department = Department(
                      name: nameController.text.trim(),
                      supervisor: supervisorController.text.trim(),
                      description: descriptionController.text.trim(),
                      location: locationController.text.trim(),
                    );
                    widget.onSave(department);
                  }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                    isButtonEnabled ? AppColors.purple : Colors.grey,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25)),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 14),
                  ),
                  child: Text(
                    widget.initialDepartment == null ? 'إضافة' : 'حفظ',
                    style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 20,color: AppColors.offWhite),
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
