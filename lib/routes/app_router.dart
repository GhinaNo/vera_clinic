
import 'package:go_router/go_router.dart';
import 'package:vera_clinic/features/departments/models/department.dart';
import 'package:vera_clinic/features/departments/pages/departments_pages.dart';
import 'package:vera_clinic/features/departments/pages/editDepartment_page.dart';
import 'package:vera_clinic/features/services/pages/service_page.dart';
import '../features/auth/login_page.dart';
import '../features/home/dashboard_page.dart';

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
      name: 'departments',
      builder: (context, state) =>  DepartmentsPage(departments: [], onDepartmentsChanged: (List<Department> value) {  },),
    ),
    GoRoute(
      path: '/departments/edit',
      builder: (context, state) {
        final department = state.extra as Department;
        return EditDepartmentDialog(department: department, onSave: (Department updatedDepartment) {  },);
      },
    ),
    GoRoute(
      path: '/services',
      name: 'services',
      builder: (context, state) => ServicesPage(departments: []),
    ),
  ],
);
