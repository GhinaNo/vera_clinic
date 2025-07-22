import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vera_clinic/features/services/models/service.dart';
import '../../../core/theme/app_theme.dart';
import '../../services/cubit/ServicesCubit.dart';
import '../model/offersModel.dart';
import 'SelectServicesPage.dart';

class AddOrEditOfferPage extends StatefulWidget {
  final Offer? offer;

  const AddOrEditOfferPage({super.key, this.offer});

  @override
  State<AddOrEditOfferPage> createState() => _AddOrEditOfferPageState();
}

class _AddOrEditOfferPageState extends State<AddOrEditOfferPage> {
  final titleController = TextEditingController();
  final discountController = TextEditingController();
  DateTime? startDate;
  DateTime? endDate;

  List<String> selectedServiceIds = [];

  @override
  void initState() {
    super.initState();
    if (widget.offer != null) {
      titleController.text = widget.offer!.title;
      discountController.text = widget.offer!.discountPercent.toString();
      startDate = widget.offer!.startDate;
      endDate = widget.offer!.endDate;
      selectedServiceIds = List.from(widget.offer!.serviceIds);
    }

    discountController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    titleController.dispose();
    discountController.dispose();
    super.dispose();
  }

  Future<void> _pickDate(bool isStart) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isStart ? (startDate ?? DateTime.now()) : (endDate ?? DateTime.now()),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          startDate = picked;
        } else {
          endDate = picked;
        }
      });
    }
  }

  bool _isFormValid() {
    return titleController.text.trim().isNotEmpty &&
        discountController.text.trim().isNotEmpty &&
        startDate != null &&
        endDate != null &&
        selectedServiceIds.isNotEmpty;
  }

  Future<bool?> _showConfirmDialog(String title, String content) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: AppColors.offWhite,
        title: Text(
          title,
          style: TextStyle(color: AppColors.purple, fontWeight: FontWeight.bold),
        ),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('إلغاء', style: TextStyle(color: AppColors.purple)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.purple,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('تأكيد', style: TextStyle(color: AppColors.offWhite)),
          ),
        ],
      ),
    );
  }

  Future<void> _saveOffer() async {
    if (!_isFormValid()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الرجاء تعبئة جميع الحقول واختيار خدمة واحدة على الأقل')),
      );
      return;
    }

    final confirm = await _showConfirmDialog(
      widget.offer == null ? 'تأكيد الإضافة' : 'تأكيد التعديل',
      widget.offer == null
          ? 'هل أنت متأكد أنك تريد إضافة هذا العرض؟'
          : 'هل تريد حفظ التعديلات؟',
    );

    if (confirm == true) {
      final newOffer = Offer(
        id: widget.offer?.id ?? UniqueKey().toString(),
        title: titleController.text.trim(),
        discountPercent: double.tryParse(discountController.text) ?? 0,
        startDate: startDate!,
        endDate: endDate!,
        serviceIds: List.from(selectedServiceIds),
      );

      Navigator.pop(context, newOffer);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ServicesCubit, List<Service>>(
      builder: (context, allServices) {
        if (allServices.isEmpty) {
          return Scaffold(
            appBar: AppBar(title: Text(widget.offer == null ? 'إضافة عرض' : 'تعديل عرض')),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        final discountPercent = double.tryParse(discountController.text) ?? 0;

        return Scaffold(
          appBar: AppBar(title: Text(widget.offer == null ? 'إضافة عرض' : 'تعديل عرض')),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'عنوان العرض',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: discountController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                  ],
                  decoration: const InputDecoration(
                    labelText: 'نسبة الخصم %',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _pickDate(true),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.purple),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            startDate == null
                                ? 'تاريخ البداية'
                                : '${startDate!.year}/${startDate!.month}/${startDate!.day}',
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _pickDate(false),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.purple),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            endDate == null
                                ? 'تاريخ النهاية'
                                : '${endDate!.year}/${endDate!.month}/${endDate!.day}',
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text('الخدمات المرتبطة بالعرض:', style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  icon: const Icon(Icons.list),
                  label: const Text('اختيار الخدمات', style: TextStyle(color: AppColors.offWhite)),
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.purple),
                  onPressed: () async {
                    final result = await Navigator.push<List<String>>(
                      context,
                      MaterialPageRoute(
                        builder: (_) => SelectServicesPage(
                          allServices: allServices,
                          initiallySelectedIds: selectedServiceIds,
                        ),
                      ),
                    );
                    if (result != null) {
                      setState(() {
                        selectedServiceIds = List.from(result);
                      });
                    }
                  },
                ),
                const SizedBox(height: 12),
                if (selectedServiceIds.isEmpty)
                  const Text('لم يتم اختيار خدمات بعد'),
                if (selectedServiceIds.isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: selectedServiceIds.map((id) {
                      final service = allServices.firstWhere(
                            (s) => s.id == id,
                        orElse: () => Service(
                          id: '',
                          name: 'غير معروف',
                          description: '',
                          durationMinutes: 0,
                          price: 0.0,
                          departmentName: '',
                          imagePath: '',
                        ),
                      );

                      // if (service.id.isEmpty) return const SizedBox.shrink();

                      final discountedPrice = service.price * (1 - discountPercent / 100);

                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        child: ListTile(
                          title: Text(service.name),
                          subtitle: Text('${service.departmentName} | ${service.durationMinutes} دقيقة'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    '${service.price.toStringAsFixed(1)} ل.س',
                                    style: const TextStyle(
                                      decoration: TextDecoration.lineThrough,
                                      color: Colors.redAccent,
                                      fontSize: 12,
                                    ),
                                  ),
                                  Text(
                                    '${discountedPrice.toStringAsFixed(1)} ل.س',
                                    style: const TextStyle(
                                      color: Colors.green,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(width: 12),
                              IconButton(
                                icon: const Icon(Icons.close, color: Colors.redAccent),
                                onPressed: () {
                                  setState(() {
                                    selectedServiceIds.remove(id);
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.purple),
                    onPressed: _saveOffer,
                    child: Text(
                      widget.offer == null ? 'إضافة العرض' : 'حفظ التعديلات',
                      style: const TextStyle(color: AppColors.offWhite),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
