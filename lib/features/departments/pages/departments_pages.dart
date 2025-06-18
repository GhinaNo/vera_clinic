import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vera_clinic/core/theme/app_theme.dart';
import '../models/department.dart';
import '../widgets/department_card.dart';

class DepartmentsPage extends StatefulWidget {
  final List<Department> departments;
  final ValueChanged<List<Department>> onDepartmentsChanged;

  const DepartmentsPage({
    super.key,
    required this.departments,
    required this.onDepartmentsChanged,
  });

  @override
  State<DepartmentsPage> createState() => _DepartmentsPageState();
}

class _DepartmentsPageState extends State<DepartmentsPage> {
  late List<Department> departments;

  @override
  void initState() {
    super.initState();
    departments = List.from(widget.departments);
  }

  void _addDepartment(Department department) {
    setState(() => departments.add(department));
    widget.onDepartmentsChanged(departments);
  }

  void _updateDepartment(int index, Department updated) {
    setState(() => departments[index] = updated);
    widget.onDepartmentsChanged(departments);
  }

  void _removeDepartment(int index) {
    setState(() => departments.removeAt(index));
    widget.onDepartmentsChanged(departments);
  }

  void _showAddDialog() {
    final nameController = TextEditingController();
    final supervisorController = TextEditingController();
    final descriptionController = TextEditingController();
    final locationController = TextEditingController();

    bool isButtonEnabled() {
      return nameController.text.trim().isNotEmpty &&
          supervisorController.text.trim().isNotEmpty &&
          descriptionController.text.trim().isNotEmpty &&
          locationController.text.trim().isNotEmpty;
    }

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            nameController.addListener(() => setStateDialog(() {}));
            supervisorController.addListener(() => setStateDialog(() {}));
            descriptionController.addListener(() => setStateDialog(() {}));
            locationController.addListener(() => setStateDialog(() {}));

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
                      'إضافة قسم جديد',
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
                        Expanded(child: _buildInputField('اسم القسم', nameController, maxLength: 30)),
                        const SizedBox(width: 24),
                        Expanded(child: _buildInputField('الطبيب المشرف', supervisorController, maxLength: 30)),
                      ],
                    ),
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
                          onPressed: isButtonEnabled()
                              ? () {
                            final department = Department(
                              name: nameController.text.trim(),
                              supervisor: supervisorController.text.trim(),
                              description: descriptionController.text.trim(),
                              location: locationController.text.trim(),
                            );
                            _addDepartment(department);
                            Navigator.pop(context);
                          }
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isButtonEnabled() ? AppColors.purple : Colors.grey,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 14),
                          ),
                          child: const Text('إضافة', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildInputField(String label, TextEditingController controller,
      {int maxLines = 1, int? maxLength}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      maxLength: maxLength,
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

  Future<bool?> _showConfirmDialog(String title, String content) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: AppColors.offWhite,
        title: Text(title, style: TextStyle(color: AppColors.purple, fontWeight: FontWeight.bold)),
        content: Text(content),
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
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton.icon(
              onPressed: _showAddDialog,
              icon: const Icon(Icons.add, size: 22),
              label: const Text('قسم جديد', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                elevation: 3,
                backgroundColor: AppColors.purple,
                foregroundColor: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: departments.isEmpty
                  ? Center(
                key: const ValueKey("empty"),
                child: Text(
                  'لا توجد أقسام حالياً',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
                ),
              )
                  : GridView.builder(
                key: const ValueKey("grid"),
                itemCount: departments.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
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
                      final updated = await context.push<Department>(
                        '/departments/edit',
                        extra: department,
                      );
                      final confirm = await _showConfirmDialog(
                        'تأكيد التغييرات',
                        'هل أنت متأكد من حفظ هذه التغييرات؟',
                      );
                      if (updated != null) {
                        _updateDepartment(index, updated);
                      }
                    },
                    onDelete: () async {
                      final confirm = await _showConfirmDialog(
                        'تأكيد الحذف',
                        'هل أنت متأكد من حذف هذا القسم؟',
                      );
                      if (confirm == true) {
                        _removeDepartment(index);
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
  }
}
