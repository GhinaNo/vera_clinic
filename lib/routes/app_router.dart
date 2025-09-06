import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../features/auth/cubit/log_out/logout_cubit.dart';
import '../features/auth/login_page.dart';
import '../features/auth/repository/auth_repository.dart';
import '../features/clients/cubit_client/user_cubit.dart';
import '../features/clients/model/user_repository.dart';
import '../features/clients/pages/clients_page.dart';
import '../features/departments/cubit/show_departments/show_departments_cubit.dart';
import '../features/departments/models/departments_repository.dart';
import '../features/departments/pages/departments_pages.dart';
import '../features/employee/employee_cubit.dart';
import '../features/invoices/cubit_invoices/invoices_cubit.dart';
import '../features/services/cubit/ServicesCubit.dart';
import '../features/services/models/ServicesRepository.dart';
import '../features/services/pages/service_page.dart';
import '../features/offers/cubit/offer_cubit.dart';
import '../features/offers/pages/offers_page.dart';
import '../features/offers/model/offers_repository.dart';
import '../features/home/dashboard_page.dart';
import '../features/statistics/cubit/statistics_cubit.dart';
import '../features/statistics/repository/statistics_repository.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/login',
  routes: [
    GoRoute(path: '/login', builder: (context, state) => LoginScreen()),

    GoRoute(
      path: '/home',
      builder: (context, state) {
        final extra = state.extra as Map<String, String>? ?? {};
        final role = extra['role'] ?? 'receptionist';
        final token = extra['token'] ?? '';

        final departmentsCubit = ShowDepartmentsCubit(
          repository: DepartmentsRepository(token: token),
        )..fetchDepartments();

        final servicesCubit = ServicesCubit(
          repository: ServicesRepository(token: token),
        )..fetchServices();

        final statisticsCubit = StatisticsCubit(StatisticsRepository());

        final offersCubit = OffersCubit(
          repository: OffersRepository(token: token),
        );

        final employeeCubit = EmployeeCubit()..fetchEmployees(
          extraHeaders: {'Authorization': 'Bearer $token'},
        );

        final clientCubit = ClientCubit(
          repository: ClientRepository(token: token),
        )..fetchClients();

        // final invoicesCubit = InvoicesCubit();

        return MultiBlocProvider(
          providers: [
            BlocProvider.value(value: departmentsCubit),
            BlocProvider.value(value: servicesCubit),
            BlocProvider.value(value: statisticsCubit),
            BlocProvider.value(value: offersCubit),
            BlocProvider.value(value: employeeCubit),
            BlocProvider.value(value: clientCubit),
            // BlocProvider.value(value: invoicesCubit),
            BlocProvider(create: (_) => LogoutCubit(AuthRepository())),
          ],
          child: DashboardPage(role: role, token: token),
        );
      },
    ),
  ],
);
