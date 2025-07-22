import 'dart:io' show File;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:vera_clinic/core/theme/app_theme.dart';
import 'package:vera_clinic/features/departments/models/department.dart';
import 'package:vera_clinic/features/departments/cubit/departments_cubit.dart';
import 'package:vera_clinic/features/services/cubit/ServicesCubit.dart';
import 'package:vera_clinic/features/services/models/service.dart';
import 'package:vera_clinic/features/services/pages/edit_service_dialog.dart';

class ServicesPage extends StatelessWidget {
  const ServicesPage({super.key, required List<Department> departments});

  Future<void> pickImage(Function(String path) onImagePicked) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      onImagePicked(image.path);
    }
  }

  void _showAddServiceDialog(BuildContext context, List<Department> departments) {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    final priceController = TextEditingController();
    final descriptionController = TextEditingController();
    String? selectedDepartment;
    String? selectedImagePath;
    int? selectedDurationMinutes;

    final numberFormat = NumberFormat("#,###", "ar");

    void formatPrice() {
      final text = priceController.text.replaceAll(RegExp(r'[^\d]'), '');
      if (text.isEmpty) return;
      final number = int.parse(text);
      priceController.value = TextEditingValue(
        text: numberFormat.format(number),
        selection: TextSelection.collapsed(offset: numberFormat.format(number).length),
      );
    }

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (contextSB, setStateDialog) {
            return Dialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              backgroundColor: AppColors.offWhite,
              child: Container(
                width: 600,
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('إضافة خدمة جديدة',
                            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.purple)),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: nameController,
                          decoration: _inputDecoration('اسم الخدمة'),
                          validator: (value) => value!.isEmpty ? 'يرجى إدخال اسم الخدمة' : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: descriptionController,
                          maxLines: 3,
                          decoration: _inputDecoration('وصف الخدمة'),
                          validator: (value) => value!.isEmpty ? 'يرجى إدخال الوصف' : null,
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<int>(
                          decoration: _inputDecoration('المدة'),
                          value: selectedDurationMinutes,
                          items: [30, 45, 60, 90, 120].map((minutes) {
                            return DropdownMenuItem(
                              value: minutes,
                              child: Text('$minutes دقيقة'),
                            );
                          }).toList(),
                          onChanged: (value) => setStateDialog(() => selectedDurationMinutes = value),
                          validator: (value) => value == null ? 'يرجى اختيار المدة' : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: priceController,
                          keyboardType: TextInputType.number,
                          decoration: _inputDecoration('السعر').copyWith(suffixText: 'ل.س'),
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          onChanged: (value) => formatPrice(),
                          validator: (value) => value!.isEmpty ? 'يرجى إدخال السعر' : null,
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          decoration: _inputDecoration('القسم'),
                          items: departments.map((dep) {
                            return DropdownMenuItem(
                              value: dep.name,
                              child: Text(dep.name),
                            );
                          }).toList(),
                          onChanged: (value) => setStateDialog(() => selectedDepartment = value),
                          validator: (value) => value == null ? 'يرجى اختيار القسم' : null,
                        ),
                        const SizedBox(height: 16),
                        GestureDetector(
                          onTap: () async {
                            await pickImage((path) {
                              setStateDialog(() {
                                selectedImagePath = path;
                              });
                            });
                          },
                          child: Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: selectedImagePath == null
                                ? const Icon(Icons.camera_alt, size: 40, color: Colors.grey)
                                : kIsWeb
                                ? Image.network(selectedImagePath!, fit: BoxFit.cover)
                                : Image.file(File(selectedImagePath!), fit: BoxFit.cover),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () => Navigator.pop(dialogContext),
                              child: Text('إلغاء', style: TextStyle(color: AppColors.purple)),
                            ),
                            const SizedBox(width: 12),
                            ElevatedButton(
                              onPressed: () {
                                if (!formKey.currentState!.validate() || selectedImagePath == null) return;

                                final cleanedPrice = priceController.text.replaceAll(RegExp(r'[^\d]'), '');

                                final newService = Service(
                                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                                  name: nameController.text.trim(),
                                  description: descriptionController.text.trim(),
                                  durationMinutes: selectedDurationMinutes!,
                                  price: double.tryParse(cleanedPrice) ?? 0.0,
                                  departmentName: selectedDepartment!,
                                  imagePath: selectedImagePath!,
                                );


                                context.read<ServicesCubit>().addService(newService);
                                Navigator.pop(dialogContext);
                              },
                              style: ElevatedButton.styleFrom(backgroundColor: AppColors.purple),
                              child: const Text('إضافة', style: TextStyle(color: Colors.white)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showEditServiceDialog(BuildContext context, Service oldService, int index, List<Department> departments) {
    showDialog(
      context: context,
      builder: (dialogContext) => EditServiceDialog(
        oldService: oldService,
        departments: departments,
        onSave: (updatedService) {
          context.read<ServicesCubit>().updateService(index, updatedService);
          Navigator.pop(dialogContext);
        },
      ),
    );
  }

  void _showServiceDetailsDialog(BuildContext context, Service service, int index, List<Department> departments) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(service.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            kIsWeb
                ? Image.network(service.imagePath, height: 100)
                : Image.file(File(service.imagePath), height: 100),
            const SizedBox(height: 10),
            Text('الوصف: ${service.description}'),
            Text('المدة: ${service.durationMinutes} دقيقة'),
            Text('السعر: ${service.price} ل.س'),
            Text('القسم: ${service.departmentName}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              _showEditServiceDialog(context, service, index, departments);
            },
            child: const Text('تعديل'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              showDialog(
                context: context,
                builder: (confirmContext) => AlertDialog(
                  content: const Text('هل أنت متأكد أنك تريد حذف هذه الخدمة؟'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(confirmContext),
                      child: const Text('إلغاء'),
                    ),
                    TextButton(
                      onPressed: () {
                        context.read<ServicesCubit>().removeService(index);
                        Navigator.pop(confirmContext);
                      },
                      child: const Text('احذف', style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );
            },
            child: const Text('حذف', style: TextStyle(color: Colors.red)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('إغلاق'),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      filled: true,
      fillColor: Colors.white,
    );
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final width = media.size.width;

    int crossAxisCount = 1;
    if (width > 1200) {
      crossAxisCount = 4;
    } else if (width > 800) {
      crossAxisCount = 3;
    } else if (width > 600) {
      crossAxisCount = 2;
    }

    return BlocBuilder<DepartmentsCubit, List<Department>>(
      builder: (context, departments) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton.icon(
                  onPressed: () => _showAddServiceDialog(context, departments),
                  icon: const Icon(Icons.add, color: Colors.white),
                  label: const Text('خدمة جديدة', style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.purple),
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: BlocBuilder<ServicesCubit, List<Service>>(
                  builder: (context, services) {
                    if (services.isEmpty) {
                      return const Center(child: Text('لا توجد خدمات حالياً'));
                    }

                    if (crossAxisCount == 1) {
                      return ListView.builder(
                        itemCount: services.length,
                        itemBuilder: (context, index) {
                          final s = services[index];
                          return Card(
                            elevation: 4,
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            child: ListTile(
                              leading: kIsWeb
                                  ? Image.network(s.imagePath, width: 50, height: 50, fit: BoxFit.cover)
                                  : Image.file(File(s.imagePath), width: 50, height: 50, fit: BoxFit.cover),
                              title: Text(s.name),
                              subtitle: Text(
                                'المدة: ${s.durationMinutes} دقيقة | السعر: ${s.price} ليرة سورية\nالقسم: ${s.departmentName}',
                              ),
                              onTap: () => _showServiceDetailsDialog(context, s, index, departments),
                            ),
                          );
                        },
                      );
                    }

                    return GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 3 / 2,
                      ),
                      itemCount: services.length,
                      itemBuilder: (context, index) {
                        final s = services[index];
                        return GestureDetector(
                          onTap: () => _showServiceDetailsDialog(context, s, index, departments),
                          child: Card(
                            elevation: 4,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Expanded(
                                  child: ClipRRect(
                                    borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                                    child: kIsWeb
                                        ? Image.network(s.imagePath, fit: BoxFit.cover)
                                        : Image.file(File(s.imagePath), fit: BoxFit.cover),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(s.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                                      const SizedBox(height: 4),
                                      Text('المدة: ${s.durationMinutes} دقيقة'),
                                      Text('السعر: ${s.price} ل.س'),
                                      Text('القسم: ${s.departmentName}'),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
