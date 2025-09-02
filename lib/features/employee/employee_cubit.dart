import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:vera_clinic/core/services/token_storage.dart';
import 'package:vera_clinic/features/employee/employee_model.dart';
import 'employee_state.dart';

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
    print('💡 fetchEmployees started');
    emit(const EmployeeLoading());
    try {
      final uri = Uri.parse(baseUrl);
      final token = await TokenStorage.getToken();
      print('💡 Token: $token');

      final headers = {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
        if (extraHeaders != null) ...extraHeaders,
      };

      final response = await _client.get(uri, headers: headers);
      print('💡 Response status: ${response.statusCode}');
      print('💡 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final employeesData = data['data'] as List? ?? [];
        print('💡 Employees JSON count: ${employeesData.length}');
        final employees =
        employeesData.map((e) => EmployeeModel.fromJson(e)).toList();

        employeesCache = employees.reversed.toList();
        print('💡 Employees loaded count: ${employeesCache.length}');
        emit(EmployeeLoaded(employeesCache));
      } else {
        String err = 'فشل في جلب الموظفين (${response.statusCode})';
        try {
          final data = jsonDecode(response.body);
          if (data is Map && data['message'] is String) err = data['message'];
        } catch (_) {}
        print('❌ $err');
        emit(EmployeeError(err));
      }
    } catch (e, st) {
      print('❌ Exception in fetchEmployees: $e\n$st');
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
    Map<String, String>? extraHeaders,
  }) async {
    print('💡 addEmployee started: $name');
    emit(const EmployeeAdding());
    try {
      final uri = Uri.parse(baseUrl);
      final token = await TokenStorage.getToken();

      final payload = {
        "name": name,
        "email": email,
        "password": password,
        "password_confirmation": passwordConfirmation,
        "role": role,
        "department_id": departmentId,
        "hire_date": hireDate,
      };


      final headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
        if (extraHeaders != null) ...extraHeaders,
      };

      final response = await _client.post(uri,
          headers: headers, body: jsonEncode(payload));

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = jsonDecode(response.body);
        emit(EmployeeAdded(data['data']));
        await fetchEmployees();
      } else {
        String err = 'فشل الإرسال (${response.statusCode})';
        try {
          final data = jsonDecode(response.body);
          if (data is Map && data['message'] is String) err = data['message'];
          else if (data is Map && data['errors'] != null) {
            err = data['errors'].toString();
          }
        } catch (_) {}
        emit(EmployeeAddError(err));
      }
    } catch (e, st) {
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
    Map<String, String>? extraHeaders,
  }) async {
    print('💡 updateEmployee started: id=$id');
    emit(const EmployeeUpdating());
    try {
      final uri = Uri.parse('$baseUrl/$id');
      final token = await TokenStorage.getToken();

      final payload = {
        "name": name,
        if (password != null && password.isNotEmpty) "password": password,
        if (passwordConfirmation != null &&
            passwordConfirmation.isNotEmpty) ...{
          "password_confirmation": passwordConfirmation
        },
        "email":email,
        "role": role,
        "department_id": departmentId,
        "hire_date": hireDate,
      };

      final headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
        if (extraHeaders != null) ...extraHeaders,
      };

      final response = await _client.put(uri,
          headers: headers, body: jsonEncode(payload));

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = jsonDecode(response.body);
        emit(EmployeeUpdated(data['data']));
        await fetchEmployees();
      } else {
        String err = 'فشل التعديل (${response.statusCode})';
        try {
          final data = jsonDecode(response.body);
          if (data is Map && data['message'] is String) err = data['message'];
          else if (data is Map && data['errors'] != null) {
            err = data['errors'].toString();
          }
        } catch (_) {}
        emit(EmployeeUpdateError(err));
      }
    } catch (e, st) {
      emit(EmployeeUpdateError(e.toString()));
    }
  }

  /// ----------------- Fetch Archived Employees -----------------
  Future<void> fetchArchivedEmployees({Map<String, String>? extraHeaders}) async {
    print('💡 fetchArchivedEmployees started');
    emit(const ArchivedEmployeesLoading());
    try {
      final uri = Uri.parse('$baseUrl/archives');
      final token = await TokenStorage.getToken();

      final headers = {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
        if (extraHeaders != null) ...extraHeaders,
      };

      final response = await _client.get(uri, headers: headers);
      print('💡 Response status: ${response.statusCode}');
      print('💡 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);

        List<dynamic> employeesData = [];
        if (decoded is Map && decoded['data'] != null) {
          if (decoded['data'] is List) {
            employeesData = decoded['data'];
          } else if (decoded['data'] is Map) {
            employeesData = (decoded['data'] as Map).values.toList();
          }
        } else if (decoded is List) {
          employeesData = decoded;
        }

        archivedCache = employeesData.map((e) => EmployeeModel.fromJson(e)).toList();
        print('💡 Archived employees loaded count: ${archivedCache.length}');
        emit(ArchivedEmployeesLoaded(archivedCache));
      } else {
        emit(ArchivedEmployeesError('فشل في تحميل المؤرشفين (${response.statusCode})'));
      }
    } catch (e, st) {
      emit(ArchivedEmployeesError(e.toString()));
    }
  }

  /// ----------------- Toggle Archive Employee -----------------
  Future<void> toggleArchiveEmployee(
      {required int id, required bool isArchiveMode}) async {
    print('💡 toggleArchiveEmployee called, id=$id, isArchiveMode=$isArchiveMode');
    emit(const EmployeeArchiving());
    try {
      final uri = Uri.parse('$baseUrl/$id/toggle-archive');
      final token = await TokenStorage.getToken();

      final response = await _client.post(uri, headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      });

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        emit(EmployeeArchivedSuccessfully(data['message'] ?? 'تمت العملية بنجاح'));
        if (isArchiveMode) {
          await fetchArchivedEmployees();
        } else {
          await fetchEmployees();
        }
      } else {
        emit(EmployeeArchiveError('فشل في العملية (${response.statusCode})'));
      }
    } catch (e, st) {
      emit(EmployeeArchiveError(e.toString()));
    }
  }

  /// ----------------- Search Employees -----------------
  Future<void> searchEmployees(
      {required String query, Map<String, String>? extraHeaders}) async {
    print('💡 searchEmployees called, query="$query"');
    emit(const EmployeeSearching());

    if (query.isEmpty) {
      emit(EmployeeSearchResults(employeesCache));
      return;
    }

    try {
      final uri = Uri.parse('$baseUrl/search?search=$query');
      final token = await TokenStorage.getToken();

      final headers = {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
        if (extraHeaders != null) ...extraHeaders,
      };

      final response = await _client.get(uri, headers: headers);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final employeesData = (data['data'] as List?) ?? [];
        final employees =
        employeesData.map((e) => EmployeeModel.fromJson(e)).toList();
        emit(EmployeeSearchResults(employees));
      } else {
        emit(EmployeeSearchResults([]));
      }
    } catch (e, st) {
      emit(EmployeeSearchResults([]));
    }
  }
}
