import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/payment_model.dart';
import '../../../core/constant/ApiConstants.dart';

class PaymentRepository {
  final http.Client client;

  PaymentRepository({required this.client});

  Future<List<Payment>> fetchPayments() async {
    print("Fetching all payments...");
    final response = await client.get(
      Uri.parse(ApiConstants.showPaymentsUrl()),
      headers: {'Accept': 'application/json'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body)['data'] as List;
      final payments = data.map((e) => Payment.fromJson(e)).toList();
      print("Fetched ${payments.length} payments.");
      return payments;
    } else {
      print("Failed to fetch payments: ${response.body}");
      throw Exception('Failed to fetch payments');
    }
  }

  Future<Payment> addPayment(int bookingId, double amount) async {
    print("Adding payment of $amount to booking $bookingId...");
    final response = await http.post(
      Uri.parse(ApiConstants.addPaymentUrl(bookingId)),
      headers: {'Accept': 'application/json'},
      body: {'amount': amount.toString()},
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body)['data'];
      print("Payment added successfully: $data");
      return Payment.fromJson(data);
    } else {
      print("Failed to add payment: ${response.body}");
      throw Exception('Failed to add payment');
    }
  }

  Future<Payment> getPayment(int id) async {
    print("Fetching payment with id $id...");
    final response = await client.get(
      Uri.parse(ApiConstants.showPaymentUrl(id)),
      headers: {'Accept': 'application/json'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body)['data'];
      print("Fetched payment: $data");
      return Payment.fromJson(data);
    } else {
      print("Failed to fetch payment: ${response.body}");
      throw Exception('Failed to fetch payment');
    }
  }
}
