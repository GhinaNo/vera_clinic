import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../core/services/token_storage.dart';
import '../../core/theme/app_theme.dart';
import '../auth/cubit/log_out/logout_cubit.dart';
import '../auth/repository/auth_repository.dart';
import '../departments/cubit/show_departments/show_departments_cubit.dart';
import '../departments/models/departments_repository.dart';
import '../departments/pages/departments_pages.dart';
import '../services/cubit/ServicesCubit.dart';
import '../services/models/ServicesRepository.dart';
import '../services/pages/service_page.dart';
import '../offers/cubit/offer_cubit.dart';
import '../offers/pages/offers_page.dart';
import '../invoices/cubit/invoices_cubit.dart';
import '../invoices/pages/invoices_list_page.dart';

class DashboardPage extends StatefulWidget {
  final String role;
  final String token;

   DashboardPage({super.key, required this.role, required this.token,});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int selectedIndex = 0;
  bool isCollapsed = false;

  late List<String> allowedTitles;
  late List<IconData> allowedIcons;
  late List<Widget> allowedContent;

  late ShowDepartmentsCubit _departmentsCubit;

  @override
  void initState() {
    super.initState();

    if (widget.role == 'admin') {
      allowedTitles = [
        'الأقسام',
        'الخدمات',
        'العروض',
        'المحاسبة',
        'الزبائن',
        'المواعيد',
        'الحجوزات',
        'الإدارة',
        'الموظفون',
        'الإشعارات',
        'تسجيل الخروج',
      ];
      allowedIcons = [
        Icons.category_outlined,
        Icons.medical_services_outlined,
        Icons.local_offer_outlined,
        Icons.account_balance_wallet_outlined,
        Icons.person_outline,
        Icons.calendar_month_outlined,
        Icons.book_online_outlined,
        Icons.manage_accounts_outlined,
        Icons.people_alt_outlined,
        Icons.notifications_outlined,
        Icons.logout,
      ];
    } else {
      allowedTitles = [
        'المحاسبة',
        'الزبائن',
        'المواعيد',
        'الحجوزات',
        'الإشعارات',
        'تسجيل الخروج',
      ];
      allowedIcons = [
        Icons.account_balance_wallet_outlined,
        Icons.person_outline,
        Icons.calendar_month_outlined,
        Icons.book_online_outlined,
        Icons.notifications_outlined,
        Icons.logout,
      ];
    }

    _departmentsCubit = ShowDepartmentsCubit(
      repository: DepartmentsRepository(token: widget.token),
    )..fetchDepartments();

    allowedContent = allowedTitles.map((t) {
      switch (t) {
        case 'الأقسام':
          return DepartmentsPage(token: widget.token);
        case 'الخدمات':
          return BlocProvider(
            create: (_) => ServicesCubit(
              repository: ServicesRepository(token: widget.token),
            ),
            child: const ServicesPage(),
          );




        case 'العروض':
          return OffersPage();
        case 'المحاسبة':
          return InvoicesListPage();
        case 'تسجيل الخروج':
          return _buildLogoutPage();
        default:
          return const Center(child: Text('محتوى غير متوفر'));
      }
    }).toList();
  }

  @override
  void dispose() {
    _departmentsCubit.close();
    super.dispose();
  }

  Widget _buildLogoutPage() {
    return const Center(child: Text("جارٍ تسجيل الخروج..."));
  }

  Future<void> _confirmLogout(BuildContext context) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        backgroundColor: Colors.white,
        title: Row(
          children: [
            Icon(Icons.logout, color: AppColors.purple),
            const SizedBox(width: 8),
            const Text(
              "تسجيل الخروج",
              style: TextStyle(
                fontFamily: 'Tajawal',
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ],
        ),
        content: const Text(
          "هل أنت متأكد أنك تريد تسجيل الخروج؟",
          style: TextStyle(
            fontFamily: 'Tajawal',
            fontSize: 16,
          ),
        ),
        actionsAlignment: MainAxisAlignment.spaceBetween,
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text(
              "إلغاء",
              style: TextStyle(
                fontFamily: 'Tajawal',
                color: Colors.grey,
                fontSize: 16,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.purple,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
            child: const Text(
              "تسجيل الخروج",
              style: TextStyle(
                fontFamily: 'Tajawal',
                fontSize: 16,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );

    if (shouldLogout == true) {
      context.read<LogoutCubit>().logout().then((_) async {
        await TokenStorage.clear();
        if (mounted) context.go('/login');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isSmallScreen = screenWidth < 700;

    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _departmentsCubit),
        BlocProvider.value(value: _departmentsCubit),
        BlocProvider(create: (_) => OffersCubit()),
        BlocProvider(create: (_) => InvoicesCubit()),
        BlocProvider(create: (_) => LogoutCubit(AuthRepository())),
      ],
      child: Scaffold(
        backgroundColor: AppColors.offWhite,
        drawer: isSmallScreen ? _buildDrawer() : null,
        body: isSmallScreen ? _buildSmallScreenBody() : _buildLargeScreenBody(),
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.purple, AppColors.purple.withOpacity(0.9)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Image.asset('assets/images/logo.png', width: 120, height: 120),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: allowedTitles.length,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemBuilder: (context, i) {
                    final isSelected = selectedIndex == i;

                    return ListTile(
                      leading: Icon(allowedIcons[i], color: Colors.white),
                      title: Text(
                        allowedTitles[i],
                        style: const TextStyle(
                          fontFamily: 'Tajawal',
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      selected: isSelected,
                      selectedTileColor: Colors.white.withOpacity(0.2),
                      onTap: () {
                        if (allowedTitles[i] == "تسجيل الخروج") {
                          _confirmLogout(context);
                        } else {
                          setState(() => selectedIndex = i);
                        }
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSmallScreenBody() {
    return Column(
      children: [
        AppBar(
          backgroundColor: AppColors.purple,
          title: Row(
            children: [
              Icon(allowedIcons[selectedIndex], color: Colors.white),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  allowedTitles[selectedIndex],
                  style: const TextStyle(
                    fontFamily: 'Tajawal',
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          leading: Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
          ),
        ),
        Expanded(child: _buildContent()),
      ],
    );
  }

  Widget _buildLargeScreenBody() {
    return Row(
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
                      : Image.asset('assets/images/logo.png', width: 150, height: 150),
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
                    itemCount: allowedTitles.length,
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    itemBuilder: (context, i) {
                      final isSelected = selectedIndex == i;
                      return InkWell(
                        onTap: () {
                          if (allowedTitles[i] == "تسجيل الخروج") {
                            _confirmLogout(context);
                          } else {
                            setState(() => selectedIndex = i);
                          }
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
                              Icon(allowedIcons[i], color: AppColors.secondaryColor, size: 20),
                              if (!isCollapsed) const SizedBox(width: 12),
                              if (!isCollapsed)
                                Expanded(
                                  child: Text(
                                    allowedTitles[i],
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
                    Icon(allowedIcons[selectedIndex], color: AppColors.purple),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        allowedTitles[selectedIndex],
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
              Expanded(child: _buildContent()),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildContent() {
    return IndexedStack(
      index: selectedIndex,
      children: allowedContent,
    );
  }
}
