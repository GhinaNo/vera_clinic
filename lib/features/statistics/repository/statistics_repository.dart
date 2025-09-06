import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/constant/ApiConstants.dart';
import '../../../core/services/token_storage.dart';
import '../models/client_count_model.dart';
import '../models/popular_service_model.dart';

class StatisticsRepository {
  StatisticsRepository();

  Future<ClientCountModel> fetchClientCount({
    required String startDate,
    required String endDate,
  }) async {
    final token = await TokenStorage.getToken();

    final response = await http.post(
      Uri.parse(ApiConstants.fetchClientCountUrl()),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'start_date': startDate,
        'end_date': endDate,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return ClientCountModel.fromJson(data);
    } else {
      throw Exception('Failed to fetch client count: ${response.statusCode}');
    }
  }

  Future<List<PopularServiceModel>> fetchPopularServices() async {
    final token = await TokenStorage.getToken();

    final response = await http.get(
      Uri.parse(ApiConstants.fetchPopularServicesUrl()),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final list = data['data'] ?? [];
      return list.map<PopularServiceModel>((e) => PopularServiceModel.fromJson(e)).toList();
    } else {
      throw Exception('Failed to fetch popular services: ${response.statusCode}');
    }
  }
}
