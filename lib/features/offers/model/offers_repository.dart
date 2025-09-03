import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/constant/ApiConstants.dart';
import 'offersModel.dart';

class OffersRepository {
  final String token;

  OffersRepository({required this.token});

  Map<String, String> get _headers => {
    'Accept': 'application/json',
    'Authorization': 'Bearer $token',
    'Content-Type': 'application/json',
  };

  // جلب كل العروض
  Future<List<Offer>> fetchOffers({String status = 'all'}) async {
    final url = Uri.parse(ApiConstants.showOffersUrl());
    print('Fetching offers with status: $status from $url');

    final response = await http.post(
      url,
      headers: _headers,
      body: jsonEncode({'status': status}),
    );

    print('Response status code: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['status'] == 1) {
        final List offers = data['data'] ?? [];
        print('Fetched ${offers.length} offers successfully');
        return offers.map((json) => Offer.fromJson(json)).toList();
      } else {
        print('Failed to fetch offers: ${data['message']}');
        throw Exception(data['message'] ?? 'Failed to fetch offers');
      }
    } else {
      print('HTTP error while fetching offers: ${response.statusCode}');
      throw Exception('Failed to fetch offers: ${response.statusCode}');
    }
  }

  // جلب عرض واحد
  Future<Offer> fetchOfferById(String id) async {
    final url = Uri.parse(ApiConstants.showOfferUrl(int.parse(id)));
    print('Fetching offer with ID: $id from $url');

    final response = await http.get(url, headers: _headers);
    print('Response status code: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['status'] == 1) {
        print('Offer fetched successfully: ${data['data']}');
        return Offer.fromJson(data['data']);
      } else {
        print('Failed to fetch offer: ${data['message']}');
        throw Exception(data['message'] ?? 'Failed to fetch offer');
      }
    } else {
      print('HTTP error while fetching offer: ${response.statusCode}');
      throw Exception('Failed to fetch offer: ${response.statusCode}');
    }
  }

  // إضافة عرض
  Future<Offer> addOffer(Offer offer) async {
    final url = Uri.parse(ApiConstants.addOfferUrl());
    print('Adding new offer: ${offer.toJson()} to $url');

    final response = await http.post(url, headers: _headers, body: jsonEncode(offer.toJson()));

    print('Response status code: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['status'] == 1) {
        print('Offer added successfully: ${data['data']}');
        return Offer.fromJson(data['data']);
      } else {
        print('Failed to add offer: ${data['message']}');
        throw Exception(data['message'] ?? 'Failed to add offer');
      }
    } else {
      print('HTTP error while adding offer: ${response.statusCode}');
      throw Exception('Failed to add offer: ${response.statusCode}');
    }
  }

  // تحديث عرض
  Future<Offer> updateOffer(Offer offer) async {
    final url = Uri.parse(ApiConstants.updateOfferUrl(int.parse(offer.id)));
    print('Updating offer: ${offer.toJson()} at $url');

    final response = await http.post(url, headers: _headers, body: jsonEncode(offer.toJson()));

    print('Response status code: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['status'] == 1) {
        print('Offer updated successfully: ${data['data']}');
        return Offer.fromJson(data['data']);
      } else {
        print('Failed to update offer: ${data['message']}');
        throw Exception(data['message'] ?? 'Failed to update offer');
      }
    } else {
      print('HTTP error while updating offer: ${response.statusCode}');
      throw Exception('Failed to update offer: ${response.statusCode}');
    }
  }

  // حذف عرض
  Future<void> deleteOffer(String id) async {
    final url = Uri.parse(ApiConstants.deleteOfferUrl(int.parse(id)));
    print('--- DELETE OFFER START ---');
    print('Offer ID: $id');
    print('URL: $url');
    print('Headers: $_headers');

    try {
      final response = await http.delete(url, headers: _headers);

      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('Decoded response: $data');

        if (data['status'] == 1) {
          print('✅ Offer deleted successfully on server');
        } else {
          print('❌ Failed to delete offer on server: ${data['message']}');
          throw Exception(data['message'] ?? 'Failed to delete offer');
        }
      } else if (response.statusCode == 404) {
        print('❌ Not found - Check your URL or ID');
        throw Exception('Offer not found');
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        print('❌ Unauthorized - Check your token or permissions');
        throw Exception('Unauthorized');
      } else {
        print('❌ HTTP error: ${response.statusCode}');
        throw Exception('Failed to delete offer: ${response.statusCode}');
      }
    } catch (e) {
      print('Exception during deleteOffer: $e');
      rethrow;
    } finally {
      print('--- DELETE OFFER END ---');
    }
  }
}
