import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:vera_clinic/features/auth/screens/check_code_screen.dart';
import 'package:vera_clinic/features/auth/screens/forget_password_screen.dart';
import '../features/auth/cubit/log_out/logout_cubit.dart';
import '../features/auth/login_page.dart';
import '../features/auth/repository/auth_repository.dart';
import '../features/auth/screens/reset_password_screen.dart';
import '../features/clients/cubit_client/user_cubit.dart';
import '../features/clients/model/user_repository.dart';
import '../features/departments/cubit/show_departments/show_departments_cubit.dart';
import '../features/departments/models/departments_repository.dart';
import '../features/employee/employee_cubit.dart';
import '../features/services/cubit/ServicesCubit.dart';
import '../features/services/models/services_repository.dart .dart';
import '../features/offers/cubit/offer_cubit.dart';
import '../features/offers/model/offers_repository.dart';
import '../features/home/dashboard_page.dart';
import '../features/statistics/cubit/statistics_cubit.dart';
import '../features/statistics/repository/statistics_repository.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/login',
  routes: [
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),

    GoRoute(
      path: '/forget-password',
      builder: (context, state) => const ForgetPasswordScreen(),
    ),

    GoRoute(
      path: '/check-code',
      builder: (context, state) => CheckCodeScreen(),
    ),

    GoRoute(
      path: '/reset-password',
      builder: (context, state) {
        final code = state.extra as String? ?? '';
        return ResetPasswordScreen(code: code);
      },
    ),

    GoRoute(
      path: '/admin-home',
      builder: (context, state) {
        final extra = state.extra as Map<String, String>? ?? {};
        final role = extra['role'] ?? 'admin';
        final token = extra['token'] ?? '';

        return _buildDashboard(role, token);
      },
    ),

    GoRoute(
      path: '/reception-home',
      builder: (context, state) {
        final extra = state.extra as Map<String, String>? ?? {};
        final role = extra['role'] ?? 'receptionist';
        final token = extra['token'] ?? '';

        return _buildDashboard(role, token);
      },
    ),

    GoRoute(
      path: '/home',
      builder: (context, state) {
        final extra = state.extra as Map<String, String>? ?? {};
        final role = extra['role'] ?? 'user';
        final token = extra['token'] ?? '';

        return _buildDashboard(role, token);
      },
    ),
  ],
);

MultiBlocProvider _buildDashboard(String role, String token) {
  final departmentsCubit = ShowDepartmentsCubit(
    repository: DepartmentsRepository(token: token),
  )..fetchDepartments();

  final servicesCubit = ServicesCubit(
    repository: ServicesRepository(token: token),
  )..fetchServices();

  final statisticsCubit = StatisticsCubit(StatisticsRepository());

  final offersCubit = offer_cubit(
    repository: offers_repository(token: token),
  );

  final employeeCubit = EmployeeCubit()
    ..fetchEmployees();


  final clientCubit = ClientCubit(
    repository: ClientRepository(token: token),
  )..fetchClients();

  return MultiBlocProvider(
    providers: [
      BlocProvider.value(value: departmentsCubit),
      BlocProvider.value(value: servicesCubit),
      BlocProvider.value(value: statisticsCubit),
      BlocProvider.value(value: offersCubit),
      BlocProvider.value(value: employeeCubit),
      BlocProvider.value(value: clientCubit),
      BlocProvider(create: (_) => LogoutCubit(AuthRepository())),
    ],
    child: DashboardPage(role: role, token: token),
  );
}
