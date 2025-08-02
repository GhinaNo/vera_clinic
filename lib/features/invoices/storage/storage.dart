import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/invoice_model.dart';

class InvoiceStorage {
  static const String key = 'invoices_data';

  static Future<void> saveInvoices(List<Invoice> invoices) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(invoices.map((e) => e.toJson()).toList());
    await prefs.setString(key, encoded);
  }

  static Future<List<Invoice>> loadInvoices() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(key);

    if (data == null) return [];

    try {
      final decoded = jsonDecode(data) as List<dynamic>;
      return decoded.map((e) => Invoice.fromJson(e)).toList();
    } catch (e) {
      return [];
    }
  }
}
