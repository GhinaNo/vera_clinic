import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/model_user.dart';
import '../../../core/constant/ApiConstants.dart';

class ClientRepository {
  final String token;
  ClientRepository({required this.token});

  Map<String, String> get _headers => {
    'Authorization': 'Bearer $token',
    'Accept': 'application/json',
    'Content-Type': 'application/json',
  };

  /// ---------------- جلب جميع العملاء ----------------
  Future<List<Client>> fetchClients() async {
    print('fetchClients: بدء جلب العملاء');
    final response = await http.get(
      Uri.parse(ApiConstants.showUsersUrl()),
      headers: _headers,
    );
    print('fetchClients: statusCode = ${response.statusCode}');
    print('fetchClients: body = ${response.body}');
    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      final data = decoded['data'];

      if (data is List) {
        final clients = data
            .map((e) => Client.fromJson(Map<String, dynamic>.from(e)))
            .toList();
        print('fetchClients: جلب ${clients.length} عميل');
        return clients;
      } else if (data is Map) {
        final clients = data.values
            .map((e) => Client.fromJson(Map<String, dynamic>.from(e)))
            .toList();
        print('fetchClients: جلب ${clients.length} عميل (map)');
        return clients;
      } else {
        throw Exception('شكل بيانات غير متوقع: ${data.runtimeType}');
      }
    } else {
      throw Exception('فشل جلب العملاء');
    }
  }

  /// ---------------- جلب عميل محدد ----------------
  Future<Client> showClient(int id) async {
    print('showClient: بدء جلب العميل ID=$id');
    final response = await http.get(
      Uri.parse(ApiConstants.showUserUrl(id)),
      headers: _headers,
    );
    print('showClient: statusCode = ${response.statusCode}');
    print('showClient: body = ${response.body}');
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body)['data'];
      final client = Client.fromJson(Map<String, dynamic>.from(data));
      print('showClient: تم جلب العميل ${client.name}');
      return client;
    } else {
      throw Exception('فشل جلب العميل');
    }
  }

  /// ---------------- إضافة عميل جديد ----------------
  Future<Client> addClient(Client client) async {
    print('addClient: إضافة عميل ${client.name}');
    final response = await http.post(
      Uri.parse(ApiConstants.addUserUrl()),
      headers: _headers,
      body: jsonEncode({
        'name': client.name,
        'email': client.email,
      }),
    );
    print('addClient: statusCode = ${response.statusCode}');
    print('addClient: body = ${response.body}');
    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body)['data'];
      final newClient = Client.fromJson(Map<String, dynamic>.from(data));
      print('addClient: تم إضافة العميل ${newClient.name}');
      return newClient;
    } else {
      throw Exception('فشل إضافة العميل');
    }
  }

  /// ---------------- تبديل حالة العميل (حظر/فك) ----------------
  Future<void> toggleStatus(int id) async {
    print('toggleStatus: تبديل حالة العميل ID=$id');
    final response = await http.post(
      Uri.parse(ApiConstants.toggleUserStatusUrl(id)),
      headers: _headers,
    );
    print('toggleStatus: statusCode = ${response.statusCode}');
    print('toggleStatus: body = ${response.body}');
    final decoded = jsonDecode(response.body);
    if (response.statusCode != 200 || decoded['status'] != 1) {
      throw Exception('فشل تبديل حالة العميل: ${decoded['message']}');
    } else {
      print('toggleStatus: تم تبديل الحالة بنجاح');
    }
  }

  /// ---------------- البحث عن العملاء ----------------
  Future<List<Client>> searchClient(String query) async {
    print('searchClient: البحث عن "$query"');
    final response = await http.post(
      Uri.parse(ApiConstants.searchUserUrl()),
      headers: _headers,
      body: jsonEncode({'search': query}),
    );

    print('searchClient: statusCode = ${response.statusCode}');
    print('searchClient: body = ${response.body}');

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      final data = decoded['data'];

      List<Client> clients = [];

      if (data is List) {
        clients = data
            .map((e) => Client.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      } else if (data is Map) {
        clients = data.values
            .map((e) => Client.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      } else {
        print('searchClient: شكل بيانات غير متوقع');
      }

      print('searchClient: تم العثور على ${clients.length} عميل');
      return clients;
    } else {
      throw Exception('فشل البحث عن العملاء');
    }
  }
}
