import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_theme.dart';
import '../../services/cubit/ServicesCubit.dart';
import '../../services/cubit/ServicesState.dart';
import '../../services/models/service.dart';
import '../model/offersModel.dart';
import 'SelectServicesPage.dart';

class AddOrEditOfferPage extends StatefulWidget {
  final Offer? offer;

  const AddOrEditOfferPage({super.key, this.offer});

  @override
  State<AddOrEditOfferPage> createState() => _AddOrEditOfferPageState();
}

class _AddOrEditOfferPageState extends State<AddOrEditOfferPage>
    with SingleTickerProviderStateMixin {
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

  Future<void> _saveOffer() async {
    if (!_isFormValid()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الرجاء تعبئة جميع الحقول واختيار خدمة واحدة على الأقل')),
      );
      return;
    }

    List<String> finalServiceIds;
    if (widget.offer != null) {
      finalServiceIds = selectedServiceIds.isEmpty
          ? List.from(widget.offer!.serviceIds)
          : List.from(selectedServiceIds);
    } else {
      finalServiceIds = List.from(selectedServiceIds);
    }

    final newOffer = Offer(
      id: widget.offer?.id ?? UniqueKey().toString(),
      title: titleController.text.trim(),
      discountPercent: double.tryParse(discountController.text) ?? 0,
      startDate: startDate!,
      endDate: endDate!,
      serviceIds: finalServiceIds,
    );

    print(widget.offer == null
        ? 'Adding new offer: ${newOffer.toJson()}'
        : 'Updating offer: ${newOffer.toJson()}');

    Navigator.pop(context, newOffer);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ServicesCubit, ServicesState>(
      builder: (context, state) {
        if (state is ServicesInitial || state is ServicesLoading) {
          return Scaffold(
            appBar: AppBar(title: Text(widget.offer == null ? 'إضافة عرض' : 'تعديل عرض')),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        if (state is ServicesError) {
          return Scaffold(
            appBar: AppBar(title: Text(widget.offer == null ? 'إضافة عرض' : 'تعديل عرض')),
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, size: 40),
                  const SizedBox(height: 8),
                  Text(state.message ?? 'حدث خطأ أثناء جلب الخدمات'),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () => context.read<ServicesCubit>().fetchServices(),
                    child: const Text('إعادة المحاولة'),
                  ),
                ],
              ),
            ),
          );
        }

        final services = (state as ServicesLoaded).services;
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
                  decoration: InputDecoration(
                    labelText: 'عنوان العرض',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: discountController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))],
                  decoration: InputDecoration(
                    labelText: 'نسبة الخصم %',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
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
                            borderRadius: BorderRadius.circular(12),
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
                            borderRadius: BorderRadius.circular(12),
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
                const Text('الخدمات المرتبطة بالعرض:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  icon: const Icon(Icons.list, color: Colors.white),
                  label: const Text('اختيار الخدمات', style: TextStyle(color: AppColors.offWhite)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.purple,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () async {
                    final result = await Navigator.push<List<String>>(
                      context,
                      MaterialPageRoute(
                        builder: (_) => SelectServicesPage(
                          allServices: services,
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
                if (selectedServiceIds.isEmpty) const Text('لم يتم اختيار خدمات بعد'),
                if (selectedServiceIds.isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: selectedServiceIds.map((id) {
                      final service = services.firstWhere(
                            (s) => s.id.toString() == id,
                        orElse: () => Service(
                          id: -1,
                          name: 'غير معروف',
                          description: '',
                          price: 0.0,
                          duration: 0,
                          departmentId: 0,
                          imageUrl: '',
                        ),
                      );

                      final discountedPrice = service.price * (1 - discountPercent / 100);

                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: ListTile(
                          title: Text(service.name),
                          subtitle: Text('القسم: ${service.departmentId} | ${service.duration} دقيقة'),
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
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.purple,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: _saveOffer,
                    child: Text(
                      widget.offer == null ? 'إضافة العرض' : 'حفظ التعديلات',
                      style: const TextStyle(
                        color: AppColors.offWhite,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
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
