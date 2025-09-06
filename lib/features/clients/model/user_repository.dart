import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/model_user.dart';
import '../../../core/constant/ApiConstants.dart';

class ClientRepository {
  final String token;
  ClientRepository({required this.token});

  // 1- fetch all clients
  Future<List<Client>> fetchClients() async {
    print('fetchClients: بدء جلب العملاء');
    final response = await http.get(
      Uri.parse(ApiConstants.showUsersUrl()),
      headers: {'Authorization': 'Bearer $token'},
    );
    print('fetchClients: statusCode = ${response.statusCode}');
    print('fetchClients: body = ${response.body}');
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body)['data'] as Map<String, dynamic>;
      final clients = data.values
          .map((e) => Client.fromJson(Map<String, dynamic>.from(e)))
          .toList();
      print('fetchClients: جلب ${clients.length} عملاء');
      return clients;
    } else {
      throw Exception('فشل جلب العملاء');
    }
  }

  // 2- show single client
  Future<Client> showClient(int id) async {
    print('showClient: بدء جلب العميل ID=$id');
    final response = await http.get(
      Uri.parse(ApiConstants.showUserUrl(id)),
      headers: {'Authorization': 'Bearer $token'},
    );
    print('showClient: statusCode = ${response.statusCode}');
    print('showClient: body = ${response.body}');
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body)['data'].values.first;
      final client = Client.fromJson(Map<String, dynamic>.from(data));
      print('showClient: تم جلب العميل ${client.name}');
      return client;
    } else {
      throw Exception('فشل جلب العميل');
    }
  }

  // 3- add client
  Future<Client> addClient(Client client) async {
    print('addClient: إضافة عميل ${client.name}');
    final response = await http.post(
      Uri.parse(ApiConstants.addUserUrl()),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'name': client.name,
        'email': client.email,
      }),
    );
    print('addClient: statusCode = ${response.statusCode}');
    print('addClient: body = ${response.body}');
    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body)['data'].values.first;
      final newClient = Client.fromJson(Map<String, dynamic>.from(data));
      print('addClient: تم إضافة العميل ${newClient.name}');
      return newClient;
    } else {
      throw Exception('فشل إضافة العميل');
    }
  }

  // 4- toggle status (block/unblock)
  Future<void> toggleStatus(int id) async {
    print('toggleStatus: تبديل حالة العميل ID=$id');
    final response = await http.post(
      Uri.parse(ApiConstants.toggleUserStatusUrl(id)),
      headers: {'Authorization': 'Bearer $token'},
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

  // 5- search clients
  Future<List<Client>> searchClient(String query) async {
    print('searchClient: البحث عن "$query"');
    final response = await http.post(
      Uri.parse(ApiConstants.searchUserUrl()),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'search': query}),
    );

    print('searchClient: statusCode = ${response.statusCode}');
    print('searchClient: body = ${response.body}');

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      final data = decoded['data'];

      List<Client> clients = [];

      if (data is List) {
        clients = data.map((e) => Client.fromJson(Map<String, dynamic>.from(e))).toList();
      } else if (data is Map) {
        clients = data.values
            .map((e) => Client.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      } else {
        print('searchClient: شكل بيانات غير متوقع');
      }

      print('searchClient: تم العثور على ${clients.length} عملاء');
      return clients;
    } else {
      throw Exception('فشل البحث عن العملاء');
    }
  }
}
