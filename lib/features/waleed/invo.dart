import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'api.dart'; 

class InvoicePage extends StatefulWidget {
  final String token;

  const InvoicePage({super.key, required this.token});

  @override
  State<InvoicePage> createState() => _InvoicePageState();
}

class _InvoicePageState extends State<InvoicePage> {
  List<dynamic> invoices = [];
  List<dynamic> allInvoices = [];
  bool isLoading = true;
  bool showArchives = false;
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchInvoices();
  }

  Future<void> fetchInvoices() async {
    setState(() => isLoading = true);
    final url = Uri.parse("$baseUrl/web/invoices");
    final response = await http.get(url, headers: {
      "Accept": "application/json",
      "Authorization": "Bearer ${widget.token}",
    });

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      setState(() {
        allInvoices = body["data"];
        invoices = allInvoices;
        isLoading = false;
        showArchives = false;
      });
    } else {
      setState(() => isLoading = false);
      throw Exception("فشل في الحصول الفواتير");
    }
  }

  Future<void> fetchArchives() async {
    setState(() => isLoading = true);
    final url = Uri.parse("$baseUrl/web/archives");
    final response = await http.get(url, headers: {
      "Accept": "application/json",
      "Authorization": "Bearer ${widget.token}",
    });

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      setState(() {
        allInvoices = body["data"];
        invoices = allInvoices;
        isLoading = false;
        showArchives = true;
      });
    } else {
      setState(() => isLoading = false);
      throw Exception("فشل في الحصول على الأرشيف");
    }
  }

  Future<void> archiveInvoice(int invoiceId) async {
    final url = Uri.parse("$baseUrl/web/invoice-archive/$invoiceId");
    final response = await http.get(url, headers: {
      "Accept": "application/json",
      "Authorization": "Bearer ${widget.token}",
    });

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      if (body["status"] == 1) {
        await fetchInvoices();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("تم أرشفة الفاتورة")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(body["message"] ?? "فشل في الأرشفة")),
        );
      }
    } else {
      throw Exception("فشل في الأرشفة");
    }
  }

  Future<void> restoreInvoice(int invoiceId) async {
    final url = Uri.parse("$baseUrl/web/restore-invoice/$invoiceId");
    final response = await http.get(url, headers: {
      "Accept": "application/json",
      "Authorization": "Bearer ${widget.token}",
    });

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      if (body["status"] == 1) {
        await fetchArchives();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("تم استرجاع الفاتورة")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(body["message"] ?? "فشل في الاسترجاع")),
        );
      }
    } else {
      throw Exception("فشل في الاسترجاع");
    }
  }

  Future<void> makePayment(int invoiceId, double amount) async {
    final url = Uri.parse("$baseUrl/web/invoice/$invoiceId/payment");
    final response = await http.post(url,
        headers: {
          "Accept": "application/json",
          "Authorization": "Bearer ${widget.token}",
          "Content-Type": "application/json"
        },
        body: jsonEncode({"amount": amount}));

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      if (body["status"] == 1) {
        await fetchInvoices();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("نجحت العملية")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(body["message"] ?? "فشل عمل الدفع")),
        );
      }
    } else {
      throw Exception("اكسبشن بالدفع");
    }
  }

  void showPaymentDialog(int invoiceId, double remainingAmount) {
    final TextEditingController amountController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Add Payment"),
          content: TextField(
            controller: amountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: "Amount",
              hintText:
                  "ادخل مبلغ الدفع (max \$${remainingAmount.toStringAsFixed(2)})",
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                final amount = double.tryParse(amountController.text);
                if (amount == null || amount <= 0 || amount > remainingAmount) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text(
                            "ادخل عدد صحيح \$${remainingAmount.toStringAsFixed(2)}")),
                  );
                  return;
                }
                Navigator.pop(context);
                try {
                  await makePayment(invoiceId, amount);
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(e.toString())),
                  );
                }
              },
              child: const Text("Submit"),
            ),
          ],
        );
      },
    );
  }

  void filterInvoices(String query) {
    query = query.toLowerCase();
    setState(() {
      invoices = allInvoices.where((invoice) {
        final userId = invoice["user_id"].toString();
        final serviceName =
            (invoice["booking"]?["service"]?["name"] ?? "").toString().toLowerCase();
        return userId.contains(query) || serviceName.contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(showArchives ? "Archives" : "Invoices"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.purple),
            onPressed: showArchives ? fetchArchives : fetchInvoices,
          ),
          IconButton(
            icon: Icon(
              showArchives ? Icons.list : Icons.archive,
              color: Colors.purple,
            ),
            onPressed: showArchives ? fetchInvoices : fetchArchives,
            tooltip: showArchives ? "Show Invoices" : "Show Archives",
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      labelText: "Search by User ID or Service Name",
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      suffixIcon: searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                searchController.clear();
                                filterInvoices("");
                              },
                            )
                          : null,
                    ),
                    onChanged: filterInvoices,
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 1.3,
                      ),
                      itemCount: invoices.length,
                      itemBuilder: (context, index) {
                        final invoice = invoices[index];

                        final id = "#INV${invoice["id"]}";
                        final userId = invoice["user_id"];
                        final status = invoice["status"] ?? "";
                        final name =
                            invoice["booking"]?["service"]?["name"] ?? "No Name";
                        final total =
                            double.tryParse(invoice["total_amount"].toString()) ?? 0.0;
                        final paid =
                            double.tryParse(invoice["paid_amount"].toString()) ?? 0.0;
                        final remaining =
                            double.tryParse(invoice["remaining_amount"].toString()) ?? (total - paid);
                        final payments = invoice["payments"] ?? [];

                        return Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(color: Colors.grey.shade200),
                          ),
                          elevation: 2,
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Status: $status",
                                    style: const TextStyle(
                                        color: Colors.blueGrey,
                                        fontWeight: FontWeight.bold)),
                                const SizedBox(height: 4),
                                Text("User ID: $userId",
                                    style: TextStyle(color: Colors.grey.shade600)),
                                const SizedBox(height: 4),
                                Text("Invoice No.",
                                    style: TextStyle(color: Colors.grey.shade600)),
                                Text(id,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.purple)),
                                const SizedBox(height: 4),
                                Text(name,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold, fontSize: 16)),
                                const Divider(height: 20),
                                Text("Total Amount: \$${total.toStringAsFixed(2)}"),
                                Text("Paid Amount: \$${paid.toStringAsFixed(2)}"),
                                Text(
                                  "Remaining: \$${remaining.toStringAsFixed(2)}",
                                  style: TextStyle(
                                    color: remaining > 0 ? Colors.red : Colors.green,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                if (payments.isNotEmpty)
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text("Payments:",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold)),
                                      ...payments.map((p) {
                                        final amount = double.tryParse(p["amount"].toString()) ?? 0.0;
                                        final date = p["payment_date"] ?? "";
                                        return Text("- \$${amount.toStringAsFixed(2)} on $date",
                                            style: const TextStyle(fontSize: 12));
                                      }).toList(),
                                    ],
                                  ),
                                const Spacer(),
                                Row(
                                  children: [
                                    if (!showArchives)
                                      Expanded(
                                        child: ElevatedButton(
                                          onPressed: remaining > 0
                                              ? () => showPaymentDialog(invoice["id"], remaining)
                                              : null,
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.purple,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                          ),
                                          child: const Text(
                                            "Add Payment",
                                            style: TextStyle(color: Colors.white),
                                          ),
                                        ),
                                      ),
                                    if (!showArchives) const SizedBox(width: 8),
                                    OutlinedButton(
                                      onPressed: () {
                                        if (showArchives) {
                                          restoreInvoice(invoice["id"]);
                                        } else {
                                          archiveInvoice(invoice["id"]);
                                        }
                                      },
                                      style: OutlinedButton.styleFrom(
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                      ),
                                      child: Text(showArchives ? "Restore" : "Archive"),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
