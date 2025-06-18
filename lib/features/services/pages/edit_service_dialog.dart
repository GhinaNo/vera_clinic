import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:vera_clinic/core/widgets/edit_form_dialog.dart';
import 'package:vera_clinic/features/departments/models/department.dart';
import 'package:vera_clinic/features/services/models/service.dart';


class EditServiceDialog extends StatefulWidget {
  final Service oldService;
  final List<Department> departments;
  final void Function(Service updatedService) onSave;

  const EditServiceDialog({
    super.key,
    required this.oldService,
    required this.departments,
    required this.onSave,
  });

  @override
  State<EditServiceDialog> createState() => _EditServiceDialogState();
}

class _EditServiceDialogState extends State<EditServiceDialog> {
  final formKey = GlobalKey<FormState>();
  late TextEditingController nameController;
  late TextEditingController descriptionController;
  late TextEditingController durationController;
  late TextEditingController priceController;
  String? selectedDepartment;
  String? selectedImagePath;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.oldService.name);
    descriptionController = TextEditingController(text: widget.oldService.description);
    durationController = TextEditingController(text: widget.oldService.durationMinutes.toString());
    priceController = TextEditingController(text: widget.oldService.price.toString());
    selectedDepartment = widget.oldService.departmentName;
    selectedImagePath = widget.oldService.imagePath;
  }

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
    return StatefulBuilder(
      builder: (context, setStateDialog) {
        return Form(
          key: formKey,
          child: EditFormDialog(
            title: 'تعديل الخدمة',
            onCancel: () => Navigator.pop(context),
            onSave: () {
              if (!formKey.currentState!.validate()) return;

              final updatedService = Service(
                name: nameController.text,
                description: descriptionController.text,
                durationMinutes: int.tryParse(durationController.text) ?? 0,
                price: double.tryParse(priceController.text) ?? 0.0,
                departmentName: selectedDepartment!,
                imagePath: selectedImagePath ?? '',
              );

              widget.onSave(updatedService);
            },
            fields: [
              TextFormField(
                controller: nameController,
                decoration: _inputDecoration('اسم الخدمة'),
                validator: (value) => value!.isEmpty ? 'يرجى إدخال الاسم' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: descriptionController,
                decoration: _inputDecoration('الوصف'),
                validator: (value) => value!.isEmpty ? 'يرجى إدخال الوصف' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: durationController,
                decoration: _inputDecoration('المدة'),
                validator: (value) => value!.isEmpty ? 'يرجى إدخال المدة' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: priceController,
                decoration: _inputDecoration('السعر'),
                validator: (value) => value!.isEmpty ? 'يرجى إدخال السعر' : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: selectedDepartment,
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
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () => pickImage(setStateDialog, (path) => selectedImagePath = path),
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: selectedImagePath == null
                      ? const Icon(Icons.camera_alt)
                      : Image.network(selectedImagePath!, fit: BoxFit.cover),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
