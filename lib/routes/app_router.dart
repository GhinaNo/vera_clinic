import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:vera_clinic/features/departments/pages/departments_pages.dart';
import 'package:vera_clinic/features/employee/employee_cubit.dart';
import 'package:vera_clinic/features/services/pages/service_page.dart';
import '../features/auth/login_page.dart';
import '../features/auth/screens/check_code_screen.dart';
import '../features/auth/screens/forget_password_screen.dart';
import '../features/auth/screens/reset_password_screen.dart';
import '../features/clients/cubit_client/user_cubit.dart';
import '../features/clients/model/user_repository.dart';
import '../features/clients/pages/clients_page.dart';
import '../features/employee/employee_management_page (1).dart';
import '../features/home/dashboard_page.dart';
import '../features/invoices/pages/invoices_list_page.dart';
import '../features/offers/cubit/offer_cubit.dart';
import '../features/offers/model/offers_repository.dart';
import '../features/offers/pages/offers_page.dart';
import '../features/services/cubit/ServicesCubit.dart';
import '../features/services/models/ServicesRepository.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/login',
  routes: [
    GoRoute(path: '/login', builder: (context, state) => LoginScreen()),
    GoRoute(path: '/forget-password', builder: (context, state) => const ForgetPasswordScreen()),
    GoRoute(path: '/check-code', builder: (context, state) => CheckCodeScreen()),
    GoRoute(path: '/reset-password', builder: (context, state) {
      final code = state.extra as String? ?? '';
      return ResetPasswordScreen(code: code);
    }),

    GoRoute(
      path: '/users',
      builder: (context, state) {
        final token = (state.extra as Map<String, String>? ?? {})['token'] ?? '';
        return BlocProvider(
          create: (_) => ClientCubit(
            repository: ClientRepository(token: token),
          )..fetchClients(),
          child: Builder(
            builder: (context) {
              final clientCubit = context.read<ClientCubit>();
              return ClientPage(cubit: clientCubit);
            },
          ),
        );
      },
    ),


    GoRoute(path: '/home', builder: (context, state) {
      final extra = state.extra as Map<String, String>? ?? {};
      final role = extra['role'] ?? 'receptionist';
      final token = extra['token'] ?? '';
      return DashboardPage(role: role, token: token);
    }),
    GoRoute(path: '/departments', builder: (context, state) {
      final extra = state.extra as Map<String, String>? ?? {};
      final token = extra['token'] ?? '';
      return DepartmentsPage(token: token);
    }),
    GoRoute(
      path: '/offers',
      builder: (context, state) {
        final extra = state.extra as Map<String, String>? ?? {};
        final token = extra['token'] ?? '';

        return BlocProvider(
          create: (_) => OffersCubit(
            repository: OffersRepository(token: token),
          ),
          child: const OffersPage(),
        );
      },
    ),
    GoRoute(
      path: '/services',
      builder: (context, state) {
        final extra = state.extra as Map<String, String>? ?? {};
        final token = extra['token'] ?? '';

        return BlocProvider(
          create: (_) => ServicesCubit(
            repository: ServicesRepository(token: token),
          ),
          child: const ServicesPage(),
        );
      },
    ),
    GoRoute(
      path: '/employees',
      builder: (context, state) {
        final extra = state.extra as Map<String, String>? ?? {};
        final token = extra['token'] ?? '';

        return BlocProvider(
          create: (_) => EmployeeCubit()..fetchEmployees(
            extraHeaders: {'Authorization': 'Bearer $token'},
          ),
          child: const EmployeePage(),
        );
      },
    ),


    GoRoute(path: '/invoices', builder: (context, state) => InvoicesListPage()),
  ],
);
