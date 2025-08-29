import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/constant/ApiConstants.dart';
import '../models/department.dart';

class DepartmentsRepository {
  final String token;

  DepartmentsRepository({required this.token});

  // إضافة قسم
  Future<Department> addDepartment(Department department) async {
    final url = Uri.parse('${ApiConstants.baseUrl}/web/admin/departments');

    print('إرسال طلب إضافة القسم: ${department.name}');

    final response = await http.post(
      url,
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'name': department.name,
        'suite_no': department.suite_no,
        'description': department.description,
      }),
    );

    print('تم استلام الاستجابة من السيرفر، حالة الاستجابة: ${response.statusCode}');
    print('محتوى الاستجابة: ${response.body}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      final decoded = jsonDecode(response.body);
      final data = decoded['data'] ?? {};
      return Department(
        id: data['id'], // ← أضفنا الـ id هنا
        name: data['name'] ?? department.name,
        suite_no: data['suite_no'] ?? department.suite_no,
        description: data['description'] ?? department.description,
      );
    } else {
      throw Exception('فشل إضافة القسم: ${response.body}');
    }
  }

// تحديث قسم
  Future<Department> updateDepartment(int id, Department department) async {
    final url = Uri.parse('${ApiConstants.baseUrl}/web/admin/departments/$id');

    print('إرسال طلب تحديث القسم: ${department.name}');

    final response = await http.post(
      url,
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'name': department.name,
        'suite_no': department.suite_no,
        'description': department.description,
      }),
    );

    print('تم استلام الاستجابة من السيرفر، حالة الاستجابة: ${response.statusCode}');
    print('محتوى الاستجابة: ${response.body}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      final decoded = jsonDecode(response.body);
      final data = decoded['data'] ?? {};
      return Department(
        id: data['id'],
        name: data['name'] ?? department.name,
        suite_no: data['suite_no'] ?? department.suite_no,
        description: data['description'] ?? department.description,
      );
    } else {
      throw Exception('فشل تحديث القسم: ${response.body}');
    }
  }

  // حذف قسم
  Future<void> deleteDepartment(int id) async {
    final url = Uri.parse('${ApiConstants.baseUrl}/web/admin/departments/$id');

    print('إرسال طلب حذف القسم: $id');

    final response = await http.delete(
      url,
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    print('تم استلام الاستجابة من السيرفر، حالة الاستجابة: ${response.statusCode}');
    print('محتوى الاستجابة: ${response.body}');

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('فشل حذف القسم: ${response.body}');
    }
  }

  // جلب كل الأقسام
  Future<List<Department>> showDepartments() async {
    final url = Uri.parse('${ApiConstants.baseUrl}/web/admin/departments');

    final response = await http.get(
      url,
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      final dataList = decoded['data'] as List? ?? [];

      return dataList.map((data) => Department(
        id: data['id'],
        name: data['name'] ?? '',
        suite_no: data['suite_no'] ?? '',
        description: data['description'] ?? '',
      )).toList();
    } else {
      throw Exception('فشل جلب الأقسام: ${response.body}');
    }
  }

  // جلب قسم واحد
  Future<Department> showDepartment(int id) async {
    final url = Uri.parse('${ApiConstants.baseUrl}/web/admin/departments/$id');

    final response = await http.get(
      url,
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      final data = decoded['data'] ?? {};
      return Department(
        id: data['id'],
        name: data['name'] ?? '',
        suite_no: data['suite_no'] ?? '',
        description: data['description'] ?? '',
      );
    } else {
      throw Exception('فشل جلب القسم: ${response.body}');
    }
  }
}


