import 'dart:convert';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:vera_clinic/core/services/token_storage.dart';
import 'package:vera_clinic/core/theme/app_theme.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:vera_clinic/core/widgets/custom_toast.dart';
import 'employee_cubit.dart';
import 'employee_state.dart';
import 'employee_model.dart';
import 'package:http/http.dart' as http;

class EmployeePage extends StatefulWidget {
  const EmployeePage({super.key});

  @override
  State<EmployeePage> createState() => _EmployeePageState();
}

class _EmployeePageState extends State<EmployeePage> {
  bool isArchiveMode = false;
  String searchQuery = '';

  void _showAddEmployeeDialog(EmployeeModel? employee) {
    final cubit = context.read<EmployeeCubit>();
    showDialog(
      context: context,
      builder: (_) => AddEmployeeDialog(
        cubit: cubit,
        initialData: employee,
        onAdded: () {
          if (isArchiveMode) {
            cubit.fetchArchivedEmployees();
          } else {
            cubit.fetchEmployees();
          }
        },
      ),
    );
  }

  void _toggleArchiveMode() {
    setState(() => isArchiveMode = !isArchiveMode);
    final cubit = context.read<EmployeeCubit>();
    if (isArchiveMode) {
      cubit.fetchArchivedEmployees();
    } else {
      cubit.fetchEmployees();
    }
  }

