import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageHelper {
  static const _archivedInvoicesKey = 'archived_invoices';

  static Future<void> saveArchivedInvoiceIds(List<String> ids) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_archivedInvoicesKey, jsonEncode(ids));
  }

  static Future<List<String>> getArchivedInvoiceIds() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_archivedInvoicesKey);
    if (jsonString == null) return [];
    return List<String>.from(jsonDecode(jsonString));
  }
}
