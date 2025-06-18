import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vera_clinic/core/theme/app_theme.dart';
import 'package:vera_clinic/features/departments/models/department.dart';
import 'package:vera_clinic/features/services/pages/edit_service_dialog.dart';
import '../models/service.dart';

class ServicesPage extends StatefulWidget {
  final List<Department> departments;

  const ServicesPage({super.key, required this.departments});

  @override
  State<ServicesPage> createState() => _ServicesPageState();
}

class _ServicesPageState extends State<ServicesPage> {
  final List<Service> services = [];

  void pickImage(void Function(VoidCallback fn) setStateDialog, void Function(String path) onImagePicked) {
    final uploadInput = html.FileUploadInputElement()..accept = 'image/*';
    uploadInput.click();

    uploadInput.onChange.listen((e) {
      final file = uploadInput.files?.first;
      if (file != null) {
        final reader = html.FileReader();
        reader.readAsDataUrl(file);
        reader.onLoadEnd.listen((e) {
          setStateDialog(() {
            onImagePicked(reader.result as String);
          });
        });
      }
    });
  }

  void _showAddServiceDialog() {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    final durationController = TextEditingController();
    final priceController = TextEditingController();
    final descriptionController = TextEditingController();
    String? selectedDepartment;
    String? selectedImagePath;

    void showInfoDialog(String title, String message) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              child: const Text('حسناً'),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      );
    }

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
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
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: durationController,
                                keyboardType: TextInputType.numberWithOptions(decimal: true),
                                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9,،]'))],
                                decoration: _inputDecoration('المدة (بالدقائق)'),
                                validator: (value) => value!.isEmpty ? 'يرجى إدخال المدة' : null,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.info_outline, color: Colors.grey),
                              onPressed: () {
                                showInfoDialog('مثال على المدة', 'يمكنك إدخال "90" (90 دقيقة)، أو "1,30" (ساعة ونصف).');
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: priceController,
                                keyboardType: TextInputType.numberWithOptions(decimal: true),
                                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9,،]'))],
                                decoration: _inputDecoration('السعر'),
                                validator: (value) => value!.isEmpty ? 'يرجى إدخال السعر' : null,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text('ل.س', style: TextStyle(fontWeight: FontWeight.bold)),
                            IconButton(
                              icon: const Icon(Icons.info_outline, color: Colors.grey),
                              onPressed: () {
                                showInfoDialog('مثال على السعر', 'أدخل السعر مثل: "50000" أو "50,000".');
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          decoration: _inputDecoration('القسم'),
                          items: widget.departments.map((dep) {
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
                          onTap: () => pickImage(setStateDialog, (path) => selectedImagePath = path),
                          child: Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: selectedImagePath == null
                                ? const Icon(Icons.camera_alt, size: 40, color: Colors.grey)
                                : ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(selectedImagePath!, fit: BoxFit.cover),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text('إلغاء', style: TextStyle(color: AppColors.purple)),
                            ),
                            const SizedBox(width: 12),
                            ElevatedButton(
                              onPressed: () {
                                if (!formKey.currentState!.validate() || selectedImagePath == null) return;

                                final cleanedPrice = priceController.text.replaceAll(RegExp(r'[,\،]'), '');
                                final cleanedDuration = durationController.text.replaceAll(RegExp(r'[,\،]'), '');

                                final newService = Service(
                                  name: nameController.text.trim(),
                                  description: descriptionController.text.trim(),
                                  durationMinutes: int.tryParse(cleanedDuration) ?? 0,
                                  price: double.tryParse(cleanedPrice) ?? 0.0,
                                  departmentName: selectedDepartment!,
                                  imagePath: selectedImagePath!,
                                );

                                setState(() => services.add(newService));
                                Navigator.pop(context);
                              },
                              style: ElevatedButton.styleFrom(backgroundColor: AppColors.purple),
                              child: const Text('إضافة'),
                            )
                          ],
                        )
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

  void _showServiceDetailsDialog(Service service, int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(service.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(service.imagePath, height: 100),
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
              Navigator.pop(context);
              _showEditServiceDialog(service, index);
            },
            child: const Text('تعديل'),
          ),
          TextButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('تأكيد الحذف'),
                  content: const Text('هل أنت متأكد أنك تريد حذف هذه الخدمة؟'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('إلغاء'),
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() => services.removeAt(index));
                        Navigator.pop(context); // إغلاق تأكيد الحذف
                      },
                      child: const Text('نعم، احذف', style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );
            },
            child: const Text('حذف', style: TextStyle(color: Colors.red)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إغلاق'),
          ),
        ],
      ),
    );
  }

  void _showEditServiceDialog(Service oldService, int index) {
    showDialog(
      context: context,
      builder: (context) => EditServiceDialog(
        oldService: oldService ,
        departments: widget.departments,
        onSave: (updatedService) {
          setState(() {
            services[index] = updatedService ;
          });
          Navigator.pop(context);
        },
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
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton.icon(
              onPressed: _showAddServiceDialog,
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text('خدمة جديدة', style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.purple),
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: services.isEmpty
                ? const Center(child: Text('لا توجد خدمات حالياً'))
                : ListView.builder(
              itemCount: services.length,
              itemBuilder: (context, index) {
                final s = services[index];
                return Card(
                  elevation: 4,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    leading: Image.network(s.imagePath, width: 50, height: 50, fit: BoxFit.cover),
                    title: Text(s.name),
                    subtitle: Text(
                        'المدة: ${s.durationMinutes} دقيقة | السعر: ${s.price} ليرة سورية\nالقسم: ${s.departmentName}'),
                    onTap: () => _showServiceDetailsDialog(s, index),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
