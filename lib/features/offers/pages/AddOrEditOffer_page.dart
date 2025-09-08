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
  final offersModel? offer;

  const AddOrEditOfferPage({super.key, this.offer});

  @override
  State<AddOrEditOfferPage> createState() => _AddOrEditOfferPageState();
}

class _AddOrEditOfferPageState extends State<AddOrEditOfferPage> {
  final titleController = TextEditingController();
  final discountController = TextEditingController();
  DateTime? startDate;
  DateTime? endDate;
  List<Service> selectedServices = [];

  double get discountPercent =>
      double.tryParse(discountController.text) ?? 0;

  @override
  void initState() {
    super.initState();
    if (widget.offer != null) {
      titleController.text = widget.offer!.title;
      discountController.text = widget.offer!.discountPercent.toString();
      startDate = widget.offer!.startDate;
      endDate = widget.offer!.endDate;
      selectedServices = List.from(widget.offer!.services);
    }
    discountController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    discountController.dispose();
    titleController.dispose();
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
        if (isStart) startDate = picked;
        else endDate = picked;
      });
    }
  }

  bool _isFormValid() {
    return titleController.text.trim().isNotEmpty &&
        discountController.text.trim().isNotEmpty &&
        startDate != null &&
        endDate != null &&
        selectedServices.isNotEmpty;
  }

  Future<void> _saveOffer() async {
    if (!_isFormValid()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الرجاء تعبئة جميع الحقول واختيار خدمة واحدة على الأقل')),
      );
      return;
    }

    final newOffer = offersModel(
      id: widget.offer?.id ?? UniqueKey().toString(),
      title: titleController.text.trim(),
      discountPercent: discountPercent,
      startDate: startDate!,
      endDate: endDate!,
      isActive: true,
      services: selectedServices,
    );


    Navigator.pop(context, newOffer);
  }

  double _applyDiscount(double price) {
    if (discountPercent <= 0) return price;
    return price * (1 - discountPercent / 100);
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

        final apiServices = List<Service>.from((state as ServicesLoaded).services);

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
                    final result = await Navigator.push<List<Service>>(
                      context,
                      MaterialPageRoute(
                        builder: (_) => SelectServicesPage(
                          allServices: apiServices,
                          initiallySelectedServices: selectedServices,
                        ),
                      ),
                    );
                    if (result != null) {
                      setState(() {
                        selectedServices = List.from(result);
                      });
                    }
                  },
                ),
                const SizedBox(height: 12),
                if (selectedServices.isEmpty) const Text('لم يتم اختيار خدمات بعد'),
                if (selectedServices.isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: selectedServices.map((service) {
                      final originalPrice = service.price;
                      final discountedPrice = _applyDiscount(service.price);
                      final hasDiscount = discountedPrice < originalPrice;

                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: ListTile(
                          leading: service.imageUrl != null && service.imageUrl!.isNotEmpty
                              ? Image.network(service.imageUrl!, width: 50, height: 50, fit: BoxFit.cover)
                              : const Icon(Icons.miscellaneous_services, size: 40),
                          title: Text(service.name),
                          subtitle: Text('القسم: ${service.departmentId} | ${service.duration} دقيقة'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (hasDiscount)
                                Text(
                                  '${originalPrice.toStringAsFixed(1)} ل.س',
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                    decoration: TextDecoration.lineThrough,
                                  ),
                                ),
                              if (hasDiscount) const SizedBox(width: 6),
                              Text(
                                '${discountedPrice.toStringAsFixed(1)} ل.س',
                                style: TextStyle(
                                  color: hasDiscount ? Colors.green : Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(width: 12),
                              IconButton(
                                icon: const Icon(Icons.close, color: Colors.redAccent),
                                onPressed: () {
                                  setState(() {
                                    selectedServices.remove(service);
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