  void _onSearchChanged(String val) {
    setState(() => searchQuery = val.trim());
    final cubit = context.read<EmployeeCubit>();
    if (searchQuery.isEmpty) {
      if (isArchiveMode) {
        cubit.fetchArchivedEmployees();
      } else {
        cubit.fetchEmployees();
      }
    } else {
      cubit.searchEmployees(query: searchQuery);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: ui.TextDirection.rtl,
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: () => _showAddEmployeeDialog(null),
                    icon: const Icon(Icons.add, color: AppColors.offWhite),
                    label: const Text('إضافة موظف', style: TextStyle(color: AppColors.offWhite)),
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.purple),
                  ),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: _toggleArchiveMode,
                    icon: Icon(isArchiveMode ? Icons.list : Icons.archive, color: AppColors.offWhite),
                    label: Text(isArchiveMode ? 'عرض الموظفين' : 'عرض الأرشيف',
                        style: const TextStyle(color: AppColors.offWhite)),
                    style: TextButton.styleFrom(backgroundColor: AppColors.purple),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Icon(Icons.receipt_long, color: AppColors.purple, size: 30),
                  const SizedBox(width: 10),
                  Text(isArchiveMode ? 'الأرشيف' : 'قائمة الموظفين',
                      style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.purple)),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: const InputDecoration(
                  hintText: '🔍 ابحث عن موظف...',
                  border: OutlineInputBorder(),
                ),
                onChanged: _onSearchChanged,
              ),
              const SizedBox(height: 16),
              Expanded(
                child: BlocBuilder<EmployeeCubit, EmployeeState>(
                  builder: (context, state) {
                    List<EmployeeModel> employees = [];

                    if (isArchiveMode) {
                      if (state is ArchivedEmployeesLoading) return const Center(child: CircularProgressIndicator());
                      if (state is ArchivedEmployeesLoaded) employees = state.archivedEmployees;
                      if (state is ArchivedEmployeesError) return Center(child: Text(state.message));
                    } else {
                      if (state is EmployeeLoading || state is EmployeeSearching) return const Center(child: CircularProgressIndicator());
                      if (state is EmployeeLoaded) employees = state.employees;
                      if (state is EmployeeSearchResults) employees = state.employees;
                      if (state is EmployeeError || state is EmployeeSearchError) {
                        final msg = state is EmployeeError ? state.message : (state as EmployeeSearchError).message;
                        return Center(child: Text(msg));
                      }
                    }

                    employees = employees.where((e) {
                      if (isArchiveMode) return e.archivedAt != null;
                      return e.archivedAt == null;
                    }).toList();

                    if (searchQuery.isNotEmpty) {
                      employees = employees.where((e) {
                        final nameMatch = e.user.name.toLowerCase().contains(searchQuery.toLowerCase());
                        final roleMatch = (e.user.role ?? e.role ?? '').toLowerCase().contains(searchQuery.toLowerCase());
                        return nameMatch || roleMatch;
                      }).toList();
                    }

                    if (employees.isEmpty) {
                      return Center(
                        child: Text(
                          searchQuery.isEmpty
                              ? (isArchiveMode ? 'لا يوجد موظفين في الأرشيف' : 'لا يوجد موظفين حالياً')
                              : 'لا يوجد نتائج للبحث عن "$searchQuery"',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      );
                    }

                    return AnimationLimiter(
                      child: ListView.builder(
                        itemCount: employees.length,
                        itemBuilder: (_, index) {
                          final emp = employees[index];
                          return AnimationConfiguration.staggeredList(
                            position: index,
                            duration: const Duration(milliseconds: 400),
                            child: SlideAnimation(
                              verticalOffset: 50.0,
                              child: FadeInAnimation(
                                child: Card(
                                  elevation: 2,
                                  margin: const EdgeInsets.symmetric(vertical: 8),
                                  child: Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(emp.user.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                                              Text('الدور: ${emp.user.role ?? emp.role ?? ""}'),
                                              Text('البريد: ${emp.user.email}'),
                                              Text(
                                                emp.archivedAt != null
                                                    ? '🗄️ الحالة: مؤرشف'
                                                    : (emp.user.status == 'blocked' ? '⛔ الحالة: محظور' : '✅ الحالة: نشط'),
                                                style: TextStyle(
                                                  color: emp.archivedAt != null
                                                      ? Colors.red
                                                      : (emp.user.status == 'blocked' ? Colors.orange : Colors.green),
                                                ),
                                              ),
                                              if (emp.createdAt != null) Text('📅 انضم: ${emp.createdAt!.substring(0, 10)}'),
                                              if (emp.updatedAt != null) Text('✏️ آخر تحديث: ${emp.updatedAt!.substring(0, 10)}'),
                                            ],
                                          ),
                                        ),
                                        Row(
                                          children: [
                                            if (!isArchiveMode)
                                              IconButton(
                                                icon: const Icon(Icons.edit),
                                                tooltip: 'تعديل الموظف',
                                                onPressed: () => _showAddEmployeeDialog(emp),
                                              ),
                                            IconButton(
                                              icon: Icon(isArchiveMode ? Icons.unarchive : Icons.archive),
                                              tooltip: isArchiveMode ? 'استرجاع الموظف' : 'أرشفة الموظف',
                                              onPressed: () async {
                                                final confirm = await showDialog<bool>(
                                                  context: context,
                                                  builder: (_) => AlertDialog(
                                                    title: Text(isArchiveMode ? 'استرجاع موظف؟' : 'أرشفة موظف؟'),
                                                    content: Text(isArchiveMode
                                                        ? 'هل أنت متأكد من استرجاع الموظف؟'
                                                        : 'هل أنت متأكد من أرشفة الموظف؟'),
                                                    actions: [
                                                      TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('إلغاء')),
                                                      ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('تأكيد')),
                                                    ],
                                                  ),
                                                );
                                                if (confirm != true) return;

                                                final cubit = context.read<EmployeeCubit>();
                                                await cubit.toggleArchiveEmployee(
                                                  id: emp.id,
                                                  isArchiveMode: isArchiveMode,
                                                );

                                                if (isArchiveMode) {
                                                  cubit.fetchArchivedEmployees();
                                                } else {
                                                  cubit.fetchEmployees();
                                                }

                                                showCustomToast(
                                                  context,
                                                  isArchiveMode ? 'تم استرجاع الموظف بنجاح' : 'تم أرشفة الموظف بنجاح',
                                                  success: true,
                                                );
                                              },
                                            ),
                                            if (emp.user.role != 'admin')
                                              IconButton(
                                                icon: Icon(emp.user.status == 'blocked' ? Icons.check_circle : Icons.block),
                                                tooltip: emp.user.status == 'blocked' ? 'تفعيل الموظف' : 'حظر الموظف',
                                                onPressed: () async {
                                                  final confirm = await showDialog<bool>(
                                                    context: context,
                                                    builder: (_) => AlertDialog(
                                                      title: Text(emp.user.status == 'blocked' ? 'تفعيل موظف؟' : 'حظر موظف؟'),
                                                      content: Text(emp.user.status == 'blocked'
                                                          ? 'هل أنت متأكد من تفعيل الموظف؟'
                                                          : 'هل أنت متأكد من حظر الموظف؟'),
                                                      actions: [
                                                        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('إلغاء')),
                                                        ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('تأكيد')),
                                                      ],
                                                    ),
                                                  );

                                                  if (confirm != true) return;

                                                  final cubit = context.read<EmployeeCubit>();
                                                  await cubit.toggleStatusEmployee(employeeId: emp.id);

                                                  showCustomToast(
                                                    context,
                                                    emp.user.status == 'blocked' ? 'تم تفعيل الموظف بنجاح' : 'تم حظر الموظف بنجاح',
                                                    success: true,
                                                  );
                                                },
                                              ),

                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ----------------- AddEmployeeDialog -------------------

class AddEmployeeDialog extends StatefulWidget {
  final VoidCallback onAdded;
  final EmployeeModel? initialData;
  final EmployeeCubit cubit;

  const AddEmployeeDialog({
    super.key,
    required this.onAdded,
    this.initialData,
    required this.cubit,
  });

  @override
  State<AddEmployeeDialog> createState() => _AddEmployeeDialogState();
}

class _AddEmployeeDialogState extends State<AddEmployeeDialog> {
  final _formKey = GlobalKey<FormState>();
  String name = '', password = '', passwordConfirmation = '', role = '', email = '';
  String? selectedDepartmentId;
  DateTime? hireDate;
  List<Map<String, dynamic>> departments = [];
  String? token;
  bool _obscurePassword = true, _obscureConfirmPassword = true;
  bool showPasswordFields = true;

  @override
  void initState() {
    super.initState();
    _loadToken();
    _loadInitialData();
  }

  void _loadInitialData() {
    if (widget.initialData != null) {
      final emp = widget.initialData!;
      name = emp.user.name;
      email = emp.user.email;
      role = emp.user.role ?? '';
      selectedDepartmentId = emp.departmentId?.toString();
      hireDate = emp.hireDate != null ? DateTime.tryParse(emp.hireDate!) : null;
      password = '';
      passwordConfirmation = '';
      showPasswordFields = false;
    }
  }

  Future<void> _loadToken() async {
    token = await TokenStorage.getToken();
    if (token != null) fetchDepartments();
  }

  Future<void> fetchDepartments() async {
    try {
      final response = await http.get(
        Uri.parse("http://127.0.0.1:8000/web/admin/departments"),
        headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        List<Map<String, dynamic>> loadedDepartments = [];
        if (data is List) loadedDepartments = List<Map<String, dynamic>>.from(data);
        else if (data is Map && data['data'] is List)
          loadedDepartments = List<Map<String, dynamic>>.from(data['data']);
        setState(() => departments = loadedDepartments);
      }
    } catch (e) {
      showCustomToast(context, "فشل جلب الأقسام: $e", success: false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: AppColors.offWhite,
      content: SingleChildScrollView(
        child: Container(
          width: 600,
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Text(widget.initialData != null ? 'تعديل بيانات الموظف' : 'إضافة موظف جديد',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.purple)),
                const SizedBox(height: 20),
                TextFormField(
                  decoration: _inputDecoration('اسم الموظف'),
                  initialValue: name,
                  onChanged: (v) => name = v,
                  validator: (val) => val == null || val.isEmpty ? 'الرجاء إدخال الاسم' : null,
                ),
                const SizedBox(height: 10),
                if (widget.initialData == null || showPasswordFields) ...[
                  TextFormField(
                    decoration: _inputDecoration('كلمة المرور').copyWith(
                      suffixIcon: IconButton(
                        icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                      ),
                    ),
                    obscureText: _obscurePassword,
                    initialValue: password,
                    onChanged: (v) => password = v,
                    validator: (val) {
                      if ((widget.initialData == null || val!.isNotEmpty) && val!.length < 6)
                        return 'كلمة المرور يجب أن تكون 6 محارف على الأقل';
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    decoration: _inputDecoration('تأكيد كلمة المرور').copyWith(
                      suffixIcon: IconButton(
                        icon: Icon(_obscureConfirmPassword ? Icons.visibility_off : Icons.visibility),
                        onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                      ),
                    ),
                    obscureText: _obscureConfirmPassword,
                    initialValue: passwordConfirmation,
                    onChanged: (v) => passwordConfirmation = v,
                    validator: (val) {
                      if (password.isNotEmpty && val != password) return 'تأكيد كلمة المرور لا يتطابق';
                      return null;
                    },
                  ),
                ],
                if (widget.initialData != null && !showPasswordFields)
                  TextButton(
                    onPressed: () => setState(() => showPasswordFields = true),
                    child: const Text('تغيير كلمة المرور'),
                  ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  decoration: _inputDecoration('الدور الوظيفي'),
                  value: role.isNotEmpty ? role : null,
                  items: const [
                    DropdownMenuItem(value: 'admin', child: Text('مدير')),
                    DropdownMenuItem(value: 'doctor', child: Text('طبيب')),
                    DropdownMenuItem(value: 'receptionist', child: Text('موظف استقبال')),
                  ],
                  onChanged: (v) => setState(() => role = v ?? ''),
                  validator: (val) => val == null || val.isEmpty ? 'اختر الدور الوظيفي' : null,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  decoration: _inputDecoration('البريد الإلكتروني'),
                  initialValue: email,
                  onChanged: (v) => email = v,
                  validator: (val) => val == null || val.isEmpty ? 'الرجاء إدخال البريد الإلكتروني' : null,
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  decoration: _inputDecoration('اختر القسم'),
                  value: selectedDepartmentId,
                  items: departments
                      .map((d) => DropdownMenuItem(value: d['id'].toString(), child: Text(d['name'] ?? '')))
                      .toList(),
                  onChanged: (v) => setState(() => selectedDepartmentId = v),
                  validator: (val) => val == null || val.isEmpty ? 'اختر القسم' : null,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Text('تاريخ التوظيف: '),
                    Text(hireDate == null ? 'لم يتم التحديد' : DateFormat('yyyy-MM-dd').format(hireDate!)),
                    IconButton(
                      icon: const Icon(Icons.calendar_today),
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: context,
                          firstDate: DateTime(2000),
                          lastDate: DateTime.now(),
                          initialDate: hireDate ?? DateTime.now(),
                        );
                        if (picked != null) setState(() => hireDate = picked);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
        ElevatedButton(onPressed: _submit, child: Text(widget.initialData != null ? 'حفظ' : 'إضافة')),
      ],
    );
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final cubit = widget.cubit;
    final hireDateStr = hireDate == null ? '' : DateFormat('yyyy-MM-dd').format(hireDate!);

    if (widget.initialData != null) {
      await cubit.updateEmployee(
        id: widget.initialData!.id,
        name: name,
        password: password.isNotEmpty ? password : null,
        passwordConfirmation: passwordConfirmation.isNotEmpty ? passwordConfirmation : null,
        role: role,
        email: email,
        departmentId: selectedDepartmentId!,
        hireDate: hireDateStr,
      );
      showCustomToast(context, 'تم تعديل بيانات الموظف بنجاح', success: true);
    } else {
      if (password.isEmpty || passwordConfirmation.isEmpty) {
        showCustomToast(context, 'يجب إدخال كلمة المرور وتأكيدها', success: false);
        return;
      }
      await cubit.addEmployee(
        name: name,
        password: password,
        passwordConfirmation: passwordConfirmation,
        role: role,
        email: email,
        departmentId: selectedDepartmentId!,
        hireDate: hireDateStr,
      );
      showCustomToast(context, 'تم إضافة الموظف بنجاح', success: true);
    }

    widget.onAdded();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) Navigator.pop(context);
    });
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      filled: true,
      fillColor: Colors.white,
    );
  }
}
