import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:vera_clinic/core/services/token_storage.dart';
import 'employee_state.dart';
import 'employee_model.dart';
import '../../../core/constant/ApiConstants.dart';

class EmployeeCubit extends Cubit<EmployeeState> {
  final http.Client _client;

  List<EmployeeModel> employeesCache = [];
  List<EmployeeModel> archivedCache = [];

  EmployeeCubit({http.Client? client})
      : _client = client ?? http.Client(),
        super(const EmployeeInitial());

  /// ----------------- Fetch Employees -----------------
  Future<void> fetchEmployees() async {
    print("Cubit: fetchEmployees بدأ");
    emit(const EmployeeLoading());
    try {
      final token = await TokenStorage.getToken();
      final response = await _client.get(
        Uri.parse(ApiConstants.showEmployeesUrl()),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      print("fetchEmployees: statusCode = ${response.statusCode}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final employeesData = (data['data'] as List?) ?? [];
        employeesCache = employeesData
            .map((e) => EmployeeModel.fromJson(e))
            .toList()
            .reversed
            .toList();
        emit(EmployeeLoaded(employeesCache));
        print("fetchEmployees: ✅ تم تحميل ${employeesCache.length} موظف");
      } else {
        emit(EmployeeError('فشل في جلب الموظفين (${response.statusCode})'));
      }
    } catch (e) {
      print("fetchEmployees: ❌ Exception: $e");
      emit(EmployeeError(e.toString()));
    }
  }

  /// ----------------- Add Employee -----------------
  Future<void> addEmployee({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
    required String role,
    required String departmentId,
    required String hireDate,
  }) async {
    print("Cubit: addEmployee $name");
    emit(const EmployeeAdding());
    try {
      final token = await TokenStorage.getToken();
      final response = await _client.post(
        Uri.parse(ApiConstants.addEmployeeUrl()),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          "name": name,
          "email": email,
          "password": password,
          "password_confirmation": passwordConfirmation,
          "role": role,
          "department_id": departmentId,
          "hire_date": hireDate,
        }),
      );

      print("addEmployee: statusCode = ${response.statusCode}");

      if (response.statusCode >= 200 && response.statusCode < 300) {
        print("addEmployee: ✅ تمت الإضافة بنجاح");
        await fetchEmployees(); // refresh مباشر
      } else {
        emit(EmployeeAddError('فشل إضافة الموظف (${response.statusCode})'));
      }
    } catch (e) {
      print("addEmployee: ❌ Exception: $e");
      emit(EmployeeAddError(e.toString()));
    }
  }

  /// ----------------- Update Employee -----------------
  Future<void> updateEmployee({
    required int id,
    required String name,
    String? password,
    String? passwordConfirmation,
    required String role,
    required String email,
    required String departmentId,
    required String hireDate,
  }) async {
    print("Cubit: updateEmployee id=$id");
    emit(const EmployeeUpdating());
    try {
      final token = await TokenStorage.getToken();
      final response = await _client.put(
        Uri.parse(ApiConstants.updateEmployeeUrl(id)),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          "name": name,
          if (password != null && password.isNotEmpty) "password": password,
          if (passwordConfirmation != null &&
              passwordConfirmation.isNotEmpty)
            "password_confirmation": passwordConfirmation,
          "email": email,
          "role": role,
          "department_id": departmentId,
          "hire_date": hireDate,
        }),
      );

      print("updateEmployee: statusCode = ${response.statusCode}");

      if (response.statusCode >= 200 && response.statusCode < 300) {
        print("updateEmployee: ✅ تم التعديل للموظف $id");
        await fetchEmployees(); // refresh مباشر
      } else {
        emit(EmployeeUpdateError(
            'فشل تعديل الموظف (${response.statusCode})'));
      }
    } catch (e) {
      print("updateEmployee: ❌ Exception: $e");
      emit(EmployeeUpdateError(e.toString()));
    }
  }

  /// ----------------- Fetch Archived Employees -----------------
  Future<void> fetchArchivedEmployees() async {
    print("Cubit: fetchArchivedEmployees بدأ");
    emit(const ArchivedEmployeesLoading());
    try {
      final token = await TokenStorage.getToken();
      final response = await _client.get(
        Uri.parse(ApiConstants.showArchivedEmployeesUrl()),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print("fetchArchivedEmployees: statusCode = ${response.statusCode}");

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final employeesData = (decoded['data'] as List?) ?? [];
        archivedCache =
            employeesData.map((e) => EmployeeModel.fromJson(e)).toList();
        emit(ArchivedEmployeesLoaded(archivedCache));
        print("fetchArchivedEmployees: ✅ ${archivedCache.length} موظف مؤرشف");
      } else {
        emit(ArchivedEmployeesError(
            'فشل تحميل الأرشيف (${response.statusCode})'));
      }
    } catch (e) {
      print("fetchArchivedEmployees: ❌ Exception: $e");
      emit(ArchivedEmployeesError(e.toString()));
    }
  }

  /// ----------------- Toggle Archive Employee -----------------
  Future<void> toggleArchiveEmployee({required int id}) async {
    print("Cubit: toggleArchiveEmployee id=$id");
    emit(const EmployeeArchiving());
    try {
      final token = await TokenStorage.getToken();
      final response = await _client.post(
        Uri.parse(ApiConstants.toggleArchiveEmployeeUrl(id)),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print("toggleArchiveEmployee: statusCode = ${response.statusCode}");

      if (response.statusCode == 200) {
        await fetchEmployees();
        await fetchArchivedEmployees();
        emit(EmployeeArchivedSuccessfully('تم تحديث الأرشيف بنجاح'));
      } else {
        emit(EmployeeArchiveError(
            'فشل في العملية (${response.statusCode})'));
      }
    } catch (e) {
      print("toggleArchiveEmployee: ❌ Exception: $e");
      emit(EmployeeArchiveError(e.toString()));
    }
  }

  /// ----------------- Search Employees -----------------
  Future<void> searchEmployees({required String query}) async {
    print("Cubit: searchEmployees query=$query");
    emit(const EmployeeSearching());
    try {
      final token = await TokenStorage.getToken();
      final uri =
      Uri.parse("${ApiConstants.searchEmployeeUrl()}?search=$query");

      final response = await _client.get(uri, headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      });

      print("searchEmployees: statusCode = ${response.statusCode}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final employeesData = (data['data'] as List?) ?? [];
        final employees = employeesData
            .map((e) => EmployeeModel.fromJson(e))
            .toList();
        emit(EmployeeSearchResults(employees));
        print("searchEmployees: ✅ ${employees.length} نتيجة");
      } else {
        emit(EmployeeSearchResults([]));
      }
    } catch (e) {
      print("searchEmployees: ❌ Exception: $e");
      emit(EmployeeSearchResults([]));
    }
  }

  /// ----------------- Toggle Employee Status -----------------
  Future<void> toggleStatusEmployee({required int userId}) async {
    print("Cubit: toggleStatusEmployee userId=$userId");
    try {
      final token = await TokenStorage.getToken();
      final uri = Uri.parse(ApiConstants.toggleUserStatusUrl(userId));
      final response = await _client.post(uri, headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      });

      print("toggleStatusEmployee: statusCode = ${response.statusCode}");
      print("toggleStatusEmployee: body = ${response.body}");

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);

        if (decoded['status'] == 1) {
          print("toggleStatusEmployee: ✅ تم تحديث الحالة");

          // تعديل الحالة محلياً في الكاش
          employeesCache = employeesCache.map((e) {
            if (e.user.id == userId) {
              return e.copyWith(
                user: e.user.copyWith(
                  status: e.user.status == 'active' ? 'blocked' : 'active',
                ),
              );
            }
            return e;
          }).toList();

          emit(EmployeeLoaded(employeesCache));
        } else {
          emit(EmployeeArchiveError(
              'فشل تبديل حالة الموظف: ${decoded['message']}'));
        }
      } else {
        emit(EmployeeArchiveError(
            'فشل تبديل حالة الموظف (${response.statusCode})'));
      }
    } catch (e) {
      print("toggleStatusEmployee: ❌ Exception: $e");
      emit(EmployeeArchiveError(e.toString()));
    }
  }
}
