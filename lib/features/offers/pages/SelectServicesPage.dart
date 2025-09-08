import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../services/models/service.dart';

class SelectServicesPage extends StatefulWidget {
  final List<Service> allServices;
  final List<Service> initiallySelectedServices;

  const SelectServicesPage({
    super.key,
    required this.allServices,
    required this.initiallySelectedServices,
  });

  @override
  State<SelectServicesPage> createState() => _SelectServicesPageState();
}

class _SelectServicesPageState extends State<SelectServicesPage> {
  late List<Service> displayedServices;
  late Set<int> selectedServiceIds;
  int? selectedDepartmentId;

  @override
  void initState() {
    super.initState();
    displayedServices = widget.allServices;
    selectedServiceIds = widget.initiallySelectedServices.map((s) => s.id).toSet();
  }

  List<Service> get filteredServices {
    return displayedServices
        .where((service) =>
    selectedDepartmentId == null || service.departmentId == selectedDepartmentId)
        .toList();
  }

  Widget _buildDepartmentButton(int? deptId, String label) {
    final isSelected = selectedDepartmentId == deptId;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ElevatedButton(
        onPressed: () {
          setState(() {
            selectedDepartmentId = deptId;
          });
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: isSelected ? AppColors.purple : Colors.grey[200],
          foregroundColor: isSelected ? Colors.white : Colors.black87,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
        child: Text(label),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final departments = displayedServices.map((s) => s.departmentId).toSet().toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('اختيار الخدمات'),
        backgroundColor: AppColors.purple,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildDepartmentButton(null, 'كل الأقسام'),
                ...departments.map((deptId) => _buildDepartmentButton(deptId, 'قسم $deptId'))
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: filteredServices.isEmpty
                ? const Center(child: Text('لا توجد خدمات متاحة'))
                : ListView.builder(
              itemCount: filteredServices.length,
              itemBuilder: (context, index) {
                final service = filteredServices[index];
                final isSelected = selectedServiceIds.contains(service.id);
                final discountedPrice = service.discountedPrice ?? service.price;
                final hasDiscount = discountedPrice < service.price;

                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: CheckboxListTile(
                    title: Text(service.name),
                    subtitle: Text('القسم: ${service.departmentId} | ${service.duration} دقيقة'),
                    secondary: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (hasDiscount)
                          Text(
                            '${service.price.toStringAsFixed(1)} ل.س',
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
                      ],
                    ),
                    value: isSelected,
                    onChanged: (value) {
                      setState(() {
                        if (value == true) {
                          selectedServiceIds.add(service.id);
                        } else {
                          selectedServiceIds.remove(service.id);
                        }
                      });
                    },
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.purple),
              onPressed: () {
                if (selectedServiceIds.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('يرجى اختيار خدمة واحدة على الأقل')),
                  );
                  return;
                }
                final selectedServices = displayedServices
                    .where((s) => selectedServiceIds.contains(s.id))
                    .toList();
                Navigator.pop(context, selectedServices);
              },
              child: const Text('تأكيد الاختيار', style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}
