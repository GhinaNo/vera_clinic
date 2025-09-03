// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import '../../../core/constant/ApiConstants.dart';
// import '../models/invoice_model.dart';
//
// class InvoiceRepository {
//   final String token;
//
//   InvoiceRepository({required this.token});
//
//   Map<String, String> get _headers => {
//     'Accept': 'application/json',
//     'Authorization': 'Bearer $token',
//   };
//
//   Future<List<Invoice>> fetchInvoices() async {
//     print('Fetching all invoices...');
//     final response =
//     await http.get(Uri.parse(ApiConstants.showInvoicesUrl()), headers: _headers);
//     print('Status code: ${response.statusCode}');
//     print('Response body: ${response.body}');
//
//     if (response.statusCode == 200) {
//       final data = jsonDecode(response.body) as List;
//       print('Fetched ${data.length} invoices');
//       return data.map((e) => Invoice.fromJson(e)).toList();
//     } else {
//       print('Failed to fetch invoices');
//       throw Exception('Failed to fetch invoices');
//     }
//   }
//
//   Future<Invoice> fetchInvoice(int id) async {
//     print('Fetching invoice with id: $id');
//     final response =
//     await http.get(Uri.parse(ApiConstants.showInvoiceUrl(id)), headers: _headers);
//     print('Status code: ${response.statusCode}');
//     print('Response body: ${response.body}');
//
//     if (response.statusCode == 200) {
//       print('Invoice $id fetched successfully');
//       return Invoice.fromJson(jsonDecode(response.body));
//     } else {
//       print('Failed to fetch invoice $id');
//       throw Exception('Failed to fetch invoice $id');
//     }
//   }
//
//   Future<Invoice> createInvoice(int id) async {
//     print('Creating invoice for id: $id');
//     final response =
//     await http.post(Uri.parse(ApiConstants.createInvoiceUrl(id)), headers: _headers);
//     print('Status code: ${response.statusCode}');
//     print('Response body: ${response.body}');
//
//     if (response.statusCode == 200 || response.statusCode == 201) {
//       print('Invoice created successfully');
//       return Invoice.fromJson(jsonDecode(response.body));
//     } else {
//       print('Failed to create invoice');
//       throw Exception('Failed to create invoice');
//     }
//   }
//
//   Future<void> archiveInvoice(int id) async {
//     print('Archiving invoice $id...');
//     final response =
//     await http.get(Uri.parse(ApiConstants.archiveInvoiceUrl(id)), headers: _headers);
//     print('Status code: ${response.statusCode}');
//
//     if (response.statusCode == 200) {
//       print('Invoice $id archived successfully');
//     } else {
//       print('Failed to archive invoice $id');
//       throw Exception('Failed to archive invoice $id');
//     }
//   }
//
//   Future<void> restoreInvoice(int id) async {
//     print('Restoring invoice $id...');
//     final response =
//     await http.get(Uri.parse(ApiConstants.restoreInvoiceUrl(id)), headers: _headers);
//     print('Status code: ${response.statusCode}');
//
//     if (response.statusCode == 200) {
//       print('Invoice $id restored successfully');
//     } else {
//       print('Failed to restore invoice $id');
//       throw Exception('Failed to restore invoice $id');
//     }
//   }
//
//   Future<List<Invoice>> fetchArchivedInvoices() async {
//     print('Fetching archived invoices...');
//     final response =
//     await http.get(Uri.parse(ApiConstants.showArchivesUrl()), headers: _headers);
//     print('Status code: ${response.statusCode}');
//     print('Response body: ${response.body}');
//
//     if (response.statusCode == 200) {
//       final data = jsonDecode(response.body) as List;
//       print('Fetched ${data.length} archived invoices');
//       return data.map((e) => Invoice.fromJson(e)).toList();
//     } else {
//       print('Failed to fetch archived invoices');
//       throw Exception('Failed to fetch archived invoices');
//     }
//   }
//
//   Future<Invoice> fetchArchive(int id) async {
//     print('Fetching archive invoice $id...');
//     final response =
//     await http.get(Uri.parse(ApiConstants.showArchiveUrl(id)), headers: _headers);
//     print('Status code: ${response.statusCode}');
//     print('Response body: ${response.body}');
//
//     if (response.statusCode == 200) {
//       print('Archive invoice $id fetched successfully');
//       return Invoice.fromJson(jsonDecode(response.body));
//     } else {
//       print('Failed to fetch archive $id');
//       throw Exception('Failed to fetch archive $id');
//     }
//   }
//
//   Future<Map<String, dynamic>> getReports(String reportType, String date) async {
//     print('Fetching report type: $reportType for date: $date');
//     final response = await http.post(
//       Uri.parse(ApiConstants.reportsUrl()),
//       headers: _headers,
//       body: {
//         'report_type': reportType,
//         'date': date,
//       },
//     );
//     print('Status code: ${response.statusCode}');
//     print('Response body: ${response.body}');
//
//     if (response.statusCode == 200) {
//       print('Report fetched successfully');
//       return jsonDecode(response.body);
//     } else {
//       print('Failed to fetch report');
//       throw Exception('Failed to fetch report');
//     }
//   }
// }
