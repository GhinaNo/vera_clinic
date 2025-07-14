import 'package:flutter/material.dart';
import 'package:vera_clinic/features/departments/models/department.dart';
import 'package:vera_clinic/features/departments/pages/departments_pages.dart';
import 'package:vera_clinic/features/services/pages/service_page.dart';
import '../../core/theme/app_theme.dart';
import '../offers/pages/offers_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int selectedIndex = 0;
  bool isCollapsed = false;

  List<Department> departments = [
    Department(
      name: 'العناية بالبشرة',
      supervisor: 'د. ليلى أحمد',
      description: 'قسم متخصص في العناية بالبشرة والعلاجات التجميلية.',
      location: 'الجناح 101',
    ),
    Department(
      name: 'قسم الليزر',
      supervisor: 'د. سامر الخطيب',
      description: 'قسم الليزر لخدمات ازالة الشعر والعناية بالبشرة.',
      location: 'الجناح 1',
    ),
  ];

  void updateDepartments(List<Department> updatedDepartments) {
    setState(() {
      departments = updatedDepartments;
    });
  }

  final List<String> titles = [
    'الرئيسية',
    'الأقسام',
    'الخدمات',
    'العروض',
    'الموظفون',
    'الزبائن',
    'المواعيد',
    'الحجوزات',
    'الإدارة',
    'المحاسبة',
    'الإشعارات',
  ];

  final List<IconData> icons = [
    Icons.dashboard_outlined,
    Icons.category_outlined,
    Icons.medical_services_outlined,
    Icons.local_offer_outlined,
    Icons.people_alt_outlined,
    Icons.person_outline,
    Icons.calendar_month_outlined,
    Icons.book_online_outlined,
    Icons.manage_accounts_outlined,
    Icons.account_balance_wallet_outlined,
    Icons.notifications_outlined,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.offWhite,
      body: Row(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: isCollapsed ? 70 : 260,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
              gradient: LinearGradient(
                colors: [AppColors.purple, AppColors.purple.withOpacity(0.9)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 8)],
            ),
            child: SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                    child: isCollapsed
                        ? Image.asset('assets/images/logo.png', width: 60, height: 60)
                        : Column(
                      children: [
                        Image.asset('assets/images/logo.png', width: 150, height: 150),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      isCollapsed ? Icons.menu : Icons.arrow_back_ios,
                      color: AppColors.secondaryColor,
                    ),
                    onPressed: () => setState(() => isCollapsed = !isCollapsed),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: ListView.builder(
                      itemCount: titles.length,
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      itemBuilder: (context, i) {
                        final isSelected = selectedIndex == i;
                        return InkWell(
                          onTap: () {
                            setState(() => selectedIndex = i);
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            decoration: BoxDecoration(
                              color: isSelected ? Colors.white.withOpacity(0.15) : Colors.transparent,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                Icon(icons[i], color: AppColors.secondaryColor, size: 20),
                                if (!isCollapsed) const SizedBox(width: 12),
                                if (!isCollapsed)
                                  Expanded(
                                    child: Text(
                                      titles[i],
                                      style: const TextStyle(
                                        fontFamily: 'Tajawal',
                                        color: AppColors.secondaryColor,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Column(
              children: [
                Container(
                  height: 60,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      )
                    ],
                  ),
                  child: Row(
                    children: [
                      Icon(icons[selectedIndex], color: AppColors.purple),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          titles[selectedIndex],
                          style: Theme.of(context).textTheme.titleLarge!.copyWith(
                            fontFamily: 'Tajawal',
                            color: AppColors.purple,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: _buildContent(selectedIndex),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(int index) {
    switch (index) {
      case 0:
        return Center(child: Text('محتوى الرئيسية'));
      case 1:
        return DepartmentsPage(
          departments: departments,
          onDepartmentsChanged: updateDepartments,
        );
      case 2:
        return ServicesPage(departments: departments);
      case 3:
        return OffersPage();
      default:
        return Center(child: Text('محتوى غير متوفر'));
    }
  }
}
