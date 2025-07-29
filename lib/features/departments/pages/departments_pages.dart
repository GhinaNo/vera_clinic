import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_theme.dart';
import '../models/department.dart';
import '../widgets/add_edit_department_dialog.dart';
import '../widgets/department_card.dart';
import '../cubit/departments_cubit.dart';

class DepartmentsPage extends StatefulWidget {
  const DepartmentsPage({super.key});

  @override
  State<DepartmentsPage> createState() => _DepartmentsPageState();
}

class _DepartmentsPageState extends State<DepartmentsPage> {
  void _showAddDialog() {
    final cubit = context.read<DepartmentsCubit>();

    showDialog(
      context: context,
      builder: (_) => AddEditDepartmentDialog(
        title: 'إضافة قسم جديد',
        onSave: (department) {
          cubit.addDepartment(department);
          Navigator.pop(context);
        },
      ),
    );
  }

  Future<void> _showEditDialog(Department department, int index) async {
    final cubit = context.read<DepartmentsCubit>();

    await showDialog(
      context: context,
      builder: (_) => AddEditDepartmentDialog(
        initialDepartment: department,
        title: 'تعديل قسم',
        onSave: (updatedDepartment) async {
          final confirmed = await _showConfirmDialog(
            'تأكيد التغييرات',
            'هل أنت متأكد من حفظ هذه التغييرات؟',
          );
          if (confirmed == true) {
            cubit.updateDepartment(index, updatedDepartment);
            Navigator.pop(context);
          }
        },
      ),
    );
  }

  Future<bool?> _showConfirmDialog(String title, String content) {
    return showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
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
                        onEdit: () async {
                          await _showEditDialog(department, index);
                        },
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
