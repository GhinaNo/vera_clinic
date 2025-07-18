import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vera_clinic/core/theme/app_theme.dart';
import 'package:vera_clinic/features/departments/models/department.dart';
import 'package:vera_clinic/features/services/pages/edit_service_dialog.dart';
import '../models/service.dart';
import 'package:intl/intl.dart';

class ServicesPage extends StatefulWidget {
  final List<Department> departments;

  const ServicesPage({super.key, required this.departments});

  @override
  State<ServicesPage> createState() => _ServicesPageState();
}

class _ServicesPageState extends State<ServicesPage> {
  @override
  void initState() {
    super.initState();
    services.addAll([
      Service(
        name: 'تنظيف بشرة عميق',
        description: 'تنظيف عميق للبشرة باستخدام أجهزة وتقنيات حديثة.',
        durationMinutes: 90,
        price: 50000,
        departmentName: widget.departments.isNotEmpty ? widget.departments.first.name : 'قسم البشرة',
        imagePath: "C:/Users/Lenovo/Downloads/logo1.png",
      ),
      Service(
        name: 'جلسة ليزر إزالة شعر',
        description: 'جلسة ليزر لإزالة الشعر بدون ألم.',
        durationMinutes: 60,
        price: 80000,
        departmentName: widget.departments.length > 1 ? widget.departments[1].name : 'قسم الليزر',
        imagePath: 'https://via.placeholder.com/150',
      ),
    ]);
  }

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
                                final cleanedPrice = priceController.text.replaceAll(RegExp(r'[^\d]'), '');
                                final newService = Service(
                                  name: nameController.text.trim(),
                                  description: descriptionController.text.trim(),
                                  durationMinutes: selectedDurationMinutes!,
                                  price: double.tryParse(cleanedPrice) ?? 0.0,
                                  departmentName: selectedDepartment!,
                                  imagePath: selectedImagePath!,
                                );
                                setState(() => services.add(newService));
                                Navigator.pop(context);
                              },
                              style: ElevatedButton.styleFrom(backgroundColor: AppColors.purple),
                              child: const Text('إضافة', style: TextStyle(color: AppColors.offWhite)),
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
                  content: const Text('هل أنت متأكد أنك تريد حذف هذه الخدمة؟'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('إلغاء'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.pop(context);
                        setState(() => services.removeAt(index));
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
        oldService: oldService,
        departments: widget.departments,
        onSave: (updatedService) {
          setState(() {
            services[index] = updatedService;
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
                      'المدة: ${s.durationMinutes} دقيقة | السعر: ${s.price} ليرة سورية\nالقسم: ${s.departmentName}',
                    ),
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
