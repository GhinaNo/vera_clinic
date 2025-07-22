import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../services/models/service.dart';

class SelectServicesPage extends StatefulWidget {
  final List<Service> allServices;
  final List<String> initiallySelectedIds;

  const SelectServicesPage({
    super.key,
    required this.allServices,
    required this.initiallySelectedIds,
  });

  @override
  State<SelectServicesPage> createState() => _SelectServicesPageState();
}

class _SelectServicesPageState extends State<SelectServicesPage> {
  late List<Service> uniqueServices;
  late Set<String> selectedIds;  // استخدم Set لتجنب التكرار
  String? selectedDepartment;
  String search = '';

  @override
  void initState() {
    super.initState();
    uniqueServices = widget.allServices;
    selectedIds = widget.initiallySelectedIds.toSet();
  }

  List<Service> get filteredServices {
    return uniqueServices.where((service) {
      final matchesDepartment =
          selectedDepartment == null || service.departmentName == selectedDepartment;
      final matchesSearch = search.isEmpty || service.name.toLowerCase().contains(search.toLowerCase());
      return matchesDepartment && matchesSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final departments = uniqueServices.map((s) => s.departmentName).toSet().toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('اختيار الخدمات'),
        backgroundColor: AppColors.purple,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'بحث',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) {
                setState(() {
                  search = value.trim();
                });
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                ChoiceChip(
                  label: const Text('كل الأقسام'),
                  selected: selectedDepartment == null,
                  onSelected: (_) {
                    setState(() {
                      selectedDepartment = null;
                    });
                  },
                ),
                const SizedBox(width: 8),
                ...departments.map((department) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(department),
                      selected: selectedDepartment == department,
                      onSelected: (_) {
                        setState(() {
                          selectedDepartment = department;
                        });
                      },
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: filteredServices.isEmpty
                ? const Center(child: Text('لا توجد خدمات مطابقة'))
                : ListView.builder(
              itemCount: filteredServices.length,
              itemBuilder: (context, index) {
                final service = filteredServices[index];
                final isSelected = selectedIds.contains(service.id);

                return Card(
                  key: ValueKey(service.id), // مفتاح فريد للـ widget
                  margin:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: CheckboxListTile(
                    key: ValueKey('checkbox_${service.id}'),
                    title: Text(service.name),
                    subtitle: Text(
                        '${service.departmentName} | ${service.durationMinutes} دقيقة'),
                    secondary: Text('${service.price.toStringAsFixed(1)} ل.س'),
                    value: isSelected,
                    onChanged: (value) {
                      setState(() {
                        if (value == true) {
                          selectedIds.add(service.id);
                        } else {
                          selectedIds.remove(service.id);
                        }
                        // طباعة لتتبع الاختيارات أثناء التطوير
                        // print('Selected services: $selectedIds');
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
                if (selectedIds.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('يرجى اختيار خدمة واحدة على الأقل')),
                  );
                  return;
                }
                Navigator.pop(context, selectedIds.toList());
              },
              child: const Text('تأكيد الاختيار', style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}
