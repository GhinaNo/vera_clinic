import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_theme.dart';
import '../../services/models/service.dart';
import '../model/offersModel.dart';

final dummyServices = [
  Service(
    name: 'تنظيف بشرة',
    description: 'تنظيف عميق للبشرة',
    durationMinutes: 60,
    price: 50000,
    departmentName: 'العناية بالبشرة',
    imagePath: '',
  ),
  Service(
    name: 'ليزر كامل',
    description: 'جلسة ليزر كاملة',
    durationMinutes: 90,
    price: 80000,
    departmentName: 'الليزر',
    imagePath: '',
  ),
];

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

  List<String> selectedServiceNames = [];

  @override
  void initState() {
    super.initState();
    if (widget.offer != null) {
      titleController.text = widget.offer!.title;
      discountController.text = widget.offer!.discountPercent.toString();
      startDate = widget.offer!.startDate;
      endDate = widget.offer!.endDate;
      selectedServiceNames = List.from(widget.offer!.serviceIds);
    }
  }

  Future<void> _pickDate(bool isStart) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
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
        endDate != null;
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
        SnackBar(content: Text('الرجاء تعبئة جميع الحقول')),
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
        title: titleController.text.trim(),
        discountPercent: double.tryParse(discountController.text) ?? 0,
        startDate: startDate ?? DateTime.now(),
        endDate: endDate ?? DateTime.now(),
        serviceIds: selectedServiceNames,
      );
      Navigator.pop(context, newOffer);
    }
  }

  @override
  Widget build(BuildContext context) {
    final discount = double.tryParse(discountController.text) ?? 0;

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
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(
                labelText: 'نسبة الخصم %',
                border: OutlineInputBorder(),
              ),
              onChanged: (_) => setState(() {}),
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
            Text('الخدمات المرتبطة بالعرض:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ...dummyServices.map((service) {
              final isSelected = selectedServiceNames.contains(service.name);
              final discountedPrice = service.price * (1 - discount / 100);
              return CheckboxListTile(
                title: Text(service.name),
                subtitle: Text(
                  'السعر: ${service.price.toInt()} ل.س - بعد الحسم: ${discountedPrice.toInt()} ل.س',
                  style: const TextStyle(fontSize: 13),
                ),
                value: isSelected,
                onChanged: (value) {
                  setState(() {
                    if (value == true) {
                      selectedServiceNames.add(service.name);
                    } else {
                      selectedServiceNames.remove(service.name);
                    }
                  });
                },
              );
            }).toList(),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.purple),
                onPressed: _saveOffer,
                child: Text(widget.offer == null ? 'إضافة العرض' : 'حفظ التعديلات',
                    style: TextStyle(color: AppColors.offWhite)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
