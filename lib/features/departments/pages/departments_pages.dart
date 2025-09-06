import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/custom_toast.dart';
import '../cubit/add_departments/add_department_cubit.dart';
import '../cubit/add_departments/add_department_state.dart';
import '../cubit/delete_department/delete_department_cubi.dart';
import '../cubit/delete_department/delete_department_state.dart';
import '../cubit/show_departments/show_departments_cubit.dart';
import '../cubit/show_departments/show_departments_state.dart';
import '../cubit/update_department/update_department_cubit.dart';
import '../cubit/update_department/update_department_state.dart';
import '../models/departments_repository.dart';
import '../models/department.dart';
import '../widgets/add_edit_department_dialog.dart';
import '../widgets/department_card.dart';

class DepartmentsPage extends StatelessWidget {
  final String token;

  const DepartmentsPage({super.key, required this.token});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => AddDepartmentCubit(
            repository: DepartmentsRepository(token: token),
          ),
        ),
        BlocProvider(
          create: (_) => ShowDepartmentsCubit(
            repository: DepartmentsRepository(token: token),
          )..fetchDepartments(),
        ),
        BlocProvider(
          create: (_) => UpdateDepartmentCubit(
            repository: DepartmentsRepository(token: token),
          ),
        ),
        BlocProvider(
          create: (_) => DeleteDepartmentCubit(
            repository: DepartmentsRepository(token: token),
          ),
        ),
      ],
      child: const DepartmentsView(),
    );
  }
}

class DepartmentsView extends StatefulWidget {
  const DepartmentsView({super.key});

  @override
  State<DepartmentsView> createState() => _DepartmentsViewState();
}

class _DepartmentsViewState extends State<DepartmentsView> {
  void _showAddDialog() {
    final addCubit = context.read<AddDepartmentCubit>();

    showDialog(
      context: context,
      builder: (dialogContext) => AddEditDepartmentDialog(
        title: 'إضافة قسم جديد',
        onSave: (department) {
          addCubit.addDepartment(department);
        },
      ),
    );
  }

  void _showEditDialog(Department department) {
    final updateCubit = context.read<UpdateDepartmentCubit>();

    if (department.id != null) {
      showDialog(
        context: context,
        builder: (dialogContext) => AddEditDepartmentDialog(
          title: 'تعديل القسم',
          initialDepartment: department,
          onSave: (updatedDept) {
            updateCubit.updateDepartment(department.id!, updatedDept);
          },
        ),
      );
    } else {
      showCustomToast(context, 'لا يمكن تعديل القسم: معرف القسم غير موجود', success: false);
    }
  }

  void _deleteDepartment(Department department) async {
    final deleteCubit = context.read<DeleteDepartmentCubit>();

    if (department.id != null) {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text("تأكيد الحذف"),
          content: Text("هل أنت متأكد من حذف القسم '${department.name}'؟"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text("إلغاء"),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.purple),
              child: const Text("حذف",style: TextStyle(color: AppColors.offWhite),),
            ),
          ],
        ),
      );
      if (confirm == true) {
        deleteCubit.deleteDepartment(department.id!);
      }
    } else {
      showCustomToast(context, 'لا يمكن حذف القسم: معرف القسم غير موجود', success: false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<AddDepartmentCubit, AddDepartmentState>(
          listener: (context, state) {
            if (state is AddDepartmentSuccess) {
              showCustomToast(context, "تم إضافة القسم بنجاح", success: true);
              context.read<ShowDepartmentsCubit>().fetchDepartments();
            } else if (state is AddDepartmentFailure) {
              showCustomToast(context, "فشل إضافة القسم: ${state.error}", success: false);
            }
          },
        ),
        BlocListener<UpdateDepartmentCubit, UpdateDepartmentState>(
          listener: (context, state) {
            if (state is UpdateDepartmentSuccess) {
              showCustomToast(context, "تم تعديل القسم بنجاح", success: true);
              context.read<ShowDepartmentsCubit>().fetchDepartments();
            } else if (state is UpdateDepartmentFailure) {
              showCustomToast(context, "فشل تعديل القسم: ${state.error}", success: false);
            }
          },
        ),
        BlocListener<DeleteDepartmentCubit, DeleteDepartmentState>(
          listener: (context, state) {
            if (state is DeleteDepartmentSuccess) {
              showCustomToast(context, "تم حذف القسم بنجاح", success: true);
              context.read<ShowDepartmentsCubit>().fetchDepartments();
            } else if (state is DeleteDepartmentFailure) {
              showCustomToast(context, "فشل حذف القسم: ${state.error}", success: false);
            }
          },
        ),
      ],
      child: BlocBuilder<ShowDepartmentsCubit, ShowDepartmentsState>(
        builder: (context, state) {
          if (state is ShowDepartmentsLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ShowDepartmentsFailure) {
            return Center(child: Text('فشل تحميل الأقسام: ${state.error}'));
          } else if (state is ShowDepartmentsSuccess) {
            final departments = state.departments;

            return Scaffold(
              body: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton(
                        onPressed: _showAddDialog,
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.purple),
                        child: const Text('قسم جديد', style: TextStyle(color: Colors.white)),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Expanded(
                      child: GridView.builder(
                        itemCount: departments.length,
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          childAspectRatio: 3 / 2,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                        ),
                        itemBuilder: (context, index) {
                          final department = departments[index];
                          return DepartmentCard(
                            department: department,
                            onEdit: () async => _showEditDialog(department),
                            onDelete: () async => _deleteDepartment(department),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          } else {
            return const SizedBox();
          }
        },
      ),
    );
  }
}
