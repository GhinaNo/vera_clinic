import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/constant/ApiConstants.dart';
import '../models/payment_model.dart';

class PaymentRepository {
  final String token;

  PaymentRepository({required this.token});

  Map<String, String> get _headers => {
    'Accept': 'application/json',
    'Authorization': 'Bearer $token',
  };

  Future<Payment> addPayment(int invoiceId, double amount) async {
    print('Adding payment of $amount to invoice $invoiceId...');
    final response = await http.post(
      Uri.parse(ApiConstants.addPaymentUrl(invoiceId)),
      headers: _headers,
      body: {'amount': amount.toString()},
    );
    print('Status code: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      print('Payment added successfully');
      return Payment.fromJson(jsonDecode(response.body));
    } else {
      print('Failed to add payment');
      throw Exception('Failed to add payment');
    }
  }

  Future<List<Payment>> fetchPayments() async {
    print('Fetching all payments...');
    final response =
    await http.get(Uri.parse(ApiConstants.showPaymentsUrl()), headers: _headers);
    print('Status code: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as List;
      print('Fetched ${data.length} payments');
      return data.map((e) => Payment.fromJson(e)).toList();
    } else {
      print('Failed to fetch payments');
      throw Exception('Failed to fetch payments');
    }
  }

  Future<Payment> fetchPayment(int id) async {
    print('Fetching payment $id...');
    final response =
    await http.get(Uri.parse(ApiConstants.showPaymentUrl(id)), headers: _headers);
    print('Status code: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      print('Payment $id fetched successfully');
      return Payment.fromJson(jsonDecode(response.body));
    } else {
      print('Failed to fetch payment $id');
      throw Exception('Failed to fetch payment $id');
    }
  }
}
