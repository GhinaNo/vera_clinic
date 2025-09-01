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

class _SelectServicesPageState extends State<SelectServicesPage>
    with SingleTickerProviderStateMixin {
  late List<Service> uniqueServices;
  late Set<String> selectedIds;
  int? selectedDepartmentId;
  String search = '';

  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    uniqueServices = widget.allServices;
    selectedIds = widget.initiallySelectedIds.toSet();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<Service> get filteredServices {
    return uniqueServices.where((service) {
      final matchesDepartment =
          selectedDepartmentId == null || service.departmentId == selectedDepartmentId;
      final matchesSearch = search.isEmpty ||
          service.name.toLowerCase().contains(search.toLowerCase());
      return matchesDepartment && matchesSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final departments = uniqueServices.map((s) => s.departmentId).toSet().toList();

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
                  _controller.reset();
                  _controller.forward();
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
                  selected: selectedDepartmentId == null,
                  onSelected: (_) {
                    setState(() {
                      selectedDepartmentId = null;
                      _controller.reset();
                      _controller.forward();
                    });
                  },
                ),
                const SizedBox(width: 8),
                ...departments.map((departmentId) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text('قسم $departmentId'),
                      selected: selectedDepartmentId == departmentId,
                      onSelected: (_) {
                        setState(() {
                          selectedDepartmentId = departmentId;
                          _controller.reset();
                          _controller.forward();
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
                final serviceIdStr = service.id.toString();
                final isSelected = selectedIds.contains(serviceIdStr);

                final start = index * 0.1;
                final end = start + 0.5;
                final animation = CurvedAnimation(
                  parent: _controller,
                  curve: Interval(
                    start < 1.0 ? start : 1.0,
                    end < 1.0 ? end : 1.0,
                    curve: Curves.easeOut,
                  ),
                );

                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 0.1),
                      end: Offset.zero,
                    ).animate(animation),
                    child: Card(
                      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: CheckboxListTile(
                        title: Text(service.name),
                        subtitle: Text(
                            'القسم: ${service.departmentId} | ${service.duration} دقيقة'),
                        secondary: Text('${service.price.toStringAsFixed(1)} ل.س'),
                        value: isSelected,
                        onChanged: (value) {
                          setState(() {
                            if (value == true) {
                              selectedIds.add(serviceIdStr);
                            } else {
                              selectedIds.remove(serviceIdStr);
                            }
                          });
                        },
                      ),
                    ),
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
