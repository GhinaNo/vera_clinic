import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:vera_clinic/core/services/token_storage.dart';
import 'employee_state.dart';
import 'employee_model.dart';

class EmployeeCubit extends Cubit<EmployeeState> {
  final http.Client _client;
  final String baseUrl;

  List<EmployeeModel> employeesCache = [];
  List<EmployeeModel> archivedCache = [];

  EmployeeCubit({
    http.Client? client,
    this.baseUrl = 'http://127.0.0.1:8000/web/admin/employees',
  })  : _client = client ?? http.Client(),
        super(const EmployeeInitial());

  /// ----------------- Fetch Employees -----------------
  Future<void> fetchEmployees({Map<String, String>? extraHeaders}) async {
    emit(const EmployeeLoading());
    try {
      final token = await TokenStorage.getToken();
      final headers = {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
        if (extraHeaders != null) ...extraHeaders,
      };

      final response = await _client.get(Uri.parse(baseUrl), headers: headers);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final employeesData = (data['data'] as List?) ?? [];
        employeesCache = employeesData
            .map((e) => EmployeeModel.fromJson(e))
            .toList()
            .reversed
            .toList();
        emit(EmployeeLoaded(employeesCache));
      } else {
        emit(EmployeeError('فشل في جلب الموظفين (${response.statusCode})'));
      }
    } catch (e) {
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
    emit(const EmployeeAdding());
    try {
      final token = await TokenStorage.getToken();
      final response = await _client.post(
        Uri.parse(baseUrl),
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

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = jsonDecode(response.body);
        emit(EmployeeAdded(data['data']));
        await fetchEmployees();
      } else {
        emit(EmployeeAddError('فشل إضافة الموظف (${response.statusCode})'));
      }
    } catch (e) {
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
    emit(const EmployeeUpdating());
    try {
      final token = await TokenStorage.getToken();
      final response = await _client.put(
        Uri.parse('$baseUrl/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          "name": name,
          if (password != null && password.isNotEmpty) "password": password,
          if (passwordConfirmation != null && passwordConfirmation.isNotEmpty)
            "password_confirmation": passwordConfirmation,
          "email": email,
          "role": role,
          "department_id": departmentId,
          "hire_date": hireDate,
        }),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = jsonDecode(response.body);
        emit(EmployeeUpdated(data['data']));
        await fetchEmployees();
      } else {
        emit(EmployeeUpdateError('فشل تعديل الموظف (${response.statusCode})'));
      }
    } catch (e) {
      emit(EmployeeUpdateError(e.toString()));
    }
  }

  /// ----------------- Fetch Archived Employees -----------------
  Future<void> fetchArchivedEmployees() async {
    emit(const ArchivedEmployeesLoading());
    try {
      final token = await TokenStorage.getToken();
      final response = await _client.get(
        Uri.parse('$baseUrl/archives'),
        headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        List<dynamic> employeesData = [];
        if (decoded['data'] is List) employeesData = decoded['data'];
        else if (decoded['data'] is Map)
          employeesData = (decoded['data'] as Map).values.toList();

        archivedCache = employeesData.map((e) => EmployeeModel.fromJson(e)).toList();
        emit(ArchivedEmployeesLoaded(archivedCache));
      } else {
        emit(ArchivedEmployeesError('فشل تحميل الأرشيف (${response.statusCode})'));
      }
    } catch (e) {
      emit(ArchivedEmployeesError(e.toString()));
    }
  }

  /// ----------------- Toggle Archive Employee -----------------
  Future<void> toggleArchiveEmployee({required int id, required bool isArchiveMode}) async {
    emit(const EmployeeArchiving());
    try {
      final token = await TokenStorage.getToken();
      final response = await _client.post(
        Uri.parse('$baseUrl/$id/toggle-archive'),
        headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        if (isArchiveMode) await fetchArchivedEmployees();
        else await fetchEmployees();
        emit(EmployeeArchivedSuccessfully('تم تحديث الأرشيف بنجاح'));
      } else {
        emit(EmployeeArchiveError('فشل في العملية (${response.statusCode})'));
      }
    } catch (e) {
      emit(EmployeeArchiveError(e.toString()));
    }
  }

  /// ----------------- Search Employees -----------------
  Future<void> searchEmployees({required String query}) async {
    emit(const EmployeeSearching());
    try {
      final token = await TokenStorage.getToken();
      final uri = Uri.parse('$baseUrl/search?search=$query');

      final response = await _client.get(uri, headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      });

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final employeesData = (data['data'] as List?) ?? [];
        final employees = employeesData.map((e) => EmployeeModel.fromJson(e)).toList();
        emit(EmployeeSearchResults(employees));
      } else {
        emit(EmployeeSearchResults([]));
      }
    } catch (_) {
      emit(EmployeeSearchResults([]));
    }
  }

  /// ----------------- Toggle Employee Status (Active/Blocked) -----------------
  Future<void> toggleStatusEmployee({required int employeeId}) async {
    try {
      final index = employeesCache.indexWhere((e) => e.id == employeeId);
      if (index == -1) return;
      final emp = employeesCache[index];

      final newStatus = emp.user.status == 'active' ? 'blocked' : 'active';
      employeesCache[index] = emp.copyWith(user: emp.user.copyWith(status: newStatus));
      emit(EmployeeLoaded(List.from(employeesCache)));

      final token = await TokenStorage.getToken();
      final uri = Uri.parse('http://127.0.0.1:8000/web/users/${emp.user.id}/toggle-status');

      final response = await _client.post(uri, headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      });

      if (response.statusCode != 200) {
        employeesCache[index] = emp;
        emit(EmployeeLoaded(List.from(employeesCache)));
        emit(EmployeeArchiveError('فشل تبديل حالة الموظف (${response.statusCode})'));
        return;
      }

      final decoded = jsonDecode(response.body);
      if (decoded['status'] != 1) {
        employeesCache[index] = emp;
        emit(EmployeeLoaded(List.from(employeesCache)));
        emit(EmployeeArchiveError('فشل تبديل حالة الموظف: ${decoded['message']}'));
        return;
      }

      emit(EmployeeArchivedSuccessfully('تم تحديث حالة الموظف بنجاح'));
    } catch (e) {
      emit(EmployeeArchiveError(e.toString()));
    }
  }
}
