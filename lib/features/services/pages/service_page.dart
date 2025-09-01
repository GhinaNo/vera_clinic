import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/custom_toast.dart';
import '../cubit/ServicesCubit.dart';
import '../cubit/ServicesState.dart';
import '../models/service.dart';
import '../../departments/cubit/show_departments/show_departments_cubit.dart';
import '../../departments/cubit/show_departments/show_departments_state.dart';
import '../../departments/models/department.dart';
import 'edit_service_dialog.dart';

class ServicesPage extends StatefulWidget {
  const ServicesPage({super.key});
  @override
  State<ServicesPage> createState() => _ServicesPageState();
}

class _ServicesPageState extends State<ServicesPage> {
  final TextEditingController searchController = TextEditingController();
  final picker = ImagePicker();
  File? selectedImage;
  Uint8List? imageBytes;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ServicesCubit>().fetchServices();
    });
  }

  void _showAddServiceDialog(BuildContext context, List<Department> departments) async {
    final servicesCubit = context.read<ServicesCubit>();
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    final descController = TextEditingController();
    final priceController = TextEditingController();
    int? duration;
    String? departmentId;

    selectedImage = null;
    imageBytes = null;

    bool isFormValid() {
      return nameController.text.isNotEmpty &&
          priceController.text.isNotEmpty &&
          double.tryParse(priceController.text) != null &&
          duration != null &&
          departmentId != null &&
          (selectedImage != null || imageBytes != null);
    }

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          title: const Text("إضافة خدمة جديدة"),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: "اسم الخدمة"),
                    onChanged: (_) => setStateDialog(() {}),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: descController,
                    decoration: const InputDecoration(labelText: "الوصف"),
                    onChanged: (_) => setStateDialog(() {}),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: priceController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    decoration: const InputDecoration(
                      labelText: "السعر",
                      hintText: "أدخل رقم فقط",
                    ),
                    validator: (val) {
                      if (val == null || val.isEmpty) {
                        return "الحقل مطلوب";
                      }
                      if (double.tryParse(val) == null) {
                        return "يرجى إدخال رقم صحيح";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<int>(
                    decoration: const InputDecoration(labelText: "المدة (دقيقة)"),
                    items: [15, 30, 45, 60, 90, 120]
                        .map((e) => DropdownMenuItem(value: e, child: Text("$e دقيقة")))
                        .toList(),
                    onChanged: (val) {
                      setStateDialog(() => duration = val);
                    },
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: "القسم"),
                    items: departments
                        .map((d) => DropdownMenuItem(value: d.id.toString(), child: Text(d.name)))
                        .toList(),
                    onChanged: (val) => setStateDialog(() => departmentId = val),
                  ),
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: () async {
                      final XFile? picked = await picker.pickImage(source: ImageSource.gallery);
                      if (picked != null) {
                        if (kIsWeb) {
                          imageBytes = await picked.readAsBytes();
                        } else {
                          selectedImage = File(picked.path);
                        }
                        setStateDialog(() {});
                      }
                    },
                    child: Container(
                      width: 100,
                      height: 100,
                      color: Colors.grey[300],
                      child: (selectedImage != null)
                          ? Image.file(selectedImage!, fit: BoxFit.cover)
                          : (imageBytes != null)
                          ? Image.memory(imageBytes!, fit: BoxFit.cover)
                          : const Icon(Icons.camera_alt),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("إلغاء")),
            ElevatedButton(
              onPressed: isFormValid()
                  ? () async {
                final data = {
                  "name": nameController.text.trim(),
                  "description": descController.text.trim(),
                  "price": priceController.text.trim(),
                  "duration": duration.toString(),
                  "department_id": departmentId!,
                };

                await servicesCubit.addService(
                  data,
                  image: !kIsWeb ? selectedImage : null,
                  imageBytes: kIsWeb ? imageBytes : null,
                );
                Navigator.pop(ctx);
              }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
              ),
              child: const Text("إضافة",style: TextStyle(color:  AppColors.offWhite),),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditServiceDialog(BuildContext context, Service service, List<Department> departments) {
    showDialog(
      context: context,
      builder: (ctx) => BlocProvider.value(
        value: context.read<ServicesCubit>(),
        child: EditServiceDialog(service: service, departments: departments),
      ),
    );
  }

  void _showServiceDetails(Service service) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(service.name),
        content: SingleChildScrollView(
          child: Column(
            children: [
              service.imageUrl != null
                  ? Image.network(service.imageUrl!, height: 150, fit: BoxFit.cover)
                  : const Icon(Icons.image, size: 100, color: Colors.grey),
              const SizedBox(height: 10),
              Text(service.description ?? "لا يوجد وصف"),
              const SizedBox(height: 10),
              Text("السعر: ${service.price} ل.س"),
              Text("المدة: ${service.duration} دقيقة"),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("إغلاق")),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ShowDepartmentsCubit, ShowDepartmentsState>(
      builder: (context, deptState) {
        List<Department> departments = [];
        if (deptState is ShowDepartmentsSuccess) departments = deptState.departments;

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
              child: Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: () => _showAddServiceDialog(context, departments),
                    icon: const Icon(Icons.add,color: AppColors.offWhite,),
                    label:  Text("إضافة خدمة",style: TextStyle(color: AppColors.offWhite),),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: searchController,
                      decoration: InputDecoration(
                        hintText: "ابحث عن خدمة...",
                        prefixIcon: const Icon(Icons.search),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onChanged: (val) {
                        final cubit = context.read<ServicesCubit>();
                        if (val.isEmpty) {
                          cubit.fetchServices();
                        } else {
                          cubit.searchServices(val);
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: BlocBuilder<ServicesCubit, ServicesState>(
                builder: (context, state) {
                  if (state is ServicesLoading) return const Center(child: CircularProgressIndicator());
                  if (state is ServicesLoaded) {
                    final services = state.services;
                    if (services.isEmpty) return const Center(child: Text("لا توجد خدمات"));

                    return GridView.builder(
                      padding: const EdgeInsets.all(8),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 8,
                        crossAxisSpacing: 8,
                        childAspectRatio: 1.1,
                      ),
                      itemCount: services.length,
                      itemBuilder: (ctx, i) {
                        final s = services[i];
                        final imageUrl = s.imageUrl ?? '';

                        return GestureDetector(
                          onTap: () => _showServiceDetails(s),
                          child: Card(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: 4,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Expanded(
                                  child: ClipRRect(
                                    borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                                    child: imageUrl.isNotEmpty
                                        ? Image.network(
                                      imageUrl,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => Container(
                                        color: Colors.grey[300],
                                        child: const Icon(Icons.camera_alt, size: 40, color: Colors.white70),
                                      ),
                                    )
                                        : Container(
                                      color: Colors.grey[300],
                                      child: const Icon(Icons.camera_alt, size: 40, color: Colors.white70),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        s.name,
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Text("${s.price} ل.س | ${s.duration} دقيقة", style: const TextStyle(fontSize: 12)),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.edit, color: Colors.purple),
                                            onPressed: () => _showEditServiceDialog(context, s, departments),
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.delete, color: Colors.red),
                                            onPressed: () async {
                                              final confirm = await showDialog<bool>(
                                                context: context,
                                                builder: (_) => AlertDialog(
                                                  title: const Text("تأكيد الحذف"),
                                                  content: const Text("هل أنت متأكد من حذف هذه الخدمة؟"),
                                                  actions: [
                                                    TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("إلغاء")),
                                                    ElevatedButton(
                                                      onPressed: () => Navigator.pop(context, true),
                                                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                                      child: const Text("حذف"),
                                                    ),
                                                  ],
                                                ),
                                              );
                                              if (confirm ?? false) {
                                                try {
                                                  await context.read<ServicesCubit>().deleteService(s.id);
                                                  showCustomToast(context, "تم حذف الخدمة بنجاح", success: true);
                                                } catch (e) {
                                                  showCustomToast(context, "فشل حذف الخدمة", success: false);
                                                }
                                              }
                                            },
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  }
                  if (state is ServicesError) return Center(child: Text("خطأ: ${state.message}"));
                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
