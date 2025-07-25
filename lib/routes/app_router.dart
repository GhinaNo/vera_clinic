import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:vera_clinic/features/departments/pages/departments_pages.dart';
import 'package:vera_clinic/features/services/cubit/ServicesCubit.dart';
import 'package:vera_clinic/features/services/pages/service_page.dart';
import '../features/auth/login_page.dart';
import '../features/departments/cubit/departments_cubit.dart';
import '../features/home/dashboard_page.dart';
import '../features/invoices/cubit/invoices_cubit.dart';
import '../features/invoices/pages/AddInvoicePage.dart';
import '../features/invoices/pages/invoices_list_page.dart';
import '../features/offers/cubit/offer_cubit.dart';
import '../features/offers/pages/offers_page.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/login',
  routes: [
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => const DashboardPage(),
    ),
    GoRoute(
      path: '/departments',
      builder: (context, state) =>
          BlocProvider(
            create: (_) => DepartmentsCubit(),
            child: DepartmentsPage(),
          ),
    ),

    GoRoute(
      path: '/offers',
      builder: (context, state) => BlocProvider(
        create: (_) => OffersCubit(),
        child: const OffersPage(),
      ),
    ),
    GoRoute(
      path: '/services',
      builder: (context, state) => ServicesPage(departments: []),
    ),
    GoRoute(
      path: '/invoices',
      builder: (context, state) => InvoicesListPage(),
    ),

  ],
);
