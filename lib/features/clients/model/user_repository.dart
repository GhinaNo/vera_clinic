import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/model_user.dart';
import '../../../core/constant/ApiConstants.dart';

class ClientRepository {
  final String token;

  ClientRepository({required this.token});

  Future<List<Client>> fetchClients() async {
    final url = ApiConstants.showUsersUrl();
    final response = await http.get(
      Uri.parse(url),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      final data = decoded['data'] as List;
      return data.map((e) => Client.fromJson(Map<String, dynamic>.from(e))).toList();
    } else {
      throw Exception('فشل جلب العملاء');
    }
  }

  Future<Client> addClient(Client client, String password, String passwordConfirmation) async {
    final url = ApiConstants.addUserUrl();
    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'name': client.name,
        'email': client.email,
        'password': password,
        'password_confirmation': passwordConfirmation,
      }),
    );

    final decoded = jsonDecode(response.body);
    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = decoded['data'];
      return Client.fromJson(Map<String, dynamic>.from(data));
    } else {
      throw Exception('فشل إضافة العميل: ${decoded['message']}');
    }
  }

  Future<Client> showClient(int id) async {
    final url = ApiConstants.showUserUrl(id);
    final response = await http.get(
      Uri.parse(url),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      final data = decoded['data'];
      return Client.fromJson(Map<String, dynamic>.from(data));
    } else {
      final decoded = jsonDecode(response.body);
      throw Exception('فشل جلب العميل: ${decoded['message']}');
    }
  }

  Future<void> toggleStatus(int id) async {
    final url = ApiConstants.toggleUserStatusUrl(id);
    final response = await http.post(
      Uri.parse(url),
      headers: {'Authorization': 'Bearer $token'},
    );

    final decoded = jsonDecode(response.body);
    if (response.statusCode != 200 || decoded['status'] != 1) {
      throw Exception('فشل تبديل حالة العميل: ${decoded['message']}');
    }
  }

  Future<List<Client>> searchClient(String query) async {
    final url = ApiConstants.searchUserUrl();
    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'search': query}),
    );

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      final data = decoded['data'] as List;
      return data.map((e) => Client.fromJson(Map<String, dynamic>.from(e))).toList();
    } else {
      throw Exception('فشل البحث عن العملاء');
    }
  }
}
