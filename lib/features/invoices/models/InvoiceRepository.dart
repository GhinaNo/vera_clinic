import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/constant/ApiConstants.dart';
import '../models/invoice_model.dart';

class InvoiceRepository {
  final http.Client client;

  InvoiceRepository({required this.client});

  Future<List<Invoice>> getInvoices() async {
    print("Fetching all invoices...");
    final response = await client.get(
      Uri.parse(ApiConstants.showInvoicesUrl()),
      headers: {'Accept': 'application/json'},
    );
    final data = jsonDecode(response.body);
    if (data['status'] == 1) {
      print("Fetched ${data['data'].length} invoices.");
      return (data['data'] as List).map((e) => Invoice.fromJson(e)).toList();
    } else {
      print("Failed to fetch invoices: ${data['message']}");
      throw Exception(data['message']);
    }
  }

  Future<Invoice> getInvoice(int id) async {
    print("Fetching invoice with id: $id");
    final response = await client.get(
      Uri.parse(ApiConstants.showInvoiceUrl(id)),
      headers: {'Accept': 'application/json'},
    );
    final data = jsonDecode(response.body);
    if (data['status'] == 1) {
      print("Invoice $id fetched successfully.");
      return Invoice.fromJson(data['data']);
    } else {
      print("Failed to fetch invoice $id: ${data['message']}");
      throw Exception(data['message']);
    }
  }

  /// تم تعديلها لتستخدم Booking ID
  Future<Invoice> createInvoice(int bookingId) async {
    print("Creating invoice for booking id: $bookingId");
    final response = await client.post(
      Uri.parse(ApiConstants.createInvoiceUrl(bookingId)),
      headers: {'Accept': 'application/json'},
    );
    final data = jsonDecode(response.body);
    if (data['status'] == 1) {
      print("Invoice created successfully with id: ${data['data']['id']}");
      return Invoice.fromJson(data['data']);
    } else {
      print("Failed to create invoice: ${data['message']}");
      throw Exception(data['message']);
    }
  }

  Future<void> archiveInvoice(int id) async {
    print("Archiving invoice with id: $id");
    final response = await client.get(
      Uri.parse(ApiConstants.archiveInvoiceUrl(id)),
      headers: {'Accept': 'application/json'},
    );
    final data = jsonDecode(response.body);
    if (data['status'] == 1) {
      print("Invoice $id archived successfully.");
    } else {
      print("Failed to archive invoice $id: ${data['message']}");
      throw Exception(data['message']);
    }
  }

  Future<void> restoreInvoice(int id) async {
    print("Restoring invoice with id: $id");
    final response = await client.get(
      Uri.parse(ApiConstants.restoreInvoiceUrl(id)),
      headers: {'Accept': 'application/json'},
    );
    final data = jsonDecode(response.body);
    if (data['status'] == 1) {
      print("Invoice $id restored successfully.");
    } else {
      print("Failed to restore invoice $id: ${data['message']}");
      throw Exception(data['message']);
    }
  }

  Future<List<Invoice>> getArchives() async {
    print("Fetching archived invoices...");
    final response = await client.get(
      Uri.parse(ApiConstants.showArchivesUrl()),
      headers: {'Accept': 'application/json'},
    );
    final data = jsonDecode(response.body);
    if (data['status'] == 1) {
      print("Fetched ${data['data'].length} archived invoices.");
      return (data['data'] as List).map((e) => Invoice.fromJson(e)).toList();
    } else {
      print("Failed to fetch archives: ${data['message']}");
      throw Exception(data['message']);
    }
  }

  Future<Invoice> getArchive(int id) async {
    print("Fetching archive invoice with id: $id");
    final response = await client.get(
      Uri.parse(ApiConstants.showArchiveUrl(id)),
      headers: {'Accept': 'application/json'},
    );
    final data = jsonDecode(response.body);
    if (data['status'] == 1) {
      print("Archive invoice $id fetched successfully.");
      return Invoice.fromJson(data['data']);
    } else {
      print("Failed to fetch archive invoice $id: ${data['message']}");
      throw Exception(data['message']);
    }
  }

  Future<Map<String, dynamic>> getReport({required String reportType, required String date}) async {
    print("Fetching report of type: $reportType for date: $date");
    final response = await client.post(
      Uri.parse(ApiConstants.reportsUrl()),
      headers: {'Accept': 'application/json'},
      body: {'report_type': reportType, 'date': date},
    );
    final data = jsonDecode(response.body);
    if (data['status'] == 1) {
      print("Report fetched successfully.");
      return data['data'];
    } else {
      print("Failed to fetch report: ${data['message']}");
      throw Exception(data['message']);
    }
  }
}
