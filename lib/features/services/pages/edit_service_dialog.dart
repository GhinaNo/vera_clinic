import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show Uint8List, kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/custom_toast.dart';
import '../../departments/cubit/show_departments/show_departments_cubit.dart';
import '../../departments/cubit/show_departments/show_departments_state.dart';
import '../../departments/models/department.dart';
import '../cubit/ServicesCubit.dart';
import '../cubit/ServicesState.dart';
import '../models/service.dart';

class EditServiceDialog extends StatefulWidget {
  final Service service;
  const EditServiceDialog({super.key, required this.service});

  @override
  State<EditServiceDialog> createState() => _EditServiceDialogState();
}

class _EditServiceDialogState extends State<EditServiceDialog> {
  final formKey = GlobalKey<FormState>();
  late TextEditingController nameController;
  late TextEditingController descController;
  late TextEditingController priceController;
  int? duration;
  String? departmentId;
  File? newImage;
  Uint8List? newImageBytes;
  final picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.service.name);
    descController = TextEditingController(text: widget.service.description ?? "");
    priceController = TextEditingController(text: widget.service.price.toString());
    duration = widget.service.duration;
    departmentId = widget.service.departmentId.toString();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ServicesCubit, ServicesState>(
      listener: (context, state) {
        if (state is ServiceActionSuccess) {
          context.read<ServicesCubit>().fetchServices();
          Navigator.pop(context);
          showCustomToast(context, "تم حفظ التعديلات بنجاح", success: true);
        } else if (state is ServicesError) {
          showCustomToast(context, state.message, success: false);
        }
      },
      child: AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("تعديل الخدمة"),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              children: [
                TextFormField(controller: nameController, decoration: const InputDecoration(labelText: "اسم الخدمة"), validator: (val) => val!.isEmpty ? "مطلوب" : null),
                const SizedBox(height: 12),
                TextFormField(controller: descController, decoration: const InputDecoration(labelText: "الوصف")),
                const SizedBox(height: 12),
                TextFormField(
                  controller: priceController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: const InputDecoration(labelText: "السعر"),
                  validator: (val) {
                    if (val == null || val.isEmpty) return "مطلوب";
                    if (double.tryParse(val) == null) return "رقم غير صحيح";
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<int>(
                  value: duration,
                  decoration: const InputDecoration(labelText: "المدة"),
                  items: [15, 30, 45, 60, 90, 120].map((e) => DropdownMenuItem(value: e, child: Text("$e دقيقة"))).toList(),
                  onChanged: (val) => setState(() => duration = val),
                  validator: (val) => val == null ? "اختر المدة" : null,
                ),
                const SizedBox(height: 12),
                BlocBuilder<ShowDepartmentsCubit, ShowDepartmentsState>(
                  builder: (context, state) {
                    List<Department> departments = [];
                    if (state is ShowDepartmentsSuccess) departments = state.departments;
                    return DropdownButtonFormField<String>(
                      value: departmentId,
                      decoration: const InputDecoration(labelText: "القسم"),
                      items: departments.map((d) => DropdownMenuItem(value: d.id.toString(), child: Text(d.name))).toList(),
                      onChanged: (val) => setState(() => departmentId = val),
                      validator: (val) => val == null ? "اختر القسم" : null,
                    );
                  },
                ),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: () async {
                    final XFile? picked = await picker.pickImage(source: ImageSource.gallery);
                    if (picked != null) {
                      if (kIsWeb) newImageBytes = await picked.readAsBytes();
                      else newImage = File(picked.path);
                      setState(() {});
                    }
                  },
                  child: Container(
                    width: double.infinity,
                    height: 120,
                    decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)),
                    child: _buildImagePreview(),
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("إلغاء")),
          ElevatedButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;
              if (duration == null || departmentId == null) return;

              final confirm = await showDialog<bool>(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text("تأكيد الحفظ"),
                  content: const Text("هل تريد حفظ التعديلات؟"),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("إلغاء")),
                    ElevatedButton(onPressed: () => Navigator.pop(context, true), style: ElevatedButton.styleFrom(backgroundColor: Colors.purple), child: const Text("حفظ", style: TextStyle(color: AppColors.offWhite))),
                  ],
                ),
              );

              if (confirm ?? false) {
                final data = {
                  "name": nameController.text,
                  "description": descController.text,
                  "price": priceController.text,
                  "duration": duration.toString(),
                  "department_id": departmentId!,
                };
                context.read<ServicesCubit>().updateService(
                  widget.service.id,
                  data,
                  image: (!kIsWeb && newImage != null) ? newImage : null,
                  imageBytes: (kIsWeb && newImageBytes != null) ? newImageBytes : null,
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
            child: const Text("حفظ", style: TextStyle(color: AppColors.offWhite)),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePreview() {
    if (newImage != null) return Image.file(newImage!, fit: BoxFit.cover);
    if (newImageBytes != null) return Image.memory(newImageBytes!, fit: BoxFit.cover);
    if (widget.service.imageUrl != null && widget.service.imageUrl!.startsWith('http')) return Image.network(widget.service.imageUrl!, fit: BoxFit.cover);
    return const Icon(Icons.camera_alt);
  }
}
